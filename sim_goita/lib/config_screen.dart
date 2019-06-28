import 'package:flutter_web/material.dart';
import 'package:flutter_web/services.dart'; /* TextInputFormatter */
import 'storage.dart';

class ConfigScreen extends StatefulWidget {
  @override
  ConfigScreenState createState() => ConfigScreenState();
}

class Config {
  final int trials;
  final int workers;
  Config(this.trials, this.workers);
}

class ConfigScreenState extends State<ConfigScreen> {
  int _trials;
  final TextEditingController trialsController = TextEditingController();
  int _workers;
  final TextEditingController workersController = TextEditingController();

  ConfigScreenState() {
    _trials = Storage.getInt(KEY_TRIALS);
    _workers = Storage.getInt(KEY_WORKERS);
    trialsController.text = _trials.toString();
    workersController.text = _workers.toString();
  }

  TextField createNumericTextField(
      TextEditingController controller, String labelText, String hintText) {
    return TextField(
      keyboardType: TextInputType.number,
      inputFormatters: <TextInputFormatter>[
        WhitelistingTextInputFormatter.digitsOnly
      ],
      controller: controller,
      decoration: InputDecoration(labelText: labelText, hintText: hintText),
    );
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
                  child: createNumericTextField(
                      trialsController, "試行回数", "試行回数（100万位を推奨）")),
              Padding(
                  padding: EdgeInsets.all(20.0),
                  child: createNumericTextField(
                      workersController, "並列実行数", "並列に動かすスレッド数（CPUの論理コア数を推奨）")),
              FlatButton(
                onPressed: () {
                  final trials = int.tryParse(trialsController.text) ??
                      DEFAULT_CONFIG[KEY_TRIALS];
                  final rawWorkers = int.tryParse(workersController.text) ??
                      DEFAULT_CONFIG[KEY_WORKERS];
                  final workers = (rawWorkers <= 0) ? 1 : rawWorkers;
                  Storage.setInt(KEY_TRIALS, trials);
                  Storage.setInt(KEY_WORKERS, workers);
                  Navigator.pop(context, Config(trials, workers));
                },
                child: Text(
                  "Apply",
                ),
              ),
            ]));
  }
}
