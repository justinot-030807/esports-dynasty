enum TeamFocus {
  balanced,
  scrimBlock,
  vodReview,
  bootcamp,
  restWeek,
  streamMarathon,
}

enum PlayerActivity {
  trainAim,
  trainReaction,
  trainGameSense,
  trainTeamwork,
  trainMental,
  trainStamina,
  scrim,
  studyRole,
  stream,
  soloQueue,
  rest,
  freeTime,
}

class WeeklyPlan {
  TeamFocus focus;
  Map<String, PlayerActivity> playerActivities; // playerId -> activity

  WeeklyPlan({
    this.focus = TeamFocus.balanced,
    Map<String, PlayerActivity>? playerActivities,
  }) : playerActivities = playerActivities ?? {};

  String get focusTitle {
    switch (focus) {
      case TeamFocus.balanced: return 'Balanced';
      case TeamFocus.scrimBlock: return 'Scrim Block';
      case TeamFocus.vodReview: return 'VOD Review';
      case TeamFocus.bootcamp: return 'Bootcamp';
      case TeamFocus.restWeek: return 'Rest Week';
      case TeamFocus.streamMarathon: return 'Stream Marathon';
    }
  }

  String get focusDescription {
    switch (focus) {
      case TeamFocus.balanced: return 'Normal training and moderate fatigue.';
      case TeamFocus.scrimBlock: return 'Extra chemistry and teamwork gains.';
      case TeamFocus.vodReview: return 'Game sense and role mastery focus.';
      case TeamFocus.bootcamp: return 'Big gains (+50%), big fatigue (+60%).';
      case TeamFocus.restWeek: return 'Double recovery, zero training gains.';
      case TeamFocus.streamMarathon: return 'Bonus cash & fans, morale drain.';
    }
  }

  static String activityTitle(PlayerActivity act) {
    switch (act) {
      case PlayerActivity.trainAim: return 'Train Aim';
      case PlayerActivity.trainReaction: return 'Train Reaction';
      case PlayerActivity.trainGameSense: return 'Train Game Sense';
      case PlayerActivity.trainTeamwork: return 'Train Teamwork';
      case PlayerActivity.trainMental: return 'Train Mental';
      case PlayerActivity.trainStamina: return 'Train Stamina';
      case PlayerActivity.scrim: return 'Team Scrim';
      case PlayerActivity.studyRole: return 'Study Role';
      case PlayerActivity.stream: return 'Stream Online';
      case PlayerActivity.soloQueue: return 'Solo Queue';
      case PlayerActivity.rest: return 'Full Rest';
      case PlayerActivity.freeTime: return 'Free Time';
    }
  }

  static String requiredStation(PlayerActivity act) {
    switch (act) {
      case PlayerActivity.trainAim:
      case PlayerActivity.trainReaction:
      case PlayerActivity.trainGameSense:
      case PlayerActivity.trainTeamwork:
      case PlayerActivity.trainMental:
      case PlayerActivity.trainStamina:
      case PlayerActivity.scrim:
      case PlayerActivity.soloQueue:
        return 'pc';
      case PlayerActivity.stream:
        return 'stream';
      case PlayerActivity.studyRole:
        return 'meeting';
      case PlayerActivity.rest:
        return 'bed';
      case PlayerActivity.freeTime:
        return 'kitchen';
    }
  }

  static int baseFatigueChange(PlayerActivity act) {
    switch (act) {
      case PlayerActivity.trainAim:
      case PlayerActivity.trainReaction:
      case PlayerActivity.trainGameSense:
      case PlayerActivity.trainTeamwork:
      case PlayerActivity.trainMental:
      case PlayerActivity.trainStamina:
      case PlayerActivity.soloQueue:
        return 12;
      case PlayerActivity.scrim:
      case PlayerActivity.studyRole:
        return 8;
      case PlayerActivity.stream:
        return 5;
      case PlayerActivity.rest:
        return -25;
      case PlayerActivity.freeTime:
        return -10;
    }
  }

  Map<String, dynamic> toJson() => {
    'focus': focus.name,
    'playerActivities': playerActivities.map((k, v) => MapEntry(k, v.name)),
  };

  factory WeeklyPlan.fromJson(Map<String, dynamic> json) {
    final focus = TeamFocus.values.firstWhere(
      (e) => e.name == json['focus'],
      orElse: () => TeamFocus.balanced,
    );
    final map = (json['playerActivities'] as Map<String, dynamic>? ?? {})
        .map((k, v) => MapEntry(
              k,
              PlayerActivity.values.firstWhere(
                (e) => e.name == v,
                orElse: () => PlayerActivity.trainAim,
              ),
            ));
    return WeeklyPlan(focus: focus, playerActivities: map);
  }
}
