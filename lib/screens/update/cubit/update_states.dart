abstract class UpdateState {
  const UpdateState();
}

class UpdateIdle extends UpdateState {
  const UpdateIdle();
}

class UpdateChecking extends UpdateState {
  const UpdateChecking();
}

class UpdateUpToDate extends UpdateState {
  const UpdateUpToDate();
}

class UpdateUnavailable extends UpdateState {
  const UpdateUnavailable();
}

class UpdateAvailable extends UpdateState {
  const UpdateAvailable();
}

class UpdateDownloading extends UpdateState {
  final double progress;
  const UpdateDownloading(this.progress);
}

class UpdateReadyToRestart extends UpdateState {
  const UpdateReadyToRestart();
}

class UpdateFailed extends UpdateState {
  final String error;
  const UpdateFailed(this.error);
}
