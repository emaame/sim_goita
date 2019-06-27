import 'package:flutter_web/material.dart';
import 'dart:math';
import 'goita.dart';

class FilterEditor extends StatefulWidget {
  @override
  FilterEditorState createState() => FilterEditorState();
}

const Komas = [
  Koma.SHI,
  Koma.GON,
  Koma.UMA,
  Koma.GIN,
  Koma.KIN,
  Koma.KAKU,
  Koma.HI,
  Koma.OU,
];
const CondTargets = [
  CondTarget.P1,
  CondTarget.P2,
  CondTarget.P3,
  CondTarget.P4,
  CondTarget.PAIR_FRIEND,
  CondTarget.PAIR_ENEMY,
  CondTarget.WHOLE
];
const CondTypes = [
  CondType.LESS,
  CondType.LESS_THAN,
  CondType.EQUAL,
  CondType.MORE_THAN,
  CondType.MORE
];
const NstoText = {
  0: "0",
  1: "1",
  2: "2",
  3: "3",
  4: "4",
  5: "5",
  6: "6",
  7: "7",
  8: "8",
  9: "9",
  10: "10",
};

class FilterEditorState extends State<FilterEditor> {
  Koma koma;
  int n;
  CondType condType;
  CondTarget condTarget;

  FilterEditorState() {
    koma = Koma.SHI;
    condType = CondType.EQUAL;
    condTarget = CondTarget.P1;
    n = 1;
  }

  DropdownButton<_T> _buildDropdownButton<_T>(_T value, Function(_T) onChanged, Iterable<_T> list, Map<_T, String> nameDict) {
    return DropdownButton<_T>(
      value: value,
      onChanged: onChanged,
      items: list.map<DropdownMenuItem<_T>>((_T value) {
        return DropdownMenuItem<_T>(
          value: value,
          child: Text(nameDict[value]),
        );
      }).toList(),
    );
  }
  int maxN() {
    switch(koma) {
      case Koma.SHI:
        return 10;
      case Koma.GON: case Koma.UMA:
      case Koma.GIN: case Koma.KIN:
        return 4;
      case Koma.KAKU: case Koma.HI:
      case Koma.OU:
        return 2;
      default:
        return 4;
    }
  }

  @override
  Widget build(BuildContext context) {
    var ns = List.generate(maxN()+1, (i) => i);
    return Scaffold(
        appBar: AppBar(
          title: Text('フィルタの編集'),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Card(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children:[
                  /* ここで無名関数を作らないと不自然なエラーが出ることがある */
                  _buildDropdownButton(
                    condTarget,
                    (CondTarget newT) { setState(() {condTarget = newT;}); },
                    CondTargets, CondTargetToName),
                  Text(" が "),
                  _buildDropdownButton(
                    koma,
                    (Koma newK) { setState(() {koma = newK; n = min(n ?? 0, maxN());}); },
                    Komas, KomaToName),
                  Text(" を "),
                  _buildDropdownButton(
                    n,
                    (int newN) { setState(() {n = newN;}); },
                    ns, NstoText),
                  Text(" 枚 "),
                  _buildDropdownButton(
                    condType,
                    (CondType newT) { setState(() {condType = newT;}); },
                    CondTypes,
                    CondTypeToName),
                  Text(" 所持"),
                ])
            )
            ,
            FlatButton(
              onPressed: () {
                Navigator.pop(context, Filter(koma, n, condType, condTarget));
              },
              child: Text(
                "Apply",
              ),
            ),
        ]));
  }
}
