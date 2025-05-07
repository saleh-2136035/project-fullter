import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';

@GenerateMocks([http.Client])
void main() {} // لازم يكون فيه دالة main فاضية عشان ما يعطيك خطأ
