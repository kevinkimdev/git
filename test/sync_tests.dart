part of console_test_harness;

class SyncTests {
  static void run() {
    test('true result is cool', _testTrueIsCool);
    test('false result fails', _testFalseIsFail);
    test('null result is sad', _testNullIsSad);
  }

  static void _testTrueIsCool() {
    final tasks = new Tasks();
    tasks.addTask('good', (ctx) => true);
    tasks.freeze();

    final runner = new Runner(tasks, ['good']);
    final future = runner.run();
    expect(future, isNotNull);
    expect(future.isComplete, isTrue);

    final onComplete = expectAsync1((f) {
      expect(f.value, isTrue);
    });

    future.onComplete(onComplete);
  }

  static void _testFalseIsFail() {
    final tasks = new Tasks();
    tasks.addTask('fail', (ctx) => false);
    tasks.freeze();

    final runner = new Runner(tasks, ['fail']);
    final future = runner.run();
    expect(future, isNotNull);
    expect(future.isComplete, isTrue);

    final onComplete = expectAsync1((f) {
      expect(f.value, isFalse);
    });

    future.onComplete(onComplete);
  }

  static void _testNullIsSad() {
    final tasks = new Tasks();
    tasks.addTask('null', (ctx) => null);
    tasks.freeze();

    final runner = new Runner(tasks, ['null']);
    final future = runner.run();
    expect(future, isNotNull);
    expect(future.isComplete, isTrue);

    final onComplete = expectAsync1((Future f) {
      expect(f.exception, isNotNull);
    });

    future.onComplete(onComplete);
  }
}