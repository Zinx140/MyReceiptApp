import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import 'package:syncfusion_flutter_pdf/pdf.dart';

class PrintPage extends StatelessWidget {
  final File imageFile;

  PrintPage({required this.imageFile});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Confirm Print"),
        backgroundColor: Colors.blue[300],
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Image.file(imageFile),
          Container(
            margin: EdgeInsets.only(top: 20), // 20px margin from top
            child: MaterialButton(
              color: Colors.blue[200],
              minWidth: 200,
              child: Row(
                mainAxisSize: MainAxisSize.min, // keep the content tight
                children: [
                  Icon(Icons.print, color: Colors.white), // print icon
                  SizedBox(width: 8), // spacing between icon and text
                  Text(
                    "Print",
                    style: TextStyle(color: Colors.white, fontSize: 24),
                  ),
                ],
              ),
              onPressed: () {
                insertImageIntoPdf(imageFile);
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> insertImageIntoPdf(File imageFile) async {
    // 1. Load PDF template dari assets
    final data = await rootBundle.load("assets/nota_toko.pdf");
    final pdfDocument = PdfDocument(inputBytes: data.buffer.asUint8List());

    // 2. Load image dari file (misalnya hasil foto / picker)
    final imageBytes = await imageFile.readAsBytes();
    final image = PdfBitmap(imageBytes);

    // 3. Tambahkan ke halaman pertama (posisi 400,440 ukuran 120x120)
    final page = pdfDocument.pages[0];
    page.graphics.drawImage(image, const Rect.fromLTWH(400, 460, 120, 120));

    // 4. Simpan hasil PDF
    final downloadsDir = Directory('/storage/emulated/0/Download');
    final outputFile = File('${downloadsDir.path}/output.pdf');
    await outputFile.writeAsBytes(await pdfDocument.save());

    // 5. Bersihkan resource
    pdfDocument.dispose();

    print('✅ PDF saved: ${outputFile.path}');
  }
}
