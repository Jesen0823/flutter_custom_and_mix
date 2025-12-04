import 'package:flutter/material.dart';

import '../value_key/list_build/cart_item_widget .dart';
import '../value_key/list_build/cart_product.dart';

/// 购物车页面（场景：加载数据、增删商品、排序、选中结算）
/// 去掉key也可以运行？
/// 是的，但是
/// ListView 和 ListView.builder 的底层复用逻辑完全不同，这是导致 Key 看似 “失效” 的核心原因
/// ——不是 Key 没用，而是 builder 的「动态 Element 树」让 Flutter 的匹配算法更难找到旧 Element。
/// 非 builder 列表：所有 Element 都在内存，排序后 Flutter 能遍历完整的旧 Element 树，
/// 通过 Key 快速匹配，所以复用成功；
// builder 列表：排序后，旧的 Element 可能已被回收（比如 iPhone 原来在可视区，排序后跑到屏幕外，
// Element 被销毁），Flutter 找不到对应的旧 Element，只能新建 Element（执行 initState），导致状态丢失。
// 结论：builder 的懒加载导致部分旧 Element 被回收，Key 匹配失败。

///
/// 生产环境解决方案：builder 列表 + Key + 状态提升（兼顾性能 + 状态稳定）
// 生产中大量数据必须用 ListView.builder（否则一次性构建上千个 Widget 会 OOM），
// 解决思路是「Key 保证 RenderObject 复用（性能）+ 状态提升保证状态不丢失（正确性） 」
// ，既解决 builder 的懒加载问题，又兼顾性能和稳定性。
//
// 核心逻辑：
// 状态提升：把子组件的状态（如选中状态）移到父组件 / 状态管理（Provider/Bloc），
// 用「productId → 状态」的映射存储（如你最初的_selectedStatus）；
// Key 保留：给 builder 的 Item 加 Key（绑定 productId），目的是「复用 RenderObject」
// （如商品图片缓存、组件尺寸计算），避免不必要的重建（提升性能）；
// 子组件：只负责渲染，状态由父组件传递，不自己维护状态（避免 Element 回收导致状态丢失）。

/// 生产级方案的核心优势（兼顾性能 + 稳定）
// 1. 状态绝对稳定（不会丢失 / 错乱）
// 状态存储在父组件的_selectedStatus（或状态管理），用productId作为 key—— 排序 / 删除 / 滚动时，状态与商品强绑定，不会因 Element 回收而丢失；
// 子组件是 StatelessWidget，仅负责渲染，无内部状态，彻底避免 Element 复用导致的状态错乱。
// 2. 性能最优（Key 的真正价值体现）
// 虽然状态由父组件管理，但ValueKey(product.productId)依然要加 —— 目的是「复用 RenderObject」：
// 商品图片的缓存不会失效（不用重新下载）；
// 组件的尺寸、布局计算结果会复用（不用重新计算）；
// 避免不必要的 Widget 重建（Flutter 检测到 Key 和 runtimeType 不变，会跳过重建逻辑）。
// 3. 适配大量数据（builder 的核心作用）
// 懒加载只构建可视区域的 Widget，内存占用极低（支持上千条商品列表）；
// 即使 Element 被回收，重新构建时父组件会通过productId传递正确的状态，用户无感知。
// 五、builder 列表使用 Key 的生产级规范
// 必须加 Key，但 Key 的作用是「性能优化」而非「状态保留」：
// 状态保留靠「状态提升 + productId 映射」；
// Key 的作用是复用 RenderObject，减少重建开销。
// Key 必须绑定「业务唯一 ID」（如 productId）：
// 绝对不能用 index（排序 / 删除后 index 变化，Key 失效）；
// 不能用 UniqueKey（每次重建生成新 Key，RenderObject 无法复用）。
// 子组件优先用 StatelessWidget：
// 动态列表的子组件尽量避免内部维护状态（交给父组件 / 状态管理）；
// 若必须有内部临时状态（如输入框内容），用TextEditingController+ 父组件存储（或PageStorageKey）。
// 避免动态修改 Widget 的 runtimeType：
// 同一位置的 Item，runtimeType 必须一致（比如不能有时返回 CartItemWidget，有时返回 OtherWidget），否则 Key 匹配失效，Element 会重建。
// 合理配置预加载和缓存：
// 可通过cacheExtent参数调整 ListView.builder 的预加载范围（默认 250.0），减少滚动时的重建频率：
// dart
// ListView.builder(
//   cacheExtent: 500.0, // 预加载更多区域的Widget，减少滚动时的Element创建/回收
//   itemCount: _products.length,
//   itemBuilder: (context, index) => ...,
// );
class ValueKeyShoppingCartPageExample extends StatefulWidget {
  const ValueKeyShoppingCartPageExample({super.key});

  @override
  State<ValueKeyShoppingCartPageExample> createState() =>
      _ValueKeyShoppingCartPageExampleState();
}

class _ValueKeyShoppingCartPageExampleState
    extends State<ValueKeyShoppingCartPageExample> {
  // 购物车商品列表（通常从本地缓存/接口加载）
  late List<CartProduct> _cartProducts;

  // 选中状态映射（key：productId，value：是否选中，避免状态存在子组件中丢失）
  late Map<String, bool> _selectedStatus;

  @override
  void initState() {
    super.initState();
    // 模拟从接口加载购物车数据（企业开发中实际是接口请求+本地缓存）
    _cartProducts = [
      CartProduct(
        productId: "prod_1001", // 业务唯一ID
        name: "iPhone 15 Pro Max 256G",
        price: 9999.0,
        imageUrl: "https://picsum.photos/200/200?random=1",
      ),
      CartProduct(
        productId: "prod_1002",
        name: "华为 Mate 60 Pro 512G",
        price: 6999.0,
        imageUrl: "https://picsum.photos/200/200?random=2",
      ),
      CartProduct(
        productId: "prod_1003",
        name: "小米 14 Ultra 1TB",
        price: 5999.0,
        imageUrl: "https://picsum.photos/200/200?random=3",
      ),
      CartProduct(
        productId: "prod_1004",
        name: "三星 S24 Ultra 512G",
        price: 7999.0,
        imageUrl: "https://picsum.photos/200/200?random=4",
      ),
    ];

    // 初始化选中状态（默认全部未选中）
    _selectedStatus = {
      for (var product in _cartProducts) product.productId: false,
    };
  }

  // 新增商品（模拟加入购物车）
  void _addProduct() {
    final newProduct = CartProduct(
      productId: "prod_${DateTime.now().millisecondsSinceEpoch}", // 生成唯一ID
      name: "新增商品 ${_cartProducts.length + 1}",
      price: (3000 + _cartProducts.length * 500).toDouble(),
      imageUrl:
          "https://picsum.photos/200/200?random=${_cartProducts.length + 1}",
    );
    setState(() {
      _cartProducts = List.from(_cartProducts)..add(newProduct); // 不可变更新
      _selectedStatus[newProduct.productId] = false; // 初始化新商品选中状态
    });
  }

  // 删除商品
  void _deleteProduct(String productId) {
    setState(() {
      _cartProducts = _cartProducts
          .where((p) => p.productId != productId)
          .toList();
      _selectedStatus.remove(productId); // 移除选中状态
    });
  }

  // 按价格排序（升序/降序切换）
  bool _isAscending = true;

  void _sortByPrice() {
    setState(() {
      _cartProducts = List.from(_cartProducts)
        ..sort((a, b) {
          return _isAscending
              ? a.price.compareTo(b.price)
              : b.price.compareTo(a.price);
        });
      _isAscending = !_isAscending;
    });
  }

  // 选中状态变化回调
  void _onSelectChanged(String productId, bool isSelected) {
    setState(() {
      _selectedStatus[productId] = isSelected;
    });
  }

  // 计算选中商品总价（企业开发中结算核心逻辑）
  double _calculateTotalPrice() {
    double total = 0;
    for (var product in _cartProducts) {
      if (_selectedStatus[product.productId] ?? false) {
        total += product.price;
      }
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("我的购物车"),
        actions: [
          IconButton(
            icon: Icon(
              _isAscending
                  ? Icons.vertical_align_top
                  : Icons.vertical_align_bottom,
            ),
            onPressed: _sortByPrice,
            tooltip: _isAscending ? "价格升序" : "价格降序",
          ),
        ],
      ),
      body: Column(
        children: [
          // 购物车列表
          Expanded(
            child: _cartProducts.isEmpty
                ? const Center(child: Text("购物车为空，快去添加商品吧～"))
                : ListView.builder(
                    itemCount: _cartProducts.length,
                    itemBuilder: (context, index) {
                      final product = _cartProducts[index];
                      return Stack(
                        key: ValueKey(product.productId), //Key 加在 ListView 的直接子 Widget 上；
                        children: [
                          CartItemWidget(
                            product: product,
                            isSelected:
                                _selectedStatus[product.productId] ?? false,
                            onSelectChanged: (value) =>
                                _onSelectChanged(product.productId, value),
                          ),
                          // 删除按钮（企业级列表项常见功能）
                          Positioned(
                            top: 8,
                            right: 8,
                            child: IconButton(
                              icon: const Icon(
                                Icons.delete,
                                color: Colors.grey,
                              ),
                              onPressed: () =>
                                  _deleteProduct(product.productId),
                              iconSize: 20,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
          ),
          // 底部结算栏（企业级购物车标准布局）
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Colors.grey[200]!)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "选中总价：¥${_calculateTotalPrice().toStringAsFixed(2)}",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
                ElevatedButton(
                  onPressed: _calculateTotalPrice() > 0
                      ? () {
                          // 模拟结算逻辑
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                "结算成功！总价：¥${_calculateTotalPrice().toStringAsFixed(2)}",
                              ),
                            ),
                          );
                        }
                      : null,
                  child: const Text("立即结算"),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addProduct,
        tooltip: "添加商品",
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerTop,
    );
  }
}
