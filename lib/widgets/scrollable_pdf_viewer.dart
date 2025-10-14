import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';

class ScrollablePdfViewer extends StatefulWidget {
  final Uint8List pdfBytes;
  final String title;
  final bool showActions;

  const ScrollablePdfViewer({
    super.key,
    required this.pdfBytes,
    this.title = 'Vista Previa PDF',
    this.showActions = true,
  });

  @override
  State<ScrollablePdfViewer> createState() => _ScrollablePdfViewerState();
}

class _ScrollablePdfViewerState extends State<ScrollablePdfViewer> {
  double _scale = 1.0;

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

          // Visor de PDF con scroll nativo
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: (600 * _scale).clamp(300, 1200),
                  ),
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
                      build: (format) => widget.pdfBytes,
                      allowPrinting: false,
                      allowSharing: false,
                      canChangePageFormat: false,
                      canChangeOrientation: false,
                      canDebug: false,
                      maxPageWidth: (600 * _scale).clamp(300, 1200),
                      useActions: false,
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

          // Botón de ajustar a pantalla
          IconButton(
            onPressed: _fitToScreen,
            icon: const Icon(Icons.fit_screen),
            tooltip: 'Ajustar a pantalla',
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

  void _fitToScreen() {
    setState(() {
      _scale = 1.0;
    });
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
