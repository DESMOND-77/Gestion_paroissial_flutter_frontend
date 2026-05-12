import 'dart:async';
import 'package:flutter/material.dart';

class AutoScrollingText extends StatefulWidget {
  final Widget child;
  final Duration scrollDuration;
  final Duration pauseDuration;

  const AutoScrollingText({
    super.key,
    required this.child,
    this.scrollDuration = const Duration(seconds: 5),
    this.pauseDuration = const Duration(seconds: 1),
  });

  @override
  State<AutoScrollingText> createState() => _AutoScrollingTextState();
}

class _AutoScrollingTextState extends State<AutoScrollingText> {
  final ScrollController _controller = ScrollController();
  bool _scrollingForward = true;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _startScrolling());
  }

  void _startScrolling() async {
    if (!_controller.hasClients) return;

    final maxScroll = _controller.position.maxScrollExtent;
    if (maxScroll <= 0) return; // Ne scroll pas si inutile

    while (mounted) {
      final target = _scrollingForward ? maxScroll : 0;

      await _controller.animateTo(
        target.toDouble(),
        duration: widget.scrollDuration,
        curve: Curves.linear,
      );

      await Future.delayed(widget.pauseDuration);

      _scrollingForward = !_scrollingForward;
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: _controller,
      scrollDirection: Axis.horizontal,
      physics: const NeverScrollableScrollPhysics(),
      child: widget.child,
    );
  }
}
