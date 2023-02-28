import 'package:ecommerce_app/models/models.dart';
import 'package:sqflite/sqlite_api.dart';
import 'package:sqflite/sqflite.dart' as sql;
import 'package:path/path.dart' as path;

class DBHelper {
  static Future<Database> database() async {
    final dbPath = await sql.getDatabasesPath();
    return sql.openDatabase(
      path.join(dbPath, 'myapp.db'),
      onCreate: (db, version) async {
        await db.execute(
          'CREATE TABLE products(id TEXT PRIMARY KEY, title TEXT, price REAL)',
        );
        await db.execute(
            ' CREATE TABLE invoices( id TEXT PRIMARY KEY, total_price REAL NOT NULL, datetime INTEGER NOT NULL, product_titles TEXT NOT NULL, product_prices TEXT NOT NULL, product_quantities INTEGER NOT NULL,is_deleted INTEGER NOT NULL DEFAULT 0)');
      },
      version: 1,
    );
  }

  static Future<void> insert(String table, Map<String, Object> data) async {
    final db = await DBHelper.database();
    await db.insert(
      table,
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<void> insertInvoice(
    String id,
    double totalPrice,
    int dateTime,
    List<String> productTitles,
    List<double> productPrices,
    List<int> productQuantities,
    int isDeleted,
  ) async {
    final db = await DBHelper.database();
    final productTitlesString = productTitles.join(',');
    final productPricesString =
        productPrices.map((p) => p.toString()).join(',');
    final productQuantitiesString =
        productQuantities.map((q) => q.toString()).join(',');
    await db.rawInsert('''
    INSERT INTO invoices (
      id, total_price, datetime,
      product_titles, product_prices, product_quantities, is_deleted
    ) VALUES (?, ?, ?, ?, ?, ?, ?)
  ''', [
      id,
      totalPrice,
      dateTime,
      productTitlesString,
      productPricesString,
      productQuantitiesString,
      isDeleted,
    ]);
  }

  static Future<void> deleteProduct(String productId) async {
    final db = await DBHelper.database();
    await db.delete(
      'products',
      where: 'id = ?',
      whereArgs: [productId],
    );
  }

  static Future<void> deleteInvoice(
      String invoiceId, String s, List<String> list) async {
    final db = await DBHelper.database();
    await db.update(
      'invoices',
      {'is_deleted': 1},
      where: 'id = ?',
      whereArgs: [invoiceId],
    );
  }

  static Future<List<Map<String, dynamic>>> getData(String table,
      {String? where, List<dynamic>? whereArgs}) async {
    final db = await DBHelper.database();
    return db.query(table, where: where, whereArgs: whereArgs);
  }
}
