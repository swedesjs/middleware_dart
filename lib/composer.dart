import 'package:middleware_dart/compose.dart' as compose_file;
import 'package:middleware_dart/snippets.dart';
import 'package:middleware_dart/types.dart';

/// A simple middleware compose builder
class Composer<T extends Object> {
  List<Middleware<T>> _middlewares = List.empty(growable: true);

  /// The number of middleware installed in Composer
  int get lenght => _middlewares.length;

  /// Adds middleware to the chain
  void use(Middleware<T> middleware) {
    _middlewares.add(middleware);
  }

  /// Lazily asynchronously gets middleware
  void lazy(LazyMiddlewareFactory<T> factory) {
    use(getLazyMiddleware(factory));
  }

  /// Runs the middleware and force call `next()`
  void tap(Middleware<T> middleware) {
    use(getTapMiddleware(middleware));
  }

  /// Runs the middleware at the next event loop and force call `next()`
  void fork(Middleware<T> middleware) {
    use(getForkMiddleware(middleware));
  }

  /// By condition splits the middleware
  void branch(
    condition,
    Middleware<T> trueMiddleware,
    Middleware<T> falseMiddleware,
  ) {
    use(getBranchMiddleware(condition, trueMiddleware, falseMiddleware));
  }

  /// Conditionally runs optional middleware or skips middleware
  void optional(condition, Middleware<T> optionalMiddleware) {
    use(getOptionalMiddleware(condition, optionalMiddleware));
  }

  /// Conditionally runs middleware or stops the chain
  void filter(condition, Middleware<T> filterMiddleware) {
    use(getFilterMiddleware(condition, filterMiddleware));
  }

  /// Runs the second middleware before the main
  void before(Middleware<T> beforeMiddleware, Middleware<T> middleware) {
    use(getBeforeMiddleware(beforeMiddleware, middleware));
  }

  /// Runs the second middleware after the main
  void after(Middleware<T> middleware, Middleware<T> afterMiddleware) {
    use(getAfterMiddleware(middleware, afterMiddleware));
  }

  /// Runs middleware before and after the main
  void enforce(
    Middleware<T> beforeMiddleware,
    Middleware<T> middleware,
    Middleware<T> afterMiddleware,
  ) {
    use(getEnforceMiddleware(beforeMiddleware, middleware, afterMiddleware));
  }

  /// Catches errors in the middleware chain
  void caught(CaughtMiddlewareHandler<T> errorHandler) {
    use(getCaughtMiddleware(errorHandler));
  }

  /// Concurrently launches middleware, the chain will continue if is called in
  /// all middlewares `next(`)`
  void concurrency(Iterable<Middleware<T>> middlewares) {
    use(getConcurrencyMiddleware(middlewares));
  }

  /// Clones an instance
  Composer<T> clone() {
    final composer = Composer<T>().._middlewares = [..._middlewares];

    return composer;
  }

  /// Compose middleware handlers into a single handler
  Middleware<T> compose() => compose_file.compose(_middlewares);
}
