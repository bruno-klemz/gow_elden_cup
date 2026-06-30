/// A selection returned by the search screen: jump to a realm, or to a boss
/// (which lives in a realm and should be scrolled into view).
sealed class SearchResult {
  const SearchResult();
}

class RegionResult extends SearchResult {
  final String realmId;
  const RegionResult(this.realmId);
}

class BossResult extends SearchResult {
  final String bossId;
  final String realmId;
  const BossResult({required this.bossId, required this.realmId});
}
