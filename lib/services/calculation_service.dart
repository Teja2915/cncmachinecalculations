class CalculationService {
  static List<Map<String, double>> calculateResults(
    List<Map<String, double>> inputData,
  ) {
    List<Map<String, double>> results = [];

    for (var data in inputData) {
      double cs = data['Cutting Speed'] ?? 0;
      double fr = data['Feed Rate'] ?? 0;
      double doc = data['Depth of Cut'] ?? 0;

      // Surface Roughness (SR) Calculation
      double sr =
          0.147 +
          (0.000467 * cs) +
          (0.00047 * fr) -
          (0.282 * doc) +
          (0.000001 * cs * cs) +
          (0.000144 * fr * fr) +
          (0.683 * doc * doc) -
          (0.000057 * cs * fr) -
          (0.001725 * cs * doc) +
          (0.0402 * fr * doc);

      // Tool Wear (TW) Calculation
      double tw =
          -0.149 +
          (0.000096 * cs) -
          (0.0232 * fr) +
          (1.812 * doc) +
          (0.000001 * cs * cs) -
          (0.000586 * fr * fr) +
          (0.702 * doc * doc) +
          (0.000129 * cs * fr) -
          (0.003667 * cs * doc) -
          (0.0810 * fr * doc);

      results.add({'Surface Roughness': sr, 'Tool Wear': tw});
    }

    return results;
  }

  static Map<String, dynamic> findLeastValue(
    List<Map<String, double>> inputData,
    List<Map<String, double>> results,
  ) {
    double minSR = double.infinity;
    Map<String, double> minInput = {};

    for (int i = 0; i < results.length; i++) {
      if (results[i]['Surface Roughness']! < minSR) {
        minSR = results[i]['Surface Roughness']!;
        minInput = inputData[i];
      }
    }

    return {'leastValue': minSR, 'inputs': minInput};
  }
}
