import 'package:desktop_lyric/component/foreground.dart';
import 'package:desktop_lyric/message.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';

const WHITE_TRANSPARENT = Color.fromARGB(0, 255, 255, 255);
const BLACK_TRANSPARENT = Color.fromARGB(0, 0, 0, 0);
final ValueNotifier<double> BACKGROUND_OPACITY = ValueNotifier(0);

class DesktopLyricBody extends StatefulWidget {
  const DesktopLyricBody({super.key});

  @override
  State<DesktopLyricBody> createState() => _DesktopLyricBodyState();
}

class _DesktopLyricBodyState extends State<DesktopLyricBody> {
  bool isHovering = false;

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeChangedMessage>();

    return ValueListenableBuilder(
        valueListenable: BACKGROUND_OPACITY,
        builder: (context, opacity, _) {
          final background = Color(theme.surfaceContainer).withOpacity(opacity);
          return TweenAnimationBuilder(
            duration: const Duration(milliseconds: 300),
            tween: isHovering
                ? ColorTween(
                    begin: background,
                    end: Color(theme.surfaceContainer),
                  )
                : ColorTween(
                    begin: Color(theme.surfaceContainer),
                    end: background,
                  ),
            builder: (context, value, child) => ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Scaffold(backgroundColor: value, body: child),
            ),
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onPanStart: (details) {
                windowManager.startDragging();
              },
              child: MouseRegion(
                onEnter: (_) {
                  setState(() {
                    isHovering = true;
                  });
                },
                onExit: (_) {
                  setState(() {
                    isHovering = false;
                  });
                },
                child: Center(
                    child: DesktopLyricForeground(isHovering: isHovering)),
              ),
            ),
          );
        });
  }
}
