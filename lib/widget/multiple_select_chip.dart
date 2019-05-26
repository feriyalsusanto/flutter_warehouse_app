import 'package:flutter/material.dart';
import 'package:pina_warehouse/entity/category_entity.dart';

class MultiSelectChip extends StatefulWidget {
  final List<Category> categoryList;
  final List<Category> selectedChoices;
  final Function(List<Category>) onSelectionChanged;

  MultiSelectChip(this.categoryList, this.selectedChoices,
      {this.onSelectionChanged});

  @override
  _MultiSelectChipState createState() => _MultiSelectChipState();
}

class _MultiSelectChipState extends State<MultiSelectChip> {
  List<Category> selectedChoices = List();

  _buildChoiceList() {
    List<Widget> choices = List();
    selectedChoices = widget.selectedChoices;

    widget.categoryList.forEach((item) {
      choices.add(Container(
        padding: const EdgeInsets.all(2.0),
        child: ChoiceChip(
          label: Text(item.name),
          selected: selectedChoices.contains(item),
          onSelected: (selected) {
            setState(() {
              selectedChoices.contains(item)
                  ? selectedChoices.remove(item)
                  : selectedChoices.add(item);
              widget.onSelectionChanged(selectedChoices);
            });
          },
        ),
      ));
    });

    return choices;
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: _buildChoiceList(),
    );
  }
}
