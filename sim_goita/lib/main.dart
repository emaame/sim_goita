import 'dart:html';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:async';
import 'dart:math';
import 'package:flutter_web/material.dart';
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
  int _passedCount = 0;
  var _samples = List<Game>(0);
  int _trials = 1000000;
  int _workers = 0;
  String _resultText = "";
  int _index = 0;
  bool _simulating = false;

  RandomGoitaState() {
    _trials = Storage.getInt(KEY_TRIALS);
    _workers = Storage.getInt(KEY_WORKERS);
  }

  Game get sample => (_index == null)
      ? null
      : _index >= _samples.length ? null : _samples[_index];

  ListTile _buildListTile(Filter item, int index) {
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
            onPressed: () {
              appendFilter(index);
            },
            child:
                Column(children: [Icon(Icons.add), Text("条件", style: _font)])));
  }

  Widget buildListView() {
    var count = _filters.length + 1;
    var list = List<Filter>.from(_filters);
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

  Future<void> appendFilter(int index) async {
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
    if (_passedCount <= 0) return true;
    return false;
  }

  bool shouldNextDisabled() {
    if (_passedCount <= 0) return true;
    if (_index >= _passedCount - 1) return true;
    return false;
  }

  Game convertInt8ListToGame(List<int> sublist) {
    final List<Koma> yama = List<Koma>(32);
    for (int offset = 0; offset < 32; offset += 8) {
      final hand = sublist.sublist(offset, offset + 8);
      hand.sort();
      for (int i = 0; i < 8; ++i) {
        yama[offset + i] = Koma.values[hand[i]];
      }
    }
    return Game.yama(yama);
  }

  Future<dynamic> invokeWorker(int trials, int samplesPerWorker) {
    var completer = new Completer<dynamic>();

    final w = Worker("filter.js");
    w.onMessage.listen((msg) {
      completer.complete(msg.data);
    });
    w.postMessage(jsonEncode(
        {"trials": trials, "filters": _filters, "samples": samplesPerWorker}));

    return completer.future;
  }

  void Function() simulateionPressed() {
    return () {
      setState(() {
        _simulating = true;
        _passedCount = 0;
      });
      // WebWorker Version
      final nowWW = DateTime.now();

      int restTrials = _trials;
      int restSamples = 100;
      int trialsPerWorker = restTrials ~/ _workers;
      int samplesPerWorker = restSamples ~/ _workers;
      var workers = List<Future<dynamic>>(_workers);
      for (int i = 0; i < _workers; ++i) {
        final trials = (i == _workers - 1) ? restTrials : trialsPerWorker;
        final samples = (i == _workers - 1) ? restSamples : samplesPerWorker;
        restTrials -= trials;
        restSamples -= samples;
        workers[i] = invokeWorker(trials, samples);
      }

      Future.wait<dynamic>(workers).then((results) {
        setState(() {
          _passedCount = 0;
          _samples = [];
          for (int i = 0; i < _workers; ++i) {
            final dynamic data = results[i];
            final passedCount = data["passedCount"] as int;
            _passedCount += passedCount;

            final lst = (data["samples"] as ByteBuffer).asInt8List();
            final int len = min(lst.length, passedCount * 32);
            for (int offset = 0; offset < len; offset += 32) {
              final Game game =
                  convertInt8ListToGame(lst.sublist(offset, offset + 32));
              _samples.add(game);
            }
          }
          final timeWW = DateTime.now().difference(nowWW);
          final percent = 100.0 * _passedCount / _trials;
          _index = 0;
          _resultText =
              "${percent.toStringAsFixed(4)}% -- ${_passedCount} passed / $_trials tried (${timeWW.inMilliseconds / 1000} sec.)";
        });
      });
    };
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
          MaterialButton(
              minWidth: 10.0,
              /* minimize button */
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              onPressed: () async {
                window.location.replace('https://sim-goita-old.web.app/');
              },
              child: Column(children: [
                Icon(Icons.arrow_back),
                Text("旧版", style: _font)
              ])),
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
                _workers = conf.workers;
              });
            },
          ),
        ]),
        body: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Expanded(child: buildListView()),
          FlatButton(
            onPressed: simulateionPressed(),
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
                      children: (sample != null)
                          ? sample.yama.map((koma) => komaImages[koma]).toList()
                          : List.generate(32, (i) => komaImages[Koma.BLANK]))),
              SizedBox(
                  width: 30.0,
                  child: IconButton(
                    onPressed: shouldNextDisabled()
                        ? null
                        : () {
                            setState(() {
                              _index++;
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
  final List<Koma> hand;
  @override
  GoitaHandState createState() => GoitaHandState();
}

class GoitaHandState extends State<GoitaHand> {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text(komalistToString(widget.hand)));
  }
}
