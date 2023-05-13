import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:invidious/controllers/searchController.dart';
import 'package:invidious/globals.dart';
import 'package:invidious/models/searchResult.dart';

import '../models/searchSuggestion.dart';

class TvSearchController extends SearchController {
  FocusNode resultFocus = FocusNode();
  FocusNode searchFocus = FocusNode();


  @override
  onClose() async {
    resultFocus.dispose();
    searchFocus.dispose();
  }

  KeyEventResult handleResultScopeKeyEvent(FocusNode node, KeyEvent event) {
    print(event);
    if (event is KeyUpEvent && event.logicalKey == LogicalKeyboardKey.goBack) {
      searchFocus.requestFocus();
      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }

}
