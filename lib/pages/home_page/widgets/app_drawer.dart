import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as utils;

import 'package:sweet/bloc/data_loading_bloc/data_loading.dart';
import 'package:sweet/mixins/file_selector_mixin.dart';
import 'package:sweet/pages/character_profile/widgets/character_profile_header.dart';
import 'package:sweet/pages/home_page/widgets/app_update_banner.dart';
import 'package:sweet/pages/home_page/widgets/pi_reminder.dart';
import 'package:sweet/util/localisation_constants.dart';
import 'package:sweet/util/platform_helper.dart';
import 'package:sweet/util/sweet_icons.dart';

import '../../ship_fitting/widgets/pilot_context_drawer.dart';
import '../../../bloc/navigation_bloc/navigation.dart';
import '../../../model/character/character.dart';
import '../../../repository/character_repository.dart';

import 'app_banner.dart';
import 'social_button.dart';
import 'version_label.dart';

class AppDrawer extends StatefulWidget {
  const AppDrawer({
    super.key,
  });

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> with FileSelector {
  @override
  Widget build(BuildContext context) {
    final charRepo = RepositoryProvider.of<CharacterRepository>(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.primaryColor;

    // Subtle background tint for the drawer
    final drawerBg = isDark
        ? Color.lerp(Colors.grey.shade900, primaryColor, 0.05)
        : Colors.white;

    // Section header style
    final sectionStyle = TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w600,
      letterSpacing: 1.2,
      color: primaryColor.withAlpha(isDark ? 180 : 200),
    );

    return SafeArea(
      child: Drawer(
        backgroundColor: drawerBg,
        child: SafeArea(
          child: Column(
            children: [
              // --- Banner ---
              AppBanner(),

              // --- Menu ---
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  children: <Widget>[
                    AppUpdateBanner(),

                    // -- Pilot section --
                    _buildSectionHeader('PILOT', sectionStyle),
                    _buildPilotTile(context, charRepo, primaryColor, isDark),
                    PIReminder(),

                    const SizedBox(height: 4),
                    _buildDivider(isDark),

                    // -- Browse section --
                    _buildSectionHeader('BROWSE', sectionStyle),
                    _buildDrawerItem(
                      context,
                      title: 'Character Browser',
                      icon: Icons.person_outline,
                      event: ShowCharacterBrowserPage(),
                      primaryColor: primaryColor,
                      isDark: isDark,
                    ),
                    _buildDrawerItem(
                      context,
                      title: 'Market Browser',
                      icon: Icons.storefront_outlined,
                      event: ShowMarketBrowserPage(),
                      primaryColor: primaryColor,
                      isDark: isDark,
                    ),
                    if (PlatformHelper.isDebug)
                      _buildDrawerItem(
                        context,
                        title: 'Items Browser',
                        icon: Icons.menu_book_outlined,
                        event: ShowItemBrowserPage(),
                        primaryColor: primaryColor,
                        isDark: isDark,
                      ),

                    const SizedBox(height: 4),
                    _buildDivider(isDark),

                    // -- Tools section --
                    _buildSectionHeader('TOOLS', sectionStyle),
                    _buildDrawerItem(
                      context,
                      title: 'Fitting Tool',
                      icon: SweetIcons.fitting,
                      event: ShowFittingToolPage(),
                      primaryColor: primaryColor,
                      isDark: isDark,
                    ),
                    _buildDrawerItem(
                      context,
                      title: 'Implant List',
                      icon: SweetIcons.implant,
                      event: ShowImplantToolPage(),
                      primaryColor: primaryColor,
                      isDark: isDark,
                    ),

                    const SizedBox(height: 4),
                    _buildDivider(isDark),

                    // -- Other section --
                    _buildSectionHeader('OTHER', sectionStyle),
                    _buildDrawerItem(
                      context,
                      title: 'Announcements',
                      icon: Icons.campaign_outlined,
                      event: ShowPatchNotesPage(),
                      primaryColor: primaryColor,
                      isDark: isDark,
                    ),
                    _buildDrawerItem(
                      context,
                      title: 'Settings',
                      icon: Icons.settings_outlined,
                      event: ShowSettingsPage(),
                      primaryColor: primaryColor,
                      isDark: isDark,
                    ),
                    _buildImportExportTile(context, primaryColor, isDark),
                  ],
                ),
              ),

              // --- Footer ---
              _buildDivider(isDark),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: VersionLabel(
                        color: theme.textTheme.bodyLarge!.color!
                            .withAlpha(100),
                      ),
                    ),
                    SizedBox(
                      height: 32,
                      child: SocialButton(
                        assetName:
                            'assets/branding/discord-logo-white.svg',
                        socialUrl: 'https://discord.gg/2QyVpSJKte',
                        size: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, TextStyle style) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 16, 4),
      child: Text(title, style: style),
    );
  }

  Widget _buildDivider(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Divider(
        height: 1,
        thickness: 1,
        color: isDark
            ? Colors.white.withAlpha(15)
            : Colors.black.withAlpha(15),
      ),
    );
  }

  Widget _buildPilotTile(
    BuildContext context,
    CharacterRepository charRepo,
    Color primaryColor,
    bool isDark,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
      child: ListTile(
        dense: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        leading: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: primaryColor.withAlpha(isDark ? 40 : 25),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.airline_seat_recline_extra_outlined,
            size: 20,
            color: primaryColor,
          ),
        ),
        title: Text(
          StaticLocalisationStrings.defaultPilot,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          charRepo.defaultPilot.name,
          style: TextStyle(
            fontSize: 12,
            color: primaryColor.withAlpha(isDark ? 200 : 180),
          ),
        ),
        onTap: () => showPilotDrawer(context),
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context, {
    required String title,
    required IconData icon,
    required NavigationEvent event,
    required Color primaryColor,
    required bool isDark,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
      child: ListTile(
        dense: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        leading: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: primaryColor.withAlpha(isDark ? 40 : 25),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 20,
            color: primaryColor,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
        ),
        onTap: () {
          BlocProvider.of<NavigationBloc>(context).add(event);
          Navigator.of(context).pop();
        },
      ),
    );
  }

  Widget _buildImportExportTile(
    BuildContext context,
    Color primaryColor,
    bool isDark,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
      child: ListTile(
        dense: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        leading: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: primaryColor.withAlpha(isDark ? 40 : 25),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.swap_horiz_outlined,
            size: 20,
            color: primaryColor,
          ),
        ),
        title: Text(
          StaticLocalisationStrings.importExport,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
        ),
        onTap: _importExportDialog,
      ),
    );
  }

  Future<void> showPilotDrawer(BuildContext context) async {
    var selection = await showModalBottomSheet<Character>(
      context: context,
      elevation: 16,
      builder: (context) => PilotContextDrawer(),
    );

    if (selection != null) {
      final charRepo = RepositoryProvider.of<CharacterRepository>(context);
      await charRepo.setDefaultPilot(pilot: selection);
      setState(() {});
    }
  }

  Future<void> _importExportDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext dialogContext) {
        return ImportExportDialog(
          title: 'Import/Export Data',
          description:
              'Importing will override all skills and fittings and cannot be undone!',
          onExport: () => _exportFromFile(),
          onImport: () => _importFromFile(),
        );
      },
    );
  }

  Future<void> _exportFromFile() async {
    final folder = await selectFolder();

    if (folder != null) {
      final path = utils.join(
        folder,
        DateFormat('yyyyMMdd-HHmm').format(DateTime.now()),
      );
      context.read<DataLoadingBloc>().add(ExportDataEvent(path: path));
    }
  }

  Future<void> _importFromFile() async {
    final path = await selectFile();

    if (path != null) {
      context.read<DataLoadingBloc>().add(ImportDataEvent(path: path));
    }
  }
}
