import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tutorial_overlay/tutorial.dart';
import 'package:tutorial_overlay/tutorial_step.dart';

/// Wrap your initial screen with this widget to enable tutorial functionality.
///
/// Works with [Tutorial] controller to render tooltips and indicators (e.g., arrows, circles)
/// for a tutorial identified by [tutorialId].
///
/// {@tool snippet}
/// ```dart
/// TutorialOverlay<String>(
///   tutorialId: 'home',
///   width: 320,
///   child: const MyHomePage(),
/// )
/// ```
/// {@end-tool}
class TutorialOverlay<T> extends StatefulWidget {
  /// The screen content to display under the tutorial overlay.
  ///
  /// This required widget represents the main UI of the screen (e.g., a [Scaffold])
  /// where the tutorial starts. It typically contains widgets with [GlobalKey]s for
  /// targeting.
  final Widget child;

  /// Unique ID matching the tutorial in [Tutorial] controller
  ///
  /// Use the same ID for multi-step tutorials a single overlay,
  /// or different IDs for different tutorials.
  final T tutorialId;

  /// Width of tooltip container. (Required)
  final double width;

  /// Optional height of tooltip container.
  ///
  /// If null, the tooltip height is determined by its content.
  final double? height;

  /// Optional decoration of tooltip container.
  final Decoration? decoration;

  /// Optional padding of tooltip container.
  ///
  /// Adds padding inside the tooltip container to space its content.
  final EdgeInsetsGeometry? padding;

  /// Whether the tutorial ends when tapping outside the tooltip. (default: true)
  final bool dismissOnTap;

  /// Default custom widget that points to the target. (e.g. arrow)
  ///
  /// Used when [TutorialStep.indicator] isn't specified.
  /// Requires [indicatorHeight] and [indicatorWidth] for correct positioning.
  ///
  /// {@tool snippet}
  /// ```dart
  /// indicator: Icon(Icons.arrow_downward, size: 24),
  /// indicatorHeight: 24,
  /// indicatorWidth: 24,
  /// ```
  /// {@end-tool}
  final Widget? indicator;

  /// Default height of [indicator].
  ///
  /// Overridden by [TutorialStep.indicatorHeight] if specified.
  /// Required when [indicator] is set.
  final double? indicatorHeight;

  /// Default width of [indicator].
  ///
  /// Overridden by [TutorialStep.indicatorWidth] if specified.
  /// Required when [indicator] is set.
  final double? indicatorWidth;

  /// Color of the overlay covering the area outside the target widget. (default: Colors.black54)
  final Color overlayColor;

  /// Corner radius of highlighted area around the target widget. (default: 4)
  final double radius;

  /// Padding of highlight area around the target widget.
  ///
  /// Adds space around the highlighted widget to expand the focus area.
  final EdgeInsets? focusOverlayPadding;

  const TutorialOverlay({
    super.key,
    required this.child,
    required this.tutorialId,
    required this.width,
    this.height,
    this.decoration,
    this.padding,
    this.dismissOnTap = true,
    this.indicator,
    this.indicatorHeight,
    this.indicatorWidth,
    this.overlayColor = Colors.black54,
    this.radius = 4,
    this.focusOverlayPadding,
  });

  @override
  State<TutorialOverlay> createState() => _TutorialOverlayState();
}

class _TutorialOverlayState extends State<TutorialOverlay> {
  OverlayEntry? _overlayEntry;
  late double _kTutorialWidth;

  @override
  void initState() {
    super.initState();
    _kTutorialWidth = widget.width;
    final tutorialState = Provider.of<Tutorial>(context, listen: false);
    tutorialState.addListener(() {
      if (mounted) {
        _updateOverlay(
          context,
          tutorialState.getCurrentStep(widget.tutorialId),
        );
      }
    });
  }

  void _updateOverlay(BuildContext context, int step) {
    _removeOverlay();

    final tutorialState = Provider.of<Tutorial>(context, listen: false);
    final steps = tutorialState.getSteps(widget.tutorialId);

    if (step < 0 || steps.isEmpty || step >= steps.length) return;

    final TutorialStep currentStep = steps[step];
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_overlayEntry != null) return;

      if (currentStep.widgetKey != null) {
        final RenderBox? renderBox =
            currentStep.widgetKey!.currentContext?.findRenderObject()
                as RenderBox?;
        if (renderBox == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _updateOverlay(context, step);
          });
          return;
        }

        _overlayEntry = _createOverlayEntry(renderBox, currentStep);
      } else {
        _overlayEntry = _createOverlayEntryWithoutTarget(currentStep);
      }

      Overlay.of(context).insert(_overlayEntry!);
    });
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }

  @override
  void dispose() {
    _removeOverlay();
    super.dispose();
  }

  OverlayEntry _createOverlayEntry(RenderBox renderBox, TutorialStep step) {
    final Size targetSize = renderBox.size;
    final Offset targetPosition = renderBox.localToGlobal(Offset.zero);
    final padding = step.focusOverlayPadding ?? widget.focusOverlayPadding;

    final indicator = step.indicator ?? widget.indicator;
    final indicatorHeight = step.indicatorHeight ?? widget.indicatorHeight ?? 0;
    final indicatorWidth = step.indicatorWidth ?? widget.indicatorWidth ?? 0;

    bool showAbove;
    if (step.showAbove != null) {
      showAbove = step.showAbove!;
    } else {
      final spaceAbove = targetPosition.dy;
      final spaceBelow =
          MediaQuery.sizeOf(context).height -
          (targetPosition.dy + targetSize.height);
      showAbove = spaceAbove > spaceBelow;
    }

    return OverlayEntry(
      builder: (BuildContext context) {
        return Stack(
          children: [
            GestureDetector(
              onTap: () {
                if (widget.dismissOnTap) {
                  Provider.of<Tutorial>(
                    context,
                    listen: false,
                  ).endTutorial(widget.tutorialId);
                }
              },
              child: FocusOverlay(
                highlightRect: Rect.fromLTWH(
                  targetPosition.dx - (padding?.left ?? 0),
                  targetPosition.dy - (padding?.top ?? 0),
                  targetSize.width +
                      (padding?.left ?? 0) +
                      (padding?.right ?? 0),
                  targetSize.height +
                      (padding?.top ?? 0) +
                      (padding?.bottom ?? 0),
                ),
                color: widget.overlayColor,
                radius: widget.radius,
              ),
            ),
            Positioned(
              top:
                  showAbove
                      ? (targetPosition.dy -
                          indicatorHeight -
                          (padding?.top ?? 0))
                      : (targetPosition.dy +
                          (padding?.bottom ?? 0) +
                          targetSize.height),
              left:
                  targetPosition.dx + targetSize.width / 2 - indicatorWidth / 2,
              child: SizedBox(
                width: indicatorWidth,
                height: indicatorHeight,
                child: Transform.scale(
                  scaleY: showAbove ? 1 : -1,
                  child: indicator,
                ),
              ),
            ),
            Positioned(
              top:
                  showAbove
                      ? null
                      : targetPosition.dy +
                          targetSize.height +
                          (padding?.bottom ?? 0) +
                          indicatorHeight,
              bottom:
                  showAbove
                      ? MediaQuery.sizeOf(context).height -
                          targetPosition.dy +
                          (padding?.top ?? 0) +
                          indicatorHeight
                      : null,
              left: _calculateLeft(targetPosition.dx, targetSize.width),
              child: Material(
                color: Colors.transparent,
                child: _buildTutorialContent(step),
              ),
            ),
          ],
        );
      },
    );
  }

  OverlayEntry _createOverlayEntryWithoutTarget(TutorialStep step) {
    return OverlayEntry(
      builder: (BuildContext context) {
        return Stack(
          alignment: Alignment.center,
          children: [
            GestureDetector(
              onTap: () {
                if (widget.dismissOnTap) {
                  Provider.of<Tutorial>(
                    context,
                    listen: false,
                  ).endTutorial(widget.tutorialId);
                }
              },
              child: Container(color: widget.overlayColor),
            ),
            Material(
              color: Colors.transparent,
              child: _buildTutorialContent(step),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTutorialContent(TutorialStep step) {
    return Container(
      height: widget.height,
      width: _kTutorialWidth,
      padding: widget.padding,
      decoration: widget.decoration,
      child: IntrinsicHeight(child: step.child),
    );
  }

  double _calculateLeft(double targetX, double targetWidth) {
    final left = targetX + targetWidth / 2 - _kTutorialWidth / 2;
    final screenWidth = MediaQuery.of(context).size.width;
    if (left < 0) return 8;
    if (left + _kTutorialWidth > screenWidth) {
      return screenWidth - _kTutorialWidth - 8;
    }
    return left;
  }
}

class FocusOverlay extends StatelessWidget {
  final Rect highlightRect;
  final Color color;
  final double radius;

  const FocusOverlay({
    super.key,
    required this.highlightRect,
    this.color = const Color(0xAA000000),
    this.radius = 4,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.infinite,
      painter: _FocusOverlayPainter(
        highlightRect: highlightRect,
        overlayColor: color,
        radius: radius,
      ),
    );
  }
}

class _FocusOverlayPainter extends CustomPainter {
  final Rect highlightRect;
  final Color overlayColor;
  final double radius;

  _FocusOverlayPainter({
    required this.highlightRect,
    required this.overlayColor,
    required this.radius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final backgroundPath =
        Path()
          ..fillType = PathFillType.evenOdd
          ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
          ..addRRect(
            RRect.fromRectAndRadius(highlightRect, Radius.circular(radius)),
          );
    canvas.drawPath(backgroundPath, Paint()..color = overlayColor);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
