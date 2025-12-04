import 'package:flutter/material.dart';

class PersistentTextField extends StatefulWidget {
  // 唯一标识,PageStorageKey的value
  final String storageKey;
  final String hintText;

  const PersistentTextField({
    super.key,
    required this.storageKey,
    required this.hintText,
  });

  @override
  State<PersistentTextField> createState() => _PersistentTextFieldState();
}

class _PersistentTextFieldState extends State<PersistentTextField> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    // 从PageStorage读取历史值
    final storedValue =
        PageStorage.of(
              context,
            ).readState(context, identifier: widget.storageKey)
            as String?;
    _controller = TextEditingController(text: storedValue ?? "");
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      decoration: InputDecoration(
        hintText: widget.hintText,
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
      // 输入变化时保存到PageStorage
      onChanged: (value) {
        PageStorage.of(
          context,
        ).writeState(context, value, identifier: widget.storageKey);
      },
    );
  }
}
