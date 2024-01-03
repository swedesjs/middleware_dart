> **Middleware_Dart** - Library for middleware, inspired by [middleware-io](https://github.com/negezor/middleware-io)

# Features

1. **Self-sufficient.** The library has no dependencies
2. **Reliable.** The library is covered with tests
3. **Strong.** Supports the following additional features:
   - The library has enough built-in snippets;
   - Middleware chain designer;

# Example Usage

```dart
import 'package:middleware_dart/middleware_dart.dart';

void main() async {
  final composedMiddleware = compose([
    (context, next) async {
      print('step 1');
      await next();
      print('step 4');
    },
    (context, next) async {
      print('step 2');
      await next();
      print('step 3');
    }
  ]);

  await composedMiddleware([], () {
    print('Middleware finished work');
  });
}
```
