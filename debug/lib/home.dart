import 'package:flutter/material.dart';

import 'main.dart';

class Page {
  Page(String route) {
    final endPoint = route.split('/').last;
    name = endPoint;
    this.endPoint = endPoint;
  }

  String name;
  String endPoint;
}

final pages = routes.keys.map((route) => Page(route)).where((page) => page.endPoint != null || page.endPoint != '');

class PageCard extends StatelessWidget {
  PageCard({Key key, @required this.package, @required this.onPressed}):super(key: key);

  final Page package;
  final Function onPressed;
  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextStyle titleStyle = theme.textTheme.headline6;
    final TextStyle descriptionStyle = theme.textTheme.bodyText2;

    return Container(
      padding: const EdgeInsets.all(4.0),
      child: GestureDetector(
        onTap: () {
          this.onPressed(this.package.endPoint);
        },
        child: Card(
          child: DefaultTextStyle(
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
                    child: Text(this.package.name, style: titleStyle,),
                  ),
                ],
              ),
            ),
          )
        ),
      )
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chart Packages'),
      ),
      body: ListView(
        children: pages.map((package) => (
          PageCard(
            package: package,
            onPressed: (String endPoint) {
              Navigator.pushNamed(context, '/demos/$endPoint');
            },
          )
        )).toList(),
      )
    );
  }
}
