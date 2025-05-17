import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/settings.dart';
import '../providers/settings_provider.dart';

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: CupertinoColors.systemBackground.resolveFrom(context),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: CupertinoColors.systemBackground.resolveFrom(context),
        title: Text(
          'Settings',
          style: theme.textTheme.titleLarge?.copyWith(
            fontFamily: 'Alata',
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Consumer<SettingsProvider>(
        builder: (ctx, provider, _) {
          return ListView(
            children: [
              _buildSection(
                context,
                title: 'Appearance',
                children: [
                  _buildSwitchTile(
                    context,
                    title: 'Dark Mode',
                    subtitle: 'Use dark theme',
                    icon: CupertinoIcons.moon_fill,
                    value: provider.isDarkMode(
                      MediaQuery.of(context).platformBrightness ==
                          Brightness.dark,
                    ),
                    onChanged: (value) async {
                      await provider.setDarkMode(value);
                    },
                  ),
                ],
              ),
              _buildSection(
                context,
                title: 'Text',
                children: [
                  _buildDropdownTile(
                    context,
                    title: 'Font Size',
                    subtitle: 'Adjust hymn text size',
                    icon: CupertinoIcons.textformat_size,
                    value: provider.getFontSize(),
                    items: [14, 16, 18, 20, 22],
                    onChanged: (value) async {
                      if (value != null) {
                        await provider.setFontSize(value);
                      }
                    },
                  ),
                ],
              ),
              _buildSection(
                context,
                title: 'Language',
                children: [
                  _buildInfoTile(
                    context,
                    title: 'App Language',
                    subtitle: provider.getLanguage().name,
                    icon: CupertinoIcons.globe,
                  ),
                ],
              ),
              _buildSection(
                context,
                title: 'About',
                children: [
                  _buildInfoTile(
                    context,
                    title: 'Version',
                    subtitle: '1.0.0',
                    icon: CupertinoIcons.info_circle_fill,
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            title.toUpperCase(),
            style: TextStyle(
              color: CupertinoColors.systemGrey.resolveFrom(context),
              fontSize: 13,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: CupertinoColors.systemBackground.resolveFrom(context),
            border: Border(
              top: BorderSide(
                color: CupertinoColors.systemGrey5.resolveFrom(context),
                width: 0.5,
              ),
              bottom: BorderSide(
                color: CupertinoColors.systemGrey5.resolveFrom(context),
                width: 0.5,
              ),
            ),
          ),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildSwitchTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: CupertinoColors.systemGrey5.resolveFrom(context),
            width: 0.5,
          ),
        ),
      ),
      child: CupertinoListTile(
        leading: Icon(
          icon,
          color: CupertinoColors.activeGreen.resolveFrom(context),
        ),
        title: Text(title),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: CupertinoColors.systemGrey.resolveFrom(context),
          ),
        ),
        trailing: CupertinoSwitch(
          value: value,
          onChanged: onChanged,
          activeColor: CupertinoColors.activeGreen.resolveFrom(context),
        ),
      ),
    );
  }

  Widget _buildDropdownTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required int value,
    required List<int> items,
    required ValueChanged<int?> onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: CupertinoColors.systemGrey5.resolveFrom(context),
            width: 0.5,
          ),
        ),
      ),
      child: CupertinoListTile(
        leading: Icon(
          icon,
          color: CupertinoColors.activeGreen.resolveFrom(context),
        ),
        title: Text(title),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: CupertinoColors.systemGrey.resolveFrom(context),
          ),
        ),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                value.toString(),
                style: TextStyle(
                  color: CupertinoColors.systemGrey.resolveFrom(context),
                ),
              ),
              Icon(
                CupertinoIcons.chevron_right,
                color: CupertinoColors.systemGrey.resolveFrom(context),
                size: 20,
              ),
            ],
          ),
          onPressed: () {
            int selectedIndex = items.indexOf(value);
            showCupertinoModalPopup(
              context: context,
              builder: (BuildContext context) => Container(
                height: 216,
                padding: const EdgeInsets.only(top: 6.0),
                margin: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                color: CupertinoColors.systemBackground.resolveFrom(context),
                child: SafeArea(
                  top: false,
                  child: Column(
                    children: [
                      Container(
                        height: 40,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: CupertinoColors.systemBackground
                              .resolveFrom(context),
                          border: Border(
                            bottom: BorderSide(
                              color: CupertinoColors.systemGrey5
                                  .resolveFrom(context),
                              width: 0.5,
                            ),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            CupertinoButton(
                              padding: EdgeInsets.zero,
                              child: Text('Cancel'),
                              onPressed: () => Navigator.of(context).pop(),
                            ),
                            CupertinoButton(
                              padding: EdgeInsets.zero,
                              child: Text('Done'),
                              onPressed: () => Navigator.of(context).pop(),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: CupertinoPicker(
                          scrollController: FixedExtentScrollController(
                            initialItem: selectedIndex,
                          ),
                          itemExtent: 32.0,
                          onSelectedItemChanged: (index) {
                            onChanged(items[index]);
                          },
                          children: items
                              .map((size) => Center(
                                    child: Text(
                                      size.toString(),
                                      style: TextStyle(
                                        fontSize: 20,
                                        color: CupertinoColors.label
                                            .resolveFrom(context),
                                      ),
                                    ),
                                  ))
                              .toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildInfoTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: CupertinoColors.systemGrey5.resolveFrom(context),
            width: 0.5,
          ),
        ),
      ),
      child: CupertinoListTile(
        leading: Icon(
          icon,
          color: CupertinoColors.activeGreen.resolveFrom(context),
        ),
        title: Text(title),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: CupertinoColors.systemGrey.resolveFrom(context),
          ),
        ),
      ),
    );
  }
}
