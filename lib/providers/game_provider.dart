import 'dart:math';
import 'package:flutter/material.dart';
import '../models/word_model.dart';
import '../services/database_helper.dart';

class GameProvider with ChangeNotifier {
  int _playerCount = 4;
  int _dbWordCount = 0;
  WordModel? _currentSecret;
  int _impostorIndex = 0;
  int _currentPlayerIndex = 0;
  bool _hasViewedCard = false;

  int get playerCount => _playerCount;
  int get dbWordCount => _dbWordCount;
  int get currentPlayerIndex => _currentPlayerIndex;
  bool get hasViewedCard => _hasViewedCard;

  void incrementPlayer() {
    _playerCount++;
    notifyListeners();
  }

  void decrementPlayer() {
    if (_playerCount > 3) {
      _playerCount--;
      notifyListeners();
    }
  }

  Future<void> refreshDbWordCount() async {
    _dbWordCount = await DatabaseHelper.instance.getWordCount();
    notifyListeners();
  }

  Future<void> setupNewGame() async {
    _currentSecret = await DatabaseHelper.instance.getRandomWord();
    if (_currentSecret != null) {
      _impostorIndex = Random().nextInt(_playerCount);
    }
    _currentPlayerIndex = 0;
    _hasViewedCard = false;
    notifyListeners();
  }

  void markCardAsViewed() {
    _hasViewedCard = true;
    notifyListeners();
  }

  void advanceToNextPlayer() {
    _currentPlayerIndex++;
    _hasViewedCard = false;
    notifyListeners();
  }

  String getPlayerRoleString(int index) {
    if (_currentSecret == null) return "Loading...";
    if (index == _impostorIndex) {
      return "Youre the impostor hint:${_currentSecret!.hint}";
    }
    return _currentSecret!.word;
  }
}