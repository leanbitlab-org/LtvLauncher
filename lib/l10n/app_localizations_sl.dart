// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Slovenian (`sl`).
class AppLocalizationsSl extends AppLocalizations {
  AppLocalizationsSl([String locale = 'sl']) : super(locale);

  @override
  String get aboutFlauncher => 'O programu LTvLauncher';

  @override
  String get addCategory => 'Dodaj kategorijo';

  @override
  String get addSection => 'Dodaj razdelek';

  @override
  String get alphabetical => 'Po abecedi';

  @override
  String get appCardHighlightAnimation =>
      'Animacija označevanja kartice aplikacije';

  @override
  String get appInfo => 'Podatki o aplikaciji';

  @override
  String get appKeyClick => 'Zvok klika ob pritisku tipke';

  @override
  String get applications => 'Aplikacije';

  @override
  String get autoHideAppBar => 'Samodejno skrij vrstico stanja';

  @override
  String get backButtonAction => 'Dejanje gumba Nazaj';

  @override
  String get category => 'Kategorija';

  @override
  String get categories => 'Kategorije';

  @override
  String get columnCount => 'Število stolpcev';

  @override
  String get date => 'Datum';

  @override
  String get dateAndTimeFormat => 'Oblika datuma in časa';

  @override
  String get delete => 'Izbriši';

  @override
  String get dialogOptionBackButtonActionDoNothing => 'Ne naredi ničesar';

  @override
  String get dialogOptionBackButtonActionShowScreensaver =>
      'Prikaži ohranjevalnik zaslona';

  @override
  String get dialogOptionBackButtonActionShowClock => 'Prikaži uro';

  @override
  String get dialogTextNoFileExplorer =>
      'Za izbiro slike namestite raziskovalec datotek.';

  @override
  String get dialogTitleBackButtonAction => 'Izberite dejanje gumba Nazaj';

  @override
  String disambiguateCategoryTitle(String title) {
    return '$title (Kategorija)';
  }

  @override
  String formattedDate(String dateString) {
    return 'Formatiran datum: $dateString';
  }

  @override
  String formattedTime(String timeString) {
    return 'Formatiran čas: $timeString';
  }

  @override
  String get gradient => 'Prehod';

  @override
  String get favoriteApps => 'Priljubljene aplikacije';

  @override
  String get grid => 'Mreža';

  @override
  String get height => 'Višina';

  @override
  String get hide => 'Skrij';

  @override
  String get hiddenApplications => 'Skrite aplikacije';

  @override
  String get launcherSections => 'Razdelki';

  @override
  String get layout => 'Postavitev';

  @override
  String get loading => 'Nalaganje';

  @override
  String get manual => 'Ročno';

  @override
  String get modifySection => 'Spremeni razdelek';

  @override
  String get mustNotBeEmpty => 'Ne sme biti prazno';

  @override
  String get name => 'Ime';

  @override
  String get newSection => 'Nov razdelek';

  @override
  String get noDateFormatSpecified => 'Oblika datuma ni določena';

  @override
  String get noTimeFormatSpecified => 'Oblika časa ni določena';

  @override
  String get nonTvApplications => 'Ne-TV aplikacije';

  @override
  String get open => 'Odpri';

  @override
  String get orSelectFormatSpecifiers => 'Ali izberite določila oblike';

  @override
  String get picture => 'Slika';

  @override
  String removeFrom(String name) {
    return 'Odstrani iz $name';
  }

  @override
  String get renameCategory => 'Preimenuj kategorijo';

  @override
  String get reorder => 'Preuredi';

  @override
  String get row => 'Vrstica';

  @override
  String get rowHeight => 'Višina vrstice';

  @override
  String get save => 'Shrani';

  @override
  String get spacer => 'Presledek';

  @override
  String get spacerMaxHeightRequirement =>
      'Mora biti večje od 0 in manjše ali enako 500';

  @override
  String get statusBar => 'Vrstica stanja';

  @override
  String get settings => 'Nastavitve';

  @override
  String get show => 'Prikaži';

  @override
  String get showCategoryTitles => 'Prikaži naslove kategorij';

  @override
  String get showCategoryAppCount => 'Prikaži število aplikacij v kategorijah';

  @override
  String get themes => 'Teme';

  @override
  String get hideHighlightOutlineOnHomescreen =>
      'Skrij obrobo poudarka na domačem zaslonu';

  @override
  String get appSelectorTransitionAnimation =>
      'Prehodna animacija izbirnika aplikacij';

  @override
  String get sort => 'Razvrsti';

  @override
  String get systemSettings => 'Sistemske nastavitve';

  @override
  String textAboutDialog(String repoUrl) {
    return 'LTvLauncher je prilagojen odprtokodni zaganjalnik za Android TV, ki temelji na FLauncherju.\n\nRazvil LeanBitLab.\nIzvorna koda je na voljo na $repoUrl.';
  }

  @override
  String get textEmptyCategory => 'Ta kategorija je prazna.';

  @override
  String get time => 'Čas';

  @override
  String get titleStatusBarSettingsPage =>
      'Izberite, kaj naj bo prikazano v vrstici stanja';

  @override
  String get tvApplications => 'TV aplikacije';

  @override
  String get type => 'Vrsta';

  @override
  String get typeInTheDateFormat => 'Vnesite obliko datuma';

  @override
  String get typeInTheHourFormat => 'Vnesite obliko časa';

  @override
  String get uninstall => 'Odstrani';

  @override
  String get wallpaper => 'Ozadje';

  @override
  String get withEllipsisAddTo => 'Dodaj v...';

  @override
  String get timeBasedWallpaper => 'Časovno odvisno ozadje';

  @override
  String get pickDayWallpaper => 'Izberi dnevno ozadje';

  @override
  String get pickNightWallpaper => 'Izberi nočno ozadje';

  @override
  String get accessibility => 'Dostopnost';

  @override
  String get defaultLauncherIsDefault => 'LTvLauncher je privzeti zaganjalnik';

  @override
  String get defaultLauncherNotDefault => 'LTvLauncher ni privzeti zaganjalnik';

  @override
  String get setAsDefaultLauncher => 'Nastavi kot privzeti zaganjalnik';

  @override
  String get defaultLauncherDescription =>
      'Ko je nastavljen kot privzeti zaganjalnik, se s pritiskom na gumb Domov vedno vrnete v LTvLauncher. TV se bo zagnal neposredno v LTvLauncher.';

  @override
  String get inputs => 'Vhodi';

  @override
  String get inputSources => 'Vhodni viri';

  @override
  String get backupAndRestore => 'Varnostno kopiranje in obnovitev';

  @override
  String get exportBackup => 'Izvozi varnostno kopijo';

  @override
  String get importBackup => 'Uvozi varnostno kopijo';

  @override
  String exportSuccess(String path) {
    return 'Varnostna kopija uspešno izvožena v $path';
  }

  @override
  String get importSuccess => 'Varnostna kopija uspešno uvožena';

  @override
  String get importConfirm =>
      'Ali ste prepričani, da želite uvoziti varnostno kopijo? To bo prepisalo vaše trenutne nastavitve in postavitev.';

  @override
  String importError(String error) {
    return 'Uvoz varnostne kopije ni uspel: $error';
  }

  @override
  String exportError(String error) {
    return 'Izvoz varnostne kopije ni uspel: $error';
  }

  @override
  String get shareBackup => 'Deli varnostno kopijo';

  @override
  String get shareBackupDescription =>
      'Deli varnostno kopijo z drugimi napravami v lokalnem omrežju';

  @override
  String get stopSharing => 'Ustavi deljenje';

  @override
  String get localNetworkSharingActive =>
      'Deljenje v lokalnem omrežju je aktivno!';

  @override
  String get localNetworkSharingInstructions =>
      'Povežite drugo napravo v isto omrežje Wi-Fi in v spletnem brskalniku odprite naslednji naslov URL:';

  @override
  String get localNetworkSharingDetails =>
      'Tukaj lahko prenesete nastavitve/postavitev televizorja ali naložite datoteko varnostne kopije nazaj na ta televizor.';

  @override
  String failedToStartServer(String error) {
    return 'Zagon strežnika za skupno rabo ni uspel: $error';
  }

  @override
  String get notificationBell => 'Zvonček za obvestila';

  @override
  String get autoHideNotificationBell => 'Samodejno skrij zvonček za obvestila';

  @override
  String get continueWatching => 'Nadaljuj z ogledom';

  @override
  String get showContinueWatchingOnHome =>
      'Prikaži Nadaljuj z ogledom na domačem zaslonu';

  @override
  String get permissionDeniedContinueWatching =>
      'Za prikaz Nadaljuj z ogledom je potrebno dovoljenje';

  @override
  String get interface => 'Vmesnik';

  @override
  String get system => 'Sistem';

  @override
  String get accentColor => 'Poudarjena barva';

  @override
  String get miscellaneous => 'Razno';

  @override
  String get brightnessScheduler => 'Urnik svetlosti';

  @override
  String get screensaverSettings => 'Nastavitve ohranjevalnika zaslona';

  @override
  String get screensaverClockStyle => 'Slog ure ohranjevalnika zaslona';

  @override
  String get screensaverAnimation => 'Screensaver Animation';

  @override
  String get screensaverAnimationBounce => 'DVD Bounce';

  @override
  String get screensaverAnimationBounceSubtitle =>
      'Classic floating DVD logo bounce with wall color shifts';

  @override
  String get screensaverAnimationFade => 'Minimal Fade';

  @override
  String get screensaverAnimationFadeSubtitle =>
      'Smooth fade out and in at new positions';

  @override
  String get screensaverAnimationScatter => 'Character Scatter';

  @override
  String get screensaverAnimationScatterSubtitle =>
      'Playful bouncing characters';

  @override
  String get dataUsagePeriod => 'Obdobje porabe podatkov';

  @override
  String get notificationAccess => 'Dostop do obvestil';

  @override
  String get granted => 'Odobreno';

  @override
  String get permissionRequired => 'Potrebno dovoljenje';

  @override
  String get systemWidePopupAlert => 'Sistemsko pojavno opozorilo';

  @override
  String get overlayPermissionRequired => 'Potrebno dovoljenje za prekrivanje';

  @override
  String get enabled => 'Omogočeno';

  @override
  String get disabled => 'Onemogočeno';

  @override
  String get showAppNamesBelowIcons => 'Prikaži imena aplikacij pod ikonami';

  @override
  String get dataUsage => 'Poraba podatkov';

  @override
  String get networkIndicator => 'Indikator omrežja';

  @override
  String get homeButtonFix => 'Popravek gumba Domov (Google TV)';

  @override
  String get startOnBoot => 'Zaženi ob zagonu (Google TV / Fire TV)';

  @override
  String get appLanguage => 'Jezik';

  @override
  String get systemDefault => 'Sistemsko privzeto';

  @override
  String get english => 'Angleščina';

  @override
  String get spanish => 'Španščina';

  @override
  String get ukrainian => 'Ukrajinščina';

  @override
  String get chinese => 'Kitajščina';

  @override
  String get french => 'Francoščina';

  @override
  String get german => 'Nemščina';

  @override
  String get japanese => 'Japonščina';

  @override
  String get portuguese => 'Portugalščina';

  @override
  String get russian => 'Ruščina';

  @override
  String get italian => 'Italijanščina';

  @override
  String get hindi => 'Hindijščina';

  @override
  String get korean => 'Korejščina';

  @override
  String get arabic => 'Arabščina';

  @override
  String get turkish => 'Turščina';

  @override
  String get slovenian => 'Slovenščina';

  @override
  String get hidePersistentNotifications => 'Skrij trajna obvestila';

  @override
  String get hidePersistentNotificationsDesc =>
      'Skrij obvestila trajnih storitev v ozadju in sistemska obvestila';

  @override
  String get blockedNotificationApps => 'Blokirane aplikacije';

  @override
  String get blockAppNotifications => 'Blokiraj obvestila';

  @override
  String get unblockAppNotifications => 'Odblokiraj obvestila';

  @override
  String get noBlockedApps => 'Ni blokiranih aplikacij';

  @override
  String get persistentNotification => 'Trajno';

  @override
  String get unblockAll => 'Odblokiraj vse';

  @override
  String get weather => 'Vreme';

  @override
  String get showWeatherWarnings => 'Prikaži vremenska in dežna opozorila';

  @override
  String get temperatureUnit => 'Enota za temperaturo';

  @override
  String get celsius => 'Celzij (°C)';

  @override
  String get fahrenheit => 'Fahrenheit (°F)';

  @override
  String get breezyWeatherSetupHint =>
      'Namestite Breezy Weather in v njegovih nastavitvah omogočite »Lokalna skupna raba podatkov« / »Gadgetbridge«, da boste videli opozorila za vreme in dež.';

  @override
  String get displayAndScreensaver => 'Zaslon in ohranjevalnik';

  @override
  String get notifications => 'Obvestila';

  @override
  String get continueWatchingDescription =>
      'Prikaži nedavno gledane filme in TV-oddaje iz podprtih aplikacij na domačem zaslonu';

  @override
  String get continueWatchingPermissionDesc =>
      'Za branje zgodovine ogledov iz TV aplikacij je potrebno posebno dovoljenje. Odobrite ga lahko s spodnjim gumbom ali prek ADB:';

  @override
  String get requestPermission => 'Zahtevaj dovoljenje';

  @override
  String get dismiss => 'Opusti';

  @override
  String get openApp => 'Odpri';

  @override
  String get notificationOptions => 'Možnosti obvestil';

  @override
  String get noBlockedAppsDesc =>
      'Vsem aplikacijam je trenutno dovoljeno prikazovanje obvestil';

  @override
  String get notificationsAllowed => 'Obvestila dovoljena';

  @override
  String get notificationsBlocked => 'Obvestila blokirana';

  @override
  String get dpadDismissHint => 'Levo: Opusti • V redu: Možnosti';
}
