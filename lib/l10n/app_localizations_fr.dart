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
      'Vous pouvez enregistrer votre progression ou abandonner toutes les modifications.';

  @override
  String get cancel => 'Annuler';

  @override
  String get saveAndExit => 'Enregistrer et quitter';

  @override
  String get discardAndExit => 'Abandonner et quitter';

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

  @override
  String get cleanupReminder => 'Rappel de nettoyage';

  @override
  String get daily => 'Quotidien';

  @override
  String get weekly => 'Hebdomadaire';

  @override
  String get monday => 'Lundi';

  @override
  String get tuesday => 'Mardi';

  @override
  String get wednesday => 'Mercredi';

  @override
  String get thursday => 'Jeudi';

  @override
  String get friday => 'Vendredi';

  @override
  String get saturday => 'Samedi';

  @override
  String get sunday => 'Dimanche';

  @override
  String get forever => 'Tout';

  @override
  String get help => 'Aide';

  @override
  String get helpWhatIsEpura => 'Qu\'est-ce qu\'Epura ?';

  @override
  String get helpWhatIsEpuraBody =>
      'Epura vous aide à examiner et nettoyer les photos, vidéos et téléchargements sur votre téléphone.';

  @override
  String get helpHowItWorks => 'Comment ça marche';

  @override
  String get helpHowItWorksBody =>
      'Glissez à droite pour garder un fichier, à gauche pour le supprimer, ou appuyez sur « Passer » pour décider plus tard.';

  @override
  String get helpNotifications => 'Notifications';

  @override
  String get helpNotificationsBody =>
      'Activez les rappels pour être notifié chaque jour ou chaque semaine de nettoyer votre stockage.';

  @override
  String get helpLookback => 'Période de recherche';

  @override
  String get helpLookbackBody =>
      'Quand vous commencez un examen, choisissez la période — de 1 jour à tout l\'historique.';

  @override
  String get helpStats => 'Statistiques';

  @override
  String get helpStatsBody =>
      'Voyez combien d\'espace vous avez libéré et suivez votre série de nettoyage.';

  @override
  String get preparingReview => 'Préparation de l\'examen';

  @override
  String get filesScanned => 'fichiers scannés';

  @override
  String get scanningPhotosAndVideos => 'Scan des photos et vidéos...';

  @override
  String get scanningDownloads => 'Scan des téléchargements...';

  @override
  String get cleaningUp => 'Nettoyage en cours...';

  @override
  String filesDeletedProgress(int done, int total) {
    return '$done / $total fichiers supprimés';
  }

  @override
  String get loadingStats => 'Chargement des stats...';

  @override
  String get startingReview => 'Démarrage de l\'examen...';

  @override
  String get scanning => 'Scan en cours...';
}
