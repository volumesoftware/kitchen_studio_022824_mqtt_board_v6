abstract interface class DataAccess<T> {
  Future<int?> create(T t);

  Future<T?> getById(int id);

  Future<List<T>?> findAll();

  Future<List<T>?> search(String? where, {bool? distinct,
    List<String>? columns,
    List<Object?>? whereArgs,
    String? groupBy,
    String? having,
    String? orderBy,
    int? limit,
    int? offse});

  Future<int?> delete(int id);

  Future<T?> updateById(int id, T t);
}
