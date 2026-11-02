class MonthlyFinanceReport {
  final int year;
  final int month;
  final int totalIncome;
  final int totalExpenses;
  final int netProfit;
  final int playerSalariesPaid;
  final int staffSalariesPaid;
  final int rentPaid;
  final int sponsorIncome;
  final int streamIncome;
  final int prizeIncome;
  final int fansGained;
  final int fameGained;
  final String mikaTip;

  MonthlyFinanceReport({
    required this.year,
    required this.month,
    required this.totalIncome,
    required this.totalExpenses,
    required this.netProfit,
    required this.playerSalariesPaid,
    required this.staffSalariesPaid,
    required this.rentPaid,
    required this.sponsorIncome,
    required this.streamIncome,
    required this.prizeIncome,
    required this.fansGained,
    required this.fameGained,
    required this.mikaTip,
  });

  Map<String, dynamic> toJson() => {
    'year': year,
    'month': month,
    'totalIncome': totalIncome,
    'totalExpenses': totalExpenses,
    'netProfit': netProfit,
    'playerSalariesPaid': playerSalariesPaid,
    'staffSalariesPaid': staffSalariesPaid,
    'rentPaid': rentPaid,
    'sponsorIncome': sponsorIncome,
    'streamIncome': streamIncome,
    'prizeIncome': prizeIncome,
    'fansGained': fansGained,
    'fameGained': fameGained,
    'mikaTip': mikaTip,
  };

  factory MonthlyFinanceReport.fromJson(Map<String, dynamic> json) {
    return MonthlyFinanceReport(
      year: (json['year'] as num?)?.toInt() ?? 1,
      month: (json['month'] as num?)?.toInt() ?? 1,
      totalIncome: (json['totalIncome'] as num?)?.toInt() ?? 0,
      totalExpenses: (json['totalExpenses'] as num?)?.toInt() ?? 0,
      netProfit: (json['netProfit'] as num?)?.toInt() ?? 0,
      playerSalariesPaid: (json['playerSalariesPaid'] as num?)?.toInt() ?? 0,
      staffSalariesPaid: (json['staffSalariesPaid'] as num?)?.toInt() ?? 0,
      rentPaid: (json['rentPaid'] as num?)?.toInt() ?? 0,
      sponsorIncome: (json['sponsorIncome'] as num?)?.toInt() ?? 0,
      streamIncome: (json['streamIncome'] as num?)?.toInt() ?? 0,
      prizeIncome: (json['prizeIncome'] as num?)?.toInt() ?? 0,
      fansGained: (json['fansGained'] as num?)?.toInt() ?? 0,
      fameGained: (json['fameGained'] as num?)?.toInt() ?? 0,
      mikaTip: json['mikaTip'] as String? ?? 'Galingan pa natin Boss!',
    );
  }
}
