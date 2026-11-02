import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';

import '../ad_helper.dart';
import '../models/settings.dart';
import '../providers/settings_provider.dart';
import '../utils/platform_icons.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  static const _fontSizes = [14, 16, 18, 20, 22];

  // Read from the app bundle, so it always matches pubspec.yaml.
  static final Future<PackageInfo> _packageInfo = PackageInfo.fromPlatform();

  @override
  Widget build(BuildContext context) {
    return AdaptiveScaffold(
      appBar: AdaptiveAppBar(title: 'Settings'),
      // Grouped sections sit on the grey grouped background, as in iOS Settings.
      backgroundColor: PlatformInfo.isIOS
          ? CupertinoColors.systemGroupedBackground.resolveFrom(context)
          : null,
      body: Builder(
        // The scaffold adds its bars to the padding inside its body.
        builder: (context) {
          final insets = MediaQuery.paddingOf(context);
          return Consumer<SettingsProvider>(
            builder: (ctx, provider, _) {
              final fontSize = provider.getFontSize();
              return ListView(
                padding: EdgeInsets.only(
                  top: insets.top + 8,
                  bottom: insets.bottom + 16,
                ),
                children: [
                  AdaptiveFormSection.insetGrouped(
                    header: const Text('Appearance'),
                    children: [
                      AdaptiveListTile(
                        leading: _icon(
                          context,
                          CupertinoIcons.moon_fill,
                          Icons.dark_mode_outlined,
                        ),
                        title: const Text('Dark Mode'),
                        trailing: AdaptiveSwitch(
                          value: provider.isDarkMode(
                            MediaQuery.platformBrightnessOf(context) ==
                                Brightness.dark,
                          ),
                          activeColor: brandGreen,
                          onChanged: provider.setDarkMode,
                        ),
                      ),
                      AdaptiveListTile(
                        leading: _icon(
                          context,
                          CupertinoIcons.textformat_size,
                          Icons.format_size,
                        ),
                        title: const Text('Hymn Text Size'),
                        hideBottomDivider: true,
                        trailing: AdaptivePopupMenuButton.text<int>(
                          label: '$fontSize',
                          items: [
                            for (final size in _fontSizes)
                              AdaptivePopupMenuItem<int>(
                                label: '$size',
                                value: size,
                                selected: size == fontSize,
                              ),
                          ],
                          onSelected: (_, item) {
                            final size = item.value;
                            if (size != null) provider.setFontSize(size);
                          },
                        ),
                      ),
                    ],
                  ),
                  AdaptiveFormSection.insetGrouped(
                    header: const Text('Language'),
                    children: [
                      AdaptiveListTile(
                        leading: _icon(
                          context,
                          CupertinoIcons.globe,
                          Icons.language,
                        ),
                        title: const Text('App Language'),
                        hideBottomDivider: true,
                        trailing: _detail(
                          context,
                          provider.getLanguage().label,
                        ),
                      ),
                    ],
                  ),
                  FutureBuilder<bool>(
                    future: AdHelper.isPrivacyOptionsRequired(),
                    builder: (context, snapshot) {
                      if (snapshot.data != true) return const SizedBox.shrink();
                      return AdaptiveFormSection.insetGrouped(
                        header: const Text('Privacy'),
                        children: [
                          AdaptiveListTile(
                            leading: _icon(
                              context,
                              CupertinoIcons.lock_shield_fill,
                              Icons.privacy_tip_outlined,
                            ),
                            title: const Text('Privacy Settings'),
                            subtitle: const Text(
                              'Change your ad consent choices',
                            ),
                            hideBottomDivider: true,
                            trailing: _chevron(context),
                            onTap: AdHelper.showPrivacyOptionsForm,
                          ),
                        ],
                      );
                    },
                  ),
                  AdaptiveFormSection.insetGrouped(
                    header: const Text('About'),
                    children: [
                      AdaptiveListTile(
                        leading: _icon(
                          context,
                          CupertinoIcons.info_circle_fill,
                          Icons.info_outline,
                        ),
                        title: const Text('Version'),
                        trailing: FutureBuilder<PackageInfo>(
                          future: _packageInfo,
                          builder: (context, info) =>
                              _detail(context, info.data?.version ?? ''),
                        ),
                      ),
                      AdaptiveListTile(
                        leading: _icon(
                          context,
                          CupertinoIcons.doc_text_fill,
                          Icons.description_outlined,
                        ),
                        title: const Text('Licences'),
                        hideBottomDivider: true,
                        trailing: _chevron(context),
                        onTap: () => showLicensePage(
                          context: context,
                          applicationName: 'Baptist Hymnal',
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  static Widget _icon(
    BuildContext context,
    IconData cupertino,
    IconData material,
  ) => Icon(
    platformIconData(cupertino: cupertino, material: material),
    color: PlatformInfo.isIOS
        ? CupertinoColors.systemGreen.resolveFrom(context)
        : brandGreen,
  );

  static Widget _detail(BuildContext context, String text) => Text(
    text,
    style: TextStyle(
      fontSize: 17,
      color: CupertinoColors.secondaryLabel.resolveFrom(context),
    ),
  );

  static Widget _chevron(BuildContext context) => Icon(
    platformIconData(
      cupertino: CupertinoIcons.chevron_right,
      material: Icons.chevron_right,
    ),
    size: 18,
    color: CupertinoColors.tertiaryLabel.resolveFrom(context),
  );
}
