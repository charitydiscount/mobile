import 'package:flutter/material.dart';

class AnimatedPages extends StatefulWidget {
  final Widget Function(BuildContext, int, PageController) itemBuilder;
  final Function(int) onPageChanged;
  final int itemCount;
  final ScrollPhysics physics;

  const AnimatedPages({
    Key key,
    this.itemBuilder,
    this.onPageChanged,
    this.itemCount,
    this.physics,
  }) : super(key: key);

  @override
  _AnimatedPagesState createState() => _AnimatedPagesState();
}

class _AnimatedPagesState extends State<AnimatedPages>
    with TickerProviderStateMixin {
  PageController _controller;

  @override
  void initState() {
    super.initState();
    _controller = PageController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      itemCount: widget.itemCount,
      controller: _controller,
      physics: widget.physics,
      onPageChanged: widget.onPageChanged,
      itemBuilder: (context, index) {
        return Transform(
          transform: Matrix4.translationValues(0, 0, 0),
          child: widget.itemBuilder(
            context,
            index,
            _controller,
          ),
        );
      },
    );
  }
}
