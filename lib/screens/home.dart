import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_i18n/flutter_i18n.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          FlutterI18n.translate(
            context,
            'home.title',
          ),
        ),
      ),
      body: Center(
        child: ElevatedButton(
          child: I18nText('home.play_button'),
          onPressed: () {
            GoRouter.of(context).go('/game');
          },
        ),
      ),
    );
  }
}
