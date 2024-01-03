// ignore_for_file: avoid_print

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
