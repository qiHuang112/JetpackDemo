import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

enum DragDirection { top, right, left, bottom }

class GestureDragDrawer extends StatefulWidget {
  final Widget child;

  /// 子视图大小
  final double childSize;

  ///偏移量
  final double originOffset;

  ///拖拽方向
  final DragDirection direction;

  final double parentWidth;
  final double parentHeight;

  GestureDragDrawer(
      {this.child, //拖拽组件要展示的子内容
      this.childSize = 0, //子内容的大小
      this.originOffset = 0, //预设偏移量
      this.parentWidth = 0, //父级组件的宽度 当拖拽组件在bottom和right时需要用到
      this.parentHeight = 0, //父级组件的高度
      this.direction = DragDirection.left});

  _GestureDragDrawerState state;

  @override
  _GestureDragDrawerState createState() {
    state = _GestureDragDrawerState();
    return state;
  }

  setToMaxAnimation() {
    switch (direction) {
      case DragDirection.top:
        state.setToMaxAnimation();
        state._toMaxAnimationController.forward(from: state.offsetY);
        break;
      case DragDirection.bottom:
        state.setToMaxAnimation();
        state._toMaxAnimationController.reset();
        state._toMaxAnimationController.forward();
        break;
      case DragDirection.left:
        state.setToMaxAnimation();
        state._toMaxAnimationController.forward(from: state.offsetX);

        break;
      case DragDirection.right:
        state.setToMaxAnimation();
        state._toMaxAnimationController.reset();
        state._toMaxAnimationController.forward();
        break;
    }
  }

  setCallBackAnimation() {
    switch (direction) {
      case DragDirection.top:
        state.setCallBackAnimation();
        state._callbackAnimationController.forward(from: state.offsetY);
        break;
      case DragDirection.bottom:
        state.setCallBackAnimation();
        state._callbackAnimationController.reset();
        state._callbackAnimationController.forward();
        break;
      case DragDirection.left:
        state.setCallBackAnimation();
        state._callbackAnimationController.forward(from: state.offsetX);

        break;
      case DragDirection.right:
        state.setCallBackAnimation();
        state._callbackAnimationController.reset();
        state._callbackAnimationController.forward();
        break;
    }
  }
}

class _GestureDragDrawerState extends State<GestureDragDrawer>
    with TickerProviderStateMixin {
  /// 初始化状态:设置宽度、起始偏移量、最小偏移量、中间偏移量、最大偏移量
  _initValue() {
    width = widget.childSize.abs();
    minOffset = -width / 2;
    midOffset = -width / 3;
    maxOffset = 0;

    /// 底部和右边的偏移量需要特殊计算初始值（右边和底部的值偏移量 = 父组件的宽或高 - 初始预设偏移量）
    switch (widget.direction) {
      case DragDirection.bottom:
        originOffset = widget.parentHeight - widget.originOffset;
        maxOffset = widget.parentHeight - width;
        midOffset = maxOffset + width / 3;
        minOffset = maxOffset + width / 2;
        break;
      case DragDirection.right:
        originOffset = widget.parentWidth - widget.originOffset;
        maxOffset = widget.parentWidth - width;
        midOffset = maxOffset + width / 3;
        minOffset = maxOffset + width / 2;
        break;
      default:
        originOffset = -width + widget.originOffset;
        break;
    }
  }

  /// 复原动画
  setCallBackAnimation() {
    double offset;
    switch (widget.direction) {
      //根据方向设置起始偏移值
      case DragDirection.top:
      case DragDirection.bottom:
        offset = offsetY;
        break;
      case DragDirection.left:
      case DragDirection.right:
        offset = offsetX;
        break;
    }
    _animation = Tween<double>(begin: offset, end: originOffset).animate(
        CurvedAnimation(
            parent: _callbackAnimationController, curve: Curves.easeOut))
      ..addListener(() {
        setState(() {
          switch (widget.direction) {
            case DragDirection.top:
            case DragDirection.bottom:
              offsetY = _animation.value;
              break;
            case DragDirection.left:
            case DragDirection.right:
              offsetX = _animation.value;
              break;
          }
        });
      });
  }

  /// 展开动画
  setToMaxAnimation() {
    double offset;
    switch (widget.direction) {
      //根据方向设置起始偏移值
      case DragDirection.top:
      case DragDirection.bottom:
        offset = offsetY;
        break;
      case DragDirection.left:
      case DragDirection.right:
        offset = offsetX;
        break;
    }
    _animation = Tween<double>(begin: offset, end: maxOffset).animate(
        CurvedAnimation(
            parent: _toMaxAnimationController, curve: Curves.easeOutQuart))
      ..addListener(() {
        setState(() {
          switch (widget.direction) {
            case DragDirection.top:
            case DragDirection.bottom:
              offsetY = _animation.value;
              break;
            case DragDirection.left:
            case DragDirection.right:
              offsetX = _animation.value;
              break;
          }
        });
      });
  }

  /// 偏移量最大值
  double maxOffset = 300;

  ///偏移量中间值
  double midOffset = 250;

  /// 偏移量最小值
  double minOffset = 200;

  /// 组件宽度
  double width;

  /// 初始偏移量
  double originOffset = -100;

  /// 水平偏移量
  double offsetY = 0;

  /// 垂直偏移量
  double offsetX = 0;

  ///缩回动画控制器
  AnimationController _callbackAnimationController;

  ///展开动画控制器
  AnimationController _toMaxAnimationController;

  /// 动画对象
  Animation _animation;

  @override
  void initState() {
    super.initState();
    _initValue();
    _callbackAnimationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 400));
    _toMaxAnimationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 400));

    switch (widget.direction) {
      case DragDirection.top:
        offsetY = originOffset;
        break;
      case DragDirection.bottom:
        offsetY = originOffset;
        break;
      case DragDirection.left:
        offsetX = originOffset;
        break;
      case DragDirection.right:
        offsetX = originOffset;
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: Offset(offsetX, offsetY),
      child: RawGestureDetector(
        gestures: {
          DrawerPanGestureRecognizer:
              GestureRecognizerFactoryWithHandlers<DrawerPanGestureRecognizer>(
            () => DrawerPanGestureRecognizer(),
            (DrawerPanGestureRecognizer instance) {
              instance
                ..onUpdate = (DragUpdateDetails details) {
                  switch (widget.direction) {
                    case DragDirection.top:
                      if (offsetY <= maxOffset) {
                        setState(() {
                          offsetY = offsetY + details.delta.dy;
                        });
                      }
                      break;
                    case DragDirection.bottom:
                      if (offsetY >= maxOffset) {
                        setState(() {
                          offsetY = offsetY + details.delta.dy;
                        });
                      }
                      break;
                    case DragDirection.left:
                      if (offsetX <= maxOffset) {
                        setState(() {
                          offsetX = offsetX + details.delta.dx;
                        });
                      }
                      break;
                    case DragDirection.right:
                      if (offsetX >= maxOffset) {
                        setState(() {
                          offsetX = offsetX + details.delta.dx;
                        });
                      }
                      break;
                  }
                }
                ..onEnd = (DragEndDetails details) {
                  switch (widget.direction) {
                    case DragDirection.top:
                      if (offsetY < minOffset) {
                        setCallBackAnimation();
                        _callbackAnimationController.forward(from: offsetY);
                      } else if (offsetY > minOffset) {
                        setToMaxAnimation();
                        _toMaxAnimationController.forward(from: offsetY);
                      }
                      break;
                    case DragDirection.bottom:
                      if (offsetY > minOffset) {
                        setCallBackAnimation();
                        _callbackAnimationController.reset();
                        _callbackAnimationController.forward();
                      } else if (offsetY < minOffset) {
                        setToMaxAnimation();
                        _toMaxAnimationController.reset();
                        _toMaxAnimationController.forward();
                      }
                      break;
                    case DragDirection.left:
                      if (offsetX < minOffset) {
                        setCallBackAnimation();
                        _callbackAnimationController.forward(from: offsetX);
                      } else if (offsetX > minOffset) {
                        setToMaxAnimation();
                        _toMaxAnimationController.forward(from: offsetX);
                      }
                      break;
                    case DragDirection.right:
                      if (offsetX > minOffset) {
                        setCallBackAnimation();
                        _callbackAnimationController.reset();
                        _callbackAnimationController.forward();
                      } else if (offsetX < minOffset) {
                        setToMaxAnimation();
                        _toMaxAnimationController.reset();
                        _toMaxAnimationController.forward();
                      }
                      break;
                  }
                };
            },
          ),
        },
        child: Container(
          width: width,
          child: widget.child,
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    if (_callbackAnimationController != null) {
      _callbackAnimationController.dispose();
    }
    if (_toMaxAnimationController != null) {
      _toMaxAnimationController.dispose();
    }
  }
}

class DrawerPanGestureRecognizer extends PanGestureRecognizer {}
