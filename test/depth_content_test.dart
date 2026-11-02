import 'package:flutter_test/flutter_test.dart';
import 'package:esports_dynasty/models/game_state.dart';
import 'package:esports_dynasty/models/player.dart';
import 'package:esports_dynasty/models/staff.dart';
import 'package:esports_dynasty/models/sponsor.dart';
import 'package:esports_dynasty/models/game_event.dart';
import 'package:esports_dynasty/models/placed_furniture.dart';
import 'package:esports_dynasty/services/sponsor_service.dart';
import 'package:esports_dynasty/services/event_service.dart';
import 'package:esports_dynasty/services/transfer_service.dart';
import 'package:esports_dynasty/services/academy_service.dart';
import 'package:esports_dynasty/services/achievement_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Phase 6 Depth: Difficulty Modes', () {
    test('Difficulty modes correctly scale starting funds and income multipliers', () {
      final easyState = GameState.initial(
        teamName: 'Easy Team',
        ownerName: 'Boss Easy',
        primaryColorHex: '#1B2A49',
        secondaryColorHex: '#F5B700',
        emblemSymbol: 'lightning',
        emblemLetters: 'ET',
        difficulty: 'easy',
      );
      expect(easyState.money, equals(65000));
      expect(easyState.incomeDifficultyMultiplier, equals(1.25));

      final normalState = GameState.initial(
        teamName: 'Normal Team',
        ownerName: 'Boss Normal',
        primaryColorHex: '#1B2A49',
        secondaryColorHex: '#F5B700',
        emblemSymbol: 'lightning',
        emblemLetters: 'NT',
        difficulty: 'normal',
      );
      expect(normalState.money, equals(50000));
      expect(normalState.incomeDifficultyMultiplier, equals(1.0));

      final hardState = GameState.initial(
        teamName: 'Hard Team',
        ownerName: 'Boss Hard',
        primaryColorHex: '#1B2A49',
        secondaryColorHex: '#F5B700',
        emblemSymbol: 'lightning',
        emblemLetters: 'HT',
        difficulty: 'hard',
      );
      expect(hardState.money, equals(35000));
      expect(hardState.incomeDifficultyMultiplier, equals(0.80));
    });
  });

  group('Phase 6 Depth: Sponsor Contracts & Goals', () {
    test('Signing sponsor, progressing goal, and claiming bonus works', () {
      final state = GameState.initial(
        teamName: 'Sponsor Test',
        ownerName: 'Boss Sponsor',
        primaryColorHex: '#1B2A49',
        secondaryColorHex: '#F5B700',
        emblemSymbol: 'lightning',
        emblemLetters: 'ST',
      );

      const def = SponsorDef(
        id: 'test_sponsor',
        name: 'Test Telecom',
        tier: 1,
        weeklyPay: 3000,
        bonusPay: 8000,
        minFame: 0,
        durationWeeks: 12,
        goalType: 'win_matches',
        goalTarget: 3,
        desc: 'Test description',
      );

      final signed = SponsorService().signSponsor(def, state);
      expect(signed, isTrue);
      expect(state.activeSponsors.length, equals(1));
      expect(state.activeSponsors.first.isCompleted, isFalse);

      // Progress goal
      state.progressSponsors('win_matches', 2);
      expect(state.activeSponsors.first.goalProgress, equals(2));
      expect(state.activeSponsors.first.isCompleted, isFalse);

      state.progressSponsors('win_matches', 1);
      expect(state.activeSponsors.first.goalProgress, equals(3));
      expect(state.activeSponsors.first.isCompleted, isTrue);

      // Claim bonus
      final initialMoney = state.money;
      final claimed = SponsorService().claimBonus(state.activeSponsors.first, state);
      expect(claimed, isTrue);
      expect(state.money, equals(initialMoney + 8000));
      expect(state.activeSponsors.first.isBonusClaimed, isTrue);
    });

    test('Weekly sponsor tick pays income and manager level scales payout', () {
      final state = GameState.initial(
        teamName: 'Sponsor Tick',
        ownerName: 'Boss Tick',
        primaryColorHex: '#1B2A49',
        secondaryColorHex: '#F5B700',
        emblemSymbol: 'lightning',
        emblemLetters: 'ST',
      );

      state.staff.add(
        StaffMember(id: 'm1', name: 'Manager Joy', role: StaffRole.manager, level: 2, salary: 4000),
      );

      state.activeSponsors.add(
        ActiveSponsor(
          id: 'sp1',
          name: 'Partner Bank',
          tier: 1,
          weeklyPay: 5000,
          bonusPay: 10000,
          durationWeeks: 12,
          weeksRemaining: 4,
          goalType: 'gain_fans',
          goalTarget: 200,
        ),
      );

      final initialMoney = state.money;
      SponsorService().tickWeeklySponsors(state);

      // Manager bonus +16% -> 5000 * 1.16 = 5800
      expect(state.money, equals(initialMoney + 5800));
      expect(state.activeSponsors.first.weeksRemaining, equals(3));
    });
  });

  group('Phase 6 Depth: Random Events & Choices', () {
    test('Applying choices updates money, morale, fatigue, flags, and cooldowns', () {
      final state = GameState.initial(
        teamName: 'Event Test',
        ownerName: 'Boss Event',
        primaryColorHex: '#1B2A49',
        secondaryColorHex: '#F5B700',
        emblemSymbol: 'lightning',
        emblemLetters: 'ET',
      );

      const evt = NarrativeEvent(
        id: 'TEST_EVT',
        title: 'Fiesta Day',
        category: 'team',
        text: 'Niyaya ng buong barangay ang squad!',
        choices: [
          EventChoice(
            text: 'Bumili ng meryenda',
            cost: 2000,
            outcome: EventOutcome(morale: 10, fatigue: -5, flag: 'fiesta_done', text: 'Busog ang squad!'),
          ),
        ],
      );

      final initialMoney = state.money;
      final initialMorale = state.players.first.morale;

      final res = EventService().applyEventChoice(evt, evt.choices.first, state);
      expect(res, equals('Busog ang squad!'));
      expect(state.money, equals(initialMoney - 2000));
      expect(state.players.first.morale, equals(initialMorale + 10));
      expect(state.storyFlags['fiesta_done'], isTrue);
      expect(state.eventCooldowns['TEST_EVT'], equals(12));
    });
  });

  group('Phase 6 Depth: Contracts, Transfers, & Retirement', () {
    test('Contract renewal demand reflects player morale and traits', () {
      final happyPlayer = Player(
        id: 'p1', realName: 'Juan', gamerTag: 'Kidlat', role: PlayerRole.carry,
        aim: 70, reaction: 70, gameSense: 70, teamwork: 70, mental: 70, stamina: 70,
        morale: 80,
      );
      expect(TransferService().calculateSalaryDemand(happyPlayer), equals(happyPlayer.weeklySalary));

      final unhappyPlayer = Player(
        id: 'p2', realName: 'Pedro', gamerTag: 'Kulog', role: PlayerRole.carry,
        aim: 70, reaction: 70, gameSense: 70, teamwork: 70, mental: 70, stamina: 70,
        morale: 40,
      );
      // Unhappy demands +25%
      expect(TransferService().calculateSalaryDemand(unhappyPlayer), equals((unhappyPlayer.weeklySalary * 1.25).round()));

      final pennyPlayer = Player(
        id: 'p3', realName: 'Jose', gamerTag: 'Tipid', role: PlayerRole.carry,
        aim: 70, reaction: 70, gameSense: 70, teamwork: 70, mental: 70, stamina: 70,
        morale: 80, traits: ['Penny Wise'],
      );
      // Penny Wise demands -15%
      expect(TransferService().calculateSalaryDemand(pennyPlayer), equals((pennyPlayer.weeklySalary * 0.85).round()));
    });

    test('Transfer fee calculation factors in rank factor and manager level discount', () {
      final state = GameState.initial(
        teamName: 'Transfer Squad',
        ownerName: 'Owner T',
        primaryColorHex: '#1B2A49',
        secondaryColorHex: '#F5B700',
        emblemSymbol: 'lightning',
        emblemLetters: 'TS',
      );

      final proPlayer = Player(
        id: 'pro1', realName: 'Dexter', gamerTag: 'ProGamer', role: PlayerRole.carry,
        aim: 70, reaction: 70, gameSense: 70, teamwork: 70, mental: 70, stamina: 70,
      );

      // Without manager: 7000 * 20 * 1.8 = 252,000
      final feeWithoutManager = TransferService().calculateTransferFee(proPlayer, state);
      expect(feeWithoutManager, equals(252000));

      // With Level 3 Manager (-12% fee)
      state.staff.add(StaffMember(id: 'm1', name: 'Mgr', role: StaffRole.manager, level: 3, salary: 5000));
      final feeWithManager = TransferService().calculateTransferFee(proPlayer, state);
      expect(feeWithManager, equals((252000 * 0.88).round()));
    });

    test('Retirement converts legend to Hall of Fame and offers staff coaching', () {
      final state = GameState.initial(
        teamName: 'Retire Squad',
        ownerName: 'Owner R',
        primaryColorHex: '#1B2A49',
        secondaryColorHex: '#F5B700',
        emblemSymbol: 'lightning',
        emblemLetters: 'RS',
      );

      final veteran = Player(
        id: 'vet1', realName: 'Mark Santos', gamerTag: 'Kidlat', role: PlayerRole.carry,
        aim: 85, reaction: 80, gameSense: 85, teamwork: 80, mental: 80, stamina: 80,
        age: 32,
      );
      state.players.add(veteran);

      TransferService().retirePlayer(veteran, state);
      expect(state.players.contains(veteran), isFalse);
      expect(state.hallOfFame.any((h) => h.category == 'Retired Legend'), isTrue);

      // Convert to coach
      final coachStaff = TransferService().convertToStaff(veteran, StaffRole.coach);
      expect(coachStaff.level, equals(2)); // +1 level bonus
      expect(coachStaff.name.contains('Kidlat'), isTrue);
    });
  });

  group('Phase 6 Depth: Academy & Sub-Roster', () {
    test('Academy unlocks at Tier 3 and generates 16-17 year old rookie prospect', () {
      final state = GameState.initial(
        teamName: 'Academy Team',
        ownerName: 'Owner A',
        primaryColorHex: '#1B2A49',
        secondaryColorHex: '#F5B700',
        emblemSymbol: 'lightning',
        emblemLetters: 'AT',
      );

      // Tier 0 -> Locked
      expect(state.isAcademyUnlocked, isFalse);
      expect(AcademyService().checkAcademyProspect(state), isNull);

      // Upgrade to Pro Gaming House (Tier 3)
      state.houseTier = 3;
      expect(state.isAcademyUnlocked, isTrue);

      final prospect = AcademyService().checkAcademyProspect(state);
      expect(prospect, isNotNull);
      expect(prospect!.age, inInclusiveRange(16, 17));
      expect(prospect.potentialStars, greaterThanOrEqualTo(3));

      // Enroll into roster
      final initialCount = state.players.length;
      final enrolled = AcademyService().enrollProspect(prospect, state);
      expect(enrolled, isTrue);
      expect(state.players.length, equals(initialCount + 1));
      expect(state.subs.contains(prospect), isTrue);
    });
  });

  group('Phase 6 Depth: Achievements Engine', () {
    test('Milestone evaluator awards rewards and prevents duplicate claims', () {
      final state = GameState.initial(
        teamName: 'Trophy Squad',
        ownerName: 'Owner T',
        primaryColorHex: '#1B2A49',
        secondaryColorHex: '#F5B700',
        emblemSymbol: 'lightning',
        emblemLetters: 'TS',
      );

      // Set conditions: 5 starters, P100k money, 500 fans
      while (state.starters.length < 5) {
        state.players.add(Player(
          id: 'p_${state.players.length}', realName: 'Sub', gamerTag: 'Player${state.players.length}',
          role: PlayerRole.mid, aim: 40, reaction: 40, gameSense: 40, teamwork: 40, mental: 40, stamina: 40,
          isStarter: true,
        ));
      }
      state.money = 120000;
      state.fans = 600;

      final unlocked = AchievementService().checkMilestones(state);
      expect(unlocked.any((a) => a.id == 'roster_full_five'), isTrue);
      expect(unlocked.any((a) => a.id == 'money_100k'), isTrue);
      expect(unlocked.any((a) => a.id == 'fans_500'), isTrue);

      // Claim reward for roster_full_five
      final ach = unlocked.firstWhere((a) => a.id == 'roster_full_five');
      final initialMoney = state.money;
      final claimed = AchievementService().claimReward(ach, state);
      expect(claimed, isTrue);
      expect(state.money, equals(initialMoney + ach.rewardMoney));

      // Attempt duplicate claim
      final duplicateClaim = AchievementService().claimReward(ach, state);
      expect(duplicateClaim, isFalse);
    });
  });

  group('Phase 6 Depth: Staff Leveling & Combos', () {
    test('Staff leveling up scales bonuses and enforces max level 5', () {
      final coach = StaffMember(
        id: 'c1',
        name: 'Coach Ramon',
        role: StaffRole.coach,
        level: 1,
        salary: 2500,
      );

      expect(coach.level, equals(1));
      expect(coach.upgradeCost, equals(10000));
      expect(coach.effectDescription, contains('+6%'));

      coach.levelUp();
      expect(coach.level, equals(2));
      expect(coach.salary, equals((2500 * 1.5).round()));
      expect(coach.effectDescription, contains('+12%'));

      // Level up to 5
      coach.levelUp(); // 3
      coach.levelUp(); // 4
      coach.levelUp(); // 5
      expect(coach.level, equals(5));
      expect(coach.upgradeCost, equals(0));
      expect(coach.effectDescription, contains('+30%'));

      // Cannot exceed 5
      coach.levelUp();
      expect(coach.level, equals(5));
    });

    test('House comfort rating and combos calculate correctly', () {
      final state = GameState.initial(
        teamName: 'Comfort Squad',
        ownerName: 'Owner C',
        primaryColorHex: '#1B2A49',
        secondaryColorHex: '#F5B700',
        emblemSymbol: 'lightning',
        emblemLetters: 'CS',
      );

      expect(state.hasScrimRoomCombo, isFalse);
      expect(state.hasKainanCombo, isFalse);

      // Add 2 more PC desks to reach 5
      state.furniture.add(PlacedFurniture(
        id: 'desk_4', itemId: 'pc_desk', name: 'PC Desk', tileX: 1, tileY: 2, sizeX: 2, sizeY: 1, station: 'pc',
      ));
      state.furniture.add(PlacedFurniture(
        id: 'desk_5', itemId: 'pc_desk', name: 'PC Desk', tileX: 3, tileY: 2, sizeX: 2, sizeY: 1, station: 'pc',
      ));
      expect(state.hasScrimRoomCombo, isTrue);

      // Add dining table
      state.furniture.add(PlacedFurniture(
        id: 'dt_1', itemId: 'dining_table', name: 'Dining Table', tileX: 5, tileY: 2, sizeX: 2, sizeY: 1, station: 'table',
      ));
      expect(state.hasKainanCombo, isTrue);

      // Add lounge sofa & aircon to reach 5-star comfort
      state.furniture.add(PlacedFurniture(
        id: 'sofa_1', itemId: 'lounge_sofa', name: 'Lounge Sofa', tileX: 0, tileY: 0, sizeX: 2, sizeY: 1, station: 'lounge',
      ));
      state.furniture.add(PlacedFurniture(
        id: 'ac_1', itemId: 'aircon', name: 'Aircon', tileX: 0, tileY: 1, sizeX: 1, sizeY: 1, station: 'wall',
      ));
      expect(state.comfortRating, equals(5));
    });
  });
}
