import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({
    Key key,
  }) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final PageController _parentPageController = PageController(viewportFraction: 1);
  final PageController _childPageController = PageController();
  final ScrollController _scrollController = ScrollController();

  List<List<FlutterLogo>> _listOfFlutterLogos = [];
  int _currentPage = 0;
  Map<int, int> childSelectionMap = {};

  @override
  void dispose() {
    _parentPageController.dispose();
    _childPageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Home"),
        actions: [
          FlatButton(
            child: Text("Add Parent"),
            onPressed: () {
              setState(() {
                _listOfFlutterLogos.add([FlutterLogo()]);
              });
            },
          ),
          FlatButton(
            child: Text("Add Child"),
            onPressed: () {
              setState(() {
                _listOfFlutterLogos[_currentPage].add(FlutterLogo());
              });
            },
          ),
        ],
      ),
      body: PageView.builder(
          controller: _parentPageController,
          itemCount: _listOfFlutterLogos.length,
          onPageChanged: (parentPage) {
            setState(() {
              _currentPage = parentPage;
            });
          },
          itemBuilder: (context, parentIndex) {
            List<FlutterLogo> flutterLogos = _listOfFlutterLogos[parentIndex];
            return Column(
              children: [
                Expanded(
                  child: PageView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      controller: _childPageController,
                      onPageChanged: (childPage) {
                        setState(() {
                          childSelectionMap[_currentPage] = childPage;
                        });
                      },
                      itemCount: flutterLogos.length,
                      itemBuilder: (context, childIndex) {
                        FlutterLogo flutterLogo = flutterLogos[childIndex];
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Expanded(child: flutterLogo),
                          ],
                        );
                      }),
                ),
                Expanded(
                  child: ListView.builder(
                      controller: _scrollController,
                      scrollDirection: Axis.horizontal,
                      itemCount: flutterLogos.length,
                      itemBuilder: (context, flutterLogoIndex) {
                        return InkWell(
                          onTap: () {
                            setState(() {
                              _childPageController.animateToPage(flutterLogoIndex,
                                  duration: kTabScrollDuration, curve: Curves.easeIn);
                            });
                          },
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 60,
                                height: 60,
                                child: flutterLogos[flutterLogoIndex],
                              ),
                              Container(
                                color: childSelectionMap[_currentPage] == flutterLogoIndex ? Colors.blue : Colors.transparent,
                                height: 10,
                                width: 20,
                              )
                            ],
                          ),
                        );
                      }),
                ),
                Text("Total Parent Lists: ${_listOfFlutterLogos.length}"),
                Text("Current Page: $_currentPage"),
              ],
            );
          }),
    );
  }
}
