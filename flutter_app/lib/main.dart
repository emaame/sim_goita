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

class FilterListView extends StatefulWidget {
  @override
  FilterListViewState createState() => FilterListViewState();
}
class FilterListViewState extends State<FilterListView> {
  final _filters = <Filter>[];
  final _biggerFont = const TextStyle(fontSize: 18.0);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemBuilder: (context, i) {
          if (i.isOdd) return Divider();

          final index = i ~/ 2;
          return _buildRow(_filters[index]);
        });
  }

  Widget _buildRow(Filter filter) {
    return ListTile(
      title: Text(
        filter.toString(),
        style: _biggerFont,
      ),
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

  Widget buildListView(BuildContext context) {
    return ListView.builder(
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      padding: const EdgeInsets.all(16.0),
      itemBuilder: (context, i) {
        if (i.isOdd) return Divider();

        final index = i ~/ 2;
        if (_filters.length <= index) {
          return null;
        }
        return ListTile(
          title: Text(
            _filters[index].toString(),
            style: _biggerFont,
          ),
        );
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('Goita Simulator')),
        body: Column(children: [
          ...List.generate(4, (idx) { /* ... は Dart 2.3 で導入された List を展開する記法 */
              return getGoitaHand(idx);
          }),
          new Expanded(
            child: buildListView(context)
          ),
          FlatButton(
            onPressed: () async {
              final result = await Navigator.pushNamed(
                context,
                FilterEditor.routeName
              );
              setState(() {
                _filters.add(result as Filter);
              });
            },
            child: Text(
              "Add Filter",
            ),
          ),
          FlatButton(
            onPressed: () {
              setState(() {
                game = Game();
              });
            },
            child: Text(
              "Reset",
            ),
          )
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
