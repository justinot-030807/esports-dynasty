import 'placed_furniture.dart';
import 'player.dart';
import 'weekly_plan.dart';

/// Seed objects for a brand new GameState
class GameStateDefaults {
  static List<PlacedFurniture> createInitialFurniture() {
    return [
      PlacedFurniture(
        id: 'desk_1', itemId: 'pc_desk', name: 'Gaming PC Desk',
        tileX: 1, tileY: 1, sizeX: 2, sizeY: 1, station: 'pc',
      ),
      PlacedFurniture(
        id: 'desk_2', itemId: 'pc_desk', name: 'Gaming PC Desk',
        tileX: 3, tileY: 1, sizeX: 2, sizeY: 1, station: 'pc',
      ),
      PlacedFurniture(
        id: 'desk_3', itemId: 'pc_desk', name: 'Gaming PC Desk',
        tileX: 5, tileY: 1, sizeX: 2, sizeY: 1, station: 'pc',
      ),
      PlacedFurniture(
        id: 'bed_1', itemId: 'bunk_bed', name: 'Bunk Bed',
        tileX: 1, tileY: 4, sizeX: 2, sizeY: 1, station: 'bed',
      ),
      PlacedFurniture(
        id: 'bed_2', itemId: 'bunk_bed', name: 'Bunk Bed',
        tileX: 4, tileY: 4, sizeX: 2, sizeY: 1, station: 'bed',
      ),
      PlacedFurniture(
        id: 'kitchen_1', itemId: 'kitchen', name: 'Kitchen',
        tileX: 6, tileY: 3, sizeX: 2, sizeY: 2, station: 'kitchen',
      ),
      PlacedFurniture(
        id: 'shelf_1', itemId: 'trophy_shelf', name: 'Trophy Shelf',
        tileX: 0, tileY: 3, sizeX: 1, sizeY: 2, station: 'shelf',
      ),
    ];
  }

  static List<Player> createInitialPlayers({
    required String primaryColorHex,
    required String secondaryColorHex,
  }) {
    return [
      Player(
        id: 'rookie_1', realName: 'Mark Angelo Santos', gamerTag: 'Kidlat',
        role: PlayerRole.carry, age: 18,
        aim: 38, reaction: 36, gameSense: 32, teamwork: 30, mental: 34, stamina: 35,
        traits: ['Clutch'],
        jerseyColorHex: primaryColorHex, hairColorHex: '#1B2A49', skinColorHex: '#E0AC69',
        posX: 0.25, posY: 0.35, currentStation: 'pc',
      ),
      Player(
        id: 'rookie_2', realName: 'Bryan Mendoza', gamerTag: 'Amihan',
        role: PlayerRole.mid, age: 19,
        aim: 34, reaction: 35, gameSense: 39, teamwork: 33, mental: 35, stamina: 32,
        traits: ['Team Player'],
        jerseyColorHex: secondaryColorHex, hairColorHex: '#4A3728', skinColorHex: '#C68642',
        posX: 0.50, posY: 0.35, currentStation: 'pc',
      ),
      Player(
        id: 'rookie_3', realName: 'Kyle Justin Cruz', gamerTag: 'Tsinelas',
        role: PlayerRole.tank, age: 17,
        aim: 30, reaction: 32, gameSense: 34, teamwork: 38, mental: 36, stamina: 38,
        traits: ['Workaholic'],
        jerseyColorHex: '#3FA7FF', hairColorHex: '#0F172A', skinColorHex: '#8D5524',
        posX: 0.75, posY: 0.75, currentStation: 'kitchen',
      ),
    ];
  }

  static WeeklyPlan createInitialPlan() {
    return WeeklyPlan(
      focus: TeamFocus.balanced,
      playerActivities: {
        'rookie_1': PlayerActivity.trainAim,
        'rookie_2': PlayerActivity.trainGameSense,
        'rookie_3': PlayerActivity.trainTeamwork,
      },
    );
  }
}
