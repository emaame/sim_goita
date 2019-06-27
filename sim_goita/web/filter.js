Array.prototype.shuffle = function () {
  for (let i = this.length - 1; i > 0; i--) {
    const j = Math.floor(Math.random() * (i + 1));
    const tmp = this[i];
    this[i] = this[j];
    this[j] = tmp;
  }
  return this;
}

const SHI = 1, GON = 2, UMA = 3;
const GIN = 4, KIN = 5;
const HI = 6, KAKU = 7;
const OU = 8;

const initYama = new Array(32);
initYama.fill(SHI, 0, 10);
initYama.fill(GON, 10, 14);
initYama.fill(UMA, 14, 18);
initYama.fill(GIN, 18, 22);
initYama.fill(KIN, 22, 26);
initYama.fill(HI, 26, 28);
initYama.fill(KAKU, 28, 30);
initYama.fill(OU, 30, 32);

function makeTestFunc(filters) {
  var code = "";
  for (var filter of filters) {
    code += "{";
    code += "const l = ";
    switch (filter["target"]) {
      case 0: code += "yama.slice( 0, 8);"; break;
      case 1: code += "yama.slice( 8,16);"; break;
      case 2: code += "yama.slice(16,24);"; break;
      case 3: code += "yama.slice(24,32);"; break;
      case 4: code += "yama.slice( 0, 8).concat(yama.slice(16,24));"; break;
      case 5: code += "yama.slice( 8,16).concat(yama.slice(24,32));"; break;
      case 6: code += "yama;"; break;
    }
    code += "var n=0, len=l.length; for(var i=0; i<len; ++i){ if (l[i]==" + filter["koma"] + ") {++n;} }";
    //code += "console.log(yama, l, n);";
    code += "if (!(";
    switch (filter["type"]) {
      case 0: code += "n< " + filter["n"]; break;
      case 1: code += "n<=" + filter["n"]; break;
      case 2: code += "n==" + filter["n"]; break;
      case 3: code += "n>=" + filter["n"]; break;
      case 4: code += "n> " + filter["n"]; break;
    }
    code += ")) { return false; }";
    code += "}";
  }
  code += "return true;";
  //console.log(code);
  return Function("yama", code);
}

self.addEventListener('message', function (e) {
  const param = JSON.parse(e.data);
  const trials = param.trials;
  const filters = param.filters;
  const testFunc = makeTestFunc(filters);
  const result = new Uint8Array(100 * 32);
  var passedCount = 0;
  var offset = 0;
  const yama = Array.from(initYama);
  for (var i = 0; i < trials; ++i) {
    yama.shuffle();
    if (testFunc(yama)) {
      ++passedCount;
      if (passedCount < 100) {
        for (var j = 0; j < 32; ++j) {
          result[offset + j] = yama[j];
        }
        offset += 32
      }
    }
  }
  self.postMessage({ passedCount: passedCount, samples: result.buffer }, [result.buffer]);
}, false);