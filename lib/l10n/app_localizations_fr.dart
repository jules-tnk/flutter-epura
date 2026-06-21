// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Epura';

  @override
  String get home => 'Accueil';

  @override
  String get review => 'Revue';

  @override
  String get localOnlyBadge => 'Local uniquement';

  @override
  String get takeControlOfSpace => 'Reprenez le contrôle de votre espace';

  @override
  String get allTime => 'Depuis le début';

  @override
  String get thisMonth => 'Ce mois-ci';

  @override
  String get thisSession => 'Cette session';

  @override
  String get daysInARow => 'jours de suite';

  @override
  String get readyToReview => 'Prêt à passer en revue';

  @override
  String reviewModesAvailable(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count modes de revue disponibles',
      one: '1 mode de revue disponible',
    );
    return '$_temp0';
  }

  @override
  String get resumeReview => 'Reprendre la revue';

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
  String get reviewModes => 'Modes de revue';

  @override
  String get reviewModeRecent => 'Récents';

  @override
  String get reviewModeLargestFiles => 'Plus gros';

  @override
  String get reviewModeScreenshots => 'Captures';

  @override
  String get reviewModeLargeVideos => 'Grandes vidéos';

  @override
  String get reviewModeBursts => 'Rafales';

  @override
  String get reviewModeDownloads => 'Téléchargements';

  @override
  String get reviewModeSelectedFolders => 'Dossiers sélectionnés';

  @override
  String reviewModeFolder(String name) {
    return 'Dossier : $name';
  }

  @override
  String get reviewModeDuplicates => 'Doublons';

  @override
  String get reviewModeSkipped => 'Passés';

  @override
  String get reviewModeMore => 'Plus de modes';

  @override
  String get reviewModeSheetTitle => 'Choisir un mode de revue';

  @override
  String get noFilesForMode => 'Aucun fichier trouvé pour ce mode de revue.';

  @override
  String get exactDuplicateGroups => 'Groupes de doublons exacts';

  @override
  String exactCopies(int count) {
    return '$count copies exactes';
  }

  @override
  String recoverableStorage(String size) {
    return '$size récupérables';
  }

  @override
  String get reviewGroup => 'Examiner le groupe';

  @override
  String reviewGroupCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count groupes',
      one: '1 groupe',
    );
    return '$_temp0';
  }

  @override
  String get compareGroup => 'Comparer le groupe';

  @override
  String get comparePhotos => 'Comparer les photos';

  @override
  String get compareShots => 'Comparer les prises';

  @override
  String groupComparePosition(int index, int count) {
    return '$index sur $count';
  }

  @override
  String get dismissGroup => 'Masquer le groupe';

  @override
  String get groupDismissed => 'Groupe masqué.';

  @override
  String get noDuplicateGroups => 'Aucun groupe de doublons exacts trouvé.';

  @override
  String get photoBursts => 'Rafales photo';

  @override
  String burstShots(int count) {
    return '$count prises';
  }

  @override
  String burstSpan(int seconds) {
    return '${seconds}s d\'écart';
  }

  @override
  String burstTotalStorage(String size) {
    return '$size au total';
  }

  @override
  String groupTotalStorage(String size) {
    return '$size au total';
  }

  @override
  String get reviewBurst => 'Examiner la rafale';

  @override
  String get noBurstGroups => 'Aucune rafale photo trouvée.';

  @override
  String get leaveReview => 'Quitter l\'examen ?';

  @override
  String get leaveReviewMessage =>
      'Vous pouvez enregistrer votre progression ou abandonner toutes les modifications.';

  @override
  String get cancel => 'Annuler';

  @override
  String get save => 'Enregistrer';

  @override
  String get saveAndExit => 'Enregistrer et quitter';

  @override
  String get discardAndExit => 'Abandonner et quitter';

  @override
  String get skipForLater => 'Passer pour plus tard';

  @override
  String get neverAskAgain => 'Ne plus demander';

  @override
  String reviewProgress(int current, int total) {
    return '$current/$total';
  }

  @override
  String filesMarkedForDeletion(int count) {
    return 'Supprimer $count';
  }

  @override
  String get photo => 'Photo';

  @override
  String get video => 'Vidéo';

  @override
  String get download => 'Téléchargement';

  @override
  String get openPreview => 'Ouvrir l\'aperçu';

  @override
  String duplicateCandidate(int index, int count) {
    return 'Doublon $index sur $count';
  }

  @override
  String get duplicateCandidateHelp =>
      'Même empreinte locale et même taille. Vérifiez chaque copie ; Epura ne supprime rien automatiquement.';

  @override
  String burstCandidate(int index, int count) {
    return 'Rafale $index sur $count';
  }

  @override
  String get burstCandidateHelp =>
      'Photos prises à quelques secondes d\'écart. Examinez chaque prise ; Epura ne choisit pas automatiquement la meilleure.';

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
  String get reviewPromptTitle => 'Vous aimez Epura ?';

  @override
  String get reviewPromptBody =>
      'Une note sur le Play Store aide d\'autres personnes à trouver une app de nettoyage privée. Epura ne demande qu\'après des sessions réussies.';

  @override
  String get rateEpura => 'Noter Epura';

  @override
  String get notNow => 'Pas maintenant';

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
  String get sessions => 'Sessions';

  @override
  String get sessionHistory => 'Historique des sessions';

  @override
  String get recentSessions => 'Sessions récentes';

  @override
  String filesReviewedCount(int count) {
    return '$count fichiers examinés';
  }

  @override
  String get monthlyReviewProgress => 'Progression de revue ce mois-ci';

  @override
  String get storageFreedThisMonth => 'Espace libéré ce mois-ci';

  @override
  String get storageInsightTitle => 'Analyse du stockage';

  @override
  String get storageInsightStatsEntryBody =>
      'Voir ce qu\'Epura peut examiner et ce qu\'Android gère.';

  @override
  String get storageInsightEpuraCanReview => 'Epura peut examiner';

  @override
  String get storageInsightEpuraCanReviewBody =>
      'Cela couvre seulement le stockage choisi pour l\'analyse : photos, vidéos, dossiers sélectionnés et fichiers importés.';

  @override
  String storageInsightFilesAvailable(int count) {
    return '$count fichiers dans le périmètre';
  }

  @override
  String get storageInsightAlreadyFreed => 'Déjà libéré';

  @override
  String get storageInsightPhotosVideos => 'Photos et vidéos';

  @override
  String get storageInsightGuideTitle => 'Qu\'est-ce qui prend de la place ?';

  @override
  String get storageInsightPhotosVideosBody =>
      'Les médias grossissent souvent le plus vite. Epura aide à examiner les photos et vidéos qu\'Android lui laisse voir.';

  @override
  String get storageInsightDownloadsBody =>
      'Les téléchargements importés et dossiers sélectionnés restent locaux et sont examinés seulement après votre choix.';

  @override
  String get storageInsightAppCache => 'Cache des apps';

  @override
  String get storageInsightAppCacheBody =>
      'Android gère le cache des autres apps. Epura ne le vide pas et n\'inspecte pas vos apps installées.';

  @override
  String get storageInsightCloudCopies => 'Copies cloud';

  @override
  String get storageInsightCloudCopiesBody =>
      'Un fichier peut sembler sauvegardé tout en occupant l\'appareil. Vérifiez l\'app d\'origine avant de supprimer un élément important.';

  @override
  String get storageInsightSystemStorage => 'Stockage système';

  @override
  String get storageInsightSystemStorageBody =>
      'Les fichiers système et données cachées des apps relèvent des paramètres Android, pas du tri Epura.';

  @override
  String get storageInsightPlanTitle => 'Plan de nettoyage';

  @override
  String get storageInsightPlan2MinuteTitle => 'Nettoyage en 2 minutes';

  @override
  String get storageInsightPlan2MinuteBody =>
      'Examinez les captures récentes et les images ponctuelles évidentes.';

  @override
  String get storageInsightPlan5MinuteTitle => 'Nettoyage en 5 minutes';

  @override
  String get storageInsightPlan5MinuteBody =>
      'Examinez d\'abord les grandes vidéos et les groupes de doublons exacts.';

  @override
  String get storageInsightPlanWeeklyTitle => 'Nettoyage hebdomadaire';

  @override
  String get storageInsightPlanWeeklyBody =>
      'Examinez les nouveaux fichiers depuis la dernière session avant que la file grandisse.';

  @override
  String get storageInsightPlanMonthlyTitle => 'Nettoyage mensuel';

  @override
  String get storageInsightPlanMonthlyBody =>
      'Importez les téléchargements ou rescanez les dossiers sélectionnés qui demandent un tri.';

  @override
  String get openAndroidStorageSettings =>
      'Ouvrir les paramètres de stockage Android';

  @override
  String get androidStorageSettingsUnavailable =>
      'Les paramètres de stockage Android ne sont pas disponibles sur cet appareil.';

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
      'Epura vous aide à examiner et nettoyer les photos, vidéos, les fichiers des dossiers que vous sélectionnez explicitement et les fichiers téléchargés que vous importez manuellement.';

  @override
  String get helpHowItWorks => 'Comment ça marche';

  @override
  String get helpHowItWorksBody =>
      'Glissez à droite pour garder un fichier, à gauche pour le supprimer, ou appuyez sur « Passer » pour décider plus tard. Les photos et vidéos sont scannées automatiquement, les dossiers sélectionnés sont rescannés avec votre autorisation, et les fichiers téléchargés peuvent être importés dans la même pile d\'examen.';

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
  String get scanningCustomFolders => 'Scan des dossiers sélectionnés...';

  @override
  String get cleaningUp => 'Nettoyage en cours...';

  @override
  String filesRemovalProgress(int done, int total) {
    return '$done / $total fichiers traités';
  }

  @override
  String get loadingStats => 'Chargement des stats...';

  @override
  String get startingReview => 'Démarrage de l\'examen...';

  @override
  String get scanning => 'Scan en cours...';

  @override
  String get addDownloadedFiles => 'Ajouter des fichiers téléchargés';

  @override
  String get downloadsInboxTitle => 'Boîte de téléchargements';

  @override
  String downloadsInboxSummary(int count, String size) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count fichiers importés - $size',
      one: '1 fichier importé - $size',
    );
    return '$_temp0';
  }

  @override
  String get downloadsInboxBody =>
      'Android vous demande de choisir les téléchargements manuellement. Epura examine seulement les fichiers choisis.';

  @override
  String get reviewDownloads => 'Examiner les téléchargements';

  @override
  String get filterDownloads => 'Filtrer';

  @override
  String get downloadFilterTitle => 'Examiner les téléchargements par type';

  @override
  String get downloadFilterAll => 'Tous les téléchargements';

  @override
  String get downloadFilterPdfs => 'PDF';

  @override
  String get downloadFilterArchives => 'Archives';

  @override
  String get downloadFilterApks => 'APK';

  @override
  String get downloadFilterAudio => 'Audio';

  @override
  String get downloadFilterDocuments => 'Documents';

  @override
  String get downloadFilterOther => 'Autres';

  @override
  String downloadFilterOption(String label, int count) {
    return '$label ($count)';
  }

  @override
  String get addMoreDownloads => 'Ajouter';

  @override
  String clearImportedFiles(int count) {
    return 'Effacer les fichiers importés ($count)';
  }

  @override
  String importedFilesAdded(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count fichiers ajoutés à votre file d\'examen.',
      one: '1 fichier ajouté à votre file d\'examen.',
    );
    return '$_temp0';
  }

  @override
  String get importedFilesCleared =>
      'Les fichiers importés ont été retirés de la file d\'examen.';

  @override
  String get customFoldersToScan => 'Dossiers personnalisés à scanner';

  @override
  String get addCustomFolder => 'Ajouter un dossier';

  @override
  String get customFoldersHelp =>
      'Choisissez les dossiers qu\'Epura doit rescanner automatiquement. L\'accès est limité aux dossiers que vous sélectionnez explicitement.';

  @override
  String get renameFolder => 'Renommer le dossier';

  @override
  String get folderNickname => 'Nom du dossier';

  @override
  String folderLastReviewed(String date) {
    return 'Dernière revue : $date';
  }

  @override
  String get noCustomFolders =>
      'Aucun dossier personnalisé sélectionné. Par défaut, Epura ne scanne que les photos et les vidéos.';

  @override
  String folderAdded(String name) {
    return '$name ajouté aux scans de dossiers.';
  }

  @override
  String folderRemoved(String name) {
    return '$name retiré des scans de dossiers.';
  }

  @override
  String get downloadFolderSelectionHint =>
      'Android 11+ n\'autorise pas les applications à sélectionner le dossier Téléchargements comme accès de dossier réutilisable. Utilisez plutôt « Ajouter des fichiers téléchargés » sur l\'écran d\'accueil.';

  @override
  String filesCouldNotBeDeleted(int count) {
    return '$count fichiers n\'ont pas pu être supprimés et ont été conservés sur votre appareil.';
  }

  @override
  String filesMovedToTrash(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count fichiers déplacés vers la corbeille Android. Vous pourrez peut-être les restaurer depuis votre galerie jusqu\'à ce qu\'Android vide la corbeille.',
      one:
          '1 fichier déplacé vers la corbeille Android. Vous pourrez peut-être le restaurer depuis votre galerie jusqu\'à ce qu\'Android vide la corbeille.',
    );
    return '$_temp0';
  }

  @override
  String filesPermanentlyDeleted(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count fichiers ont été supprimés définitivement.',
      one: '1 fichier a été supprimé définitivement.',
    );
    return '$_temp0';
  }

  @override
  String get trashStorageFreedNote =>
      'L\'espace libéré ne compte que les fichiers supprimés définitivement. Les médias dans la corbeille peuvent encore occuper de l\'espace jusqu\'à ce que la corbeille soit vidée.';

  @override
  String get appearance => 'Apparence';

  @override
  String get light => 'Clair';

  @override
  String get dark => 'Sombre';

  @override
  String get legal => 'Mentions légales';

  @override
  String get privacyPolicy => 'Politique de confidentialité';

  @override
  String get termsOfService => 'Conditions d\'utilisation';

  @override
  String get viewOnline => 'Voir en ligne';

  @override
  String get privacyAndControl => 'Confidentialité et contrôle';

  @override
  String get privacyPermissions => 'Confidentialité et autorisations';

  @override
  String get privacyPermissionsSubtitle =>
      'Voyez ce qu\'Epura peut utiliser et effacez l\'historique local.';

  @override
  String get privacyReceipt => 'Reçu de confidentialité';

  @override
  String get noAccount => 'Aucun compte';

  @override
  String get noCloudSync => 'Aucune synchronisation cloud';

  @override
  String get noAnalyticsTracking => 'Aucune analyse ni suivi';

  @override
  String get localOnlyProcessing => 'Tout le traitement reste sur cet appareil';

  @override
  String get permissionsEpuraUses => 'Autorisations utilisées par Epura';

  @override
  String get mediaPermissionTitle => 'Photos et vidéos';

  @override
  String get mediaPermissionBody =>
      'Utilisées uniquement pour afficher les médias choisis dans votre revue.';

  @override
  String get selectedFoldersPermissionTitle =>
      'Dossiers et fichiers sélectionnés';

  @override
  String get selectedFoldersPermissionBody =>
      'Utilisés uniquement pour les dossiers ou fichiers téléchargés que vous choisissez avec le sélecteur Android.';

  @override
  String get notificationsPermissionTitle => 'Notifications';

  @override
  String get notificationsPermissionBody =>
      'Utilisées uniquement pour les rappels que vous activez.';

  @override
  String get currentLocalAccess => 'Accès local actuel';

  @override
  String get selectedFolders => 'Dossiers sélectionnés';

  @override
  String get noneSelected => 'Aucun';

  @override
  String selectedFolderCount(int count) {
    return '$count sélectionné(s)';
  }

  @override
  String get enabled => 'Activé';

  @override
  String get disabled => 'Désactivé';

  @override
  String get localHistory => 'Historique local';

  @override
  String get noLocalReviewHistory => 'Aucun historique local';

  @override
  String localReviewSessionCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sessions locales',
      one: '1 session locale',
    );
    return '$_temp0';
  }

  @override
  String get clearHistoryExplanation =>
      'Cela efface les statistiques de revue d\'Epura, le repère de dernière revue, la file des fichiers passés, les décisions « ne plus demander », les groupes masqués et l\'index local des fichiers. Cela ne supprime pas vos fichiers, ne révoque pas les dossiers sélectionnés et ne change pas vos réglages de scan.';

  @override
  String get clearEpuraHistory => 'Effacer l\'historique Epura';

  @override
  String get clearHistoryTitle => 'Effacer l\'historique local ?';

  @override
  String get clearHistoryMessage =>
      'Epura effacera les sessions de revue, les statistiques, le repère de dernière revue, la file des fichiers passés, les décisions « ne plus demander », les groupes masqués et l\'index local des fichiers. Vos fichiers et dossiers sélectionnés resteront inchangés.';

  @override
  String get clearHistoryConfirm => 'Effacer l\'historique';

  @override
  String get historyClearedMessage =>
      'Historique Epura effacé. Vos fichiers n\'ont pas été modifiés.';

  @override
  String get welcomeToEpura => 'Bienvenue sur Epura';

  @override
  String get termsBottomSheetSummary =>
      'Epura fonctionne entièrement sur votre appareil. Aucune donnée n\'est collectée, transmise ou partagée. En continuant, vous acceptez notre politique de confidentialité et nos conditions d\'utilisation.';

  @override
  String get accept => 'Accepter';

  @override
  String get readPrivacyPolicy => 'Lire la politique de confidentialité';

  @override
  String get readTermsOfService => 'Lire les conditions d\'utilisation';

  @override
  String get privacyPolicyLastUpdated => 'Dernière mise à jour : 13 avril 2026';

  @override
  String get privacyPolicyIntro =>
      'Epura ne collecte, ne transmet et ne partage aucune donnée personnelle.';

  @override
  String get privacyPolicyAccess =>
      'L\'application demande l\'accès uniquement à la photothèque de votre appareil et aux dossiers ou fichiers que vous sélectionnez explicitement via le sélecteur système Android. Les fichiers ne sont supprimés que lorsque vous choisissez explicitement de les supprimer dans Epura.';

  @override
  String get privacyPolicyNoData =>
      'Aucune donnée ne quitte votre appareil. Pas d\'analyse, pas de suivi, pas de compte requis.';

  @override
  String get privacyPolicyPermissions => 'Autorisations';

  @override
  String get privacyPolicyPermMedia =>
      'READ_MEDIA_IMAGES / READ_MEDIA_VIDEO : utilisées pour afficher vos photos et vidéos.';

  @override
  String get privacyPolicyPermStorage =>
      'Autorisations Storage Access Framework : utilisées uniquement pour les dossiers personnalisés et les fichiers téléchargés que vous sélectionnez explicitement dans le sélecteur système.';

  @override
  String get privacyPolicyPermNotif =>
      'POST_NOTIFICATIONS : utilisée pour envoyer des rappels périodiques.';

  @override
  String get privacyPolicyPermAlarm =>
      'SCHEDULE_EXACT_ALARM / RECEIVE_BOOT_COMPLETED : utilisées pour livrer les rappels aux heures choisies.';

  @override
  String get tosLastUpdated => 'Dernière mise à jour : 20 mars 2026';

  @override
  String get tosIntro =>
      'En utilisant Epura, vous acceptez les conditions suivantes.';

  @override
  String get tosLocalOnly =>
      'Epura fonctionne entièrement sur votre appareil. Aucun compte n\'est requis et aucune donnée n\'est transmise.';

  @override
  String get tosDeletion =>
      'Lorsque vous choisissez de supprimer un fichier, il est définitivement supprimé de votre appareil. Epura n\'est pas responsable de toute perte de données résultant de vos décisions.';

  @override
  String get tosNoWarranty =>
      'Epura est fourni « en l\'état » sans aucune garantie.';

  @override
  String get tosChanges =>
      'Ces conditions peuvent être mises à jour. L\'utilisation continue de l\'application vaut acceptation des modifications.';
}
