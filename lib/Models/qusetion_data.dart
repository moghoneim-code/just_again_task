import 'package:cloud_firestore/cloud_firestore.dart';

class QuestionModel {
  final String correctAnswer;
  final String question;
  final List<String> answers;
  final String exam_id;

  QuestionModel({
    required this.correctAnswer,
    required this.exam_id,
    required this.answers,
    required this.question,
  });

  factory QuestionModel.empty() {
    return QuestionModel(
        correctAnswer: "___correct_answer___", answers: [], exam_id: 'exam_id', question: '__question__');
  }

  factory QuestionModel.fromSnapshot(DocumentSnapshot snapshot) {
    final Map<String, dynamic> _data = snapshot.data() as Map<String, dynamic>;
    return QuestionModel(
      correctAnswer: _data['correct_answer'],
      exam_id: _data['exam_id'],
      question: _data['question'],
      answers: (_data['answers'] as List).map((e) => e.toString()).toList(),
    );
  }
}
