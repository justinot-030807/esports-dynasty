class TutorialState {
  int step; // 1: recruit, 2: build desk, 3: set plan, 4: ready for tourney, 5: completed
  bool isCompleted;
  bool isSkipped;

  TutorialState({
    this.step = 1,
    this.isCompleted = false,
    this.isSkipped = false,
  });

  String get currentPrompt {
    if (isCompleted || isSkipped) return '';
    switch (step) {
      case 1:
        return 'Mika: "Boss! Kailangan natin ng 5 players bago mag-Week 3. Silipin ang Scouting board sa Team tab para makapagrekrut!"';
      case 2:
        return 'Mika: "May dagdag tayong player! Maglagay ng PC Desk sa Build tab para may pwesto sila sa scrim."';
      case 3:
        return 'Mika: "Magtakda tayo ng Training Plan sa Plan tab para lumakas ang Aim at Teamwork ng squad!"';
      case 4:
        return 'Mika: "Handa na tayo! Pagdating ng W5, bubukas ang Internet Cafe Cup: Spring. Laban Pilipinas!"';
      default:
        return '';
    }
  }

  Map<String, dynamic> toJson() => {
    'step': step,
    'isCompleted': isCompleted,
    'isSkipped': isSkipped,
  };

  factory TutorialState.fromJson(Map<String, dynamic> json) {
    return TutorialState(
      step: (json['step'] as num?)?.toInt() ?? 1,
      isCompleted: json['isCompleted'] as bool? ?? false,
      isSkipped: json['isSkipped'] as bool? ?? false,
    );
  }
}
