import 'package:flutter/material.dart';
import 'profile.dart'; // استيراد صفحة البروفايل
import 'appintments.dart'; // استيراد صفحة المواعيد
import 'home_page.dart';
import 'sign up.dart';

class AppointmentsScreen extends StatelessWidget {
  final List<Map<String, String>> appointments = [
    {'date': 'May 10, 2025', 'time': '10:00 AM'},
    {'date': 'Jul 12, 2025', 'time': '2:00 PM'},
    {'date': 'May 15, 2025', 'time': '4:30 PM'},
    {'date': 'Nov 20, 2025', 'time': '7:30 PM'},
    {'date': 'Jul 1, 2025', 'time': '9:00 AM'},
    {'date': 'Nov 5, 2025', 'time': '3:00 PM'},
    {'date': 'Jul 10, 2025', 'time': '11:00 AM'},
    {'date': 'May 15, 2025', 'time': '5:30 PM'},
  ];

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
            children: [
              Text(
                'Book Appointments',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF070707),
                ),
              ),
              SizedBox(height: 20),

              // استخدام ListView لعرض المواعيد
              Expanded(
                child: ListView.builder(
                  itemCount: appointments.length,
                  itemBuilder: (context, index) {
                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      margin: EdgeInsets.only(bottom: 16),
                      color: Color(0xFFD9D9D9), // اللون الرمادي
                      child: ListTile(
                        contentPadding: EdgeInsets.all(16),
                        title: Text(
                          'Appointment: ${appointments[index]['date']} - ${appointments[index]['time']}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF000000),
                          ),
                        ),
                        onTap: () {
                          // عند الضغط على الموعد، يتم فتح نافذة تفاصيل الموعد
                          _showAppointmentDetails(context, appointments[index]);
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // عرض تفاصيل الموعد
  void _showAppointmentDetails(BuildContext context, Map<String, String> appointment) {
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
              SizedBox(height: 20),
              // أزرار تأكيد أو إلغاء الموعد
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                      onPressed: () {
                        // يمكنك إضافة وظيفة لتأكيد الموعد هنا
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
                        // يمكنك إضافة وظيفة لإلغاء الموعد هنا
                        Navigator.of(context).pop(); // إغلاق النافذة
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