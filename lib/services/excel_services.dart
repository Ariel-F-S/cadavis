import 'dart:io';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:open_file/open_file.dart';

class ExcelServices {
  
  static Future<bool> requestPermission() async {
    if (Platform.isAndroid) {
      var status = await Permission.storage.status;
      if (!status.isGranted) {
        status = await Permission.storage.request();
      }
      
      // Untuk Android 13+
      if (await Permission.manageExternalStorage.isDenied) {
        await Permission.manageExternalStorage.request();
      }
      
      return status.isGranted;
    }
    return true;
  }

  static Future<String?> exportToExcel(List<Map<String, dynamic>> data, String tanggal) async {
    try {
      // Request permission
      bool hasPermission = await requestPermission();
      if (!hasPermission) {
        throw Exception('Permission tidak diberikan');
      }

      // Buat Excel baru
      var excel = Excel.createExcel();
      Sheet sheetObject = excel['Data'];

      // Tambahkan header
      sheetObject.appendRow([
        TextCellValue('Nama'),
        TextCellValue('Laki-laki'),
        TextCellValue('Perempuan'),
        TextCellValue('Lokasi'),
      ]);

      // Style header
      for (int i = 0; i < 4; i++) {
        var cell = sheetObject.cell(
          CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0)
        );
        cell.cellStyle = CellStyle(
          bold: true,
          backgroundColorHex: ExcelColor.blue,
          fontColorHex: ExcelColor.white,
        );
      }

      // Tambahkan data
      for (var item in data) {
        sheetObject.appendRow([
          TextCellValue(item['nama']?.toString() ?? ''),
          IntCellValue(item['lakilaki'] ?? 0),
          IntCellValue(item['perempuan'] ?? 0),
          TextCellValue(item['lokasi']?.toString() ?? ''),
        ]);
      }

      // Encode Excel
      var fileBytes = excel.encode();
      if (fileBytes == null) {
        throw Exception('Gagal membuat file Excel');
      }

      // Tentukan path
      Directory? directory;
      if (Platform.isAndroid) {
        directory = Directory('/storage/emulated/0/Download');
        if (!await directory.exists()) {
          directory = await getExternalStorageDirectory();
        }
      } else if (Platform.isIOS) {
        directory = await getApplicationDocumentsDirectory();
      }

      // Simpan file
      String fileName = 'Data_Export_$tanggal.xlsx';
      String filePath = '${directory!.path}/$fileName';
      File file = File(filePath);
      await file.writeAsBytes(fileBytes);

      // Buka file
      await OpenFile.open(filePath);

      return filePath;

    } catch (e) {
      print('Error exporting: $e');
      return null;
    }
  }
}