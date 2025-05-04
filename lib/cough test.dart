import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart' show MultipartRequest;

import 'Appointment.dart';
import 'profile.dart';
import 'appintments.dart';
import 'home_page.dart';
import 'login.dart';

class CoughTestScreen extends StatefulWidget {
  const CoughTestScreen({super.key});

  @override
  State<CoughTestScreen> createState() => _CoughTestScreenState();
}

class _CoughTestScreenState extends State<CoughTestScreen> {
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

  Future<String?> _getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    final refreshToken = prefs.getString('refresh_token');
    if (refreshToken == null) return null;

    const refreshUrl = 'https://smart-analysis-of-health-condition.onrender.com/api/token/refresh/';

    try {
      final response = await http.post(
        Uri.parse(refreshUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"refresh": refreshToken}),
      );
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      return response.statusCode == 200 ? data['access'] : null;
    } catch (e) {
      print('❗ خطأ في تحديث التوكن: $e');
      return null;
    }
  }

  Future<void> _analyzeAudio(String path) async {
    final file = File(path);
    if (!(await file.exists()) || await file.length() == 0) {
      _showMessage('⚠️ الملف غير موجود أو فارغ');
      return;
    }

    final accessToken = await _getAccessToken();
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
        String result = data['result'];
        print(result);
        bool isPositive = result.toLowerCase().startsWith("مصاب") || result.toLowerCase().contains("positive");

        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: Text('نتيجة التحليل'),
            backgroundColor:  Colors.white,
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
                child: Text('إلغاء' , style: TextStyle(fontSize: 18)),
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
                  backgroundColor: Color(0xFFFFDDDD),
                ),
                child: Text('حجز موعد' ,style: TextStyle(fontSize: 18)),
              ),
            ],
          ),
        );
      } else {
        _showMessage('❌ فشل التحليل: ${data.toString()}');
      }
    } catch (e) {
      _showMessage('❌ خطأ أثناء الاتصال بالخادم');
    }
  }

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), duration: Duration(seconds: 3)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(''),
        backgroundColor: Color(0xFFFFDDDD),
        actions: [
          IconButton(
            icon: Icon(Icons.account_circle),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => MyProfileScreen()));
            },
          ),
          Builder(
            builder: (context) => IconButton(
              icon: Icon(Icons.menu),
              onPressed: () => _openDrawer(context),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('اختبار السعال', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
              SizedBox(height: 20),
              Image.asset('Assets/soundـaudio.png', width: 180, height: 180),
              SizedBox(height: 20),
              Text(
                'مرحباً! ابدأ الاختبار أدناه.',
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 10),
              Text(
                'ضع الجهاز على بعد حوالي 20 سم من فمك، وابدأ بالسعال بشكل طبيعي.',
                style: TextStyle(fontSize: 16, color: Colors.black54),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 30),
              ElevatedButton.icon(
                onPressed: isRecording ? _stopRecording : _startRecording,
                icon: Icon(isRecording ? Icons.stop : Icons.mic),
                label: Text(
                  isRecording ? 'إيقاف التسجيل' : 'ابدأ التسجيل',
                  style: TextStyle(color: Colors.white,fontSize: 18),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF7B0000),
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openDrawer(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        color: Color(0xFFFFDDDD),
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              title: Text('الصفحة الرئيسية', style: TextStyle(color: Color(0xFF7B0000), fontSize: 18)),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => HomeScreen1())),
            ),
            Divider(),
            ListTile(
              title: Text('ملفي الشخصي', style: TextStyle(color: Color(0xFF7B0000), fontSize: 18)),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => MyProfileScreen())),
            ),
            Divider(),
            ListTile(
              title: Text('مواعيدي', style: TextStyle(color: Color(0xFF7B0000), fontSize: 18)),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => MyAppointments())),
            ),
            Divider(),
            ListTile(
              title: Text('تسجيل الخروج', style: TextStyle(color: Color(0xFF7B0000), fontSize: 18)),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => HomeScreen())),
            ),
          ],
        ),
      ),
    );
  }
}
