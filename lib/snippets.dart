import 'package:middleware_dart/compose.dart';
import 'package:middleware_dart/helpers.dart';
import 'package:middleware_dart/types.dart';

/// Call `next()` in middleware
dynamic skipMiddleware<T>(T context, NextMiddleware next) => next();

/// Does not call `next()` in middleware
Future<dynamic> stopMiddleware<T>(T context, NextMiddleware next) =>
    Future.value();

/// Lazily asynchronously gets middleware
///
/// Example:
///
/// ```dart
/// getLazyMiddleware((context) async {
///   final route = await getSomeRoute(context.path) // Future<Function>;
///
///   return route;
/// });
/// ```
Middleware<T> getLazyMiddleware<T>(LazyMiddlewareFactory<T> factory) {
  Middleware<T>? middleware;

  return (context, next) async {
    middleware ??= await factory(context);

    return middleware!(context, next);
  };
}

/// Runs the middleware and force call `next()`
///
/// Example:
///
/// ```dart
/// getTapMiddleware((context) {
///   print('Context $context');
/// });
/// ```
// ignore: prefer_expression_function_bodies
Middleware<T> getTapMiddleware<T>(Middleware<T> middleware) {
  return (context, next) async {
    await middleware(context, noopNext);
    await next();
  };
}

/// Runs the middleware at the next event loop and force call `next()`
///
/// Example:
///
/// ```dart
/// getForkMiddleware((context) {
///   statisticsMiddlewares(context);
/// });
/// ```
// ignore: prefer_expression_function_bodies
Middleware<T> getForkMiddleware<T>(Middleware<T> middleware) {
  return (context, next) async {
    await Future<dynamic>.sync(() => middleware(context, noopNext));

    return next();
  };
}

/// By condition splits the middleware
Middleware<T> getBranchMiddleware<T>(
  condition,
  Middleware<T> trueMiddleware,
  Middleware<T> falseMiddleware,
) {
  branchMiddlewareCondition<T>(condition);
  if (condition is! Function) {
    return condition as bool ? trueMiddleware : falseMiddleware;
  }

  return (context, next) async {
    // ignore: avoid_dynamic_calls
    if (await condition(context) as bool) {
      trueMiddleware(context, next);
    } else {
      falseMiddleware(context, next);
    }
  };
}

/// Conditionally runs optional middleware or skips middleware
///
/// Example:
///
/// ```dart
/// getOptionalMiddleware(
///   (context, next) => context.user.isAdmin,
///   addFieldsForAdmin
/// );
/// ```
Middleware<T> getOptionalMiddleware<T>(
  condition,
  Middleware<T> optionalMiddleware,
) {
  branchMiddlewareCondition<T>(condition);
  return getBranchMiddleware(condition, optionalMiddleware, skipMiddleware);
}

/// Conditionally runs middleware or stops the chain
///
/// Example:
///
/// ```dart
/// getFilterMiddleware(
///   (context) => context.authorized,
///   middlewareForAuthorized
/// );
/// ```
Middleware<T> getFilterMiddleware<T>(
  condition,
  Middleware<T> filterMiddleware,
) {
  branchMiddlewareCondition<T>(condition);
  return getBranchMiddleware(condition, filterMiddleware, stopMiddleware);
}

/// Runs the second middleware before the main
///
/// Example:
///
/// ```dart
/// getBeforeMiddleware(
///   myMockMiddleware,
///   ouputUserData
/// );
/// ```

Middleware<T> getBeforeMiddleware<T>(
  Middleware<T> beforeMiddleware,
  Middleware<T> middleware,
// ignore: prefer_expression_function_bodies
) {
  return (context, next) async {
    final called = await wrapMiddlewareNextCall(context, beforeMiddleware);

    if (called) {
      return middleware(context, next);
    }
  };
}

/// Runs the second middleware after the main
///
/// Example:
///
/// ```dart
/// getAfterMiddleware(
///   sendSecureData,
///   clearSecurityData
/// );
/// ```
Middleware<T> getAfterMiddleware<T>(
  Middleware<T> middleware,
  Middleware<T> afterMiddleware,
// ignore: prefer_expression_function_bodies
) {
  return (context, next) async {
    final called = await wrapMiddlewareNextCall(context, middleware);

    if (called) {
      return afterMiddleware(context, next);
    }
  };
}

/// Runs middleware before and after the main
///
/// Example:
///
/// ```dart
/// getEnforceMiddleware(
///   prepareData,
///   sendData,
///   clearData
/// );
Middleware<T> getEnforceMiddleware<T>(
  Middleware<T> beforeMiddleware,
  Middleware<T> middleware,
  Middleware<T> afterMiddleware,
// ignore: prefer_expression_function_bodies
) {
  return (context, next) async {
    final beforeCalled =
        await wrapMiddlewareNextCall(context, beforeMiddleware);

    if (!beforeCalled) {
      return;
    }

    final middlewareCalled = await wrapMiddlewareNextCall(context, middleware);
    if (!middlewareCalled) {
      return;
    }

    return afterMiddleware(context, next);
  };
}

/// Catches errors in the middleware chain
///
/// Example:
/// ```dart
/// getCaughtMiddleware((context, error) {
///   if (error is NetworkError) {
///     return context.send('Sorry, network issues 😔');
///   }
///
///   throw error;
/// })
/// ```
///
/// Without a snippet, it would look like this:
///
/// ```dart
/// (context, next) async {
///   try {
///     await next();
///   } catch (error) {
///     if (error is NetworkError) {
///       return context.send('Sorry, network issues 😔');
///     }
///
///     throw error;
///   }
/// };
/// ```
// ignore: prefer_expression_function_bodies
Middleware<T> getCaughtMiddleware<T>(CaughtMiddlewareHandler<T> errorHandler) {
  return (context, next) async {
    try {
      await next();
    } on Exception {
      return errorHandler(context, errorHandler as Exception);
    }
  };
}

/// Concurrently launches middleware,
/// the chain will continue if `next()` is called in all middlewares
///
/// **Warning: Error interrupts all others**
///
/// Example:
///
/// ```dart
/// getConcurrencyMiddleware(
///   initializeUser,
///   initializeSession,
///   initializeDatabase
/// );
/// ```
// ignore: prefer_expression_function_bodies
Middleware<T> getConcurrencyMiddleware<T>(Iterable<Middleware<T>> middlewares) {
  return (context, next) async {
    await Future.wait(
      // ignore: prefer_expression_function_bodies
      List<Middleware<T>>.from(middlewares).map((middleware) {
        return wrapMiddlewareNextCall(context, middleware);
      }),
    );

    return next();
  };
}
