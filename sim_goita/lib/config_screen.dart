import 'package:flutter_web/material.dart';
import 'package:flutter_web/services.dart'; /* TextInputFormatter */
import 'storage.dart';

class ConfigScreen extends StatefulWidget {
  @override
  ConfigScreenState createState() => ConfigScreenState();
}

class Config {
  int trials = DEFAULT_CONFIG[KEY_TRIALS];
  Config(int newTrials) {
    trials = newTrials;
  }
}

class ConfigScreenState extends State<ConfigScreen> {
  int _trials;
  final trialsController = TextEditingController();

  ConfigScreenState() {
    _trials = Storage.getInt(KEY_TRIALS);
    trialsController.text = _trials.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('設定'),
        ),
        body: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: EdgeInsets.all(20.0),
                child:
                    // How to create number input field in Flutter?
                    // @ref https://stackoverflow.com/questions/49577781/how-to-create-number-input-field-in-flutter
                    TextField(
                      keyboardType: TextInputType.number,
                      inputFormatters: <TextInputFormatter>[
                        WhitelistingTextInputFormatter.digitsOnly
                      ],
                      controller: trialsController,
                      decoration: InputDecoration(
                          labelText: "試行回数", hintText: "試行回数（100万位を推奨）"
                      ),
                    ),
              ),
              FlatButton(
                onPressed: () {
                  final value = int.tryParse(trialsController.text) ?? DEFAULT_CONFIG[KEY_TRIALS];
                  Storage.setInt(KEY_TRIALS, value);
                  Navigator.pop(context, Config(value));
                },
                child: Text(
                  "Apply",
                ),
              ),
            ]));
  }
}
