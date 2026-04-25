import 'package:flutter/foundation.dart';
import '../models/models.dart';
import '../services/storage_service.dart';

enum HistoryFilter { all, normal, borderline, dysarthria }

class HistoryProvider extends ChangeNotifier {
  HistoryProvider(this._store);
  final StorageService _store;

  HistoryFilter _filter = HistoryFilter.all;
  HistoryFilter get filter => _filter;

  List<AssessmentModel> get all => _store.getAll();
  int get totalCount => _store.count;

  List<AssessmentModel> get filtered {
    final src = all;
    switch (_filter) {
      case HistoryFilter.all:         return src;
      case HistoryFilter.normal:      return src.where((a) => a.result == DDKResult.normal).toList();
      case HistoryFilter.borderline:  return src.where((a) => a.result == DDKResult.borderline).toList();
      case HistoryFilter.dysarthria:  return src.where((a) => a.result == DDKResult.possibleDysarthria).toList();
    }
  }

  void setFilter(HistoryFilter f) { _filter = f; notifyListeners(); }

  Future<void> delete(String id) async {
    await _store.delete(id);
    notifyListeners();
  }

  void refresh() => notifyListeners();
}
