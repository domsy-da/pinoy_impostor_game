  class WordModel {
  final int? id;
  final String word;
  final String hint;

  WordModel({this.id, required this.word, required this.hint});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'word': word,
      'hint': hint,
    };
  }

  factory WordModel.fromMap(Map<String, dynamic> map) {
    return WordModel(
      id: map['id'],
      word: map['word'],
      hint: map['hint'],
    );
  }
}