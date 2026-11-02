/// Transfer market and contract negotiation models
class TransferOffer {
  final String id;
  final String offeringTeamId;
  final String offeringTeamName;
  final String playerId;
  final String playerName;
  final int transferFee;
  final int offeredSalary;
  int weeksValid;

  TransferOffer({
    required this.id,
    required this.offeringTeamId,
    required this.offeringTeamName,
    required this.playerId,
    required this.playerName,
    required this.transferFee,
    required this.offeredSalary,
    this.weeksValid = 2,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'offeringTeamId': offeringTeamId,
    'offeringTeamName': offeringTeamName,
    'playerId': playerId,
    'playerName': playerName,
    'transferFee': transferFee,
    'offeredSalary': offeredSalary,
    'weeksValid': weeksValid,
  };

  factory TransferOffer.fromJson(Map<String, dynamic> json) {
    return TransferOffer(
      id: json['id'] as String? ?? 'offer_${DateTime.now().millisecondsSinceEpoch}',
      offeringTeamId: json['offeringTeamId'] as String? ?? '',
      offeringTeamName: json['offeringTeamName'] as String? ?? 'Rival Team',
      playerId: json['playerId'] as String? ?? '',
      playerName: json['playerName'] as String? ?? 'Player',
      transferFee: (json['transferFee'] as num?)?.toInt() ?? 20000,
      offeredSalary: (json['offeredSalary'] as num?)?.toInt() ?? 5000,
      weeksValid: (json['weeksValid'] as num?)?.toInt() ?? 2,
    );
  }
}
