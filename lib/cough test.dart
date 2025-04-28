import 'package:flutter/material.dart';
import 'package:untitled/sign%20up.dart';
import 'profile.dart'; // استيراد صفحة البروفايل
import 'appintments.dart'; // استيراد صفحة المواعيد
import 'home_page.dart';
import 'analysis results.dart';
class CoughTestScreen extends StatelessWidget {
  // إضافة key هنا

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
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // عنوان الصفحة
              Text(
                'Cough Test',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF000000), // اللون البني الزهري
                ),
              ),
              SizedBox(height: 100),

              // صورة توضح المكان
              Image.asset(
                'Assets/Screenshot 2025-04-12 at 7.57.48 PM.png', // تأكد من وضع الصورة في مجلد "assets/images"
                width: 170,
                height: 170,
              ),
              SizedBox(height: 20),

              // النص التوضيحي
              Text(
                'Welcome! Start your test below.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Place the device about 20 cm away from your mouth, and start coughing normally.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                ),
              ),
              SizedBox(height: 40),

              // زر بدء الاختبار
              ElevatedButton.icon(
                onPressed: () {
                  _showTestDialog(context);
                },
                icon: Icon(Icons.mic, color: Colors.white),
                label: Text(
                  'Start Test',
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF7B0000), // اللون البني الزهري
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
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
  // عرض النافذة المنبثقة
  void _showTestDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'Assets/soundـaudio.png', // تأكد من إضافة صورة الموجات الصوتية في مجلد "assets/images"
                width: 150,
                height: 150,
              ),
              SizedBox(height: 20),
              // النصوص
              Text(
                'Start your coughing test!',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),

              SizedBox(height: 40),
              // الأزرار
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      // يمكن إضافة وظيفة لإعادة المحاولة هنا
                      Navigator.of(context).pop(); // إغلاق النافذة
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFFFDDDD), // اللون البني الزهري
                    ),
                    child: Text(
                      'Retry',
                      style: TextStyle(color: Color(0xFF7B0000)),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      // التنقل إلى صفحة "Analysis Results"
                      Navigator.of(context).pop(); // إغلاق النافذة
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => AnalysisResultsScreen()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFFFDDDD), // اللون البني الزهري
                    ),
                    child: Text(
                      'Next',
                      style: TextStyle(color: Color(0xFF7B0000)),
                    ),
                  ),
                ],
              )
            ],
          ),
        );
      },
    );
  }
}
