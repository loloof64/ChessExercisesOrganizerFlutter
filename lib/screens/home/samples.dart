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
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SamplesScreen extends StatelessWidget {
  final _sampleFiles = <String>['KQ_K', 'K2R_K', 'KR_K', 'KP_K'];
  final void Function(
      {required String pgnAssetRef, required BuildContext context}) onItemTap;
  SamplesScreen({Key? key, required this.onItemTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: _sampleFiles.length,
      itemBuilder: (ctx, index) {
        final itemRef = _sampleFiles[index];
        final itemText = FlutterI18n.translate(
          context,
          'sample_games.$itemRef',
        );

        return ListTile(
          leading: SvgPicture.asset(
            'assets/vectors/text_file.svg',
            width: 60,
            height: 60,
            fit: BoxFit.cover,
          ),
          title: Text(
            itemText,
            style: TextStyle(
              fontSize: 18,
            ),
          ),
          onTap: () => onItemTap(
            pgnAssetRef: _sampleFiles[index],
            context: context,
          ),
        );
      },
      separatorBuilder: (context, index) => SizedBox(
        height: 10,
      ),
      padding: EdgeInsets.only(top: 10),
    );
  }
}
