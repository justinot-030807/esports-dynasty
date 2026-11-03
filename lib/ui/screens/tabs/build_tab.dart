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

  String _getItemImagePath(String id) {
    if (id.startsWith('gadget_')) return 'assets/images/items/$id.png';
    return 'assets/images/furniture/$id.png';
  }

  void _buyItem(String itemId, String name, int price, String station, int sx, int sy) {
    if (widget.state.money < price) {
      _showMessage('Kulang ang pera! Kailangan ng P$price.');
      return;
    }

    setState(() {
      widget.state.money -= price;
      final nextTileX = (widget.state.furniture.length % 5) + 1;
      final nextTileY = ((widget.state.furniture.length ~/ 5) % 4) + 2;

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

      widget.state.addNotification('+$name', '#22C55E', 0.5, 0.4);

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
        content: Text(msg, style: const TextStyle(fontFamily: AppConstants.pixelFont, fontSize: 13)),
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
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: const BoxDecoration(
              color: Color(0xFF1E293B),
              border: Border(bottom: BorderSide(color: Color(0xFF334155), width: 1.5)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Text('Comfort: ', style: TextStyle(fontFamily: AppConstants.pixelFont, fontSize: 13, color: Color(0xFFCBD5E1), fontWeight: FontWeight.bold)),
                    for (int i = 0; i < widget.state.comfortRating; i++)
                      const Icon(Icons.star, size: 16, color: AppConstants.moneyGold),
                  ],
                ),
                Row(
                  children: [
                    if (widget.state.hasScrimRoomCombo)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(color: AppConstants.positiveGreen, borderRadius: BorderRadius.circular(4)),
                        child: const Text('COMBO: Scrim Room', style: TextStyle(fontFamily: AppConstants.pixelFont, fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    if (widget.state.hasKainanCombo) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(color: AppConstants.fansPink, borderRadius: BorderRadius.circular(4)),
                        child: const Text('COMBO: Kainan', style: TextStyle(fontFamily: AppConstants.pixelFont, fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),

          // Catalog vs Placed Mode Toggle
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            color: const Color(0xFFF1F5F9),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _viewMode == 0 ? const Color(0xFF0284C7) : const Color(0xFFE2E8F0),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                        side: BorderSide(color: _viewMode == 0 ? AppConstants.moneyGold : const Color(0xFFCBD5E1), width: 1.5),
                      ),
                    ),
                    onPressed: () => setState(() => _viewMode = 0),
                    child: Text('SHOP CATALOG', style: TextStyle(fontFamily: AppConstants.pixelFont, fontSize: 12, fontWeight: FontWeight.bold, color: _viewMode == 0 ? Colors.white : const Color(0xFF334155))),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _viewMode == 1 ? const Color(0xFF0284C7) : const Color(0xFFE2E8F0),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                        side: BorderSide(color: _viewMode == 1 ? AppConstants.moneyGold : const Color(0xFFCBD5E1), width: 1.5),
                      ),
                    ),
                    onPressed: () => setState(() => _viewMode = 1),
                    child: Text('PLACED (${widget.state.furniture.length})', style: TextStyle(fontFamily: AppConstants.pixelFont, fontSize: 12, fontWeight: FontWeight.bold, color: _viewMode == 1 ? Colors.white : const Color(0xFF334155))),
                  ),
                ),
              ],
            ),
          ),

          // Categories Filter
          if (_viewMode == 0)
            Container(
              height: 38,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              color: const Color(0xFFF8FAFC),
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: ['all', 'pc', 'chair', 'bed', 'kitchen', 'decor', 'gadget', 'utility'].map((cat) {
                  final isSelected = _selectedCategory == cat;
                  return Padding(
                    padding: const EdgeInsets.only(right: 6, top: 4, bottom: 4),
                    child: ChoiceChip(
                      label: Text(
                        cat.toUpperCase(),
                        style: TextStyle(
                          fontFamily: AppConstants.pixelFont,
                          fontSize: 11,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected ? Colors.white : const Color(0xFF334155),
                        ),
                      ),
                      selected: isSelected,
                      selectedColor: const Color(0xFF0284C7),
                      backgroundColor: const Color(0xFFE2E8F0),
                      onSelected: (_) => setState(() => _selectedCategory = cat),
                    ),
                  );
                }).toList(),
              ),
            ),

          // Main List View
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
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isUnlocked ? Colors.white : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isUnlocked ? const Color(0xFFCBD5E1) : const Color(0xFFE2E8F0),
                            width: 1.5,
                          ),
                          boxShadow: const [
                            BoxShadow(color: Color(0x0A000000), offset: Offset(0, 1), blurRadius: 3),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              padding: const EdgeInsets.all(3),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: const Color(0xFFCBD5E1), width: 1),
                              ),
                              child: isUnlocked
                                  ? Image.asset(
                                      _getItemImagePath(item.id),
                                      fit: BoxFit.contain,
                                      filterQuality: FilterQuality.none,
                                      errorBuilder: (_, _, _) => const Icon(Icons.inventory_2, color: AppConstants.moneyGold, size: 22),
                                    )
                                  : Image.asset(
                                      'assets/images/icons/ui_lock.png',
                                      fit: BoxFit.contain,
                                      filterQuality: FilterQuality.none,
                                      errorBuilder: (_, _, _) => const Icon(Icons.lock, color: Color(0xFF94A3B8), size: 22),
                                    ),
                            ),
                            const SizedBox(width: 12),

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
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          color: isUnlocked ? const Color(0xFF0F172A) : const Color(0xFF94A3B8),
                                        ),
                                      ),
                                      if (isNew) ...[
                                        const SizedBox(width: 6),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                          decoration: BoxDecoration(color: AppConstants.negativeRed, borderRadius: BorderRadius.circular(3)),
                                          child: const Text('NEW!', style: TextStyle(fontFamily: AppConstants.pixelFont, fontSize: 9, color: Colors.white, fontWeight: FontWeight.bold)),
                                        ),
                                      ],
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    isUnlocked ? '${item.desc} | P${item.price}' : 'Kailangan ng ${item.fameReq} Fame',
                                    style: TextStyle(
                                      fontFamily: AppConstants.bodyFont,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: isUnlocked ? const Color(0xFFD97706) : const Color(0xFF94A3B8),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isUnlocked ? AppConstants.positiveGreen : const Color(0xFF334155),
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                              ),
                              onPressed: isUnlocked
                                  ? () => _buyItem(item.id, item.name, item.price, item.station, item.sizeX, item.sizeY)
                                  : null,
                              child: Text(
                                isUnlocked ? 'BUY' : 'LOCKED',
                                style: const TextStyle(fontFamily: AppConstants.pixelFont, fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
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
                          style: TextStyle(fontFamily: AppConstants.pixelFont, color: Color(0xFF94A3B8), fontSize: 13),
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
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E293B),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: const Color(0xFF334155), width: 1.5),
                            ),
                            child: Row(
                              children: [
                                Image.asset(
                                  _getItemImagePath(f.itemId),
                                  width: 34,
                                  height: 34,
                                  fit: BoxFit.contain,
                                  filterQuality: FilterQuality.none,
                                  errorBuilder: (_, _, _) => const Icon(Icons.chair, color: AppConstants.energyBlue, size: 28),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(f.name, style: const TextStyle(fontFamily: AppConstants.pixelFont, fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
                                      Text('Tile: (${f.tileX}, ${f.tileY}) | Station: ${f.station}', style: const TextStyle(fontFamily: AppConstants.pixelFont, fontSize: 11, color: Color(0xFF94A3B8))),
                                    ],
                                  ),
                                ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppConstants.negativeRed,
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                                  ),
                                  onPressed: () => _sellFurniture(f),
                                  child: Text('SELL P$refund', style: const TextStyle(fontFamily: AppConstants.pixelFont, fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)),
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
