import 'package:books/providers/read_state.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants.dart';
import '../providers/filter.dart';
import '../providers/genres.dart';
import '../widgets/combo_widget.dart';
import '../widgets/genre_list_widget.dart';

class FilterDrawer extends StatefulWidget {
  final void Function() pressDone;

  const FilterDrawer(this.pressDone, {Key? key}) : super(key: key);

  @override
  State<FilterDrawer> createState() => _FilterDrawerState();
}

class _FilterDrawerState extends State<FilterDrawer> {
  final TextEditingController _controllerName = TextEditingController();

  final TextEditingController _controllerAuthor = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final filterProvider = Provider.of<Filter>(context, listen: false);
    final filter = filterProvider.filter;
    final genres = Provider.of<Genres>(context, listen: false);

    _controllerName.text = filter.fltName;
    _controllerAuthor.text = filter.fltAuthor;

    return Drawer(
      child: Container(
        padding:
            const EdgeInsets.only(top: 40.0, left: 10, right: 10, bottom: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //фильтр по названию
            Row(children: [
              const Text(
                'наименование',
                style: kTextStyleLabel,
              ),
              const SizedBox(
                width: 10.0,
              ),
              Expanded(
                child: Container(
                  decoration: kInputBoxDecoration,
                  child: TextField(
                    key: const ValueKey('fNText'),
                    decoration: kInputFieldDecoration,
                    controller: _controllerName,
                    onChanged: (value) {
                      filter.fltName = value;
                    },
                  ),
                ),
              ),
              // IconButton(onPressed: (){
              //   _controllerName.text = '';
              // }, icon: const Icon(Icons.cancel_rounded, color: kInputColor,)),

            ]),
            const SizedBox(
              height: 5,
            ),
            //фильтр по автору
            Row(children: [
              const Text(
                'автор',
                style: kTextStyleLabel,
              ),
              const SizedBox(
                width: 10.0,
              ),
              Expanded(
                  child: Container(
                decoration: kInputBoxDecoration,
                child: TextField(
                  key: const ValueKey('fAText'),
                  decoration: kInputFieldDecoration,
                  controller: _controllerAuthor,
                  onChanged: (value) {
                    filter.fltAuthor = value;
                  },
                ),
              ))
            ]),
            const SizedBox(
              height: 5.0,
            ),
            FilterStateRadio(
                filter: filter,
                onPressIcon: () {
                  setState(() {
                    filter.fltExpandedState = !filter.fltExpandedState;
                  });
                }),
            //
            if (filter.fltExpandedState)
              SizedBox(
                height: 60,
                width: double.infinity,
                child: ComboWidget(
                  items: Provider.of<ReadStates>(context, listen: false)
                      .getListMap(),
                  onChange: (value) {
                    //print(value.toString());
                    filter.fltState = value!.toString();
                  },
                  initialValue: filter.fltState,
                  caption: 'статус',
                ),
              ),
            //******************
            const SizedBox(
              height: 5.0,
            ),
            // Checkbox(value: filter.fltActual, onChanged: (value){
            //   filter.fltActual = value!;
            // },
            // ),
            //******************
            FilterActualRadioBar(filter),
            //******************
            const SizedBox(
              height: 5.0,
            ),
            //фильтр по жанрам
            const Text(
              'жанры',
              style: kTextStyleLabel,
            ),
            const SizedBox(
              height: 5.0,
            ),
            Expanded(
              child: Container(
                decoration: kInputBoxDecoration,
                //padding: EdgeInsets.only(top:5),
                //color: Colors.red,
                child: GenreCheckList(filter.fltGenres),
              ),
            ),

            //ряд кнопок
            Row(
              children: [
                Expanded(
                    flex: 1,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2.0),
                      child: ElevatedButton(
                          onPressed: () async {
                            await filterProvider.readFilterData().then(
                                (value) =>
                                    Navigator.of(context).pushNamed('/'));
                          },
                          child: const Icon(Icons.arrow_back)),
                    )),
                Expanded(
                    flex: 2,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: ElevatedButton(
                          onPressed: () {
                            filterProvider.clearFilter();
                            genres.setCheckedValue('');
                            filterProvider.saveFilterData().then((value) =>
                                Navigator.of(context).pushNamed('/'));
                          },
                          child: const Text('сброс')),
                    )),
                Expanded(
                    flex: 2,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: ElevatedButton(
                          onPressed: () {
                            filter.fltSeries = '';
                            filter.fltGenres = genres.codeCheckString;
                            //print('on press DONE ${filter.fltGenres}');
                            widget.pressDone();
                            filterProvider.saveFilterData().then((value) =>
                                Navigator.of(context).pushNamed('/'));
                          },
                          child: const Text('готово')),
                    )),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class FilterStateRadio extends StatelessWidget {
  final FilterData filter;
  final void Function() onPressIcon;

  //const FilterStateRadio({Key? key}) : super(key: key);
  FilterStateRadio({required this.filter, required this.onPressIcon});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 30,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'статус',
            style: kTextStyleLabel,
          ),
          IconButton(
              onPressed: onPressIcon,
              icon: Icon(filter.fltExpandedState
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked)),
        ],
      ),
    );
  }
}

class FilterActualRadioBar extends StatefulWidget {
  final FilterData filter;

  FilterActualRadioBar(this.filter);

  @override
  State<FilterActualRadioBar> createState() => _FilterActualRadioBarState();
}

class _FilterActualRadioBarState extends State<FilterActualRadioBar> {
  void onActualToggle(bool? value) {
    setState(() {
      widget.filter.fltActual = value!;
    });
  }

  @override
  Widget build(BuildContext context) {
    TextStyle radioStyle(bool value) {
      return (widget.filter.fltActual == value)
          ? const TextStyle()
          : kTextStyleLabel;
    }

    return Row(
      children: [
        Text(
          'текущие',
          style: radioStyle(true),
        ),
        Radio<bool>(
          value: true,
          groupValue: widget.filter.fltActual,
          onChanged: onActualToggle,
        ),
        Expanded(child: Container()),
        Text(
          'aрхивные',
          style: radioStyle(false),
        ),
        Radio<bool>(
          value: false,
          groupValue: widget.filter.fltActual,
          onChanged: onActualToggle,
        ),
      ],
    );
  }
}
