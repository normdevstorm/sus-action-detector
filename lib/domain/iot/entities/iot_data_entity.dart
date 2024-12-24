import '../../../app/app.dart';

class IotDataEntity {
  final bool doorStatus;
  final bool bellStatus;
  final AiAnalysisStatusEnum aiAnalysisStatus;

  IotDataEntity({
    required this.doorStatus,
    required this.bellStatus,
    required this.aiAnalysisStatus,
  });

  IotDataEntity copyWith({
    bool? doorStatus,
    bool? bellStatus,
    AiAnalysisStatusEnum? aiAnalysisStatus,
  }) {
    return IotDataEntity(
      doorStatus: doorStatus ?? this.doorStatus,
      bellStatus: bellStatus ?? this.bellStatus,
      aiAnalysisStatus: aiAnalysisStatus ?? this.aiAnalysisStatus,
    );
  }
}