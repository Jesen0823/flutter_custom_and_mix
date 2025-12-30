import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_custom_and_mix/communication/channel/base_method_channel.dart';
import 'package:flutter_custom_and_mix/communication/channel/base/base_serializable.dart';
import 'package:flutter_custom_and_mix/communication/channel/base/channel_error.dart';
import 'package:flutter_custom_and_mix/communication/utils/app_logger.dart';

// Mock BaseSerializable class for testing
class MockUser extends BaseSerializable {
  final String name;
  final int age;
  
  MockUser({required this.name, required this.age});
  
  @override
  Map<String, dynamic> toJson() {
    return {'name': name, 'age': age};
  }
  
  factory MockUser.fromJson(Map<String, dynamic> json) {
    return MockUser(
      name: json['name'] as String,
      age: json['age'] as int,
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  late BaseMethodChannel baseMethodChannel;
  
  setUp(() {
    // Initialize AppLogger
    AppLogger().init(isRelease: false);
    
    // Create BaseMethodChannel using the public factory method
    const channelName = 'com.test/mock';
    baseMethodChannel = BaseMethodChannel.create(channelName: channelName);
    
    // Clear any existing mock handlers
    MethodChannel(channelName).setMockMethodCallHandler(null);
  });
  
  tearDown(() {
    // Clear any pending method calls
    const channelName = 'com.test/mock';
    MethodChannel(channelName).setMockMethodCallHandler(null);
    
    // Dispose the channel
    BaseMethodChannel.instanceMap[channelName]?.dispose();
    
    // Dispose AppLogger
    AppLogger().dispose();
  });
  
  group('BaseMethodChannel - 错误处理', () {
    test('正确处理序列化错误', () async {
      // Arrange
      const methodName = 'testSerializeError';
      
      const channelName = 'com.test/mock';
      MethodChannel(channelName).setMockMethodCallHandler((MethodCall call) async {
        if (call.method == methodName) {
          return 'not a map'; // 返回非Map类型，会导致序列化失败
        }
        throw PlatformException(code: 'NOT_IMPLEMENTED');
      });
      
      // Act & Assert
      expect(() async {
        await baseMethodChannel.invokeMethod<MockUser>(
          method: methodName,
          params: null,
          resultConverter: (json) => MockUser.fromJson(json as Map<String, dynamic>),
        );
      }, throwsA(isA<ChannelError>()));
    });
  });
}