import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // لتحويل JSON إلى بيانات Dart

import 'home_page.dart'; // استيراد الصفحة الرئيسية
import 'appintments.dart'; // استيراد صفحة المواعيد
import 'login.dart';
import 'sign up.dart';

class MyProfileScreen extends StatefulWidget {
  @override
  _MyProfileScreenState createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends State<MyProfileScreen> {
  // متغير لتحزين البيانات التي تأتي من API
  late Future<Map<String, dynamic>> profileData;

  @override
  void initState() {
    super.initState();
    profileData = fetchProfileData();  // عند تحميل الصفحة نقوم بسحب البيانات
  }

  // دالة لسحب البيانات من الـ API
  Future<Map<String, dynamic>> fetchProfileData() async {
    final response = await http.get(Uri.parse('http://127.0.0.1:8000/api/get_patinet/{patinetID}/'));

    if (response.statusCode == 200) {
      // إذا كانت الاستجابة ناجحة
      return jsonDecode(response.body); // تحويل الـ JSON إلى Dart map
    } else {
      // في حالة الخطأ
      throw Exception('Failed to load profile data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Profile'),
        backgroundColor: Color(0xFFFFDDDD),
        actions: [
          // أيقونة البروفايل
          IconButton(
            icon: Icon(Icons.account_circle),
            onPressed: () {
              // يمكنك إضافة أي وظيفة هنا عند الضغط على الأيقونة
            },
          ),
          // أيقونة القائمة (Menu)
          IconButton(
            icon: Icon(Icons.menu),
            onPressed: () {
              // عند الضغط على أيقونة القائمة (Menu)
              _openDrawer(context);
            },
          ),
        ],
      ),
      body: SafeArea(
        child: FutureBuilder<Map<String, dynamic>>(
          future: profileData,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator()); // في انتظار البيانات
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData) {
              return Center(child: Text('No Data Available'));
            } else {
              var profile = snapshot.data;
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Name: ${profile?['name']}',
                      style: TextStyle(fontSize: 18),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Date of birth day: ${profile?['dob']}',
                      style: TextStyle(fontSize: 18),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Gender: ${profile?['gender']}',
                      style: TextStyle(fontSize: 18),
                    ),
                    SizedBox(height: 20),
                    Divider(),
                    SizedBox(height: 20),
                    Text('..............................'),
                    SizedBox(height: 10),
                    Text('..............................'),
                    SizedBox(height: 10),
                    Text('..............................'),
                    SizedBox(height: 10),
                    Text('..............................'),
                    SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFFFFDDDD), // اللون البني الزهري
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
              );
            }
          },
        ),
      ),
    );
  }

  // وظيفة لفتح Drawer (القائمة الجانبية)
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
