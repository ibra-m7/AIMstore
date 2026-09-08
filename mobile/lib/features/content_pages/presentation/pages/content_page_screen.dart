import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_html/flutter_html.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/circle_back_button.dart';
import '../../data/services/content_pages_api.dart';

class ContentPageArgs {
  final String slug;
  final String? title;

  const ContentPageArgs({
    required this.slug,
    this.title,
  });
}

class ContentPageScreen extends StatefulWidget {
  static const routeName = '/content-page';

  final ContentPageArgs args;

  const ContentPageScreen({super.key, required this.args});

  @override
  State<ContentPageScreen> createState() => _ContentPageScreenState();
}

class _ContentPageScreenState extends State<ContentPageScreen> {
  late Future<ContentPage?> _future;

  @override
  void initState() {
    super.initState();
    _future = ContentPagesApi.instance.show(widget.args.slug);
  }

  void _reload() {
    setState(() {
      _future = ContentPagesApi.instance.show(widget.args.slug);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark,
        child: Scaffold(
          backgroundColor: AppTheme.background,
          appBar: AppBar(
            backgroundColor: AppTheme.background,
            elevation: 0,
            scrolledUnderElevation: 0,
            centerTitle: true,
            automaticallyImplyLeading: false,
            leadingWidth: 56,
            leading: CircleBackButton.appBarLeading(),
            title: Text(
              widget.args.title?.trim().isNotEmpty == true
                  ? widget.args.title!
                  : AppStrings.profilePrivacyAndTerms,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppTheme.darkText,
              ),
            ),
          ),
          body: FutureBuilder<ContentPage?>(
            future: _future,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const Center(child: CircularProgressIndicator());
              }

              final page = snapshot.data;
              if (page == null) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          AppStrings.errorPageNotFound,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextButton(
                          onPressed: _reload,
                          child: const Text(AppStrings.retry),
                        ),
                      ],
                    ),
                  ),
                );
              }

              final html = (page.content ?? '').trim();
              final title = page.title.trim().isNotEmpty
                  ? page.title
                  : (widget.args.title ?? '');

              return ListView(
                padding: const EdgeInsets.fromLTRB(18, 8, 18, 28),
                children: [
                  if (title.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.darkText,
                        ),
                      ),
                    ),
                  if (html.isEmpty)
                    Text(
                      AppStrings.dynamicPageEmpty,
                      style: TextStyle(
                        fontSize: 13,
                        color: AppTheme.mutedText.withValues(alpha: 0.95),
                      ),
                    )
                  else
                    Html(
                      data: html,
                      style: {
                        'body': Style(
                          margin: Margins.zero,
                          padding: HtmlPaddings.zero,
                          fontSize: FontSize(14),
                          lineHeight: const LineHeight(1.7),
                          color: AppTheme.darkText,
                          direction: TextDirection.rtl,
                        ),
                        'h1': Style(
                          fontSize: FontSize(20),
                          fontWeight: FontWeight.w800,
                        ),
                        'h2': Style(
                          fontSize: FontSize(18),
                          fontWeight: FontWeight.w800,
                        ),
                        'p': Style(
                          margin: Margins.only(bottom: 10),
                        ),
                      },
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
