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
// Based on the parser https://github.com/mliebelt/pgn-parser/blob/main/src/pgn-rules.pegj

import 'package:petitparser/petitparser.dart';

class PgnGrammarDefinition extends GrammarDefinition {
  Parser start() => ref0(games).end();

  Parser games() =>
      ref0(ws).optional() &
      (ref0(game) & (ref0(ws) & ref0(game)).star()).optional() &
      ref0(ws).optional();

  Parser game() =>
      ref0(tags).optional() & ref0(comments).optional() & ref0(pgn);

  Parser tags() => ref0(tag) & (ref0(ws) & ref0(tag)).star();
  Parser tag() =>
      ref0(bl) &
      ref0(ws).optional() &
      ref0(tagKeyValue) &
      ref0(ws).optional() &
      ref0(br);

  Parser tagKeyValue() =>
      ref0(eventKey) & ref0(ws) & ref0(m_string) |
      ref0(siteKey) & ref0(ws) & ref0(m_string) |
      ref0(dateKey) & ref0(ws) & ref0(dateString) |
      ref0(roundKey) & ref0(ws) & ref0(m_string) |
      ref0(whiteTitleKey) & ref0(ws) & ref0(m_string) |
      ref0(blackTitleKey) & ref0(ws) & ref0(m_string) |
      ref0(whiteEloKey) & ref0(ws) & ref0(integerOrDashString) |
      ref0(blackEloKey) & ref0(ws) & ref0(integerOrDashString) |
      ref0(whiteUSCFKey) & ref0(ws) & ref0(integerString) |
      ref0(blackUSCFKey) & ref0(ws) & ref0(integerString) |
      ref0(whiteNAKey) & ref0(ws) & ref0(m_string) |
      ref0(blackNAKey) & ref0(ws) & ref0(m_string) |
      ref0(whiteTypeKey) & ref0(ws) & ref0(m_string) |
      ref0(blackTypeKey) & ref0(ws) & ref0(m_string) |
      ref0(whiteKey) & ref0(ws) & ref0(m_string) |
      ref0(blackKey) & ref0(ws) & ref0(m_string) |
      ref0(resultKey) & ref0(ws) & ref0(result) |
      ref0(eventDateKey) & ref0(ws) & ref0(dateString) |
      ref0(eventSponsorKey) & ref0(ws) & ref0(m_string) |
      ref0(sectionKey) & ref0(ws) & ref0(m_string) |
      ref0(stageKey) & ref0(ws) & ref0(m_string) |
      ref0(boardKey) & ref0(ws) & ref0(integerString) |
      ref0(openingKey) & ref0(ws) & ref0(m_string) |
      ref0(variationKey) & ref0(ws) & ref0(m_string) |
      ref0(subVariationKey) & ref0(ws) & ref0(m_string) |
      ref0(ecoKey) & ref0(ws) & ref0(m_string) |
      ref0(nicKey) & ref0(ws) & ref0(m_string) |
      ref0(timeKey) & ref0(ws) & ref0(timeString) |
      ref0(utcTimeKey) & ref0(ws) & ref0(timeString) |
      ref0(utcDateKey) & ref0(ws) & ref0(dateString) |
      ref0(timeControlKey) & ref0(ws) & ref0(timeControl) |
      ref0(setUpKey) & ref0(ws) & ref0(m_string) |
      ref0(fenKey) & ref0(ws) & ref0(m_string) |
      ref0(terminationKey) & ref0(ws) & ref0(m_string) |
      ref0(annotatorKey) & ref0(ws) & ref0(m_string) |
      ref0(modeKey) & ref0(ws) & ref0(m_string) |
      ref0(plyCountKey) & ref0(ws) & ref0(integerString) |
      ref0(variantKey) & ref0(ws) & ref0(m_string) |
      ref0(whiteRatingDiffKey) & ref0(ws) & ref0(m_string) |
      ref0(blackRatingDiffKey) & ref0(ws) & ref0(m_string) |
      ref0(whiteFideIdKey) & ref0(ws) & ref0(m_string) |
      ref0(blackFideIdKey) & ref0(ws) & ref0(m_string) |
      ref0(whiteTeamKey) & ref0(ws) & ref0(m_string) |
      ref0(blackTeamKey) & ref0(ws) & ref0(m_string) |
      ref0(clockKey) & ref0(ws) & ref0(colorClockTimeQ) |
      ref0(whiteClockKey) & ref0(ws) & ref0(clockTimeQ) |
      ref0(blackClockKey) & ref0(ws) & ref0(clockTimeQ) |
      ref0(stringNoQuot) & ref0(ws) & ref0(m_string);

  Parser eventKey() => string('Event') | string('event');
  Parser siteKey() => string('Site') | string('site');
  Parser dateKey() => string('Date') | string('date');
  Parser roundKey() => string('Round') | string('round');
  Parser whiteKey() => string('White') | string('white');
  Parser blackKey() => string('Black') | string('black');
  Parser resultKey() => string('Result') | string('result');
  Parser whiteTitleKey() =>
      string('WhiteTitle') |
      string('Whitetitle') |
      string('whitetitle') |
      string('whiteTitle');
  Parser blackTitleKey() =>
      string('BlackTitle') |
      string('Blacktitle') |
      string('blacktitle') |
      string('blackTitle');
  Parser whiteEloKey() =>
      string('WhiteELO') |
      string('WhiteElo') |
      string('Whiteelo') |
      string('whiteelo') |
      string('whiteElo');
  Parser blackEloKey() =>
      string('BlackELO') |
      string('BlackElo') |
      string('Blackelo') |
      string('blackelo') |
      string('blackElo');
  Parser whiteUSCFKey() =>
      string('WhiteUSCF') |
      string('WhiteUscf') |
      string('Whiteuscf') |
      string('whiteuscf') |
      string('whiteUscf');
  Parser blackUSCFKey() =>
      string('BlackUSCF') |
      string('BlackUscf') |
      string('Blackuscf') |
      string('blackuscf') |
      string('blackUscf');
  Parser whiteNAKey() =>
      string('WhiteNA') |
      string('WhiteNa') |
      string('Whitena') |
      string('whitena') |
      string('whiteNa') |
      string('whiteNA');
  Parser blackNAKey() =>
      string('BlackNA') |
      string('BlackNa') |
      string('Blackna') |
      string('blackna') |
      string('blackNA') |
      string('blackNa');
  Parser whiteTypeKey() =>
      string('WhiteType') |
      string('Whitetype') |
      string('whitetype') |
      string('whiteType');
  Parser blackTypeKey() =>
      string('BlackType') |
      string('Blacktype') |
      string('blacktype') |
      string('blackType');
  Parser eventDateKey() =>
      string('EventDate') |
      string('Eventdate') |
      string('eventdate') |
      string('eventDate');
  Parser eventSponsorKey() =>
      string('EventSponsor') |
      string('Eventsponsor') |
      string('eventsponsor') |
      string('eventSponsor');
  Parser sectionKey() => string('Section') | string('section');
  Parser stageKey() => string('Stage') | string('stage');
  Parser boardKey() => string('Board') | string('board');
  Parser openingKey() => string('Opening') | string('opening');
  Parser variationKey() => string('Variation') | string('variation');
  Parser subVariationKey() =>
      string('SubVariation') |
      string('Subvariation') |
      string('subvariation') |
      string('subVariation');
  Parser ecoKey() => string('ECO') | string('Eco') | string('eco');
  Parser nicKey() => string('NIC') | string('Nic') | string('nic');
  Parser timeKey() => string('Time') | string('time');
  Parser utcTimeKey() =>
      string('UTCTime') |
      string('UTCtime') |
      string('UtcTime') |
      string('Utctime') |
      string('utctime') |
      string('utcTime');
  Parser utcDateKey() =>
      string('UTCDate') |
      string('UTCdate') |
      string('UtcDate') |
      string('Utcdate') |
      string('utcdate') |
      string('utcDate');
  Parser timeControlKey() =>
      string('TimeControl') |
      string('Timecontrol') |
      string('timecontrol') |
      string('timeControl');
  Parser setUpKey() =>
      string('SetUp') | string('Setup') | string('setup') | string('setUp');
  Parser fenKey() => string('FEN') | string('Fen') | string('fen');
  Parser terminationKey() => string('Termination') | string('termination');
  Parser annotatorKey() => string('Annotator') | string('annotator');
  Parser modeKey() => string('Mode') | string('mode');
  Parser plyCountKey() =>
      string('PlyCount') |
      string('Plycount') |
      string('plycount') |
      string('plyCount');
  Parser variantKey() => string('Variant') | string('variant');
  Parser whiteRatingDiffKey() => string('WhiteRatingDiff');
  Parser blackRatingDiffKey() => string('BlackRatingDiff');
  Parser whiteFideIdKey() => string('WhiteFideId');
  Parser blackFideIdKey() => string('BlackFideId');
  Parser whiteTeamKey() => string('WhiteTeam');
  Parser blackTeamKey() => string('BlackTeam');
  Parser clockKey() => string('Clock');
  Parser whiteClockKey() => string('WhiteClock');
  Parser blackClockKey() => string('BlackClock');
  Parser anyKey() => ref0(stringNoQuot);

  Parser integer() => digit().plus();

  Parser whiteSpace() => string(' ').plus();
  Parser ws() => pattern(' \t\n\r').star();
  Parser wsp() => pattern(' \t\n\r').plus();
  Parser eol() => pattern('\n\r').plus();

  Parser innerComment() =>
      (ref0(ws) &
          ref0(bl) &
          string('%csl') &
          ref0(wsp) &
          ref0(colorFields) &
          ref0(ws) &
          ref0(br) &
          ref0(ws) &
          ref0(innerComment).star()) |
      (ref0(ws) &
          ref0(bl) &
          string('%cal') &
          ref0(wsp) &
          ref0(colorArrows) &
          ref0(ws) &
          ref0(br) &
          ref0(ws) &
          ref0(innerComment).star()) |
      (ref0(ws) &
          ref0(bl) &
          string('%') &
          ref0(clockCommand1D) &
          ref0(wsp) &
          ref0(clockValue1D) &
          ref0(ws) &
          ref0(br) &
          ref0(ws) &
          ref0(innerComment).star()) |
      (ref0(ws) &
          ref0(bl) &
          string('%') &
          ref0(clockCommand2D) &
          ref0(wsp) &
          ref0(clockValue2D) &
          ref0(ws) &
          ref0(br) &
          ref0(ws) &
          ref0(innerComment).star()) |
      (ref0(ws) &
          ref0(bl) &
          string('%eval') &
          ref0(wsp) &
          ref0(stringNoQuot) &
          ref0(ws) &
          ref0(br) &
          ref0(ws) &
          ref0(innerComment).star()) |
      (ref0(ws) &
          ref0(bl) &
          string('%') &
          ref0(stringNoQuot) &
          ref0(wsp) &
          ref0(nbr).plus() &
          ref0(br) &
          ref0(ws) &
          ref0(innerComment).star()) |
      (ref0(nonCommand).plus() & ref0(innerComment).star());

  Parser nonCommand() => string('[%').not() & string('}').not() & any();
  Parser nbr() => ref0(br).not() & any();

  Parser commentEndOfLine() =>
      ref0(semicolon) & pattern('\n\r').not().star() & ref0(eol);

  Parser colorFields() =>
      ref0(colorField) &
      ref0(ws) &
      (string(',') & ref0(ws) & ref0(colorField)).star();
  Parser colorField() => ref0(color) & ref0(field);

  Parser colorArrows() =>
      ref0(colorArrow) &
      ref0(ws) &
      (string(',') & ref0(ws) & ref0(colorArrow)).star();
  Parser colorArrow() => ref0(column) & ref0(field) & ref0(field);

  Parser color() => string('Y') | string('R') | string('G') | string('B');

  Parser field() => ref0(column) & ref0(row);

  Parser cl() => string('{');
  Parser cr() => string('}');

  Parser bl() => string('[');
  Parser br() => string(']');

  Parser semicolon() => string(';');
  Parser quotationMark() => string('"');
  Parser m_string() =>
      ref0(quotationMark) & string('"').neg().star() & ref0(quotationMark);
  Parser stringNoQuot() => pattern('-a-zA-Z0-9.').star();

  Parser dateString() =>
      ref0(quotationMark) &
      ref0(digitFields4) &
      string('.') &
      ref0(digitFields2) &
      string('.') &
      ref0(digitFields2) &
      ref0(quotationMark);

  Parser digitFields2() => pattern('0-9\?').times(2);
  Parser digitFields4() => pattern('0-9\?').times(4);

  Parser timeString() =>
      ref0(quotationMark) &
      pattern('0-9').plus() &
      string(':') &
      pattern('0-9').plus() &
      string(':') &
      pattern('0-9').plus() &
      ref0(millis).optional() &
      ref0(quotationMark);

  Parser colorClockTimeQ() =>
      ref0(quotationMark) & ref0(colorClockTime) & ref0(quotationMark);
  Parser colorClockTime() => ref0(clockColor) & string('/') & ref0(clockTime);
  Parser clockColor() => string('B') | string('W') | string('N');

  Parser clockTimeQ() =>
      ref0(quotationMark) & ref0(clockTime) & ref0(quotationMark);
  Parser clockTime() => ref0(clockValue1D);

  Parser timeControl() =>
      ref0(quotationMark) & ref0(tcnqs) & ref0(quotationMark);

  Parser tcnqs() => (ref0(tcnq) & (string(':') & ref0(tcnq)).star()).optional();

  Parser tcnq() =>
      string('?') |
      string('-') |
      (ref0(integer) &
          string('/') &
          ref0(integer) &
          string('+') &
          ref0(integer)) |
      (ref0(integer) & string('/') & ref0(integer)) |
      (ref0(integer) & string('+') & ref0(integer)) |
      ref0(integer) |
      string('*') & ref0(integer);

  Parser result() =>
      ref0(quotationMark) & ref0(innerResult) & ref0(quotationMark);
  Parser innerResult() =>
      string('1-0') | string('0-1') | string('1/2-1/2') | string('*');

  Parser integerOrDashString() =>
      ref0(integerString) |
      (ref0(quotationMark) & string('-') & ref0(quotationMark)) |
      (ref0(quotationMark) & ref0(quotationMark));
  Parser integerString() =>
      ref0(quotationMark) & pattern('0-9').plus() & ref0(quotationMark);

  Parser pgn() =>
      (ref0(ws).optional() &
          ref0(comments).optional() &
          ref0(ws).optional() &
          ref0(moveNumber).optional() &
          ref0(ws) &
          ref0(halfMove) &
          ref0(ws) &
          ref0(nags).optional() &
          ref0(drawOffer).optional() &
          ref0(ws) &
          ref0(comments).optional() &
          ref0(ws) &
          ref0(variation).optional() &
          ref0(pgn).optional()) |
      (ref0(ws).optional() & ref0(endGame) & ref0(ws));

  Parser drawOffer() => ref0(pl) & string('=') & ref0(pr);

  Parser endGame() => ref0(innerResult);
  Parser comments() => ref0(comment) & (ref0(ws) & ref0(comment)).star();

  Parser comment() =>
      (ref0(cl) & ref0(innerComment) & ref0(cr)) | ref0(commentEndOfLine);

  Parser millis() => string('.') & pattern('0-9').plus();

  Parser clockCommand() =>
      string('clk') | string('egt') | string('emt') | string('mct');
  Parser clockCommand1D() => string('clk') | string('egt') | string('emt');
  Parser clockCommand2D() => string('mct');

  Parser clockValue1D() =>
      ref0(hoursMinutes).optional() &
      ref0(digit) &
      ref0(digit).optional() &
      ref0(millis).optional();
  Parser clockValue2D() =>
      ref0(hoursMinutes).optional() & ref0(digit) & ref0(digit).optional();
  Parser hoursMinutes() => ref0(hoursClock) & ref0(minutesClock).optional();
  Parser hoursClock() => ref0(digit) & ref0(digit).star() & string(':');
  Parser minutesClock() => ref0(digit) & ref0(digit).optional() & string(':');

  Parser digit() => pattern('0-9');

  Parser variation() =>
      ref0(pl) & ref0(pgn) & ref0(pr) & ref0(variation).optional();
  Parser pl() => string('(');
  Parser pr() => string(')');

  Parser moveNumber() =>
      ref0(integer) & ref0(whiteSpace).star() & ref0(dot).plus();

  Parser dot() => string('.');

  Parser halfMove() =>
      (ref0(figure).optional() &
          ref0(discriminator) &
          ref0(strike).optional() &
          ref0(column) &
          ref0(row) &
          ref0(promotion).optional() &
          ref0(check).optional() &
          ref0(ws).optional() &
          string('e.p.').optional()) |
      (ref0(figure).optional() &
          ref0(column) &
          ref0(row) &
          ref0(strikeOrDash).optional() &
          ref0(column) &
          ref0(row) &
          ref0(promotion).optional() &
          ref0(check).optional()) |
      (ref0(figure).optional() &
          ref0(strike).optional() &
          ref0(column) &
          ref0(row) &
          ref0(promotion).optional() &
          ref0(check).optional()) |
      (string('O-O-O') & ref0(check).optional()) |
      (string('O-O') & ref0(check).optional()) |
      (ref0(figure) & string('@') & ref0(column) & ref0(row));

  Parser check() => string('+') | string('#');

  Parser promotion() => string('=') & ref0(promFigure);

  Parser nags() => ref0(nag) & ref0(ws) & ref0(nags).optional();

  Parser nag() =>
      (string('\$') & ref0(integer)) |
      string('!!') |
      string('??') |
      string('!?') |
      string('?!') |
      string('!') |
      string('?') |
      string('□') |
      string('=') |
      string('∞') |
      string('⩲') |
      string('⩱') |
      string('±') |
      string('∓') |
      string('+-') |
      string('-+') |
      string('⨀') |
      string('⟳') |
      string('→') |
      string('↑') |
      string('⇆') |
      string('D');

  Parser checkdisc() =>
      ref0(discriminator) & ref0(strike).optional() & ref0(column) & ref0(row);
  Parser discriminator() => ref0(column) | ref0(row);

  Parser figure() => pattern('RNBQKP');
  Parser promFigure() => pattern('RNBQ');

  Parser column() => pattern('a-h');
  Parser row() => pattern('1-8');

  Parser strike() => string('x');
  Parser strikeOrDash() => string('x') | string('-');
}
