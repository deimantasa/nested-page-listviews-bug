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

  List<List<FlutterLogo>> _listOfFlutterLogos = [];
  int _currentParentPage = 0;
  int _currentChildPage = 0;
  Map<int, int> _childSelectionMap = {};
  Map<int, PageController> _childPageControllers = {};
  Map<int, ScrollController> _childScrollControllers = {};

  @override
  void dispose() {
    _parentPageController.dispose();
    for (PageController pageController in _childPageControllers.values) {
      pageController.dispose();
    }
    for (ScrollController scrollController in _childScrollControllers.values) {
      scrollController.dispose();
    }
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
                _listOfFlutterLogos[_currentParentPage].add(FlutterLogo());
              });
            },
          ),
        ],
      ),
      body: PageView.builder(
          controller: _parentPageController,
          itemCount: _listOfFlutterLogos.length,
          onPageChanged: (parentPage) {
            print("Parent Page is changing: $parentPage");
            setState(() {
              _currentParentPage = parentPage;
              _updateSelectedChildPage();
            });
          },
          itemBuilder: (context, parentIndex) {
            List<FlutterLogo> flutterLogos = _listOfFlutterLogos[parentIndex];
            return Column(
              children: [
                Expanded(
                  child: PageView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      controller: _getCurrentChildPageController(),
                      onPageChanged: (childPage) {
                        print("Child Page is changing. Parent Page: $parentIndex, Child Page: $childPage");
                        setState(() {
                          _currentChildPage = childPage;
                          _childSelectionMap[_currentParentPage] = childPage;
                        });
                      },
                      itemCount: flutterLogos.length,
                      itemBuilder: (context, childIndex) {
                        FlutterLogo flutterLogo = flutterLogos[childIndex];
                        return _getFlutterLogoWithIndex(flutterLogo, childIndex);
                      }),
                ),
                Expanded(
                  child: ListView.builder(
                      controller: _getCurrentChildScrollController(),
                      scrollDirection: Axis.horizontal,
                      itemCount: flutterLogos.length,
                      itemBuilder: (context, flutterLogoIndex) {
                        return InkWell(
                          onTap: () {
                            setState(() {
                              _getCurrentChildPageController()
                                  .animateToPage(flutterLogoIndex, duration: kTabScrollDuration, curve: Curves.easeIn);
                            });
                          },
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 60,
                                height: 60,
                                child: _getFlutterLogoWithIndex(flutterLogos[flutterLogoIndex], flutterLogoIndex),
                              ),
                              Container(
                                color:
                                    _childSelectionMap[_currentParentPage] == flutterLogoIndex ? Colors.blue : Colors.transparent,
                                height: 10,
                                width: 20,
                              )
                            ],
                          ),
                        );
                      }),
                ),
                Text("Total Parent Lists: ${_listOfFlutterLogos.length}"),
                Text("Current Parent Page: $_currentParentPage"),
              ],
            );
          }),
    );
  }

  PageController _getCurrentChildPageController() {
    if (!_childPageControllers.containsKey(_currentParentPage)) {
      _childPageControllers[_currentParentPage] = PageController();
    }

    return _childPageControllers[_currentParentPage];
  }

  ScrollController _getCurrentChildScrollController() {
    if (!_childScrollControllers.containsKey(_currentChildPage)) {
      _childScrollControllers[_currentChildPage] = ScrollController();
    }

    return _childScrollControllers[_currentChildPage];
  }

  Widget _getFlutterLogoWithIndex(Widget widget, int index) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(width: 300, height: 300, child: widget),
        Text("$index"),
      ],
    );
  }

  Future<void> _updateSelectedChildPage() async {
    //If delay commented out, it will crash.
    //ScrollController not attached to any scroll views.
    await Future.delayed(Duration(seconds: 1));

    setState(() {
      int currentChildPage = _childSelectionMap[_currentParentPage];
      PageController childPageController = _getCurrentChildPageController();
      //Brand new page doesn't have a value yet therefore don't need to do any updates
      if (currentChildPage != null) {
        //If scrolling fast, controller gets detached and
        //ScrollController not attached to any scroll views. exception is thrown
        int scrollControllerPositionsLength = childPageController.positions.length;
        print("Scroll Controller Positions Length: $scrollControllerPositionsLength");
        if (scrollControllerPositionsLength == 1) {
          _getCurrentChildPageController().jumpToPage(currentChildPage);
        }
      }
    });
  }
}
