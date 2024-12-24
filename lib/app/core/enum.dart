part of '../app.dart';

enum BlocStatus {
  @JsonValue('INITIAL')
  initial,
  @JsonValue('LOADING')
  loading,
  @JsonValue('LOADED')
  loaded,
  @JsonValue('ERROR')
  error,
  @JsonValue('SUCCESS')
  success,
  //use for create, update= flow
  @JsonValue('IN_PROGRESS')
  inProgress
}

enum AiAnalysisStatusEnum {
  @JsonValue('SAFE')
  safe,
  @JsonValue('DUBIOUS')
  dubious,
  @JsonValue('DANGEROUS')
  dangerous
}

