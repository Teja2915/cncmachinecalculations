import 'package:excel/excel.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class ExcelService {
  // Read an Excel file and extract data
  Future<List<Map<String, double>>> readExcel(File file) async {
    var bytes = await file.readAsBytes();
    var excel = Excel.decodeBytes(bytes);
    var sheet = excel.tables[excel.tables.keys.first];

    List<Map<String, double>> data = [];

    for (var row in sheet!.rows.skip(1)) {
      // Skipping header row
      data.add({
        'Cutting Speed':
            double.tryParse(row[0]?.value.toString() ?? '0') ?? 0.0,
        'Feed Rate': double.tryParse(row[1]?.value.toString() ?? '0') ?? 0.0,
        'Depth of Cut': double.tryParse(row[2]?.value.toString() ?? '0') ?? 0.0,
      });
    }

    return data;
  }

  // Write results to a new Excel file
  Future<File> writeExcel(
    List<Map<String, double>> data,
    List<Map<String, double>> results,
    String fileName,
  ) async {
    var excel = Excel.createExcel();
    var sheet = excel['Sheet1'];

    // Add headers
    sheet.appendRow([
      'Cutting Speed',
      'Feed Rate',
      'Depth of Cut',
      'Surface Roughness',
      'Toolware',
    ]);

    // Add data and results
    for (int i = 0; i < data.length; i++) {
      sheet.appendRow([
        data[i]['Cutting Speed'],
        data[i]['Feed Rate'],
        data[i]['Depth of Cut'],
        results[i]['Surface Roughness'],
        results[i]['Toolware'],
      ]);
    }

    // Save the file
    Directory tempDir = await getApplicationDocumentsDirectory();
    String filePath = '${tempDir.path}/$fileName';
    File file =
        File(filePath)
          ..createSync(recursive: true)
          ..writeAsBytesSync(excel.encode()!);

    return file;
  }
}
