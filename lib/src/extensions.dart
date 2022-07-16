extension ListGetExtension<T> on List<T> {
  T? tryGet(int? index) =>
      index == null || index < 0 || index >= length ? null : this[index];
}
