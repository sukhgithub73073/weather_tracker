import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_dimens.dart';
import '../../../app/theme/app_gradients.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/context_extensions.dart';
import '../../../core/widgets/app_logo.dart';
import '../../../core/widgets/section_card.dart';
import '../controllers/settings_controller.dart';
import '../widgets/settings_tile.dart';

class AboutView extends GetView<SettingsController> {
  const AboutView({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textStyles;
    return DecoratedBox(
      decoration: BoxDecoration(gradient: AppGradients.scaffold(context.brightness)),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(title: const Text('About')),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(AppSpacing.page, AppSpacing.md, AppSpacing.page, AppSpacing.xxl),
          physics: const BouncingScrollPhysics(),
          children: [
            Center(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: AppGradients.floatingShadow(context.brightness),
                ),
                child: const AppLogo(size: 120),
              ),
            ).animate().scale(begin: const Offset(0.8, 0.8), curve: Curves.easeOutBack, duration: 600.ms).fadeIn(),
            const SizedBox(height: AppSpacing.lg),
            Text(
              AppConstants.appName,
              textAlign: TextAlign.center,
              style: textTheme.headlineMedium,
            ),
            const SizedBox(height: AppSpacing.xs),
            Obx(
              () => Text(
                'Version ${controller.appVersion.value}',
                textAlign: TextAlign.center,
                style: textTheme.bodyMedium?.copyWith(color: context.appColors.textSecondary),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Real-time conditions, hourly and multi-day forecasts, severe-weather alerts and '
              'air quality for any city in the world – with beautiful visuals that follow the sky.',
              textAlign: TextAlign.center,
              style: textTheme.bodyLarge?.copyWith(height: 1.5),
            ),
            const SizedBox(height: AppSpacing.xl),
            SectionCard(
              title: 'Credits',
              icon: Icons.favorite_rounded,
              accent: const Color(0xFFFF5F8F),
              child: Column(
                children: [
                  SettingsTile(
                    icon: Icons.cloud_outlined,
                    accent: AppColors.primary,
                    title: 'Weather data',
                    subtitle: 'OpenWeatherMap',
                    onTap: () => controller.openUrl('https://openweathermap.org'),
                  ),
                  SettingsTile(
                    icon: Icons.map_outlined,
                    accent: AppColors.success,
                    title: 'Map tiles',
                    subtitle: '© OpenStreetMap contributors',
                    onTap: () => controller.openUrl('https://www.openstreetmap.org/copyright'),
                  ),
                  SettingsTile(
                    icon: Icons.flutter_dash,
                    accent: AppColors.info,
                    title: 'Built with Flutter & GetX',
                    subtitle: 'flutter.dev',
                    onTap: () => controller.openUrl('https://flutter.dev'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            SectionCard(
              title: 'Legal',
              icon: Icons.gavel_rounded,
              accent: AppColors.primaryDark,
              child: Column(
                children: [
                  SettingsTile(
                    icon: Icons.privacy_tip_outlined,
                    accent: AppColors.sunDeep,
                    title: 'Privacy policy',
                    onTap: () => controller.openUrl(AppConstants.privacyUrl),
                  ),
                  SettingsTile(
                    icon: Icons.mail_outline_rounded,
                    accent: AppColors.info,
                    title: 'Contact support',
                    subtitle: AppConstants.supportEmail,
                    onTap: () => controller.openUrl('mailto:${AppConstants.supportEmail}'),
                  ),
                  SettingsTile(
                    icon: Icons.article_outlined,
                    accent: const Color(0xFF78909C),
                    title: 'Open-source licenses',
                    onTap: () => showLicensePage(
                      context: context,
                      applicationName: AppConstants.appName,
                      applicationVersion: controller.appVersion.value,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              '© ${DateTime.now().year} ${AppConstants.appName}',
              textAlign: TextAlign.center,
              style: textTheme.labelMedium?.copyWith(color: context.appColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
