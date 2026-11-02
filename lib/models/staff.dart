enum StaffRole { coach, analyst, manager, psychologist, cook, streamProducer }

class StaffMember {
  final String id;
  final String name;
  final StaffRole role;
  int level; // 1 to 5
  int salary;

  StaffMember({
    required this.id,
    required this.name,
    required this.role,
    this.level = 1,
    required this.salary,
  });

  String get roleTitle {
    switch (role) {
      case StaffRole.coach: return 'Head Coach';
      case StaffRole.analyst: return 'Analyst';
      case StaffRole.manager: return 'Manager';
      case StaffRole.psychologist: return 'Psychologist';
      case StaffRole.cook: return 'Cook (Kusinero)';
      case StaffRole.streamProducer: return 'Stream Producer';
    }
  }

  String get effectDescription {
    switch (role) {
      case StaffRole.coach:
        return 'Training gains +${(level * 6)}%';
      case StaffRole.analyst:
        return 'Scouting ${(30 + level * 12)}%, Match prep +${(level * 0.5).toStringAsFixed(1)} power';
      case StaffRole.manager:
        return 'Sponsor pay +${(level * 8)}%, Transfer fees -${(level * 4)}%';
      case StaffRole.psychologist:
        return 'Morale recovery +${(level * 10)}%';
      case StaffRole.cook:
        return 'Fatigue recovery +${(level * 8)}%, Meals +${level * 2 + 1} morale';
      case StaffRole.streamProducer:
        return 'Stream income +${(level * 10)}%, Fans +${(level * 5)}%';
    }
  }

  int get upgradeCost {
    if (level >= 5) return 0;
    switch (role) {
      case StaffRole.coach:
        return [10000, 25000, 60000, 150000][(level - 1).clamp(0, 3)];
      case StaffRole.analyst:
        return [8000, 20000, 50000, 120000][(level - 1).clamp(0, 3)];
      case StaffRole.manager:
        return [9000, 22000, 55000, 130000][(level - 1).clamp(0, 3)];
      case StaffRole.psychologist:
        return [10000, 24000, 58000, 140000][(level - 1).clamp(0, 3)];
      case StaffRole.cook:
        return [7500, 18000, 45000, 100000][(level - 1).clamp(0, 3)];
      case StaffRole.streamProducer:
        return [8500, 20000, 48000, 110000][(level - 1).clamp(0, 3)];
    }
  }

  void levelUp() {
    if (level >= 5) return;
    level++;
    salary = (salary * 1.5).round();
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'role': role.name,
    'level': level,
    'salary': salary,
  };

  factory StaffMember.fromJson(Map<String, dynamic> json) {
    return StaffMember(
      id: json['id'] as String? ?? 'staff_${DateTime.now().millisecondsSinceEpoch}',
      name: json['name'] as String? ?? 'Staff Member',
      role: StaffRole.values.firstWhere(
        (e) => e.name == json['role'],
        orElse: () => StaffRole.coach,
      ),
      level: (json['level'] as num?)?.toInt() ?? 1,
      salary: (json['salary'] as num?)?.toInt() ?? 2000,
    );
  }
}
