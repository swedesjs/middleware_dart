import 'package:middleware_dart/middleware_dart.dart';
import 'package:test/test.dart';

import 'contexts.dart';
import 'middleware_test.dart';

void main() {
  group('Composer', () {
    test('should work', () async {
      final out = List<int>.empty(growable: true);

      final composer = Composer()
        ..use((context, next) async {
          out.add(1);
          await delay();
          await next();
          await delay();
          out.add(6);
        })
        ..use((context, next) async {
          out.add(2);
          await delay();
          await next();
          await delay();
          out.add(5);
        })
        ..use((context, next) async {
          out.add(3);
          await delay();
          await next();
          await delay();
          out.add(4);
        });

      final middleware = composer.compose();
      await middleware([], noopNext);

      expect(out, equals([1, 2, 3, 4, 5, 6]));
    });
    test('should keep the context', () async {
      final ctx = <Map<dynamic, dynamic>>{};
      final composer = Composer()
        ..use((context, next) async {
          await next();
          expect(context, ctx);
        })
        ..use((context, next) async {
          await next();
          expect(context, ctx);
        })
        ..use((context, next) async {
          await next();
          expect(context, ctx);
        });

      final middleware = composer.compose();
      await middleware(ctx, noopNext);
    });
    test('should work with 0 middleware', () async {
      final middleware = Composer().compose();

      await middleware({}, noopNext);
    });
    test('should reject on errors in middleware', () async {
      final composer = Composer<ContextTest>()
        ..use((context, next) {
          context.now = DateTime.now();
        })
        ..use((context, next) {
          throw Exception();
        });

      final middleware = composer.compose();
      try {
        await middleware(ContextTest(null), noopNext);
      } on Exception catch (error) {
        expect(error, throwsA(isA<Exception>()));
        return;
      }
    });
    test('composer should be cloned', () async {
      final baseComposer = Composer<CloneContext>()
        ..use((context, next) {
          context.baseValue = true;

          return next();
        });

      final firstComposer = baseComposer.clone()
        ..use((context, next) {
          context.value = CloneContextValue.first;
          return next();
        });

      final secondComposer = baseComposer.clone()
        ..use((context, next) {
          context.value = CloneContextValue.second;
          return next();
        });

      final baseContext = CloneContext(value: CloneContextValue.def);
      final firstContext = CloneContext(value: CloneContextValue.first);
      final secondContext = CloneContext(value: CloneContextValue.second);

      await baseComposer.compose()(baseContext, noopNext);
      await firstComposer.compose()(firstContext, noopNext);
      await secondComposer.compose()(secondContext, noopNext);

      expect(baseContext.baseValue, equals(true));
      expect(baseContext.value, equals(CloneContextValue.def));

      expect(firstContext.baseValue, equals(true));
      expect(firstContext.value, equals(CloneContextValue.first));

      expect(secondContext.baseValue, equals(true));
      expect(secondContext.value, equals(CloneContextValue.second));
    });
    test('should correctly display the number of middleware', () async {
      final composer = Composer();

      expect(composer.lenght, equals(0));

      composer.tap((context, next) {});
      expect(composer.lenght, equals(1));
      composer.tap((context, next) {});
      expect(composer.lenght, equals(2));
    });
    test('should create new instance of the Composer class', () {
      final composer = Composer<Map<String, dynamic>>()
        ..use((context, next) {
          if (context['text'] == 'aaa') {
            //...
          }
        });

      expect(composer.lenght, equals(1));
    });
    test('should throw if next() is called multiple time', () async {
      final composer = Composer()
        ..use((context, next) async {
          await next();
        })
        ..use((context, next) async {
          await next();
          await next();
        })
        ..use((context, next) async {
          await next();
        });

      final middleware = composer.compose();

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
