enum ModelLoadingStatus { idle, loading, ready, error }

class ModelLoadingState {
  const ModelLoadingState({
    this.status = ModelLoadingStatus.idle,
    this.progress = 0.0,
    this.errorMessage,
  });

  final ModelLoadingStatus status;
  final double progress; // 0.0 to 1.0
  final String? errorMessage;

  bool get isLoading => status == ModelLoadingStatus.loading;
  bool get isReady => status == ModelLoadingStatus.ready;
  bool get hasError => status == ModelLoadingStatus.error;

  ModelLoadingState copyWith({
    ModelLoadingStatus? status,
    double? progress,
    String? errorMessage,
  }) {
    return ModelLoadingState(
      status: status ?? this.status,
      progress: progress ?? this.progress,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
