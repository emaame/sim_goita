library goita;

enum Koma {
  BLANK, SHI, GON, UMA, GIN, KIN, HI, KAKU, OU, GYOKU, BACK, QUESTION
}

final komaToName = {
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
  return komas.map((koma) { return komaToName[koma]; }).join(",");
}

final initYama = List.filled(10, Koma.SHI) +
                 List.filled( 4, Koma.GON) +
                 List.filled( 4, Koma.UMA) +
                 List.filled( 4, Koma.GIN) +
                 List.filled( 4, Koma.KIN) +
                 List.filled( 2, Koma.HI) +
                 List.filled( 2, Koma.KAKU) +
                 List.filled( 1, Koma.OU)+
                 List.filled( 1, Koma.GYOKU);

class Game {
  List yama;
  Game() {
    yama = List.from(initYama);
    yama.shuffle(); // destructive
  }

  @override
  String toString() {
    return komalistToString(yama);
  }
}