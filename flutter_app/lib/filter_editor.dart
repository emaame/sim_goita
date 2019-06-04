import 'package:flutter/material.dart';
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

  final _font = const TextStyle(fontSize: 14.0);

  FilterEditorState() {
    koma = Koma.SHI;
    condType = CondType.EQUAL;
    condTarget = CondTarget.P1;
    n = 1;
  }

  _buildDropdownButton<_T>(value, onChanged, list, nameDict) {
    return DropdownButton<_T>(
      value: value,
      onChanged: onChanged,
      items: list.map<DropdownMenuItem<_T>>((_T value) {
        return DropdownMenuItem<_T>(
          value: value,
          child: Text(nameDict[value], style: _font),
        );
      }).toList(),
    );
  }

  maxN() {
    switch (koma) {
      case Koma.SHI:
        return 10;
      case Koma.GON:
      case Koma.UMA:
      case Koma.GIN:
      case Koma.KIN:
        return 4;
      case Koma.KAKU:
      case Koma.HI:
      case Koma.OU:
        return 2;
      default:
        return 4;
    }
  }

  @override
  Widget build(BuildContext context) {
    var ns = List.generate(maxN() + 1, (i) => i);
    return Scaffold(
        appBar: AppBar(
          title: Text('フィルタの編集'),
        ),
        body: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Row(children: [
            /* ここで無名関数を作らないと不自然なエラーが出ることがある */
            Padding(
              padding: EdgeInsets.all(8.0),
              child: _buildDropdownButton(condTarget, (newT) {
                setState(() {
                  condTarget = newT;
                });
              }, CondTargets, CondTargetToName),
            ),
            Text("が"),
            Padding(
                padding: EdgeInsets.all(8.0),
                child: _buildDropdownButton(koma, (newK) {
                  setState(() {
                    koma = newK;
                    n = min(n ?? 0, maxN());
                  });
                }, Komas, KomaToName)),
            Text("を"),
            Padding(
                padding: EdgeInsets.all(8.0),
                child: _buildDropdownButton(n, (newN) {
                  setState(() {
                    n = newN;
                  });
                }, ns, NstoText)),
            Text("枚"),
            Padding(
                padding: EdgeInsets.all(8.0),
                child: _buildDropdownButton(condType, (newT) {
                  setState(() {
                    condType = newT;
                  });
                }, CondTypes, CondTypeToName)),
            Text("所持"),
          ]),
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
