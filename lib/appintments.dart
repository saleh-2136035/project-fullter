import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'chat.dart';

class MyAppointments extends StatefulWidget {
  @override
  _MyAppointmentsState createState() => _MyAppointmentsState();
}

class _MyAppointmentsState extends State<MyAppointments> {
  List<Map<String, dynamic>> _appointments = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadAppointments();
  }

  Future<void> _loadAppointments() async {
    try {
      await _refreshAccessToken();

      final prefs = await SharedPreferences.getInstance();
      final patientJson = prefs.getString('patient');
      if (patientJson == null) {
        setState(() {
          _errorMessage = 'بيانات المريض غير موجودة';
          _isLoading = false;
        });
        return;
      }

      final patientMap = jsonDecode(patientJson);
      final patientID = patientMap['id'];
      final accessToken = prefs.getString('access_token');

      final response = await http.get(
        Uri.parse(
          'https://smart-analysis-of-health-condition.onrender.com/api/patient_appintments/$patientID/',
        ),
        headers: {'Authorization': 'Bearer $accessToken'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        final appointments = data['appointments'] as List<dynamic>?;
        print(data);
        setState(() {
          _appointments =
              appointments
                  ?.map<Map<String, dynamic>>(
                    (item) => item as Map<String, dynamic>,
                  )
                  .toList() ??
              [];
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'فشل في جلب المواعيد';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'حدث خطأ أثناء تحميل المواعيد أو ليس لديك مواعيد';
        _isLoading = false;
      });
    }
  }

  Future<void> _cancelAppointment(int appointmentId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final patientJson = prefs.getString('patient');
      if (patientJson == null) {
        _showMessage('بيانات المريض غير موجودة');
        return;
      }

      final patientMap = jsonDecode(patientJson);
      final patientID = patientMap['id'];
      final accessToken = prefs.getString('access_token');

      final response = await http.patch(
        Uri.parse(
          'https://smart-analysis-of-health-condition.onrender.com/api/update_appointment/$appointmentId/',
        ),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'status': 'canceled', 'patientID': null}),
      );

      if (response.statusCode == 200) {
        _showMessage('تم إلغاء الموعد بنجاح');
        _loadAppointments(); // إعادة تحميل المواعيد
      } else {
        _showMessage('فشل في إلغاء الموعد');
      }
    } catch (e) {
      _showMessage('حدث خطأ أثناء إلغاء الموعد');
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _refreshAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    final refreshToken = prefs.getString('refresh_token');

    if (refreshToken == null) return;

    final response = await http.post(
      Uri.parse(
        'https://smart-analysis-of-health-condition.onrender.com/api/token/refresh/',
      ),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'refresh': refreshToken}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      prefs.setString('access_token', data['access']);
    }
  }

  Widget _buildStatusBadge(String status) {
    Color color = status != 'booked' ? Colors.green : Colors.red;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status != 'booked' ? 'متاح' : 'محجوز',
        style: TextStyle(color: color, fontWeight: FontWeight.bold),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Appointments'),
        backgroundColor: Color(0xFFFFDDDD),
      ),
      body:
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : _errorMessage != null
              ? Center(child: Text(_errorMessage!))
              : _appointments.isEmpty
              ? Center(child: Text('لا توجد مواعيد حالياً'))
              : ListView.builder(
                padding: EdgeInsets.all(16),
                itemCount: _appointments.length,
                itemBuilder: (context, index) {
                  final appt = _appointments[index];
                  final date = appt['date'] ?? '';
                  final timeRaw = appt['time'] ?? '';
                  final time =
                      timeRaw != ''
                          ? DateFormat(
                            'hh:mm a',
                          ).format(DateTime.parse(timeRaw))
                          : '';
                  final status = appt['status'] ?? 'غير معروف';
                  final appointmentId = appt['id'];
                  Color color = status != 'booked' ? Colors.green : Colors.red;
                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 4,
                    margin: EdgeInsets.only(bottom: 16),
                    color: Color(0xFFFBE7E7),
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'التاريخ: $date',
                            style: TextStyle(fontSize: 16),
                          ),
                          SizedBox(height: 8),
                          Text('الوقت: $time', style: TextStyle(fontSize: 16)),
                          SizedBox(height: 8),
                          // Text(
                          //   ' الحالة: ${_getStatusText(status) != 'booked' ? '${_getStatusText(status)}' : 'محجوز'}',
                          //   style: TextStyle(
                          //     color: color,
                          //     fontWeight: FontWeight.bold,
                          //   ),
                          // ),
                          _buildStatusBadge(_getStatusText(status)),
                          SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed:
                                    () => _cancelAppointment(appointmentId),
                                tooltip: 'حذف الموعد',
                              ),
                              IconButton(
                                icon: Icon(Icons.chat, color: Colors.blue),
                                onPressed: () async {
                                  final prefs =
                                      await SharedPreferences.getInstance();
                                  await prefs.setInt(
                                    'chat_id',
                                    appt['chat'],
                                  ); // تأكد أن المفتاح الصحيح هو 'chat'

                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ChatPage(),
                                    ),
                                  );
                                },
                                tooltip: 'الانتقال إلى الشات',
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
    );
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'booked':
        return 'محجوز';
      case 'pending':
        return 'قيد الانتظار';
      case 'canceled':
        return 'ملغي';
      default:
        return status;
    }
  }
}
