import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_dimens.dart';
import '../../../app/theme/app_gradients.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/feature_flags.dart';
import '../../../core/utils/context_extensions.dart';
import '../../../core/utils/unit_converter.dart';
import '../../../core/widgets/section_card.dart';
import '../controllers/settings_controller.dart';
import '../widgets/settings_tile.dart';

class SettingsView extends GetView<SettingsController> {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = controller.settings;

    final sections = <Widget>[
      // ---- Appearance ------------------------------------------------------
      SectionCard(
        title: 'Appearance',
        icon: Icons.palette_outlined,
        accent: const Color(0xFF7E57C2),
        child: Obx(
          () => SegmentedButton<ThemeMode>(
            showSelectedIcon: false,
            segments: const [
              ButtonSegment(value: ThemeMode.light, label: Text('Light'), icon: Icon(Icons.light_mode_outlined)),
              ButtonSegment(value: ThemeMode.dark, label: Text('Dark'), icon: Icon(Icons.dark_mode_outlined)),
              ButtonSegment(value: ThemeMode.system, label: Text('System'), icon: Icon(Icons.phone_iphone_rounded)),
            ],
            selected: {settings.themeMode.value},
            onSelectionChanged: (selection) => controller.setThemeMode(selection.first),
          ),
        ),
      ),

      // ---- Units -----------------------------------------------------------
      SectionCard(
        title: 'Units',
        icon: Icons.straighten_rounded,
        accent: AppColors.primary,
        child: Obx(
          () => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _ChoiceLabel('Temperature'),
              SettingsChoice<TemperatureUnit>(
                values: TemperatureUnit.values,
                selected: settings.temperatureUnit.value,
                labelOf: (u) => '${u.label} (${u.symbol})',
                onSelected: controller.setTemperatureUnit,
              ),
              const SizedBox(height: AppSpacing.md),
              const _ChoiceLabel('Wind speed'),
              SettingsChoice<WindSpeedUnit>(
                values: WindSpeedUnit.values,
                selected: settings.windSpeedUnit.value,
                labelOf: (u) => u.symbol,
                onSelected: controller.setWindSpeedUnit,
              ),
              const SizedBox(height: AppSpacing.md),
              const _ChoiceLabel('Pressure'),
              SettingsChoice<PressureUnit>(
                values: PressureUnit.values,
                selected: settings.pressureUnit.value,
                labelOf: (u) => u.symbol,
                onSelected: controller.setPressureUnit,
              ),
              const SizedBox(height: AppSpacing.sm),
              SettingsTile(
                icon: Icons.schedule_rounded,
                accent: AppColors.info,
                title: '24-hour time',
                subtitle: settings.use24HourClock.value ? '14:30' : '2:30 PM',
                trailing: Switch(
                  value: settings.use24HourClock.value,
                  onChanged: controller.setUse24HourClock,
                ),
              ),
            ],
          ),
        ),
      ),

      // ---- Location --------------------------------------------------------
      SectionCard(
        title: 'Location',
        icon: Icons.location_on_outlined,
        accent: AppColors.success,
        child: Obx(() {
          final status = controller.locationStatus.value;
          final (label, color, icon) = switch (status) {
            LocationAccessStatus.allowed => ('Allowed', AppColors.success, Icons.check_circle_rounded),
            LocationAccessStatus.denied => ('Not allowed', AppColors.error, Icons.block_rounded),
            LocationAccessStatus.servicesOff => ('Location services off', AppColors.warning, Icons.gps_off_rounded),
            LocationAccessStatus.unknown => ('Checking…', AppColors.info, Icons.help_outline_rounded),
          };
          return Column(
            children: [
              SettingsTile(
                icon: icon,
                accent: color,
                title: 'Location access',
                subtitle: label,
                trailing: TextButton(
                  onPressed: controller.openLocationFix,
                  child: Text(status == LocationAccessStatus.allowed ? 'Manage' : 'Fix'),
                ),
              ),
              SettingsTile(
                icon: Icons.my_location_rounded,
                accent: AppColors.primary,
                title: 'Use my current location',
                subtitle: 'Show weather for where you are',
                onTap: controller.useCurrentLocation,
              ),
            ],
          );
        }),
      ),

      // ---- Notifications ---------------------------------------------------
      if (FeatureFlags.notifications)
        SectionCard(
          title: 'Notifications',
          icon: Icons.notifications_outlined,
          accent: AppColors.sunDeep,
          child: Obx(
            () => Column(
              children: [
                SettingsTile(
                  icon: Icons.wb_twilight_rounded,
                  accent: AppColors.sun,
                  title: 'Morning summary',
                  subtitle: 'A daily overview of the day ahead',
                  trailing: Switch(
                    value: settings.dailySummaryEnabled.value,
                    onChanged: controller.setDailySummaryEnabled,
                  ),
                ),
                AnimatedOpacity(
                  duration: AppDurations.normal,
                  opacity: settings.dailySummaryEnabled.value ? 1 : 0.45,
                  child: SettingsTile(
                    icon: Icons.alarm_rounded,
                    accent: AppColors.info,
                    title: 'Summary time',
                    subtitle: controller.formatTime(settings.dailySummaryTime.value),
                    onTap: settings.dailySummaryEnabled.value
                        ? () => controller.pickDailySummaryTime(context)
                        : null,
                  ),
                ),
                SettingsTile(
                  icon: Icons.warning_amber_rounded,
                  accent: AppColors.severitySevere,
                  title: 'Severe weather alerts',
                  subtitle: 'Warnings for your saved locations',
                  trailing: Switch(
                    value: settings.severeAlertsEnabled.value,
                    onChanged: controller.setSevereAlertsEnabled,
                  ),
                ),
              ],
            ),
          ),
        ),

      // ---- Data ------------------------------------------------------------
      SectionCard(
        title: 'Data',
        icon: Icons.storage_rounded,
        accent: const Color(0xFF26A69A),
        child: Obx(
          () => Column(
            children: [
              SettingsTile(
                icon: Icons.history_rounded,
                accent: AppColors.info,
                title: 'Clear search history',
                subtitle: '${controller.recentSearches.length} recent searches',
                onTap: controller.clearSearchHistory,
              ),
              SettingsTile(
                icon: Icons.favorite_border_rounded,
                accent: const Color(0xFFFF5F8F),
                title: 'Clear favorite locations',
                subtitle: '${controller.favorites.length} saved',
                onTap: controller.clearFavorites,
              ),
              SettingsTile(
                icon: Icons.cloud_off_rounded,
                accent: const Color(0xFF78909C),
                title: 'Clear cached weather',
                subtitle: 'Removes offline data',
                onTap: controller.clearCachedWeather,
              ),
              SettingsTile(
                icon: Icons.restart_alt_rounded,
                accent: AppColors.error,
                title: 'Reset settings',
                subtitle: 'Back to defaults',
                onTap: controller.resetSettings,
                destructive: true,
              ),
            ],
          ),
        ),
      ),

      // ---- About -----------------------------------------------------------
      SectionCard(
        title: 'About',
        icon: Icons.info_outline_rounded,
        accent: AppColors.primaryDark,
        child: Column(
          children: [
            SettingsTile(
              icon: Icons.wb_sunny_rounded,
              accent: AppColors.sun,
              title: 'About ${AppConstants.appName}',
              subtitle: AppConstants.tagline,
              onTap: controller.openAbout,
            ),
            SettingsTile(
              icon: Icons.public_rounded,
              accent: AppColors.primary,
              title: 'Weather data by OpenWeatherMap',
              subtitle: 'openweathermap.org',
              onTap: () => controller.openUrl('https://openweathermap.org'),
            ),
            Obx(
              () => SettingsTile(
                icon: Icons.verified_outlined,
                accent: AppColors.success,
                title: 'App version',
                subtitle: controller.appVersion.value.isEmpty ? '…' : controller.appVersion.value,
              ),
            ),
          ],
        ),
      ),
    ];

    return DecoratedBox(
      decoration: BoxDecoration(gradient: AppGradients.scaffold(context.brightness)),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(title: const Text('Settings')),
        body: ListView.separated(
          padding: const EdgeInsets.fromLTRB(AppSpacing.page, AppSpacing.sm, AppSpacing.page, AppSpacing.xxl),
          physics: const BouncingScrollPhysics(),
          itemCount: sections.length,
          separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
          itemBuilder: (context, index) => sections[index]
              .animate(delay: (50 * index).ms)
              .fadeIn(duration: 350.ms)
              .slideY(begin: 0.05, end: 0, curve: Curves.easeOutCubic),
        ),
      ),
    );
  }
}

class _ChoiceLabel extends StatelessWidget {
  const _ChoiceLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Text(
        text,
        style: context.textStyles.labelLarge?.copyWith(color: context.appColors.textSecondary),
      ),
    );
  }
}
