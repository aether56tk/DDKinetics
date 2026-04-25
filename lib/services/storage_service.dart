import 'package:hive_flutter/hive_flutter.dart';
import '../models/models.dart';

class StorageService {
  static const _boxName = 'ddkinetics_assessments_v3';
  late Box<AssessmentModel> _box;

  Future<void> init() async {
    await Hive.initFlutter();
    if (!Hive.isAdapterRegistered(0)) Hive.registerAdapter(TestTypeAdapter());
    if (!Hive.isAdapterRegistered(1)) Hive.registerAdapter(PatientTypeAdapter());
    if (!Hive.isAdapterRegistered(2)) Hive.registerAdapter(InputModeAdapter());
    if (!Hive.isAdapterRegistered(3)) Hive.registerAdapter(DDKResultAdapter());
    if (!Hive.isAdapterRegistered(4)) Hive.registerAdapter(AssessmentModelAdapter());
    _box = await Hive.openBox<AssessmentModel>(_boxName);
  }

  Future<void> save(AssessmentModel a) => _box.put(a.id, a);

  List<AssessmentModel> getAll() {
    final list = _box.values.toList();
    list.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return list;
  }

  Future<void> delete(String id) => _box.delete(id);

  int get count => _box.length;
}
