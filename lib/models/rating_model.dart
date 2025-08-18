class RatingResponse {
  final double averageRating;
  final int ratingCount;

  RatingResponse({
    required this.averageRating,
    required this.ratingCount,
  });

  factory RatingResponse.fromJson(Map<String, dynamic> json) {
    return RatingResponse(
      averageRating: (json['averageRating'] ?? 0).toDouble(),
      ratingCount: json['ratingCount'] ?? 0,
    );
  }
}
