class Quiz {
  final String question;
  final List<String> options;
  final String correctAnswer;

  Quiz({
    required this.question,
    required this.options,
    required this.correctAnswer,
  });

  factory Quiz.fromJson(Map<String, dynamic> json) {
    return Quiz(
      question: json['question'],
      options: List<String>.from(json['options']),
      correctAnswer: json['correctAnswer'],
    );
  }
}
