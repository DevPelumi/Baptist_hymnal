import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../ad_helper.dart';
import '../models/settings.dart';
import '../providers/settings_provider.dart';
import '../purchases/premium.dart';
import 'remove_ads_screen.dart';
import '../utils/app_font.dart';
import '../utils/platform_icons.dart';
import '../utils/responsive.dart';
import '../utils/review_prompt.dart';
import '../widgets/duo_tab_bar.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  static const _fontSizes = [14, 16, 18, 20, 22];

  // Read from the app bundle, so it always matches pubspec.yaml.
  static final Future<PackageInfo> _packageInfo = PackageInfo.fromPlatform();

  @override
  Widget build(BuildContext context) {
    return AdaptiveScaffold(
      appBar: AdaptiveAppBar(title: 'Settings'),
      bottomNavigationBar: DuoTabBar.of(context),
      // Grouped sections sit on the grey grouped background, as in iOS Settings.
      backgroundColor: PlatformInfo.isIOS
          ? CupertinoColors.systemGroupedBackground.resolveFrom(context)
          : null,
      body: AppFont(
        child: Builder(
          // The scaffold adds its bars to the padding inside its body.
          builder: (context) {
            final insets = MediaQuery.paddingOf(context);
            return Consumer<SettingsProvider>(
              builder: (ctx, provider, _) {
                final fontSize = provider.getFontSize();
                return ListView(
                  // A centred column on a tablet, as in iPad Settings.
                  padding: EdgeInsets.only(
                    top: insets.top + 8 + DuoTabBar.titleFadeClearance(context),
                    bottom: insets.bottom + 16,
                    left: Responsive.inset(context),
                    right: Responsive.inset(context),
                  ),
                  children: [
                    _removeAdsSection(context),
                    AdaptiveFormSection.insetGrouped(
                      header: const _AppText('Appearance'),
                      children: [
                        AdaptiveListTile(
                          leading: _icon(
                            context,
                            CupertinoIcons.moon_fill,
                            Icons.dark_mode_outlined,
                          ),
                          title: const _AppText('Dark Mode'),
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
                          title: const _AppText('Hymn Text Size'),
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
                      header: const _AppText('Hymn of the Day'),
                      footer: const _AppText(
                        'A notification each day with a hymn you can sing '
                        'along to its tune.',
                      ),
                      children: [
                        AdaptiveListTile(
                          leading: _icon(
                            context,
                            CupertinoIcons.bell_fill,
                            Icons.notifications_outlined,
                          ),
                          title: const _AppText('Daily Hymn'),
                          hideBottomDivider: !provider.hymnOfTheDay,
                          trailing: AdaptiveSwitch(
                            value: provider.hymnOfTheDay,
                            activeColor: brandGreen,
                            onChanged: (on) =>
                                _setHymnOfTheDay(context, provider, on),
                          ),
                        ),
                        if (provider.hymnOfTheDay)
                          AdaptiveListTile(
                            leading: _icon(
                              context,
                              CupertinoIcons.clock_fill,
                              Icons.schedule,
                            ),
                            title: const _AppText('Time'),
                            hideBottomDivider: true,
                            trailing: _detail(
                              context,
                              provider.hymnOfTheDayTime.format(context),
                            ),
                            onTap: () async {
                              final time = await AdaptiveTimePicker.show(
                                context: context,
                                initialTime: provider.hymnOfTheDayTime,
                                use24HourFormat:
                                    MediaQuery.alwaysUse24HourFormatOf(context),
                              );
                              if (time != null) {
                                await provider.setHymnOfTheDayTime(time);
                              }
                            },
                          ),
                      ],
                    ),
                    AdaptiveFormSection.insetGrouped(
                      header: const _AppText('Language'),
                      children: [
                        AdaptiveListTile(
                          leading: _icon(
                            context,
                            CupertinoIcons.globe,
                            Icons.language,
                          ),
                          title: const _AppText('App Language'),
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
                        if (snapshot.data != true) {
                          return const SizedBox.shrink();
                        }
                        return AdaptiveFormSection.insetGrouped(
                          header: const _AppText('Privacy'),
                          children: [
                            AdaptiveListTile(
                              leading: _icon(
                                context,
                                CupertinoIcons.lock_shield_fill,
                                Icons.privacy_tip_outlined,
                              ),
                              title: const _AppText('Privacy Settings'),
                              subtitle: const _AppText(
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
                      header: const _AppText('About'),
                      children: [
                        AdaptiveListTile(
                          leading: _icon(
                            context,
                            CupertinoIcons.star_fill,
                            Icons.star_outline,
                          ),
                          title: const _AppText('Rate Baptist Hymnal'),
                          subtitle: _AppText(
                            PlatformInfo.isIOS
                                ? 'Write a review on the App Store'
                                : 'Write a review on Google Play',
                          ),
                          trailing: _chevron(context),
                          onTap: ReviewPrompt.openStorePage,
                        ),
                        AdaptiveListTile(
                          leading: _icon(
                            context,
                            CupertinoIcons.info_circle_fill,
                            Icons.info_outline,
                          ),
                          title: const _AppText('Version'),
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
                          title: const _AppText('Licences'),
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
      ),
    );
  }

  /// Remove Ads and Restore Purchases, or, once paid, the plan and where to
  /// manage it.
  static Widget _removeAdsSection(BuildContext context) {
    // Tries again if the plans couldn't be fetched at launch.
    Premium.checkPlans();
    return ListenableBuilder(
      listenable: Listenable.merge([
        Premium.isActive,
        Premium.customerInfo,
        Premium.hasPlans,
      ]),
      builder: (context, _) {
        if (!Premium.isActive.value && !Premium.hasPlans.value) {
          return const SizedBox.shrink();
        }
        if (!Premium.isActive.value) {
          return AdaptiveFormSection.insetGrouped(
            header: const _AppText('Ads'),
            children: [
              AdaptiveListTile(
                leading: _icon(context, CupertinoIcons.nosign, Icons.block),
                title: const _AppText('Remove Ads'),
                subtitle: const _AppText('Monthly, yearly or pay once'),
                trailing: _chevron(context),
                onTap: () => showRemoveAds(context, source: 'settings'),
              ),
              AdaptiveListTile(
                leading: _icon(
                  context,
                  CupertinoIcons.arrow_clockwise,
                  Icons.restore,
                ),
                title: const _AppText('Restore Purchases'),
                hideBottomDivider: true,
                onTap: () => restorePurchases(context),
              ),
            ],
          );
        }
        final entitlement = Premium.activeEntitlement;
        final expires = DateTime.tryParse(
          entitlement?.expirationDate ?? '',
        )?.toLocal();
        final plan = Premium.activePlanName;
        final String status;
        if (entitlement == null || plan == null) {
          status = 'Thank you for supporting Baptist Hymnal';
        } else if (expires == null) {
          status = 'Lifetime. Thank you for your support!';
        } else {
          final localizations = MaterialLocalizations.of(context);
          final date =
              '${localizations.formatShortMonthDay(expires)}, ${expires.year}';
          status = entitlement.willRenew
              ? '$plan, renews $date'
              : '$plan, ends $date';
        }
        return AdaptiveFormSection.insetGrouped(
          header: const _AppText('Ads'),
          children: [
            AdaptiveListTile(
              leading: _icon(
                context,
                CupertinoIcons.checkmark_seal_fill,
                Icons.verified_outlined,
              ),
              title: const _AppText('Ads Removed'),
              subtitle: _AppText(status),
              hideBottomDivider: expires == null,
            ),
            if (expires != null)
              AdaptiveListTile(
                leading: _icon(
                  context,
                  CupertinoIcons.creditcard_fill,
                  Icons.credit_card,
                ),
                title: const _AppText('Manage Subscription'),
                hideBottomDivider: true,
                trailing: _chevron(context),
                onTap: () => launchUrl(
                  Premium.manageSubscriptionsUrl,
                  mode: LaunchMode.externalApplication,
                ),
              ),
          ],
        );
      },
    );
  }

  /// Turning it on asks to send notifications. If they're blocked, says
  /// where to allow them.
  static Future<void> _setHymnOfTheDay(
    BuildContext context,
    SettingsProvider provider,
    bool on,
  ) async {
    final isOn = await provider.setHymnOfTheDay(on, source: 'settings');
    if (!on || isOn || !context.mounted) return;
    await AdaptiveAlertDialog.show(
      context: context,
      title: 'Notifications Are Off',
      message:
          'To get the hymn of the day, allow notifications for Baptist '
          'Hymnal in your phone’s Settings.',
      actions: [AlertAction(title: 'OK', onPressed: () {})],
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
      fontFamily: appFont,
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

/// Text in the app's font. The adaptive rows and section headers set their
/// own text style, which would otherwise drop back to the system font.
class _AppText extends StatelessWidget {
  const _AppText(this.data);

  final String data;

  @override
  Widget build(BuildContext context) => Text(data, style: appFontStyle);
}
