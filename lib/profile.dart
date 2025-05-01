import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'home_page.dart';
import 'appintments.dart'; // استيراد صفحة المواعيد
import 'login.dart'; // استيراد صفحة تسجيل الدخول
import 'sign up.dart'; // استيراد صفحة التسجيل

import 'package:shared_preferences/shared_preferences.dart'; // استيراد الحزمة

class MyProfileScreen extends StatefulWidget {
  @override
  _MyProfileScreenState createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends State<MyProfileScreen> {
  // متغير لتخزين بيانات المريض
  Map<String, dynamic> _profileData = {};



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

  //يبغاله تعديل
  // دالة لجلب بيانات المريض
  Future<void> fetchProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('access_token');
    final patient = prefs.getString('patient');

    if (patient == null) {
      showMessage(context, "Patient data not found.");
      return;
    }

    final patientData = jsonDecode(patient);
    final patientId = patientData['id'];


    final String url = 'https://smart-analysis-of-health-condition.onrender.com/api/get_patinet/$patientId/';


    print('Fetching data from: $url');

    if (accessToken == null) {
      showMessage(context, "No access token found.");
      return;
    }


    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        setState(() {
          _profileData = data;
          // تحديث بيانات المريض
        });
      } else {
        if (response.statusCode == 401) {
          // التوكن منتهي الصلاحية، قم بتحديثه
          await refreshAccessToken();
        } else {
          throw Exception('Failed to load profile data');
        }
      }
    } catch (e) {
      print('Error: $e');
      showMessage(context, "Error occurred while fetching profile data");
    }
  }

  // دالة لإظهار الرسائل للمستخدم
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
  void initState() {
    super.initState();
    fetchProfileData(); // جلب البيانات عند بدء الصفحة
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Profile'),
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
      body: SafeArea(
        child: _profileData.isEmpty
            ? Center(child: CircularProgressIndicator()) // عرض مؤشر تحميل أثناء الانتظار
            : Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Name: ${_profileData['user'] ['first_name']  ?? 'غير متوفر'}',
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 10),
              Text(
                'Age: ${_profileData['patinet']['age'] ?? 'غير متوفر'}',
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 10),
              Text(
                'Gender: ${_profileData['patinet']['gender'] ?? 'غير متوفر'}',
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 20),
              Divider(),
              SizedBox(height: 20),
              Text('Health Data: ${_profileData['patinet']['healthdataa'] ?? 'غير متوفر'}'),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFFFDDDD),
                    ),
                    child: Text('Edit', style: TextStyle(color: Color(0xFF7B0000))),
                  ),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFFFDDDD),
                    ),
                    child: Text('Save', style: TextStyle(color: Color(0xFF7B0000))),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
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