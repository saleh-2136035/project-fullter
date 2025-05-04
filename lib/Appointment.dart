import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'home_page.dart';
import 'appintments.dart'; // استيراد صفحة المواعيد
import 'login.dart'; // استيراد صفحة تسجيل الدخول
import 'sign up.dart'; // استيراد صفحة التسجيل

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  _AppointmentsScreenState createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen> {
  List<Map<String, dynamic>> appointments = [];

  @override
  void initState() {
    super.initState();
    fetchAppointments();
  }

  Future<void> fetchAppointments() async {
    await refreshAccessToken();
    if (!mounted) return;

    final accessToken = await _getAccessToken();
    if (accessToken == null) {
      showMessage("فشل في الحصول على التوكن بعد التحديث");
      return;
    }

    const String url =
        'https://smart-analysis-of-health-condition.onrender.com/api/get_appointment_data_based_on_specialty/';
    const body = {"specialty": "الأمراض الصدرية والتنفسية"};

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      final responseData = jsonDecode(utf8.decode(response.bodyBytes));
      if (!mounted) return;

      if (response.statusCode == 200) {
        setState(() {
          appointments = List<Map<String, dynamic>>.from(
            responseData['appointments'],
          );
        });
      } else {
        showMessage('فشل في جلب بيانات المواعيد');
      }
    } catch (e) {
      if (!mounted) return;
      showMessage('حدث خطأ أثناء الاتصال بالخادم');
      print('Exception: $e');
    }
  }

  Future<void> refreshAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    final refreshToken = prefs.getString('refresh_token');

    if (refreshToken == null) {
      if (!mounted) return;
      showMessage('لم يتم العثور على توكن التحديث');
      return;
    }

    final String url =
        'https://smart-analysis-of-health-condition.onrender.com/api/token/refresh/';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"refresh": refreshToken}),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final newAccessToken = responseData['access'];
        prefs.setString('access_token', newAccessToken);
      } else {
        showMessage('فشل في تحديث التوكن');
      }
    } catch (e) {
      if (!mounted) return;
      showMessage('خطأ أثناء تحديث التوكن');
      print(e);
    }
  }

  Future<String?> _getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }

  void showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: TextStyle(fontSize: 16)),
        backgroundColor: Colors.teal,
        duration: Duration(seconds: 3),
      ),
    );
  }

  Future<void> _confirmAppointment(
    BuildContext context,
    int id,
    Map<String, dynamic> appointment,
  ) async {
    await refreshAccessToken();
    if (!mounted) return;

    final accessToken = await _getAccessToken();
    if (accessToken == null) {
      if (!mounted) return;
      showMessage('فشل في الحصول على التوكن');
      return;
    }

    final url =
        'https://smart-analysis-of-health-condition.onrender.com/api/update_appointment/$id/';

    // ✅ استرجاع patientID من SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final patientJson = prefs.getString('patient');
    if (patientJson == null) {
      showMessage('بيانات المريض غير موجودة');
      return;
    }

    final patientMap = jsonDecode(patientJson);
    final patientID = patientMap['id'];

    final body = {"status": "booked", "patientID": patientID};

    try {
      final response = await http.patch(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      final data = jsonDecode(utf8.decode(response.bodyBytes));
      if (!mounted) return;

      if (response.statusCode == 200) {
        print(data);
        showMessage('✅ تم حجز الموعد بنجاح');
        fetchAppointments(); // تحديث قائمة المواعيد بعد الحجز
      } else {
        final msg = data['mssage'] ?? 'فشل في تأكيد الموعد';
        showMessage(msg);
      }
    } catch (e) {
      if (!mounted) return;
      showMessage('حدث خطأ أثناء تأكيد الموعد');
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('المواعيد'),
        backgroundColor: Color(0xFFFFDDDD),
        actions: [
          IconButton(
            icon: Icon(Icons.account_circle),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.menu),
            onPressed: () {
              _openDrawer(context);
            },
          ),
        ],
      ),
      body:
          appointments.isEmpty
              ? Center(child: CircularProgressIndicator())
              : ListView.builder(
                itemCount: appointments.length,
                itemBuilder: (context, index) {
                  final appointment = appointments[index];
                  final rawTime = appointment['time'];
                  final formattedTime = DateFormat(
                    'hh:mm a',
                  ).format(DateTime.parse(rawTime));
                  final isAvailable = appointment['status'] != 'booked';

                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    margin: EdgeInsets.all(10),
                    color: Color(0xFFF9F9F9),
                    child: ListTile(
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 16,
                      ),
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '📅 التاريخ: ${appointment['date']}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            '⏰ الوقت: $formattedTime',
                            style: TextStyle(fontSize: 16),
                          ),
                          SizedBox(height: 8),
                          Container(
                            padding: EdgeInsets.symmetric(
                              vertical: 4,
                              horizontal: 8,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  isAvailable
                                      ? Colors.green[100]
                                      : Colors.red[100],
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              isAvailable ? 'متاح' : 'محجوز',
                              style: TextStyle(
                                color: isAvailable ? Colors.green : Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      onTap: () {
                        _showAppointmentDetails(context, appointment);
                      },
                    ),
                  );
                },
              ),
    );
  }

  void _showAppointmentDetails(
    BuildContext context,
    Map<String, dynamic> appointment,
  ) {
    final rawTime = appointment['time'];
    final formattedTime = DateFormat('hh:mm a').format(DateTime.parse(rawTime));

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text('تفاصيل الموعد'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('📅 التاريخ: ${appointment['date']}'),
              SizedBox(height: 8),
              Text('⏰ الوقت: $formattedTime'),
              SizedBox(height: 8),
              Text(
                '🔖 الحالة: ${appointment['status'] != 'booked' ? 'متاح' : 'محجوز'}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color:
                      appointment['status'] != 'booked'
                          ? Colors.green
                          : Colors.red,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: Text('إغلاق'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            if (appointment['status'] != 'booked')
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _confirmAppointment(context, appointment['id'], appointment);
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                child: Text('تأكيد الموعد'),
              ),
          ],
        );
      },
    );
  }
  // دالة لفتح Drawer (القائمة الجانبية)
  void _openDrawer(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        color: Color(0xFFFFDDDD),
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            ListTile(
              title: Text(
                'Home',
                style: TextStyle(color: Color(0xFF7B0000), fontSize: 18),
              ),
              tileColor: Color(0xFFFFDDDD),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => HomeScreen1()),
                );
              },
            ),
            Divider(),
            ListTile(
              title: Text(
                'My appointments',
                style: TextStyle(color: Color(0xFF7B0000), fontSize: 18),
              ),
              tileColor: Color(0xFFFFDDDD),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MyAppointments()),
                );
              },
            ),
            Divider(),
            ListTile(
              title: Text(
                'Login',
                style: TextStyle(color: Color(0xFF7B0000), fontSize: 18),
              ),
              tileColor: Color(0xFFFFDDDD),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => HomeScreen()),
                );
              },
            ),
            Divider(),
            ListTile(
              title: Text(
                'Logout',
                style: TextStyle(color: Color(0xFF7B0000), fontSize: 18),
              ),
              tileColor: Color(0xFFFFDDDD),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SignUpScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
