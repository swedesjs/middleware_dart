class ContextTest {
  ContextTest(this.now);
  DateTime? now;
}

enum CloneContextValue { first, def, second }

class CloneContext {
  CloneContext({required this.value, this.baseValue});
  bool? baseValue;
  CloneContextValue value;
}
