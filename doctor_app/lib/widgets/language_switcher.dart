import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';
import '../utils/constants.dart';

class LanguageSwitcher extends StatelessWidget {
  final bool showText;
  final bool isCompact;

  const LanguageSwitcher({
    super.key,
    this.showText = true,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);

    if (isCompact) {
      return IconButton(
        onPressed: () => languageProvider.toggleLanguage(),
        icon: Icon(Icons.language, color: AppColors.textSecondary),
        tooltip: languageProvider.otherLanguageName,
      );
    }

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(AppConstants.mediumRadius),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildLanguageOption(
            context,
            'العربية',
            'ar',
            languageProvider.isArabic,
            () => languageProvider.setArabic(),
          ),
          Container(width: 1, height: 30, color: AppColors.border),
          _buildLanguageOption(
            context,
            'English',
            'en',
            languageProvider.isEnglish,
            () => languageProvider.setEnglish(),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageOption(
    BuildContext context,
    String text,
    String code,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.mediumSpacing,
          vertical: AppConstants.smallSpacing,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(AppConstants.mediumRadius),
        ),
        child: Text(
          showText ? text : code.toUpperCase(),
          style: AppTextStyles.bodySmall.copyWith(
            color:
                isSelected ? AppColors.textOnPrimary : AppColors.textSecondary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

class LanguageDropdown extends StatelessWidget {
  const LanguageDropdown({super.key});

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);

    return PopupMenuButton<String>(
      onSelected: (String languageCode) {
        languageProvider.changeLanguage(languageCode);
      },
      itemBuilder:
          (BuildContext context) => [
            PopupMenuItem<String>(
              value: 'ar',
              child: Row(
                children: [
                  Icon(
                    Icons.check,
                    color:
                        languageProvider.isArabic
                            ? AppColors.primary
                            : Colors.transparent,
                  ),
                  const SizedBox(width: AppConstants.smallSpacing),
                  const Text('العربية'),
                ],
              ),
            ),
            PopupMenuItem<String>(
              value: 'en',
              child: Row(
                children: [
                  Icon(
                    Icons.check,
                    color:
                        languageProvider.isEnglish
                            ? AppColors.primary
                            : Colors.transparent,
                  ),
                  const SizedBox(width: AppConstants.smallSpacing),
                  const Text('English'),
                ],
              ),
            ),
          ],
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.mediumSpacing,
          vertical: AppConstants.smallSpacing,
        ),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(AppConstants.mediumRadius),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.language,
              size: AppConstants.mediumIconSize,
              color: AppColors.textSecondary,
            ),
            const SizedBox(width: AppConstants.smallSpacing),
            Text(
              languageProvider.currentLanguageName,
              style: AppTextStyles.bodyMedium,
            ),
            const SizedBox(width: AppConstants.smallSpacing),
            Icon(Icons.arrow_drop_down, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}
