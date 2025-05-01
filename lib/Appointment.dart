import 'package:flutter/material.dart';
import 'profile.dart'; // استيراد صفحة البروفايل
import 'appintments.dart'; // استيراد صفحة المواعيد
import 'home_page.dart';
import 'sign up.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'login.dart';
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

  // دالة لجلب المواعيد
  Future<void> fetchAppointments() async {
    final accessToken = await _getAccessToken();  // استرجاع التوكن
    if (accessToken == null) return;

    const String url = 'https://smart-analysis-of-health-condition.onrender.com/api/get_appointment_data_based_on_specialty/';
    const body = {"specialty": "الأمراض الصدرية والتنفسية"};

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $accessToken',  // إضافة التوكن في الهيدر
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      final responseData = jsonDecode(utf8.decode(response.bodyBytes));
      if (response.statusCode == 200) {
        setState(() {
          appointments = List<Map<String, dynamic>>.from(responseData['appointments']);
        });
      } else if (response.statusCode == 401) {
        // في حالة انتهاء التوكن، نقوم بتحديثه
        await refreshAccessToken();  // تحديث التوكن
        fetchAppointments();  // استدعاء الدالة مرة أخرى بعد تحديث التوكن
      } else {
        showMessage(context, ' فشل في جلب بيانات المواعيد');
      }
    } catch (e) {
      showMessage(context, ' خطأ أثناء الاتصال بالخادم');
      print(' Exception: $e');
    }
  }

  // دالة للحصول على التوكن من SharedPreferences
  Future<String?> _getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('access_token');
    if (accessToken == null) {
      showMessage(context, ' لم يتم العثور على التوكن');
    }
    return accessToken;
  }

  // دالة لتحديث التوكن
  Future<void> refreshAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    final refreshToken = prefs.getString('refresh_token');

    if (refreshToken == null) {
      showMessage(context, 'No refresh token found.');
      return;
    }

    final String url = 'https://smart-analysis-of-health-condition.onrender.com/api/token/refresh/';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode({"refresh": refreshToken}),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // الحصول على أكسس توكن جديد
        final newAccessToken = responseData['access'];
        prefs.setString('access_token', newAccessToken);  // تخزين التوكن الجديد
        showMessage(context, "Token refreshed successfully");
      } else {
        showMessage(context, "Failed to refresh token ");
      }
    } catch (e) {
      showMessage(context, "Error occurred while refreshing token ");
      print(e);
    }
  }

  // عرض الرسالة للمستخدم
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
    return Scaffold(
      appBar: AppBar(
        title: Text('Appointment'),
        backgroundColor: Color(0xFFFFDDDD),
        actions: [
          IconButton(
            icon: Icon(Icons.account_circle),
            onPressed: () {Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => MyProfileScreen()),
            );},
          ),
          IconButton(
            icon: Icon(Icons.menu),
            onPressed: () {
              _openDrawer(context);
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: appointments.isEmpty
              ? Center(child: CircularProgressIndicator())
              : ListView.builder(
            itemCount: appointments.length,
            itemBuilder: (context, index) {
              final appointment = appointments[index];
              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                margin: EdgeInsets.only(bottom: 16),
                color: Color(0xFFD9D9D9), // اللون الرمادي
                child: ListTile(
                  contentPadding: EdgeInsets.all(16),
                  title: Text(
                    'Date: ${appointment['date']} - Time: ${appointment['time']}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF000000),
                    ),
                  ),
                  subtitle: Text(
                    'Status: ${appointment['status']}',
                    style: TextStyle(fontSize: 14),
                  ),
                  onTap: () {
                    // عند الضغط على الموعد، يتم فتح نافذة تفاصيل الموعد
                    _showAppointmentDetails(context, appointment);
                  },
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  // عرض تفاصيل الموعد
  void _showAppointmentDetails(BuildContext context, Map<String, dynamic> appointment) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Appointment Details'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Date: ${appointment['date']}'),
              Text('Time: ${appointment['time']}'),
              Text('Status: ${appointment['status']}'),
              SizedBox(height: 20),
              // أزرار تأكيد أو إلغاء الموعد
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                      onPressed: () {

                        Navigator.of(context).pop(); // إغلاق النافذة
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF7B0000), // اللون البني الزهري
                      ),
                      child: Text('Cancel',
                        style: TextStyle(
                          color: Color(0xFFFFFFFF),
                        ),)
                  ),
                  ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        showMessage(context, "Your appointment has been confirmed successfully.");
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF1FBA02), // اللون البني الزهري
                      ),
                      child: Text('Confirm',
                        style: TextStyle(
                          color: Color(0xFFFFFFFF),
                        ),)
                  ),
                ],
              ),
            ],
          ),
        );
      },
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

