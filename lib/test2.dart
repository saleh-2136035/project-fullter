import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'تسجيل الصوت',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('تسجيل الصوت'),
        ),
        body: const Center(
          child: RecordAudioButton(),
        ),
      ),
    );
  }
}

class RecordAudioButton extends StatefulWidget {
  const RecordAudioButton({super.key});

  @override
  _RecordAudioButtonState createState() => _RecordAudioButtonState();
}

class _RecordAudioButtonState extends State<RecordAudioButton> {
  final FlutterSoundRecorder _audioRecorder = FlutterSoundRecorder();
  bool isRecording = false;

  @override
  void initState() {
    super.initState();
    _initializeRecorder();
  }

  // تهيئة المسجل
  Future<void> _initializeRecorder() async {
    await _audioRecorder.openRecorder();
  }

  // بدء التسجيل
  Future<void> startRecording() async {
    final desktopPath = 'Assets/audio';  // مسار سطح المكتب
    final filePath = '$desktopPath/audio_recording.wav'; // حفظ الملف بصيغة wav على سطح المكتب
    await _audioRecorder.startRecorder(
      toFile: filePath,
      codec: Codec.pcm16WAV, // تحديد صيغة WAV
    );
    setState(() {
      isRecording = true;
    });
  }

  // إيقاف التسجيل
  Future<void> stopRecording() async {
    final filePath = await _audioRecorder.stopRecorder();
    setState(() {
      isRecording = false;
    });

    // إرسال الملف إلى الخادم بعد إيقاف التسجيل
    if (filePath != null) {
      print("تم حفظ الملف في: $filePath");
      // يمكنك إضافة وظيفة إرسال الملف هنا.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          onPressed: isRecording ? null : startRecording,
          child: const Text('ابدأ التسجيل'),
        ),
        ElevatedButton(
          onPressed: !isRecording ? null : stopRecording,
          child: const Text('إيقاف التسجيل'),
        ),
      ],
    );
  }
}