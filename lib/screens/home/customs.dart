/*
    Chess exercises organizer : load your chess exercises and train yourself against the device.
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
