class WatchesVideoModel {
  final String? vidId;
  final int? avaWatches;

  WatchesVideoModel({
    required this.vidId,
    required this.avaWatches,
  });

  // Factory method to create an instance from a Map (e.g., from JSON)
  factory WatchesVideoModel.fromMap(Map<String, dynamic> map) {
    return WatchesVideoModel(
      vidId: map['id'] as String? ?? '',
      avaWatches: map['avaWatches'] as int? ?? 4,
    );
  }
}
