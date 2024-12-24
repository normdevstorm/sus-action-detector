part of '../app.dart';

extension AiAnalysisStatusEnumExt on String {
  AiAnalysisStatusEnum toAiAnalysisStatusEnum() {
    switch (this) {
      case 'SAFE':
        return AiAnalysisStatusEnum.safe;
      case 'DUBIOUS':
        return AiAnalysisStatusEnum.dubious;
      case 'DANGEROUS':
        return AiAnalysisStatusEnum.dangerous;
      default:
        return AiAnalysisStatusEnum.safe;
    }
  }
}