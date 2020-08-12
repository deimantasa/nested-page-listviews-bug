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
  static Map<int, int> childSelectionMap = {};

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
            _currentParentPage = parentPage;
//            setState(() {
//              _currentParentPage = parentPage;
//              _updateSelectedChildPage();
//            });
          },
          itemBuilder: (context, parentIndex) {
            List<FlutterLogo> flutterLogos = _listOfFlutterLogos[parentIndex];
            return _ChildWidget(
              pageIndex: parentIndex,
              flutterLogos: flutterLogos,
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

//  Future<void> _updateSelectedChildPage() async {
//    //If delay commented out, it will crash.
//    //ScrollController not attached to any scroll views.
//    await Future.delayed(Duration(seconds: 1));
//
//    setState(() {
//      int currentChildPage = _childSelectionMap[_currentParentPage];
//      PageController childPageController = _getCurrentChildPageController();
//      //Brand new page doesn't have a value yet therefore don't need to do any updates
//      if (currentChildPage != null) {
//        //If scrolling fast, controller gets detached and
//        //ScrollController not attached to any scroll views. exception is thrown
//        int scrollControllerPositionsLength = childPageController.positions.length;
//        print("Scroll Controller Positions Length: $scrollControllerPositionsLength");
//        if (scrollControllerPositionsLength == 1) {
//          _getCurrentChildPageController().jumpToPage(currentChildPage);
//        }
//      }
//    });
//  }
}

class _ChildWidget extends StatefulWidget {
  final int pageIndex;
  final List<FlutterLogo> flutterLogos;

  const _ChildWidget({
    Key key,
    @required this.flutterLogos,
    @required this.pageIndex,
  }) : super(key: key);

  @override
  __ChildWidgetState createState() => __ChildWidgetState();
}

class __ChildWidgetState extends State<_ChildWidget> {
  PageController _pageController;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    if (MyHomePage.childSelectionMap.containsKey(widget.pageIndex)) {
      _pageController = PageController(initialPage: MyHomePage.childSelectionMap[widget.pageIndex]);
    } else {
      _pageController = PageController();
    }
    super.initState();
  }

  @override
  void dispose() {
    _pageController?.dispose();
    _scrollController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print(widget.pageIndex);
    return Column(
      children: [
        Expanded(
          child: PageView.builder(
              physics: NeverScrollableScrollPhysics(),
              controller: _pageController,
              onPageChanged: (childPage) {
                print("Child Page is changing. Child Page: $childPage");
//                setState(() {
//                  _currentChildPage = childPage;
//                  _childSelectionMap[_currentParentPage] = childPage;
//                });
              },
              itemCount: widget.flutterLogos.length,
              itemBuilder: (context, childIndex) {
                FlutterLogo flutterLogo = widget.flutterLogos[childIndex];
                MyHomePage.childSelectionMap[widget.pageIndex] = childIndex;
                return _getFlutterLogoWithIndex(flutterLogo, childIndex);
              }),
        ),
        Expanded(
          child: ListView.builder(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              itemCount: widget.flutterLogos.length,
              itemBuilder: (context, flutterLogoIndex) {
                return InkWell(
                  onTap: () {
                    setState(() {
                      _pageController.animateToPage(flutterLogoIndex, duration: kTabScrollDuration, curve: Curves.easeIn);
                    });
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        child: _getFlutterLogoWithIndex(widget.flutterLogos[flutterLogoIndex], flutterLogoIndex),
                      ),
//                      Container(
//                        color: _childSelectionMap[_currentParentPage] == flutterLogoIndex ? Colors.blue : Colors.transparent,
//                        height: 10,
//                        width: 20,
//                      )
                    ],
                  ),
                );
              }),
        ),
//        Text("Total Parent Lists: ${_listOfFlutterLogos.length}"),
//        Text("Current Parent Page: $_currentParentPage"),
      ],
    );
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
}
