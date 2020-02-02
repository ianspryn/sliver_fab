library sliver_fab;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// A helper class if you want a FloatingActionButton to be pinned in the FlexibleAppBar
class SliverFab extends StatefulWidget {
  ///List of slivers placed in CustomScrollView
  final List<Widget> slivers;

  ///FloatingActionButton placed on the edge of FlexibleAppBar and rest of view
  final Widget floatingWidget;

  ///Expanded height of FlexibleAppBar
  final double expandedHeight;

  ///The radius for the top corners that will overlay other slivers
  final double topCornersRadius;

  ///Number of pixels from top from which the [floatingWidget] should start shrinking.
  ///E.g. If your SliverAppBar is pinned, I would recommend this leaving as default 96.0
  ///     If you want [floatingActionButton] to shrink earlier, increase the value.
  final double topScalingEdge;


  ///Number of pixels from the top from which the [floatingWidget] should disappear.
  ///E.g., if your SliverAppBar is pinned, you may wish for it to disappear before it
  ///reaches the SliverAppbar. When this is true, increase the value.
  final double disappearAt;

  ///Position of the widget.
  final FloatingPosition floatingPosition;

  /// Changes edge behavior to account for [SliverAppBar.pinned].
  ///
  /// Hides the edge when the [ScrollController.offset] reaches the collapsed
  /// height of the [SliverAppBar] to prevent it from overlapping the app bar.
  ///
  /// For best results, it is recommended you set this to true if you are using
  /// a SliverAppBar that is using expandedHeight.
  final bool hasPinnedAppBar;

  SliverFab({
    @required this.slivers,
    @required this.floatingWidget,
    this.floatingPosition = const FloatingPosition(right: 16.0),
    this.expandedHeight = 256.0,
    this.topCornersRadius = 0.0,
    this.topScalingEdge = 96.0,
    this.disappearAt = 0.0,
    this.hasPinnedAppBar = false,
  }) {
    assert(slivers != null);
    assert(floatingWidget != null);
    assert(floatingPosition != null);
    assert(expandedHeight != null);
    assert(topCornersRadius != null);
    assert(topScalingEdge != null);
    assert(disappearAt != null);
    assert(hasPinnedAppBar != null);
  }

  @override
  State<StatefulWidget> createState() {
    return new SliverFabState();
  }
}

class SliverFabState extends State<SliverFab> {
  ScrollController scrollController;

  @override
  void initState() {
    super.initState();
    scrollController = new ScrollController();
    scrollController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        CustomScrollView(
          controller: scrollController,
          slivers: widget.slivers,
        ),
        if (widget.topCornersRadius > 0) _buildEdge(),
        _buildFab(),
      ],
    );
  }

  Widget _buildEdge() {
    var paddingTop = MediaQuery.of(context).padding.top;

    var defaultOffset = (paddingTop + widget.expandedHeight) - widget.topCornersRadius;

    var top = defaultOffset;
    var edgeSize = widget.topCornersRadius;

    if (scrollController.hasClients) {
      double offset = scrollController.offset;
      top -= offset > 0 ? offset : 0;

      if (widget.hasPinnedAppBar) {
        // Hide edge to prevent overlapping the toolbar during scroll.
        var breakpoint = widget.expandedHeight - kToolbarHeight - widget.topCornersRadius;

        if (offset >= breakpoint) {
          edgeSize = widget.topCornersRadius - (offset - breakpoint);
          if (edgeSize < 0) {
            edgeSize = 0;
          }

          top += (widget.topCornersRadius - edgeSize);
        }
      }
    }

    return Positioned(
      top: top,
      left: 0,
      right: 0,
      child: Container(
        height: edgeSize,
        decoration: BoxDecoration(
          color: Theme.of(context).canvasColor,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(widget.topCornersRadius),
          ),
        ),
      ),
    );
  }

  Widget _buildFab() {
    final double defaultFabSize = 56.0;
    final double paddingTop = MediaQuery.of(context).padding.top;
    final double defaultTopMargin = widget.expandedHeight +
        paddingTop +
        (widget.floatingPosition.top ?? 0) -
        defaultFabSize / 2;

    final double scale0edge = widget.expandedHeight - kToolbarHeight - widget.disappearAt;
    final double scale1edge = defaultTopMargin - widget.topScalingEdge;

    double top = defaultTopMargin;
    double scale = 1.0;
    if (scrollController.hasClients) {
      double offset = scrollController.offset;
      top -= offset > 0 ? offset : 0;
      if (offset < scale1edge) {
        scale = 1.0;
      } else if (offset > scale0edge) {
        scale = 0.0;
      } else {
        scale = (scale0edge - offset) / (scale0edge - scale1edge);
      }
    }

    return Positioned(
      top: top,
      right: widget.floatingPosition.right,
      left: widget.floatingPosition.left,
      child: new Transform(
        transform: new Matrix4.identity()..scale(scale, scale),
        alignment: Alignment.center,
        child: widget.floatingWidget,
      ),
    );
  }
}

///A class representing position of the widget.
///At least one value should be not null
class FloatingPosition {
  ///Can be negative. Represents how much should you change the default position.
  ///E.g. if your widget is bigger than normal [FloatingActionButton] by 20 pixels,
  ///you can set it to -10 to make it stick to the edge
  final double top;

  ///Margin from the right. Should be positive.
  ///The widget will stretch if both [right] and [left] are not nulls.
  final double right;

  ///Margin from the left. Should be positive.
  ///The widget will stretch if both [right] and [left] are not nulls.
  final double left;

  const FloatingPosition({this.top, this.right, this.left});
}
