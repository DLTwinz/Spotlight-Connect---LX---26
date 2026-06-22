class FanPassport {
  final String userId;
  final List<String> stamps;

  FanPassport({
    required this.userId,
    this.stamps = const [], 
  });
}