import 'package:flutter/material.dart';
import 'goita.dart';
import 'filter_editor.dart';
import 'screens.dart';

void main() => runApp(MyApp());

class MainScreen extends MainScreenBase {
  @override
  Widget build(BuildContext context) {
    return RandomGoita();
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "ごいたシミュレータ",
      initialRoute: MainScreenBase.routeName,
      routes: {
        MainScreenBase.routeName: (context) => MainScreen(),
        FilterEditorBase.routeName: (context) => FilterEditor(),
      },
    );
  }
}

class RandomGoita extends StatefulWidget {
  @override
  RandomGoitaState createState() => RandomGoitaState();
}

class RandomGoitaState extends State<RandomGoita> {
  final _biggerFont = const TextStyle(fontSize: 18.0);

  var game = Game();
  List<Filter> _filters = [];

  GoitaHand getGoitaHand(idx) {
    var hand = game.yama.skip(idx * 8).take(8).toList();
    return GoitaHand(hand: hand);
  }

  Widget buildListView() {
    var count = _filters.length + 1;
    var list = List.from(_filters);
    list.add(null);
    return ListView.separated(
      padding: const EdgeInsets.all(16.0),
      itemCount: count,
      itemBuilder: (context, i) {
        var text = "";
        if (list[i] is Filter) {
          text = list[i].toString();
        }
        return ListTile(
          title: Text(
            text,
            style: _biggerFont,
          ),
          trailing: FloatingActionButton(
              heroTag: "addFilterBtn" + i.toString(), /* 個別のidが必要 */
              onPressed: () async {
                appendFilter(i);
              },
              child: Column(children: [Icon(Icons.add), Text("条件")])),
        );
      },
      separatorBuilder: (BuildContext context, int index) => const Divider(),
    );
  }

  appendFilter(index) async {
    final result = await Navigator.pushNamed(context, FilterEditor.routeName);
    Filter filter = result as Filter;
    setState(() {
      if (index < 0 || index >= _filters.length) {
        _filters.add(filter);
      } else {
        _filters.insert(index, filter);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('Goita Simulator')),
        body: Column(children: [
          ...List.generate(4, (idx) {
            /* ... は Dart 2.3 で導入された List を展開する記法 */
            return getGoitaHand(idx);
          }),
          new Expanded(child: buildListView()),
          /*
          FlatButton(
            onPressed: () async {
              appendFilter(-1);
            },
            child: Text(
              "Add Filter",
            ),
          ),
          */
          FlatButton(
            onPressed: () {
              setState(() {});
            },
            child: Text(
              "Simulate",
            ),
          ),
          /*
          FlatButton(
            onPressed: () {
              setState(() {
                game = Game();
              });
            },
            child: Text(
              "Reset",
            ),
          )*/
        ]));
  }
}

class GoitaHand extends StatefulWidget {
  GoitaHand({Key key, this.hand}) : super(key: key);
  final List hand;
  @override
  GoitaHandState createState() => GoitaHandState();
}

class GoitaHandState extends State<GoitaHand> {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text(komalistToString(widget.hand)));
  }
}
