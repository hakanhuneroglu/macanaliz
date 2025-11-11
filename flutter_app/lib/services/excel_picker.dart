import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';

class ExcelPicker {
  static Future<Uint8List?> pickExcel() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx', 'xls'],
    );

    if (result != null && result.files.single.bytes != null) {
      return result.files.single.bytes!;
    }

    return null;
  }
}
