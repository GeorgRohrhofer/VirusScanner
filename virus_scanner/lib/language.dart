import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;

class Language{
    String scanButton = '';
    String abortButton = '';
    String file = '';
    String directory = '';
    String memory = '';
    String choosePath = '';
    String noPathSelected = '';
    String activeScanLabel = '';
    String scanHistoryLabel = '';
    String deleteHistoryToolTip = '';
    String openSettingsToolTip = '';
    String settingsPageTitle = '';
    String lightDarkMode = '';
    String themeColor = '';
    String selectThemeColor = '';
    String language = '';

    Language(String languageAbbreviation) {
        changeLanguage(languageAbbreviation);
    }

    changeLanguage(String languageAbbreviation) {
        String filePath;
        switch(languageAbbreviation) {
            case 'en':
                filePath = 'english.language';
                break;
            case 'de':
                filePath = 'german.language';
                break;
            default:
                debugPrint('Unsupported language: $languageAbbreviation');
                return;
        }

        // Change language by reloading the file
        try {
            final exeDir = File(Platform.resolvedExecutable).parent;
            final assetPath = path.join(exeDir.path, 'data', 'flutter_assets', filePath);

            var lines = File(assetPath).readAsLinesSync(); 
            scanButton = lines[0];
            abortButton = lines[1];
            file = lines[2];
            directory = lines[3];
            memory = lines[4];
            choosePath = lines[5];
            noPathSelected = lines[6];
            activeScanLabel = lines[7];
            scanHistoryLabel = lines[8];
            deleteHistoryToolTip = lines[9];
            openSettingsToolTip = lines[10];
            settingsPageTitle = lines[11];
            lightDarkMode = lines[12];
            themeColor = lines[13];
            selectThemeColor = lines[14];
            language = lines[15];
        } catch (e) {
            // Handle file reading errors
            debugPrint("Error reading language file: $e");
        }
    }
}