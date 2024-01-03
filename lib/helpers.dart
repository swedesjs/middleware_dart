import 'package:middleware_dart/types.dart';

// ignore: public_member_api_docs
Future<bool> wrapMiddlewareNextCall<T>(
  T context,
  Middleware<T> middleware,
) async {
  var called = false;

  await middleware(context, () {
    if (called) {
      throw Exception('next() called multiple times');
    }

    called = true;
  });

  return called;
}
