import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/constants.dart';

class NewsTicker extends StatefulWidget {
  final List<String> newsItems;

  const NewsTicker({
    super.key,
    required this.newsItems,
  });

  @override
  State<NewsTicker> createState() => _NewsTickerState();
}

class _NewsTickerState extends State<NewsTicker> {
  int _currentIndex = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 6), (_) {
      if (widget.newsItems.isNotEmpty && mounted) {
        setState(() {
          _currentIndex = (_currentIndex + 1) % widget.newsItems.length;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final text = widget.newsItems.isNotEmpty
        ? widget.newsItems[_currentIndex]
        : 'Maligayang pagdating sa Arena Clash!';

    return Container(
      height: 30,
      decoration: const BoxDecoration(
        color: Color(0xFF131D33),
        border: Border(
          bottom: BorderSide(color: Color(0xFF1E293B), width: 1),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFFEF4444),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: const Color(0xFFB91C1C), width: 1),
            ),
            child: const Text(
              'BALITA',
              style: TextStyle(
                fontFamily: AppConstants.pixelFont,
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 350),
              transitionBuilder: (child, animation) {
                return SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0.0, 0.8),
                    end: Offset.zero,
                  ).animate(animation),
                  child: FadeTransition(opacity: animation, child: child),
                );
              },
              child: Text(
                text,
                key: ValueKey<int>(_currentIndex),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: AppConstants.pixelFont,
                  color: Color(0xFFF1F5F9),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
