import 'package:flutter/material.dart';
import 'package:flutter_finance_app/provider/general_provider.dart';
import 'package:flutter_finance_app/screens/home_page.dart';
import 'package:flutter_finance_app/theme/theme_manager.dart';
import 'package:flutter_finance_app/no_production/statistic_provider.dart';
import 'package:provider/provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (context) => ThemeModel()),
      ChangeNotifierProvider(create: (context) => GeneralProvider()),
      ChangeNotifierProvider(create: (context) => StatisticProvider()),
    ],
    child: MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeModel>(
      builder: (context, theme, child) =>
        MaterialApp(
          title: 'Giulia App',
          debugShowCheckedModeBanner: false,
          theme: theme.currentTheme,
          home: HomePage(index: 0), // Set MyScreen as the home screen
        ),
    );
  }
}
