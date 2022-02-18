import 'package:flutter/material.dart';

class CustomsScreen extends StatefulWidget {
  const CustomsScreen({Key? key}) : super(key: key);

  @override
  _CustomsScreenState createState() => _CustomsScreenState();
}

class _CustomsScreenState extends State<CustomsScreen> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Customs PGN'),
    );
  }
}
