import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'dart:collection';

HashMap<String, List> callouts = new HashMap();
HashMap<String, double> monkeys = new HashMap();

void main() {
  var path = "./input.txt";
  new File(path)
      .openRead()
      .transform(utf8.decoder)
      .transform(new LineSplitter())
      .forEach((l) => parseMonkey(l))
      .then((_) => part1())
      .then((_) => part2());
}

void part1() {
  print("Solution 1: " + evaluateMonkey("root").toInt().toString());
}

void part2() {
  // TODO: Remove assumptions

  double n = 0;
  monkeys.clear();
  monkeys["humn"] = n;
  var monkey1 = callouts["root"]![0];
  var monkey2 = callouts["root"]![2];
  double target = evaluateMonkey(monkey2);

  double humanvar = 0;
  double lower = 0;
  double upper = 0;
  n = 1;
  double guessNum = 0;
  while (guessNum > target || guessNum == 0) {
    n *= 2;
    monkeys.clear();
    monkeys["humn"] = n;
    guessNum = evaluateMonkey(monkey1);
    upper = n;
  }

  n = -1;
  guessNum = 0;
  while (guessNum < target) {
    n *= 2;
    monkeys.clear();
    monkeys["humn"] = n;
    guessNum = evaluateMonkey(monkey1);
    lower = n;
  }

  while (true) {
    n = ((upper + lower) / 2).floor() / 1;
    monkeys.clear();
    monkeys["humn"] = n;
    var evaluated = evaluateMonkey(monkey1);
    if (evaluated == target) {
      humanvar = n;
      break;
    } else if (evaluated > target) {
      lower = n;
    } else {
      upper = n;
    }
  }

  n = humanvar;
  monkeys.clear();
  monkeys["humn"] = n;
  double validate = evaluateMonkey(monkey1);

  print("Solution 2: " + humanvar.toInt().toString());
}

void parseMonkey(String monkey) {
  var parts = monkey.split(": ");
  if (double.tryParse(parts[1]) != null)
    callouts[parts[0]] = [double.parse(parts[1])];
  else
    callouts[parts[0]] = parts[1].split(" ");
}

double evaluateMonkey(String monkey) {
  if (monkeys.keys.contains(monkey)) return monkeys[monkey] ?? 0;
  double val = 0;
  if (callouts[monkey]?.length == 1) {
    val = callouts[monkey]![0];
  } else {
    var monkey1 = evaluateMonkey(callouts[monkey]![0]);
    var monkey2 = evaluateMonkey(callouts[monkey]![2]);
    switch (callouts[monkey]![1]) {
      case "-":
        val = monkey1 - monkey2;
        break;
      case "*":
        val = monkey1 * monkey2;
        break;
      case "/":
        val = monkey1 / monkey2;
        break;
      case "+":
      default:
        val = monkey1 + monkey2;
        break;
    }
    monkeys[monkey] = val;
  }
  return val;
}
