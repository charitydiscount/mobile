import 'package:charity_discount/models/meta.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MetaService {
  final _db = Firestore.instance;

  Future<TwoPerformantMeta> getTwoPerformantMeta() async {
    var twoPMeta = await _db.collection('meta').document('2performant').get();
    return TwoPerformantMeta.fromJson(twoPMeta.data);
  }

  Future<ProgramMeta> getProgramsMeta() async {
    var programsMeta = await _db.collection('meta').document('programs').get();
    if (programsMeta == null) {
      return ProgramMeta(count: 0, categories: []);
    }

    return ProgramMeta.fromJson(programsMeta.data);
  }
}

MetaService metaService = MetaService();
