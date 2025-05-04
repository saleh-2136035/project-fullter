import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart' show MultipartRequest;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Appointment.dart';
import 'appintments.dart';
import 'home_page.dart';
import 'profile.dart';
import 'sign up.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'تحليل الصوت',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('تحليل الصوت'),
        ),
        body: const Center(
          child: RecordAndAnalyzeButton(),
        ),
      ),
    );
  }
}

class RecordAndAnalyzeButton extends StatefulWidget {
  const RecordAndAnalyzeButton({super.key});

  @override
  _RecordAndAnalyzeButtonState createState() => _RecordAndAnalyzeButtonState();
}

class _RecordAndAnalyzeButtonState extends State<RecordAndAnalyzeButton> {
  final FlutterSoundRecorder _audioRecorder = FlutterSoundRecorder();
  bool isRecording = false;
  String? filePath;

  @override
  void initState() {
    super.initState();
    _initRecorder();
  }

  Future<void> _initRecorder() async {
    await _audioRecorder.openRecorder();
  }

  Future<void> _startRecording() async {
    final dir = await getApplicationDocumentsDirectory();
    filePath = '${dir.path}/audio_recording.wav';

    await _audioRecorder.startRecorder(
      toFile: filePath,
      codec: Codec.pcm16WAV,
    );
    setState(() => isRecording = true);
  }

  Future<void> _stopRecording() async {
    await _audioRecorder.stopRecorder();
    setState(() => isRecording = false);

    await Future.delayed(Duration(seconds: 1));

    if (filePath != null) {
      await _analyzeAudio(filePath!);
    }
  }

  Future<String?> _refreshAccessToken() async {
    const refreshUrl = 'https://smart-analysis-of-health-condition.onrender.com/api/token/refresh/';

    try {
      final prefs = await SharedPreferences.getInstance();
      final refreshToken = prefs.getString('refresh_token');

      if (refreshToken == null) {
        print('❗ لا يوجد refresh token مخزن');
        return null;
      }

      final response = await http.post(
        Uri.parse(refreshUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"refresh": refreshToken}),
      );

      final responseData = jsonDecode(utf8.decode(response.bodyBytes));
      if (response.statusCode == 200 && responseData.containsKey('access')) {
        return responseData['access'];
      } else {
        print('⚠️ فشل تحديث التوكن: $responseData');
        return null;
      }
    } catch (e) {
      print('❗ خطأ تحديث التوكن: $e');
      return null;
    }
  }

  Future<void> _analyzeAudio(String path) async {
    final file = File(path);
    if (!(await file.exists()) || await file.length() == 0) {
      _showMessage('⚠️ الملف غير موجود أو فارغ');
      return;
    }

    final accessToken = await _refreshAccessToken();
    if (accessToken == null) {
      _showMessage('فشل في تحديث التوكن');
      return;
    }

    try {
      var request = MultipartRequest(
        'POST',
        Uri.parse('https://smart-analysis-of-health-condition.onrender.com/api/analyze_audio/'),
      );
      request.headers['Authorization'] = 'Bearer $accessToken';
      request.files.add(await http.MultipartFile.fromPath('audio_file', path));

      final response = await http.Response.fromStream(await request.send());
      final data = jsonDecode(utf8.decode(response.bodyBytes));

      if (response.statusCode == 200) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AnalysisResultsScreen(analysisResult: data['result']),
          ),
        );
      } else {
        _showMessage('❌ فشل التحليل: ${data.toString()}');
      }
    } catch (e) {
      _showMessage('❌ خطأ أثناء الاتصال بالخادم');
      print('❗ $e');
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(fontSize: 18)),
        backgroundColor: Colors.teal,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isRecording ? _stopRecording : _startRecording,
      child: Text(isRecording ? '⏹️ إيقاف التسجيل' : '🎙️ ابدأ التسجيل'),
    );
  }
}

class AnalysisResultsScreen extends StatefulWidget {
  final String analysisResult;

  const AnalysisResultsScreen({super.key, required this.analysisResult});

  @override
  State<AnalysisResultsScreen> createState() => _AnalysisResultsScreenState();
}

class _AnalysisResultsScreenState extends State<AnalysisResultsScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      _showResultDialog(widget.analysisResult);
    });
  }

  void _showResultDialog(String result) {
    bool isPositive = result.toLowerCase().contains("مُصاب") || result.toLowerCase().contains("positive");

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text('نتيجة التحليل'),
        backgroundColor: isPositive ? Colors.red[50] : Colors.green[50],
        content: Text(
          result,
          style: TextStyle(
            fontSize: 20,
            color: isPositive ? Colors.red : Colors.green,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AppointmentsScreen()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
            ),
            child: Text('حجز موعد'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('نتائج التحليل'),
        backgroundColor: Color(0xFFFFDDDD),
      ),
      body: Center(
        child: Text(
          'جارٍ عرض النتيجة...',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
