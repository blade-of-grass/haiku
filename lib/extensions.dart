import 'dart:math';

abstract class WeightedItem {
  int get weight;
}

extension ListExtensions<T> on List<T> {
  T getRandomElement(Random random) => this[random.nextInt(this.length)];

  List<T> chainedSort([int compare(T a, T b)]) {
    this.sort(compare);
    return this;
  }
}

extension WeightedListExtensions<T extends WeightedItem> on List<T> {
  T getRandomWeightedElement(Random random) {
    int totalWeight = 0;
    for (final item in this) {
      totalWeight += item.weight;
    }

    int index = random.nextInt(totalWeight);
    for (final item in this) {
      index -= item.weight;
      if (index <= 0) {
        return item;
      }
    }

    throw Exception("this should never happen");
  }
}
