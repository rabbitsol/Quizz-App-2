class Question {
  String userId;
  String questionId;
  String title;
  String description;
  String question;
  List<String> options;
  int correctOptionIndex;

  Question({
    required this.userId,
    required this.questionId,
    required this.title,
    required this.description,
    required this.question,
    required this.options,
    required this.correctOptionIndex,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'questionId': questionId,
      'title': title,
      'description': description,
      'question': question,
      'options': options,
      'correctOptionIndex': correctOptionIndex,
    };
  }
}
