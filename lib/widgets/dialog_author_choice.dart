import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
//import 'package:scroll_to_index/scroll_to_index.dart';

//import '../providers/books.dart';
import '../providers/authors.dart';
import '../constants.dart';


class DialogAuthorChoice extends StatefulWidget {
  Author author;
  final void Function() pressOK;
  final AuthorListType authorListType;
  final String caption;

  DialogAuthorChoice({
    required this.authorListType,
    required this.author,
    this.caption = 'выбираем автора',
    required this.pressOK});

  @override
  State<DialogAuthorChoice> createState() => _DialogAuthorChoiceState();
}

class _DialogAuthorChoiceState extends State<DialogAuthorChoice> {
  final ScrollController  _controller = ScrollController();
  late List<Author> authors;
  //late int _index;
  bool isFirst = true;

  bool isInit = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (isInit) {
      // _controller = AutoScrollController(
      //     viewportBoundaryGetter: () =>
      //         Rect.fromLTRB(0, 0, 0, MediaQuery.of(context).padding.bottom),
      //     axis: Axis.vertical);
      if (widget.authorListType == AuthorListType.altAll){
        authors = Provider
            .of<Authors>(context, listen: false)
            .items;
      }
      else
      if (widget.authorListType == AuthorListType.altActual){
        authors = Provider
            .of<Authors>(context, listen: false)
            .itemsActual;
      }
      else
      if (widget.authorListType == AuthorListType.altChecked){
        authors = Provider
            .of<Authors>(context, listen: false)
            .itemsChecked;
      }
      //_index = authors.indexOf(authors.firstWhere((element) => element.id==widget.book.authorId));
      //print(_index.toString());
    }
    isInit = false;
  }


  @override
  Widget build(BuildContext context) {
    // if (isFirst) {
    //   print('isFirst true');
    //   _controller.scrollToIndex(_index, preferPosition: AutoScrollPosition.begin);
    //   // AutoScrollTag(
    //   //   key: ValueKey(_index),
    //   //   controller: _controller,
    //   //   index: _index,
    //   //   child: widget,
    //   //   highlightColor: Colors.black.withOpacity(0.1),
    //   // );
    // }
    isFirst = false;
    return SimpleDialog(
      title: Text(widget.caption),
      children: [
        SizedBox(
          width: 300,
          height: 200,
          // MediaQuery.of(context).size.height -
          //     250,
          child: ListView.builder(
              controller: _controller,
              itemCount: authors.length,
              itemBuilder: (ctx, index) {
                //print('$index - ${_controller.offset}');
                  return GestureDetector(
                    onTap: (){
                      //print('onTap ${authors[index].toString()}');
                      widget.author.id = authors[index].id;
                      widget.author.nameRus = authors[index].nameRus;
                    widget.pressOK();
                    },
                    child: Card(child: Row(
                      children: [
                        const SizedBox(width: 10, height: 20,),
                        Expanded(child: Text(authors[index].nameRus,
                          overflow: TextOverflow.ellipsis,)),
                      ],
                    ),),
                  );},
          ),
        ),
      ],
    );
  }
}