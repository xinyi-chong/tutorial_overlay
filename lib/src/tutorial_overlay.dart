import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tutorial_overlay/src/tutorial_state.dart';
import 'package:tutorial_overlay/tutorial_step.dart';

class TutorialOverlay<T> extends StatefulWidget {
  /// The content displayed in the tutorial tooltip.
  final Widget child;

  /// A unique identifier for the tutorial sequence.
  ///
  /// Each tutorial in the app should have its own `tutorialId` to distinguish
  /// its steps and progress tracking. This ID links the overlay and control
  /// functions (like `nextStep` and `endTutorial`) to the correct list of
  /// tutorial steps managed by `TutorialState`.
  final T tutorialId;

  /// The width of the tooltip container.
  final double width;

  /// Optional height of the tooltip container.
  final double? height;

  /// Optional decoration for the tooltip container.
  final Decoration? decoration;

  /// Optional padding for the tooltip content.
  final EdgeInsetsGeometry? padding;

  /// Whether the tutorial should end when tapping outside the tooltip.
  ///
  /// Defaults to `true`.
  final bool dismissOnTap;

  /// An optional default indicator widget (e.g., an arrow) to point at the target widget.
  ///
  /// This will be used for all tutorial steps unless a step provides its own [indicator].
  final Widget? indicator;

  /// The default height for the [indicator], used if not specified per step.
  final double? indicatorHeight;

  /// The default width for the [indicator], used if not specified per step.
  final double? indicatorWidth;

  /// The color of the overlay, which will cover the area outside the target widget.
  final Color overlayColor;

  /// The radius of the focused area (the target widget).
  final double radius;

  /// Padding for the highlight area around the target widget.
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
    final tutorialState = Provider.of<TutorialState>(context, listen: false);
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

    final tutorialState = Provider.of<TutorialState>(context, listen: false);
    final steps = tutorialState.getSteps(widget.tutorialId);

    if (step < 0 || steps == null || step >= steps.length) return;

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
                  Provider.of<TutorialState>(
                    context,
                    listen: false,
                  ).endTutorial(widget.tutorialId);
                }
              },
              child: FocusOverlay(
                highlightRect: Rect.fromLTWH(
                  targetPosition.dx - (padding?.left ?? 0),
                  targetPosition.dy - (padding?.top ?? 0),
                  targetSize.width + (padding?.left ?? 0) + (padding?.right ?? 0),
                  targetSize.height + (padding?.top ?? 0) + (padding?.bottom ?? 0),
                ),
                color: widget.overlayColor,
                radius: widget.radius,
              ),
            ),
            Positioned(
              top:
                  showAbove
                      ? (targetPosition.dy - indicatorHeight - (padding?.top ?? 0))
                      : (targetPosition.dy + (padding?.bottom ?? 0) + targetSize.height),
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
                      : targetPosition.dy + targetSize.height + (padding?.bottom ?? 0) + indicatorHeight,
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
                  Provider.of<TutorialState>(
                    context,
                    listen: false,
                  ).endTutorial(widget.tutorialId);
                }
              },
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
    final Path backgroundPath =
        Path()
          ..fillType = PathFillType.evenOdd
          ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    final RRect focusRect = RRect.fromRectAndRadius(
      highlightRect,
      Radius.circular(radius),
    );
    backgroundPath.addRRect(focusRect);
    canvas.drawPath(backgroundPath, Paint()..color = overlayColor);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
