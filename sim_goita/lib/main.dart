import 'package:flutter_web/material.dart';
import 'package:flutter_web/foundation.dart'; /* compute */
import 'goita.dart';
import 'routes.dart';
import 'storage.dart';
import 'filter_editor.dart';
import 'config_screen.dart';

final komaImages = {
  Koma.SHI: Image.asset('images/fore_shi.png'),
  Koma.GON: Image.asset('images/fore_gon.png'),
  Koma.UMA: Image.asset('images/fore_uma.png'),
  Koma.GIN: Image.asset('images/fore_gin.png'),
  Koma.KIN: Image.asset('images/fore_kin.png'),
  Koma.KAKU: Image.asset('images/fore_kaku.png'),
  Koma.HI: Image.asset('images/fore_hi.png'),
  Koma.OU: Image.asset('images/fore_ou.png'),
  Koma.GYOKU: Image.asset('images/fore_dama.png'),
  Koma.BLANK: Image.asset('images/fore.png'),
  Koma.QUESTION: Image.asset('images/fore_hatena.png'),
  Koma.BACK: Image.asset('images/back.png'),
};

void main() async {
  await Storage.init();
  runApp(MyApp());
}

class ComputeParam {
  int trials;
  List<Filter> filters;
  ComputeParam(newTrials, newFilters) {
    trials = newTrials;
    filters = newFilters;
  }
}

Future<List<Game>> simulate(ComputeParam args) async {
  final trials = args.trials;
  final filters = args.filters;
  var iter = Iterable.generate(trials, (i) => Game());
  filters.forEach((filter) => iter = iter.where(filter.testFunc));
  return iter.toList();
}

class MainScreen extends StatelessWidget {
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
      initialRoute: Routes.main,
      routes: {
        Routes.main: (context) => MainScreen(),
        Routes.edit_filter: (context) => FilterEditor(),
        Routes.config: (context) => ConfigScreen(),
      },
    );
  }
}

class RandomGoita extends StatefulWidget {
  @override
  RandomGoitaState createState() => RandomGoitaState();
}

class RandomGoitaState extends State<RandomGoita> {
  final _font = const TextStyle(fontSize: 14.0);

  List<Filter> _filters = [];
  List<Game> _passed = [];
  int _trials = 1000000;
  String _resultText = "";
  Game _sample;
  int _index = 0;
  bool _simulating = false;

  RandomGoitaState() {
    _trials = Storage.getInt(KEY_TRIALS);
  }

  ListTile _buildListTile(item, index) {
    final text = (item is Filter) ? item.toString() : "";
    return ListTile(
        title: Text(
          text,
          style: _font,
        ),
        trailing: MaterialButton(
            minWidth: 10.0,
            /* minimize button */
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            onPressed: () async {
              appendFilter(index);
            },
            child:
                Column(children: [Icon(Icons.add), Text("条件", style: _font)])));
  }

  Widget buildListView() {
    var count = _filters.length + 1;
    var list = List.from(_filters);
    list.add(null);
    return ListView.separated(
        padding: const EdgeInsets.all(16.0),
        itemCount: count,
        separatorBuilder: (BuildContext context, int index) => const Divider(),
        itemBuilder: (context, index) {
          final item = list[index];
          final tile = _buildListTile(item, index);
          if (item is Filter) {
            return Dismissible(
                // Show a red background as the item is swiped away
                background: Container(color: Colors.red),
                key: Key(item.toString()),
                onDismissed: (direction) {
                  setState(() {
                    _filters.removeAt(index);
                  });
                },
                child: tile);
          } else {
            return tile;
          }
        });
  }

  appendFilter(index) async {
    final result = await Navigator.pushNamed(context, Routes.edit_filter);
    if (result == null) {
      return;
    }
    Filter filter = result as Filter;
    setState(() {
      if (index < 0 || index >= _filters.length) {
        _filters.add(filter);
      } else {
        _filters.insert(index, filter);
      }
    });
  }

  bool shouldPrevDisabled() {
    if (_index <= 0) return true;
    if (_passed.isEmpty) return true;
    return false;
  }

  bool shouldNextDisabled() {
    if (_passed.isEmpty) return true;
    if (_index >= _passed.length - 1) return true;
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final gridHeight = 200.0;
    final itemWidth = (size.width - 60.0) / 8.0;
    final itemHeight = gridHeight / 4.0;
    final gridAspectRatio = (itemWidth / itemHeight);
    return Scaffold(
        appBar: AppBar(title: Text('Goita Simulator'), actions: <Widget>[
          // action button
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () async {
              final result = await Navigator.pushNamed(context, Routes.config);
              if (result == null) {
                return;
              }
              Config conf = result as Config;
              if (conf == null) {
                return;
              }
              setState(() {
                _trials = conf.trials;
              });
            },
          ),
        ]),
        body: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Expanded(child: buildListView()),
          FlatButton(
            onPressed: () async {
              final now = DateTime.now();
              setState(() {
                _simulating = true;
              });
              final args = ComputeParam(
                  _trials, _filters.map((f) => f.clone()).toList());
              final results = await simulate(args);
              final time = DateTime.now().difference(now);
              setState(() {
                _simulating = false;
                _passed = results;
                _sample = _passed[0];

                final percent = 100.0 * _passed.length / _trials;
                _resultText =
                    "${percent.toStringAsFixed(4)}% -- ${_passed.length} passed / $_trials tried (${time.inSeconds} sec.)";
              });
            },
            child: Text(
              "Simulate",
            ),
          ),
          Center(child: Text(_resultText)),
          Row(
            children: <Widget>[
              SizedBox(
                  width: 30.0,
                  child: IconButton(
                    onPressed: shouldPrevDisabled()
                        ? null
                        : () {
                            setState(() {
                              _index--;
                              _sample = _passed[_index];
                            });
                          },
                    icon: Icon(Icons.arrow_left),
                  )),
              SizedBox(
                  width: size.width - 60,
                  height: gridHeight,
                  child: GridView.count(
                      shrinkWrap: true,
                      primary: false,
                      crossAxisSpacing: 10.0,
                      crossAxisCount: 8,
                      childAspectRatio: gridAspectRatio,
                      children: (_sample != null)
                          ? _sample.yama
                              .map((koma) => komaImages[koma])
                              .toList()
                          : List.generate(32, (i) => komaImages[Koma.BLANK]))),
              SizedBox(
                  width: 30.0,
                  child: IconButton(
                    onPressed: shouldNextDisabled()
                        ? null
                        : () {
                            setState(() {
                              _index++;
                              _sample = _passed[_index];
                            });
                          },
                    icon: Icon(Icons.arrow_right),
                  )),
            ],
          ),
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
