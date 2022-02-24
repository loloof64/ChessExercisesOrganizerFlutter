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
import 'package:chess_exercises_organizer/logic/history/history_builder.dart';

class ChessHistory extends StatefulWidget {
  final HistoryNode? historyTree;
  final double defaultWidth;
  final double defaultHeight;
  final void Function({required Move moveDone}) onMoveDoneUpdateRequest;
  const ChessHistory(
      {Key? key,
      required this.historyTree,
      required this.defaultWidth,
      required this.defaultHeight,
      required this.onMoveDoneUpdateRequest})
      : super(key: key);

  @override
  _ChessHistoryState createState() => _ChessHistoryState();
}

class _ChessHistoryState extends State<ChessHistory> {
  List<Widget> _recursivelyBuildWidgetsFromHistoryTree(HistoryNode tree) {
    final result = <Widget>[];

    HistoryNode? currentHistoryNode = tree;

    final currentPosition = currentHistoryNode.fen;
    do {
      final textComponent = Text(currentHistoryNode!.caption);
      result.add(
        currentPosition == null
            ? textComponent
            : TextButton(
                onPressed: () => widget.onMoveDoneUpdateRequest(
                    moveDone: currentHistoryNode!.relatedMove!),
                child: textComponent),
      );

      if (currentHistoryNode.result != null) {
        result.add(Text(currentHistoryNode.result!));
      }

      if (currentHistoryNode.variations.isNotEmpty) {
        currentHistoryNode.variations.forEach((currentVariation) {
          result.addAll(
              _recursivelyBuildWidgetsFromHistoryTree(currentVariation));
        });
      }

      currentHistoryNode = currentHistoryNode.next;
    } while (currentHistoryNode?.next != null);

    return result;
  }

  @override
  Widget build(BuildContext context) {
    final widgetsList = (widget.historyTree) != null
        ? _recursivelyBuildWidgetsFromHistoryTree(widget.historyTree!)
        : <Widget>[];
    return SingleChildScrollView(
      child: Container(
        color: Colors.amber[100],
        width: 300,
        child: Wrap(
          spacing: 10,
          runSpacing: 6,
          children: widgetsList,
        ),
      ),
    );
  }
}
