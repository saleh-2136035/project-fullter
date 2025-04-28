import 'package:flutter/material.dart';
import 'profile.dart'; // استيراد صفحة البروفايل
import 'home_page.dart';
import 'sign up.dart';
import 'communicate.dart';
class MyAppointments extends StatelessWidget {
  final List<Map<String, String>> appointments = [
    {'date': 'February 10, 2025', 'time': '10:00 AM', 'doctor': 'Ali Saleh'},
    {'date': 'February 12, 2025', 'time': '2:00 PM', 'doctor': 'Fatima Ali'},
    // إضافة المزيد من المواعيد هنا
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Appointments'),
        backgroundColor: Color(0xFFFFDDDD),
        actions: [
          // أيقونة البروفايل
          IconButton(
            icon: Icon(Icons.account_circle),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MyProfileScreen()),
              );
            },
          ),
          // أيقونة القائمة (Menu)
          Builder(
            builder: (context) {
              return IconButton(
                icon: Icon(Icons.menu),
                onPressed: () {
                  // عند الضغط على أيقونة القائمة (Menu)، سيتم فتحها من الأسفل
                  _openDrawer(context);
                },
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: ListView.builder(
          itemCount: appointments.length,
          itemBuilder: (context, index) {
            return Card(
              margin: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              color: Color(0xFFF4F4F4),
              child: ListTile(
                contentPadding: EdgeInsets.all(16),
                title: Text(
                  'Appointment: ${appointments[index]['date']} - ${appointments[index]['time']}',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                subtitle: Text('Doctor: ${appointments[index]['doctor']}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Tooltip للتعديل
                    Tooltip(
                      message: 'Edit Appointment', // النص التعليمي
                      child: IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () {
                          // من هنا يمكن تنفيذ وظيفة تعديل الموعد
                        },
                      ),
                    ),
                    // Tooltip للتواصل
                    Tooltip(
                      message: 'Communicate with Doctor', // النص التعليمي
                      child: IconButton(
                        icon: Icon(Icons.chat),
                        onPressed: () {
                          // من هنا يمكن تنفيذ وظيفة التواصل مع الطبيب
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => ChatScreen()),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
  // وظيفة لفتح Drawer من الأسفل إلى الأعلى
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
                'My Profile',
                style: TextStyle(color: Color(0xFF7B0000), fontSize: 18),
              ),
              tileColor: Color(0xFFFFDDDD),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MyProfileScreen()),
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

