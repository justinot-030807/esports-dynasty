import 'dart:math';
import '../models/game_state.dart';
import '../models/player.dart';
import '../models/staff.dart';
import '../models/hall_of_fame.dart';
import '../models/transfer_deal.dart';
import 'scouting_service.dart';

/// Manages player contracts, transfer market poaches, and retirement ceremonies
class TransferService {
  static final TransferService _instance = TransferService._internal();
  factory TransferService() => _instance;
  TransferService._internal();

  final Random _rng = Random();

  void tickWeeklyContracts(GameState state) {
    final departed = <Player>[];

    for (final p in state.players) {
      p.contractWeeksLeft--;
      if (p.contractWeeksLeft <= 0) {
        departed.add(p);
      }
    }

    for (final p in departed) {
      state.players.remove(p);
      state.addNotification('${p.gamerTag} left: Contract Expired!', '#E5484D', 0.5, 0.45);
    }
  }

  List<Player> getRenewalCandidates(GameState state) {
    return state.players.where((p) => p.contractWeeksLeft <= 8).toList();
  }

  int calculateSalaryDemand(Player p) {
    int base = p.weeklySalary;
    if (p.morale < 50) {
      base = (base * 1.25).round();
    }
    if (p.traits.contains('Penny Wise')) {
      base = (base * 0.85).round();
    }
    return base;
  }

  bool renewContract(Player p, int weeks, GameState state) {
    p.contractWeeksLeft += weeks;
    state.addNotification('${p.gamerTag} renewed for $weeks weeks!', '#3DBE5A', 0.5, 0.4);
    return true;
  }

  bool releasePlayer(Player p, GameState state) {
    final buyout = p.weeklySalary * 8;
    if (state.money < buyout) return false;

    state.money -= buyout;
    state.monthExpenses += buyout;
    state.players.remove(p);
    state.addNotification('Released ${p.gamerTag} (Paid P$buyout)', '#E5484D', 0.5, 0.4);
    return true;
  }

  int calculateTransferFee(Player p, GameState state) {
    double rankFactor = 1.0;
    if (p.ovr >= 92) {
      rankFactor = 3.5;
    } else if (p.ovr >= 80) {
      rankFactor = 2.5;
    } else if (p.ovr >= 65) {
      rankFactor = 1.8;
    } else if (p.ovr >= 50) {
      rankFactor = 1.3;
    }

    final managerDiscount = 1.0 - ((state.manager?.level ?? 0) * 0.04);
    return (p.weeklySalary * 20 * rankFactor * managerDiscount).round();
  }

  List<Player> generateTransferTargets(GameState state) {
    final targets = <Player>[];
    for (int i = 0; i < 6; i++) {
      final p = ScoutingService().generateCandidate(minOvr: 55, maxOvr: 85);
      p.age = 19 + _rng.nextInt(6);
      p.isPotentialRevealed = true;
      targets.add(p);
    }
    return targets;
  }

  bool buyTransferPlayer(Player p, GameState state) {
    if (state.players.length >= state.maxRosterCap) return false;
    final fee = calculateTransferFee(p, state);
    if (state.money < fee) return false;

    state.money -= fee;
    state.monthExpenses += fee;
    p.isStarter = state.starters.length < 5;
    state.players.add(p);
    state.addNotification('Signed: ${p.gamerTag} for P$fee', '#3DBE5A', 0.5, 0.4);
    return true;
  }

  void checkForAiPoachOffer(GameState state) {
    if (!state.isTransferWindowOpen) return;
    if (state.players.isEmpty) return;
    if (_rng.nextDouble() > 0.40) return;

    final valuable = state.players.where((p) => p.ovr >= 65).toList();
    if (valuable.isEmpty) return;

    valuable.shuffle(_rng);
    final target = valuable.first;
    final fee = (calculateTransferFee(target, state) * 1.3).round();
    final salary = (target.weeklySalary * 1.5).round();

    final rivalNames = ['Kidlat Esports', 'Bakal Wolves', 'Dagat Dragons', 'Mayon Flames'];
    final teamName = rivalNames[_rng.nextInt(rivalNames.length)];

    final offer = TransferOffer(
      id: 'offer_${DateTime.now().millisecondsSinceEpoch}',
      offeringTeamId: 'RIV_${_rng.nextInt(10)}',
      offeringTeamName: teamName,
      playerId: target.id,
      playerName: target.gamerTag,
      transferFee: fee,
      offeredSalary: salary,
    );

    state.pendingTransferOffers.add(offer);
    state.addNotification('Transfer Offer from $teamName!', '#F5B700', 0.5, 0.45);
  }

  bool acceptTransferOffer(TransferOffer offer, GameState state) {
    final p = state.players.cast<Player?>().firstWhere((pl) => pl?.id == offer.playerId, orElse: () => null);
    if (p == null) return false;

    state.money += offer.transferFee;
    state.monthIncome += offer.transferFee;
    state.players.remove(p);
    state.pendingTransferOffers.remove(offer);

    state.addNotification('Sold ${offer.playerName} for P${offer.transferFee}!', '#3DBE5A', 0.5, 0.4);
    return true;
  }

  void performAnnualAgeing(GameState state) {
    for (final p in state.players) {
      p.age++;
      if (p.age >= 27) {
        if (_rng.nextDouble() < 0.6) {
          p.aim = max(25, p.aim - 1);
        }
        if (_rng.nextDouble() < 0.6) {
          p.reaction = max(25, p.reaction - 1);
        }
      }
    }
  }

  List<Player> checkRetirements(GameState state) {
    final retirees = <Player>[];
    for (final p in state.players) {
      if (p.age < 29) continue;
      double chance = 0.15;
      if (p.age == 30) chance = 0.30;
      if (p.age == 31) chance = 0.50;
      if (p.age == 32) chance = 0.80;
      if (p.age >= 33) chance = 1.0;

      if (_rng.nextDouble() < chance) {
        retirees.add(p);
      }
    }
    return retirees;
  }

  void retirePlayer(Player p, GameState state) {
    state.players.remove(p);
    state.storyFlags['retired_legend'] = true;

    if (p.ovr >= 70 || p.age >= 28 || state.trophies.isNotEmpty) {
      state.hallOfFame.add(
        HallOfFameRecord(
          id: 'hof_${state.year}_retire_${p.id}',
          year: state.year,
          category: 'Retired Legend',
          title: '${p.gamerTag} (${p.realName})',
          recipientName: p.gamerTag,
          teamName: state.teamName,
          details: 'Retired at age ${p.age} with peak ${p.ovr} OVR.',
        ),
      );
    }
    state.addNotification('Retired: ${p.gamerTag} (Hall of Fame)', '#9B5DE5', 0.5, 0.45);
  }

  StaffMember convertToStaff(Player p, StaffRole role) {
    return StaffMember(
      id: 'staff_retire_${p.id}',
      name: '${p.gamerTag} (${p.realName})',
      role: role,
      level: 2, // Starts with +1 level bonus (level 2)
      salary: 4000,
    );
  }

  void retireAndConvertToStaff(Player p, StaffRole role, GameState state) {
    retirePlayer(p, state);
    final member = convertToStaff(p, role);
    state.staff.removeWhere((s) => s.role == role);
    state.staff.add(member);
    state.storyFlags['converted_coach'] = true;
    state.addNotification('Bagong Coach: ${p.gamerTag}!', '#3DBE5A', 0.5, 0.45);
  }
}
