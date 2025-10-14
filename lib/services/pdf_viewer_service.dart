import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import '../widgets/pdf_viewer_widget.dart';
import '../widgets/simple_pdf_viewer.dart';

class PdfViewerService {
  /// Muestra un PDF en el visor personalizado
  static void showPdf({
    required Uint8List pdfBytes,
    required String title,
    bool showActions = true,
  }) {
    Get.to(
      () => SimplePdfViewer(
        pdfBytes: pdfBytes,
        title: title,
        showActions: showActions,
      ),
    );
  }

  /// Muestra un PDF en pantalla completa
  static void showPdfFullscreen({
    required Uint8List pdfBytes,
    required String title,
  }) {
    Get.to(
      () => SimplePdfViewer(
        pdfBytes: pdfBytes,
        title: '$title - Pantalla Completa',
        showActions: true,
      ),
      fullscreenDialog: true,
    );
  }

  /// Muestra un diálogo con vista previa del PDF
  static void showPdfDialog({
    required BuildContext context,
    required Uint8List pdfBytes,
    required String title,
  }) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(20),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          height: MediaQuery.of(context).size.height * 0.9,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              // Header del diálogo
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Color(0xFF005285),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close, color: Colors.white),
                    ),
                  ],
                ),
              ),

              // Contenido del PDF
              Expanded(child: QuickPdfPreview(pdfBytes: pdfBytes)),

              // Botones de acción
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(12),
                    bottomRight: Radius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cerrar'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        showPdf(
                          pdfBytes: pdfBytes,
                          title: title,
                          showActions: true,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF005285),
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Ver Completo'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Imprime un PDF directamente con manejo de errores
  /// Verifica si la impresión está disponible en el dispositivo
  static Future<bool> isPrintingAvailable() async {
    try {
      // Intentar obtener información de impresoras disponibles
      final info = await Printing.info();
      return info.canPrint;
    } catch (e) {
      return false;
    }
  }

  /// Imprime un PDF directamente con manejo de errores inteligente
  static Future<void> printPdf({
    required Uint8List pdfBytes,
    required String title,
  }) async {
    // Verificar si la impresión está disponible
    final canPrint = await isPrintingAvailable();

    if (!canPrint) {
      // Si no puede imprimir, mostrar directamente el visor con opciones
      showPdf(pdfBytes: pdfBytes, title: title, showActions: true);
      return;
    }

    try {
      await Printing.layoutPdf(
        onLayout: (format) async => pdfBytes,
        name: title,
        format: PdfPageFormat.a4,
      );
    } catch (e) {
      // Si falla, mostrar el visor con opciones de impresión
      showPdf(pdfBytes: pdfBytes, title: title, showActions: true);
    }
  }

  /// Genera y muestra una vista previa rápida en un bottom sheet
  static void showQuickPreview({
    required BuildContext context,
    required Uint8List pdfBytes,
    required String title,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          children: [
            // Handle del bottom sheet
            Container(
              margin: const EdgeInsets.only(top: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),

            // Vista previa
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: QuickPdfPreview(pdfBytes: pdfBytes),
              ),
            ),

            // Botones de acción
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cerrar'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        showPdf(
                          pdfBytes: pdfBytes,
                          title: title,
                          showActions: true,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF005285),
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Ver Completo'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
