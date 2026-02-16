import 'package:flutter/material.dart';
import '../utils/localization_service.dart';

class LanguageSelector extends StatelessWidget {
  const LanguageSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: LocalizationService.instance,
      builder: (context, _) {
        final localization = LocalizationService.instance;
        
        return PopupMenuButton<String>(
          icon: const Icon(Icons.language),
          tooltip: 'Select Language',
          onSelected: (String langCode) async {
            await localization.setLanguage(langCode);
          },
          itemBuilder: (BuildContext context) {
            return [
              PopupMenuItem<String>(
                value: 'en',
                child: Row(
                  children: [
                    Text(
                      localization.translate('english'),
                      style: TextStyle(
                        fontWeight: localization.languageCode == 'en'
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                    if (localization.languageCode == 'en')
                      const Padding(
                        padding: EdgeInsets.only(left: 8),
                        child: Icon(Icons.check, color: Colors.green),
                      ),
                  ],
                ),
              ),
              PopupMenuItem<String>(
                value: 'hi',
                child: Row(
                  children: [
                    Text(
                      localization.translate('hindi'),
                      style: TextStyle(
                        fontWeight: localization.languageCode == 'hi'
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                    if (localization.languageCode == 'hi')
                      const Padding(
                        padding: EdgeInsets.only(left: 8),
                        child: Icon(Icons.check, color: Colors.green),
                      ),
                  ],
                ),
              ),
            ];
          },
        );
      },
    );
  }
}
