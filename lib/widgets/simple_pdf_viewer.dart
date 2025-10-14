import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import '../services/print_service.dart';

class SimplePdfViewer extends StatefulWidget {
  final Uint8List pdfBytes;
  final String title;
  final bool showActions;
  final PdfPageFormat? pageFormat;

  const SimplePdfViewer({
    super.key,
    required this.pdfBytes,
    this.title = 'Vista Previa PDF',
    this.showActions = true,
    this.pageFormat,
  });

  @override
  State<SimplePdfViewer> createState() => _SimplePdfViewerState();
}

class _SimplePdfViewerState extends State<SimplePdfViewer> {
  double _scale = 1.0;
  int _currentPage = 1;
  int _totalPages = 1;

  @override
  Widget build(BuildContext context) {
    return Focus(
      autofocus: true,
      onKeyEvent: _handleKeyEvent,
      child: Scaffold(
        backgroundColor: Colors.grey.shade200,
        appBar: AppBar(
          backgroundColor: const Color(0xFF005285),
          title: Text(
            widget.title,
            style: const TextStyle(color: Colors.white),
          ),
          iconTheme: const IconThemeData(color: Colors.white),
          actions: widget.showActions ? _buildActions() : null,
        ),
        body: Column(
          children: [
            // Barra de herramientas
            _buildToolbar(),

            // Visor de PDF simple
            Expanded(
              child: Container(
                width: double.infinity,
                color: Colors.grey.shade100,
                child: PdfPreview(
                  build: (format) => widget.pdfBytes,
                  allowPrinting: false,
                  allowSharing: false,
                  canChangePageFormat: false,
                  canChangeOrientation: false,
                  canDebug: false,
                  useActions: false,
                  maxPageWidth: (700 * _scale).clamp(350, 1400),
                  scrollViewDecoration: BoxDecoration(
                    color: Colors.grey.shade100,
                  ),
                  pdfPreviewPageDecoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is KeyDownEvent) {
      // Zoom con Ctrl + / Ctrl -
      if (event.logicalKey.keyLabel == '+' &&
          event.logicalKey.keyId == 0x0000002b) {
        _zoomIn();
        return KeyEventResult.handled;
      }
      if (event.logicalKey.keyLabel == '-' &&
          event.logicalKey.keyId == 0x0000002d) {
        _zoomOut();
        return KeyEventResult.handled;
      }

      // Navegación de páginas con flechas
      if (event.logicalKey.keyLabel == 'Arrow Left') {
        _previousPage();
        return KeyEventResult.handled;
      }
      if (event.logicalKey.keyLabel == 'Arrow Right') {
        _nextPage();
        return KeyEventResult.handled;
      }

      // Ajustar a pantalla con Ctrl + 0
      if (event.logicalKey.keyLabel == '0' &&
          event.logicalKey.keyId == 0x00000030) {
        _fitToScreen();
        return KeyEventResult.handled;
      }

      // Imprimir con Ctrl + P
      if (event.logicalKey.keyLabel == 'p' &&
          event.logicalKey.keyId == 0x00000070) {
        _printPdf();
        return KeyEventResult.handled;
      }
    }
    return KeyEventResult.ignored;
  }

  List<Widget> _buildActions() {
    return [
      // Botón de imprimir
      IconButton(
        onPressed: _printPdf,
        icon: const Icon(Icons.print, color: Colors.white),
        tooltip: 'Imprimir PDF',
      ),

      // Botón de compartir
      IconButton(
        onPressed: _sharePdf,
        icon: const Icon(Icons.share, color: Colors.white),
        tooltip: 'Compartir PDF',
      ),

      // Botón de descargar
      IconButton(
        onPressed: _downloadPdf,
        icon: const Icon(Icons.download, color: Colors.white),
        tooltip: 'Descargar PDF',
      ),
    ];
  }

  Widget _buildToolbar() {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Row(
        children: [
          const SizedBox(width: 16),

          // Información del documento
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Tamaño: ${_formatFileSize(widget.pdfBytes.length)} • Página $_currentPage de $_totalPages • Zoom: ${(_scale * 100).toInt()}%',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),

          // Controles de zoom
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: _scale > 0.5 ? _zoomOut : null,
                  icon: const Icon(Icons.zoom_out, size: 20),
                  tooltip: 'Alejar (${((_scale / 1.2) * 100).toInt()}%)',
                ),
                PopupMenuButton<double>(
                  onSelected: (value) {
                    setState(() {
                      _scale = value;
                    });
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 0.5, child: Text('50%')),
                    const PopupMenuItem(value: 0.75, child: Text('75%')),
                    const PopupMenuItem(value: 1.0, child: Text('100%')),
                    const PopupMenuItem(value: 1.25, child: Text('125%')),
                    const PopupMenuItem(value: 1.5, child: Text('150%')),
                    const PopupMenuItem(value: 2.0, child: Text('200%')),
                  ],
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 12,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${(_scale * 100).toInt()}%',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.arrow_drop_down, size: 16),
                      ],
                    ),
                  ),
                ),
                IconButton(
                  onPressed: _scale < 3.0 ? _zoomIn : null,
                  icon: const Icon(Icons.zoom_in, size: 20),
                  tooltip: 'Acercar (${((_scale * 1.2) * 100).toInt()}%)',
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // Controles de navegación de páginas (solo si hay múltiples páginas)
          if (_totalPages > 1) ...[
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: _currentPage > 1 ? _previousPage : null,
                    icon: const Icon(Icons.keyboard_arrow_left, size: 20),
                    tooltip: 'Página anterior',
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      '$_currentPage/$_totalPages',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: _currentPage < _totalPages ? _nextPage : null,
                    icon: const Icon(Icons.keyboard_arrow_right, size: 20),
                    tooltip: 'Página siguiente',
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
          ],

          // Botón de ajustar a pantalla
          IconButton(
            onPressed: _fitToScreen,
            icon: const Icon(Icons.fit_screen),
            tooltip: 'Ajustar a pantalla (100%)',
          ),

          const SizedBox(width: 8),

          // Botón de información del documento
          IconButton(
            onPressed: _showDocumentInfo,
            icon: const Icon(Icons.info_outline),
            tooltip: 'Información del documento',
          ),

          const SizedBox(width: 8),

          // Botón de diagnóstico de impresión
          IconButton(
            onPressed: _showPrintDiagnostics,
            icon: const Icon(Icons.print_disabled),
            tooltip: 'Diagnóstico de impresión',
          ),

          const SizedBox(width: 8),

          // Botón de imprimir en toolbar con menú desplegable
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'print_direct':
                  _printPdf();
                  break;
                case 'print_alternatives':
                  _showPrintAlternatives();
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'print_direct',
                child: Row(
                  children: [
                    Icon(Icons.print, size: 20),
                    SizedBox(width: 8),
                    Text('Imprimir Directamente'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'print_alternatives',
                child: Row(
                  children: [
                    Icon(Icons.more_horiz, size: 20),
                    SizedBox(width: 8),
                    Text('Opciones de Impresión'),
                  ],
                ),
              ),
            ],
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF005285),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Padding(
                padding: EdgeInsets.all(8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.print, color: Colors.white, size: 20),
                    SizedBox(width: 4),
                    Icon(Icons.arrow_drop_down, color: Colors.white, size: 16),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(width: 16),
        ],
      ),
    );
  }

  void _zoomIn() {
    if (_scale < 3.0) {
      setState(() {
        _scale = (_scale * 1.2).clamp(0.5, 3.0);
      });
    }
  }

  void _zoomOut() {
    if (_scale > 0.5) {
      setState(() {
        _scale = (_scale / 1.2).clamp(0.5, 3.0);
      });
    }
  }

  void _fitToScreen() {
    setState(() {
      _scale = 1.0;
    });
  }

  void _previousPage() {
    if (_currentPage > 1) {
      setState(() {
        _currentPage--;
      });
    }
  }

  void _nextPage() {
    if (_currentPage < _totalPages) {
      setState(() {
        _currentPage++;
      });
    }
  }

  void _showDocumentInfo() {
    final pageFormat = widget.pageFormat ?? PdfPageFormat.a4;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.description,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 8),
            const Text('Información del Documento'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow('Título', widget.title),
            _buildInfoRow(
              'Tamaño del archivo',
              _formatFileSize(widget.pdfBytes.length),
            ),
            _buildInfoRow('Número de páginas', '$_totalPages'),
            _buildInfoRow('Página actual', '$_currentPage'),
            _buildInfoRow('Nivel de zoom', '${(_scale * 100).toInt()}%'),
            const SizedBox(height: 16),
            const Text(
              'Formato de Papel:',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            _buildInfoRow(
              'Ancho',
              '${(pageFormat.width / PdfPageFormat.mm).toStringAsFixed(1)} mm',
            ),
            _buildInfoRow(
              'Alto',
              '${(pageFormat.height / PdfPageFormat.mm).toStringAsFixed(1)} mm',
            ),
            _buildInfoRow(
              'Ancho (pulgadas)',
              '${(pageFormat.width / PdfPageFormat.inch).toStringAsFixed(2)}"',
            ),
            _buildInfoRow(
              'Alto (pulgadas)',
              '${(pageFormat.height / PdfPageFormat.inch).toStringAsFixed(2)}"',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void _showPrintDiagnostics() async {
    // Mostrar diálogo de carga
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 16),
            Text('Verificando capacidades de impresión...'),
          ],
        ),
      ),
    );

    try {
      // Verificar capacidades de impresión
      final capability = await PrintService.checkPrintCapability();
      final printers = await PrintService.getAvailablePrinters();

      if (!mounted) return;

      // Cerrar diálogo de carga
      Navigator.of(context).pop();

      // Mostrar resultados
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Row(
            children: [
              Icon(
                capability.isSupported ? Icons.check_circle : Icons.error,
                color: capability.isSupported ? Colors.green : Colors.red,
              ),
              const SizedBox(width: 8),
              const Text('Diagnóstico de Impresión'),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow(
                  'Estado',
                  capability.isSupported ? 'Soportado' : 'No Soportado',
                ),
                _buildInfoRow(
                  'Impresoras disponibles',
                  '${capability.printerCount}',
                ),
                _buildInfoRow('Plataforma', _getPlatformInfo()),
                _buildInfoRow('Mensaje', capability.message),

                if (printers.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const Text(
                    'Impresoras Detectadas:',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  ...printers.map(
                    (printer) => Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            printer.name,
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                          Text(
                            'Estado: ${printer.isAvailable ? "Disponible" : "No disponible"}${printer.isDefault ? " (Por defecto)" : ""}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.blue.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.lightbulb_outline,
                            color: Colors.blue.withValues(alpha: 0.8),
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Recomendaciones:',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _getRecommendationText(capability),
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cerrar'),
            ),
            if (!capability.isSupported || !capability.hasAvailablePrinters)
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                  _sharePdf();
                },
                icon: const Icon(Icons.share),
                label: const Text('Compartir PDF'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF005285),
                  foregroundColor: Colors.white,
                ),
              ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;

      // Cerrar diálogo de carga
      Navigator.of(context).pop();

      // Mostrar error
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.error, color: Colors.red),
              SizedBox(width: 8),
              Text('Error en Diagnóstico'),
            ],
          ),
          content: Text(
            'No se pudo verificar las capacidades de impresión: $e',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cerrar'),
            ),
          ],
        ),
      );
    }
  }

  String _getPlatformInfo() {
    if (PrintService.isWeb) return 'Web';
    if (PrintService.isMobile) return 'Móvil';
    if (PrintService.isDesktop) return 'Desktop';
    return 'Desconocido';
  }

  String _getRecommendationText(PrintCapability capability) {
    if (!capability.isSupported) {
      return '• La impresión directa no está disponible en esta plataforma\n'
          '• Use "Compartir" para enviar el PDF a otras aplicaciones\n'
          '• Considere abrir el PDF en un navegador web para imprimir';
    } else if (!capability.hasAvailablePrinters) {
      return '• Configure una impresora en la configuración del sistema\n'
          '• Verifique que la impresora esté encendida y conectada\n'
          '• Use "Compartir" como alternativa temporal';
    } else {
      return '• La impresión directa debería funcionar correctamente\n'
          '• Si tiene problemas, verifique la conexión de la impresora\n'
          '• Use "Compartir" si la impresión directa falla';
    }
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _sharePdf() async {
    try {
      await Printing.sharePdf(
        bytes: widget.pdfBytes,
        filename: '${widget.title.replaceAll(' ', '_')}.pdf',
      );
    } catch (e) {
      if (mounted) {
        _showError('No se pudo compartir el PDF: $e');
      }
    }
  }

  Future<void> _downloadPdf() async {
    try {
      await Printing.sharePdf(
        bytes: widget.pdfBytes,
        filename: '${widget.title.replaceAll(' ', '_')}.pdf',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('PDF guardado correctamente'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        _showError('No se pudo guardar el PDF: $e');
      }
    }
  }

  Future<void> _printPdf() async {
    if (!mounted) return;

    // Limpiar cualquier snackbar anterior
    ScaffoldMessenger.of(context).clearSnackBars();

    // Mostrar indicador de carga
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              SizedBox(width: 16),
              Text('Conectando con impresora...'),
            ],
          ),
          backgroundColor: Color(0xFF005285),
          duration: Duration(seconds: 10),
        ),
      );
    }

    try {
      // Intentar múltiples métodos de impresión
      bool printSuccess = false;
      String errorMessage = '';

      print('🖨️ Iniciando proceso de impresión...');

      // Método 1: Printing.layoutPdf (más compatible)
      try {
        print('🖨️ Intentando método 1: layoutPdf');
        await Printing.layoutPdf(
          onLayout: (format) async => widget.pdfBytes,
          name: widget.title,
          format: widget.pageFormat ?? PdfPageFormat.a4,
        );
        printSuccess = true;
        print('✅ Método 1 exitoso');
      } catch (e1) {
        errorMessage = e1.toString();
        print('❌ Método 1 falló: $e1');

        // Método 2: Printing.directPrintPdf (más directo)
        try {
          print('🖨️ Intentando método 2: directPrintPdf');
          final printers = await Printing.listPrinters();
          print('🖨️ Impresoras encontradas: ${printers.length}');

          if (printers.isNotEmpty) {
            final defaultPrinter = printers.firstWhere(
              (p) => p.isDefault,
              orElse: () => printers.first,
            );
            print('🖨️ Usando impresora: ${defaultPrinter.name}');

            await Printing.directPrintPdf(
              printer: defaultPrinter,
              onLayout: (format) async => widget.pdfBytes,
              name: widget.title,
              format: widget.pageFormat ?? PdfPageFormat.a4,
            );
            printSuccess = true;
            print('✅ Método 2 exitoso');
          } else {
            throw Exception('No hay impresoras disponibles');
          }
        } catch (e2) {
          print('❌ Método 2 falló: $e2');

          // Método 3: Printing.sharePdf como último recurso
          try {
            print('🖨️ Intentando método 3: sharePdf');
            await Printing.sharePdf(
              bytes: widget.pdfBytes,
              filename: '${widget.title}.pdf',
            );

            if (!mounted) return;
            ScaffoldMessenger.of(context).clearSnackBars();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Row(
                  children: [
                    Icon(Icons.share, color: Colors.white),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'PDF compartido - Selecciona tu impresora desde la aplicación que se abrió',
                      ),
                    ),
                  ],
                ),
                backgroundColor: Colors.orange,
                duration: Duration(seconds: 5),
              ),
            );
            print('✅ Método 3 exitoso (compartir)');
            return;
          } catch (e3) {
            print('❌ Método 3 falló: $e3');
            throw Exception(
              'Todos los métodos de impresión fallaron. Error original: $errorMessage',
            );
          }
        }
      }

      if (!mounted) return;

      // Limpiar el snackbar de carga
      ScaffoldMessenger.of(context).clearSnackBars();

      if (printSuccess) {
        // Mostrar mensaje de éxito
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('¡PDF enviado a impresora correctamente!'),
              ],
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      // Limpiar el snackbar de carga
      ScaffoldMessenger.of(context).clearSnackBars();
      await Future.delayed(const Duration(milliseconds: 300));

      print('💥 Error completo de impresión: $e');

      // Mostrar diálogo con opciones de impresión alternativas
      _showPrintTroubleshooting(e.toString());
    }
  }

  void _showPrintAlternatives({String errorType = 'unknown'}) {
    // Configurar mensaje específico según el tipo de error
    String errorMessage;
    IconData errorIcon;
    Color errorColor;

    switch (errorType) {
      case 'not_supported':
        errorMessage =
            'Esta aplicación no soporta impresión directa en este dispositivo o plataforma.';
        errorIcon = Icons.print_disabled;
        errorColor = Colors.red;
        break;
      case 'no_printer':
        errorMessage =
            'No se encontraron impresoras disponibles en este dispositivo.';
        errorIcon = Icons.print;
        errorColor = Colors.orange;
        break;
      case 'permission':
        errorMessage =
            'La aplicación no tiene permisos para acceder a las impresoras.';
        errorIcon = Icons.security;
        errorColor = Colors.amber;
        break;
      default:
        errorMessage =
            'La impresión directa no está disponible en este dispositivo.';
        errorIcon = Icons.info_outline;
        errorColor = Colors.orange;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.print, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 8),
            const Text('Opciones de Impresión'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: errorColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: errorColor.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Icon(
                    errorIcon,
                    color: errorColor.withValues(alpha: 0.8),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      errorMessage,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Puedes usar estas alternativas para imprimir tu PDF:',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            _buildAlternativeOption(
              Icons.share,
              'Compartir PDF',
              'Envía el PDF a otra aplicación que pueda imprimir',
              () {
                Navigator.of(context).pop();
                _sharePdf();
              },
            ),
            const SizedBox(height: 8),
            _buildAlternativeOption(
              Icons.download,
              'Descargar PDF',
              'Guarda el archivo y ábrelo en un navegador para imprimir',
              () {
                Navigator.of(context).pop();
                _downloadPdf();
              },
            ),
            const SizedBox(height: 8),
            _buildAlternativeOption(
              Icons.email,
              'Enviar por Email',
              'Envía el PDF por correo electrónico para imprimir desde otro dispositivo',
              () {
                Navigator.of(context).pop();
                _sharePdf();
              },
            ),
            const SizedBox(height: 8),
            _buildAlternativeOption(
              Icons.cloud_upload,
              'Subir a la Nube',
              'Guarda en Google Drive, Dropbox u otro servicio',
              () {
                Navigator.of(context).pop();
                _sharePdf();
              },
            ),
            const SizedBox(height: 8),
            _buildAlternativeOption(
              Icons.computer,
              'Transferir a PC',
              'Envía el archivo a una computadora para imprimir',
              () {
                Navigator.of(context).pop();
                _sharePdf();
              },
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.lightbulb_outline,
                        color: Colors.blue.shade700,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Consejos para Imprimir:',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '• Usa "Compartir" para enviar a aplicaciones como Google Drive, Gmail, etc.\n'
                    '• En computadoras, abre el PDF descargado en un navegador web\n'
                    '• Para impresoras térmicas, usa aplicaciones especializadas de punto de venta',
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).pop();
              _sharePdf();
            },
            icon: const Icon(Icons.share),
            label: const Text('Compartir Ahora'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF005285),
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlternativeOption(
    IconData icon,
    String title,
    String description,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF005285).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(icon, color: const Color(0xFF005285), size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    description,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _detectPageCount();
  }

  Future<void> _detectPageCount() async {
    try {
      // Intentar detectar el número de páginas del PDF
      // Esto es una aproximación básica
      final pdfString = String.fromCharCodes(widget.pdfBytes);
      final pageMatches = RegExp(r'/Type\s*/Page[^s]').allMatches(pdfString);
      if (pageMatches.isNotEmpty) {
        setState(() {
          _totalPages = pageMatches.length;
        });
      }
    } catch (e) {
      // Si no se puede detectar, mantener el valor por defecto
      setState(() {
        _totalPages = 1;
      });
    }
  }

  void _showPrintTroubleshooting(String errorDetails) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.build, color: Colors.orange),
            SizedBox(width: 8),
            Text('Solución de Problemas de Impresión'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.error_outline, color: Colors.red, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Error Detectado:',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(errorDetails, style: const TextStyle(fontSize: 12)),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                '🔧 Soluciones Recomendadas:',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              ),
              const SizedBox(height: 12),
              _buildTroubleshootingStep(
                '1. Verificar Impresora',
                '• Asegúrate de que la impresora esté encendida\n'
                    '• Verifica que esté conectada (USB/WiFi/Bluetooth)\n'
                    '• Revisa que tenga papel y tinta/tóner',
                Icons.print,
                Colors.blue,
                () => _checkPrinterStatus(),
              ),
              const SizedBox(height: 12),
              _buildTroubleshootingStep(
                '2. Usar Método Alternativo',
                '• Compartir PDF y seleccionar impresora\n'
                    '• Descargar y abrir en navegador\n'
                    '• Enviar por email para imprimir desde PC',
                Icons.share,
                Colors.orange,
                () {
                  Navigator.of(context).pop();
                  _sharePdf();
                },
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.lightbulb_outline,
                          color: Colors.blue,
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Consejo Pro:',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Si tienes una impresora térmica (para recibos), asegúrate de seleccionar el tamaño de papel correcto (80mm, 58mm, etc.) en el PDF Maker antes de imprimir.',
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).pop();
              _sharePdf();
            },
            icon: const Icon(Icons.share),
            label: const Text('Compartir PDF'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF005285),
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTroubleshootingStep(
    String title,
    String description,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Future<void> _checkPrinterStatus() async {
    try {
      final printers = await Printing.listPrinters();

      if (!mounted) return;

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Estado de Impresoras'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (printers.isEmpty)
                const Text('❌ No se encontraron impresoras configuradas')
              else
                ...printers.map(
                  (printer) => ListTile(
                    leading: Icon(
                      printer.isDefault ? Icons.star : Icons.print,
                      color: printer.isAvailable ? Colors.green : Colors.red,
                    ),
                    title: Text(printer.name),
                    subtitle: Text(
                      '${printer.isAvailable ? "Disponible" : "No disponible"}${printer.isDefault ? " (Predeterminada)" : ""}',
                    ),
                  ),
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cerrar'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al verificar impresoras: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
