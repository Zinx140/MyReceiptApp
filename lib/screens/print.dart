import 'dart:typed_data';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

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
      final Uint8List imageBytes = await imageFile.readAsBytes();

      double cm(double value) => value * PdfPageFormat.cm;

      // ========================================================
      // Gunakan format A4 resmi agar sama dengan setelan printer
      // ========================================================
      final PdfPageFormat a4Format = PdfPageFormat.a4; // 21.0 x 29.7 cm

      // Ukuran gambar Anda (2x2 cm)
      final double imageWidth = cm(2.5);
      final double imageHeight = cm(2.5);

      // ========================================================
      // HITUNG POSISI BARU TERHADAP KERTAS A4 PORTRAIT
      // Taruh kertas struk fisik Anda merapat ke pojok kiri atas printer.
      // ========================================================
      // xLandscape asli = 3cm dari kiri. Di Portrait, ini menjadi jarak dari ATAS.
      // yLandscape asli = 10cm dari atas. Di Portrait, ini menjadi jarak dari KANAN.

      // Karena Portrait A4 lebarnya 21cm, maka dari KANAN ke KIRI hitungannya:
      // Lebar Kertas A4 - yLandscape - Tinggi Gambar
      final double pdfX = cm(21.0) - cm(10) - imageHeight;
      final double pdfY = cm(0.4); // xLandscape menjadi Top di Portrait

      final pw.MemoryImage pdfImage = pw.MemoryImage(imageBytes);

      await Printing.layoutPdf(
        dynamicLayout: false,
        usePrinterSettings: true, // Biarkan menggunakan setelan printer (A4)
        format: a4Format,
        name: 'Cetak_Nota_${DateTime.now().millisecondsSinceEpoch}',
        onLayout: (_) async {
          final pw.Document pdf = pw.Document();

          pdf.addPage(
            pw.Page(
              pageFormat: a4Format,
              margin: pw
                  .EdgeInsets
                  .zero, // Nol-kan margin agar koordinat murni dari pojok
              build: (pw.Context context) {
                return pw.Stack(
                  children: [
                    pw.Positioned(
                      left: pdfX,
                      top: pdfY,
                      child: pw.Transform.rotate(
                        // math.pi akan memutar gambar 180 derajat agar tidak terbalik
                        angle: math.pi,
                        child: pw.Image(
                          pdfImage,
                          width: imageWidth,
                          height: imageHeight,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          );

          return pdf.save();
        },
      );
    } catch (e) {
      print("Error: $e");
    }
  }
}
