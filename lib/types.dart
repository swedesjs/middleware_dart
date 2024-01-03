/// Returns the type of response middleware
typedef NextMiddlewareReturn = dynamic;

/// Call the next middleware from the chain
typedef NextMiddleware = NextMiddlewareReturn Function();

// ignore: public_member_api_docs
typedef Middleware<T> = dynamic Function(T context, NextMiddleware next);

/// Asynchronous function for branch condition
typedef BranchMiddlewareConditionFunction<T> = Future<bool> Function(T context);

/// Possible types for branch condition
void branchMiddlewareCondition<T>(condition) {
  assert(
    condition is BranchMiddlewareConditionFunction<T> || condition is bool,
    'The condition parameter must be one of the types: Function or bool',
  );
}

/// Asynchronous factory to create middleware
typedef LazyMiddlewareFactory<T> = Future<Middleware<T>> Function(T context);

/// Handler for catching errors in middleware chains
typedef CaughtMiddlewareHandler<T> = dynamic Function(
  T context,
  Exception error,
);
