import 'package:flutter/material.dart';

class NumberPicker extends StatefulWidget {
  const NumberPicker({Key? key}) : super(key: key);

  @override
  State<NumberPicker> createState() => _NumberPickerState();
}

class _NumberPickerState extends State<NumberPicker> {
  int _currentHorizontalIntValue = 0;

  TextEditingController _valueController = TextEditingController();

  @override
  void initState() {
    _valueController =
        TextEditingController(text: "$_currentHorizontalIntValue");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.black26, style: BorderStyle.solid)),
      child: Stack(
        children: [
      Positioned(bottom: 5, top: 5, right: 5, left: 5,child:           Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => setState(() {
              final newValue = _currentHorizontalIntValue + 1;
              _currentHorizontalIntValue = newValue.clamp(0, 100);
              setState(() {
                _valueController.text = "$_currentHorizontalIntValue";
              });
            }),
          ),
          SizedBox(
            width: 100,
            child: TextFormField(
              controller: _valueController,
              decoration: const InputDecoration(border: OutlineInputBorder(), labelText: "Cycle"),
              onChanged: (value) {
                setState(() {
                  _currentHorizontalIntValue = int.parse(value);
                });
              },
            ),
          ),
          IconButton(
            icon: const Icon(Icons.remove),
            onPressed: () => setState(() {
              final newValue = _currentHorizontalIntValue - 1;
              _currentHorizontalIntValue = newValue.clamp(0, 100);
              setState(() {
                _valueController.text = "$_currentHorizontalIntValue";
              });
            }),
          ),
        ],
      ),),

          const Positioned(top: 5, right: 5, left: 5,child: Text("Cycle count", textAlign: TextAlign.center,),),

        ],
      ),
    );
  }
}
