/// Narrative and random event models
class EventOutcome {
  final int money;
  final int fame;
  final int fans;
  final int morale;
  final int fatigue;
  final int chemistry;
  final String? flag;
  final String text;

  const EventOutcome({
    this.money = 0,
    this.fame = 0,
    this.fans = 0,
    this.morale = 0,
    this.fatigue = 0,
    this.chemistry = 0,
    this.flag,
    this.text = '',
  });

  factory EventOutcome.fromJson(Map<String, dynamic> json) {
    return EventOutcome(
      money: (json['money'] as num?)?.toInt() ?? 0,
      fame: (json['fame'] as num?)?.toInt() ?? 0,
      fans: (json['fans'] as num?)?.toInt() ?? 0,
      morale: (json['morale'] as num?)?.toInt() ?? 0,
      fatigue: (json['fatigue'] as num?)?.toInt() ?? 0,
      chemistry: (json['chemistry'] as num?)?.toInt() ?? 0,
      flag: json['flag'] as String?,
      text: json['text'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'money': money,
    'fame': fame,
    'fans': fans,
    'morale': morale,
    'fatigue': fatigue,
    'chemistry': chemistry,
    if (flag != null) 'flag': flag,
    'text': text,
  };
}

class EventChoice {
  final String text;
  final String? condition;
  final int cost;
  final EventOutcome outcome;

  const EventChoice({
    required this.text,
    this.condition,
    this.cost = 0,
    required this.outcome,
  });

  factory EventChoice.fromJson(Map<String, dynamic> json) {
    return EventChoice(
      text: json['text'] as String? ?? '',
      condition: json['condition'] as String?,
      cost: (json['cost'] as num?)?.toInt() ?? 0,
      outcome: json['outcome'] != null
          ? EventOutcome.fromJson(json['outcome'] as Map<String, dynamic>)
          : const EventOutcome(),
    );
  }

  Map<String, dynamic> toJson() => {
    'text': text,
    if (condition != null) 'condition': condition,
    if (cost > 0) 'cost': cost,
    'outcome': outcome.toJson(),
  };
}

class NarrativeEvent {
  final String id;
  final String title;
  final String category;
  final String text;
  final String? condition;
  final List<EventChoice> choices;

  const NarrativeEvent({
    required this.id,
    required this.title,
    required this.category,
    required this.text,
    this.condition,
    required this.choices,
  });

  factory NarrativeEvent.fromJson(Map<String, dynamic> json) {
    final list = json['choices'] as List<dynamic>? ?? [];
    return NarrativeEvent(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      category: json['category'] as String? ?? 'general',
      text: json['text'] as String? ?? '',
      condition: json['condition'] as String?,
      choices: list.map((e) => EventChoice.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'category': category,
    'text': text,
    if (condition != null) 'condition': condition,
    'choices': choices.map((c) => c.toJson()).toList(),
  };
}
