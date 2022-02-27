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
import 'dart:ffi';

import 'package:petitparser/petitparser.dart';
import 'grammar.dart';

class PgnParsingException implements Exception {}

class PgnParserDefinition extends PgnGrammarDefinition {
  var _messages = [];

  int _makeInteger(o) {
    return int.parse(o);
  }

  dynamic _mi(o) {
    return RegExp(r'\?').hasMatch(o.join(''))
        ? o.join('')
        : _makeInteger(o.join(''));
  }

  void _addMessage(json) {
    _messages.add(json);
  }

  Map<dynamic, dynamic> _merge(arr) {
    var ret = {};
    arr.forEach((json) {
      for (var key in json) {
        if (json[key] is Array) {
          ret[key] = ret[key] ? ret[key].addAll(json[key]) : json[key];
        } else {
          ret[key] = ret[key]
              ? _trimEnd(ret[key]) + " " + _trimStart(json[key])
              : json[key];
        }
      }
    });
    return ret;
  }

  dynamic _trimStart(st) {
    if (st is String) {
      var r = RegExp(r"^\s+");
      return st.replaceFirst(r, '');
    } else {
      return st;
    }
  }

  dynamic _trimEnd(st) {
    if (st is String) {
      var r = RegExp(r"\s+$");
      return st.replaceFirst(r, '');
    } else {
      return st;
    }
  }

  @override
  Parser games() => super.games().map((each) {
        final games = each[1];
        var result;
        if (games != null) {
          final head = games[0];
          final tail = games[1].map((elt) => elt[1]);
          result = [head];
          result.addAll(tail);
        } else {
          result = [];
        }
        return result;
      });

  @override
  Parser game() => super.game().map((each) {
        var message = _messages;
        _messages = [];
        return {
          'tags': each[0],
          'gameComment': each[1],
          'moves': each[2],
          'messages': message,
        };
      });

  @override
  Parser tags() => super.tags().map((each) {
        var members = {};
        final head = each[0];
        final tail = each[1].map((elt) => elt[1]);
        var temp = [head];
        temp.addAll(tail);
        temp.forEach((element) {
          members[element['name']] = element['value'];
        });
        return members;
      });

  @override
  Parser tag() => super.tag().map((each) {
        return each[2];
      });

  @override
  Parser tagKeyValue() => super.tagKeyValue().map((each) {
        final key = each[0];
        final value = each[2];

        var usedKey = key;
        switch (key.toLowerCase()) {
          case 'event':
            usedKey = 'Event';
            break;
          case 'site':
            usedKey = 'Site';
            break;
          case 'date':
            usedKey = 'Date';
            break;
          case 'round':
            usedKey = 'Round';
            break;
          case 'whitetitle':
            usedKey = 'WhiteTitle';
            break;
          case 'blacktitle':
            usedKey = 'BlackTitle';
            break;
          case 'whiteelo':
            usedKey = 'WhiteElo';
            break;
          case 'blackelo':
            usedKey = 'BlackElo';
            break;
          case 'whiteuscf':
            usedKey = 'WhiteUSCF';
            break;
          case 'blackuscf':
            usedKey = 'BlackUSCF';
            break;
          case 'whitena':
            usedKey = 'WhiteNA';
            break;
          case 'blackna':
            usedKey = 'BlackNA';
            break;
          case 'whitetype':
            usedKey = 'WhiteType';
            break;
          case 'blacktype':
            usedKey = 'BlackType';
            break;
          case 'white':
            usedKey = 'White';
            break;
          case 'black':
            usedKey = 'Black';
            break;
          case 'result':
            usedKey = 'Result';
            break;
          case 'eventdate':
            usedKey = 'EventDate';
            break;
          case 'eventsponsor':
            usedKey = 'EventSponsor';
            break;
          case 'section':
            usedKey = 'Section';
            break;
          case 'stage':
            usedKey = 'Stage';
            break;
          case 'board':
            usedKey = 'Board';
            break;
          case 'opening':
            usedKey = 'Opening';
            break;
          case 'variation':
            usedKey = 'Variation';
            break;
          case 'subvariation':
            usedKey = 'SubVariation';
            break;
          case 'eco':
            usedKey = 'ECO';
            break;
          case 'nic':
            usedKey = 'NIC';
            break;
          case 'time':
            usedKey = 'Time';
            break;
          case 'utctime':
            usedKey = 'UTCTime';
            break;
          case 'utcdate':
            usedKey = 'UTCDate';
            break;
          case 'timecontrol':
            usedKey = 'TimeControl';
            break;
          case 'setup':
            usedKey = 'SetUp';
            break;
          case 'fen':
            usedKey = 'FEN';
            break;
          case 'termination':
            usedKey = 'Termination';
            break;
          case 'annotator':
            usedKey = 'Annotator';
            break;
          case 'mode':
            usedKey = 'Mode';
            break;
          case 'plycount':
            usedKey = 'PlyCount';
            break;
          case 'variant':
            usedKey = 'Variant';
            break;
          case 'whiteratingdiff':
            usedKey = 'WhiteRatingDiff';
            break;
          case 'blackratingdiff':
            usedKey = 'BlackRatingDiff';
            break;
          case 'whitefideid':
            usedKey = 'WhiteFideId';
            break;
          case 'blackfideid':
            usedKey = 'BlackFideId';
            break;
          case 'whiteteam':
            usedKey = 'WhiteTeam';
            break;
          case 'blackteam':
            usedKey = 'BlackTeam';
            break;
          case 'clock':
            usedKey = 'Clock';
            break;
          case 'whiteclock':
            usedKey = 'WhiteClock';
            break;
          case 'blackclock':
            usedKey = 'BlackClock';
            break;
        }
        return {'name': usedKey, 'value': value};
      });

  @override
  Parser m_string() => super.m_string().map((each) {
        return each[1].join('');
      });

  @override
  Parser ws() => super.ws().map((each) {
        return '';
      });

  @override
  Parser wsp() => super.wsp().map((each) {
        return '';
      });

  @override
  Parser eol() => super.eol().map((each) {
        return '';
      });

  @override
  Parser whiteSpace() => super.whiteSpace().map((each) {
        return '';
      });

  @override
  Parser stringNoQuot() => super.stringNoQuot().map((each) {
        return each.join('');
      });

  @override
  Parser dateString() => super.dateString().map((each) {
        final year = each[1];
        final month = each[3];
        final day = each[5];

        final val = "${year.join('')}.${month.join('')}.${day.join('')}";
        return {
          'value': val,
          'year': _mi(year),
          'month': _mi(month),
          'day': _mi(day)
        };
      });

  @override
  Parser timeString() => super.timeString().map((each) {
        final hours = each[1];
        final minutes = each[3];
        final seconds = each[5];
        final millis = each[6];

        var val = "${hours.join('')}:${minutes.join('')}:${seconds.join('')}";
        var ms = 0;
        if (millis != null) {
          val += '.${millis}';
          _addMessage({'message': "Unusual use of millis in time: ${val}"});
          ms = _mi(millis);
        }

        return {
          'value': val,
          'hour': _mi(hours),
          'minute': _mi(minutes),
          'second': _mi(seconds),
          'millis': ms
        };
      });

  @override
  Parser millis() => super.millis().map((each) {
        return each[1].join('');
      });

  @override
  Parser colorClockTimeQ() => super.colorClockTimeQ().map((each) {
        return each[1];
      });

  @override
  Parser colorClockTime() => super.colorClockTime().map((each) {
        return "${each[0]}/${each[2]}";
      });

  @override
  Parser clockTimeQ() => super.clockTimeQ().map((each) {
        return each[1];
      });

  @override
  Parser clockTime() => super.clockTime().map((each) {
        return each[0];
      });

  @override
  Parser timeControl() => super.timeControl().map((each) {
        final res = each[1];
        if (res == null) {
          _addMessage({'message': "Tag TimeControl has to have a value"});
          return '';
        } else {
          return res;
        }
      });

  @override
  Parser tcnqs() => super.tcnqs().map((each) {
        final tcnqsField = each[0];
        var tcnqs = [];
        if (tcnqsField != null) {
          final head = tcnqsField[0];
          final tail = tcnqsField[1].map((elt) => elt[1]);
          tcnqs = [head];
          tcnqs.addAll(tail);
        }
        return tcnqs;
      });

  @override
  Parser tcnq() => super.tcnq().map((each) {
        final field0 = each[0];
        if (field0 == '?') {
          return {'kind': 'unknown', 'value': '?'};
        } else if (field0 == '-') {
          return {'kind': 'unlimited', 'value': '-'};
        } else if (field0 == '*') {
          final seconds = each[1];
          return {'kind': 'hourglass', 'seconds': seconds};
        } else {
          if (each.length == 1) {
            final seconds = each[0];
            return {'kind': 'suddenDeath', 'seconds': seconds};
          } else if (each[1] == '+') {
            final seconds = each[0];
            final incr = each[2];
            return {'kind': 'increment', 'seconds': seconds, 'increment': incr};
          } else if (each.length == 3) {
            final moves = each[0];
            final seconds = each[2];
            return {
              'kind': 'movesInSeconds',
              'moves': moves,
              'seconds': seconds
            };
          } else {
            final moves = each[0];
            final seconds = each[2];
            final incr = each[4];
            return {
              'kind': 'movesInSecondsIncrement',
              'moves': moves,
              'seconds': seconds,
              'increment': incr
            };
          }
        }
      });

  @override
  Parser result() => super.result().map((each) {
        return each[1];
      });

  @override
  Parser integerOrDashString() => super.integerOrDashString().map((each) {
        if (each.length == 1) {
          return each[0];
        } else if (each.length == 3) {
          return 0;
        } else {
          _addMessage({'message': 'Use "-" for an unknown value'});
          return 0;
        }
      });

  @override
  Parser integerString() => super.integerString().map((each) {
        return _makeInteger(each[1]);
      });

  @override
  Parser pgn() => super.pgn().map((each) {
        if (each.length == 3) {
          return each[1];
        } else {
          final cm = each[1];
          final mn = each[3];
          final hm = each[5];
          final nag = each[7];
          final dr = each[8];
          final ca = each[10];
          final vari = each[12];
          final all = each[13];

          var arr = all ?? [];
          var move = {};
          move['moveNumber'] = mn;
          move['notation'] = hm;
          if (ca != null) move['commentAfter'] = ca.comment;
          if (cm != null) move['commentMove'] = cm.comment;
          if (dr != null) move['drawOffer'] = true;
          move['variations'] = vari ?? [];
          move['nag'] = nag ?? null;
          move['commentDiag'] = ca;
          arr.insert(0, move);
          return arr;
        }
      });

  @override
  Parser endGame() => super.endGame().map((each) {
        return [each];
      });

  @override
  Parser comments() => super.comments().map((each) {
        final cf = each[0];
        final cfl = each[1].map((elt) => elt[1]);
        var res = [cf];
        res.addAll(cfl);
        return _merge(res);
      });

  @override
  Parser comment() => super.comment().map((each) {
        if (each.length == 3)
          return each[1];
        else
          return {'comment': each[0]};
      });

  @override
  Parser innerComment() => super.comment().map((each) {
        if (each.length == 2) {
          final c = each[0];
          final tail = each[1].map((elt) => elt[0]);
          if (tail.isNotEmpty()) {
            var temp = [
              {comment: _trimEnd(c.join(""))}
            ];
            temp.addAll(_trimStart(tail[0]));
            return _merge(temp);
          }
        } else if (each[2] == '%csl') {
          final cf = each[4];
          final tail = each[8].map((elt) => elt[1]);
          var temp = [
            {colorFields: cf}
          ];
          temp.addAll(tail[0]);
          return _merge(temp);
        } else if (each[2] == '%cal') {
          final ca = each[4];
          final tail = each[8].map((elt) => elt[0]);
          var temp = [
            {colorArrows: ca}
          ];
          temp.addAll(tail[0]);
          return _merge(temp);
        } else if (each[2] == '%' && each.length == 10) {
          final cc = each[3];
          final cv = each[5];
          final tail = each[9].map((elt) => elt[0]);

          var ret = {};
          ret[cc] = cv;

          var temp = [ret];
          temp.addAll(tail[0]);

          return _merge(temp);
        } else if (each[2] == '%') {
          final ac = each[3];
          final val = each[5];
          final tail = each[8].map((elt) => elt[0]);

          var ret = {};
          ret[ac] = val.join("");
          var temp = [ret];
          temp.addAll(tail[0]);

          return _merge(temp);
        }
        // each[2] == '%eval'
        else {
          final ev = each[4];
          final tail = each[8].map((elt) => elt[0]);
          var ret = {};
          ret['eval'] = double.parse(ev);

          var temp = [ret];
          temp.addAll(tail[0]);

          return _merge(temp);
        }
      });

  @override
  Parser nonCommand() => super.nonCommand().map((each) {
        return each[0];
      });

  @override
  Parser nbr() => super.nbr().map((each) {
        return each[0];
      });

  @override
  Parser commentEndOfLine() => super.commentEndOfLine().map((each) {
        return each[1].join('');
      });

  @override
  Parser colorFields() => super.colorFields().map((each) {
        final cf = each[0];
        final cfl = each[2].map((elt) => elt[2]);
        var arr = [];
        arr.add(cf);
        for (var i = 0; i < cfl.length; i++) {
          arr.add(cfl[i]);
        }
        return arr;
      });

  @override
  Parser colorField() => super.colorField().map((each) {
        final col = each[0];
        final f = each[1];
        return col + f;
      });

  @override
  Parser colorArrows() => super.colorArrows().map((each) {
        final cf = each[0];
        final cfl = each[1].map((elt) => elt[2]);

        var arr = [];
        arr.add(cf);
        for (var i = 0; i < cfl.length; i++) {
          arr.add(cfl[i]);
        }
        ;
        return arr;
      });

  @override
  Parser colorArrow() => super.colorArrow().map((each) {
        final col = each[0];
        final ff = each[1];
        final ft = each[2];

        return col + ff + ft;
      });

  @override
  Parser field() => super.field().map((each) {
        final col = each[0];
        final row = each[1];

        return col + row;
      });

  @override
  Parser clockValue1D() => super.clockValue1D().map((each) {
        final hm = each[0];
        final s1 = each[1];
        final s2 = each[2];

        var ret = s1;
        if (hm == null) {
          _addMessage({'message': 'Hours and minutes missing'});
        } else {
          ret = hm + ret;
        }
        if ((hm != null) && ((RegExp(':').allMatches(hm)).length == 2)) {
          if (hm.search(':') == 1) {
            _addMessage({'message': 'Only 2 digits for hours normally used'});
          }
        }
        if (!s2) {
          _addMessage({'message': 'Only 2 digit for seconds normally used'});
        } else {
          ret += s2;
        }
        return ret;
      });

  @override
  Parser hoursMinutes() => super.hoursMinutes().map((each) {
        final hours = each[0];
        final minutes = each[1];

        if (minutes != null) {
          _addMessage({'message': 'No hours found'});
          return hours;
        }
        return hours + minutes;
      });

  @override
  Parser hoursClock() => super.hoursClock().map((each) {
        final h1 = each[0];
        final h2 = each[1];

        var ret = h1;
        if (h2) {
          ret += h2 + ":";
        } else {
          ret += ":";
        }
        return ret;
      });

  @override
  Parser minutesClock() => super.minutesClock().map((each) {
        final m1 = each[0];
        final m2 = each[1];

        var ret = m1;
        if (m2) {
          ret += m2 + ":";
        } else {
          ret += ":";
          _addMessage({'message': 'Only 2 digits for minutes normally used'});
        }
        return ret;
      });

  @override
  Parser variation() => super.variation().map((each) {
        final vari = each[1];
        final all = each[3];

        var arr = all ?? [];
        arr.insert(0, vari);
        return arr;
      });

  @override
  Parser moveNumber() => super.moveNumber().map((each) {
        return each[0];
      });

  @override
  Parser integer() => super.integer().map((each) {
        return _makeInteger(each.join(''));
      });

  @override
  Parser promotion() => super.promotion().map((each) {
        return each[1];
      });

  @override
  Parser halfMove() => super.halfMove().map((each) {
        if (each[0] == 'O-O-O') {
          final ch = each[1];
          return 'O-O-O' + (ch ?? "");
        } else if (each[0] == 'O-O') {
          final ch = each[1];
          return 'O-O' + (ch ?? "");
        } else if (each[1] == '@') {
          final fig = each[0];
          final col = each[2];
          final row = each[3];

          return fig + '@' + col + row;
        } else if (each.length == 6) {
          final fig = each[0];
          final str = each[1];
          final col = each[2];
          final row = each[3];
          final pr = each[4];
          final ch = each[5];

          return (fig ?? "") +
              (str ?? "") +
              col +
              row +
              (pr ?? "") +
              (ch ?? "");
        } else if (each.length == 8) {
          final fig = each[0];
          final cols = each[1];
          final rows = each[2];
          final str = each[3];
          final col = each[4];
          final row = each[5];
          final pr = each[6];
          final ch = each[7];

          return (fig && (fig != 'P') ? fig : "") +
              cols +
              rows +
              (str == 'x' ? str : "-") +
              col +
              row +
              (pr ?? "") +
              (ch ?? "");
        }
        // each length is 9
        else {
          final fig = each[0];
          final disc = each[1];
          final str = each[2];
          final col = each[3];
          final row = each[4];
          final pr = each[5];
          final ch = each[6];

          return (fig ?? "") +
              (disc ?? "") +
              (str ?? "") +
              col +
              row +
              (pr ?? "") +
              (ch ?? "");
        }
      });

  @override
  Parser nags() => super.nags().map((each) {
        final nag = each[0];
        final nags = each[2];

        var arr = nags ?? [];
        arr.insert(0, nag);
        return arr;
      });

  @override
  Parser nag() => super.nag().map((each) {
        if (each.length == 2) {
          return '\$' + each[1].toString();
        } else {
          switch (each[0]) {
            case '!!':
              return '\$3';
            case '??':
              return '\$4';
            case '!?':
              return '\$5';
            case '?!':
              return '\$6';
            case '!':
              return '\$1';
            case '?':
              return '\$2';
            case '‼':
              return '\$3';
            case '⁇':
              return '\$4';
            case '⁉':
              return '\$5';
            case '⁈':
              return '\$6';
            case '□':
              return '\$7';
            case '=':
              return '\$10';
            case '∞':
              return '\$13';
            case '⩲':
              return '\$14';
            case '⩱':
              return '\$15';
            case '±':
              return '\$16';
            case '∓':
              return '\$17';
            case '+-':
              return '\$18';
            case '-+':
              return '\$19';
            case '⨀':
              return '\$22';
            case '⟳':
              return '\$32';
            case '→':
              return '\$36';
            case '↑':
              return '\$40';
            case '⇆':
              return '\$132';
            case 'D':
              return '\$220';
          }
        }
      });
}

dynamic _parsePgn(String pgnContent) {
  var definition = PgnParserDefinition();
  var parser = definition.build();
  return parser.parse(pgnContent);
}

dynamic _recursivelyAdaptPgnMoves(
    {required dynamic valueToTransform,
    required bool startsWithWhiteTurn,
    required dynamic accum}) {
  if (valueToTransform.isEmpty) {
    return accum;
  }

  var result = accum;
  bool whiteTurn = startsWithWhiteTurn;
  int? moveNumber = null;

  for (var moveData in valueToTransform) {
    // MoveData can also be a string, for the result.
    if (moveData is Map) {
      var transformedData = Map.from(moveData);
      if (transformedData['moveNumber'] != null) {
        moveNumber = transformedData['moveNumber'];
      } else {
        transformedData['moveNumber'] = moveNumber;
      }
      transformedData['whiteTurn'] = whiteTurn;
      transformedData['variations'] = [];

      if (moveData['variations'].isNotEmpty) {
        for (var variationData in moveData['variations']) {
          transformedData['variations'].add(_recursivelyAdaptPgnMoves(
              valueToTransform: variationData,
              startsWithWhiteTurn: whiteTurn,
              accum: []));
        }
      }

      result.add(transformedData);

      whiteTurn = !whiteTurn;
      if (moveNumber != null && whiteTurn) moveNumber++;
    }
    // MoveData is a string, for the result.
    else {
      result.add({'result': moveData});
    }
  }

  return result;
}

dynamic _adaptPgnArray(dynamic pgnArray) {
  var result = [];
  pgnArray.forEach((current) {
    var transformedData = {};
    transformedData['tags'] = current['tags'];
    transformedData['gameComment'] = current['gameComment'];
    var startsWithWhiteTurn = true;
    if (transformedData['tags'].containsKey('FEN')) {
      final startPosition = transformedData['tags']['FEN'];
      startsWithWhiteTurn = startPosition.split(' ')[1] == 'w';
    }
    transformedData['moves'] = _recursivelyAdaptPgnMoves(
        valueToTransform: current['moves'],
        startsWithWhiteTurn: startsWithWhiteTurn,
        accum: []);
    result.add(transformedData);
  });
  return result;
}

dynamic getPgnData(String pgnContent) {
  var pgnArray = _parsePgn(pgnContent);
  if (pgnArray.isSuccess) {
    return _adaptPgnArray(pgnArray.value);
  } else {
    throw PgnParsingException();
  }
}
