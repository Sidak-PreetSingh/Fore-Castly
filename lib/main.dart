import 'package:flutter/material.dart';
import 'package:weather_app1/weather_screen.dart';
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget{
  const MyApp({super.key});

  @override
  Widget build(BuildContext context){
    return  MaterialApp(
      debugShowCheckedModeBanner: false,// now the app is not in debug
      theme: ThemeData.dark(useMaterial3: true),

      home: const WeatherScreen(),
    );
  }
}

