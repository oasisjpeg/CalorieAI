// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get appTitle => 'CalorieAI';

  @override
  String appVersionName(Object versionNumber) {
    return 'Sürüm $versionNumber';
  }

  @override
  String get appDescription => 'CalorieAI, gizliliğinize saygı duyan ücretsiz ve açık kaynaklı bir kalori ve besin takipçisidir.';

  @override
  String get alphaVersionName => '[Alfa]';

  @override
  String get betaVersionName => '[Beta]';

  @override
  String get addLabel => 'Ekle';

  @override
  String get createCustomDialogTitle => 'Özel yemek öğesi oluşturulsun mu?';

  @override
  String get createCustomDialogContent => 'Özel bir yemek öğesi oluşturmak istiyor musunuz?';

  @override
  String get settingsLabel => 'Ayarlar';

  @override
  String get homeLabel => 'Ana Sayfa';

  @override
  String get diaryLabel => 'Günlük';

  @override
  String get profileLabel => 'Profil';

  @override
  String get searchLabel => 'Ara';

  @override
  String get searchProductsPage => 'Ürünler';

  @override
  String get searchFoodPage => 'Yiyecek';

  @override
  String get searchResultsLabel => 'Arama sonuçları';

  @override
  String get searchDefaultLabel => 'Lütfen bir arama kelimesi girin';

  @override
  String get allItemsLabel => 'Tümü';

  @override
  String get recentlyAddedLabel => 'Son Eklenenler';

  @override
  String get noMealsRecentlyAddedLabel => 'Son zamanlarda eklenen yemek yok';

  @override
  String get noActivityRecentlyAddedLabel => 'Son zamanlarda eklenen aktivite yok';

  @override
  String get dialogOKLabel => 'TAMAM';

  @override
  String get dialogCancelLabel => 'İPTAL';

  @override
  String get buttonStartLabel => 'BAŞLA';

  @override
  String get buttonNextLabel => 'İLERİ';

  @override
  String get buttonSaveLabel => 'Kaydet';

  @override
  String get buttonYesLabel => 'EVET';

  @override
  String get buttonResetLabel => 'Reset';

  @override
  String get onboardingWelcomeLabel => 'Hoş Geldiniz';

  @override
  String get onboardingOverviewLabel => 'Genel Bakış';

  @override
  String get onboardingYourGoalLabel => 'Kalori hedefiniz:';

  @override
  String get onboardingYourMacrosGoalLabel => 'Makrobesin hedefleriniz:';

  @override
  String get onboardingKcalPerDayLabel => 'günlük kalori';

  @override
  String get onboardingIntroDescription => 'Başlamak için, uygulamanın günlük kalori hedefinizi hesaplamak için hakkınızda bazı bilgilere ihtiyacı var.\nHakkınızdaki tüm bilgiler cihazınızda güvenli bir şekilde saklanır.';

  @override
  String get onboardingGenderQuestionSubtitle => 'Cinsiyetiniz nedir?';

  @override
  String get onboardingEnterBirthdayLabel => 'Doğum Günü';

  @override
  String get onboardingBirthdayHint => 'Tarih Girin';

  @override
  String get onboardingBirthdayQuestionSubtitle => 'Doğum gününüz ne zaman?';

  @override
  String get onboardingHeightQuestionSubtitle => 'Mevcut boyunuz nedir?';

  @override
  String get onboardingWeightQuestionSubtitle => 'Mevcut kilonuz nedir?';

  @override
  String get onboardingWrongHeightLabel => 'Doğru boyu girin';

  @override
  String get onboardingWrongWeightLabel => 'Doğru kiloyu girin';

  @override
  String get onboardingWeightExampleHintKg => 'örn. 60';

  @override
  String get onboardingWeightExampleHintLbs => 'e.g. 132';

  @override
  String get onboardingHeightExampleHintCm => 'örn. 170';

  @override
  String get onboardingHeightExampleHintFt => 'e.g. 5.8';

  @override
  String get onboardingActivityQuestionSubtitle => 'Ne kadar aktifsiniz? (antrenmanlar hariç)';

  @override
  String get onboardingGoalQuestionSubtitle => 'Mevcut kilo hedefiniz nedir?';

  @override
  String get onboardingSaveUserError => 'Yanlış giriş, lütfen tekrar deneyin';

  @override
  String get settingsUnitsLabel => 'Birimler';

  @override
  String get stepsPermissionDenied => 'Please grant access to Apple Health to track your steps';

  @override
  String get stepsGrantAccess => 'Grant Access';

  @override
  String get steps => 'Steps';

  @override
  String get stepsToday => 'Today';

  @override
  String get settingsCalculationsLabel => 'Hesaplamalar';

  @override
  String get settingsThemeLabel => 'Tema';

  @override
  String get settingsThemeLightLabel => 'Açık';

  @override
  String get settingsThemeDarkLabel => 'Koyu';

  @override
  String get settingsThemeSystemDefaultLabel => 'Sistem varsayılanı';

  @override
  String get settingsLicensesLabel => 'Lisanslar';

  @override
  String get settingsDisclaimerLabel => 'Sorumluluk Reddi';

  @override
  String get settingsReportErrorLabel => 'Hata Bildir';

  @override
  String get settingsPrivacySettings => 'Gizlilik Ayarları';

  @override
  String get settingsSourceCodeLabel => 'Kaynak Kodu';

  @override
  String get settingFeedbackLabel => 'Geri Bildirim';

  @override
  String get settingAboutLabel => 'Hakkında';

  @override
  String get settingsMassLabel => 'Kütle';

  @override
  String get settingsSystemLabel => 'System';

  @override
  String get settingsMetricLabel => 'Metric (kg, cm, ml)';

  @override
  String get settingsImperialLabel => 'Imperial (lbs, ft, oz)';

  @override
  String get settingsDistanceLabel => 'Mesafe';

  @override
  String get settingsVolumeLabel => 'Hacim';

  @override
  String get disclaimerText => 'CalorieAI tıbbi bir uygulama değildir. Sağlanan tüm veriler doğrulanmamıştır ve dikkatle kullanılmalıdır. Lütfen sağlıklı bir yaşam tarzı sürdürün ve herhangi bir sorununuz varsa bir uzmana danışın. Hastalık, hamilelik veya emzirme döneminde kullanılması önerilmez.\n\n\nUygulama hala geliştirme aşamasındadır. Hatalar, buglar ve çökmeler meydana gelebilir.';

  @override
  String get reportErrorDialogText => 'Geliştiriciye bir hata bildirmek istiyor musunuz?';

  @override
  String get sendAnonymousUserData => 'Anonim kullanım verilerini gönder';

  @override
  String get appLicenseLabel => 'GPL-3.0 lisansı';

  @override
  String get calculationsTDEELabel => 'TDEE denklemi';

  @override
  String get calculationsTDEEIOM2006Label => 'Tıp Enstitüsü Denklemi';

  @override
  String get calculationsRecommendedLabel => '(önerilen)';

  @override
  String get calculationsMacronutrientsDistributionLabel => 'Makro besin dağılımı';

  @override
  String calculationsMacrosDistribution(Object pctCarbs, Object pctFats, Object pctProteins) {
    return '%$pctCarbs karbonhidrat, %$pctFats yağ, %$pctProteins protein';
  }

  @override
  String get dailyKcalAdjustmentLabel => 'Daily Kcal adjustment:';

  @override
  String get macroDistributionLabel => 'Macronutrient Distribution:';

  @override
  String get exportImportLabel => 'Export / Import data';

  @override
  String get exportImportDescription => 'You can export the app data to a zip file and import it later. This is useful if you want to backup your data or transfer it to another device.\n\nThe app does not use any cloud service to store your data.';

  @override
  String get exportImportSuccessLabel => 'Export / Import successful';

  @override
  String get exportImportErrorLabel => 'Export / Import error';

  @override
  String get exportAction => 'Export';

  @override
  String get importAction => 'Import';

  @override
  String get addItemLabel => 'Yeni Öğe Ekle:';

  @override
  String get activityLabel => 'Aktivite';

  @override
  String get activityExample => 'örn. koşu, bisiklet, yoga ...';

  @override
  String get breakfastLabel => 'Kahvaltı';

  @override
  String get breakfastExample => 'örn. tahıl, süt, kahve ...';

  @override
  String get lunchLabel => 'Öğle Yemeği';

  @override
  String get lunchExample => 'örn. pizza, salata, pilav ...';

  @override
  String get dinnerLabel => 'Akşam Yemeği';

  @override
  String get dinnerExample => 'örn. çorba, tavuk, şarap ...';

  @override
  String get snackLabel => 'Atıştırmalık';

  @override
  String get snackExample => 'örn. elma, dondurma, çikolata ...';

  @override
  String get editItemDialogTitle => 'Öğeyi düzenle';

  @override
  String get itemUpdatedSnackbar => 'Öğe güncellendi';

  @override
  String get deleteTimeDialogTitle => 'Öğe Silinsin mi?';

  @override
  String get deleteTimeDialogContent => 'Seçili öğeyi silmek istiyor musunuz?';

  @override
  String get itemDeletedSnackbar => 'Öğe silindi';

  @override
  String get copyDialogTitle => 'Hangi öğüne eklemek istiyorsunuz?';

  @override
  String get copyOrDeleteTimeDialogTitle => 'Ne yapılmalı?';

  @override
  String get copyOrDeleteTimeDialogContent => '\"Bugüne kopyala\" seçeneğine tıklayarak öğünü bugüne kopyalayabilirsiniz. \"Sil\" seçeneği ile öğün kaldırılabilir.';

  @override
  String get dialogCopyLabel => 'BUGÜNE KOPYALA';

  @override
  String get dialogDeleteLabel => 'SİL';

  @override
  String get suppliedLabel => 'alınan';

  @override
  String get burnedLabel => 'yakılan';

  @override
  String get kcalLeftLabel => 'kalan kalori';

  @override
  String get nutritionInfoLabel => 'Besin Bilgisi';

  @override
  String get kcalLabel => 'kalori';

  @override
  String get carbsLabel => 'karbonhidrat';

  @override
  String get fatLabel => 'yağ';

  @override
  String get proteinLabel => 'protein';

  @override
  String get energyLabel => 'enerji';

  @override
  String get saturatedFatLabel => 'doymuş yağ';

  @override
  String get carbohydrateLabel => 'karbonhidrat';

  @override
  String get sugarLabel => 'şeker';

  @override
  String get fiberLabel => 'lif';

  @override
  String get per100gmlLabel => '100g/ml başına';

  @override
  String get additionalInfoLabelOFF => 'OpenFoodFacts\'te\nDaha Fazla Bilgi';

  @override
  String get offDisclaimer => 'Bu uygulama tarafından size sağlanan veriler Open Food Facts veritabanından alınmıştır. Sağlanan bilgilerin doğruluğu, eksiksizliği veya güvenilirliği konusunda hiçbir garanti verilemez. Veriler \"olduğu gibi\" sağlanır ve verilerin kaynağı (Open Food Facts), verilerin kullanımından kaynaklanan herhangi bir zarardan sorumlu değildir.';

  @override
  String get additionalInfoLabelFDC => 'FoodData Central\'da\nDaha Fazla Bilgi';

  @override
  String get additionalInfoLabelUnknown => 'Bilinmeyen Yemek Öğesi';

  @override
  String get additionalInfoLabelCustom => 'Özel Yemek Öğesi';

  @override
  String get additionalInfoLabelCompendium2011 => '\'2011 Fiziksel Aktiviteler Özeti\'\ntarafından sağlanan bilgiler';

  @override
  String get quantityLabel => 'Miktar';

  @override
  String get baseQuantityLabel => 'Base quantity (g/ml)';

  @override
  String get unitLabel => 'Birim';

  @override
  String get scanProductLabel => 'Ürün Tara';

  @override
  String get gramUnit => 'g';

  @override
  String get milliliterUnit => 'ml';

  @override
  String get gramMilliliterUnit => 'g/ml';

  @override
  String get ozUnit => 'oz';

  @override
  String get flOzUnit => 'fl.oz';

  @override
  String get notAvailableLabel => 'N/A';

  @override
  String get missingProductInfo => 'Üründe gerekli kalori veya makrobesin bilgisi eksik';

  @override
  String get infoAddedIntakeLabel => 'Yeni alım eklendi';

  @override
  String get infoAddedActivityLabel => 'Yeni aktivite eklendi';

  @override
  String get editMealLabel => 'Yemeği düzenle';

  @override
  String get mealNameLabel => 'Yemek adı';

  @override
  String get mealBrandsLabel => 'Markalar';

  @override
  String get mealSizeLabel => 'Yemek boyutu (g/ml)';

  @override
  String get mealSizeLabelImperial => 'Yemek boyutu (oz/fl oz)';

  @override
  String get servingLabel => 'Serving';

  @override
  String get perServingLabel => 'Per Serving';

  @override
  String get servingSizeLabelMetric => 'Porsiyon boyutu (g/ml)';

  @override
  String get servingSizeLabelImperial => 'Porsiyon boyutu (oz/fl oz)';

  @override
  String get mealUnitLabel => 'Yemek birimi';

  @override
  String get mealKcalLabel => '100 g/ml başına kalori';

  @override
  String get mealCarbsLabel => '100 g/ml başına karbonhidrat';

  @override
  String get mealFatLabel => '100 g/ml başına yağ';

  @override
  String get mealProteinLabel => '100 g/ml başına protein';

  @override
  String get errorMealSave => 'Yemek kaydedilirken hata oluştu. Doğru yemek bilgilerini girdiniz mi?';

  @override
  String get bmiLabel => 'VKİ';

  @override
  String get bmiInfo => 'Vücut Kitle İndeksi (VKİ), yetişkinlerde aşırı kilolu ve obeziteyi sınıflandırmak için kullanılan bir indekstir. Kilogram cinsinden ağırlığın, metre cinsinden boyun karesine bölünmesiyle hesaplanır (kg/m²).\n\nVKİ, yağ ve kas kütlesi arasında ayrım yapmaz ve bazı bireyler için yanıltıcı olabilir.';

  @override
  String get readLabel => 'Gizlilik politikasını okudum ve kabul ediyorum.';

  @override
  String get privacyPolicyLabel => 'Gizlilik politikası';

  @override
  String get dataCollectionLabel => 'Anonim kullanım verileri sağlayarak geliştirmeyi destekleyin';

  @override
  String get palSedentaryLabel => 'Hareketsiz';

  @override
  String get palSedentaryDescriptionLabel => 'örn. ofis işi ve çoğunlukla oturarak geçirilen boş zaman aktiviteleri';

  @override
  String get palLowLActiveLabel => 'Az Aktif';

  @override
  String get palLowActiveDescriptionLabel => 'örn. işte oturmak veya ayakta durmak ve hafif boş zaman aktiviteleri';

  @override
  String get palActiveLabel => 'Aktif';

  @override
  String get palActiveDescriptionLabel => 'Çoğunlukla işte ayakta durmak veya yürümek ve aktif boş zaman aktiviteleri';

  @override
  String get palVeryActiveLabel => 'Çok Aktif';

  @override
  String get palVeryActiveDescriptionLabel => 'Çoğunlukla işte yürümek, koşmak veya ağırlık taşımak ve aktif boş zaman aktiviteleri';

  @override
  String get selectPalCategoryLabel => 'Aktivite Seviyesi Seçin';

  @override
  String get chooseWeightGoalLabel => 'Kilo Hedefi Seçin';

  @override
  String get goalLoseWeight => 'Kilo Ver';

  @override
  String get goalMaintainWeight => 'Kiloyu Koru';

  @override
  String get goalGainWeight => 'Kilo Al';

  @override
  String get goalLabel => 'Hedef';

  @override
  String get selectHeightDialogLabel => 'Boy Seçin';

  @override
  String get heightLabel => 'Boy';

  @override
  String get cmLabel => 'cm';

  @override
  String get ftLabel => 'ft';

  @override
  String get selectWeightDialogLabel => 'Kilo Seçin';

  @override
  String get weightLabel => 'Kilo';

  @override
  String get kgLabel => 'kg';

  @override
  String get lbsLabel => 'lbs';

  @override
  String get ageLabel => 'Yaş';

  @override
  String yearsLabel(Object age) {
    return '$age yaş';
  }

  @override
  String get selectGenderDialogLabel => 'Cinsiyet Seçin';

  @override
  String get genderLabel => 'Cinsiyet';

  @override
  String get genderMaleLabel => '♂ erkek';

  @override
  String get genderFemaleLabel => '♀ kadın';

  @override
  String get nothingAddedLabel => 'Hiçbir şey eklenmedi';

  @override
  String get nutritionalStatusUnderweight => 'Düşük Kilolu';

  @override
  String get nutritionalStatusNormalWeight => 'Normal Kilolu';

  @override
  String get nutritionalStatusPreObesity => 'Obezite Öncesi';

  @override
  String get nutritionalStatusObeseClassI => 'Obezite Sınıf I';

  @override
  String get nutritionalStatusObeseClassII => 'Obezite Sınıf II';

  @override
  String get nutritionalStatusObeseClassIII => 'Obezite Sınıf III';

  @override
  String nutritionalStatusRiskLabel(Object riskValue) {
    return 'Eşlik eden hastalık riski: $riskValue';
  }

  @override
  String get nutritionalStatusRiskLow => 'Düşük \n(ancak diğer klinik \nsorunların riski artmış)';

  @override
  String get nutritionalStatusRiskAverage => 'Ortalama';

  @override
  String get nutritionalStatusRiskIncreased => 'Artmış';

  @override
  String get nutritionalStatusRiskModerate => 'Orta';

  @override
  String get nutritionalStatusRiskSevere => 'Ciddi';

  @override
  String get nutritionalStatusRiskVerySevere => 'Çok Ciddi';

  @override
  String get errorOpeningEmail => 'E-posta uygulaması açılırken hata oluştu';

  @override
  String get errorOpeningBrowser => 'Tarayıcı uygulaması açılırken hata oluştu';

  @override
  String get errorFetchingProductData => 'Ürün verileri alınırken hata oluştu';

  @override
  String get errorProductNotFound => 'Ürün bulunamadı';

  @override
  String get errorLoadingActivities => 'Aktiviteler yüklenirken hata oluştu';

  @override
  String get noResultsFound => 'Sonuç bulunamadı';

  @override
  String get retryLabel => 'Tekrar dene';

  @override
  String get paHeadingBicycling => 'bisiklet sürme';

  @override
  String get paHeadingConditionalExercise => 'kondisyon egzersizi';

  @override
  String get paHeadingDancing => 'dans';

  @override
  String get paHeadingRunning => 'koşu';

  @override
  String get paHeadingSports => 'sporlar';

  @override
  String get paHeadingWalking => 'yürüyüş';

  @override
  String get paHeadingWaterActivities => 'su aktiviteleri';

  @override
  String get paHeadingWinterActivities => 'kış aktiviteleri';

  @override
  String get paGeneralDesc => 'genel';

  @override
  String get paBicyclingGeneral => 'bisiklet sürme';

  @override
  String get paBicyclingGeneralDesc => 'genel';

  @override
  String get paBicyclingMountainGeneral => 'dağ bisikleti';

  @override
  String get paBicyclingMountainGeneralDesc => 'genel';

  @override
  String get paUnicyclingGeneral => 'tek tekerlekli bisiklet';

  @override
  String get paUnicyclingGeneralDesc => 'genel';

  @override
  String get paBicyclingStationaryGeneral => 'sabit bisiklet';

  @override
  String get paBicyclingStationaryGeneralDesc => 'genel';

  @override
  String get paCalisthenicsGeneral => 'jimnastik';

  @override
  String get paCalisthenicsGeneralDesc => 'hafif veya orta efor, genel (örn. sırt egzersizleri)';

  @override
  String get paResistanceTraining => 'direnç antrenmanı';

  @override
  String get paResistanceTrainingDesc => 'ağırlık kaldırma, serbest ağırlık, nautilus veya universal';

  @override
  String get paRopeSkippingGeneral => 'ip atlama';

  @override
  String get paRopeSkippingGeneralDesc => 'genel';

  @override
  String get paWaterAerobics => 'su egzersizi';

  @override
  String get paWaterAerobicsDesc => 'su aerobiği, su jimnastiği';

  @override
  String get paDancingAerobicGeneral => 'aerobik';

  @override
  String get paDancingAerobicGeneralDesc => 'genel';

  @override
  String get paDancingGeneral => 'genel dans';

  @override
  String get paDancingGeneralDesc => 'örn. disko, halk dansı, İrlanda step dansı, sıra dansı, polka, contra, ülke dansları';

  @override
  String get paJoggingGeneral => 'hafif koşu';

  @override
  String get paJoggingGeneralDesc => 'genel';

  @override
  String get paRunningGeneral => 'koşu';

  @override
  String get paRunningGeneralDesc => 'genel';

  @override
  String get paArcheryGeneral => 'okçuluk';

  @override
  String get paArcheryGeneralDesc => 'av amaçlı olmayan';

  @override
  String get paBadmintonGeneral => 'badminton';

  @override
  String get paBadmintonGeneralDesc => 'sosyal tekler ve çiftler, genel';

  @override
  String get paBasketballGeneral => 'basketbol';

  @override
  String get paBasketballGeneralDesc => 'genel';

  @override
  String get paBilliardsGeneral => 'bilardo';

  @override
  String get paBilliardsGeneralDesc => 'genel';

  @override
  String get paBowlingGeneral => 'bowling';

  @override
  String get paBowlingGeneralDesc => 'genel';

  @override
  String get paBoxingBag => 'boks';

  @override
  String get paBoxingBagDesc => 'kum torbası';

  @override
  String get paBoxingGeneral => 'boks';

  @override
  String get paBoxingGeneralDesc => 'ringde, genel';

  @override
  String get paBroomball => 'broomball';

  @override
  String get paBroomballDesc => 'genel';

  @override
  String get paChildrenGame => 'çocuk oyunları';

  @override
  String get paChildrenGameDesc => '(örn. seksek, 4-kare, yakantop, oyun parkı aletleri, t-topu, direk topu, misket, arcade oyunları), orta efor';

  @override
  String get paCheerleading => 'amigo';

  @override
  String get paCheerleadingDesc => 'jimnastik hareketleri, yarışma';

  @override
  String get paCricket => 'kriket';

  @override
  String get paCricketDesc => 'vuruş, top atma, saha savunması';

  @override
  String get paCroquet => 'kroket';

  @override
  String get paCroquetDesc => 'genel';

  @override
  String get paCurling => 'curling';

  @override
  String get paCurlingDesc => 'genel';

  @override
  String get paDartsWall => 'dart';

  @override
  String get paDartsWallDesc => 'duvar veya çim';

  @override
  String get paAutoRacing => 'araba yarışı';

  @override
  String get paAutoRacingDesc => 'açık tekerlek';

  @override
  String get paFencing => 'eskrim';

  @override
  String get paFencingDesc => 'genel';

  @override
  String get paAmericanFootballGeneral => 'Amerikan futbolu';

  @override
  String get paAmericanFootballGeneralDesc => 'dokunmalı, bayrak, genel';

  @override
  String get paCatch => 'futbol veya beyzbol';

  @override
  String get paCatchDesc => 'top yakalama';

  @override
  String get paFrisbee => 'frizbi oynama';

  @override
  String get paFrisbeeDesc => 'genel';

  @override
  String get paGolfGeneral => 'golf';

  @override
  String get paGolfGeneralDesc => 'genel';

  @override
  String get paGymnasticsGeneral => 'jimnastik';

  @override
  String get paGymnasticsGeneralDesc => 'genel';

  @override
  String get paHackySack => 'hacky sack';

  @override
  String get paHackySackDesc => 'genel';

  @override
  String get paHandballGeneral => 'hentbol';

  @override
  String get paHandballGeneralDesc => 'genel';

  @override
  String get paHangGliding => 'yamaç paraşütü';

  @override
  String get paHangGlidingDesc => 'genel';

  @override
  String get paHockeyField => 'çim hokeyi';

  @override
  String get paHockeyFieldDesc => 'genel';

  @override
  String get paIceHockeyGeneral => 'buz hokeyi';

  @override
  String get paIceHockeyGeneralDesc => 'genel';

  @override
  String get paHorseRidingGeneral => 'at binme';

  @override
  String get paHorseRidingGeneralDesc => 'genel';

  @override
  String get paJaiAlai => 'jai alai';

  @override
  String get paJaiAlaiDesc => 'genel';

  @override
  String get paMartialArtsSlower => 'dövüş sanatları';

  @override
  String get paMartialArtsSlowerDesc => 'farklı türler, yavaş tempo, acemi performansçılar, pratik';

  @override
  String get paMartialArtsModerate => 'dövüş sanatları';

  @override
  String get paMartialArtsModerateDesc => 'farklı türler, orta tempo (örn. judo, jujitsu, karate, kick boks, tekvando, tai-bo, Muay Thai boksu)';

  @override
  String get paJuggling => 'jonglörlük';

  @override
  String get paJugglingDesc => 'genel';

  @override
  String get paKickball => 'kickball';

  @override
  String get paKickballDesc => 'genel';

  @override
  String get paLacrosse => 'lakros';

  @override
  String get paLacrosseDesc => 'genel';

  @override
  String get paLawnBowling => 'çim bowling';

  @override
  String get paLawnBowlingDesc => 'bocce topu, açık hava';

  @override
  String get paMotoCross => 'motokros';

  @override
  String get paMotoCrossDesc => 'off-road motor sporları, arazi aracı, genel';

  @override
  String get paOrienteering => 'oryantiring';

  @override
  String get paOrienteeringDesc => 'genel';

  @override
  String get paPaddleball => 'paddle topu';

  @override
  String get paPaddleballDesc => 'rahat, genel';

  @override
  String get paPoloHorse => 'polo';

  @override
  String get paPoloHorseDesc => 'at üstünde';

  @override
  String get paRacquetball => 'raketbol';

  @override
  String get paRacquetballDesc => 'genel';

  @override
  String get paMountainClimbing => 'tırmanış';

  @override
  String get paMountainClimbingDesc => 'kaya veya dağ tırmanışı';

  @override
  String get paRodeoSportGeneralModerate => 'rodeo sporları';

  @override
  String get paRodeoSportGeneralModerateDesc => 'genel, orta efor';

  @override
  String get paRopeJumpingGeneral => 'ip atlama';

  @override
  String get paRopeJumpingGeneralDesc => 'orta tempo, dakikada 100-120 atlama, genel, iki ayak atlama, düz zıplama';

  @override
  String get paRugbyCompetitive => 'ragbi';

  @override
  String get paRugbyCompetitiveDesc => 'birlik, takım, yarışma';

  @override
  String get paRugbyNonCompetitive => 'ragbi';

  @override
  String get paRugbyNonCompetitiveDesc => 'dokunmalı, yarışma dışı';

  @override
  String get paShuffleboard => 'shuffleboard';

  @override
  String get paShuffleboardDesc => 'genel';

  @override
  String get paSkateboardingGeneral => 'kaykay';

  @override
  String get paSkateboardingGeneralDesc => 'genel, orta efor';

  @override
  String get paSkatingRoller => 'paten';

  @override
  String get paSkatingRollerDesc => 'genel';

  @override
  String get paRollerbladingLight => 'paten';

  @override
  String get paRollerbladingLightDesc => 'inline paten';

  @override
  String get paSkydiving => 'serbest paraşüt';

  @override
  String get paSkydivingDesc => 'serbest paraşüt, base jumping, bungee jumping';

  @override
  String get paSoccerGeneral => 'futbol';

  @override
  String get paSoccerGeneralDesc => 'rahat, genel';

  @override
  String get paSoftballBaseballGeneral => 'softball / beyzbol';

  @override
  String get paSoftballBaseballGeneralDesc => 'hızlı veya yavaş atış, genel';

  @override
  String get paSquashGeneral => 'squash';

  @override
  String get paSquashGeneralDesc => 'genel';

  @override
  String get paTableTennisGeneral => 'masa tenisi';

  @override
  String get paTableTennisGeneralDesc => 'masa tenisi, ping pong';

  @override
  String get paTaiChiQiGongGeneral => 'tai chi, qi gong';

  @override
  String get paTaiChiQiGongGeneralDesc => 'genel';

  @override
  String get paTennisGeneral => 'tenis';

  @override
  String get paTennisGeneralDesc => 'genel';

  @override
  String get paTrampolineLight => 'trampolin';

  @override
  String get paTrampolineLightDesc => 'eğlence amaçlı';

  @override
  String get paVolleyballGeneral => 'voleybol';

  @override
  String get paVolleyballGeneralDesc => 'yarışma dışı, 6 - 9 kişilik takım, genel';

  @override
  String get paWrestling => 'güreş';

  @override
  String get paWrestlingDesc => 'genel';

  @override
  String get paWallyball => 'wallyball';

  @override
  String get paWallyballDesc => 'genel';

  @override
  String get paTrackField => 'atletizm';

  @override
  String get paTrackField1Desc => '(örn. gülle atma, disk atma, çekiç atma)';

  @override
  String get paTrackField2Desc => '(örn. yüksek atlama, uzun atlama, üç adım atlama, cirit atma, sırıkla atlama)';

  @override
  String get paTrackField3Desc => '(örn. su engelli koşu, engelli koşu)';

  @override
  String get paBackpackingGeneral => 'sırt çantalı gezme';

  @override
  String get paBackpackingGeneralDesc => 'genel';

  @override
  String get paClimbingHillsNoLoadGeneral => 'yüksüz tepe tırmanışı';

  @override
  String get paClimbingHillsNoLoadGeneralDesc => 'yüksüz';

  @override
  String get paHikingCrossCountry => 'doğa yürüyüşü';

  @override
  String get paHikingCrossCountryDesc => 'kırsal alanda';

  @override
  String get paWalkingForPleasure => 'yürüyüş';

  @override
  String get paWalkingForPleasureDesc => 'keyif için';

  @override
  String get paWalkingTheDog => 'köpek gezdirme';

  @override
  String get paWalkingTheDogDesc => 'genel';

  @override
  String get paCanoeingGeneral => 'kano';

  @override
  String get paCanoeingGeneralDesc => 'kürek çekme, keyif için, genel';

  @override
  String get paDivingSpringboardPlatform => 'dalış';

  @override
  String get paDivingSpringboardPlatformDesc => 'tramplen veya platform';

  @override
  String get paKayakingModerate => 'kano';

  @override
  String get paKayakingModerateDesc => 'orta efor';

  @override
  String get paPaddleBoat => 'pedallı tekne';

  @override
  String get paPaddleBoatDesc => 'genel';

  @override
  String get paSailingGeneral => 'yelken';

  @override
  String get paSailingGeneralDesc => 'tekne ve tahta yelken, rüzgar sörfü, buz yelkeni, genel';

  @override
  String get paSkiingWaterWakeboarding => 'su kayağı';

  @override
  String get paSkiingWaterWakeboardingDesc => 'su kayağı veya wakeboard';

  @override
  String get paDivingGeneral => 'dalış';

  @override
  String get paDivingGeneralDesc => 'cilt dalışı, scuba dalışı, genel';

  @override
  String get paSnorkeling => 'şnorkel';

  @override
  String get paSnorkelingDesc => 'genel';

  @override
  String get paSurfing => 'sörf';

  @override
  String get paSurfingDesc => 'vücut veya tahta, genel';

  @override
  String get paPaddleBoarding => 'paddle board';

  @override
  String get paPaddleBoardingDesc => 'ayakta';

  @override
  String get paSwimmingGeneral => 'yüzme';

  @override
  String get paSwimmingGeneralDesc => 'su üzerinde durma, orta efor, genel';

  @override
  String get paWateraerobicsCalisthenics => 'su aerobiği';

  @override
  String get paWateraerobicsCalisthenicsDesc => 'su aerobiği, su jimnastiği';

  @override
  String get paWaterPolo => 'su topu';

  @override
  String get paWaterPoloDesc => 'genel';

  @override
  String get paWaterVolleyball => 'su voleybolu';

  @override
  String get paWaterVolleyballDesc => 'genel';

  @override
  String get paIceSkatingGeneral => 'buz pateni';

  @override
  String get paIceSkatingGeneralDesc => 'genel';

  @override
  String get paSkiingGeneral => 'kayak';

  @override
  String get paSkiingGeneralDesc => 'genel';

  @override
  String get paSnowShovingModerate => 'kar küreme';

  @override
  String get paSnowShovingModerateDesc => 'elle, ılımlı çaba';

  @override
  String get dailyLimitReachedTitle => 'Daily Limit Reached';

  @override
  String get upgradeForUnlimitedAccess => 'Upgrade for unlimited access to all features.';

  @override
  String get maybeLater => 'Maybe Later';

  @override
  String dailyLimitMessage(int remaining) {
    return 'You have $remaining free analyses left today. Upgrade to premium for unlimited access.';
  }

  @override
  String get upgradeToPremium => 'Upgrade to Premium';

  @override
  String get purchaseError => 'Error processing purchase. Please try again.';

  @override
  String get restorePurchases => 'Restore Purchases';

  @override
  String get purchaseSuccessful => 'Thank you for upgrading to Premium!';

  @override
  String get unlockPremiumFeatures => 'Unlock Premium Features';

  @override
  String get getUnlimitedAccessToAllFeatures => 'Get unlimited access to all features and remove daily limits.';

  @override
  String get premiumFeatures => 'Premium Features';

  @override
  String get unlimitedFoodAnalysis => 'Unlimited food analysis';

  @override
  String get accessToRecipeFinder => 'Access to recipe finder';

  @override
  String get noAds => 'No ads';

  @override
  String get prioritySupport => 'Priority support';

  @override
  String get premium => 'Premium';

  @override
  String get cancelAnytime => 'Cancel anytime';

  @override
  String get subscribeFor => 'Subscribe for';

  @override
  String get premiumActive => 'Premium Active';

  @override
  String get subscriptionTerms => 'Subscription will be charged to your payment method. Auto-renews unless canceled 24 hours before the end of the current period. Manage in your account settings.';

  @override
  String get remainingAnalyses => 'Remaining Analyses';

  @override
  String get addPromptForGemini => 'Add prompt for Gemini (recommended)';

  @override
  String get addPromptForGeminiHint => 'e.g., \"This is a close-up of a salad with tomatoes and cucumbers\"';

  @override
  String get analyzeWithGemini => 'Analyze with Gemini';

  @override
  String get adjustQuantitiesAsNeeded => 'Adjust quantities as needed';

  @override
  String get analysisFailed => 'Analysis failed';

  @override
  String get camera => 'Camera';

  @override
  String get gallery => 'Gallery';

  @override
  String get hideDescription => 'Hide Description';

  @override
  String get addDescription => 'Add Description';

  @override
  String get addPromptForGeminiDescription => 'Describe your dish here';

  @override
  String get addPromptForGeminiHintDescription => 'e.g., \"I ate rice with...\"';
}
