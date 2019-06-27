library goita;

enum Koma {
  BLANK,
  SHI,
  GON,
  UMA,
  GIN,
  KIN,
  HI,
  KAKU,
  OU,
  GYOKU,
  BACK,
  QUESTION
}

const KomaToName = {
  Koma.BLANK: "　",
  Koma.SHI: "し",
  Koma.GON: "香",
  Koma.UMA: "馬",
  Koma.GIN: "銀",
  Koma.KIN: "金",
  Koma.HI: "飛",
  Koma.KAKU: "角",
  Koma.OU: "王",
  Koma.GYOKU: "玉",
  Koma.BACK: "▲",
  Koma.QUESTION: "？",
};

String komalistToString(komas) {
  return komas.map((koma) {
    return KomaToName[koma];
  }).join(",");
}

final initYama = List.filled(10, Koma.SHI) +
    List.filled(4, Koma.GON) +
    List.filled(4, Koma.UMA) +
    List.filled(4, Koma.GIN) +
    List.filled(4, Koma.KIN) +
    List.filled(2, Koma.HI) +
    List.filled(2, Koma.KAKU) +
    List.filled(2, Koma.OU);

class Game {
  List<Koma> yama;
  Game() {
    yama = List.from(initYama);
    yama.shuffle(); // destructive
  }
  Game.yama(this.yama);

  @override
  String toString() {
    return komalistToString(yama);
  }
}

enum CondType { LESS, LESS_THAN, EQUAL, MORE_THAN, MORE }
enum CondTarget { P1, P2, P3, P4, PAIR_FRIEND, PAIR_ENEMY, WHOLE }

const CondTypeToName = {
  CondType.LESS: "未満",
  CondType.LESS_THAN: "以下",
  CondType.EQUAL: "に等しく",
  CondType.MORE_THAN: "以上",
  CondType.MORE: "より多く",
};
const CondTargetToName = {
  CondTarget.P1: "自分",
  CondTarget.P2: "下家",
  CondTarget.P3: "相方",
  CondTarget.P4: "上家",
  CondTarget.PAIR_FRIEND: "味方ペア",
  CondTarget.PAIR_ENEMY: "敵ペア",
  CondTarget.WHOLE: "全体",
};

typedef CondTypeFunc CondTypeFuncGenerator(int _n);
typedef bool CondTypeFunc(int n);
CondTypeFunc genLess(_n) {
  return (n) => n < _n;
}

CondTypeFunc genLessThan(_n) {
  return (n) => n <= _n;
}

CondTypeFunc genEqual(_n) {
  return (n) => n == _n;
}

CondTypeFunc genMoreThan(_n) {
  return (n) => n >= _n;
}

CondTypeFunc genMore(_n) {
  return (n) => n > _n;
}

const Map<CondType, CondTypeFuncGenerator> CondTypeFuncGenerators = {
  CondType.LESS: genLess,
  CondType.LESS_THAN: genLessThan,
  CondType.EQUAL: genEqual,
  CondType.MORE_THAN: genMoreThan,
  CondType.MORE: genMore,
};

typedef List<Koma> CondTargetFunc(Game game);
List<Koma> getP1(Game game) {
  return game.yama.sublist(0, 8);
}

List<Koma> getP2(Game game) {
  return game.yama.sublist(8, 16);
}

List<Koma> getP3(Game game) {
  return game.yama.sublist(16, 24);
}

List<Koma> getP4(Game game) {
  return game.yama.sublist(24, 32);
}

List<Koma> getPAIRFRIEND(Game game) {
  return game.yama.sublist(0, 8) + game.yama.sublist(16, 24);
}

List<Koma> getPAIRENEMY(Game game) {
  return game.yama.sublist(8, 16) + game.yama.sublist(24, 32);
}

List<Koma> getWHOLE(Game game) {
  return game.yama;
}

const Map<CondTarget, CondTargetFunc> CondTargetFuncs = {
  CondTarget.P1: getP1,
  CondTarget.P2: getP2,
  CondTarget.P3: getP3,
  CondTarget.P4: getP4,
  CondTarget.PAIR_FRIEND: getPAIRFRIEND,
  CondTarget.PAIR_ENEMY: getPAIRENEMY,
  CondTarget.WHOLE: getWHOLE
};
typedef bool TestFunction(Game game);

class Filter {
  Koma _koma;
  int _n;
  CondType _type;
  CondTarget _target;
  TestFunction _testFunc;

  Filter(koma, int n, CondType type, CondTarget target) {
    _koma = koma;
    _n = n;
    _type = type;
    _target = target;

    _testFunc = generateTestFunction();
  }

  Filter clone() {
    return Filter(_koma, _n, _type, _target);
  }
  Map<String, dynamic> toJson() => {
    'koma': _koma.index,
    'n': _n,
    'type': _type.index,
    'target': _target.index,
  };

  Koma get koma {
    return _koma;
  }

  int get n {
    return _n;
  }

  CondType get type {
    return _type;
  }

  CondTarget get target {
    return _target;
  }

  TestFunction get testFunc {
    return _testFunc;
  }

  generateTestFunction() {
    var getKomaListFunc = CondTargetFuncs[_target];
    var compareFunc = CondTypeFuncGenerators[_type](_n);
    return (Game game) {
      final komaList = getKomaListFunc(game);
      final int n =
          komaList.fold(0, (prev, koma) => prev + ((koma == _koma) ? 1 : 0));
      return compareFunc(n);
    };
  }

  @override
  String toString() {
    var buf = new StringBuffer();
    buf.write(CondTargetToName[_target]);
    buf.write("が'");
    buf.write(KomaToName[_koma]);
    buf.write("'を");
    buf.write(_n.toString());
    buf.write("枚");
    buf.write(CondTypeToName[_type]);
    buf.write("所持");
    return buf.toString();
  }
}
