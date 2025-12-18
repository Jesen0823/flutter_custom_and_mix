import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

/// 日志工具类
class AppLogger {
  AppLogger._internal();

  // 静态单例实例
  static final AppLogger _instance = AppLogger._internal();

  // 对外暴露单例,工厂构造函数
  factory AppLogger() => _instance;

  // 核心Logger实例
  late Logger _logger;

  // 4. 初始化配置（项目启动时调用，建议在main.dart中初始化）
  void init({bool isRelease = kReleaseMode}) {
    // 开发环境配置：详细日志、彩色、栈信息、时间戳
    final devPrinter = PrettyPrinter(
      methodCount: 3, // 显示调用栈方法数,开发期便于定位
      errorMethodCount: 8, // 错误日志显示更多栈信息
      lineLength: 120,
      colors: true, // 终端彩色日志
      printEmojis: true, // 显示日志级别表情
      dateTimeFormat: DateTimeFormat.dateAndTime, // 打印时间戳（开发期便于排查时序问题）
      noBoxingByDefault: false,
    );

    // 生产环境配置：精简日志（仅核心错误）、无彩色、无敏感信息
    final prodPrinter = PrettyPrinter(
      methodCount: 0, // 生产环境隐藏调用栈,避免泄露代码结构
      errorMethodCount: 1,
      colors: false,
      printEmojis: false,
      dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
    );

    // 环境隔离：日志级别 + 格式化器
    if (isRelease) {
      _logger = Logger(
        printer: prodPrinter,
        level: Level.error, // 生产环境仅输出Error/WTF级别
        filter: ProductionFilter(), // 生产环境过滤器（仅放行>=error的日志）
      );
    } else {
      _logger = Logger(
        printer: devPrinter,
        level: Level.trace, // 开发环境输出所有级别日志
        filter: DevelopmentFilter(), // 开发环境过滤器（放行所有日志）
      );
    }
  }

  // 5. 封装日志级别方法（统一入口，便于后续扩展）
  void v(String message, {dynamic error, StackTrace? stackTrace}) =>
      _logger.t(message, error: error, stackTrace: stackTrace);

  void d(String message, {dynamic error, StackTrace? stackTrace}) =>
      _logger.d(message, error: error, stackTrace: stackTrace);

  void i(String message, {dynamic error, StackTrace? stackTrace}) =>
      _logger.i(message, error: error, stackTrace: stackTrace);

  void w(String message, {dynamic error, StackTrace? stackTrace}) =>
      _logger.w(message, error: error, stackTrace: stackTrace);

  void e(String message, {dynamic error, StackTrace? stackTrace}) =>
      _logger.e('[${DateTime.now()}] $message', error: error, stackTrace: stackTrace);

  void wtf(String message, {dynamic error, StackTrace? stackTrace}) =>
      _logger.f(message, error: error, stackTrace: stackTrace);

  // 销毁日志,可选，比如页面销毁/退出时
  void dispose() {
    _logger.close();
  }
}