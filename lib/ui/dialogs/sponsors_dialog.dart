import 'package:flutter/material.dart';
import '../../core/constants.dart';
import '../../models/game_state.dart';
import '../../models/sponsor.dart';
import '../../services/sponsor_service.dart';
import '../../services/achievement_service.dart';
import '../widgets/pixel_panel.dart';
import '../widgets/pixel_button.dart';

class SponsorsDialog extends StatefulWidget {
  final GameState state;
  final VoidCallback onUpdated;

  const SponsorsDialog({
    super.key,
    required this.state,
    required this.onUpdated,
  });

  @override
  State<SponsorsDialog> createState() => _SponsorsDialogState();
}

class _SponsorsDialogState extends State<SponsorsDialog> {
  int _tabIndex = 0; // 0 = Active Deals, 1 = Available Deals

  @override
  Widget build(BuildContext context) {
    final active = widget.state.activeSponsors;
    final offers = SponsorService().getAvailableOffers(widget.state);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 20),
      child: PixelPanel(
        title: 'MGA SPONSOR',
        onClose: () => Navigator.pop(context),
        child: SizedBox(
          height: 480,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Slots & Manager info
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Slots: ${active.length} / ${widget.state.maxSponsorSlots}',
                    style: const TextStyle(
                      fontFamily: AppConstants.pixelFont,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppConstants.textNavy,
                    ),
                  ),
                  if (widget.state.manager != null)
                    Text(
                      'Manager Bonus: +${widget.state.manager!.level * 8}% Pay',
                      style: const TextStyle(
                        fontFamily: AppConstants.pixelFont,
                        fontSize: 10,
                        color: AppConstants.positiveGreen,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),

              // Segmented Bar
              Row(
                children: [
                  Expanded(
                    child: _buildTabButton(0, 'Active (${active.length})'),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildTabButton(1, 'Offers (${offers.length})'),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Content List
              Expanded(
                child: _tabIndex == 0
                    ? _buildActiveList(active)
                    : _buildOffersList(offers),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getSponsorLogo(String id) {
    final lower = id.toLowerCase();
    if (lower.contains('silog') || lower.contains('bertos')) return 'assets/images/emblems/sponsor_silog.png';
    if (lower.contains('tindanet')) return 'assets/images/emblems/sponsor_tindanet.png';
    if (lower.contains('voltedge')) return 'assets/images/emblems/sponsor_voltedge.png';
    if (lower.contains('kapeko')) return 'assets/images/emblems/sponsor_kapeko.png';
    if (lower.contains('byteburger')) return 'assets/images/emblems/sponsor_byteburger.png';
    if (lower.contains('lakas')) return 'assets/images/emblems/sponsor_lakas.png';
    if (lower.contains('gising')) return 'assets/images/emblems/sponsor_gising.png';
    if (lower.contains('sulit')) return 'assets/images/emblems/sponsor_sulit.png';
    if (lower.contains('kuryente')) return 'assets/images/emblems/sponsor_kuryente.png';
    if (lower.contains('pixelpinoy')) return 'assets/images/emblems/sponsor_pixelpinoy.png';
    if (lower.contains('bayanihan')) return 'assets/images/emblems/sponsor_bayanihan.png';
    if (lower.contains('skylink')) return 'assets/images/emblems/sponsor_skylink.png';
    return 'assets/images/branding/app_icon.png';
  }

  Widget _buildTabButton(int index, String title) {
    final isSelected = _tabIndex == index;
    return InkWell(
      onTap: () => setState(() => _tabIndex = index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppConstants.textNavy : Colors.white,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: AppConstants.darkNavy, width: 2),
        ),
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              fontFamily: AppConstants.pixelFont,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.white : AppConstants.textNavy,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActiveList(List<ActiveSponsor> active) {
    if (active.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Wala pang active sponsors.',
              style: TextStyle(fontFamily: AppConstants.pixelFont, fontSize: 12, color: Colors.black54),
            ),
            const SizedBox(height: 8),
            PixelButton(
              label: 'MAG-APPLY SA OFFERS',
              color: PixelButtonColor.green,
              fontSize: 10,
              onPressed: () => setState(() => _tabIndex = 1),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: active.length,
      itemBuilder: (context, idx) {
        final sp = active[idx];
        final progressFrac = (sp.goalProgress / sp.goalTarget).clamp(0.0, 1.0);

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: const Color(0xFFD0D7DE), width: 1.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(
                    _getSponsorLogo(sp.id),
                    width: 32,
                    height: 32,
                    fit: BoxFit.contain,
                    filterQuality: FilterQuality.none,
                    errorBuilder: (_, _, _) => const Icon(Icons.business, size: 24, color: AppConstants.textNavy),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      sp.name,
                      style: const TextStyle(
                        fontFamily: AppConstants.pixelFont,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppConstants.textNavy,
                      ),
                    ),
                  ),
                  Text(
                    '${sp.weeksRemaining} wks left',
                    style: TextStyle(
                      fontFamily: AppConstants.pixelFont,
                      fontSize: 10,
                      color: sp.weeksRemaining <= 3 ? AppConstants.negativeRed : Colors.black54,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Weekly: +P${sp.weeklyPay} | Bonus: +P${sp.bonusPay}',
                style: const TextStyle(
                  fontFamily: AppConstants.pixelFont,
                  fontSize: 10,
                  color: AppConstants.positiveGreen,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                sp.goalDescription,
                style: const TextStyle(fontFamily: AppConstants.pixelFont, fontSize: 10, color: Colors.black87),
              ),
              const SizedBox(height: 4),
              LinearProgressIndicator(
                value: progressFrac,
                minHeight: 6,
                backgroundColor: Colors.grey.shade200,
                color: sp.isCompleted ? AppConstants.positiveGreen : AppConstants.energyBlue,
              ),
              if (sp.isCompleted && !sp.isBonusClaimed) ...[
                const SizedBox(height: 8),
                PixelButton(
                  label: 'CLAIM BONUS (+P${sp.bonusPay})',
                  color: PixelButtonColor.yellow,
                  fontSize: 10,
                  height: 32,
                  onPressed: () {
                    SponsorService().claimBonus(sp, widget.state);
                    AchievementService().checkMilestones(widget.state);
                    widget.onUpdated();
                    setState(() {});
                  },
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildOffersList(List<SponsorDef> offers) {
    if (offers.isEmpty) {
      return const Center(
        child: Text(
          'Walang available offers sa ngayon.\nTaasan ang Fame upang maakit ang mga sponsor!',
          textAlign: TextAlign.center,
          style: TextStyle(fontFamily: AppConstants.pixelFont, fontSize: 11, color: Colors.black54),
        ),
      );
    }

    final hasFreeSlots = widget.state.activeSponsors.length < widget.state.maxSponsorSlots;

    return ListView.builder(
      itemCount: offers.length,
      itemBuilder: (context, idx) {
        final def = offers[idx];

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: const Color(0xFFD0D7DE), width: 1.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(
                    _getSponsorLogo(def.id),
                    width: 32,
                    height: 32,
                    fit: BoxFit.contain,
                    filterQuality: FilterQuality.none,
                    errorBuilder: (_, _, _) => const Icon(Icons.business, size: 24, color: AppConstants.textNavy),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      def.name,
                      style: const TextStyle(
                        fontFamily: AppConstants.pixelFont,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppConstants.textNavy,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppConstants.moneyGold.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'T${def.tier}',
                      style: const TextStyle(fontFamily: AppConstants.pixelFont, fontSize: 9, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                def.desc,
                style: const TextStyle(fontFamily: AppConstants.pixelFont, fontSize: 9, color: Colors.black54),
              ),
              const SizedBox(height: 4),
              Text(
                'Sahod: P${def.weeklyPay}/wk | Bonus: P${def.bonusPay} (${def.durationWeeks} weeks)',
                style: const TextStyle(
                  fontFamily: AppConstants.pixelFont,
                  fontSize: 10,
                  color: AppConstants.positiveGreen,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Layunin: ${def.goalTitle}',
                style: const TextStyle(fontFamily: AppConstants.pixelFont, fontSize: 10, color: Colors.black87),
              ),
              const SizedBox(height: 8),
              PixelButton(
                label: hasFreeSlots ? 'PIRMAHAN ANG KONTRATA' : 'PUNO NA ANG SLOTS',
                color: hasFreeSlots ? PixelButtonColor.green : PixelButtonColor.red,
                fontSize: 10,
                height: 32,
                onPressed: hasFreeSlots
                    ? () {
                        SponsorService().signSponsor(def, widget.state);
                        AchievementService().checkMilestones(widget.state);
                        widget.onUpdated();
                        setState(() {
                          _tabIndex = 0; // Switch to active tab
                        });
                      }
                    : null,
              ),
            ],
          ),
        );
      },
    );
  }
}
