import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';

class PrintService {
  static const String _tag = 'PrintService';

  /// Verifica si la impresión está disponible en el dispositivo actual
  static Future<PrintCapability> checkPrintCapability() async {
    try {
      // Verificar si hay impresoras disponibles
      final printers = await Printing.listPrinters();

      if (printers.isNotEmpty) {
        return PrintCapability(
          isSupported: true,
          hasAvailablePrinters: true,
          printerCount: printers.length,
          supportedFormats: await _getSupportedFormats(),
          recommendedAction: PrintAction.directPrint,
          message:
              'Impresión disponible - ${printers.length} impresora(s) encontrada(s)',
        );
      } else {
        return PrintCapability(
          isSupported: true,
          hasAvailablePrinters: false,
          printerCount: 0,
          supportedFormats: await _getSupportedFormats(),
          recommendedAction: PrintAction.share,
          message: 'Impresión soportada pero no hay impresoras configuradas',
        );
      }
    } catch (e) {
      // Analizar el tipo de error
      if (e.toString().contains('does not support printing') ||
          e.toString().contains('application\'s developer')) {
        return PrintCapability(
          isSupported: false,
          hasAvailablePrinters: false,
          printerCount: 0,
          supportedFormats: [],
          recommendedAction: PrintAction.share,
          message: 'Impresión no soportada en esta plataforma',
          errorType: PrintErrorType.notSupported,
        );
      } else if (e.toString().contains('Permission')) {
        return PrintCapability(
          isSupported: false,
          hasAvailablePrinters: false,
          printerCount: 0,
          supportedFormats: [],
          recommendedAction: PrintAction.requestPermission,
          message: 'Se requieren permisos para acceder a las impresoras',
          errorType: PrintErrorType.permissionDenied,
        );
      } else {
        return PrintCapability(
          isSupported: false,
          hasAvailablePrinters: false,
          printerCount: 0,
          supportedFormats: [],
          recommendedAction: PrintAction.share,
          message:
              'Error al verificar capacidades de impresión: ${e.toString()}',
          errorType: PrintErrorType.unknown,
        );
      }
    }
  }

  /// Intenta imprimir un PDF con manejo robusto de errores
  static Future<PrintResult> printPdf({
    required Uint8List pdfBytes,
    required String documentName,
    PdfPageFormat? pageFormat,
  }) async {
    try {
      // Verificar capacidades primero
      final capability = await checkPrintCapability();

      if (!capability.isSupported) {
        return PrintResult(
          success: false,
          message: capability.message,
          recommendedAction: capability.recommendedAction,
          errorType: capability.errorType,
        );
      }

      if (!capability.hasAvailablePrinters) {
        return PrintResult(
          success: false,
          message:
              'No hay impresoras disponibles. Configura una impresora en tu dispositivo.',
          recommendedAction: PrintAction.share,
          errorType: PrintErrorType.noPrinter,
        );
      }

      // Intentar imprimir
      await Printing.layoutPdf(
        onLayout: (format) async => pdfBytes,
        name: documentName,
        format: pageFormat ?? PdfPageFormat.a4,
      );

      return PrintResult(
        success: true,
        message: 'PDF enviado a impresora correctamente',
        recommendedAction: PrintAction.none,
      );
    } catch (e) {
      debugPrint('$_tag: Error al imprimir: $e');

      PrintErrorType errorType = PrintErrorType.unknown;
      String message = 'Error desconocido al imprimir';

      if (e.toString().contains('does not support printing')) {
        errorType = PrintErrorType.notSupported;
        message = 'Impresión no soportada en este dispositivo';
      } else if (e.toString().contains('No printer')) {
        errorType = PrintErrorType.noPrinter;
        message = 'No se encontraron impresoras disponibles';
      } else if (e.toString().contains('Permission')) {
        errorType = PrintErrorType.permissionDenied;
        message = 'Permisos insuficientes para imprimir';
      } else if (e.toString().contains('cancelled')) {
        errorType = PrintErrorType.userCancelled;
        message = 'Impresión cancelada por el usuario';
      }

      return PrintResult(
        success: false,
        message: message,
        recommendedAction: _getRecommendedAction(errorType),
        errorType: errorType,
      );
    }
  }

  /// Comparte un PDF usando el sistema nativo
  static Future<bool> sharePdf({
    required Uint8List pdfBytes,
    required String fileName,
  }) async {
    try {
      await Printing.sharePdf(bytes: pdfBytes, filename: fileName);
      return true;
    } catch (e) {
      debugPrint('$_tag: Error al compartir PDF: $e');
      return false;
    }
  }

  /// Obtiene información detallada sobre las impresoras disponibles
  static Future<List<PrinterInfo>> getAvailablePrinters() async {
    try {
      final printers = await Printing.listPrinters();
      return printers
          .map(
            (printer) => PrinterInfo(
              name: printer.name,
              isDefault: printer.isDefault,
              isAvailable: printer.isAvailable,
              canPrint: true, // Asumimos que puede imprimir si está disponible
              url: printer.url,
            ),
          )
          .toList();
    } catch (e) {
      debugPrint('$_tag: Error al obtener impresoras: $e');
      return [];
    }
  }

  /// Obtiene los formatos de papel soportados
  static Future<List<String>> _getSupportedFormats() async {
    // Lista básica de formatos comúnmente soportados
    return ['A4', 'Letter', 'Legal', 'A5', 'Térmico 80mm', 'Térmico 58mm'];
  }

  /// Determina la acción recomendada según el tipo de error
  static PrintAction _getRecommendedAction(PrintErrorType errorType) {
    switch (errorType) {
      case PrintErrorType.notSupported:
        return PrintAction.share;
      case PrintErrorType.noPrinter:
        return PrintAction.configurePrinter;
      case PrintErrorType.permissionDenied:
        return PrintAction.requestPermission;
      case PrintErrorType.userCancelled:
        return PrintAction.retry;
      default:
        return PrintAction.share;
    }
  }

  /// Verifica si el dispositivo es móvil
  static bool get isMobile => !kIsWeb && (Platform.isAndroid || Platform.isIOS);

  /// Verifica si el dispositivo es desktop
  static bool get isDesktop =>
      !kIsWeb && (Platform.isWindows || Platform.isMacOS || Platform.isLinux);

  /// Verifica si es web
  static bool get isWeb => kIsWeb;
}

/// Representa las capacidades de impresión del dispositivo
class PrintCapability {
  final bool isSupported;
  final bool hasAvailablePrinters;
  final int printerCount;
  final List<String> supportedFormats;
  final PrintAction recommendedAction;
  final String message;
  final PrintErrorType? errorType;

  PrintCapability({
    required this.isSupported,
    required this.hasAvailablePrinters,
    required this.printerCount,
    required this.supportedFormats,
    required this.recommendedAction,
    required this.message,
    this.errorType,
  });
}

/// Resultado de una operación de impresión
class PrintResult {
  final bool success;
  final String message;
  final PrintAction recommendedAction;
  final PrintErrorType? errorType;

  PrintResult({
    required this.success,
    required this.message,
    required this.recommendedAction,
    this.errorType,
  });
}

/// Información sobre una impresora
class PrinterInfo {
  final String name;
  final bool isDefault;
  final bool isAvailable;
  final bool canPrint;
  final String? url;

  PrinterInfo({
    required this.name,
    required this.isDefault,
    required this.isAvailable,
    required this.canPrint,
    this.url,
  });
}

/// Tipos de errores de impresión
enum PrintErrorType {
  notSupported,
  noPrinter,
  permissionDenied,
  userCancelled,
  networkError,
  unknown,
}

/// Acciones recomendadas para el usuario
enum PrintAction {
  directPrint,
  share,
  configurePrinter,
  requestPermission,
  retry,
  none,
}
