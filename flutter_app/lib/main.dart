import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';

void main() => runApp(const MacAnalizApp());

class MacAnalizApp extends StatelessWidget {
  const MacAnalizApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'macanaliz',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  File? _excelFile;
  bool _loading = false;
  List<Map<String, dynamic>> _preds = [];

  final String apiUrl = const String.fromEnvironment(
    'API_URL',
    defaultValue: 'https://YOUR_API_HOST/predict',
  );

  Future<void> pickExcel() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
    );
    if (result != null && result.files.single.path != null) {
      setState(() => _excelFile = File(result.files.single.path!));
    }
  }

  Future<void> sendToApi() async {
    if (_excelFile == null) return;
    setState(() { _loading = true; _preds = []; });
    try {
      final dio = Dio(BaseOptions(connectTimeout: const Duration(seconds: 30)));
      final form = FormData.fromMap({
        'file': await MultipartFile.fromFile(_excelFile!.path, filename: 'data.xlsx'),
      });
      final res = await dio.post(apiUrl, data: form);
      final data = res.data as Map<String, dynamic>;
      final items = (data['predictions'] as List).cast<Map<String, dynamic>>();
      setState(() => _preds = items);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Color riskColor(String tag) {
    switch (tag) {
      case 'YESIL': return const Color(0xFF1E8449);
      case 'SARI': return const Color(0xFFB7950B);
      default: return const Color(0xFF922B21);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('macanaliz')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: pickExcel,
                  icon: const Icon(Icons.upload_file),
                  label: const Text('Excel Yükle (.xlsx)'),
                ),
                const SizedBox(width: 12),
                if (_excelFile != null) Expanded(
                  child: Text(
                    _excelFile!.path.split(Platform.pathSeparator).last,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _excelFile == null || _loading ? null : sendToApi,
              icon: const Icon(Icons.play_arrow),
              label: const Text('Tahminleri Hesapla'),
            ),
            const SizedBox(height: 16),
            if (_loading) const LinearProgressIndicator(),
            const SizedBox(height: 8),
            Expanded(
              child: _preds.isEmpty
                  ? const Center(child: Text('Henüz sonuç yok.'))
                  : ListView.separated(
                      itemCount: _preds.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (ctx, i) {
                        final m = _preds[i];
                        final title = m['match'] ?? '';
                        final ms = m['ms'] ?? '';
                        final pct = (m['confidence'] ?? 0).toString();
                        final risk = (m['risk'] ?? 'KIRMIZI') as String;
                        final skor = m['score'] ?? '';
                        return Container(
                          decoration: BoxDecoration(
                            color: riskColor(risk).withOpacity(.12),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: riskColor(risk).withOpacity(.65)),
                          ),
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              Wrap(spacing: 12, runSpacing: 8, children: [
                                Chip(label: Text('MS: $ms')),
                                Chip(label: Text('Güven: %$pct')),
                                Chip(label: Text('Skor: $skor')),
                                Chip(label: Text('Risk: $risk')),
                              ]),
                            ],
                          ),
                        );
                      },
                    ),
            )
          ],
        ),
      ),
    );
  }
}
