import 'package:flutter/foundation.dart';

enum JenisTransaksi{
  pemasukan,
  pengeluaran}

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
    if (jenisTransaksi == JenisTransaksi.pemasukan.name){
      return Transaksi(id: id, nominal: nominal, deskripsi: deskripsi, jenisTransaksi: JenisTransaksi.pemasukan, createdAt: createdAt);
    } else if(jenisTransaksi == JenisTransaksi.pengeluaran.name){
      return Transaksi(id: id, nominal: nominal, deskripsi: deskripsi, jenisTransaksi: JenisTransaksi.pengeluaran, createdAt: createdAt);
    } else {
      throw ArgumentError('Tipe Transaksi Tidak Valid : $jenisTransaksi');
    }
  }

  factory Transaksi.fromJson(Map<String, dynamic> json) {

    final createdAt = DateTime.tryParse(json['tanggalTransaksi'] ?? '');

    return Transaksi(
      id: json['id'].toString(),
      nominal: json['nominal'],
      deskripsi: json['deskripsi'],
      jenisTransaksi: JenisTransaksi.values.firstWhere(
              (e) => e.name == (json['jenisTransaksi'] as String),
          orElse: () => throw ArgumentError('Tipe Transaksi Tidak Valid : ${json['jenisTransaksi']}')
      ),
      createdAt: createdAt ?? DateTime.parse(json['tanggalTransaksi']),
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