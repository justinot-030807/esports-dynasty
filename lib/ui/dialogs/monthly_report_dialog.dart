import 'package:flutter/material.dart';
import '../../core/constants.dart';
import '../../models/finance_record.dart';
import '../widgets/pixel_panel.dart';

class MonthlyReportDialog extends StatelessWidget {
  final MonthlyFinanceReport report;

  const MonthlyReportDialog({
    super.key,
    required this.report,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: PixelPanel(
        title: 'MONTHLY REPORT (M${report.month})',
        width: 320,
        onClose: () => Navigator.of(context).pop(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Income vs Expenses
            _buildRow('Total Income:', '+P${report.totalIncome}', AppConstants.positiveGreen),
            _buildRow('Player Salaries:', '-P${report.playerSalariesPaid}', AppConstants.negativeRed),
            _buildRow('Staff Salaries:', '-P${report.staffSalariesPaid}', AppConstants.negativeRed),
            _buildRow('House Rent:', '-P${report.rentPaid}', AppConstants.negativeRed),
            const Divider(color: Color(0xFFCBD5E0), height: 14),

            _buildRow(
              'Net Profit / Loss:',
              '${report.netProfit >= 0 ? "+" : ""}P${report.netProfit}',
              report.netProfit >= 0 ? AppConstants.positiveGreen : AppConstants.negativeRed,
              isBold: true,
            ),
            const SizedBox(height: 6),

            _buildRow('Fans Growth:', '+${report.fansGained} Fans', AppConstants.fansPink),
            _buildRow('Fame Earned:', '+${report.fameGained} Fame', AppConstants.famePurple),

            const SizedBox(height: 12),

            // Manang Mika Advice Speech Bubble
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppConstants.darkNavy, width: 1.5),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.support_agent, size: 28, color: AppConstants.darkNavy),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Payo ni Manang Mika:',
                          style: TextStyle(
                            fontFamily: AppConstants.pixelFont,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                            color: AppConstants.darkNavy,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          report.mikaTip,
                          style: const TextStyle(
                            fontFamily: AppConstants.pixelFont,
                            fontSize: 10,
                            color: AppConstants.darkNavy,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppConstants.positiveGreen),
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('TULOY ANG ENSAYO!', style: TextStyle(fontFamily: AppConstants.pixelFont, color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(String label, String value, Color valColor, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontFamily: AppConstants.pixelFont,
              fontSize: 11,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: AppConstants.darkNavy,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontFamily: AppConstants.pixelFont,
              fontSize: 11,
              fontWeight: isBold ? FontWeight.bold : FontWeight.bold,
              color: valColor,
            ),
          ),
        ],
      ),
    );
  }
}
