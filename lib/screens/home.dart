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
import 'package:logger/logger.dart';
import 'dart:async' show Future;
import '../logic/pgn/parser.dart';

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
        child: Column(children: [
          ElevatedButton(
            child: I18nText('home.play_button'),
            onPressed: () {
              GoRouter.of(context).go('/game');
            },
          ),
          //////////////////////////////
          ElevatedButton(
            onPressed: () async {
              var pgnString = await loadPgnFromAsset(
                  assetRef: 'KQ_K.pgn', context: context);
              try {
                var result = getPgnData(pgnString);
                Logger().i(result);
              } on PgnParsingException catch (_) {
                Logger().e('Failed to parse pgn !');
              }
            },
            child: Text('Test parse pgn'),
          )
          //////////////////////////////
        ]),
      ),
    );
  }
}
