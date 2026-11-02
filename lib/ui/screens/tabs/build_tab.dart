import 'package:flutter/material.dart';
import '../../../core/constants.dart';
import '../../../models/game_state.dart';
import '../../../models/placed_furniture.dart';
import '../../../services/data_service.dart';

class BuildTab extends StatefulWidget {
  final GameState state;
  final VoidCallback onStateUpdated;

  const BuildTab({
    super.key,
    required this.state,
    required this.onStateUpdated,
  });

  @override
  State<BuildTab> createState() => _BuildTabState();
}

class _BuildTabState extends State<BuildTab> {
  String _selectedCategory = 'all';
  int _viewMode = 0; // 0 = Catalog, 1 = Placed (Sell)

  void _buyItem(String itemId, String name, int price, String station, int sx, int sy) {
    if (widget.state.money < price) {
      _showMessage('Kulang ang pera! Kailangan ng P$price.');
      return;
    }

    setState(() {
      widget.state.money -= price;
      // Place at an available tile
      final nextTileX = (widget.state.furniture.length % 6) + 1;
      final nextTileY = (widget.state.furniture.length ~/ 6) + 1;

      widget.state.furniture.add(PlacedFurniture(
        id: 'f_${DateTime.now().millisecondsSinceEpoch}',
        itemId: itemId,
        name: name,
        tileX: nextTileX,
        tileY: nextTileY,
        sizeX: sx,
        sizeY: sy,
        station: station,
      ));

      widget.state.addNotification('+$name', '#3DBE5A', 0.5, 0.4);

      // Tutorial progression (Step 2: place desk)
      if (widget.state.tutorial.step == 2 && itemId.contains('desk')) {
        widget.state.tutorial.step = 3;
      }
    });
    widget.onStateUpdated();
    _showMessage('Nabili ang $name!');
  }

  void _sellFurniture(PlacedFurniture f) {
    final item = DataService().findItem(f.itemId);
    final int originalPrice = item?.price ?? 5000;
    final int refund = (originalPrice * 0.70).round();

    setState(() {
      widget.state.furniture.remove(f);
      widget.state.money += refund;
      widget.state.addNotification('+P$refund', '#F5B700', 0.5, 0.4);
    });
    widget.onStateUpdated();
    _showMessage('Naibenta ang ${f.name} sa halagang P$refund (70%).');
  }

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: const TextStyle(fontFamily: AppConstants.pixelFont)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final allItems = DataService().items;
    final filtered = _selectedCategory == 'all'
        ? allItems
        : allItems.where((i) => i.category == _selectedCategory).toList();

    return Container(
      color: AppConstants.bgDark,
      child: Column(
        children: [
          // House Comfort & Combo Status Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            color: const Color(0xFF1B2A49),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Text('Comfort: ', style: TextStyle(fontFamily: AppConstants.pixelFont, fontSize: 11, color: Colors.white70)),
                    for (int i = 0; i < widget.state.comfortRating; i++)
                      const Icon(Icons.star, size: 14, color: AppConstants.moneyGold),
                  ],
                ),
                Row(
                  children: [
                    if (widget.state.hasScrimRoomCombo)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                        decoration: BoxDecoration(color: AppConstants.positiveGreen, borderRadius: BorderRadius.circular(3)),
                        child: const Text('COMBO: Scrim Room', style: TextStyle(fontFamily: AppConstants.pixelFont, fontSize: 8, color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    if (widget.state.hasKainanCombo) ...[
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                        decoration: BoxDecoration(color: AppConstants.fansPink, borderRadius: BorderRadius.circular(3)),
                        child: const Text('COMBO: Kainan', style: TextStyle(fontFamily: AppConstants.pixelFont, fontSize: 8, color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),

          // Catalog vs Placed Mode Toggle
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            color: const Color(0xFF142036),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _viewMode == 0 ? AppConstants.energyBlue : const Color(0xFF233458),
                      padding: const EdgeInsets.symmetric(vertical: 4),
                    ),
                    onPressed: () => setState(() => _viewMode = 0),
                    child: const Text('SHOP CATALOG', style: TextStyle(fontFamily: AppConstants.pixelFont, fontSize: 10, color: Colors.white)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _viewMode == 1 ? AppConstants.energyBlue : const Color(0xFF233458),
                      padding: const EdgeInsets.symmetric(vertical: 4),
                    ),
                    onPressed: () => setState(() => _viewMode = 1),
                    child: Text('PLACED (${widget.state.furniture.length})', style: const TextStyle(fontFamily: AppConstants.pixelFont, fontSize: 10, color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),

          // Categories Filter (if in Shop mode)
          if (_viewMode == 0)
            Container(
              height: 32,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: ['all', 'pc', 'bed', 'kitchen', 'decor'].map((cat) {
                  final isSelected = _selectedCategory == cat;
                  return Padding(
                    padding: const EdgeInsets.only(right: 6, top: 4, bottom: 4),
                    child: ChoiceChip(
                      label: Text(
                        cat.toUpperCase(),
                        style: TextStyle(
                          fontFamily: AppConstants.pixelFont,
                          fontSize: 9,
                          color: isSelected ? Colors.white : Colors.white70,
                        ),
                      ),
                      selected: isSelected,
                      selectedColor: AppConstants.energyBlue,
                      backgroundColor: const Color(0xFF233458),
                      onSelected: (_) => setState(() => _selectedCategory = cat),
                    ),
                  );
                }).toList(),
              ),
            ),

          // Main List View (Catalog or Placed)
          Expanded(
            child: _viewMode == 0
                ? ListView.builder(
                    padding: const EdgeInsets.all(10),
                    itemCount: filtered.length,
                    itemBuilder: (context, idx) {
                      final item = filtered[idx];
                      final isUnlocked = widget.state.fame >= item.fameReq;
                      final isNew = isUnlocked && widget.state.fame < item.fameReq + 100;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isUnlocked ? const Color(0xFF233458) : const Color(0xFF1A2640),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: AppConstants.darkNavy, width: 1.5),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: AppConstants.darkNavy,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Icon(
                                isUnlocked ? Icons.inventory_2 : Icons.lock,
                                color: isUnlocked ? AppConstants.moneyGold : Colors.white38,
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 8),

                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        item.name,
                                        style: TextStyle(
                                          fontFamily: AppConstants.pixelFont,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: isUnlocked ? Colors.white : Colors.white38,
                                        ),
                                      ),
                                      if (isNew) ...[
                                        const SizedBox(width: 4),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
                                          decoration: BoxDecoration(color: AppConstants.negativeRed, borderRadius: BorderRadius.circular(2)),
                                          child: const Text('NEW!', style: TextStyle(fontFamily: AppConstants.pixelFont, fontSize: 7, color: Colors.white, fontWeight: FontWeight.bold)),
                                        ),
                                      ],
                                    ],
                                  ),
                                  Text(
                                    isUnlocked ? '${item.desc} | P${item.price}' : 'Kailangan ng ${item.fameReq} Fame',
                                    style: TextStyle(
                                      fontFamily: AppConstants.pixelFont,
                                      fontSize: 9,
                                      color: isUnlocked ? AppConstants.moneyGold : Colors.white38,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isUnlocked ? AppConstants.positiveGreen : Colors.grey.shade800,
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                minimumSize: const Size(54, 28),
                              ),
                              onPressed: isUnlocked
                                  ? () => _buyItem(item.id, item.name, item.price, item.station, item.sizeX, item.sizeY)
                                  : null,
                              child: Text(
                                isUnlocked ? 'BUY' : 'LOCKED',
                                style: const TextStyle(fontFamily: AppConstants.pixelFont, fontSize: 9, color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  )
                : widget.state.furniture.isEmpty
                    ? const Center(
                        child: Text(
                          'Walang nakalagay na gamit.',
                          style: TextStyle(fontFamily: AppConstants.pixelFont, color: Colors.white54, fontSize: 11),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(10),
                        itemCount: widget.state.furniture.length,
                        itemBuilder: (context, idx) {
                          final f = widget.state.furniture[idx];
                          final item = DataService().findItem(f.itemId);
                          final originalPrice = item?.price ?? 5000;
                          final refund = (originalPrice * 0.70).round();

                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF233458),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: AppConstants.darkNavy, width: 1.5),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.chair, color: AppConstants.energyBlue, size: 24),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(f.name, style: const TextStyle(fontFamily: AppConstants.pixelFont, fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)),
                                      Text('Tile: (${f.tileX}, ${f.tileY}) | Station: ${f.station}', style: const TextStyle(fontFamily: AppConstants.pixelFont, fontSize: 8, color: Colors.white60)),
                                    ],
                                  ),
                                ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppConstants.negativeRed,
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    minimumSize: const Size(54, 28),
                                  ),
                                  onPressed: () => _sellFurniture(f),
                                  child: Text('SELL P$refund', style: const TextStyle(fontFamily: AppConstants.pixelFont, fontSize: 8, color: Colors.white)),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
