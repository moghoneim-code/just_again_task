// ignore_for_file: constant_identifier_names

import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Models/exam_data.dart';

const int EXAMS_PER_PAGE = 1000;

class ExamListProvider extends ChangeNotifier {
  ///retuns a provider instance of the class
  static ExamListProvider get(BuildContext context) =>
      context.read<ExamListProvider>();

  List<ExamData>? _examsList;
  DocumentSnapshot? _lastDocument;
  bool _readyToFetchNewData = true;

  // String get _uid => FirebaseAuth.instance.currentUser!.uid;

  List<ExamData>? get examsList => _examsList;

  ///describes the current pagination state, whether or not the ui should display a widget loading indicator.

  bool get nextPage => _lastDocument != null;

  ///Fetches the  exams List from [Firebase Firestore].
  ///
  ///[newData]: use with `false` to disable loading indication, for example when refreshing.
  ///

  Future<void> loadExams({bool newData = true}) async {
    _examsList = null;
    if (newData) notifyListeners();
    var data = await _getExams();
    _examsList =
        data.map((e) => ExamData.fromSnapshot(e)).toList(growable: true);
    print(_examsList!.first.examTitle);

    _lastDocument = data.last;
    notifyListeners();
  }

  Future<void> loadMoreExams() async {
    if (_readyToFetchNewData) {
      _readyToFetchNewData = false;
      log("#Fetching more data".toUpperCase());
    } else {
      return;
    }
    assert(_examsList!.isNotEmpty, "you should load exams first");

    final data = await _getExams(from: _lastDocument);
    //maps docs to exams
    var examsList = data.map((e) => ExamData.fromSnapshot(e)).toList();

    ///if the exams list is almost empty or not.
    ///
    if (examsList.isEmpty) {
      _lastDocument = null;
    } else {
      _examsList = (_examsList! + examsList);
      _lastDocument = data.last;
    }
    _readyToFetchNewData = _lastDocument?.id != null;
    notifyListeners();
  }

  Future<List<DocumentSnapshot>> _getExams({DocumentSnapshot? from}) async {
    final examRequest = FirebaseFirestore.instance.collection("exams");
    Query query = examRequest.limit(EXAMS_PER_PAGE);

    if (from != null) {
      query = query.startAfterDocument(from);
    }

    final rawData = await query.get();

    return rawData.docs.toList();
  }








}
