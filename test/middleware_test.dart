import 'package:middleware_dart/middleware_dart.dart';
import 'package:test/test.dart';

import 'contexts.dart';

// ignore: prefer_expression_function_bodies
Future<dynamic> delay() {
  return Future.delayed(const Duration(milliseconds: 1));
}

void main() {
  group('compose', () {
    test('should work', () async {
      final out = List<int>.empty(growable: true);

      final middleware = compose([
        (context, next) async {
          out.add(1);
          await delay();
          await next();
          await delay();
          out.add(6);
        },
        (context, next) async {
          out.add(2);
          await delay();
          await next();
          await delay();
          out.add(5);
        },
        (context, next) async {
          out.add(3);
          await delay();
          await next();
          await delay();
          out.add(4);
        }
      ]);

      await middleware([], noopNext);

      expect(out, equals([1, 2, 3, 4, 5, 6]));
    });

    test('should keep the context', () async {
      final ctx = <Map<dynamic, dynamic>>{};

      final middleware = compose([
        (context, next) async {
          await next();
          expect(context, ctx);
        },
        (context, next) async {
          await next();
          expect(context, ctx);
        },
        (context, next) async {
          await next();
          expect(context, ctx);
        }
      ]);

      await middleware(ctx, noopNext);
    });

    test('should work with 0 middleware', () async {
      final middleware = compose<dynamic>([]);

      await middleware(<Map<dynamic, dynamic>>{}, noopNext);
    });

    test('should reject on errors in middleware', () async {
      final middleware = compose<ContextTest>([
        (context, next) async {
          context.now = DateTime.now();
        },
        (context, next) {
          throw Exception();
        }
      ]);

      try {
        await middleware(ContextTest(null), noopNext);
      } on Exception catch (error) {
        expect(error, throwsA(isA<Exception>()));
        return;
      }
    });

    test('should throw if next() is called multiple time', () async {
      final middleware = compose([
        (context, next) async {
          await next();
        },
        (context, next) async {
          await next();
          await next();
        },
        (context, next) async {
          await next();
        }
      ]);

      try {
        await middleware([], noopNext);
      } on Exception catch (error) {
        expect(
          error.toString(),
          equals('Exception: next() called multiple times'),
        );
      }
    });
  });
}
