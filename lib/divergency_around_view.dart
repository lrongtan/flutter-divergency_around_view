library divergency_around_view;

import 'package:flutter/material.dart';
import 'dart:math';

const double _ViewRadius = 80;

const double _ItemRadius = 30;

const double _CenterRadius = 20;

class DivergencyAroundView extends StatefulWidget {
  final double viewRadius; //控制展开半径
  final double itemRadius; //小组件的半径
  final double centerRadius; //中心组件的半径

  final double startAngle;
  final double endAngle;
  final List<Widget> items;
  final Widget centerItem;
  final Widget closeItem;
  final Widget cBottomItem;
  final bool rotation;

  final DivergencyAroundController controller;

  const DivergencyAroundView({
    Key key,
    this.viewRadius = _ViewRadius,
    this.itemRadius = _ItemRadius,
    this.centerRadius = _CenterRadius,
    this.startAngle = 0,
    this.endAngle = 2 * pi,
    this.items,
    this.centerItem,
    this.closeItem,
    this.rotation = true,
    this.cBottomItem,
    this.controller,
  }) : super(key: key);

  @override
  DivergencyAroundViewState createState() => DivergencyAroundViewState();
}

class DivergencyAroundViewState extends State<DivergencyAroundView>
    with SingleTickerProviderStateMixin {
  AnimationController controller;
  CurvedAnimation _curvedAnimation;

  double _width = 0;
  double _height = 0;
  double _radius = 0;
  double _centerX = 0;
  double _centerY = 0;

  DivergencyAroundController _aroundController;

  @override
  void initState() {
    controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 400));
    super.initState();

    _curvedAnimation =
        CurvedAnimation(parent: controller, curve: Curves.bounceOut);
    if(widget.controller == null){
      _aroundController = DivergencyAroundController(DivergencyAroundValue());
    }else{
      _aroundController = widget.controller;
    }
    _aroundController._animationController = controller;

    controller.addListener(() {
      setState(() {});
      _aroundController.animationValue = controller.value;
    });
  }

  @override
  void didUpdateWidget(DivergencyAroundView oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

//  计算控件相关的大小参数
  void _calculateWidgetSize() {
    _radius = (widget.itemRadius + widget.centerRadius + widget.viewRadius);

    double longSize =
        (widget.itemRadius * 2 + widget.centerRadius + widget.viewRadius) * 2;

    double sortSize =
    (widget.itemRadius * 2 + widget.centerRadius * 2 + widget.viewRadius);

    double longPosition = _radius + widget.itemRadius;
    double sortPosition = widget.centerRadius;

    _width = longSize;
    _height = longSize;
    _centerX = longPosition;
    _centerY = longPosition;

    if (widget.endAngle - widget.startAngle > pi) {
    } else {
//      暂时没有找到消减体积的规律。通过把情况列举出来解决
      _width = sortSize;
      _height = sortSize;
      _centerX = sortPosition;
      _centerY = sortPosition;
      if (widget.startAngle >= 0 &&
          widget.startAngle < widget.endAngle &&
          widget.endAngle <= pi / 2) {
      } else if (widget.startAngle >= 0 &&
          widget.startAngle < widget.endAngle &&
          widget.endAngle <= pi) {
        _width = longSize;
        _centerX = longPosition;
      } else if (widget.startAngle >= pi / 2 &&
          widget.startAngle < widget.endAngle &&
          widget.endAngle <= pi) {
        _centerX = longPosition;
      } else if (widget.startAngle >= pi / 2 &&
          widget.startAngle < widget.endAngle &&
          widget.endAngle <= pi / 2 * 3) {
        _height = longSize;
        _centerX = longPosition;
        _centerY = longPosition;
      } else if (widget.startAngle >= pi &&
          widget.startAngle < widget.endAngle &&
          widget.endAngle <= pi / 2 * 3) {
        _centerX = longPosition;
        _centerY = longPosition;
      } else if (widget.startAngle >= pi &&
          widget.startAngle < widget.endAngle &&
          widget.endAngle <= pi * 2) {
        _width = longSize;
        _centerY = longPosition;
        _centerX = longPosition;
      } else if (widget.startAngle >= pi / 2 * 3 &&
          widget.startAngle < widget.endAngle &&
          widget.endAngle <= pi * 2) {
        _centerY = longPosition;
      } else if (widget.startAngle >= pi &&
          widget.startAngle < widget.endAngle &&
          widget.endAngle <= pi * 2) {
        _height = longSize;
        _centerY = longPosition;
      } else {
        _width = longSize;
        _height = longSize;
        _centerX = longPosition;
        _centerY = longPosition;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    _calculateWidgetSize();
    return Container(
      width: _width,
      height: _height,
      child: Stack(children: buildItems()),
    );
  }

  List<Widget> buildItems() {
    List<Widget> items = [];
    double angle = (widget.endAngle - widget.startAngle) / widget.items.length;
    for (int i = 0; i < widget.items.length; i++) {
      double itemX;
      double itemY;
      if (!_aroundController.expand) {
        itemX = _centerX +
            _radius *
                controller.value *
                cos(widget.startAngle + angle / 2 + (angle * i));
        itemY = _centerY +
            _radius *
                controller.value *
                sin(widget.startAngle + angle / 2 + (angle * i));
      } else {
        itemX = _centerX +
            _radius *
                _curvedAnimation.value *
                cos(widget.startAngle + angle / 2 + (angle * i));
        itemY = _centerY +
            _radius *
                _curvedAnimation.value *
                sin(widget.startAngle + angle / 2 + (angle * i));
      }

      Widget item = Container(
        child: widget.items[i],
      );

      if (widget.rotation) {
        item = RotationTransition(
          turns: controller,
          child: item,
        );
      }
      item = Positioned(
        width: widget.itemRadius * 2,
        height: widget.itemRadius * 2,
        left: itemX - widget.itemRadius,
        top: itemY - widget.itemRadius,
        child: GestureDetector(
          onTap: () {
            _aroundController.closeHandle();
          },
          child: item,
        ),
      );
//      items.add(item);

      if (controller.value != 0) {
        items.add(item);
      }
    }

    Widget closeItem = Positioned(
        width: widget.centerRadius * 2,
        height: widget.centerRadius * 2,
        left: _centerX - widget.centerRadius,
        top: _centerY - widget.centerRadius,
        child: RotationTransition(
          turns: controller,
          child: GestureDetector(
            onTap: () {
              _aroundController.closeHandle();
            },
            child: widget.closeItem != null
                ? widget.closeItem
                : ClipOval(
              child: Container(
                color: Colors.white,
                child: Icon(
                  Icons.close,
                  color: Colors.grey,
                  size: widget.centerRadius,
                ),
              ),
            ),
          ),
        ));
    items.add(closeItem);
    Widget centerItem = Positioned(
        width: widget.centerRadius * 2,
        height: widget.centerRadius * 2,
        left: _centerX - widget.centerRadius,
        top: _centerY - widget.centerRadius,
        child: Opacity(
          opacity: 1 - controller.value,
          child: GestureDetector(
            onTap: () {
              _aroundController.expandHandle();

            },
            child: ClipOval(
              child: widget.centerItem != null
                  ? widget.centerItem
                  : Container(
                color: Colors.grey,
              ),
            ),
          ),
        ));

    Widget cBottomItem = Positioned(
        left: _centerX - widget.centerRadius,
        top: _centerY + widget.centerRadius,
        child: Opacity(
          opacity: 1 - controller.value,
          child: widget.cBottomItem != null ? widget.cBottomItem : Container(),
        ));
    if (controller.value != 1) {
      items.add(centerItem);
      items.add(cBottomItem);
    }
    return items;
  }
}

class DivergencyAroundController extends ValueNotifier<DivergencyAroundValue> {

  AnimationController _animationController;

  DivergencyAroundController(DivergencyAroundValue value) : super(value);

  bool get expand => value.expand;

  set expand(bool newValue) {
    value = value.copyWith(expand: newValue);
  }

  double get animationValue => value.value;

  set animationValue(double newValue) {
    value = value.copyWith(value: newValue);
  }

  void expandHandle(){
    _animationController.forward();
    this.expand = true;

  }

  void closeHandle(){
    _animationController.reverse();
    this.expand = false;
  }
}

class DivergencyAroundValue {
  bool expand;
  double value;

  DivergencyAroundValue({this.expand = false, this.value = 0});

  copyWith({bool expand, double value}) {
    return DivergencyAroundValue(
        expand: expand ?? this.expand, value: value ?? this.value);
  }
}
