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
      // 1. Loading PDF
      final ByteData data = await rootBundle.load("assets/nota_toko.pdf");
      final Uint8List bytes = data.buffer.asUint8List();

      final sf.PdfDocument pdfDocument = sf.PdfDocument(inputBytes: bytes);
      final Uint8List imageBytes = await imageFile.readAsBytes();
      final sf.PdfBitmap image = sf.PdfBitmap(imageBytes);

      // 2. Gambar Image
      pdfDocument.pages[0].graphics.drawImage(
        image,
        const Rect.fromLTWH(400, 460, 120, 120),
      );

      // 3. Simpan dan Pastikan menjadi Uint8List yang bersih
      final List<int> pdfOutputBytes = await pdfDocument.save();
      pdfDocument.dispose();
      final Uint8List finalPdfData = Uint8List.fromList(pdfOutputBytes);

      final customFormat = pw.PdfPageFormat(
        15 * pw.PdfPageFormat.cm,
        10 * pw.PdfPageFormat.cm,
        marginAll:
            0.5 *
            pw
                .PdfPageFormat
                .cm, // Beri margin agar tidak terpotong printer inkjet
      );

      // 4. Perintah Layout dengan Formating A4
      await Printing.layoutPdf(
        onLayout: (pw.PdfPageFormat format) async => finalPdfData,
        // Memaksa printer inkjet menggunakan standar A4
        dynamicLayout: true,
        format: pw.PdfPageFormat.a4,
        // format: customFormat,
        name: 'Cetak_Nota_${DateTime.now().second}',
      );
    } catch (e) {
      print("Error: $e");
    }
  }
}
