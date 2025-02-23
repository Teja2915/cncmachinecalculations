import 'package:flutter/material.dart';
import 'package:cncmachinecalculations/services/excel_service.dart';
import 'package:cncmachinecalculations/services/calculation_service.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _filePath;
  final ExcelService _excelService = ExcelService();
  final CalculationService _calculationService = CalculationService();

  Map<String, dynamic>? _leastSurfaceRoughness;
  Map<String, dynamic>? _leastToolWear;

  Future<void> _importExcel() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
    );
    if (result != null) {
      setState(() {
        _filePath = result.files.single.path;
      });
    }
  }

  Future<void> _processExcel() async {
    if (_filePath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please import an Excel file first")),
      );
      return;
    }

    var data = await _excelService.readExcel(_filePath!);
    var results = _calculationService.processData(data);

    setState(() {
      _leastSurfaceRoughness = results['leastSurfaceRoughness'];
      _leastToolWear = results['leastToolWear'];
    });
  }

  void _openUpdatedExcel() {
    if (_filePath != null) {
      _excelService.openExcelFile(_filePath!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("CNC Machine Calculations")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ElevatedButton(
              onPressed: _importExcel,
              child: Text("Import Excel File"),
            ),
            if (_filePath != null) Text("File: ${_filePath!.split('/').last}"),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _processExcel,
              child: Text("Process Excel File"),
            ),
            if (_leastSurfaceRoughness != null)
              Text(
                "Least Surface Roughness: ${_leastSurfaceRoughness!['value']} (Inputs: ${_leastSurfaceRoughness!['inputs']})",
              ),
            if (_leastToolWear != null)
              Text(
                "Least Tool Wear: ${_leastToolWear!['value']} (Inputs: ${_leastToolWear!['inputs']})",
              ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _openUpdatedExcel,
              child: Text("Open Updated Excel File"),
            ),
          ],
        ),
      ),
    );
  }
}

class ExcelService {
  Future<List<Map<String, dynamic>>> readExcel(String filePath) async {
    // Read Excel file logic here
    return [];
  }

  void openExcelFile(String filePath) {
    // Logic to open Excel file
  }
}

class CalculationService {
  Map<String, dynamic> processData(List<Map<String, dynamic>> data) {
    // Processing logic here
    return {
      'leastSurfaceRoughness': {
        'value': 0.1,
        'inputs': {'speed': 100, 'feed': 0.5},
      },
      'leastToolWear': {
        'value': 0.2,
        'inputs': {'speed': 120, 'feed': 0.4},
      },
    };
  }
}
