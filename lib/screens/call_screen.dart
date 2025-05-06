import 'dart:async';
import 'package:flutter/material.dart';

class CallScreen extends StatefulWidget {
  final String callerName;
  final String callerImageUrl;

  const CallScreen({
    super.key,
    required this.callerName,
    required this.callerImageUrl,
  });

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> with TickerProviderStateMixin {
  double _dragOffset = 0.0;
  bool _callAccepted = false;
  late AnimationController _capsuleController;
  late AnimationController _dragController;
  late Animation<double> _dragAnimation;
  Timer? _idleTimer;
  double _idleOffset = 10.0;
  bool _isAnimating = false;

  @override
  void initState() {
    super.initState();

    _capsuleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _dragController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _dragAnimation = Tween<double>(begin: 0.0, end: 0.0).animate(
      CurvedAnimation(parent: _dragController, curve: Curves.easeOut),
    );

    _dragController.addListener(() {
      setState(() {
        _dragOffset = _dragAnimation.value;
      });
    });

    _startIdleAnimation();
  }

  void _startIdleAnimation() {
    _idleTimer = Timer.periodic(const Duration(seconds: 2), (timer) async {
      if (_callAccepted || _dragOffset > 0) return;

      if (mounted) {
        setState(() {
          _isAnimating = true;
          _idleOffset = 180; // move to the end of the capsule
        });

        await Future.delayed(const Duration(milliseconds: 500));

        if (!mounted || _callAccepted) return;

        setState(() {
          _idleOffset = 10; // return to start
        });

        await Future.delayed(const Duration(milliseconds: 500));

        if (mounted) {
          setState(() => _isAnimating = false);
        }
      }
    });
  }

  @override
  void dispose() {
    _capsuleController.dispose();
    _dragController.dispose();
    _idleTimer?.cancel();
    super.dispose();
  }

  void _onHorizontalDragUpdate(DragUpdateDetails details) {
    if (_callAccepted) return;

    setState(() {
      _dragOffset += details.primaryDelta!;
      if (_dragOffset > 180) _dragOffset = 180; // Cap the drag offset to the capsule width
      if (_dragOffset < 0) _dragOffset = 0;
    });
  }

  void _onHorizontalDragEnd(DragEndDetails details) {
    if (_dragOffset > 140) {
      // Accept the call
      _capsuleController.forward();
      _idleTimer?.cancel(); // stop idle animation
      setState(() {
        _callAccepted = true;
      });
    } else {
      // Animate the green button back to the start
      _dragAnimation = Tween<double>(begin: _dragOffset, end: 0.0).animate(
        CurvedAnimation(parent: _dragController, curve: Curves.easeOut),
      );
      _dragController.forward(from: 0.0);
    }
  }

  void _endCall() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final capsuleWidth = Tween<double>(begin: 300, end: 70).animate(_capsuleController);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(flex: 2),

            // Profile and call status
            Column(
              children: [
                Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.blueAccent.withOpacity(0.2),
                  ),
                  child: CircleAvatar(
                    radius: 60,
                    backgroundImage: NetworkImage(widget.callerImageUrl),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  widget.callerName,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  _callAccepted ? "Call in Progress..." : "Incoming Call...",
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 18,
                  ),
                ),
              ],
            ),

            const Spacer(flex: 3),

            // Capsule button
            AnimatedBuilder(
              animation: _capsuleController,
              builder: (context, child) {
                // Calculate the effective offset for the green button
                final effectiveOffset = (_dragOffset / 180) * (capsuleWidth.value - 70);

                // Calculate dynamic size and brightness for the green button
                final buttonSize = 70 + (_dragOffset / 180) * 30; // Size increases up to 100
                final buttonColor = Color.lerp(Colors.green, Colors.red, _dragOffset / 180)!;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 20), // Move the capsule lower
                  child: Center(
                    child: GestureDetector(
                      onHorizontalDragUpdate: _onHorizontalDragUpdate,
                      onHorizontalDragEnd: _onHorizontalDragEnd,
                      onTap: _callAccepted ? _endCall : null,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: _callAccepted ? 70 : capsuleWidth.value,
                        height: 70,
                        decoration: BoxDecoration(
                          color: _callAccepted ? Colors.red : Colors.grey[200],
                          borderRadius: BorderRadius.circular(_callAccepted ? 35 : 50),
                        ),
                        child: Stack(
                          alignment: Alignment.centerLeft,
                          children: [
                            if (!_callAccepted)
                              Positioned(
                                left: effectiveOffset.toDouble(),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  width: buttonSize, // Dynamic size
                                  height: buttonSize, // Dynamic size
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: buttonColor, // Dynamic color
                                  ),
                                  child: const Icon(Icons.call, color: Colors.white),
                                ),
                              ),
                            if (_callAccepted)
                              const Center(
                                child: Icon(Icons.call_end, color: Colors.white),
                              ),
                            if (!_callAccepted)
                              Positioned.fill(
                                child: Align(
                                  alignment: Alignment.centerRight,
                                  child: AnimatedOpacity(
                                    opacity: 1 - (_dragOffset / 100).clamp(0.0, 1.0),
                                    duration: const Duration(milliseconds: 200),
                                    child: const Padding(
                                      padding: EdgeInsets.only(right: 20.0),
                                      child: Text(
                                        "Swipe right to accept call",
                                        style: TextStyle(color: Colors.black),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 10),

            // "End Call" button (only visible before accepting)
            if (!_callAccepted)
              Padding(
                padding: const EdgeInsets.only(bottom: 1), // Move the end button lower
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  icon: const Icon(Icons.call_end, color: Colors.white),
                  label: const Text("End Call", style: TextStyle(color: Colors.white)),
                  onPressed: _endCall,
                ),
              ),

            const Spacer(flex: 1),
          ],
        ),
      ),
    );
  }
}