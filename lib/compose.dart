import 'package:middleware_dart/types.dart';

// ignore: prefer_expression_function_bodies, public_member_api_docs
Middleware<T> compose<T>(Iterable<Middleware<T>> middlewares) {
  return (context, next) {
    var lastIndex = -1;

    NextMiddlewareReturn nextDispatch(int index) {
      if (index <= lastIndex) {
        return Future<Exception>.error(
          Exception('next() called multiple times'),
        );
      }

      lastIndex = index;

      if (middlewares.length == index) {
        return next();
      }

      final middleware = middlewares.elementAt(index);

      try {
        return Future.value(middleware(context, () => nextDispatch(index + 1)));
      } on Exception catch (error) {
        return Future.error(error);
      }
    }

    return nextDispatch(0);
  };
}

/// Noop for call `next()` in middleware
Future<dynamic> noopNext() => Future.value();
