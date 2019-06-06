import 'package:flutter/material.dart';
import 'package:gradient_text/gradient_text.dart';
import 'package:charity_discount/ui/widgets/page_indicator.dart';
import 'package:charity_discount/state/state_model.dart';

class Intro extends StatefulWidget {
  @override
  _IntroState createState() => _IntroState();
}

class _IntroState extends State<Intro> with TickerProviderStateMixin {
  PageController _controller;
  int currentPage = 0;
  bool lastPage = false;
  AnimationController animationController;
  Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = PageController(
      initialPage: currentPage,
    );
    animationController =
        AnimationController(duration: Duration(milliseconds: 300), vsync: this);
    _scaleAnimation = Tween(begin: 0.6, end: 1.0).animate(animationController);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
            colors: [Color(0xFF485563), Color(0xFF29323C)],
            tileMode: TileMode.clamp,
            begin: Alignment.topCenter,
            stops: [0.0, 1.0],
            end: Alignment.bottomCenter),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            PageView.builder(
              itemCount: pageList.length,
              controller: _controller,
              onPageChanged: (index) {
                setState(() {
                  currentPage = index;
                  if (currentPage == pageList.length - 1) {
                    lastPage = true;
                    animationController.forward();
                  } else {
                    lastPage = false;
                    animationController.reset();
                  }
                });
              },
              itemBuilder: (context, index) {
                return AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    var page = pageList[index];
                    var delta;
                    var y = 1.0;

                    if (_controller.position.haveDimensions) {
                      delta = _controller.page - index;
                      y = 1 - delta.abs().clamp(0.0, 1.0);
                    }
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Padding(
                            padding: EdgeInsets.all(12),
                            child: Image.asset(
                              page.imageUrl,
                              fit: BoxFit.fill,
                            )),
                        Container(
                          margin: EdgeInsets.only(left: 12.0),
                          height: 90.0,
                          child: Stack(
                            children: <Widget>[
                              Opacity(
                                opacity: .10,
                                child: GradientText(
                                  page.title,
                                  gradient: LinearGradient(
                                      colors: pageList[index].titleGradient),
                                  style: TextStyle(
                                      fontSize: 80.0, letterSpacing: 1.0),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(top: 30.0, left: 22.0),
                                child: GradientText(
                                  page.title,
                                  gradient: LinearGradient(
                                      colors: pageList[index].titleGradient),
                                  style: TextStyle(
                                    fontSize: 50.0,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 34.0, top: 8.0),
                          child: Transform(
                            transform:
                                Matrix4.translationValues(0, 50.0 * (1 - y), 0),
                            child: Text(
                              page.body,
                              style: TextStyle(
                                  fontSize: 20.0, color: Color(0xFF9B9B9B)),
                            ),
                          ),
                        )
                      ],
                    );
                  },
                );
              },
            ),
            Positioned(
              left: 30.0,
              bottom: 35.0,
              child: Container(
                  width: 160.0,
                  child: PageIndicator(currentPage, pageList.length)),
            ),
            Positioned(
              right: 30.0,
              bottom: 30.0,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: lastPage
                    ? FloatingActionButton(
                        backgroundColor: Colors.white,
                        child: Icon(
                          Icons.arrow_forward,
                          color: Colors.black,
                        ),
                        onPressed: () {
                          AppModel.of(context, rebuildOnChange: true)
                              .finishIntro();
                        },
                      )
                    : Container(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

var pageList = [
  PageModel(
      imageUrl: "assets/icons/icon.png",
      title: "Implica-te",
      body: "Ofera un viitor tarii tale!",
      titleGradient: gradients[0]),
  PageModel(
      imageUrl: "assets/images/save_money.png",
      title: "Economiseste",
      body: "Tu cumperi, magazinele doneaza",
      titleGradient: gradients[1]),
  PageModel(
      imageUrl: "assets/images/shopping.png",
      title: "Gaseste orice",
      body: "Sute de magazine partenere",
      titleGradient: gradients[2]),
];

List<List<Color>> gradients = [
  [Color(0xFFE32029), Color(0xFF558FC1)],
  [Color(0xFFE2859F), Color(0xFFFCCF31)],
  [Color(0xFF5EFCE8), Color(0xFF736EFE)],
];

class PageModel {
  var imageUrl;
  var title;
  var body;
  List<Color> titleGradient = [];
  PageModel({this.imageUrl, this.title, this.body, this.titleGradient});
}
