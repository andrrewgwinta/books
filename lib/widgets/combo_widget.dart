import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../constants.dart';

typedef OnWidgetSizeChange = void Function(Size size);

class MeasureSizeRenderObject extends RenderProxyBox {
  late Size oldSize;
  final OnWidgetSizeChange onChange;

  MeasureSizeRenderObject(this.onChange);

  @override
  void performLayout() {
    super.performLayout();

    Size newSize = child!.size;
    if (oldSize == newSize) return;

    oldSize = newSize;
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      onChange(newSize);
    });
  }
}

class MeasureSize extends SingleChildRenderObjectWidget {
  final OnWidgetSizeChange onChange;

  const MeasureSize({
    Key? key,
    required this.onChange,
    required Widget child,
  }) : super(key: key, child: child);

  @override
  RenderObject createRenderObject(BuildContext context) {
    return MeasureSizeRenderObject(onChange);
  }
}

class ComboWidget extends StatefulWidget {
  ComboWidget(
      {Key? key, required this.items,
       required this.onChange,
       required this.initialValue,
        this.caption='',
        this.aWidth=0}) : super(key: key);

  //final List<Map<String, String>> items;
  final List<NsiRecord> items;
  final void Function(Object?) onChange;
  final String initialValue;
  String caption;
  double aWidth;

  @override
  State<ComboWidget> createState() => _ComboWidgetState();
}

class _ComboWidgetState extends State<ComboWidget> {
  String comboValue = '';
  List<DropdownMenuItem<String>> _menuItems = [];
  bool doInit = true;

  List<DropdownMenuItem<String>> getMenuItem() {
    List<DropdownMenuItem<String>> result = [];
    for (NsiRecord data in widget.items) {
      result.add(DropdownMenuItem(
        value: data.id.toString(),
        child: Text(data.name.toString(), softWrap: true),
      ));
    }
    return result;
  }

  void localChangeChoice(Object? selectedString) {
    setState(() {
      comboValue = selectedString!.toString();
      widget.onChange(comboValue);
    });
  }

  @override
  void initState() {
    super.initState();
    _menuItems = getMenuItem();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (doInit) {
      comboValue = widget.initialValue;
    }
    doInit = false;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.aWidth,
      height: 40,
      decoration: kBoxDecorationComboBox,
      // decoration: BoxDecoration(
      margin: const EdgeInsets.all(5),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: DropdownButton(
          isExpanded: true,
          borderRadius: BorderRadius.circular(8),
          dropdownColor: Colors.lightBlueAccent,
          icon: const Icon(
            Icons.signal_cellular_4_bar,
            color: Colors.blue,
          ),
          value: comboValue.isEmpty?_menuItems.first.value:comboValue,
          items: _menuItems,
          onChanged: localChangeChoice,
          underline: const Text(''),
        ),
      ),
    );
  }
}
