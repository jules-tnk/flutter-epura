// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'epura_database.dart';

// ignore_for_file: type=lint
class $ReviewSessionsTable extends ReviewSessions
    with TableInfo<$ReviewSessionsTable, ReviewSessionRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReviewSessionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<String> date = GeneratedColumn<String>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _keptCountMeta = const VerificationMeta(
    'keptCount',
  );
  @override
  late final GeneratedColumn<int> keptCount = GeneratedColumn<int>(
    'keptCount',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedCountMeta = const VerificationMeta(
    'deletedCount',
  );
  @override
  late final GeneratedColumn<int> deletedCount = GeneratedColumn<int>(
    'deletedCount',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _skippedCountMeta = const VerificationMeta(
    'skippedCount',
  );
  @override
  late final GeneratedColumn<int> skippedCount = GeneratedColumn<int>(
    'skippedCount',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bytesFreedMeta = const VerificationMeta(
    'bytesFreed',
  );
  @override
  late final GeneratedColumn<int> bytesFreed = GeneratedColumn<int>(
    'bytesFreed',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    date,
    keptCount,
    deletedCount,
    skippedCount,
    bytesFreed,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'review_sessions';
  @override
  VerificationContext validateIntegrity(
    Insertable<ReviewSessionRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('keptCount')) {
      context.handle(
        _keptCountMeta,
        keptCount.isAcceptableOrUnknown(data['keptCount']!, _keptCountMeta),
      );
    } else if (isInserting) {
      context.missing(_keptCountMeta);
    }
    if (data.containsKey('deletedCount')) {
      context.handle(
        _deletedCountMeta,
        deletedCount.isAcceptableOrUnknown(
          data['deletedCount']!,
          _deletedCountMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_deletedCountMeta);
    }
    if (data.containsKey('skippedCount')) {
      context.handle(
        _skippedCountMeta,
        skippedCount.isAcceptableOrUnknown(
          data['skippedCount']!,
          _skippedCountMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_skippedCountMeta);
    }
    if (data.containsKey('bytesFreed')) {
      context.handle(
        _bytesFreedMeta,
        bytesFreed.isAcceptableOrUnknown(data['bytesFreed']!, _bytesFreedMeta),
      );
    } else if (isInserting) {
      context.missing(_bytesFreedMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ReviewSessionRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReviewSessionRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}date'],
      )!,
      keptCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}keptCount'],
      )!,
      deletedCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deletedCount'],
      )!,
      skippedCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}skippedCount'],
      )!,
      bytesFreed: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}bytesFreed'],
      )!,
    );
  }

  @override
  $ReviewSessionsTable createAlias(String alias) {
    return $ReviewSessionsTable(attachedDatabase, alias);
  }
}

class ReviewSessionRow extends DataClass
    implements Insertable<ReviewSessionRow> {
  final int id;
  final String date;
  final int keptCount;
  final int deletedCount;
  final int skippedCount;
  final int bytesFreed;
  const ReviewSessionRow({
    required this.id,
    required this.date,
    required this.keptCount,
    required this.deletedCount,
    required this.skippedCount,
    required this.bytesFreed,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['date'] = Variable<String>(date);
    map['keptCount'] = Variable<int>(keptCount);
    map['deletedCount'] = Variable<int>(deletedCount);
    map['skippedCount'] = Variable<int>(skippedCount);
    map['bytesFreed'] = Variable<int>(bytesFreed);
    return map;
  }

  ReviewSessionsCompanion toCompanion(bool nullToAbsent) {
    return ReviewSessionsCompanion(
      id: Value(id),
      date: Value(date),
      keptCount: Value(keptCount),
      deletedCount: Value(deletedCount),
      skippedCount: Value(skippedCount),
      bytesFreed: Value(bytesFreed),
    );
  }

  factory ReviewSessionRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReviewSessionRow(
      id: serializer.fromJson<int>(json['id']),
      date: serializer.fromJson<String>(json['date']),
      keptCount: serializer.fromJson<int>(json['keptCount']),
      deletedCount: serializer.fromJson<int>(json['deletedCount']),
      skippedCount: serializer.fromJson<int>(json['skippedCount']),
      bytesFreed: serializer.fromJson<int>(json['bytesFreed']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'date': serializer.toJson<String>(date),
      'keptCount': serializer.toJson<int>(keptCount),
      'deletedCount': serializer.toJson<int>(deletedCount),
      'skippedCount': serializer.toJson<int>(skippedCount),
      'bytesFreed': serializer.toJson<int>(bytesFreed),
    };
  }

  ReviewSessionRow copyWith({
    int? id,
    String? date,
    int? keptCount,
    int? deletedCount,
    int? skippedCount,
    int? bytesFreed,
  }) => ReviewSessionRow(
    id: id ?? this.id,
    date: date ?? this.date,
    keptCount: keptCount ?? this.keptCount,
    deletedCount: deletedCount ?? this.deletedCount,
    skippedCount: skippedCount ?? this.skippedCount,
    bytesFreed: bytesFreed ?? this.bytesFreed,
  );
  ReviewSessionRow copyWithCompanion(ReviewSessionsCompanion data) {
    return ReviewSessionRow(
      id: data.id.present ? data.id.value : this.id,
      date: data.date.present ? data.date.value : this.date,
      keptCount: data.keptCount.present ? data.keptCount.value : this.keptCount,
      deletedCount: data.deletedCount.present
          ? data.deletedCount.value
          : this.deletedCount,
      skippedCount: data.skippedCount.present
          ? data.skippedCount.value
          : this.skippedCount,
      bytesFreed: data.bytesFreed.present
          ? data.bytesFreed.value
          : this.bytesFreed,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReviewSessionRow(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('keptCount: $keptCount, ')
          ..write('deletedCount: $deletedCount, ')
          ..write('skippedCount: $skippedCount, ')
          ..write('bytesFreed: $bytesFreed')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, date, keptCount, deletedCount, skippedCount, bytesFreed);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReviewSessionRow &&
          other.id == this.id &&
          other.date == this.date &&
          other.keptCount == this.keptCount &&
          other.deletedCount == this.deletedCount &&
          other.skippedCount == this.skippedCount &&
          other.bytesFreed == this.bytesFreed);
}

class ReviewSessionsCompanion extends UpdateCompanion<ReviewSessionRow> {
  final Value<int> id;
  final Value<String> date;
  final Value<int> keptCount;
  final Value<int> deletedCount;
  final Value<int> skippedCount;
  final Value<int> bytesFreed;
  const ReviewSessionsCompanion({
    this.id = const Value.absent(),
    this.date = const Value.absent(),
    this.keptCount = const Value.absent(),
    this.deletedCount = const Value.absent(),
    this.skippedCount = const Value.absent(),
    this.bytesFreed = const Value.absent(),
  });
  ReviewSessionsCompanion.insert({
    this.id = const Value.absent(),
    required String date,
    required int keptCount,
    required int deletedCount,
    required int skippedCount,
    required int bytesFreed,
  }) : date = Value(date),
       keptCount = Value(keptCount),
       deletedCount = Value(deletedCount),
       skippedCount = Value(skippedCount),
       bytesFreed = Value(bytesFreed);
  static Insertable<ReviewSessionRow> custom({
    Expression<int>? id,
    Expression<String>? date,
    Expression<int>? keptCount,
    Expression<int>? deletedCount,
    Expression<int>? skippedCount,
    Expression<int>? bytesFreed,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (date != null) 'date': date,
      if (keptCount != null) 'keptCount': keptCount,
      if (deletedCount != null) 'deletedCount': deletedCount,
      if (skippedCount != null) 'skippedCount': skippedCount,
      if (bytesFreed != null) 'bytesFreed': bytesFreed,
    });
  }

  ReviewSessionsCompanion copyWith({
    Value<int>? id,
    Value<String>? date,
    Value<int>? keptCount,
    Value<int>? deletedCount,
    Value<int>? skippedCount,
    Value<int>? bytesFreed,
  }) {
    return ReviewSessionsCompanion(
      id: id ?? this.id,
      date: date ?? this.date,
      keptCount: keptCount ?? this.keptCount,
      deletedCount: deletedCount ?? this.deletedCount,
      skippedCount: skippedCount ?? this.skippedCount,
      bytesFreed: bytesFreed ?? this.bytesFreed,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (date.present) {
      map['date'] = Variable<String>(date.value);
    }
    if (keptCount.present) {
      map['keptCount'] = Variable<int>(keptCount.value);
    }
    if (deletedCount.present) {
      map['deletedCount'] = Variable<int>(deletedCount.value);
    }
    if (skippedCount.present) {
      map['skippedCount'] = Variable<int>(skippedCount.value);
    }
    if (bytesFreed.present) {
      map['bytesFreed'] = Variable<int>(bytesFreed.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReviewSessionsCompanion(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('keptCount: $keptCount, ')
          ..write('deletedCount: $deletedCount, ')
          ..write('skippedCount: $skippedCount, ')
          ..write('bytesFreed: $bytesFreed')
          ..write(')'))
        .toString();
  }
}

class $ReviewDecisionsTable extends ReviewDecisions
    with TableInfo<$ReviewDecisionsTable, ReviewDecisionRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReviewDecisionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _fileKeyMeta = const VerificationMeta(
    'fileKey',
  );
  @override
  late final GeneratedColumn<String> fileKey = GeneratedColumn<String>(
    'fileKey',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _decisionMeta = const VerificationMeta(
    'decision',
  );
  @override
  late final GeneratedColumn<String> decision = GeneratedColumn<String>(
    'decision',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _decidedAtMeta = const VerificationMeta(
    'decidedAt',
  );
  @override
  late final GeneratedColumn<String> decidedAt = GeneratedColumn<String>(
    'decidedAt',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [fileKey, decision, decidedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'review_decisions';
  @override
  VerificationContext validateIntegrity(
    Insertable<ReviewDecisionRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('fileKey')) {
      context.handle(
        _fileKeyMeta,
        fileKey.isAcceptableOrUnknown(data['fileKey']!, _fileKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_fileKeyMeta);
    }
    if (data.containsKey('decision')) {
      context.handle(
        _decisionMeta,
        decision.isAcceptableOrUnknown(data['decision']!, _decisionMeta),
      );
    } else if (isInserting) {
      context.missing(_decisionMeta);
    }
    if (data.containsKey('decidedAt')) {
      context.handle(
        _decidedAtMeta,
        decidedAt.isAcceptableOrUnknown(data['decidedAt']!, _decidedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_decidedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {fileKey};
  @override
  ReviewDecisionRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReviewDecisionRow(
      fileKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}fileKey'],
      )!,
      decision: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}decision'],
      )!,
      decidedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}decidedAt'],
      )!,
    );
  }

  @override
  $ReviewDecisionsTable createAlias(String alias) {
    return $ReviewDecisionsTable(attachedDatabase, alias);
  }
}

class ReviewDecisionRow extends DataClass
    implements Insertable<ReviewDecisionRow> {
  final String fileKey;
  final String decision;
  final String decidedAt;
  const ReviewDecisionRow({
    required this.fileKey,
    required this.decision,
    required this.decidedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['fileKey'] = Variable<String>(fileKey);
    map['decision'] = Variable<String>(decision);
    map['decidedAt'] = Variable<String>(decidedAt);
    return map;
  }

  ReviewDecisionsCompanion toCompanion(bool nullToAbsent) {
    return ReviewDecisionsCompanion(
      fileKey: Value(fileKey),
      decision: Value(decision),
      decidedAt: Value(decidedAt),
    );
  }

  factory ReviewDecisionRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReviewDecisionRow(
      fileKey: serializer.fromJson<String>(json['fileKey']),
      decision: serializer.fromJson<String>(json['decision']),
      decidedAt: serializer.fromJson<String>(json['decidedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'fileKey': serializer.toJson<String>(fileKey),
      'decision': serializer.toJson<String>(decision),
      'decidedAt': serializer.toJson<String>(decidedAt),
    };
  }

  ReviewDecisionRow copyWith({
    String? fileKey,
    String? decision,
    String? decidedAt,
  }) => ReviewDecisionRow(
    fileKey: fileKey ?? this.fileKey,
    decision: decision ?? this.decision,
    decidedAt: decidedAt ?? this.decidedAt,
  );
  ReviewDecisionRow copyWithCompanion(ReviewDecisionsCompanion data) {
    return ReviewDecisionRow(
      fileKey: data.fileKey.present ? data.fileKey.value : this.fileKey,
      decision: data.decision.present ? data.decision.value : this.decision,
      decidedAt: data.decidedAt.present ? data.decidedAt.value : this.decidedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReviewDecisionRow(')
          ..write('fileKey: $fileKey, ')
          ..write('decision: $decision, ')
          ..write('decidedAt: $decidedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(fileKey, decision, decidedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReviewDecisionRow &&
          other.fileKey == this.fileKey &&
          other.decision == this.decision &&
          other.decidedAt == this.decidedAt);
}

class ReviewDecisionsCompanion extends UpdateCompanion<ReviewDecisionRow> {
  final Value<String> fileKey;
  final Value<String> decision;
  final Value<String> decidedAt;
  final Value<int> rowid;
  const ReviewDecisionsCompanion({
    this.fileKey = const Value.absent(),
    this.decision = const Value.absent(),
    this.decidedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ReviewDecisionsCompanion.insert({
    required String fileKey,
    required String decision,
    required String decidedAt,
    this.rowid = const Value.absent(),
  }) : fileKey = Value(fileKey),
       decision = Value(decision),
       decidedAt = Value(decidedAt);
  static Insertable<ReviewDecisionRow> custom({
    Expression<String>? fileKey,
    Expression<String>? decision,
    Expression<String>? decidedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (fileKey != null) 'fileKey': fileKey,
      if (decision != null) 'decision': decision,
      if (decidedAt != null) 'decidedAt': decidedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ReviewDecisionsCompanion copyWith({
    Value<String>? fileKey,
    Value<String>? decision,
    Value<String>? decidedAt,
    Value<int>? rowid,
  }) {
    return ReviewDecisionsCompanion(
      fileKey: fileKey ?? this.fileKey,
      decision: decision ?? this.decision,
      decidedAt: decidedAt ?? this.decidedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (fileKey.present) {
      map['fileKey'] = Variable<String>(fileKey.value);
    }
    if (decision.present) {
      map['decision'] = Variable<String>(decision.value);
    }
    if (decidedAt.present) {
      map['decidedAt'] = Variable<String>(decidedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReviewDecisionsCompanion(')
          ..write('fileKey: $fileKey, ')
          ..write('decision: $decision, ')
          ..write('decidedAt: $decidedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FileIndexEntriesTable extends FileIndexEntries
    with TableInfo<$FileIndexEntriesTable, IndexedFileRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FileIndexEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _fileKeyMeta = const VerificationMeta(
    'fileKey',
  );
  @override
  late final GeneratedColumn<String> fileKey = GeneratedColumn<String>(
    'fileKey',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fileTypeMeta = const VerificationMeta(
    'fileType',
  );
  @override
  late final GeneratedColumn<String> fileType = GeneratedColumn<String>(
    'fileType',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sizeMeta = const VerificationMeta('size');
  @override
  late final GeneratedColumn<int> size = GeneratedColumn<int>(
    'size',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _modifiedAtMeta = const VerificationMeta(
    'modifiedAt',
  );
  @override
  late final GeneratedColumn<String> modifiedAt = GeneratedColumn<String>(
    'modifiedAt',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _indexedAtMeta = const VerificationMeta(
    'indexedAt',
  );
  @override
  late final GeneratedColumn<String> indexedAt = GeneratedColumn<String>(
    'indexedAt',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _folderUriMeta = const VerificationMeta(
    'folderUri',
  );
  @override
  late final GeneratedColumn<String> folderUri = GeneratedColumn<String>(
    'folderUri',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _mimeTypeMeta = const VerificationMeta(
    'mimeType',
  );
  @override
  late final GeneratedColumn<String> mimeType = GeneratedColumn<String>(
    'mimeType',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    fileKey,
    source,
    fileType,
    size,
    modifiedAt,
    indexedAt,
    folderUri,
    mimeType,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'file_index';
  @override
  VerificationContext validateIntegrity(
    Insertable<IndexedFileRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('fileKey')) {
      context.handle(
        _fileKeyMeta,
        fileKey.isAcceptableOrUnknown(data['fileKey']!, _fileKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_fileKeyMeta);
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceMeta);
    }
    if (data.containsKey('fileType')) {
      context.handle(
        _fileTypeMeta,
        fileType.isAcceptableOrUnknown(data['fileType']!, _fileTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_fileTypeMeta);
    }
    if (data.containsKey('size')) {
      context.handle(
        _sizeMeta,
        size.isAcceptableOrUnknown(data['size']!, _sizeMeta),
      );
    } else if (isInserting) {
      context.missing(_sizeMeta);
    }
    if (data.containsKey('modifiedAt')) {
      context.handle(
        _modifiedAtMeta,
        modifiedAt.isAcceptableOrUnknown(data['modifiedAt']!, _modifiedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_modifiedAtMeta);
    }
    if (data.containsKey('indexedAt')) {
      context.handle(
        _indexedAtMeta,
        indexedAt.isAcceptableOrUnknown(data['indexedAt']!, _indexedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_indexedAtMeta);
    }
    if (data.containsKey('folderUri')) {
      context.handle(
        _folderUriMeta,
        folderUri.isAcceptableOrUnknown(data['folderUri']!, _folderUriMeta),
      );
    }
    if (data.containsKey('mimeType')) {
      context.handle(
        _mimeTypeMeta,
        mimeType.isAcceptableOrUnknown(data['mimeType']!, _mimeTypeMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {fileKey};
  @override
  IndexedFileRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return IndexedFileRow(
      fileKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}fileKey'],
      )!,
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
      fileType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}fileType'],
      )!,
      size: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}size'],
      )!,
      modifiedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}modifiedAt'],
      )!,
      indexedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}indexedAt'],
      )!,
      folderUri: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}folderUri'],
      ),
      mimeType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mimeType'],
      ),
    );
  }

  @override
  $FileIndexEntriesTable createAlias(String alias) {
    return $FileIndexEntriesTable(attachedDatabase, alias);
  }
}

class IndexedFileRow extends DataClass implements Insertable<IndexedFileRow> {
  final String fileKey;
  final String source;
  final String fileType;
  final int size;
  final String modifiedAt;
  final String indexedAt;
  final String? folderUri;
  final String? mimeType;
  const IndexedFileRow({
    required this.fileKey,
    required this.source,
    required this.fileType,
    required this.size,
    required this.modifiedAt,
    required this.indexedAt,
    this.folderUri,
    this.mimeType,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['fileKey'] = Variable<String>(fileKey);
    map['source'] = Variable<String>(source);
    map['fileType'] = Variable<String>(fileType);
    map['size'] = Variable<int>(size);
    map['modifiedAt'] = Variable<String>(modifiedAt);
    map['indexedAt'] = Variable<String>(indexedAt);
    if (!nullToAbsent || folderUri != null) {
      map['folderUri'] = Variable<String>(folderUri);
    }
    if (!nullToAbsent || mimeType != null) {
      map['mimeType'] = Variable<String>(mimeType);
    }
    return map;
  }

  FileIndexEntriesCompanion toCompanion(bool nullToAbsent) {
    return FileIndexEntriesCompanion(
      fileKey: Value(fileKey),
      source: Value(source),
      fileType: Value(fileType),
      size: Value(size),
      modifiedAt: Value(modifiedAt),
      indexedAt: Value(indexedAt),
      folderUri: folderUri == null && nullToAbsent
          ? const Value.absent()
          : Value(folderUri),
      mimeType: mimeType == null && nullToAbsent
          ? const Value.absent()
          : Value(mimeType),
    );
  }

  factory IndexedFileRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return IndexedFileRow(
      fileKey: serializer.fromJson<String>(json['fileKey']),
      source: serializer.fromJson<String>(json['source']),
      fileType: serializer.fromJson<String>(json['fileType']),
      size: serializer.fromJson<int>(json['size']),
      modifiedAt: serializer.fromJson<String>(json['modifiedAt']),
      indexedAt: serializer.fromJson<String>(json['indexedAt']),
      folderUri: serializer.fromJson<String?>(json['folderUri']),
      mimeType: serializer.fromJson<String?>(json['mimeType']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'fileKey': serializer.toJson<String>(fileKey),
      'source': serializer.toJson<String>(source),
      'fileType': serializer.toJson<String>(fileType),
      'size': serializer.toJson<int>(size),
      'modifiedAt': serializer.toJson<String>(modifiedAt),
      'indexedAt': serializer.toJson<String>(indexedAt),
      'folderUri': serializer.toJson<String?>(folderUri),
      'mimeType': serializer.toJson<String?>(mimeType),
    };
  }

  IndexedFileRow copyWith({
    String? fileKey,
    String? source,
    String? fileType,
    int? size,
    String? modifiedAt,
    String? indexedAt,
    Value<String?> folderUri = const Value.absent(),
    Value<String?> mimeType = const Value.absent(),
  }) => IndexedFileRow(
    fileKey: fileKey ?? this.fileKey,
    source: source ?? this.source,
    fileType: fileType ?? this.fileType,
    size: size ?? this.size,
    modifiedAt: modifiedAt ?? this.modifiedAt,
    indexedAt: indexedAt ?? this.indexedAt,
    folderUri: folderUri.present ? folderUri.value : this.folderUri,
    mimeType: mimeType.present ? mimeType.value : this.mimeType,
  );
  IndexedFileRow copyWithCompanion(FileIndexEntriesCompanion data) {
    return IndexedFileRow(
      fileKey: data.fileKey.present ? data.fileKey.value : this.fileKey,
      source: data.source.present ? data.source.value : this.source,
      fileType: data.fileType.present ? data.fileType.value : this.fileType,
      size: data.size.present ? data.size.value : this.size,
      modifiedAt: data.modifiedAt.present
          ? data.modifiedAt.value
          : this.modifiedAt,
      indexedAt: data.indexedAt.present ? data.indexedAt.value : this.indexedAt,
      folderUri: data.folderUri.present ? data.folderUri.value : this.folderUri,
      mimeType: data.mimeType.present ? data.mimeType.value : this.mimeType,
    );
  }

  @override
  String toString() {
    return (StringBuffer('IndexedFileRow(')
          ..write('fileKey: $fileKey, ')
          ..write('source: $source, ')
          ..write('fileType: $fileType, ')
          ..write('size: $size, ')
          ..write('modifiedAt: $modifiedAt, ')
          ..write('indexedAt: $indexedAt, ')
          ..write('folderUri: $folderUri, ')
          ..write('mimeType: $mimeType')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    fileKey,
    source,
    fileType,
    size,
    modifiedAt,
    indexedAt,
    folderUri,
    mimeType,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is IndexedFileRow &&
          other.fileKey == this.fileKey &&
          other.source == this.source &&
          other.fileType == this.fileType &&
          other.size == this.size &&
          other.modifiedAt == this.modifiedAt &&
          other.indexedAt == this.indexedAt &&
          other.folderUri == this.folderUri &&
          other.mimeType == this.mimeType);
}

class FileIndexEntriesCompanion extends UpdateCompanion<IndexedFileRow> {
  final Value<String> fileKey;
  final Value<String> source;
  final Value<String> fileType;
  final Value<int> size;
  final Value<String> modifiedAt;
  final Value<String> indexedAt;
  final Value<String?> folderUri;
  final Value<String?> mimeType;
  final Value<int> rowid;
  const FileIndexEntriesCompanion({
    this.fileKey = const Value.absent(),
    this.source = const Value.absent(),
    this.fileType = const Value.absent(),
    this.size = const Value.absent(),
    this.modifiedAt = const Value.absent(),
    this.indexedAt = const Value.absent(),
    this.folderUri = const Value.absent(),
    this.mimeType = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FileIndexEntriesCompanion.insert({
    required String fileKey,
    required String source,
    required String fileType,
    required int size,
    required String modifiedAt,
    required String indexedAt,
    this.folderUri = const Value.absent(),
    this.mimeType = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : fileKey = Value(fileKey),
       source = Value(source),
       fileType = Value(fileType),
       size = Value(size),
       modifiedAt = Value(modifiedAt),
       indexedAt = Value(indexedAt);
  static Insertable<IndexedFileRow> custom({
    Expression<String>? fileKey,
    Expression<String>? source,
    Expression<String>? fileType,
    Expression<int>? size,
    Expression<String>? modifiedAt,
    Expression<String>? indexedAt,
    Expression<String>? folderUri,
    Expression<String>? mimeType,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (fileKey != null) 'fileKey': fileKey,
      if (source != null) 'source': source,
      if (fileType != null) 'fileType': fileType,
      if (size != null) 'size': size,
      if (modifiedAt != null) 'modifiedAt': modifiedAt,
      if (indexedAt != null) 'indexedAt': indexedAt,
      if (folderUri != null) 'folderUri': folderUri,
      if (mimeType != null) 'mimeType': mimeType,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FileIndexEntriesCompanion copyWith({
    Value<String>? fileKey,
    Value<String>? source,
    Value<String>? fileType,
    Value<int>? size,
    Value<String>? modifiedAt,
    Value<String>? indexedAt,
    Value<String?>? folderUri,
    Value<String?>? mimeType,
    Value<int>? rowid,
  }) {
    return FileIndexEntriesCompanion(
      fileKey: fileKey ?? this.fileKey,
      source: source ?? this.source,
      fileType: fileType ?? this.fileType,
      size: size ?? this.size,
      modifiedAt: modifiedAt ?? this.modifiedAt,
      indexedAt: indexedAt ?? this.indexedAt,
      folderUri: folderUri ?? this.folderUri,
      mimeType: mimeType ?? this.mimeType,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (fileKey.present) {
      map['fileKey'] = Variable<String>(fileKey.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (fileType.present) {
      map['fileType'] = Variable<String>(fileType.value);
    }
    if (size.present) {
      map['size'] = Variable<int>(size.value);
    }
    if (modifiedAt.present) {
      map['modifiedAt'] = Variable<String>(modifiedAt.value);
    }
    if (indexedAt.present) {
      map['indexedAt'] = Variable<String>(indexedAt.value);
    }
    if (folderUri.present) {
      map['folderUri'] = Variable<String>(folderUri.value);
    }
    if (mimeType.present) {
      map['mimeType'] = Variable<String>(mimeType.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FileIndexEntriesCompanion(')
          ..write('fileKey: $fileKey, ')
          ..write('source: $source, ')
          ..write('fileType: $fileType, ')
          ..write('size: $size, ')
          ..write('modifiedAt: $modifiedAt, ')
          ..write('indexedAt: $indexedAt, ')
          ..write('folderUri: $folderUri, ')
          ..write('mimeType: $mimeType, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DismissedReviewGroupsTable extends DismissedReviewGroups
    with TableInfo<$DismissedReviewGroupsTable, DismissedReviewGroupRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DismissedReviewGroupsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _groupKeyMeta = const VerificationMeta(
    'groupKey',
  );
  @override
  late final GeneratedColumn<String> groupKey = GeneratedColumn<String>(
    'groupKey',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _modeMeta = const VerificationMeta('mode');
  @override
  late final GeneratedColumn<String> mode = GeneratedColumn<String>(
    'mode',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dismissedAtMeta = const VerificationMeta(
    'dismissedAt',
  );
  @override
  late final GeneratedColumn<String> dismissedAt = GeneratedColumn<String>(
    'dismissedAt',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [groupKey, mode, dismissedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'dismissed_review_groups';
  @override
  VerificationContext validateIntegrity(
    Insertable<DismissedReviewGroupRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('groupKey')) {
      context.handle(
        _groupKeyMeta,
        groupKey.isAcceptableOrUnknown(data['groupKey']!, _groupKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_groupKeyMeta);
    }
    if (data.containsKey('mode')) {
      context.handle(
        _modeMeta,
        mode.isAcceptableOrUnknown(data['mode']!, _modeMeta),
      );
    } else if (isInserting) {
      context.missing(_modeMeta);
    }
    if (data.containsKey('dismissedAt')) {
      context.handle(
        _dismissedAtMeta,
        dismissedAt.isAcceptableOrUnknown(
          data['dismissedAt']!,
          _dismissedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_dismissedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {groupKey};
  @override
  DismissedReviewGroupRow map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DismissedReviewGroupRow(
      groupKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}groupKey'],
      )!,
      mode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mode'],
      )!,
      dismissedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}dismissedAt'],
      )!,
    );
  }

  @override
  $DismissedReviewGroupsTable createAlias(String alias) {
    return $DismissedReviewGroupsTable(attachedDatabase, alias);
  }
}

class DismissedReviewGroupRow extends DataClass
    implements Insertable<DismissedReviewGroupRow> {
  final String groupKey;
  final String mode;
  final String dismissedAt;
  const DismissedReviewGroupRow({
    required this.groupKey,
    required this.mode,
    required this.dismissedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['groupKey'] = Variable<String>(groupKey);
    map['mode'] = Variable<String>(mode);
    map['dismissedAt'] = Variable<String>(dismissedAt);
    return map;
  }

  DismissedReviewGroupsCompanion toCompanion(bool nullToAbsent) {
    return DismissedReviewGroupsCompanion(
      groupKey: Value(groupKey),
      mode: Value(mode),
      dismissedAt: Value(dismissedAt),
    );
  }

  factory DismissedReviewGroupRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DismissedReviewGroupRow(
      groupKey: serializer.fromJson<String>(json['groupKey']),
      mode: serializer.fromJson<String>(json['mode']),
      dismissedAt: serializer.fromJson<String>(json['dismissedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'groupKey': serializer.toJson<String>(groupKey),
      'mode': serializer.toJson<String>(mode),
      'dismissedAt': serializer.toJson<String>(dismissedAt),
    };
  }

  DismissedReviewGroupRow copyWith({
    String? groupKey,
    String? mode,
    String? dismissedAt,
  }) => DismissedReviewGroupRow(
    groupKey: groupKey ?? this.groupKey,
    mode: mode ?? this.mode,
    dismissedAt: dismissedAt ?? this.dismissedAt,
  );
  DismissedReviewGroupRow copyWithCompanion(
    DismissedReviewGroupsCompanion data,
  ) {
    return DismissedReviewGroupRow(
      groupKey: data.groupKey.present ? data.groupKey.value : this.groupKey,
      mode: data.mode.present ? data.mode.value : this.mode,
      dismissedAt: data.dismissedAt.present
          ? data.dismissedAt.value
          : this.dismissedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DismissedReviewGroupRow(')
          ..write('groupKey: $groupKey, ')
          ..write('mode: $mode, ')
          ..write('dismissedAt: $dismissedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(groupKey, mode, dismissedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DismissedReviewGroupRow &&
          other.groupKey == this.groupKey &&
          other.mode == this.mode &&
          other.dismissedAt == this.dismissedAt);
}

class DismissedReviewGroupsCompanion
    extends UpdateCompanion<DismissedReviewGroupRow> {
  final Value<String> groupKey;
  final Value<String> mode;
  final Value<String> dismissedAt;
  final Value<int> rowid;
  const DismissedReviewGroupsCompanion({
    this.groupKey = const Value.absent(),
    this.mode = const Value.absent(),
    this.dismissedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DismissedReviewGroupsCompanion.insert({
    required String groupKey,
    required String mode,
    required String dismissedAt,
    this.rowid = const Value.absent(),
  }) : groupKey = Value(groupKey),
       mode = Value(mode),
       dismissedAt = Value(dismissedAt);
  static Insertable<DismissedReviewGroupRow> custom({
    Expression<String>? groupKey,
    Expression<String>? mode,
    Expression<String>? dismissedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (groupKey != null) 'groupKey': groupKey,
      if (mode != null) 'mode': mode,
      if (dismissedAt != null) 'dismissedAt': dismissedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DismissedReviewGroupsCompanion copyWith({
    Value<String>? groupKey,
    Value<String>? mode,
    Value<String>? dismissedAt,
    Value<int>? rowid,
  }) {
    return DismissedReviewGroupsCompanion(
      groupKey: groupKey ?? this.groupKey,
      mode: mode ?? this.mode,
      dismissedAt: dismissedAt ?? this.dismissedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (groupKey.present) {
      map['groupKey'] = Variable<String>(groupKey.value);
    }
    if (mode.present) {
      map['mode'] = Variable<String>(mode.value);
    }
    if (dismissedAt.present) {
      map['dismissedAt'] = Variable<String>(dismissedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DismissedReviewGroupsCompanion(')
          ..write('groupKey: $groupKey, ')
          ..write('mode: $mode, ')
          ..write('dismissedAt: $dismissedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$EpuraDatabase extends GeneratedDatabase {
  _$EpuraDatabase(QueryExecutor e) : super(e);
  $EpuraDatabaseManager get managers => $EpuraDatabaseManager(this);
  late final $ReviewSessionsTable reviewSessions = $ReviewSessionsTable(this);
  late final $ReviewDecisionsTable reviewDecisions = $ReviewDecisionsTable(
    this,
  );
  late final $FileIndexEntriesTable fileIndexEntries = $FileIndexEntriesTable(
    this,
  );
  late final $DismissedReviewGroupsTable dismissedReviewGroups =
      $DismissedReviewGroupsTable(this);
  late final Index idxReviewDecisionsDecision = Index(
    'idx_review_decisions_decision',
    'CREATE INDEX idx_review_decisions_decision ON review_decisions (decision)',
  );
  late final Index idxFileIndexFolder = Index(
    'idx_file_index_folder',
    'CREATE INDEX idx_file_index_folder ON file_index (folderUri)',
  );
  late final Index idxDismissedReviewGroupsMode = Index(
    'idx_dismissed_review_groups_mode',
    'CREATE INDEX idx_dismissed_review_groups_mode ON dismissed_review_groups (mode)',
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    reviewSessions,
    reviewDecisions,
    fileIndexEntries,
    dismissedReviewGroups,
    idxReviewDecisionsDecision,
    idxFileIndexFolder,
    idxDismissedReviewGroupsMode,
  ];
}

typedef $$ReviewSessionsTableCreateCompanionBuilder =
    ReviewSessionsCompanion Function({
      Value<int> id,
      required String date,
      required int keptCount,
      required int deletedCount,
      required int skippedCount,
      required int bytesFreed,
    });
typedef $$ReviewSessionsTableUpdateCompanionBuilder =
    ReviewSessionsCompanion Function({
      Value<int> id,
      Value<String> date,
      Value<int> keptCount,
      Value<int> deletedCount,
      Value<int> skippedCount,
      Value<int> bytesFreed,
    });

class $$ReviewSessionsTableFilterComposer
    extends Composer<_$EpuraDatabase, $ReviewSessionsTable> {
  $$ReviewSessionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get keptCount => $composableBuilder(
    column: $table.keptCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deletedCount => $composableBuilder(
    column: $table.deletedCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get skippedCount => $composableBuilder(
    column: $table.skippedCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get bytesFreed => $composableBuilder(
    column: $table.bytesFreed,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ReviewSessionsTableOrderingComposer
    extends Composer<_$EpuraDatabase, $ReviewSessionsTable> {
  $$ReviewSessionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get keptCount => $composableBuilder(
    column: $table.keptCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deletedCount => $composableBuilder(
    column: $table.deletedCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get skippedCount => $composableBuilder(
    column: $table.skippedCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get bytesFreed => $composableBuilder(
    column: $table.bytesFreed,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ReviewSessionsTableAnnotationComposer
    extends Composer<_$EpuraDatabase, $ReviewSessionsTable> {
  $$ReviewSessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<int> get keptCount =>
      $composableBuilder(column: $table.keptCount, builder: (column) => column);

  GeneratedColumn<int> get deletedCount => $composableBuilder(
    column: $table.deletedCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get skippedCount => $composableBuilder(
    column: $table.skippedCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get bytesFreed => $composableBuilder(
    column: $table.bytesFreed,
    builder: (column) => column,
  );
}

class $$ReviewSessionsTableTableManager
    extends
        RootTableManager<
          _$EpuraDatabase,
          $ReviewSessionsTable,
          ReviewSessionRow,
          $$ReviewSessionsTableFilterComposer,
          $$ReviewSessionsTableOrderingComposer,
          $$ReviewSessionsTableAnnotationComposer,
          $$ReviewSessionsTableCreateCompanionBuilder,
          $$ReviewSessionsTableUpdateCompanionBuilder,
          (
            ReviewSessionRow,
            BaseReferences<
              _$EpuraDatabase,
              $ReviewSessionsTable,
              ReviewSessionRow
            >,
          ),
          ReviewSessionRow,
          PrefetchHooks Function()
        > {
  $$ReviewSessionsTableTableManager(
    _$EpuraDatabase db,
    $ReviewSessionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ReviewSessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ReviewSessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ReviewSessionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> date = const Value.absent(),
                Value<int> keptCount = const Value.absent(),
                Value<int> deletedCount = const Value.absent(),
                Value<int> skippedCount = const Value.absent(),
                Value<int> bytesFreed = const Value.absent(),
              }) => ReviewSessionsCompanion(
                id: id,
                date: date,
                keptCount: keptCount,
                deletedCount: deletedCount,
                skippedCount: skippedCount,
                bytesFreed: bytesFreed,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String date,
                required int keptCount,
                required int deletedCount,
                required int skippedCount,
                required int bytesFreed,
              }) => ReviewSessionsCompanion.insert(
                id: id,
                date: date,
                keptCount: keptCount,
                deletedCount: deletedCount,
                skippedCount: skippedCount,
                bytesFreed: bytesFreed,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ReviewSessionsTableProcessedTableManager =
    ProcessedTableManager<
      _$EpuraDatabase,
      $ReviewSessionsTable,
      ReviewSessionRow,
      $$ReviewSessionsTableFilterComposer,
      $$ReviewSessionsTableOrderingComposer,
      $$ReviewSessionsTableAnnotationComposer,
      $$ReviewSessionsTableCreateCompanionBuilder,
      $$ReviewSessionsTableUpdateCompanionBuilder,
      (
        ReviewSessionRow,
        BaseReferences<_$EpuraDatabase, $ReviewSessionsTable, ReviewSessionRow>,
      ),
      ReviewSessionRow,
      PrefetchHooks Function()
    >;
typedef $$ReviewDecisionsTableCreateCompanionBuilder =
    ReviewDecisionsCompanion Function({
      required String fileKey,
      required String decision,
      required String decidedAt,
      Value<int> rowid,
    });
typedef $$ReviewDecisionsTableUpdateCompanionBuilder =
    ReviewDecisionsCompanion Function({
      Value<String> fileKey,
      Value<String> decision,
      Value<String> decidedAt,
      Value<int> rowid,
    });

class $$ReviewDecisionsTableFilterComposer
    extends Composer<_$EpuraDatabase, $ReviewDecisionsTable> {
  $$ReviewDecisionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get fileKey => $composableBuilder(
    column: $table.fileKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get decision => $composableBuilder(
    column: $table.decision,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get decidedAt => $composableBuilder(
    column: $table.decidedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ReviewDecisionsTableOrderingComposer
    extends Composer<_$EpuraDatabase, $ReviewDecisionsTable> {
  $$ReviewDecisionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get fileKey => $composableBuilder(
    column: $table.fileKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get decision => $composableBuilder(
    column: $table.decision,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get decidedAt => $composableBuilder(
    column: $table.decidedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ReviewDecisionsTableAnnotationComposer
    extends Composer<_$EpuraDatabase, $ReviewDecisionsTable> {
  $$ReviewDecisionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get fileKey =>
      $composableBuilder(column: $table.fileKey, builder: (column) => column);

  GeneratedColumn<String> get decision =>
      $composableBuilder(column: $table.decision, builder: (column) => column);

  GeneratedColumn<String> get decidedAt =>
      $composableBuilder(column: $table.decidedAt, builder: (column) => column);
}

class $$ReviewDecisionsTableTableManager
    extends
        RootTableManager<
          _$EpuraDatabase,
          $ReviewDecisionsTable,
          ReviewDecisionRow,
          $$ReviewDecisionsTableFilterComposer,
          $$ReviewDecisionsTableOrderingComposer,
          $$ReviewDecisionsTableAnnotationComposer,
          $$ReviewDecisionsTableCreateCompanionBuilder,
          $$ReviewDecisionsTableUpdateCompanionBuilder,
          (
            ReviewDecisionRow,
            BaseReferences<
              _$EpuraDatabase,
              $ReviewDecisionsTable,
              ReviewDecisionRow
            >,
          ),
          ReviewDecisionRow,
          PrefetchHooks Function()
        > {
  $$ReviewDecisionsTableTableManager(
    _$EpuraDatabase db,
    $ReviewDecisionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ReviewDecisionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ReviewDecisionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ReviewDecisionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> fileKey = const Value.absent(),
                Value<String> decision = const Value.absent(),
                Value<String> decidedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ReviewDecisionsCompanion(
                fileKey: fileKey,
                decision: decision,
                decidedAt: decidedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String fileKey,
                required String decision,
                required String decidedAt,
                Value<int> rowid = const Value.absent(),
              }) => ReviewDecisionsCompanion.insert(
                fileKey: fileKey,
                decision: decision,
                decidedAt: decidedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ReviewDecisionsTableProcessedTableManager =
    ProcessedTableManager<
      _$EpuraDatabase,
      $ReviewDecisionsTable,
      ReviewDecisionRow,
      $$ReviewDecisionsTableFilterComposer,
      $$ReviewDecisionsTableOrderingComposer,
      $$ReviewDecisionsTableAnnotationComposer,
      $$ReviewDecisionsTableCreateCompanionBuilder,
      $$ReviewDecisionsTableUpdateCompanionBuilder,
      (
        ReviewDecisionRow,
        BaseReferences<
          _$EpuraDatabase,
          $ReviewDecisionsTable,
          ReviewDecisionRow
        >,
      ),
      ReviewDecisionRow,
      PrefetchHooks Function()
    >;
typedef $$FileIndexEntriesTableCreateCompanionBuilder =
    FileIndexEntriesCompanion Function({
      required String fileKey,
      required String source,
      required String fileType,
      required int size,
      required String modifiedAt,
      required String indexedAt,
      Value<String?> folderUri,
      Value<String?> mimeType,
      Value<int> rowid,
    });
typedef $$FileIndexEntriesTableUpdateCompanionBuilder =
    FileIndexEntriesCompanion Function({
      Value<String> fileKey,
      Value<String> source,
      Value<String> fileType,
      Value<int> size,
      Value<String> modifiedAt,
      Value<String> indexedAt,
      Value<String?> folderUri,
      Value<String?> mimeType,
      Value<int> rowid,
    });

class $$FileIndexEntriesTableFilterComposer
    extends Composer<_$EpuraDatabase, $FileIndexEntriesTable> {
  $$FileIndexEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get fileKey => $composableBuilder(
    column: $table.fileKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fileType => $composableBuilder(
    column: $table.fileType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get size => $composableBuilder(
    column: $table.size,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get modifiedAt => $composableBuilder(
    column: $table.modifiedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get indexedAt => $composableBuilder(
    column: $table.indexedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get folderUri => $composableBuilder(
    column: $table.folderUri,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mimeType => $composableBuilder(
    column: $table.mimeType,
    builder: (column) => ColumnFilters(column),
  );
}

class $$FileIndexEntriesTableOrderingComposer
    extends Composer<_$EpuraDatabase, $FileIndexEntriesTable> {
  $$FileIndexEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get fileKey => $composableBuilder(
    column: $table.fileKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fileType => $composableBuilder(
    column: $table.fileType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get size => $composableBuilder(
    column: $table.size,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get modifiedAt => $composableBuilder(
    column: $table.modifiedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get indexedAt => $composableBuilder(
    column: $table.indexedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get folderUri => $composableBuilder(
    column: $table.folderUri,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mimeType => $composableBuilder(
    column: $table.mimeType,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FileIndexEntriesTableAnnotationComposer
    extends Composer<_$EpuraDatabase, $FileIndexEntriesTable> {
  $$FileIndexEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get fileKey =>
      $composableBuilder(column: $table.fileKey, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<String> get fileType =>
      $composableBuilder(column: $table.fileType, builder: (column) => column);

  GeneratedColumn<int> get size =>
      $composableBuilder(column: $table.size, builder: (column) => column);

  GeneratedColumn<String> get modifiedAt => $composableBuilder(
    column: $table.modifiedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get indexedAt =>
      $composableBuilder(column: $table.indexedAt, builder: (column) => column);

  GeneratedColumn<String> get folderUri =>
      $composableBuilder(column: $table.folderUri, builder: (column) => column);

  GeneratedColumn<String> get mimeType =>
      $composableBuilder(column: $table.mimeType, builder: (column) => column);
}

class $$FileIndexEntriesTableTableManager
    extends
        RootTableManager<
          _$EpuraDatabase,
          $FileIndexEntriesTable,
          IndexedFileRow,
          $$FileIndexEntriesTableFilterComposer,
          $$FileIndexEntriesTableOrderingComposer,
          $$FileIndexEntriesTableAnnotationComposer,
          $$FileIndexEntriesTableCreateCompanionBuilder,
          $$FileIndexEntriesTableUpdateCompanionBuilder,
          (
            IndexedFileRow,
            BaseReferences<
              _$EpuraDatabase,
              $FileIndexEntriesTable,
              IndexedFileRow
            >,
          ),
          IndexedFileRow,
          PrefetchHooks Function()
        > {
  $$FileIndexEntriesTableTableManager(
    _$EpuraDatabase db,
    $FileIndexEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FileIndexEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FileIndexEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FileIndexEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> fileKey = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<String> fileType = const Value.absent(),
                Value<int> size = const Value.absent(),
                Value<String> modifiedAt = const Value.absent(),
                Value<String> indexedAt = const Value.absent(),
                Value<String?> folderUri = const Value.absent(),
                Value<String?> mimeType = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FileIndexEntriesCompanion(
                fileKey: fileKey,
                source: source,
                fileType: fileType,
                size: size,
                modifiedAt: modifiedAt,
                indexedAt: indexedAt,
                folderUri: folderUri,
                mimeType: mimeType,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String fileKey,
                required String source,
                required String fileType,
                required int size,
                required String modifiedAt,
                required String indexedAt,
                Value<String?> folderUri = const Value.absent(),
                Value<String?> mimeType = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FileIndexEntriesCompanion.insert(
                fileKey: fileKey,
                source: source,
                fileType: fileType,
                size: size,
                modifiedAt: modifiedAt,
                indexedAt: indexedAt,
                folderUri: folderUri,
                mimeType: mimeType,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$FileIndexEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$EpuraDatabase,
      $FileIndexEntriesTable,
      IndexedFileRow,
      $$FileIndexEntriesTableFilterComposer,
      $$FileIndexEntriesTableOrderingComposer,
      $$FileIndexEntriesTableAnnotationComposer,
      $$FileIndexEntriesTableCreateCompanionBuilder,
      $$FileIndexEntriesTableUpdateCompanionBuilder,
      (
        IndexedFileRow,
        BaseReferences<_$EpuraDatabase, $FileIndexEntriesTable, IndexedFileRow>,
      ),
      IndexedFileRow,
      PrefetchHooks Function()
    >;
typedef $$DismissedReviewGroupsTableCreateCompanionBuilder =
    DismissedReviewGroupsCompanion Function({
      required String groupKey,
      required String mode,
      required String dismissedAt,
      Value<int> rowid,
    });
typedef $$DismissedReviewGroupsTableUpdateCompanionBuilder =
    DismissedReviewGroupsCompanion Function({
      Value<String> groupKey,
      Value<String> mode,
      Value<String> dismissedAt,
      Value<int> rowid,
    });

class $$DismissedReviewGroupsTableFilterComposer
    extends Composer<_$EpuraDatabase, $DismissedReviewGroupsTable> {
  $$DismissedReviewGroupsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get groupKey => $composableBuilder(
    column: $table.groupKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mode => $composableBuilder(
    column: $table.mode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dismissedAt => $composableBuilder(
    column: $table.dismissedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DismissedReviewGroupsTableOrderingComposer
    extends Composer<_$EpuraDatabase, $DismissedReviewGroupsTable> {
  $$DismissedReviewGroupsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get groupKey => $composableBuilder(
    column: $table.groupKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mode => $composableBuilder(
    column: $table.mode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dismissedAt => $composableBuilder(
    column: $table.dismissedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DismissedReviewGroupsTableAnnotationComposer
    extends Composer<_$EpuraDatabase, $DismissedReviewGroupsTable> {
  $$DismissedReviewGroupsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get groupKey =>
      $composableBuilder(column: $table.groupKey, builder: (column) => column);

  GeneratedColumn<String> get mode =>
      $composableBuilder(column: $table.mode, builder: (column) => column);

  GeneratedColumn<String> get dismissedAt => $composableBuilder(
    column: $table.dismissedAt,
    builder: (column) => column,
  );
}

class $$DismissedReviewGroupsTableTableManager
    extends
        RootTableManager<
          _$EpuraDatabase,
          $DismissedReviewGroupsTable,
          DismissedReviewGroupRow,
          $$DismissedReviewGroupsTableFilterComposer,
          $$DismissedReviewGroupsTableOrderingComposer,
          $$DismissedReviewGroupsTableAnnotationComposer,
          $$DismissedReviewGroupsTableCreateCompanionBuilder,
          $$DismissedReviewGroupsTableUpdateCompanionBuilder,
          (
            DismissedReviewGroupRow,
            BaseReferences<
              _$EpuraDatabase,
              $DismissedReviewGroupsTable,
              DismissedReviewGroupRow
            >,
          ),
          DismissedReviewGroupRow,
          PrefetchHooks Function()
        > {
  $$DismissedReviewGroupsTableTableManager(
    _$EpuraDatabase db,
    $DismissedReviewGroupsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DismissedReviewGroupsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$DismissedReviewGroupsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$DismissedReviewGroupsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> groupKey = const Value.absent(),
                Value<String> mode = const Value.absent(),
                Value<String> dismissedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DismissedReviewGroupsCompanion(
                groupKey: groupKey,
                mode: mode,
                dismissedAt: dismissedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String groupKey,
                required String mode,
                required String dismissedAt,
                Value<int> rowid = const Value.absent(),
              }) => DismissedReviewGroupsCompanion.insert(
                groupKey: groupKey,
                mode: mode,
                dismissedAt: dismissedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DismissedReviewGroupsTableProcessedTableManager =
    ProcessedTableManager<
      _$EpuraDatabase,
      $DismissedReviewGroupsTable,
      DismissedReviewGroupRow,
      $$DismissedReviewGroupsTableFilterComposer,
      $$DismissedReviewGroupsTableOrderingComposer,
      $$DismissedReviewGroupsTableAnnotationComposer,
      $$DismissedReviewGroupsTableCreateCompanionBuilder,
      $$DismissedReviewGroupsTableUpdateCompanionBuilder,
      (
        DismissedReviewGroupRow,
        BaseReferences<
          _$EpuraDatabase,
          $DismissedReviewGroupsTable,
          DismissedReviewGroupRow
        >,
      ),
      DismissedReviewGroupRow,
      PrefetchHooks Function()
    >;

class $EpuraDatabaseManager {
  final _$EpuraDatabase _db;
  $EpuraDatabaseManager(this._db);
  $$ReviewSessionsTableTableManager get reviewSessions =>
      $$ReviewSessionsTableTableManager(_db, _db.reviewSessions);
  $$ReviewDecisionsTableTableManager get reviewDecisions =>
      $$ReviewDecisionsTableTableManager(_db, _db.reviewDecisions);
  $$FileIndexEntriesTableTableManager get fileIndexEntries =>
      $$FileIndexEntriesTableTableManager(_db, _db.fileIndexEntries);
  $$DismissedReviewGroupsTableTableManager get dismissedReviewGroups =>
      $$DismissedReviewGroupsTableTableManager(_db, _db.dismissedReviewGroups);
}
