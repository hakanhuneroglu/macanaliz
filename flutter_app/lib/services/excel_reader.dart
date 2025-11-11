import 'package:excel/excel.dart';
import 'dart:typed_data';

class ExcelReader {
  static List<double> readMatchData(Uint8List bytes) {
    final excel = Excel.decodeBytes(bytes);

    // İlk sayfayı al
    final sheet = excel.tables.keys.first;
    final table = excel.tables[sheet];

    List<double> features = [];

    if (table == null) return features;

    // Tüm satırları oku, sayı olanları listeye ekle
    for (var row in table.rows) {
      for (var cell in row) {
        if (cell != null && cell.value != null) {
          final value = double.tryParse(cell.value.toString());
          if (value != null) {
            features.add(value);
          }
        }
      }
    }

    return features;
  }
}
