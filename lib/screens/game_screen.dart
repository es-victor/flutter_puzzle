import 'package:flutter/material.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({Key? key}) : super(key: key);

  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  double maxSize = 0.0;
  int n = 3;
  List<Offset> _rawOffsetTiles = [];
  @override
  initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    setState(() {
      maxSize = MediaQuery.of(context).size.shortestSide * 0.9;
      int width = maxSize ~/ n;
      maxSize = width * n.toDouble();
    });
    newGame();
    super.didChangeDependencies();
  }

  late Offset initialGapeOffset;
  ValueNotifier<List<Offset>> _offsetTiles = ValueNotifier([]);
  List<Offset> _referenceOffsetTiles = [];
  generateOffsetTile() {
    _offsetTiles.value.clear();
    for (int i = 0; i < n; i++) {
      for (int j = 0; j < n; j++) {
        _offsetTiles.value.add(Offset(j * maxSize / n, i * maxSize / n));
      }
    }
    _referenceOffsetTiles = [..._offsetTiles.value];
    initialGapeOffset = _offsetTiles.value.last;
    _offsetTiles.notifyListeners();
  }

  _checkIfSolvable() {
    int inversionCounts = 0;
    int blankTileIndex = 0;
    List<int> tileValues = [];
    _referenceOffsetTiles.forEach((offset) {
      tileValues.add(_rawOffsetTiles.indexOf(offset));
    });
    blankTileIndex = tileValues.indexOf(n * n - 1);
    for (int i = 0; i < tileValues.length; i++) {
      for (int j = i + 1; j < tileValues.length; j++) {
        if (tileValues[i] > tileValues[j] &&
            (tileValues[i] < tileValues.length - 1)) {
          inversionCounts++;
        }
      }
    }

    if (n.isEven) {
      int blankRow = ((n * n - 1 - blankTileIndex) * n / (n * n - 1)).ceil();
      if ((blankRow.isEven && inversionCounts.isEven) ||
          (blankRow.isOdd && inversionCounts.isOdd)) {
        newGame();
      }
    } else {
      if (inversionCounts.isOdd) {
        newGame();
      }
    }
  }

  newGame() {
    generateOffsetTile();
    _offsetTiles.value.shuffle();
    initialGapeOffset = _offsetTiles.value[_offsetTiles.value.length - 1];
    _rawOffsetTiles = _offsetTiles.value;
    _offsetTiles.notifyListeners();
    _checkIfSolvable();
  }

  _updateOffsetTiles({required int index}) {
    /// Check if tile can move, the move

    Offset down = _offsetTiles.value[index] + Offset(0, maxSize / n);
    Offset up = _offsetTiles.value[index] - Offset(0, maxSize / n);
    Offset left = _offsetTiles.value[index] - Offset(maxSize / n, 0);
    Offset right = _offsetTiles.value[index] + Offset(maxSize / n, 0);
    if (down == initialGapeOffset) {
      initialGapeOffset = _offsetTiles.value[index];
      _offsetTiles.value[index] = down;
    } else if (up == initialGapeOffset) {
      initialGapeOffset = _offsetTiles.value[index];
      _offsetTiles.value[index] = up;
    } else if (left == initialGapeOffset) {
      initialGapeOffset = _offsetTiles.value[index];
      _offsetTiles.value[index] = left;
    } else if (right == initialGapeOffset) {
      initialGapeOffset = _offsetTiles.value[index];
      _offsetTiles.value[index] = right;
    } else {
      return;
    }
    _offsetTiles.notifyListeners();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text("Puzzle Game"),
        ),
        body: Column(
          children: [
            Expanded(
              child: Center(
                child: SizedBox(
                  width: maxSize,
                  height: maxSize,
                  child: Stack(
                    children: [
                      Container(
                        color: Colors.white,
                      ),
                      ValueListenableBuilder(
                        builder: (context, List<Offset> offsetTiles, _) {
                          return Stack(
                            children: offsetTiles.isEmpty
                                ? [
                                    SizedBox(),
                                  ]
                                : List.generate(
                                    n * n - 1,
                                    (i) => PuzzleTile(
                                      key: Key("$i"),
                                      index: i,
                                      width: maxSize / n,
                                      offset: offsetTiles[i],
                                      onTap: () {
                                        _updateOffsetTiles(index: i);
                                      },
                                    ),
                                  ),
                          );
                        },
                        valueListenable: _offsetTiles,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Wrap(
              children: [
                TextButton(
                  onPressed: () {
                    generateOffsetTile();
                  },
                  child: Text("Solve"),
                ),
                TextButton(
                  onPressed: () {
                    newGame();
                  },
                  child: Text("New game"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class PuzzleTile extends StatefulWidget {
  final int index;
  final double width;
  final Offset offset;
  final VoidCallback onTap;
  const PuzzleTile({
    Key? key,
    required this.index,
    required this.width,
    required this.offset,
    required this.onTap,
  }) : super(key: key);

  @override
  _PuzzleTileState createState() => _PuzzleTileState();
}

class _PuzzleTileState extends State<PuzzleTile> {
  @override
  Widget build(BuildContext context) {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 300),
      left: widget.offset.dx,
      top: widget.offset.dy,
      width: widget.width,
      height: widget.width,
      child: Padding(
        padding: const EdgeInsets.all(1.0),
        child: GestureDetector(
          onTap: widget.onTap,
          child: Container(
            width: widget.width,
            height: widget.width,
            decoration: BoxDecoration(
              color: Colors.blue.shade700,
              borderRadius: BorderRadius.circular(6),
            ),
            alignment: Alignment.center,
            child: Text(
              "${widget.index}",
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
