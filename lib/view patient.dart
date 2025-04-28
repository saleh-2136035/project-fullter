import 'package:flutter/material.dart';
import 'sign up.dart';
import 'login.dart';
import 'ReportPage.dart';

void main() {
  runApp(MaterialApp(home: ViewPatientScreen()));
}

class ViewPatientScreen extends StatefulWidget {
  @override
  _ViewPatientScreenState createState() => _ViewPatientScreenState();
}

class _ViewPatientScreenState extends State<ViewPatientScreen> {
  final List<Map<String, String>> patients = [
    {'name': 'Ahmed Ali', 'email': 'ahmed.ali@example.com', 'id': '123456'},
    {'name': 'Layla Hassan', 'email': 'layla.hassan@example.com', 'id': '234567'},
    {'name': 'Ali Saleh', 'email': 'ali.saleh@example.com', 'id': '345678'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('View Patient'),
        backgroundColor: Color(0xFFFFDDDD),
        actions: [
          Builder(
            builder: (context) {
              return IconButton(
                icon: Icon(Icons.menu),
                onPressed: () {
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
              // حقل البحث
              TextField(
                decoration: InputDecoration(
                  labelText: 'Search',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              SizedBox(height: 20),

              // عرض قائمة المرضى
              Expanded(
                child: ListView.builder(
                  itemCount: patients.length,
                  itemBuilder: (context, index) {
                    return Card(
                      margin: EdgeInsets.only(bottom: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      color: Color(0xFFFFDDDD),
                      child: ListTile(
                        contentPadding: EdgeInsets.all(16),
                        leading: Icon(Icons.person),
                        title: Text(
                          'Name: ${patients[index]['name']}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text('Email: ${patients[index]['email']}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit),
                              onPressed: () {
                                _editPatientDetails(context, index);
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.visibility),
                              onPressed: () {
                                _viewPatientDetails(context, index);
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.file_download),
                              onPressed: () {
                                // إرسال التقرير عند الضغط
                                _sendReport(context, index);
                              },
                            ),
                          ],
                        ),
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

  // إرسال التقرير
  void _sendReport(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Send Report to ${patients[index]['name']}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Do you want to send a report to ${patients[index]['name']}?'),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  // يمكنك إضافة الوظيفة الخاصة بإرسال التقرير هنا.
                  Navigator.of(context).pop(); // إغلاق النافذة
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Report sent to ${patients[index]['name']}')),
                  );
                },
                child: Text('Send Report'),
              ),
            ],
          ),
        );
      },
    );
  }

  // وظيفة لتحرير تفاصيل المريض
  void _editPatientDetails(BuildContext context, int index) {
    TextEditingController emailController = TextEditingController(text: patients[index]['email']);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Patient Details'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Editing details for ${patients[index]['name']}'),
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    patients[index]['email'] = emailController.text;
                  });
                  Navigator.of(context).pop(); // إغلاق النافذة
                },
                child: Text('Save'),
              ),
            ],
          ),
        );
      },
    );
  }

  // وظيفة لعرض تفاصيل المريض
  void _viewPatientDetails(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Patient Details'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Name: ${patients[index]['name']}'),
              Text('Email: ${patients[index]['email']}'),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(); // إغلاق النافذة
                },
                child: Text('Close'),
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
                'View Patient',
                style: TextStyle(color: Color(0xFF7B0000), fontSize: 18),
              ),
              tileColor: Color(0xFFFFDDDD),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ViewPatientScreen()),
                );
              },
            ),
            Divider(),
            ListTile(
              title: Text(
                'Reports', // إضافة خيار التقارير المرسلة
                style: TextStyle(color: Color(0xFF7B0000), fontSize: 18),
              ),
              tileColor: Color(0xFFFFDDDD),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ReportScreen()), // الانتقال إلى صفحة التقارير المرسلة
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
