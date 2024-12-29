part of '../app.dart';

extension AiAnalysisStatusEnumExt on String {
  WarningLevelEnum toAiAnalysisStatusEnum() {
    switch (this) {
      case 'SAFE':
        return WarningLevelEnum.safe;
      case 'DUBIOUS':
        return WarningLevelEnum.dubious;
      case 'DANGEROUS':
        return WarningLevelEnum.dangerous;
      default:
        return WarningLevelEnum.safe;
    }
  }
}
