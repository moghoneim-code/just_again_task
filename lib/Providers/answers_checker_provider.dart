import '../Models/qusetion_data.dart';

class AnswersCheckerProvider {
  List<QuestionModel> _questions = [];
  final List<AnswerModel> _answers = [];

  void initWithQuestions(List<QuestionModel> questions) {
    _questions = questions;
  }

  void answerQuestion(AnswerModel answer) {
    _answers.add(answer);
  }

  bool didAnswerAll() {
    return _answers.length == _questions.length;
  }

  FinalResult correctExam() {
    int correct = 0;
    for (final answer in _answers) {
      if (answer.isCorrect()) {
        correct++;
      }
    }
    return FinalResult(
      correctAnswers: correct,
      totalQuestions: _questions.length,
    );
  }
}

class AnswerModel {
  final String questionId;
  final String answer;
  final String correctAnswer;

  const AnswerModel({
    required this.questionId,
    required this.answer,
    required this.correctAnswer,
  });

  bool isCorrect() {
    return answer == correctAnswer;
  }

  @override
  String toString() => 'AnswerModel(questionId: $questionId, answer: $answer, correctAnswer: $correctAnswer)';
}

class FinalResult {
  final int correctAnswers;
  final int totalQuestions;

  const FinalResult({
    required this.correctAnswers,
    required this.totalQuestions,
  });

  @override
  String toString() => 'FinalResult(correctAnswers: $correctAnswers, totalQuestions: $totalQuestions)';
}
