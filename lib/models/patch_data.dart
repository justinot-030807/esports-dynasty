class PatchDef {
  final String version;
  final String name;
  final String favoredStrategy;
  final String nerfedStrategy;
  final List<String> changes;

  const PatchDef({
    required this.version,
    required this.name,
    required this.favoredStrategy,
    required this.nerfedStrategy,
    required this.changes,
  });

  factory PatchDef.fromJson(Map<String, dynamic> json) {
    final rawChanges = json['changes'] as List<dynamic>? ?? [];
    return PatchDef(
      version: json['version'] as String? ?? '1.0',
      name: json['name'] as String? ?? 'Standard Meta',
      favoredStrategy: json['favored_strategy'] as String? ?? 'Rush',
      nerfedStrategy: json['nerfed_strategy'] as String? ?? 'Scale',
      changes: rawChanges.map((e) => e.toString()).toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'version': version,
    'name': name,
    'favored_strategy': favoredStrategy,
    'nerfed_strategy': nerfedStrategy,
    'changes': changes,
  };

  /// Returns +3 power if favored, -3 if nerfed, else 0
  int getStrategyModifier(String strategy) {
    if (strategy == favoredStrategy) return 3;
    if (strategy == nerfedStrategy) return -3;
    return 0;
  }
}
