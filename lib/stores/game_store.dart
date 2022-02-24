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
import 'package:chess/chess.dart' as chesslib;

class NoGameAvailableException implements Exception {}

class IndexOutOfBoundsException implements Exception {}

class GameStore extends ChangeNotifier {
  int _selectedGameIndex = 0;
  dynamic _pgnTree = [];
  String _fileTitle = '';

  int get selectedGameIndex => _selectedGameIndex;
  dynamic get pgnTree => _pgnTree;
  String get fileTitle => _fileTitle;

  void changeSelectedGameIndex(int newIndex) {
    if (_pgnTree.isEmpty) throw NoGameAvailableException;
    if (newIndex < 0) throw IndexOutOfBoundsException();
    if (_pgnTree.length <= newIndex) throw IndexOutOfBoundsException();
    _selectedGameIndex = newIndex;
    notifyListeners();
  }

  void changePgnTree(dynamic newPgnTree) {
    _pgnTree = newPgnTree;
    notifyListeners();
  }

  void changeFileTitle(String newTitle) {
    _fileTitle = newTitle;
    notifyListeners();
  }

  int get gamesCount => _pgnTree.length;

  dynamic getSelectedGame() {
    if (_pgnTree.isEmpty) throw NoGameAvailableException;
    return _pgnTree[_selectedGameIndex];
  }

  String getStartPosition() {
    if (_pgnTree.isEmpty) throw NoGameAvailableException;
    var selectedExercise = _pgnTree[_selectedGameIndex];
    String startPosition;
    if (selectedExercise.containsKey('tags') &&
        selectedExercise['tags'].containsKey('FEN')) {
      startPosition = selectedExercise['tags']['FEN'];
    } else {
      startPosition = chesslib.Chess.DEFAULT_POSITION;
    }

    return startPosition;
  }

  void gotoFirstGame() {
    if (_pgnTree.isEmpty) throw NoGameAvailableException;
    _selectedGameIndex = 0;
    notifyListeners();
  }

  void gotoLastGame() {
    if (_pgnTree.isEmpty) throw NoGameAvailableException;
    _selectedGameIndex = _pgnTree.length - 1;
    notifyListeners();
  }

  void gotoPreviousGame() {
    if (_pgnTree.isEmpty) throw NoGameAvailableException;
    if (_selectedGameIndex > 0) {
      _selectedGameIndex--;
      notifyListeners();
    }
  }

  void gotoNextGame() {
    if (_pgnTree.isEmpty) throw NoGameAvailableException;
    if (_selectedGameIndex < _pgnTree.length - 1) {
      _selectedGameIndex++;
      notifyListeners();
    }
  }

  String? getGameGoal() {
    if (_pgnTree.isEmpty) throw NoGameAvailableException;
    final selectedGame = _pgnTree[_selectedGameIndex];
    return selectedGame['tags'].containsKey('Goal')
        ? selectedGame['tags']['Goal']
        : null;
  }
}
