import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants.dart';
import '../providers/authors.dart';
import '../providers/filter.dart';
import '../screens/author_screen_add.dart';
import '../widgets/dialog_author_choice.dart';
import '../screens/books_screen_overview.dart';

class AuthorScreen extends StatefulWidget {
  static const routeName = '/author_nsi';

  const AuthorScreen({Key? key}) : super(key: key);

  @override
  State<AuthorScreen> createState() => _AuthorScreenState();
}

class _AuthorScreenState extends State<AuthorScreen> {
  bool isJoinMode = false;
  String _currentSearchString = '';
  Timer? searchDebounce;
  final TextEditingController _controllerSearch = TextEditingController();

  void modifyRecord(BuildContext context,
      Author author,) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      //вот так клавиатура не будет заслонять вылезший БоттомШит
      builder: (BuildContext context) =>
          SingleChildScrollView(
            padding:
            EdgeInsets.only(bottom: MediaQuery
                .of(context)
                .viewInsets
                .bottom),
            child: AddAuthorScreen(
              author: author,
            ),
          ),
    );
  }

  @override
  void initState() {
    super.initState();
    _controllerSearch.text = '';
  }

  @override
  void dispose() {
    _controllerSearch.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authors = Provider.of<Authors>(context);
    List<Author> authorsData = authors.getFilteredAuthors(_currentSearchString);

    return Scaffold(
        floatingActionButton: FloatingActionButton(
          child: Icon(
            isJoinMode ? Icons.merge_type_sharp : Icons.add,
            size: 40,
          ),
          onPressed: () {
            if (isJoinMode) {
              showDialog(
                  context: context,
                  builder: (context) {
                    if (authors.emptyChecked) {
                      return AlertDialog(
                        title: const Text('нет отмеченных для слияния'),
                        actions: [
                          ElevatedButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: const Text('   OK   ')),
                        ],
                      );
                    } else {
                      final Author choicerAuthor = Author(id: '0', nameRus: '');
                      return DialogAuthorChoice(
                        authorListType: AuthorListType.altChecked,
                        author: choicerAuthor,
                        caption: 'кого оставить?',
                        pressOK: () {
                          setState(() {
                            authors.mergingAuthors(choicerAuthor.id);
                            Navigator.of(context).pop();
                          });
                        },
                      );
                    }
                  });

              setState(() {
                isJoinMode = false;
              });
            } else {
              final Author author = Author(id: '0');
              modifyRecord(context, author);
            }
          },
        ),
        appBar: AppBar(
          title: Text('Авторы${isJoinMode ? '.слияние' : ''}'),
          actions: [
            Switch(
              value: isJoinMode,
              activeColor: Colors.white,
              onChanged: (value) {
                setState(() {
                  isJoinMode = value;
                });
              },
            )
          ],
        ),
        body: Column(
          children: [
            // Container(
            //   height: 80,
            //   color: Colors.yellow,
            //   //************ search text
            //   child:
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controllerSearch,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color(0xFF4d4dff),
                        border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        prefixIcon: const Icon(
                          Icons.search,
                          color: Colors.white,
                        ),
                        //suffixIcon: const Icon(Icons.clear, color:Colors.white),
                        hintText: 'поиск по имени',
                        hintStyle: const TextStyle(color: Colors.grey),
                      ),
                      onChanged: (value) {
                        _currentSearchString = value;
                        searchDebounce?.cancel();
                        searchDebounce =
                            Timer(const Duration(milliseconds: 500), () {
                              setState(() {
                                //reread authorList
                              });
                            });
                      },
                    ),
                  ),
                  IconButton(
                      onPressed: () {
                        setState(() {
                          _currentSearchString = '';
                          _controllerSearch.text = '';
                        });
                      },
                      icon: const Icon(Icons.clear, color: Colors.blue))
                ],
              ),
            ),

            //***********  end search text
            //),
            Expanded(
              child: ListView.builder(
                  itemCount: authorsData.length,
                  itemBuilder: (ctx, index) {
                    return AuthorCard(authorsData[index], isJoinMode,
                        //тап на редактироваии
                            () {
                          modifyRecord(context, authorsData[index]);
                        });
                  }),
            ),
          ],
        ));
  }
}

class AuthorCard extends StatefulWidget {
  final Author author;
  final void Function() onEditTap;
  final bool joinMode;

  const AuthorCard(this.author, this.joinMode, this.onEditTap, {Key? key})
      : super(key: key);

  @override
  State<AuthorCard> createState() => _AuthorCardState();
}

class _AuthorCardState extends State<AuthorCard> {
  @override
  Widget build(BuildContext context) {
    final String question =
    (widget.author.actual) ? 'Удаляем' : 'Восстанавливаем';
    return Dismissible(
      //*********************
      background: Container(
        color:
        widget.author.actual ? Colors.blueAccent : Colors.lightBlueAccent,
        child: Icon(
          widget.author.actual ? Icons.delete : Icons.restore_from_trash,
          color: Colors.white,
          size: 40,
        ),
      ),
      key: ValueKey(widget.author.id),
      direction: (widget.joinMode)
          ? DismissDirection.none
          : DismissDirection.endToStart,
      onDismissed: (_) {},
      confirmDismiss: (direction) {
        return showDialog(
            context: context,
            builder: (ctx) {
              return AlertDialog(
                title: Text('$question "${widget.author.nameRus}"'),
                content: const Text('Вы уверены?'),
                actions: [
                  ElevatedButton(
                    child: const Text('НЕТ'),
                    onPressed: () {
                      Navigator.of(ctx).pop(false);
                    },
                  ),
                  ElevatedButton(
                      child: const Text('ДА'),
                      onPressed: () {
                        setState(() {
                          widget.author.actual = !widget.author.actual;
                          widget.author.actualOnServer();
                        });
                        Navigator.of(ctx).pop(false);
                      }),
                ],
              );
            });
      },

      //*********************
      child: SizedBox(
        height: (widget.author.nameOrig == '') ? 60 : 80,
        child: GestureDetector(
          //onDoubleTap: () {},
          onTap: widget.joinMode ? null : widget.onEditTap,
          child: Card(
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            elevation: 8,
            shadowColor: Colors.deepPurple,
            //color: Colors.grey,
            child: ListTile(
              title: Text(
                widget.author.nameRus,
                style: TextStyle(
                  fontSize: 16,
                  color: (widget.author.actual) ? Colors.black : Colors.grey,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: (widget.author.nameOrig == '')
                  ? null
                  : Row(
                children: [
                  const Text(
                    'ориг',
                    style: kTextStyleLabel,
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  Text(
                    widget.author.nameOrig,
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
              trailing: (widget.joinMode)
                  ? Checkbox(
                value: widget.author.checkState,
                onChanged: (value) {
                  setState(() {
                    widget.author.checkState = value!;
                  });
                },
              )
                  : IconButton(
                onPressed: () {
                  final fd = Provider.of<Filter>(context, listen: false);
                  fd.clearFilter();
                  fd.filter.fltAuthor = widget.author.nameRus;
                  fd.filter.fltActual = FilterActualType.fatNone;
                  Navigator.of(context).pushNamed(
                      BooksOverviewScreen.routeName);
                },
                icon: const Icon(
                  Icons.navigate_next,
                  color: Colors.blue,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
