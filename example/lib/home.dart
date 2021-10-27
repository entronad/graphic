import 'package:flutter/material.dart';

import 'main.dart';

class Page {
  Page(String route) {
    final endPoint = route.split('/').last;
    name = endPoint;
    this.endPoint = endPoint;
  }

  late String name;
  late String endPoint;
}

class PageCard extends StatelessWidget {
  const PageCard({
    required Key key,
    required this.package,
    required this.onPressed,
  }) : super(key: key);

  final Page package;
  final Function onPressed;
  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextStyle titleStyle = theme.textTheme.headline6!;
    final TextStyle descriptionStyle = theme.textTheme.bodyText2!;

    return Container(
        padding: const EdgeInsets.all(4.0),
        child: GestureDetector(
          onTap: () {
            onPressed(package.endPoint);
          },
          child: Card(
              child: DefaultTextStyle(
            maxLines: 3,
            softWrap: false,
            overflow: TextOverflow.ellipsis,
            style: descriptionStyle,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12.0, 12.0, 12.0, 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 10.0),
                    child: Text(
                      package.name,
                      style: titleStyle,
                    ),
                  ),
                ],
              ),
            ),
          )),
        ));
  }
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final pages = routes.keys.toList().sublist(1).map((route) => Page(route));
    return Scaffold(
        appBar: AppBar(
          title: const Text('Graphic Examples'),
        ),
        body: ListView(
          children: pages
              .map((package) => (PageCard(
                    key: Key(package.name),
                    package: package,
                    onPressed: (String endPoint) {
                      Navigator.pushNamed(context, '/examples/$endPoint');
                    },
                  )))
              .toList(),
        ));
  }
}
