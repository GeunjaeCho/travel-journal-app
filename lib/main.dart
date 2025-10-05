import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart'; // 지역화 설정용
import 'home_screen.dart'; // 홈화면
import 'write_screen.dart'; // 글쓰기 화면
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '旅ログ',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomeScreen(), // 기본 첫 화면 → HomeScreen 표시
      debugShowCheckedModeBanner: false, // 오른쪽 상단 Debug 표시 제거

      // 지역화 설정 (DatePicker 정상 사용 위해 필수)
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        Locale('ko', ''), // 한국어
        Locale('en', ''), // 영어
      ],
    );
  }
}
