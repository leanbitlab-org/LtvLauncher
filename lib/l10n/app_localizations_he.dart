import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hebrew (`he`).
class AppLocalizationsHe extends AppLocalizations {
  AppLocalizationsHe([String locale = 'he']) : super(locale);

  @override
  String get aboutFlauncher => 'אודות LTvLauncher';

  @override
  String get addCategory => 'הוספת קטגוריה';

  @override
  String get addSection => 'הוספת מקטע';

  @override
  String get alphabetical => 'לפי סדר אלפביתי';

  @override
  String get appCardHighlightAnimation => 'אנימציית הדגשת כרטיס אפליקציה';

  @override
  String get appInfo => 'פרטי אפליקציה';

  @override
  String get appKeyClick => 'צליל לחיצה בהקשת מקש';

  @override
  String get applications => 'אפליקציות';

  @override
  String get autoHideAppBar => 'הסתרה אוטומטית של שורת המצב';

  @override
  String get backButtonAction => 'פעולת כפתור חזרה';

  @override
  String get category => 'קטגוריה';

  @override
  String get categories => 'קטגוריות';

  @override
  String get columnCount => 'מספר עמודות';

  @override
  String get date => 'תאריך';

  @override
  String get dateAndTimeFormat => 'תבנית תאריך ושעה';

  @override
  String get delete => 'מחיקה';

  @override
  String get dialogOptionBackButtonActionDoNothing => 'אל תעשה דבר';

  @override
  String get dialogOptionBackButtonActionShowScreensaver => 'הצגת שומר מסך';

  @override
  String get dialogOptionBackButtonActionShowClock => 'הצגת שעון';

  @override
  String get dialogTextNoFileExplorer => 'נא להתקין סייר קבצים כדי לבחור תמונה.';

  @override
  String get dialogTitleBackButtonAction => 'בחירת פעולת כפתור חזרה';

  @override
  String disambiguateCategoryTitle(String title) {
    return '$title (קטגוריה)';
  }

  @override
  String formattedDate(String dateString) {
    return 'תאריך מפורמט: $dateString';
  }

  @override
  String formattedTime(String timeString) {
    return 'שעה מפורמטת: $timeString';
  }

  @override
  String get gradient => 'גרדיאנט';

  @override
  String get favoriteApps => 'אפליקציות מועדפות';

  @override
  String get grid => 'רשת';

  @override
  String get height => 'גובה';

  @override
  String get hide => 'הסתרה';

  @override
  String get hiddenApplications => 'אפליקציות מוסתרות';

  @override
  String get launcherSections => 'מקטעים';

  @override
  String get layout => 'פריסה';

  @override
  String get loading => 'טוען...';

  @override
  String get manual => 'ידני';

  @override
  String get modifySection => 'עריכת מקטע';

  @override
  String get mustNotBeEmpty => 'אינו יכול להיות ריק';

  @override
  String get name => 'שם';

  @override
  String get newSection => 'מקטע חדש';

  @override
  String get noDateFormatSpecified => 'לא צוינה תבנית תאריך';

  @override
  String get noTimeFormatSpecified => 'לא צוינה תבנית שעה';

  @override
  String get nonTvApplications => 'אפליקציות שאינן לטלוויזיה';

  @override
  String get open => 'פתיחה';

  @override
  String get orSelectFormatSpecifiers => 'או בחר מזהי תבנית';

  @override
  String get picture => 'תמונה';

  @override
  String removeFrom(String name) {
    return 'הסרה מ-$name';
  }

  @override
  String get renameCategory => 'שינוי שם קטגוריה';

  @override
  String get reorder => 'שינוי סדר';

  @override
  String get row => 'שורה';

  @override
  String get rowHeight => 'גובה שורה';

  @override
  String get save => 'שמירה';

  @override
  String get spacer => 'מרווח';

  @override
  String get spacerMaxHeightRequirement => 'חייב להיות גדול מ-0 וקטן או שווה ל-500';

  @override
  String get statusBar => 'שורת מצב';

  @override
  String get settings => 'הגדרות';

  @override
  String get show => 'הצגה';

  @override
  String get showCategoryTitles => 'הצגת שמות קטגוריות';

  @override
  String get showCategoryAppCount => 'הצגת מספר אפליקציות בקטגוריות';

  @override
  String get themes => 'ערכות נושא';

  @override
  String get hideHighlightOutlineOnHomescreen => 'הסתרת מסגרת הדגשה במסך הבית';

  @override
  String get appSelectorTransitionAnimation => 'אנימציית מעבר בבחירת אפליקציות';

  @override
  String get sort => 'מיון';

  @override
  String get systemSettings => 'הגדרות מערכת';

  @override
  String textAboutDialog(String repoUrl) {
    return 'LTvLauncher הוא מסך בית מותאם אישית בקוד פתוח עבור Android TV, המבוסס על FLauncher.\n\nפותח על ידי LeanBitLab.\nקוד המקור זמין ב-$repoUrl.';
  }

  @override
  String get textEmptyCategory => 'קטגוריה זו ריקה.';

  @override
  String get time => 'שעה';

  @override
  String get titleStatusBarSettingsPage => 'בחירת הפריטים להצגה בשורת המצב';

  @override
  String get tvApplications => 'אפליקציות טלוויזיה';

  @override
  String get type => 'סוג';

  @override
  String get typeInTheDateFormat => 'הקלד את תבנית התאריך';

  @override
  String get typeInTheHourFormat => 'הקלד את תבנית השעה';

  @override
  String get uninstall => 'הסרת התקנה';

  @override
  String get wallpaper => 'טפט';

  @override
  String get withEllipsisAddTo => 'הוספה אל...';

  @override
  String get timeBasedWallpaper => 'טפט מבוסס זמן';

  @override
  String get pickDayWallpaper => 'בחירת טפט ליום';

  @override
  String get pickNightWallpaper => 'בחירת טפט ללילה';

  @override
  String get accessibility => 'נגישות';

  @override
  String get defaultLauncherIsDefault => 'LTvLauncher הוא מסך הבית המוגדר כברירת מחדל';

  @override
  String get defaultLauncherNotDefault => 'LTvLauncher אינו מוגדר כמסך הבית כברירת מחדל';

  @override
  String get setAsDefaultLauncher => 'הגדרה כמסך הבית כברירת מחדל';

  @override
  String get defaultLauncherDescription => 'כאשר מוגדר כמסך הבית כברירת מחדל, כפתור הבית תמיד יחזיר אל LTvLauncher. הטלוויזיה גם תופעל ישירות לתוך LTvLauncher.';

  @override
  String get inputs => 'כניסות';

  @override
  String get inputSources => 'מקורות קלט';

  @override
  String get backupAndRestore => 'גיבוי ושחזור';

  @override
  String get exportBackup => 'ייצוא גיבוי';

  @override
  String get importBackup => 'ייבוא גיבוי';

  @override
  String exportSuccess(String path) {
    return 'הגיבוי יוצא בהצלחה אל $path';
  }

  @override
  String get importSuccess => 'הגיבוי יובא בהצלחה';

  @override
  String get importConfirm => 'האם אתה בטוח שברצונך לייבא את הגיבוי? פעולה זו תחליף את ההגדרות והפריסה הנוכחיות שלך.';

  @override
  String importError(String error) {
    return 'ייבוא הגיבוי נכשל: $error';
  }

  @override
  String exportError(String error) {
    return 'ייצוא הגיבוי נכשל: $error';
  }

  @override
  String get shareBackup => 'שיתוף גיבוי';

  @override
  String get shareBackupDescription => 'שיתוף הגיבוי עם מכשירים אחרים ברשת המקומית';

  @override
  String get stopSharing => 'הפסקת שיתוף';

  @override
  String get localNetworkSharingActive => 'שיתוף ברשת המקומית פעיל!';

  @override
  String get localNetworkSharingInstructions => 'חבר מכשיר נוסף לאותה רשת Wi-Fi ופתח את הכתובת הבאה בדפדפן האינטרנט:';

  @override
  String get localNetworkSharingDetails => 'כאן תוכל להוריד את הגדרות ופריסת הטלוויזיה שלך או להעלות קובץ גיבוי בחזרה לטלוויזיה זו.';

  @override
  String failedToStartServer(String error) {
    return 'הפעלת שרת השיתוף נכשלה: $error';
  }

  @override
  String get notificationBell => 'פעמון התראות';

  @override
  String get autoHideNotificationBell => 'הסתרה אוטומטית של פעמון ההתראות';

  @override
  String get continueWatching => 'המשך צפייה';

  @override
  String get showContinueWatchingOnHome => 'הצגת \'המשך צפייה\' במסך הבית';

  @override
  String get permissionDeniedContinueWatching => 'נדרשת הרשאה להצגת \'המשך צפייה\'';

  @override
  String get interface => 'ממשק';

  @override
  String get system => 'מערכת';

  @override
  String get accentColor => 'צבע הדגשה';

  @override
  String get miscellaneous => 'שונות';

  @override
  String get brightnessScheduler => 'מתזמן בהירות';

  @override
  String get screensaverSettings => 'הגדרות שומר מסך';

  @override
  String get screensaverClockStyle => 'סגנון שעון שומר מסך';

  @override
  String get screensaverAnimation => 'אנימציית שומר מסך';

  @override
  String get screensaverAnimationBounce => 'הקפצת DVD';

  @override
  String get screensaverAnimationBounceSubtitle => 'הקפצה קלאסית של לוגו DVD מרחף עם שינויי צבע בקירות';

  @override
  String get screensaverAnimationFade => 'עמעום מינימלי';

  @override
  String get screensaverAnimationFadeSubtitle => 'עמעום חלק פנימה והחוצה במיקומים חדשים';

  @override
  String get screensaverAnimationScatter => 'פיזור תווים';

  @override
  String get screensaverAnimationScatterSubtitle => 'תווים קופצים ומשעשעים';

  @override
  String get dataUsagePeriod => 'תקופת שימוש בנתונים';

  @override
  String get notificationAccess => 'גישה להתראות';

  @override
  String get granted => 'אושר';

  @override
  String get permissionRequired => 'נדרשת הרשאה';

  @override
  String get systemWidePopupAlert => 'התראת חלון קופץ בכלל המערכת';

  @override
  String get overlayPermissionRequired => 'נדרשת הרשאת תצוגה מעל יישומים אחרים (Overlay)';

  @override
  String get enabled => 'מופעל';

  @override
  String get disabled => 'מושבת';

  @override
  String get showAppNamesBelowIcons => 'הצגת שמות אפליקציות מתחת לסמלים';

  @override
  String get dataUsage => 'שימוש בנתונים';

  @override
  String get networkIndicator => 'מחוון רשת';

  @override
  String get homeButtonFix => 'תיקון כפתור הבית (Google TV)';

  @override
  String get startOnBoot => 'הפעלה בעת אתחול המכשיר (Google TV / Fire TV)';

  @override
  String get appLanguage => 'שפה';

  @override
  String get systemDefault => 'ברירת מחדל של המערכת';

  @override
  String get english => 'אנגלית';

  @override
  String get spanish => 'ספרדית';

  @override
  String get ukrainian => 'אוקראינית';

  @override
  String get chinese => 'סינית';

  @override
  String get french => 'צרפתית';

  @override
  String get german => 'גרמנית';

  @override
  String get japanese => 'יפנית';

  @override
  String get portuguese => 'פורטוגזית';

  @override
  String get russian => 'רוסית';

  @override
  String get italian => 'איטלקית';

  @override
  String get hindi => 'הינדי';

  @override
  String get korean => 'קוריאנית';

  @override
  String get arabic => 'ערבית';

  @override
  String get turkish => 'טורקית';

  @override
  String get slovenian => 'סלובנית';

  @override
  String get hebrew => 'עברית';

  @override
  String get hidePersistentNotifications => 'הסתרת התראות קבועות';

  @override
  String get hidePersistentNotificationsDesc => 'הסתרת התראות מערכת והתראות מתמשכות של שירותי רקע';

  @override
  String get blockedNotificationApps => 'אפליקציות חסומות';

  @override
  String get blockAppNotifications => 'חסימת התראות';

  @override
  String get unblockAppNotifications => 'ביטול חסימת התראות';

  @override
  String get noBlockedApps => 'אין אפליקציות חסומות';

  @override
  String get persistentNotification => 'קבוע';

  @override
  String get unblockAll => 'ביטול כל החסימות';

  @override
  String get weather => 'מזג אוויר';

  @override
  String get showWeatherWarnings => 'הצגת התראות מזג אוויר וגשם';

  @override
  String get temperatureUnit => 'יחידת טמפרטורה';

  @override
  String get celsius => 'צלזיוס (°C)';

  @override
  String get fahrenheit => 'פרנהייט (°F)';

  @override
  String get breezyWeatherSetupHint => 'יש להתקין את Breezy Weather ולהפעיל את \'Local data sharing\' / \'Gadgetbridge\' בהגדרות שלו כדי לראות התראות מזג אוויר וגשם.';

  @override
  String get displayAndScreensaver => 'תצוגה ושומר מסך';

  @override
  String get notifications => 'התראות';

  @override
  String get continueWatchingDescription => 'הצגת סרטים ותוכניות טלוויזיה שנצפו לאחרונה מאפליקציות נתמכות במסך הבית שלך';

  @override
  String get continueWatchingPermissionDesc => 'נדרשת הרשאה מיוחדת לקריאת היסטוריית צפייה מאפליקציות טלוויזיה. ניתן להעניק אותה באמצעות הכפתור למטה או דרך ADB:';

  @override
  String get requestPermission => 'בקשת הרשאה';

  @override
  String get dismiss => 'התעלמות';

  @override
  String get openApp => 'פתיחה';

  @override
  String get notificationOptions => 'אפשרויות התראה';

  @override
  String get noBlockedAppsDesc => 'כל האפליקציות מורשות כרגע להציג התראות';

  @override
  String get notificationsAllowed => 'התראות מורשות';

  @override
  String get notificationsBlocked => 'התראות חסומות';

  @override
  String get dpadDismissHint => 'שמאל: התעלמות • אישור: אפשרויות';

  @override
  String get autoAddNewApps => 'הוספת אפליקציות חדשות שהותקנו למסך הבית';
}
