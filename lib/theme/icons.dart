import 'package:flutter/material.dart';

/// Central icon set. Maps the prototype's Lucide icon names to built-in Material
/// (rounded/outlined) equivalents, so there's no external icon dependency and a
/// single place to swap the icon style.
abstract class AppIcons {
  static const IconData check = Icons.check_rounded;
  static const IconData plus = Icons.add_rounded;
  static const IconData minus = Icons.remove_rounded;
  static const IconData chevronLeft = Icons.chevron_left_rounded;
  static const IconData chevronRight = Icons.chevron_right_rounded;
  static const IconData chevronDown = Icons.keyboard_arrow_down_rounded;
  static const IconData trash2 = Icons.delete_outline_rounded;
  static const IconData pencil = Icons.edit_outlined;
  static const IconData moreVertical = Icons.more_vert_rounded;
  static const IconData x = Icons.close_rounded;
  static const IconData bookmark = Icons.bookmark_border_rounded;
  static const IconData users = Icons.people_alt_outlined;
  static const IconData search = Icons.search_rounded;
  static const IconData shoppingCart = Icons.shopping_basket_outlined;
  static const IconData book = Icons.menu_book_rounded;
  static const IconData clock = Icons.schedule_rounded;
  static const IconData utensils = Icons.restaurant_rounded;
  static const IconData sparkles = Icons.auto_awesome_rounded;
  static const IconData copy = Icons.copy_rounded;
  static const IconData list = Icons.format_list_bulleted_rounded;
  static const IconData share = Icons.share_rounded;
  static const IconData uncheck = Icons.remove_done_rounded;
  static const IconData deleteChecked = Icons.cleaning_services_rounded;
  static const IconData store = Icons.store_rounded;
  static const IconData calendar = Icons.calendar_today_rounded;
  static const IconData user = Icons.person_outline_rounded;
}
