import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import '../services/excel_service.dart';
import '../services/calculation_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ExcelService _excelService = ExcelService();
  List<Map<String, double>>? results;
  Map<String, dynamic>? leastValueData;
  File? outputFile;
  bool isProcessing = false; // Loading indicator

  Future<void> pickAndProcessExcel() async {
    try {
      setState(() {
        isProcessing = true;
      });

      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx'],
      );

      if (result != null) {
        File file = File(result.files.single.path!);
        List<Map<String, double>> data = await _excelService.readExcel(file);

        // Perform calculations
        results = CalculationService.calculateResults(data);

        // Find the least value and corresponding inputs
        leastValueData = CalculationService.findLeastValue(data, results!);

        // Write results to a new Excel file with a proper filename
        outputFile = await _excelService.writeExcel(
          data,
          results!,
          'Updated_CNC_Data.xlsx',
        );

        Fluttertoast.showToast(msg: 'Output file saved successfully!');
      } else {
        Fluttertoast.showToast(msg: 'No file selected.');
      }
    } catch (e) {
      Fluttertoast.showToast(msg: 'Error processing file: $e');
    } finally {
      setState(() {
        isProcessing = false;
      });
    }
  }

  void downloadFile() {
    if (outputFile != null) {
      OpenFile.open(outputFile!.path);
    } else {
      Fluttertoast.showToast(msg: 'No file available to download.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('CNC Machine Calculations')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed:
                  isProcessing
                      ? null
                      : pickAndProcessExcel, // Disable when processing
              child: const Text('Upload Excel File'),
            ),
            const SizedBox(height: 20),
            if (isProcessing)
              const CircularProgressIndicator(), // Show loading indicator
            if (leastValueData != null && !isProcessing)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Least Surface Roughness: ${leastValueData!['leastValue'].toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Corresponding Inputs:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Cutting Speed: ${leastValueData!['inputs']['Cutting Speed']}',
                  ),
                  Text('Feed Rate: ${leastValueData!['inputs']['Feed Rate']}'),
                  Text(
                    'Depth of Cut: ${leastValueData!['inputs']['Depth of Cut']}',
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: downloadFile,
                    child: const Text('Download Updated Excel File'),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
