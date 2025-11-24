import 'package:flutter/material.dart';
import 'package:flutter_app/core/services/theme/theme_provider.dart';
import 'package:flutter_app/core/services/theme/theme_test.dart';
import 'package:flutter_app/core/services/theme/themes.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(ChangeNotifierProvider(
    create: (Context) => ThemeProvider(),
    child: const MyApp(),
    ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const ThemeTest(),
      theme: Provider.of<ThemeProvider>(context).themeData,
    );
  }
}
