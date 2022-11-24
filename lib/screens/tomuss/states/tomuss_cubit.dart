import 'package:dartus/tomuss.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oloid2/core/cache_service.dart';
import 'package:oloid2/screens/tomuss/tomuss_export.dart';

part 'tomuss_state.dart';

class TomussCubit extends Cubit<TomussState> {
  TomussCubit() : super(TomussState(status: TomussStatus.initial));

  Future<void> load({required Dartus dartus, bool cache = true}) async {
    emit(TomussState(status: TomussStatus.loading));
    List<SchoolSubjectModel> teachingUnits = [];
    if (cache) {
      compute((_) async {
        if (await CacheService.exist<SchoolSubjectModelWrapper>()) {
          teachingUnits = (await CacheService.get<SchoolSubjectModelWrapper>())!
              .teachingUnitModels;
          emit(TomussState(
              status: TomussStatus.cacheReady, teachingUnits: teachingUnits));
        }
      }, null);
    }
    try {
      teachingUnits = await GradesLogic.getGrades(dartus: dartus);
    } catch (e) {
      if (kDebugMode) {
        print("Error while loading grades: $e");
      }
      emit(TomussState(status: TomussStatus.error));
      return;
    }
    CacheService.set<SchoolSubjectModelWrapper>(
        SchoolSubjectModelWrapper(teachingUnits));
    emit(TomussState(status: TomussStatus.ready, teachingUnits: teachingUnits));
  }
}
