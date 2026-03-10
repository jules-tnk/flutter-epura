// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'epura';

  @override
  String get notificationTitle => 'C\'est l\'heure du tri !';

  @override
  String get notificationBody => 'Vous avez de nouveaux fichiers à examiner';

  @override
  String get storageAccessNeeded => 'Accès au stockage requis';

  @override
  String get storageAccessExplanation =>
      'Epura a besoin de l\'autorisation d\'accéder à vos fichiers pour les examiner.';

  @override
  String get grantAccess => 'Autoriser l\'accès';

  @override
  String get openSettings => 'Ouvrir les paramètres';

  @override
  String filesToReview(int count) {
    return '$count fichiers à examiner';
  }

  @override
  String get photos => 'Photos';

  @override
  String get videos => 'Vidéos';

  @override
  String get downloads => 'Téléchargements';

  @override
  String get startReview => 'Commencer l\'examen';

  @override
  String get stats => 'Statistiques';

  @override
  String get leaveReview => 'Quitter l\'examen ?';

  @override
  String get leaveReviewMessage =>
      'Votre progression dans cette session sera perdue.';

  @override
  String get cancel => 'Annuler';

  @override
  String get leave => 'Quitter';

  @override
  String get skipForLater => 'Passer pour plus tard';

  @override
  String get photo => 'Photo';

  @override
  String get video => 'Vidéo';

  @override
  String get download => 'Téléchargement';

  @override
  String get delete => 'Supprimer';

  @override
  String get keep => 'Garder';

  @override
  String get allDone => 'Terminé !';

  @override
  String get kept => 'Gardés';

  @override
  String get deleted => 'Supprimés';

  @override
  String get skipped => 'Passés';

  @override
  String get storageFreed => 'Espace libéré';

  @override
  String get motivationalMessage => 'Bravo, votre appareil est bien rangé !';

  @override
  String get viewStats => 'Voir les statistiques';

  @override
  String get goHome => 'Retour à l\'accueil';

  @override
  String get settings => 'Paramètres';

  @override
  String get notifications => 'Notifications';

  @override
  String get dailyCleanupReminder => 'Rappel quotidien de nettoyage';

  @override
  String get reminderTime => 'Heure du rappel';

  @override
  String get fileTypesToScan => 'Types de fichiers à analyser';

  @override
  String get about => 'À propos';

  @override
  String version(String version) {
    return 'Version $version';
  }

  @override
  String get totalStorageFreed => 'Espace total libéré';

  @override
  String get freedThisWeek => 'Libéré cette semaine';

  @override
  String get last7Days => '7 derniers jours';

  @override
  String get streak => 'Série';

  @override
  String streakDays(int count) {
    return '$count jours';
  }

  @override
  String get filesReviewed => 'Fichiers examinés';

  @override
  String get totalReviewed => 'Total examinés';

  @override
  String get sessionHistory => 'Historique des sessions';

  @override
  String filesReviewedCount(int count) {
    return '$count fichiers examinés';
  }

  @override
  String get allClean => 'Tout est propre !';

  @override
  String get noFilesToReview =>
      'Aucun fichier à examiner pour le moment. Revenez plus tard.';

  @override
  String get language => 'Langue';

  @override
  String get systemDefault => 'Système';

  @override
  String get english => 'English';

  @override
  String get french => 'Français';

  @override
  String get howFarBack => 'Sur quelle période ?';

  @override
  String get sinceLastReview => 'Depuis le dernier examen';

  @override
  String nDays(int count) {
    return '$count jours';
  }

  @override
  String get oneDay => '1 jour';
}
