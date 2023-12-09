import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:settings_ui/src/utils/theme_provider.dart';

import '../models/settings.dart';
import '../providers/settings_provider.dart';

const style = TextStyle(
  fontFamily: 'Alata',
  fontSize: 25,
  fontWeight: FontWeight.w600,
  color: Colors.white,
  letterSpacing: 1.2,
);

const subtitleStyle =
    TextStyle(fontFamily: 'Alata', fontSize: 16, color: Colors.white);

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? Colors.black
          : Colors.teal,
      body: SafeArea(
        child: Consumer<SettingsProvider>(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Text(
              'SETTINGS',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 23,
                  fontFamily: 'Alata',
                  fontWeight: FontWeight.w600),
            ),
          ),
          builder: (ctx, provider, child) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(child: child),
                Expanded(
                    child: SettingsList(
                        lightTheme: const SettingsThemeData(
                          settingsListBackground: Colors.teal,
                        ),
                        sections: [
                      SettingsSection(title: null, tiles: [
                        SettingsTile(
                          title: Text('Language'),
                          description: Text(provider.getLanguage().name,
                              style: subtitleStyle),
                          leading: Icon(Icons.language),
                        ),
                      ]),
                      SettingsSection(title: Container(), tiles: [
                        SettingsTile.switchTile(
                          initialValue: provider.isDarkMode(
                              MediaQuery.of(context).platformBrightness ==
                                  Brightness.dark),
                          title: Text('Mode'),
                          description: Text(
                              '${provider.isDarkMode(MediaQuery.of(context).platformBrightness == Brightness.dark) ? 'Dark' : 'Light'} Mode',
                              style: subtitleStyle),
                          leading: Icon(Icons.palette),
                          onToggle: (bool value) async {
                            await provider.setDarkMode(value);
                          },
                        )
                      ]),
                      SettingsSection(title: null, tiles: [
                        SettingsTile(
                          title: Text('Font Size'),
                          description:
                              Text('Hymn font size', style: subtitleStyle),
                          trailing: DropdownButton<int>(
                              onChanged: (int? newFont) async {
                                if (newFont != null) {
                                  await provider.setFontSize(newFont);
                                }
                              },
                              dropdownColor: Colors.green.shade200,
                              icon: Icon(CupertinoIcons.chevron_down),
                              value: provider.getFontSize(),
                              items: [14, 16, 18, 20, 22]
                                  .map((n) => DropdownMenuItem(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8.0),
                                        child: Text(n.toString(),
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold)),
                                      ),
                                      value: n))
                                  .toList()),
                          leading: Icon(Icons.text_fields),
                        ),
                      ])
                    ])),
              ],
            );
          },
        ),
      ),
    );
  }
}
