import 'package:flutter/foundation.dart';

enum JenisTransaksi{
  income,
  outcome}

class Transaksi{
  final String id;
  final int nominal;
  final String deskripsi;
  final JenisTransaksi jenisTransaksi;
  final DateTime createdAt;

  Transaksi({
    required this.id,
    required this.nominal,
    required this.deskripsi,
    required this.jenisTransaksi,
    required this.createdAt
  });

  factory Transaksi.fromJenisTransaksiString(String id, int nominal, String deskripsi, String jenisTransaksi, DateTime createdAt){
    if (jenisTransaksi == JenisTransaksi.income.name){
      return Transaksi(id: id, nominal: nominal, deskripsi: deskripsi, jenisTransaksi: JenisTransaksi.income, createdAt: createdAt);
    } else if(jenisTransaksi == JenisTransaksi.outcome.name){
      return Transaksi(id: id, nominal: nominal, deskripsi: deskripsi, jenisTransaksi: JenisTransaksi.outcome, createdAt: createdAt);
    } else {
      throw ArgumentError('Tipe Transaksi Tidak Valid : $jenisTransaksi');
    }
  }

  factory Transaksi.fromJson(Map<String, dynamic> json) {
    // --- KONVERSI DARI MAP KE TIPE DATA DI MODEL (DATETIME, INT) ---
    // Nominal: Ambil dari JSON. Jika datang sebagai String (dari API), parse ke int. Jika sudah int (dari SQLite), langsung pakai.
    final int parsedNominal = json['nominal'] is int
        ? json['nominal'] as int // Jika sudah int, langsung cast
        : int.parse(json['nominal'].toString()); // Jika String, convert ke String dulu lalu parse

    // CreatedAt: Ambil dari JSON. Bisa datang sebagai int (dari SQLite) atau String (dari API).
    final DateTime parsedCreatedAt;
    if (json['createdAt'] is int) {
      // Jika datang dari SQLite (INTEGER Unix timestamp)
      parsedCreatedAt = DateTime.fromMillisecondsSinceEpoch(json['createdAt'] as int);
    } else if (json['createdAt'] is String) {
      // Jika datang dari API (STRING ISO 8601)
      parsedCreatedAt = DateTime.parse(json['createdAt'] as String);
    } else {
      // Jika tipe tidak dikenal, lempar error agar tahu
      throw ArgumentError('Tipe createdAt tidak valid: ${json['createdAt'].runtimeType}');
    }

    return Transaksi(
      id: json['id'] as String, // ID: Pastikan di-cast ke String
      nominal: parsedNominal,
      deskripsi: json['deskripsi'] as String, // Deskripsi: Pastikan di-cast ke String
      jenisTransaksi: JenisTransaksi.values.firstWhere(
              (e) => e.name == (json['jenisTransaksi'] as String), // Jenis Transaksi: Pastikan di-cast ke String
          orElse: () => throw ArgumentError('Tipe Transaksi Tidak Valid : ${json['jenisTransaksi']}')
      ),
      createdAt: parsedCreatedAt,
    );
  }

  Map<String, dynamic> toJson(){
    return {
      'id' : id,
      'nominal' : nominal,
      'deskripsi': deskripsi,
      'jenisTransaksi': jenisTransaksi.name,
      'createdAt': createdAt.toIso8601String()
    };
  }
}