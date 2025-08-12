class Calculator {
  int factorial(int n) {
    if (n <= 1) {
      return 1;
    }
    return n * factorial(n - 1);
  }

  int fibonacci(int n) {
    if (n <= 1) return n;

    int a = 0, b = 1;
    for (int i = 2; i <= n; i++) {
      int temp = a + b;
      a = b;
      b = temp;
    }
    return b;
  }

  List<int> processNumbers(List<int> numbers) {
    List<int> result = [];

    for (int num in numbers) {
      if (num < 0) {
        continue; // Skip negative numbers
      }

      if (num > 100) {
        break; // Stop at large numbers
      }

      try {
        int processed = num * 2;
        result.add(processed);
      } catch (e) {
        print('Error processing $num: $e');
        throw Exception('Processing failed');
      }
    }

    return result;
  }

  void demonstrateUnreachableCode(bool condition) {
    print('Start');

    if (condition) {
      return; // Early return
    }

    print('This might not be reached');

    if (true) {
      return; // Another early return
    }

    print('This is definitely unreachable'); // Dead code
    int x = 42; // More dead code
  }
}

int globalFunction(int x) {
  while (x > 0) {
    x--;
    if (x == 5) {
      continue;
    }
    if (x == 2) {
      break;
    }
  }
  return x;
}