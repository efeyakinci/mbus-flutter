import 'package:flutter/widgets.dart';

class CardRectangleLoadingAnimation extends StatefulWidget {
  final int numRows;
  double height = 64.0;

  CardRectangleLoadingAnimation(this.numRows, {height = 64.0}) {
    this.height = height;
  }

  _CardRectangleLoadingAnimationState createState () => _CardRectangleLoadingAnimationState();
}

class _CardRectangleLoadingAnimationState extends State<CardRectangleLoadingAnimation> with SingleTickerProviderStateMixin {

  late AnimationController _controller;


  @override
  void initState() {
    _controller = AnimationController(vsync: this, duration: Duration(milliseconds: 1250), lowerBound: 0.2);
    _controller.repeat(reverse: true);
  }

  @override
  Widget build(BuildContext context) {
    return (
        ListView.builder(
          shrinkWrap: true,
          itemCount: widget.numRows,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            return AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Opacity(opacity: _controller.value, child: child,);
              },
              child: Container(
                decoration: BoxDecoration(
                    color: Color(0xFFAAAAAA),
                    borderRadius: BorderRadius.circular(widget.height / 8)
                ),
                margin: EdgeInsets.fromLTRB(0, 0, 0, 16),
                width: 32,
                height: widget.height,
              ),
            );
          },
        )
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}


class CardTextLoadingAnimation extends StatefulWidget {
  final int numRows;

  CardTextLoadingAnimation(this.numRows);

  _CardTextLoadingAnimationState createState () => _CardTextLoadingAnimationState();
}

class _CardTextLoadingAnimationState extends State<CardTextLoadingAnimation> with SingleTickerProviderStateMixin {

  late AnimationController _controller;


  @override
  void initState() {
    _controller = AnimationController(vsync: this, duration: Duration(milliseconds: 1250), lowerBound: 0.2);
    _controller.repeat(reverse: true);
  }

  @override
  Widget build(BuildContext context) {
    return (
        ListView.builder(
          shrinkWrap: true,
          itemCount: widget.numRows,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            return AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Opacity(opacity: _controller.value, child: child,);
              },
              child: Container(
                decoration: BoxDecoration(
                    color: Color(0xFFAAAAAA),
                    borderRadius: BorderRadius.circular(16)
                ),
                margin: EdgeInsets.fromLTRB(0, 0, 0, 16),
                width: 32,
                height: 16,
              ),
            );
          },
        )
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();

  }
}