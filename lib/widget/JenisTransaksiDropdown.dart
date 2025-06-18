import 'package:flutter/material.dart';

class JenisTransaksiDropdown extends StatefulWidget{
  final Function(String? value) onItemSelected;

  const JenisTransaksiDropdown({
    super.key,
    required this.onItemSelected
  });

  @override
  _JenisTransaksiDropdown createState() => _JenisTransaksiDropdown();
}

class _JenisTransaksiDropdown extends State<JenisTransaksiDropdown>{

  @override
  Widget build(BuildContext context) {
    return DropdownMenu<String?>(
      leadingIcon: Icon(Icons.currency_exchange_rounded,color:  Color(0xff8480e5)),
      hintText: "Pilih Jenis Transaksi",
      width: MediaQuery.of(context).size.width * 0.80,
      dropdownMenuEntries: <DropdownMenuEntry<String?>>
      [
        DropdownMenuEntry(value: "pemasukan", label: "Pemasukan"),
        DropdownMenuEntry(value: "pengeluaran", label: "Pengeluaran")
      ],
      textStyle: const TextStyle(
        color: Color(0xff7971ea)
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: UnderlineInputBorder(
            borderSide: BorderSide(
                color: Color(0xff7971ea),
                width: 2
            )
        ),
        focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(
                color: Color(0xff7971ea),
                width: 2
            )
        ),
        errorBorder: UnderlineInputBorder(
            borderSide: BorderSide(
                color: Colors.redAccent,
                width: 2
            )
        ),
        hintStyle: TextStyle(color: Color(0xff7971ea)),
      ),
      onSelected: (String? value) {
        widget.onItemSelected(value);
      },
    );
  }
}