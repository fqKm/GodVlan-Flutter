import 'package:flutter/material.dart';

class JenisTransaksiDropdown extends StatefulWidget{
  final Function(String? value) onItemSelected;
  final String? initialValue;

  const JenisTransaksiDropdown({
    super.key,
    this.initialValue,
    required this.onItemSelected
  });

  @override
  _JenisTransaksiDropdown createState() => _JenisTransaksiDropdown();
}

class _JenisTransaksiDropdown extends State<JenisTransaksiDropdown>{
  String? selectedValue;
  @override
  void initState() {
    selectedValue = widget.initialValue;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DropdownMenu<String?>(
      hintText: "Masukkan Jenis Transaksi",
      initialSelection: selectedValue,
      leadingIcon: Icon(Icons.currency_exchange_rounded,color:  Color(0xff8480e5)),
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
        setState(() {
          selectedValue = value;
        });
        widget.onItemSelected(value);
      },
    );
  }
}