import 'package:charity_discount/state/state_model.dart';
import 'package:charity_discount/ui/app/fadeslide.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:timeline_tile/timeline_tile.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _Header(),
            _Steps(),
            FadeSlide(
              delay: Duration(milliseconds: 5500),
              child: RaisedButton(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: EdgeInsets.all(12),
                color: Theme.of(context).primaryColor,
                child: Text(
                  tr('gotIt').toUpperCase(),
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () {
                  AppModel.of(context, rebuildOnChange: true).finishIntro();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: ListTile(
          leading: Image.asset(
            'assets/icons/logo.png',
            fit: BoxFit.cover,
          ),
          title: Text(
            'CharityDiscount',
            textAlign: TextAlign.center,
          ),
          subtitle: Text(
            '#EducatiaSalveazaRomania',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

class _Steps extends StatelessWidget {
  const _Steps({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _StepIndicator(
          isFirst: true,
          title: tr('welcome.register.title'),
          subtitle: tr('welcome.register.subtitle'),
          delay: Duration(milliseconds: 500),
        ),
        _StepIndicator(
          title: tr('welcome.findShop.title'),
          subtitle: tr('welcome.findShop.subtitle'),
          delay: Duration(milliseconds: 1500),
        ),
        _StepIndicator(
          title: tr('welcome.openShop.title'),
          subtitle: tr('welcome.openShop.subtitle'),
          delay: Duration(milliseconds: 2500),
        ),
        _StepIndicator(
          title: tr('welcome.receiveCashback.title'),
          subtitle: tr('welcome.receiveCashback.subtitle'),
          delay: Duration(milliseconds: 3500),
        ),
        _StepIndicator(
          isLast: true,
          title: tr('welcome.spendCashback.title'),
          subtitle: tr('welcome.spendCashback.subtitle'),
          delay: Duration(milliseconds: 4500),
        ),
      ],
    );
  }
}

class _StepIndicator extends StatelessWidget {
  const _StepIndicator({
    Key key,
    @required this.title,
    @required this.subtitle,
    @required this.delay,
    this.isFirst = false,
    this.isLast = false,
  }) : super(key: key);

  final String title;
  final String subtitle;
  final bool isFirst;
  final bool isLast;
  final Duration delay;

  @override
  Widget build(BuildContext context) {
    final color = Colors.grey.shade400;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 50.0),
      child: FadeSlide(
        delay: delay,
        child: TimelineTile(
          isFirst: isFirst,
          isLast: isLast,
          topLineStyle: LineStyle(
            color: color,
            width: 5,
          ),
          indicatorStyle: IndicatorStyle(
            color: color,
            width: 20,
          ),
          bottomLineStyle: LineStyle(
            color: color,
            width: 5,
          ),
          rightChild: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0),
            child: ListTile(
              title: Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(color: Theme.of(context).primaryColor),
              ),
              subtitle: Text(
                subtitle,
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
