import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:notie/style/app_style.dart';

Widget listCard(Function()? onTap, QueryDocumentSnapshot doc) {
  Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

  return InkWell(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(8.0),
      margin: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: AppStyle.cardsColor[data['color_id']],
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            data["list_title"],
            style: AppStyle.mainTitle,
          ),
          const SizedBox(
            height: 4.0,
          ),
          Text(
            data["creation_date"],
            style: AppStyle.dateTitle,
          ),
          const SizedBox(
            height: 8.0,
          ),
          Text(
            _buildListItems(data["list_items"]),
            style: AppStyle.mainContent,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    ),
  );
}

String _buildListItems(List<dynamic> listItems) {
  String items = '';
  for (var item in listItems) {
    if (item['item_completed']) {
      items += '✓ ${item['item_title']}\n';
    } else {
      items += '▢ ${item['item_title']}\n';
    }
  }
  return items;
}
