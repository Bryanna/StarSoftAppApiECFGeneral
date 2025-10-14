import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';

class PdfViewerWidget extends StatefulWidget {
  final Uint8List pdfBytes;
  final String title;
  final bool showActions;

  const PdfViewerWidget({
    super.key,
    required this.pdfBytes,
    this.title = 'Vista Previa PDF',
    this.showActions = true,
  });

  @override
  State<PdfViewerWidget> createState() => _PdfViewerWidgetState();
}

class _PdfViewerWidgetState extends State<PdfViewerWidget> {
  double _scale = 1.0;
  final GlobalKey<State<StatefulWidget>> _pdfPreviewKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      appBar: AppBar(
        backgroundColor: const Color(0xFF005285),
        title: Text(widget.title, style: const TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: widget.showActions ? _buildActions() : null,
      ),
      body: Column(
        children: [
          // Barra de herramientas
          _buildToolbar(),

          // Visor de PDF
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              child: Center(
                child: Container(
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: PdfPreview(
                    key: _pdfPreviewKey,
                    build: (format) => widget.pdfBytes,
                    allowPrinting: false,
                    allowSharing: false,
                    canChangePageFormat: false,
                    canChangeOrientation: false,
                    canDebug: false,
                    maxPageWidth: (700 * _scale).clamp(300, 1400),
                    scrollViewDecoration: BoxDecoration(
                      color: Colors.grey.shade100,
                    ),
                    pdfPreviewPageDecoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildActions() {
    return [
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

      // Botón de imprimir (si está disponible)
      IconButton(
        onPressed: _printPdf,
        icon: const Icon(Icons.print, color: Colors.white),
        tooltip: 'Imprimir PDF',
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
                  'Tamaño: ${_formatFileSize(widget.pdfBytes.length)}',
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
                  onPressed: _zoomOut,
                  icon: const Icon(Icons.zoom_out, size: 20),
                  tooltip: 'Alejar',
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    '${(_scale * 100).toInt()}%',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: _zoomIn,
                  icon: const Icon(Icons.zoom_in, size: 20),
                  tooltip: 'Acercar',
                ),
              ],
            ),
          ),

          const SizedBox(width: 16),

          // Botón de pantalla completa
          IconButton(
            onPressed: _toggleFullscreen,
            icon: const Icon(Icons.fullscreen),
            tooltip: 'Pantalla completa',
          ),

          const SizedBox(width: 16),
        ],
      ),
    );
  }

  void _zoomIn() {
    setState(() {
      _scale = (_scale * 1.2).clamp(0.5, 3.0);
    });
  }

  void _zoomOut() {
    setState(() {
      _scale = (_scale / 1.2).clamp(0.5, 3.0);
    });
  }

  void _toggleFullscreen() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PdfViewerWidget(
          pdfBytes: widget.pdfBytes,
          title: '${widget.title} - Pantalla Completa',
          showActions: true,
        ),
        fullscreenDialog: true,
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
      _showError('No se pudo compartir el PDF: $e');
    }
  }

  Future<void> _downloadPdf() async {
    try {
      await Printing.sharePdf(
        bytes: widget.pdfBytes,
        filename: '${widget.title.replaceAll(' ', '_')}.pdf',
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('PDF guardado correctamente'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      _showError('No se pudo guardar el PDF: $e');
    }
  }

  Future<void> _printPdf() async {
    try {
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => widget.pdfBytes,
        name: widget.title,
      );
    } catch (e) {
      // Si no se puede imprimir, mostrar opciones alternativas
      _showPrintAlternatives();
    }
  }

  void _showPrintAlternatives() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Opciones de Impresión'),
        content: const Text(
          'La impresión directa no está disponible en este dispositivo.\n\n'
          'Puedes:\n'
          '• Compartir el PDF y abrirlo en otra aplicación\n'
          '• Descargar el PDF y enviarlo por email\n'
          '• Usar un navegador web para imprimir',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _sharePdf();
            },
            child: const Text('Compartir PDF'),
          ),
        ],
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

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}

// Widget simplificado para vista previa rápida
class QuickPdfPreview extends StatefulWidget {
  final Uint8List pdfBytes;
  final double? width;
  final double? height;

  const QuickPdfPreview({
    super.key,
    required this.pdfBytes,
    this.width,
    this.height,
  });

  @override
  State<QuickPdfPreview> createState() => _QuickPdfPreviewState();
}

class _QuickPdfPreviewState extends State<QuickPdfPreview> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: PdfPreview(
          build: (format) => widget.pdfBytes,
          allowPrinting: false,
          allowSharing: false,
          canChangePageFormat: false,
          canChangeOrientation: false,
          canDebug: false,
          maxPageWidth: widget.width ?? 300,
          scrollViewDecoration: BoxDecoration(color: Colors.grey.shade50),
          pdfPreviewPageDecoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 2,
                offset: const Offset(0, 1),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
