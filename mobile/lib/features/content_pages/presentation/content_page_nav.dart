import 'package:flutter/material.dart';

import '../../../../core/router/app_router.dart';
import '../data/services/content_pages_api.dart';
import 'pages/content_page_screen.dart';

void openContentPage(
  BuildContext context,
  ContentPage page, {
  bool rootNavigator = true,
}) {
  Navigator.of(context, rootNavigator: rootNavigator).pushNamed(
    AppRouter.contentPage,
    arguments: ContentPageArgs(
      slug: page.slug,
      title: page.buttonLabel.isNotEmpty ? page.buttonLabel : page.title,
    ),
  );
}
