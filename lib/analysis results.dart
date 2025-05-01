import 'package:flutter/material.dart';
import 'Appointment.dart';
import 'profile.dart'; // استيراد صفحة البروفايل
import 'appintments.dart'; // استيراد صفحة المواعيد
import 'home_page.dart';
import 'sign up.dart';

class AnalysisResultsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(''),
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
        child: Padding(
          padding: const EdgeInsets.all(50.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,  // لتوسيط المحتوى عموديًا
            crossAxisAlignment: CrossAxisAlignment.center,  // لتوسيط المحتوى أفقيًا
            children: [
              // العنوان
              Text(
                'Analysis Results',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF000000),
                ),
              ),
              SizedBox(height: 200),

              // مربع لعرض النتائج
              Container(
                padding: EdgeInsets.all(50),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Color(0xFF000000)),
                ),
                child: Text(
                  'View health Analysis Results',
                  style: TextStyle(fontSize:16,color: Colors.black54),
                ),
              ),
              SizedBox(height: 40),

              // زر تحديد الموعد
              ElevatedButton(
                onPressed: () {

                  // عند الضغط على زر "Appointments"، ننتقل إلى صفحة المواعيد المتاحة
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AppointmentsScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFFFDDDD),
                    padding: EdgeInsets.symmetric(vertical: 16, horizontal: 25)
                  // اللون البني الزهري
                ),
                child: Text(
                  'Appointment',
                  style: TextStyle(fontWeight: FontWeight.bold,color: Color(0xFF7B0000)),
                ),
              ),
            ],
          ),
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
                'My Appointments',
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