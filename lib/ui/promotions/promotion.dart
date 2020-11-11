import 'package:cached_network_image/cached_network_image.dart';
import 'package:charity_discount/models/promotion.dart';
import 'package:charity_discount/ui/app/access_button.dart';
import 'package:charity_discount/util/tools.dart';
import 'package:flutter/material.dart';

class PromotionCard extends StatelessWidget {
  final Promotion promotion;

  const PromotionCard({Key key, @required this.promotion}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final linkButton = AccessButton(
      buttonType: AccessButtonType.FLAT,
      url: promotion.actualAffiliateUrl,
      programId: promotion.program.id.toString(),
      programName: promotion.program.name,
      eventScreen: 'promotion',
    );

    return Container(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ListTile(
                title: Text(
                  promotion.name,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 15,
                        color: Colors.green,
                      ),
                      Text(_getPromoPeriod()),
                    ],
                  ),
                ),
              ),
              CachedNetworkImage(
                imageUrl: promotion.campaignLogo,
                height: 20,
                fit: BoxFit.contain,
              ),
              ButtonBar(
                children: [linkButton],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getPromoPeriod() => '${formatDate(promotion.promotionEnd.toLocal())}';
}
