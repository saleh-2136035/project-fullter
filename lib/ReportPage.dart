import 'package:flutter/material.dart';

class ReportScreen extends StatelessWidget {
  final Map<String, String> patientData = {
    'date': 'February 4, 2025',
    'patientId': '123456',
    'patientName': 'Ahmed Ali',
    'age': '35 years',
    'coughType': 'Dry',
    'fever': 'Yes (38.2°C)',
    'coughDuration': '2 weeks',
    'shortnessOfBreath': 'Mild',
    'fatigueLevel': 'Moderate',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Report'),
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
              // تقرير المريض
              Text(
                'Report',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),

              // تفاصيل المريض
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Color(0xFF7B0000)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Date: ${patientData['date']}'),
                    Text('Patient ID: ${patientData['patientId']}'),
                    Text('Patient Name: ${patientData['patientName']}'),
                    Text('Age: ${patientData['age']}'),
                  ],
                ),
              ),
              SizedBox(height: 40),

              // نتائج التشخيص
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Color(0xFF7B0000)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Diagnosis Results',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF7B0000),
                      ),
                    ),
                    Divider(),
                    Text('Possible Condition: Bronchitis'),
                    Text('Cough Type: ${patientData['coughType']}'),
                    Text('Fever: ${patientData['fever']}'),
                    Text('Cough Duration: ${patientData['coughDuration']}'),
                    Text('Shortness of Breath: ${patientData['shortnessOfBreath']}'),
                    Text('Fatigue Level: ${patientData['fatigueLevel']}'),
                  ],
                ),
              ),
              SizedBox(height: 40),

              // زر تحميل التقرير
              ElevatedButton.icon(
                onPressed: () {
                  // يمكنك إضافة منطق لتحميل التقرير هنا
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF7B0000),
                ),
                icon: Icon(Icons.download, color: Colors.white),
                label: Text(
                  'Download Report',
                  style: TextStyle(color: Colors.white),
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
                'View Patient',
                style: TextStyle(color: Color(0xFF7B0000), fontSize: 18),
              ),
              tileColor: Color(0xFFFFDDDD),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              onTap: () {
                // الانتقال إلى صفحة View Patient
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
                // الانتقال إلى صفحة تسجيل الخروج
              },
            ),
          ],
        ),
      ),
    );
  }
}

