import 'package:flutter_web/material.dart';
import 'goita.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Goita Simulator',
      home: RandomGoita(),
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

  GoitaHand getGoitaHand(idx) {
    var hand = game.yama.skip(idx * 8).take(8).toList();
    return GoitaHand(hand: hand);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('Goita Simulator')),
        body: Row(children: [
          Column(
            children: List.generate(4, (idx) {
              return getGoitaHand(idx);
            }),
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
    return Card(child: Text(komalistToString(widget.hand)));
  }
}
