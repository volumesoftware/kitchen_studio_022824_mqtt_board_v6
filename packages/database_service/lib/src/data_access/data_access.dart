abstract interface class DataAccess<T> {
  Future<int?> create(T t);

  Future<T?> getById(int id);

  Future<List<T>?> findAll();

  Future<List<T>?> search(String? where, {List<Object>? whereArgs});

  Future<int?> delete(int id);

  Future<T?> updateById(int id, T t);
}
