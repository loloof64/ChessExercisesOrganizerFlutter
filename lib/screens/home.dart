/*
    Chess exercises organizer : oad your chess exercises and train yourself against the device.
    Copyright (C) 2022  Laurent Bernabe <laurent.bernabe@gmail.com>

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <https://www.gnu.org/licenses/>.
*/

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:async' show Future;
import '../logic/pgn/parser.dart';
import '../screens/home/samples.dart';
import '../screens/home/customs.dart';

Future<String> loadPgnFromAsset(
    {required BuildContext context, required String assetRef}) async {
  return await DefaultAssetBundle.of(context)
      .loadString('assets/pgn/$assetRef');
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentScreenIndex = 0;
  List _screens = [SamplesScreen(), CustomsScreen()];

  void _setScreen(int index) {
    setState(() {
      _currentScreenIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final samplesTitle = FlutterI18n.translate(context, "home.samples_tab");
    final customsTitle = FlutterI18n.translate(context, "home.customs_tab");
    return Scaffold(
      appBar: AppBar(
        title: Text(
          FlutterI18n.translate(
            context,
            'home.title',
          ),
        ),
      ),
      body: _screens[_currentScreenIndex],
      bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: _currentScreenIndex,
          backgroundColor: Colors.blue[200],
          selectedItemColor: Colors.blue[900],
          selectedFontSize: 13,
          unselectedFontSize: 10,
          iconSize: 30,
          onTap: _setScreen,
          items: [
            BottomNavigationBarItem(
              label: samplesTitle,
              icon: SvgPicture.asset(
                'assets/vectors/gift.svg',
                width: 20,
                height: 20,
                fit: BoxFit.cover,
              ),
            ),
            BottomNavigationBarItem(
              label: customsTitle,
              icon: SvgPicture.asset(
                'assets/vectors/homework.svg',
                width: 20,
                height: 20,
                fit: BoxFit.cover,
              ),
            ),
          ]),
    );
  }
}
