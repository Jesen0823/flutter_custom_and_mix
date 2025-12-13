import 'package:flutter/material.dart';

/// AnimatedPositioned：首页悬浮购物车按钮
// 场景:
// 电商 App 首页，滚动列表时悬浮购物车按钮从右下角滑到右侧中间位置（避免遮挡内容），滚动到底部时恢复原位，提升操作便捷性。
/// 过滤事件类型：只处理需要的ScrollNotification子类（如ScrollUpdateNotification），减少无效逻辑；
// 防抖 / 节流：高频触发的回调（如滚动、输入）必须加防抖（延迟执行）或节流（限制执行频率）；
// 避免在监听中做耗时操作：滚动监听每帧触发，耗时操作会导致卡顿；
// 状态防抖：对布尔型状态（如_isScrolled），增加 “状态锁” 避免短时间内反复切换：状态切换后，立即 “上锁”，50ms 内不允许再次切换；
// 50ms 后自动 “解锁”，恢复状态切换能力；
// 锁的时长（50ms）是经验值：既短到不影响用户感知，又能过滤高频触发的无效切换。
class AnimatedPositionedCartPage extends StatefulWidget {
  const AnimatedPositionedCartPage({super.key});

  @override
  State<AnimatedPositionedCartPage> createState() =>
      _AnimatedPositionedCartPageState();
}

class _AnimatedPositionedCartPageState
    extends State<AnimatedPositionedCartPage> {
  // 控制按钮位置：是否滚动（true=中间，false=右下角）
  bool _isScrolled = false;

  // 技术锁：防高频触发
  bool _isStateLocked = false;

  // 滚动阈值
  static const double _scrollUpThreshold = 120; // 向上滚动超过120px才上移
  static const double _scrollDownThreshold = 80; // 向下滚动低于80px才下移
  static const Duration _stateLockDuration = Duration(milliseconds: 50);

  // 商品数据列表
  final List<String> _productList = List.generate(
    20,
    (index) => "商品 ${index + 1}",
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("首页（AnimatedPositioned）")),
      body: Stack(
        children: [
          // 商品列表滚动监听
          // 推荐使用ScrollController替代NotificationListener
          // ScrollController的addListener更可控,final currentPixels = _scrollController.offset
          NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              print("px: ${notification.metrics.pixels}");
              // 仅处理滚动更新事件,过滤其他无关事件
              if (notification is ScrollUpdateNotification) {
                _handleScrollUpdate(notification);
              }
              return false; // 不拦截事件
            },
            child: ListView.builder(
              itemCount: _productList.length,
              itemBuilder: (context, index) {
                return ListTile(
                  key: ValueKey(_productList[index]),
                  title: Text(_productList[index]),
                  leading: const Icon(Icons.shopping_bag_outlined),
                );
              },
            ),
          ),
          // AnimatedPositioned 实现按钮位置动画
          AnimatedPositioned(
            // 滚动时：右侧20px，垂直居中；未滚动时：右下20px
            right: 20,
            bottom: _isScrolled
                ? MediaQuery.of(context).size.height / 2 - 30
                : 20,
            curve: Curves.easeOut,
            duration: const Duration(milliseconds: 500),
            onEnd: () => debugPrint("购物车按钮动画完成"),
            child: FloatingActionButton(
              backgroundColor: Colors.redAccent,
              onPressed: () {
                // 跳转购物车页面（AutoRouter.of(context).push(CartRoute())）
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text("进入购物车页面")));
              },
              child: Stack(
                children: [
                  const Icon(Icons.shopping_cart, color: Colors.white),
                  // 购物车角标
                  Positioned(
                    top: 9,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Text(
                        "3",
                        style: TextStyle(fontSize: 12, color: Colors.redAccent),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleScrollUpdate(ScrollUpdateNotification notification) {
    // 上锁时直接返回
    if (_isStateLocked) return;
    final currentPixels = notification.metrics.pixels;
    // 判断滚动方向：dy < 0 向上滚动， dy > 0 向下滚动，null 表示非手指滚动，如惯性
    final double? scrollDirection = notification.dragDetails?.delta.dy;
    // 状态未变化时，不执行无谓的setState
    bool needUpdate = false;

    if (scrollDirection != null) {
      // 1. 向上滚动（dy < 0）：超过上阈值，且当前未上移 → 上移按钮
      if (scrollDirection < 0 && currentPixels > _scrollUpThreshold) {
        needUpdate = _updateScrolledState(true);
      } else if (scrollDirection > 0 && currentPixels < _scrollDownThreshold) {
        // 2. 向下滚动（dy > 0）：低于下阈值，且当前已上移 → 下移按钮
        needUpdate = _updateScrolledState(false);
      }
    } else {
      // 惯性滚动（无手指触摸）：仅在滚动到底部/顶部时调整
      if (notification.metrics.atEdge && currentPixels == 0) {
        needUpdate = _updateScrolledState(false);
      }
    }
    // 仅在需要更新时执行setState
    if (needUpdate && mounted) {
      setState(() {});
    }
  }

  /// 更新按钮位置状态
  /// [newValue] 新的业务状态（true=上移，false=下移）
  /// 返回值：是否需要执行setState
  bool _updateScrolledState(bool newValue) {
    // 1. 如果状态没变化，无需处理
    if (_isScrolled == newValue) return false;
    // 2. 先修改业务状态（核心逻辑）
    _isScrolled = newValue;
    // 3. 立即上锁，防止短时间内重复切换
    _lockState();
    // 4. 标记需要更新UI
    return true;
  }

  // 防抖锁
  void _lockState() {
    _isStateLocked = true;
    Future.delayed(_stateLockDuration, () {
      if (mounted) _isStateLocked = false;
    });
  }
}
