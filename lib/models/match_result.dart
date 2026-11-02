class GameResult {
  final int gameNumber;
  final int teamAScore; // kills
  final int teamBScore; // kills
  final String winnerTeamId;
  final int durationMinutes;

  GameResult({
    required this.gameNumber,
    required this.teamAScore,
    required this.teamBScore,
    required this.winnerTeamId,
    required this.durationMinutes,
  });

  factory GameResult.fromJson(Map<String, dynamic> json) {
    return GameResult(
      gameNumber: (json['gameNumber'] as num?)?.toInt() ?? 1,
      teamAScore: (json['teamAScore'] as num?)?.toInt() ?? 12,
      teamBScore: (json['teamBScore'] as num?)?.toInt() ?? 8,
      winnerTeamId: json['winnerTeamId'] as String? ?? '',
      durationMinutes: (json['durationMinutes'] as num?)?.toInt() ?? 18,
    );
  }

  Map<String, dynamic> toJson() => {
    'gameNumber': gameNumber,
    'teamAScore': teamAScore,
    'teamBScore': teamBScore,
    'winnerTeamId': winnerTeamId,
    'durationMinutes': durationMinutes,
  };
}

class MatchSeriesResult {
  final String matchId;
  final String tournamentId;
  final String tournamentName;
  final String roundName;
  final String teamAId;
  final String teamAName;
  final String teamBId;
  final String teamBName;
  final int scoreA;
  final int scoreB;
  final String winnerId;
  final String winnerName;
  final List<GameResult> games;
  final String mvpName;
  final int fameChange;
  final int fansChange;
  final int prizeMoney;
  final int circuitPoints;
  final String newsHeadline;

  MatchSeriesResult({
    required this.matchId,
    required this.tournamentId,
    required this.tournamentName,
    required this.roundName,
    required this.teamAId,
    required this.teamAName,
    required this.teamBId,
    required this.teamBName,
    required this.scoreA,
    required this.scoreB,
    required this.winnerId,
    required this.winnerName,
    required this.games,
    required this.mvpName,
    required this.fameChange,
    required this.fansChange,
    required this.prizeMoney,
    required this.circuitPoints,
    required this.newsHeadline,
  });

  bool get isUserVictory => winnerId == 'user_team';
  bool get hasUser => teamAId == 'user_team' || teamBId == 'user_team';

  factory MatchSeriesResult.fromJson(Map<String, dynamic> json) {
    final gList = (json['games'] as List<dynamic>? ?? [])
        .map((e) => GameResult.fromJson(e as Map<String, dynamic>))
        .toList();

    return MatchSeriesResult(
      matchId: json['matchId'] as String? ?? '',
      tournamentId: json['tournamentId'] as String? ?? '',
      tournamentName: json['tournamentName'] as String? ?? '',
      roundName: json['roundName'] as String? ?? '',
      teamAId: json['teamAId'] as String? ?? '',
      teamAName: json['teamAName'] as String? ?? '',
      teamBId: json['teamBId'] as String? ?? '',
      teamBName: json['teamBName'] as String? ?? '',
      scoreA: (json['scoreA'] as num?)?.toInt() ?? 0,
      scoreB: (json['scoreB'] as num?)?.toInt() ?? 0,
      winnerId: json['winnerId'] as String? ?? '',
      winnerName: json['winnerName'] as String? ?? '',
      games: gList,
      mvpName: json['mvpName'] as String? ?? 'MVP',
      fameChange: (json['fameChange'] as num?)?.toInt() ?? 0,
      fansChange: (json['fansChange'] as num?)?.toInt() ?? 0,
      prizeMoney: (json['prizeMoney'] as num?)?.toInt() ?? 0,
      circuitPoints: (json['circuitPoints'] as num?)?.toInt() ?? 0,
      newsHeadline: json['newsHeadline'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'matchId': matchId,
    'tournamentId': tournamentId,
    'tournamentName': tournamentName,
    'roundName': roundName,
    'teamAId': teamAId,
    'teamAName': teamAName,
    'teamBId': teamBId,
    'teamBName': teamBName,
    'scoreA': scoreA,
    'scoreB': scoreB,
    'winnerId': winnerId,
    'winnerName': winnerName,
    'games': games.map((g) => g.toJson()).toList(),
    'mvpName': mvpName,
    'fameChange': fameChange,
    'fansChange': fansChange,
    'prizeMoney': prizeMoney,
    'circuitPoints': circuitPoints,
    'newsHeadline': newsHeadline,
  };
}
