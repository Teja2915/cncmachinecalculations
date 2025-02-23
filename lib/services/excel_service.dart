import 'dart:io';
import 'dart:math';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';

class ExcelService {
  File? _selectedFile;
  String? _fileName;

  String? get fileName => _fileName;

  Future<List<Map<String, double>>> pickAndReadExcel() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx'],
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) {
        throw Exception('No file selected');
      }

      final path = result.files.single.path;
      if (path == null) throw Exception('Invalid file path');

      _selectedFile = File(path);
      _fileName = result.files.single.name;

      return await _readExcelAndConvert(_selectedFile!);
    } catch (e) {
      throw Exception('Error picking Excel file: $e');
    }
  }

  Future<List<Map<String, double>>> _readExcelAndConvert(File file) async {
    if (!await file.exists()) {
      throw FileSystemException('File does not exist', file.path);
    }

    try {
      final bytes = await file.readAsBytes();
      final excel = Excel.decodeBytes(bytes);
      final dataList = <Map<String, double>>[];

      for (var table in excel.tables.keys) {
        final sheet = excel.tables[table];
        if (sheet == null || sheet.rows.isEmpty) continue;

        for (var i = 1; i < sheet.rows.length; i++) {
          final row = sheet.rows[i];
          if (row.length < 4) continue;

          final cuttingSpeed =
              double.tryParse(row[1]?.value.toString() ?? '') ?? 0.0;
          final feedRate =
              double.tryParse(row[2]?.value.toString() ?? '') ?? 0.0;
          final depthOfCut =
              double.tryParse(row[3]?.value.toString() ?? '') ?? 0.0;

          if (cuttingSpeed > 0 && feedRate > 0 && depthOfCut > 0) {
            dataList.add({
              "Cutting Speed": cuttingSpeed,
              "Feed Rate": feedRate,
              "Depth of Cut": depthOfCut,
            });
          }
        }
      }
      return dataList;
    } catch (e) {
      throw Exception('Error reading Excel file: $e');
    }
  }

  Future<void> processAndOpenExcel(
    List<Map<String, double>> processedData,
  ) async {
    if (_selectedFile == null) throw Exception('No file selected');

    try {
      final excel = Excel.createExcel();
      final sheet = excel.sheets[excel.getDefaultSheet()]!;

      sheet.appendRow(
        [
          'Cutting Speed (cs) (rpm)',
          'Feed Rate (fr) (mm/min)',
          'Depth of Cut (doc) (mm)',
          'Surface Roughness (µm)',
          'Tool Wear (mm)',
        ].map((v) => TextCellValue(v)).toList(),
      );

      for (var row in processedData) {
        sheet.appendRow([
          DoubleCellValue(row['Cutting Speed']!),
          DoubleCellValue(row['Feed Rate']!),
          DoubleCellValue(row['Depth of Cut']!),
          DoubleCellValue(row['Surface Roughness']!),
          DoubleCellValue(row['Tool Wear']!),
        ]);
      }

      final outputFile = await _saveExcelFile(excel);
      await OpenFile.open(outputFile.path);
    } catch (e) {
      throw Exception('Error processing Excel file: $e');
    }
  }

  Future<File> _saveExcelFile(Excel excel) async {
    final outputBytes = excel.encode();
    if (outputBytes == null) {
      throw Exception('Failed to encode Excel file');
    }

    final directory =
        await getDownloadsDirectory() ?? await getTemporaryDirectory();
    final outputPath = '${directory.path}/updated_results.xlsx';

    return await File(outputPath).writeAsBytes(outputBytes);
  }

  Future<List<Map<String, double>>> readExcel(String filePath) async {
    var bytes = File(filePath).readAsBytesSync();
    var excel = Excel.decodeBytes(bytes);
    var sheet = excel.tables[excel.tables.keys.first]!;

    List<String> headers = [];
    List<Map<String, double>> data = [];

    // Get headers from first row
    for (var cell in sheet.row(0)) {
      headers.add(cell?.value?.toString() ?? '');
    }

    // Read data rows
    for (var i = 1; i < sheet.maxRows; i++) {
      var row = sheet.row(i);
      Map<String, double> rowData = {};

      for (var j = 0; j < headers.length; j++) {
        var cellValue = row[j]?.value;
        if (cellValue != null) {
          rowData[headers[j]] = double.tryParse(cellValue.toString()) ?? 0.0;
        }
      }

      if (rowData.isNotEmpty) {
        data.add(rowData);
      }
    }

    return data;
  }
}
