import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:godvlan/model/Transaksi.dart';
class SqliteHelper {
  static Database? _database;

  SqliteHelper._privateConstructor();
  static final SqliteHelper instance = SqliteHelper._privateConstructor();

  Future<Database> get database async {
    if(_database != null){
      return _database!;
    }

    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final directory = await getDatabasesPath();
    final path = join(directory, 'transactionDatabase.db');
    final query = '''
    CREATE TABLE Transaksi(
      id TEXT PRIMARY KEY,
      nominal INTEGER NOT NULL,
      deskripsi TEXT,
      jenisTransaksi TEXT CHECK(jenisTransaksi IN ('income', 'outcome')) NOT NULL,
      createdAt INTEGER NOT NULL
    )
  ''';

    return await openDatabase(path, version : 1, onCreate: (db, version) {
      return db.execute(query);});
  }

  Future<int> insertTransaction(Transaksi transaksi) async {
    final db = await instance.database;
    final Map<String, dynamic> mapToInsert = {
      'id': transaksi.id,
      'nominal': transaksi.nominal,
      'deskripsi': transaksi.deskripsi,
      'jenisTransaksi': transaksi.jenisTransaksi.name,
      'createdAt': transaksi.createdAt.millisecondsSinceEpoch,
    };
    // print('Inserting into DB: $mapToInsert'); // Untuk debugging
    return db.insert('Transaksi', mapToInsert, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Transaksi>> getAllTransaction() async {
    final db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query('Transaksi', orderBy: 'createdAt DESC');
    return List.generate(maps.length, (i) {
      final Map<String, dynamic> row = Map<String, dynamic>.from(maps[i]);
      // row['createdAt'] = DateTime.fromMillisecondsSinceEpoch(row['createdAt']);
      return Transaksi.fromJson(row);
    });
  }

  Future<Transaksi?> getTransactionById(String id) async {
    final db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query('Transaksi', where: 'id = ?', whereArgs: [id]);
    if (maps.isNotEmpty){
      final Map<String, dynamic> row = Map<String, dynamic>.from(maps.first);
      row['createdAt'] = DateTime.fromMillisecondsSinceEpoch(row['createdAt']);
      return Transaksi.fromJson(row);
    }
    return null;
  }
  
  Future<List<Transaksi>> getTransactionByYear(int year) async {
    final db = await instance.database;
    final startYear = DateTime(year, 1, 1).millisecondsSinceEpoch;
    final endYear = DateTime(year + 1, 1, 1).millisecondsSinceEpoch - 1;
    final List<Map<String, dynamic>> maps = await db.query(
        'Transaksi',
        where : 'createdAt >= ? AND createdAt <= ?',
        whereArgs: [startYear, endYear],
        orderBy: 'createdAt DESC');
    return List.generate(maps.length, (i){
      final Map<String, dynamic> row = Map<String, dynamic>.from(maps[i]);
      // row['createdAt'] = DateTime.fromMillisecondsSinceEpoch(row['createdAt']);
      return Transaksi.fromJson(row);
    });
  }

  Future<int> updateTransaction(Transaksi transaksi) async {
    final db = await instance.database;
    final map = transaksi.toJson();
    map['createdAt'] = transaksi.createdAt.millisecondsSinceEpoch;
    return await db.update(
      'Transaksi',
      map,
      where: 'id = ?',
      whereArgs: [transaksi.id],
    );
  }

  Future<int> deleteTransaction(String id) async {
    final db = await instance.database;
    return await db.delete(
      'Transaksi',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}