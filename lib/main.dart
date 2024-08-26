import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

class FallingGameScreen extends StatefulWidget {
  @override
  _FallingGameScreenState createState() => _FallingGameScreenState();
}
class _FallingGameScreenState extends State<FallingGameScreen> {
  static const int _columnCount = 10;  // Number of columns
  List<Offset> _objects = [];
  double _playerPosition = 0.0;
  double _objectSpeed = 3.0;  // Increase speed for more challenge
  int _score = 0;
  Timer? _gameTimer;
  Timer? _spawnTimer;
  late List<double> _columns;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeColumns();
      _startGame();
      _startSpawningObjects();
    });
  }

  void _initializeColumns() {
    // Calculate column positions based on screen width
    double columnWidth = MediaQuery.of(context).size.width / _columnCount;
    _columns = List.generate(_columnCount, (index) => columnWidth * index + (columnWidth / 2) - 25);
  }

  void _startGame() {
    _gameTimer = Timer.periodic(Duration(milliseconds: 16), (timer) {
      setState(() {
        _updateObjects();
        _checkCollisions();
      });
    });
  }

  void _startSpawningObjects() {
    // Reduce the spawn interval to increase the number of objects
    _spawnTimer = Timer.periodic(Duration(milliseconds: 500), (timer) {  // Spawning every 0.5 seconds
      setState(() {
        _spawnNewObject();
      });
    });
  }

  void _spawnNewObject() {
    final rng = Random();
    int columnIndex = rng.nextInt(_columns.length);  // Randomly select a column
    _objects.add(Offset(_columns[columnIndex], -50));
  }

  void _updateObjects() {
    for (int i = 0; i < _objects.length; i++) {
      _objects[i] = _objects[i] + Offset(0, _objectSpeed);

      // Remove object if it goes off screen
      if (_objects[i].dy > MediaQuery.of(context).size.height) {
        _objects.removeAt(i);
        i--;
      }
    }
  }

  void _checkCollisions() {
    for (int i = 0; i < _objects.length; i++) {
      final object = _objects[i];
      if ((object.dy + 50) > MediaQuery.of(context).size.height - 100 &&
          (object.dx + 50) > _playerPosition &&
          object.dx < (_playerPosition + 100)) {
        _score++;
        _objects.removeAt(i);
        i--;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Falling Object Game'),
      ),
      body: GestureDetector(
        onPanUpdate: (details) {
          setState(() {
            _playerPosition = max(
                0, min(MediaQuery.of(context).size.width - 100, details.globalPosition.dx - 50));
          });
        },
        child: Stack(
          children: [
            ..._objects.map((position) => Positioned(
              left: position.dx,
              top: position.dy,
              child: Container(
                width: 50,
                height: 50,
                color: Colors.red,
              ),
            )),
            Positioned(
              left: _playerPosition,
              bottom: 0,
              child: Container(
                width: 100,
                height: 20,
                color: Colors.blue,
              ),
            ),
            Positioned(
              top: 20,
              left: 20,
              child: Text(
                'Score: $_score',
                style: TextStyle(fontSize: 24),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _gameTimer?.cancel();
    _spawnTimer?.cancel();
    super.dispose();
  }
}