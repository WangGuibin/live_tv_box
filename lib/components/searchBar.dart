import 'package:flutter/material.dart';

class CustomSearchBar extends StatefulWidget {
  final Function(String query) onQueryChanged;

  const CustomSearchBar({super.key, required this.onQueryChanged});

  @override
  _CustomSearchBarState createState() => _CustomSearchBarState();
}

class _CustomSearchBarState extends State<CustomSearchBar> {
  String query = '';

  void onQueryChanged(String newQuery) {
    setState(() {
      query = newQuery;
      widget.onQueryChanged(newQuery);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: TextField(
        onChanged: onQueryChanged,
        decoration: const InputDecoration(
          labelText: '请输入关键字进行搜索',
          border: OutlineInputBorder(),
          prefixIcon: Icon(Icons.search),
        ),
      ),
    );
  }
}
