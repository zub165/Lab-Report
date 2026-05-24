import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lab_mobile_app/providers/language_provider.dart';

void main() {
  group('LanguageProvider', () {
    late LanguageProvider provider;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      provider = LanguageProvider();
    });

    test('default language is English', () {
      expect(provider.currentLanguage, AppLanguage.english);
    });

    test('isLoaded becomes true after construction', () async {
      await Future.microtask(() {});
      expect(provider.isLoaded, true);
    });

    test('getText returns English text by default', () {
      expect(provider.getText('dashboard'), 'Dashboard');
      expect(provider.getText('patients'), 'Patients');
      expect(provider.getText('tests'), 'Tests');
    });

    test('getText returns key for unknown keys', () {
      expect(provider.getText('nonexistent_key'), 'nonexistent_key');
    });

    test('setLanguage changes language and text', () async {
      await provider.setLanguage(AppLanguage.spanish);
      expect(provider.currentLanguage, AppLanguage.spanish);
      expect(provider.getText('dashboard'), 'Panel de Control');
      expect(provider.getText('patients'), 'Pacientes');
    });

    test('setLanguage to French returns French text', () async {
      await provider.setLanguage(AppLanguage.french);
      expect(provider.getText('dashboard'), 'Tableau de Bord');
      expect(provider.getText('retry'), 'Réessayer');
    });

    test('setLanguage to Arabic returns Arabic text and RTL', () async {
      await provider.setLanguage(AppLanguage.arabic);
      expect(provider.currentLanguage, AppLanguage.arabic);
      expect(provider.textDirection, TextDirection.rtl);
      expect(provider.getText('dashboard'), 'لوحة التحكم');
    });

    test('setLanguage to Urdu returns Urdu text and RTL', () async {
      await provider.setLanguage(AppLanguage.urdu);
      expect(provider.currentLanguage, AppLanguage.urdu);
      expect(provider.textDirection, TextDirection.rtl);
      expect(provider.getText('dashboard'), 'ڈیش بورڈ');
    });

    test('setLanguage to Hindi returns Hindi text and LTR', () async {
      await provider.setLanguage(AppLanguage.hindi);
      expect(provider.currentLanguage, AppLanguage.hindi);
      expect(provider.textDirection, TextDirection.ltr);
      expect(provider.getText('dashboard'), 'डैशबोर्ड');
    });

    test('setLanguage to German returns German text', () async {
      await provider.setLanguage(AppLanguage.german);
      expect(provider.getText('dashboard'), 'Dashboard');
      expect(provider.getText('patients'), 'Patienten');
    });

    test('setLanguage to Portuguese returns Portuguese text', () async {
      await provider.setLanguage(AppLanguage.portuguese);
      expect(provider.getText('dashboard'), 'Painel');
      expect(provider.getText('logout'), 'Sair');
    });

    test('setLanguage to Chinese returns Chinese text', () async {
      await provider.setLanguage(AppLanguage.chinese);
      expect(provider.getText('dashboard'), '仪表板');
      expect(provider.getText('patients'), '患者');
    });

    test('setLanguage to Turkish returns Turkish text', () async {
      await provider.setLanguage(AppLanguage.turkish);
      expect(provider.getText('dashboard'), 'Kontrol paneli');
      expect(provider.getText('retry'), 'Tekrar dene');
    });

    test('setLanguage to Bengali returns Bengali text', () async {
      await provider.setLanguage(AppLanguage.bengali);
      expect(provider.getText('dashboard'), 'ড্যাশবোর্ড');
      expect(provider.getText('patients'), 'রোগী');
    });

    test('locale returns correct Locale for each language', () async {
      await provider.setLanguage(AppLanguage.english);
      expect(provider.locale, const Locale('en'));

      await provider.setLanguage(AppLanguage.spanish);
      expect(provider.locale, const Locale('es'));

      await provider.setLanguage(AppLanguage.french);
      expect(provider.locale, const Locale('fr'));
    });

    test('notifyListeners is called on setLanguage', () async {
      var notified = false;
      provider.addListener(() => notified = true);
      await provider.setLanguage(AppLanguage.french);
      expect(notified, true);
    });

    test('supportedLanguages list includes all 11 languages', () {
      expect(LanguageProvider.supportedLanguages.length, 11);
      expect(LanguageProvider.supportedLanguages[0].language, AppLanguage.english);
      expect(LanguageProvider.supportedLanguages[0].flag, '🇺🇸');
    });
  });
}
