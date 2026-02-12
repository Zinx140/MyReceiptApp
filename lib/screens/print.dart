import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter/services.dart' show Uint8List, rootBundle;
import 'package:pdf/pdf.dart' as pw;
import 'package:syncfusion_flutter_pdf/pdf.dart' as sf;
import 'package:printing/printing.dart';

class PrintPage extends StatelessWidget {
  final File imageFile;

  const PrintPage({super.key, required this.imageFile});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Confirm Print"),
        backgroundColor: Colors.blue[300],
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Image.file(imageFile),
            ),
            Container(
              margin: const EdgeInsets.only(top: 20),
              child: MaterialButton(
                color: Colors.blue[200],
                minWidth: 200,
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.print, color: Colors.white),
                    SizedBox(width: 8),
                    Text(
                      "Print",
                      style: TextStyle(color: Colors.white, fontSize: 24),
                    ),
                  ],
                ),
                onPressed: () {
                  processAndPrint(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> processAndPrint(BuildContext context) async {
    try {
      final ByteData data = await rootBundle.load("assets/nota_toko.pdf");
      final Uint8List bytes = data.buffer.asUint8List();

      final sf.PdfDocument pdfDocument = sf.PdfDocument(inputBytes: bytes);

      final Uint8List imageBytes = await imageFile.readAsBytes();
      final sf.PdfBitmap image = sf.PdfBitmap(imageBytes);

      final sf.PdfPage page = pdfDocument.pages[0];
      page.graphics.drawImage(image, const Rect.fromLTWH(400, 460, 120, 120));
      final List<int> pdfOutputBytes = await pdfDocument.save();
      pdfDocument.dispose();

      await Printing.layoutPdf(
        onLayout: (pw.PdfPageFormat format) async =>
            Uint8List.fromList(pdfOutputBytes),
        name: 'Nota_Toko_${DateTime.now().millisecondsSinceEpoch}.pdf',
      );
    } catch (e) {
      debugPrint("Error detail: $e");
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Terjadi kesalahan: $e")));
      }
    }
  }
}
