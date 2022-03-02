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

class ChessHistory extends StatelessWidget {
  final HistoryNode? historyTree;
  final double width;
  final double height;
  final void Function({required Move moveDone}) onMoveDoneUpdateRequest;
  const ChessHistory(
      {Key? key,
      required this.historyTree,
      required this.width,
      required this.height,
      required this.onMoveDoneUpdateRequest})
      : super(key: key);

  List<Widget> _recursivelyBuildWidgetsFromHistoryTree(HistoryNode tree) {
    final result = <Widget>[];

    HistoryNode? currentHistoryNode = tree;

    final currentPosition = currentHistoryNode.fen;
    final fontSize = width * 0.05;

    do {
      final textComponent = Text(
        currentHistoryNode!.caption,
        style: TextStyle(fontSize: fontSize),
      );
      result.add(
        currentPosition == null
            ? textComponent
            : TextButton(
                onPressed: () => onMoveDoneUpdateRequest(
                    moveDone: currentHistoryNode!.relatedMove!),
                child: textComponent),
      );

      if (currentHistoryNode.result != null) {
        result.add(Text(currentHistoryNode.result!));
      }

      if (currentHistoryNode.variations.isNotEmpty) {
        currentHistoryNode.variations.forEach((currentVariation) {
          final currentVariationResult =
              _recursivelyBuildWidgetsFromHistoryTree(currentVariation);
          result.addAll(currentVariationResult);
        });
      }

      currentHistoryNode = currentHistoryNode.next;
    } while (currentHistoryNode != null);

    return result;
  }

  @override
  Widget build(BuildContext context) {
    final widgetsList = (historyTree) != null
        ? _recursivelyBuildWidgetsFromHistoryTree(historyTree!)
        : <Widget>[];
    return Expanded(
      child: SingleChildScrollView(
        child: Expanded(
          child: Container(
            color: Colors.amber[100],
            child: Wrap(
              spacing: 10,
              runSpacing: 6,
              children: widgetsList,
            ),
          ),
        ),
      ),
    );
  }
}
