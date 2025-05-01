import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'عرض مواعيد المريض',
      home: Scaffold(
        appBar: AppBar(title: const Text('مواعيدي')),
        body: const Center(
          child: GetPatientAppointmentsButton(),
        ),
      ),
    );
  }
}

class GetPatientAppointmentsButton extends StatelessWidget {
  const GetPatientAppointmentsButton({super.key});

  // 👇 ضع هنا الـ refresh token الخاص بك
  final String refreshToken =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc0NjExMjcyOCwiaWF0IjoxNzQ2MDI2MzI4LCJqdGkiOiIwNmNmODI3ZjlkYjY0YWExODVmYjQwZGRiNWFmYzk4NCIsInVzZXJfaWQiOjF9.bbO607HdkR00OmgBq8ky8QR-rBDlXLHfBDoM_MgaGjQ';

  Future<void> getAppointments(BuildContext context) async {
    final accessToken = await _refreshAccessToken(context);
    if (accessToken == null) return;

    const url = 'https://smart-analysis-of-health-condition.onrender.com/api/patient_appintments/18/';

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
      );

      final responseData = jsonDecode(utf8.decode(response.bodyBytes));

      if (response.statusCode == 200) {
        showMessage(context, '✅ تم جلب المواعيد بنجاح');
        print(' $responseData');
      } else {
        showMessage(context, '❌ فشل في جلب المواعيد');
        print('⚠️ الخطأ: $responseData');
      }
    } catch (e) {
      showMessage(context, '❌ حدث خطأ أثناء الاتصال بالخادم');
      print('❗️ Exception: $e');
    }
  }

  Future<String?> _refreshAccessToken(BuildContext context) async {
    const refreshUrl = 'https://smart-analysis-of-health-condition.onrender.com/api/token/refresh/';

    try {
      final response = await http.post(
        Uri.parse(refreshUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"refresh": refreshToken}),
      );

      final responseData = jsonDecode(utf8.decode(response.bodyBytes));

      if (response.statusCode == 200 && responseData.containsKey('access')) {
        return responseData['access'];
      } else {
        showMessage(context, '❌ فشل في تحديث التوكن');
        print('⚠️ استجابة غير متوقعة: $responseData');
        return null;
      }
    } catch (e) {
      showMessage(context, '❌ خطأ أثناء تحديث التوكن');
      print('❗️ Exception during refresh: $e');
      return null;
    }
  }

  void showMessage(BuildContext context, String message) {
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
      onPressed: () => getAppointments(context),
      child: const Text('عرض مواعيدي'),
    );
  }
}