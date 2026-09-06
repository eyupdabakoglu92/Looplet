// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $PlayersTable extends Players with TableInfo<$PlayersTable, Player> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlayersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _guestIdMeta = const VerificationMeta(
    'guestId',
  );
  @override
  late final GeneratedColumn<String> guestId = GeneratedColumn<String>(
    'guest_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _firebaseUidMeta = const VerificationMeta(
    'firebaseUid',
  );
  @override
  late final GeneratedColumn<String> firebaseUid = GeneratedColumn<String>(
    'firebase_uid',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtUtcMsMeta = const VerificationMeta(
    'createdAtUtcMs',
  );
  @override
  late final GeneratedColumn<int> createdAtUtcMs = GeneratedColumn<int>(
    'created_at_utc_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [guestId, firebaseUid, createdAtUtcMs];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'player';
  @override
  VerificationContext validateIntegrity(
    Insertable<Player> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('guest_id')) {
      context.handle(
        _guestIdMeta,
        guestId.isAcceptableOrUnknown(data['guest_id']!, _guestIdMeta),
      );
    } else if (isInserting) {
      context.missing(_guestIdMeta);
    }
    if (data.containsKey('firebase_uid')) {
      context.handle(
        _firebaseUidMeta,
        firebaseUid.isAcceptableOrUnknown(
          data['firebase_uid']!,
          _firebaseUidMeta,
        ),
      );
    }
    if (data.containsKey('created_at_utc_ms')) {
      context.handle(
        _createdAtUtcMsMeta,
        createdAtUtcMs.isAcceptableOrUnknown(
          data['created_at_utc_ms']!,
          _createdAtUtcMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_createdAtUtcMsMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {guestId};
  @override
  Player map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Player(
      guestId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}guest_id'],
      )!,
      firebaseUid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}firebase_uid'],
      ),
      createdAtUtcMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at_utc_ms'],
      )!,
    );
  }

  @override
  $PlayersTable createAlias(String alias) {
    return $PlayersTable(attachedDatabase, alias);
  }
}

class Player extends DataClass implements Insertable<Player> {
  final String guestId;
  final String? firebaseUid;
  final int createdAtUtcMs;
  const Player({
    required this.guestId,
    this.firebaseUid,
    required this.createdAtUtcMs,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['guest_id'] = Variable<String>(guestId);
    if (!nullToAbsent || firebaseUid != null) {
      map['firebase_uid'] = Variable<String>(firebaseUid);
    }
    map['created_at_utc_ms'] = Variable<int>(createdAtUtcMs);
    return map;
  }

  PlayersCompanion toCompanion(bool nullToAbsent) {
    return PlayersCompanion(
      guestId: Value(guestId),
      firebaseUid: firebaseUid == null && nullToAbsent
          ? const Value.absent()
          : Value(firebaseUid),
      createdAtUtcMs: Value(createdAtUtcMs),
    );
  }

  factory Player.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Player(
      guestId: serializer.fromJson<String>(json['guestId']),
      firebaseUid: serializer.fromJson<String?>(json['firebaseUid']),
      createdAtUtcMs: serializer.fromJson<int>(json['createdAtUtcMs']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'guestId': serializer.toJson<String>(guestId),
      'firebaseUid': serializer.toJson<String?>(firebaseUid),
      'createdAtUtcMs': serializer.toJson<int>(createdAtUtcMs),
    };
  }

  Player copyWith({
    String? guestId,
    Value<String?> firebaseUid = const Value.absent(),
    int? createdAtUtcMs,
  }) => Player(
    guestId: guestId ?? this.guestId,
    firebaseUid: firebaseUid.present ? firebaseUid.value : this.firebaseUid,
    createdAtUtcMs: createdAtUtcMs ?? this.createdAtUtcMs,
  );
  Player copyWithCompanion(PlayersCompanion data) {
    return Player(
      guestId: data.guestId.present ? data.guestId.value : this.guestId,
      firebaseUid: data.firebaseUid.present
          ? data.firebaseUid.value
          : this.firebaseUid,
      createdAtUtcMs: data.createdAtUtcMs.present
          ? data.createdAtUtcMs.value
          : this.createdAtUtcMs,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Player(')
          ..write('guestId: $guestId, ')
          ..write('firebaseUid: $firebaseUid, ')
          ..write('createdAtUtcMs: $createdAtUtcMs')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(guestId, firebaseUid, createdAtUtcMs);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Player &&
          other.guestId == this.guestId &&
          other.firebaseUid == this.firebaseUid &&
          other.createdAtUtcMs == this.createdAtUtcMs);
}

class PlayersCompanion extends UpdateCompanion<Player> {
  final Value<String> guestId;
  final Value<String?> firebaseUid;
  final Value<int> createdAtUtcMs;
  final Value<int> rowid;
  const PlayersCompanion({
    this.guestId = const Value.absent(),
    this.firebaseUid = const Value.absent(),
    this.createdAtUtcMs = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PlayersCompanion.insert({
    required String guestId,
    this.firebaseUid = const Value.absent(),
    required int createdAtUtcMs,
    this.rowid = const Value.absent(),
  }) : guestId = Value(guestId),
       createdAtUtcMs = Value(createdAtUtcMs);
  static Insertable<Player> custom({
    Expression<String>? guestId,
    Expression<String>? firebaseUid,
    Expression<int>? createdAtUtcMs,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (guestId != null) 'guest_id': guestId,
      if (firebaseUid != null) 'firebase_uid': firebaseUid,
      if (createdAtUtcMs != null) 'created_at_utc_ms': createdAtUtcMs,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PlayersCompanion copyWith({
    Value<String>? guestId,
    Value<String?>? firebaseUid,
    Value<int>? createdAtUtcMs,
    Value<int>? rowid,
  }) {
    return PlayersCompanion(
      guestId: guestId ?? this.guestId,
      firebaseUid: firebaseUid ?? this.firebaseUid,
      createdAtUtcMs: createdAtUtcMs ?? this.createdAtUtcMs,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (guestId.present) {
      map['guest_id'] = Variable<String>(guestId.value);
    }
    if (firebaseUid.present) {
      map['firebase_uid'] = Variable<String>(firebaseUid.value);
    }
    if (createdAtUtcMs.present) {
      map['created_at_utc_ms'] = Variable<int>(createdAtUtcMs.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlayersCompanion(')
          ..write('guestId: $guestId, ')
          ..write('firebaseUid: $firebaseUid, ')
          ..write('createdAtUtcMs: $createdAtUtcMs, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SettingsRowsTable extends SettingsRows
    with TableInfo<$SettingsRowsTable, SettingsRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SettingsRowsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _guestIdMeta = const VerificationMeta(
    'guestId',
  );
  @override
  late final GeneratedColumn<String> guestId = GeneratedColumn<String>(
    'guest_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _soundEnabledMeta = const VerificationMeta(
    'soundEnabled',
  );
  @override
  late final GeneratedColumn<bool> soundEnabled = GeneratedColumn<bool>(
    'sound_enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("sound_enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _hapticsEnabledMeta = const VerificationMeta(
    'hapticsEnabled',
  );
  @override
  late final GeneratedColumn<bool> hapticsEnabled = GeneratedColumn<bool>(
    'haptics_enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("haptics_enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _languageMeta = const VerificationMeta(
    'language',
  );
  @override
  late final GeneratedColumn<String> language = GeneratedColumn<String>(
    'language',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('tr'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    guestId,
    soundEnabled,
    hapticsEnabled,
    language,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<SettingsRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('guest_id')) {
      context.handle(
        _guestIdMeta,
        guestId.isAcceptableOrUnknown(data['guest_id']!, _guestIdMeta),
      );
    } else if (isInserting) {
      context.missing(_guestIdMeta);
    }
    if (data.containsKey('sound_enabled')) {
      context.handle(
        _soundEnabledMeta,
        soundEnabled.isAcceptableOrUnknown(
          data['sound_enabled']!,
          _soundEnabledMeta,
        ),
      );
    }
    if (data.containsKey('haptics_enabled')) {
      context.handle(
        _hapticsEnabledMeta,
        hapticsEnabled.isAcceptableOrUnknown(
          data['haptics_enabled']!,
          _hapticsEnabledMeta,
        ),
      );
    }
    if (data.containsKey('language')) {
      context.handle(
        _languageMeta,
        language.isAcceptableOrUnknown(data['language']!, _languageMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {guestId};
  @override
  SettingsRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SettingsRow(
      guestId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}guest_id'],
      )!,
      soundEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}sound_enabled'],
      )!,
      hapticsEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}haptics_enabled'],
      )!,
      language: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}language'],
      )!,
    );
  }

  @override
  $SettingsRowsTable createAlias(String alias) {
    return $SettingsRowsTable(attachedDatabase, alias);
  }
}

class SettingsRow extends DataClass implements Insertable<SettingsRow> {
  final String guestId;
  final bool soundEnabled;
  final bool hapticsEnabled;
  final String language;
  const SettingsRow({
    required this.guestId,
    required this.soundEnabled,
    required this.hapticsEnabled,
    required this.language,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['guest_id'] = Variable<String>(guestId);
    map['sound_enabled'] = Variable<bool>(soundEnabled);
    map['haptics_enabled'] = Variable<bool>(hapticsEnabled);
    map['language'] = Variable<String>(language);
    return map;
  }

  SettingsRowsCompanion toCompanion(bool nullToAbsent) {
    return SettingsRowsCompanion(
      guestId: Value(guestId),
      soundEnabled: Value(soundEnabled),
      hapticsEnabled: Value(hapticsEnabled),
      language: Value(language),
    );
  }

  factory SettingsRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SettingsRow(
      guestId: serializer.fromJson<String>(json['guestId']),
      soundEnabled: serializer.fromJson<bool>(json['soundEnabled']),
      hapticsEnabled: serializer.fromJson<bool>(json['hapticsEnabled']),
      language: serializer.fromJson<String>(json['language']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'guestId': serializer.toJson<String>(guestId),
      'soundEnabled': serializer.toJson<bool>(soundEnabled),
      'hapticsEnabled': serializer.toJson<bool>(hapticsEnabled),
      'language': serializer.toJson<String>(language),
    };
  }

  SettingsRow copyWith({
    String? guestId,
    bool? soundEnabled,
    bool? hapticsEnabled,
    String? language,
  }) => SettingsRow(
    guestId: guestId ?? this.guestId,
    soundEnabled: soundEnabled ?? this.soundEnabled,
    hapticsEnabled: hapticsEnabled ?? this.hapticsEnabled,
    language: language ?? this.language,
  );
  SettingsRow copyWithCompanion(SettingsRowsCompanion data) {
    return SettingsRow(
      guestId: data.guestId.present ? data.guestId.value : this.guestId,
      soundEnabled: data.soundEnabled.present
          ? data.soundEnabled.value
          : this.soundEnabled,
      hapticsEnabled: data.hapticsEnabled.present
          ? data.hapticsEnabled.value
          : this.hapticsEnabled,
      language: data.language.present ? data.language.value : this.language,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SettingsRow(')
          ..write('guestId: $guestId, ')
          ..write('soundEnabled: $soundEnabled, ')
          ..write('hapticsEnabled: $hapticsEnabled, ')
          ..write('language: $language')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(guestId, soundEnabled, hapticsEnabled, language);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SettingsRow &&
          other.guestId == this.guestId &&
          other.soundEnabled == this.soundEnabled &&
          other.hapticsEnabled == this.hapticsEnabled &&
          other.language == this.language);
}

class SettingsRowsCompanion extends UpdateCompanion<SettingsRow> {
  final Value<String> guestId;
  final Value<bool> soundEnabled;
  final Value<bool> hapticsEnabled;
  final Value<String> language;
  final Value<int> rowid;
  const SettingsRowsCompanion({
    this.guestId = const Value.absent(),
    this.soundEnabled = const Value.absent(),
    this.hapticsEnabled = const Value.absent(),
    this.language = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SettingsRowsCompanion.insert({
    required String guestId,
    this.soundEnabled = const Value.absent(),
    this.hapticsEnabled = const Value.absent(),
    this.language = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : guestId = Value(guestId);
  static Insertable<SettingsRow> custom({
    Expression<String>? guestId,
    Expression<bool>? soundEnabled,
    Expression<bool>? hapticsEnabled,
    Expression<String>? language,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (guestId != null) 'guest_id': guestId,
      if (soundEnabled != null) 'sound_enabled': soundEnabled,
      if (hapticsEnabled != null) 'haptics_enabled': hapticsEnabled,
      if (language != null) 'language': language,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SettingsRowsCompanion copyWith({
    Value<String>? guestId,
    Value<bool>? soundEnabled,
    Value<bool>? hapticsEnabled,
    Value<String>? language,
    Value<int>? rowid,
  }) {
    return SettingsRowsCompanion(
      guestId: guestId ?? this.guestId,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      hapticsEnabled: hapticsEnabled ?? this.hapticsEnabled,
      language: language ?? this.language,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (guestId.present) {
      map['guest_id'] = Variable<String>(guestId.value);
    }
    if (soundEnabled.present) {
      map['sound_enabled'] = Variable<bool>(soundEnabled.value);
    }
    if (hapticsEnabled.present) {
      map['haptics_enabled'] = Variable<bool>(hapticsEnabled.value);
    }
    if (language.present) {
      map['language'] = Variable<String>(language.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SettingsRowsCompanion(')
          ..write('guestId: $guestId, ')
          ..write('soundEnabled: $soundEnabled, ')
          ..write('hapticsEnabled: $hapticsEnabled, ')
          ..write('language: $language, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $JourneyProgressRowsTable extends JourneyProgressRows
    with TableInfo<$JourneyProgressRowsTable, JourneyProgressRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $JourneyProgressRowsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _guestIdMeta = const VerificationMeta(
    'guestId',
  );
  @override
  late final GeneratedColumn<String> guestId = GeneratedColumn<String>(
    'guest_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _highestUnlockedLevelMeta =
      const VerificationMeta('highestUnlockedLevel');
  @override
  late final GeneratedColumn<int> highestUnlockedLevel = GeneratedColumn<int>(
    'highest_unlocked_level',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _completedLevelsCsvMeta =
      const VerificationMeta('completedLevelsCsv');
  @override
  late final GeneratedColumn<String> completedLevelsCsv =
      GeneratedColumn<String>(
        'completed_levels_csv',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant(''),
      );
  @override
  List<GeneratedColumn> get $columns => [
    guestId,
    highestUnlockedLevel,
    completedLevelsCsv,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'journey_progress';
  @override
  VerificationContext validateIntegrity(
    Insertable<JourneyProgressRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('guest_id')) {
      context.handle(
        _guestIdMeta,
        guestId.isAcceptableOrUnknown(data['guest_id']!, _guestIdMeta),
      );
    } else if (isInserting) {
      context.missing(_guestIdMeta);
    }
    if (data.containsKey('highest_unlocked_level')) {
      context.handle(
        _highestUnlockedLevelMeta,
        highestUnlockedLevel.isAcceptableOrUnknown(
          data['highest_unlocked_level']!,
          _highestUnlockedLevelMeta,
        ),
      );
    }
    if (data.containsKey('completed_levels_csv')) {
      context.handle(
        _completedLevelsCsvMeta,
        completedLevelsCsv.isAcceptableOrUnknown(
          data['completed_levels_csv']!,
          _completedLevelsCsvMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {guestId};
  @override
  JourneyProgressRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return JourneyProgressRow(
      guestId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}guest_id'],
      )!,
      highestUnlockedLevel: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}highest_unlocked_level'],
      )!,
      completedLevelsCsv: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}completed_levels_csv'],
      )!,
    );
  }

  @override
  $JourneyProgressRowsTable createAlias(String alias) {
    return $JourneyProgressRowsTable(attachedDatabase, alias);
  }
}

class JourneyProgressRow extends DataClass
    implements Insertable<JourneyProgressRow> {
  final String guestId;
  final int highestUnlockedLevel;
  final String completedLevelsCsv;
  const JourneyProgressRow({
    required this.guestId,
    required this.highestUnlockedLevel,
    required this.completedLevelsCsv,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['guest_id'] = Variable<String>(guestId);
    map['highest_unlocked_level'] = Variable<int>(highestUnlockedLevel);
    map['completed_levels_csv'] = Variable<String>(completedLevelsCsv);
    return map;
  }

  JourneyProgressRowsCompanion toCompanion(bool nullToAbsent) {
    return JourneyProgressRowsCompanion(
      guestId: Value(guestId),
      highestUnlockedLevel: Value(highestUnlockedLevel),
      completedLevelsCsv: Value(completedLevelsCsv),
    );
  }

  factory JourneyProgressRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return JourneyProgressRow(
      guestId: serializer.fromJson<String>(json['guestId']),
      highestUnlockedLevel: serializer.fromJson<int>(
        json['highestUnlockedLevel'],
      ),
      completedLevelsCsv: serializer.fromJson<String>(
        json['completedLevelsCsv'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'guestId': serializer.toJson<String>(guestId),
      'highestUnlockedLevel': serializer.toJson<int>(highestUnlockedLevel),
      'completedLevelsCsv': serializer.toJson<String>(completedLevelsCsv),
    };
  }

  JourneyProgressRow copyWith({
    String? guestId,
    int? highestUnlockedLevel,
    String? completedLevelsCsv,
  }) => JourneyProgressRow(
    guestId: guestId ?? this.guestId,
    highestUnlockedLevel: highestUnlockedLevel ?? this.highestUnlockedLevel,
    completedLevelsCsv: completedLevelsCsv ?? this.completedLevelsCsv,
  );
  JourneyProgressRow copyWithCompanion(JourneyProgressRowsCompanion data) {
    return JourneyProgressRow(
      guestId: data.guestId.present ? data.guestId.value : this.guestId,
      highestUnlockedLevel: data.highestUnlockedLevel.present
          ? data.highestUnlockedLevel.value
          : this.highestUnlockedLevel,
      completedLevelsCsv: data.completedLevelsCsv.present
          ? data.completedLevelsCsv.value
          : this.completedLevelsCsv,
    );
  }

  @override
  String toString() {
    return (StringBuffer('JourneyProgressRow(')
          ..write('guestId: $guestId, ')
          ..write('highestUnlockedLevel: $highestUnlockedLevel, ')
          ..write('completedLevelsCsv: $completedLevelsCsv')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(guestId, highestUnlockedLevel, completedLevelsCsv);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is JourneyProgressRow &&
          other.guestId == this.guestId &&
          other.highestUnlockedLevel == this.highestUnlockedLevel &&
          other.completedLevelsCsv == this.completedLevelsCsv);
}

class JourneyProgressRowsCompanion extends UpdateCompanion<JourneyProgressRow> {
  final Value<String> guestId;
  final Value<int> highestUnlockedLevel;
  final Value<String> completedLevelsCsv;
  final Value<int> rowid;
  const JourneyProgressRowsCompanion({
    this.guestId = const Value.absent(),
    this.highestUnlockedLevel = const Value.absent(),
    this.completedLevelsCsv = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  JourneyProgressRowsCompanion.insert({
    required String guestId,
    this.highestUnlockedLevel = const Value.absent(),
    this.completedLevelsCsv = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : guestId = Value(guestId);
  static Insertable<JourneyProgressRow> custom({
    Expression<String>? guestId,
    Expression<int>? highestUnlockedLevel,
    Expression<String>? completedLevelsCsv,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (guestId != null) 'guest_id': guestId,
      if (highestUnlockedLevel != null)
        'highest_unlocked_level': highestUnlockedLevel,
      if (completedLevelsCsv != null)
        'completed_levels_csv': completedLevelsCsv,
      if (rowid != null) 'rowid': rowid,
    });
  }

  JourneyProgressRowsCompanion copyWith({
    Value<String>? guestId,
    Value<int>? highestUnlockedLevel,
    Value<String>? completedLevelsCsv,
    Value<int>? rowid,
  }) {
    return JourneyProgressRowsCompanion(
      guestId: guestId ?? this.guestId,
      highestUnlockedLevel: highestUnlockedLevel ?? this.highestUnlockedLevel,
      completedLevelsCsv: completedLevelsCsv ?? this.completedLevelsCsv,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (guestId.present) {
      map['guest_id'] = Variable<String>(guestId.value);
    }
    if (highestUnlockedLevel.present) {
      map['highest_unlocked_level'] = Variable<int>(highestUnlockedLevel.value);
    }
    if (completedLevelsCsv.present) {
      map['completed_levels_csv'] = Variable<String>(completedLevelsCsv.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('JourneyProgressRowsCompanion(')
          ..write('guestId: $guestId, ')
          ..write('highestUnlockedLevel: $highestUnlockedLevel, ')
          ..write('completedLevelsCsv: $completedLevelsCsv, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PersonalBestsTable extends PersonalBests
    with TableInfo<$PersonalBestsTable, PersonalBest> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PersonalBestsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _guestIdMeta = const VerificationMeta(
    'guestId',
  );
  @override
  late final GeneratedColumn<String> guestId = GeneratedColumn<String>(
    'guest_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _levelIdMeta = const VerificationMeta(
    'levelId',
  );
  @override
  late final GeneratedColumn<String> levelId = GeneratedColumn<String>(
    'level_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bestMoveCountMeta = const VerificationMeta(
    'bestMoveCount',
  );
  @override
  late final GeneratedColumn<int> bestMoveCount = GeneratedColumn<int>(
    'best_move_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _starsMeta = const VerificationMeta('stars');
  @override
  late final GeneratedColumn<int> stars = GeneratedColumn<int>(
    'stars',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isPerfectMeta = const VerificationMeta(
    'isPerfect',
  );
  @override
  late final GeneratedColumn<bool> isPerfect = GeneratedColumn<bool>(
    'is_perfect',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_perfect" IN (0, 1))',
    ),
  );
  static const VerificationMeta _firstCompletedAtUtcMsMeta =
      const VerificationMeta('firstCompletedAtUtcMs');
  @override
  late final GeneratedColumn<int> firstCompletedAtUtcMs = GeneratedColumn<int>(
    'first_completed_at_utc_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    guestId,
    levelId,
    bestMoveCount,
    stars,
    isPerfect,
    firstCompletedAtUtcMs,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'personal_best';
  @override
  VerificationContext validateIntegrity(
    Insertable<PersonalBest> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('guest_id')) {
      context.handle(
        _guestIdMeta,
        guestId.isAcceptableOrUnknown(data['guest_id']!, _guestIdMeta),
      );
    } else if (isInserting) {
      context.missing(_guestIdMeta);
    }
    if (data.containsKey('level_id')) {
      context.handle(
        _levelIdMeta,
        levelId.isAcceptableOrUnknown(data['level_id']!, _levelIdMeta),
      );
    } else if (isInserting) {
      context.missing(_levelIdMeta);
    }
    if (data.containsKey('best_move_count')) {
      context.handle(
        _bestMoveCountMeta,
        bestMoveCount.isAcceptableOrUnknown(
          data['best_move_count']!,
          _bestMoveCountMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_bestMoveCountMeta);
    }
    if (data.containsKey('stars')) {
      context.handle(
        _starsMeta,
        stars.isAcceptableOrUnknown(data['stars']!, _starsMeta),
      );
    } else if (isInserting) {
      context.missing(_starsMeta);
    }
    if (data.containsKey('is_perfect')) {
      context.handle(
        _isPerfectMeta,
        isPerfect.isAcceptableOrUnknown(data['is_perfect']!, _isPerfectMeta),
      );
    } else if (isInserting) {
      context.missing(_isPerfectMeta);
    }
    if (data.containsKey('first_completed_at_utc_ms')) {
      context.handle(
        _firstCompletedAtUtcMsMeta,
        firstCompletedAtUtcMs.isAcceptableOrUnknown(
          data['first_completed_at_utc_ms']!,
          _firstCompletedAtUtcMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_firstCompletedAtUtcMsMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {guestId, levelId};
  @override
  PersonalBest map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PersonalBest(
      guestId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}guest_id'],
      )!,
      levelId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}level_id'],
      )!,
      bestMoveCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}best_move_count'],
      )!,
      stars: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}stars'],
      )!,
      isPerfect: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_perfect'],
      )!,
      firstCompletedAtUtcMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}first_completed_at_utc_ms'],
      )!,
    );
  }

  @override
  $PersonalBestsTable createAlias(String alias) {
    return $PersonalBestsTable(attachedDatabase, alias);
  }
}

class PersonalBest extends DataClass implements Insertable<PersonalBest> {
  final String guestId;
  final String levelId;
  final int bestMoveCount;
  final int stars;
  final bool isPerfect;
  final int firstCompletedAtUtcMs;
  const PersonalBest({
    required this.guestId,
    required this.levelId,
    required this.bestMoveCount,
    required this.stars,
    required this.isPerfect,
    required this.firstCompletedAtUtcMs,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['guest_id'] = Variable<String>(guestId);
    map['level_id'] = Variable<String>(levelId);
    map['best_move_count'] = Variable<int>(bestMoveCount);
    map['stars'] = Variable<int>(stars);
    map['is_perfect'] = Variable<bool>(isPerfect);
    map['first_completed_at_utc_ms'] = Variable<int>(firstCompletedAtUtcMs);
    return map;
  }

  PersonalBestsCompanion toCompanion(bool nullToAbsent) {
    return PersonalBestsCompanion(
      guestId: Value(guestId),
      levelId: Value(levelId),
      bestMoveCount: Value(bestMoveCount),
      stars: Value(stars),
      isPerfect: Value(isPerfect),
      firstCompletedAtUtcMs: Value(firstCompletedAtUtcMs),
    );
  }

  factory PersonalBest.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PersonalBest(
      guestId: serializer.fromJson<String>(json['guestId']),
      levelId: serializer.fromJson<String>(json['levelId']),
      bestMoveCount: serializer.fromJson<int>(json['bestMoveCount']),
      stars: serializer.fromJson<int>(json['stars']),
      isPerfect: serializer.fromJson<bool>(json['isPerfect']),
      firstCompletedAtUtcMs: serializer.fromJson<int>(
        json['firstCompletedAtUtcMs'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'guestId': serializer.toJson<String>(guestId),
      'levelId': serializer.toJson<String>(levelId),
      'bestMoveCount': serializer.toJson<int>(bestMoveCount),
      'stars': serializer.toJson<int>(stars),
      'isPerfect': serializer.toJson<bool>(isPerfect),
      'firstCompletedAtUtcMs': serializer.toJson<int>(firstCompletedAtUtcMs),
    };
  }

  PersonalBest copyWith({
    String? guestId,
    String? levelId,
    int? bestMoveCount,
    int? stars,
    bool? isPerfect,
    int? firstCompletedAtUtcMs,
  }) => PersonalBest(
    guestId: guestId ?? this.guestId,
    levelId: levelId ?? this.levelId,
    bestMoveCount: bestMoveCount ?? this.bestMoveCount,
    stars: stars ?? this.stars,
    isPerfect: isPerfect ?? this.isPerfect,
    firstCompletedAtUtcMs: firstCompletedAtUtcMs ?? this.firstCompletedAtUtcMs,
  );
  PersonalBest copyWithCompanion(PersonalBestsCompanion data) {
    return PersonalBest(
      guestId: data.guestId.present ? data.guestId.value : this.guestId,
      levelId: data.levelId.present ? data.levelId.value : this.levelId,
      bestMoveCount: data.bestMoveCount.present
          ? data.bestMoveCount.value
          : this.bestMoveCount,
      stars: data.stars.present ? data.stars.value : this.stars,
      isPerfect: data.isPerfect.present ? data.isPerfect.value : this.isPerfect,
      firstCompletedAtUtcMs: data.firstCompletedAtUtcMs.present
          ? data.firstCompletedAtUtcMs.value
          : this.firstCompletedAtUtcMs,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PersonalBest(')
          ..write('guestId: $guestId, ')
          ..write('levelId: $levelId, ')
          ..write('bestMoveCount: $bestMoveCount, ')
          ..write('stars: $stars, ')
          ..write('isPerfect: $isPerfect, ')
          ..write('firstCompletedAtUtcMs: $firstCompletedAtUtcMs')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    guestId,
    levelId,
    bestMoveCount,
    stars,
    isPerfect,
    firstCompletedAtUtcMs,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PersonalBest &&
          other.guestId == this.guestId &&
          other.levelId == this.levelId &&
          other.bestMoveCount == this.bestMoveCount &&
          other.stars == this.stars &&
          other.isPerfect == this.isPerfect &&
          other.firstCompletedAtUtcMs == this.firstCompletedAtUtcMs);
}

class PersonalBestsCompanion extends UpdateCompanion<PersonalBest> {
  final Value<String> guestId;
  final Value<String> levelId;
  final Value<int> bestMoveCount;
  final Value<int> stars;
  final Value<bool> isPerfect;
  final Value<int> firstCompletedAtUtcMs;
  final Value<int> rowid;
  const PersonalBestsCompanion({
    this.guestId = const Value.absent(),
    this.levelId = const Value.absent(),
    this.bestMoveCount = const Value.absent(),
    this.stars = const Value.absent(),
    this.isPerfect = const Value.absent(),
    this.firstCompletedAtUtcMs = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PersonalBestsCompanion.insert({
    required String guestId,
    required String levelId,
    required int bestMoveCount,
    required int stars,
    required bool isPerfect,
    required int firstCompletedAtUtcMs,
    this.rowid = const Value.absent(),
  }) : guestId = Value(guestId),
       levelId = Value(levelId),
       bestMoveCount = Value(bestMoveCount),
       stars = Value(stars),
       isPerfect = Value(isPerfect),
       firstCompletedAtUtcMs = Value(firstCompletedAtUtcMs);
  static Insertable<PersonalBest> custom({
    Expression<String>? guestId,
    Expression<String>? levelId,
    Expression<int>? bestMoveCount,
    Expression<int>? stars,
    Expression<bool>? isPerfect,
    Expression<int>? firstCompletedAtUtcMs,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (guestId != null) 'guest_id': guestId,
      if (levelId != null) 'level_id': levelId,
      if (bestMoveCount != null) 'best_move_count': bestMoveCount,
      if (stars != null) 'stars': stars,
      if (isPerfect != null) 'is_perfect': isPerfect,
      if (firstCompletedAtUtcMs != null)
        'first_completed_at_utc_ms': firstCompletedAtUtcMs,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PersonalBestsCompanion copyWith({
    Value<String>? guestId,
    Value<String>? levelId,
    Value<int>? bestMoveCount,
    Value<int>? stars,
    Value<bool>? isPerfect,
    Value<int>? firstCompletedAtUtcMs,
    Value<int>? rowid,
  }) {
    return PersonalBestsCompanion(
      guestId: guestId ?? this.guestId,
      levelId: levelId ?? this.levelId,
      bestMoveCount: bestMoveCount ?? this.bestMoveCount,
      stars: stars ?? this.stars,
      isPerfect: isPerfect ?? this.isPerfect,
      firstCompletedAtUtcMs:
          firstCompletedAtUtcMs ?? this.firstCompletedAtUtcMs,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (guestId.present) {
      map['guest_id'] = Variable<String>(guestId.value);
    }
    if (levelId.present) {
      map['level_id'] = Variable<String>(levelId.value);
    }
    if (bestMoveCount.present) {
      map['best_move_count'] = Variable<int>(bestMoveCount.value);
    }
    if (stars.present) {
      map['stars'] = Variable<int>(stars.value);
    }
    if (isPerfect.present) {
      map['is_perfect'] = Variable<bool>(isPerfect.value);
    }
    if (firstCompletedAtUtcMs.present) {
      map['first_completed_at_utc_ms'] = Variable<int>(
        firstCompletedAtUtcMs.value,
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PersonalBestsCompanion(')
          ..write('guestId: $guestId, ')
          ..write('levelId: $levelId, ')
          ..write('bestMoveCount: $bestMoveCount, ')
          ..write('stars: $stars, ')
          ..write('isPerfect: $isPerfect, ')
          ..write('firstCompletedAtUtcMs: $firstCompletedAtUtcMs, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DailyEntriesTable extends DailyEntries
    with TableInfo<$DailyEntriesTable, DailyEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DailyEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _guestIdMeta = const VerificationMeta(
    'guestId',
  );
  @override
  late final GeneratedColumn<String> guestId = GeneratedColumn<String>(
    'guest_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _langMeta = const VerificationMeta('lang');
  @override
  late final GeneratedColumn<String> lang = GeneratedColumn<String>(
    'lang',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dailyDateMeta = const VerificationMeta(
    'dailyDate',
  );
  @override
  late final GeneratedColumn<String> dailyDate = GeneratedColumn<String>(
    'daily_date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dailyIdMeta = const VerificationMeta(
    'dailyId',
  );
  @override
  late final GeneratedColumn<String> dailyId = GeneratedColumn<String>(
    'daily_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _firstRunMoveCountMeta = const VerificationMeta(
    'firstRunMoveCount',
  );
  @override
  late final GeneratedColumn<int> firstRunMoveCount = GeneratedColumn<int>(
    'first_run_move_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _firstRunDurationMsMeta =
      const VerificationMeta('firstRunDurationMs');
  @override
  late final GeneratedColumn<int> firstRunDurationMs = GeneratedColumn<int>(
    'first_run_duration_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _firstRunStarsMeta = const VerificationMeta(
    'firstRunStars',
  );
  @override
  late final GeneratedColumn<int> firstRunStars = GeneratedColumn<int>(
    'first_run_stars',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _firstRunCompletedAtUtcMsMeta =
      const VerificationMeta('firstRunCompletedAtUtcMs');
  @override
  late final GeneratedColumn<int> firstRunCompletedAtUtcMs =
      GeneratedColumn<int>(
        'first_run_completed_at_utc_ms',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      );
  @override
  late final GeneratedColumnWithTypeConverter<DailySyncStatus, String>
  syncStatus = GeneratedColumn<String>(
    'sync_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  ).withConverter<DailySyncStatus>($DailyEntriesTable.$convertersyncStatus);
  @override
  List<GeneratedColumn> get $columns => [
    guestId,
    lang,
    dailyDate,
    dailyId,
    firstRunMoveCount,
    firstRunDurationMs,
    firstRunStars,
    firstRunCompletedAtUtcMs,
    syncStatus,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'daily_entry';
  @override
  VerificationContext validateIntegrity(
    Insertable<DailyEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('guest_id')) {
      context.handle(
        _guestIdMeta,
        guestId.isAcceptableOrUnknown(data['guest_id']!, _guestIdMeta),
      );
    } else if (isInserting) {
      context.missing(_guestIdMeta);
    }
    if (data.containsKey('lang')) {
      context.handle(
        _langMeta,
        lang.isAcceptableOrUnknown(data['lang']!, _langMeta),
      );
    } else if (isInserting) {
      context.missing(_langMeta);
    }
    if (data.containsKey('daily_date')) {
      context.handle(
        _dailyDateMeta,
        dailyDate.isAcceptableOrUnknown(data['daily_date']!, _dailyDateMeta),
      );
    } else if (isInserting) {
      context.missing(_dailyDateMeta);
    }
    if (data.containsKey('daily_id')) {
      context.handle(
        _dailyIdMeta,
        dailyId.isAcceptableOrUnknown(data['daily_id']!, _dailyIdMeta),
      );
    } else if (isInserting) {
      context.missing(_dailyIdMeta);
    }
    if (data.containsKey('first_run_move_count')) {
      context.handle(
        _firstRunMoveCountMeta,
        firstRunMoveCount.isAcceptableOrUnknown(
          data['first_run_move_count']!,
          _firstRunMoveCountMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_firstRunMoveCountMeta);
    }
    if (data.containsKey('first_run_duration_ms')) {
      context.handle(
        _firstRunDurationMsMeta,
        firstRunDurationMs.isAcceptableOrUnknown(
          data['first_run_duration_ms']!,
          _firstRunDurationMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_firstRunDurationMsMeta);
    }
    if (data.containsKey('first_run_stars')) {
      context.handle(
        _firstRunStarsMeta,
        firstRunStars.isAcceptableOrUnknown(
          data['first_run_stars']!,
          _firstRunStarsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_firstRunStarsMeta);
    }
    if (data.containsKey('first_run_completed_at_utc_ms')) {
      context.handle(
        _firstRunCompletedAtUtcMsMeta,
        firstRunCompletedAtUtcMs.isAcceptableOrUnknown(
          data['first_run_completed_at_utc_ms']!,
          _firstRunCompletedAtUtcMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_firstRunCompletedAtUtcMsMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {guestId, lang, dailyDate};
  @override
  DailyEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DailyEntry(
      guestId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}guest_id'],
      )!,
      lang: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}lang'],
      )!,
      dailyDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}daily_date'],
      )!,
      dailyId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}daily_id'],
      )!,
      firstRunMoveCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}first_run_move_count'],
      )!,
      firstRunDurationMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}first_run_duration_ms'],
      )!,
      firstRunStars: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}first_run_stars'],
      )!,
      firstRunCompletedAtUtcMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}first_run_completed_at_utc_ms'],
      )!,
      syncStatus: $DailyEntriesTable.$convertersyncStatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}sync_status'],
        )!,
      ),
    );
  }

  @override
  $DailyEntriesTable createAlias(String alias) {
    return $DailyEntriesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<DailySyncStatus, String, String>
  $convertersyncStatus = const EnumNameConverter<DailySyncStatus>(
    DailySyncStatus.values,
  );
}

class DailyEntry extends DataClass implements Insertable<DailyEntry> {
  final String guestId;
  final String lang;
  final String dailyDate;
  final String dailyId;
  final int firstRunMoveCount;
  final int firstRunDurationMs;
  final int firstRunStars;
  final int firstRunCompletedAtUtcMs;
  final DailySyncStatus syncStatus;
  const DailyEntry({
    required this.guestId,
    required this.lang,
    required this.dailyDate,
    required this.dailyId,
    required this.firstRunMoveCount,
    required this.firstRunDurationMs,
    required this.firstRunStars,
    required this.firstRunCompletedAtUtcMs,
    required this.syncStatus,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['guest_id'] = Variable<String>(guestId);
    map['lang'] = Variable<String>(lang);
    map['daily_date'] = Variable<String>(dailyDate);
    map['daily_id'] = Variable<String>(dailyId);
    map['first_run_move_count'] = Variable<int>(firstRunMoveCount);
    map['first_run_duration_ms'] = Variable<int>(firstRunDurationMs);
    map['first_run_stars'] = Variable<int>(firstRunStars);
    map['first_run_completed_at_utc_ms'] = Variable<int>(
      firstRunCompletedAtUtcMs,
    );
    {
      map['sync_status'] = Variable<String>(
        $DailyEntriesTable.$convertersyncStatus.toSql(syncStatus),
      );
    }
    return map;
  }

  DailyEntriesCompanion toCompanion(bool nullToAbsent) {
    return DailyEntriesCompanion(
      guestId: Value(guestId),
      lang: Value(lang),
      dailyDate: Value(dailyDate),
      dailyId: Value(dailyId),
      firstRunMoveCount: Value(firstRunMoveCount),
      firstRunDurationMs: Value(firstRunDurationMs),
      firstRunStars: Value(firstRunStars),
      firstRunCompletedAtUtcMs: Value(firstRunCompletedAtUtcMs),
      syncStatus: Value(syncStatus),
    );
  }

  factory DailyEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DailyEntry(
      guestId: serializer.fromJson<String>(json['guestId']),
      lang: serializer.fromJson<String>(json['lang']),
      dailyDate: serializer.fromJson<String>(json['dailyDate']),
      dailyId: serializer.fromJson<String>(json['dailyId']),
      firstRunMoveCount: serializer.fromJson<int>(json['firstRunMoveCount']),
      firstRunDurationMs: serializer.fromJson<int>(json['firstRunDurationMs']),
      firstRunStars: serializer.fromJson<int>(json['firstRunStars']),
      firstRunCompletedAtUtcMs: serializer.fromJson<int>(
        json['firstRunCompletedAtUtcMs'],
      ),
      syncStatus: $DailyEntriesTable.$convertersyncStatus.fromJson(
        serializer.fromJson<String>(json['syncStatus']),
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'guestId': serializer.toJson<String>(guestId),
      'lang': serializer.toJson<String>(lang),
      'dailyDate': serializer.toJson<String>(dailyDate),
      'dailyId': serializer.toJson<String>(dailyId),
      'firstRunMoveCount': serializer.toJson<int>(firstRunMoveCount),
      'firstRunDurationMs': serializer.toJson<int>(firstRunDurationMs),
      'firstRunStars': serializer.toJson<int>(firstRunStars),
      'firstRunCompletedAtUtcMs': serializer.toJson<int>(
        firstRunCompletedAtUtcMs,
      ),
      'syncStatus': serializer.toJson<String>(
        $DailyEntriesTable.$convertersyncStatus.toJson(syncStatus),
      ),
    };
  }

  DailyEntry copyWith({
    String? guestId,
    String? lang,
    String? dailyDate,
    String? dailyId,
    int? firstRunMoveCount,
    int? firstRunDurationMs,
    int? firstRunStars,
    int? firstRunCompletedAtUtcMs,
    DailySyncStatus? syncStatus,
  }) => DailyEntry(
    guestId: guestId ?? this.guestId,
    lang: lang ?? this.lang,
    dailyDate: dailyDate ?? this.dailyDate,
    dailyId: dailyId ?? this.dailyId,
    firstRunMoveCount: firstRunMoveCount ?? this.firstRunMoveCount,
    firstRunDurationMs: firstRunDurationMs ?? this.firstRunDurationMs,
    firstRunStars: firstRunStars ?? this.firstRunStars,
    firstRunCompletedAtUtcMs:
        firstRunCompletedAtUtcMs ?? this.firstRunCompletedAtUtcMs,
    syncStatus: syncStatus ?? this.syncStatus,
  );
  DailyEntry copyWithCompanion(DailyEntriesCompanion data) {
    return DailyEntry(
      guestId: data.guestId.present ? data.guestId.value : this.guestId,
      lang: data.lang.present ? data.lang.value : this.lang,
      dailyDate: data.dailyDate.present ? data.dailyDate.value : this.dailyDate,
      dailyId: data.dailyId.present ? data.dailyId.value : this.dailyId,
      firstRunMoveCount: data.firstRunMoveCount.present
          ? data.firstRunMoveCount.value
          : this.firstRunMoveCount,
      firstRunDurationMs: data.firstRunDurationMs.present
          ? data.firstRunDurationMs.value
          : this.firstRunDurationMs,
      firstRunStars: data.firstRunStars.present
          ? data.firstRunStars.value
          : this.firstRunStars,
      firstRunCompletedAtUtcMs: data.firstRunCompletedAtUtcMs.present
          ? data.firstRunCompletedAtUtcMs.value
          : this.firstRunCompletedAtUtcMs,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DailyEntry(')
          ..write('guestId: $guestId, ')
          ..write('lang: $lang, ')
          ..write('dailyDate: $dailyDate, ')
          ..write('dailyId: $dailyId, ')
          ..write('firstRunMoveCount: $firstRunMoveCount, ')
          ..write('firstRunDurationMs: $firstRunDurationMs, ')
          ..write('firstRunStars: $firstRunStars, ')
          ..write('firstRunCompletedAtUtcMs: $firstRunCompletedAtUtcMs, ')
          ..write('syncStatus: $syncStatus')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    guestId,
    lang,
    dailyDate,
    dailyId,
    firstRunMoveCount,
    firstRunDurationMs,
    firstRunStars,
    firstRunCompletedAtUtcMs,
    syncStatus,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DailyEntry &&
          other.guestId == this.guestId &&
          other.lang == this.lang &&
          other.dailyDate == this.dailyDate &&
          other.dailyId == this.dailyId &&
          other.firstRunMoveCount == this.firstRunMoveCount &&
          other.firstRunDurationMs == this.firstRunDurationMs &&
          other.firstRunStars == this.firstRunStars &&
          other.firstRunCompletedAtUtcMs == this.firstRunCompletedAtUtcMs &&
          other.syncStatus == this.syncStatus);
}

class DailyEntriesCompanion extends UpdateCompanion<DailyEntry> {
  final Value<String> guestId;
  final Value<String> lang;
  final Value<String> dailyDate;
  final Value<String> dailyId;
  final Value<int> firstRunMoveCount;
  final Value<int> firstRunDurationMs;
  final Value<int> firstRunStars;
  final Value<int> firstRunCompletedAtUtcMs;
  final Value<DailySyncStatus> syncStatus;
  final Value<int> rowid;
  const DailyEntriesCompanion({
    this.guestId = const Value.absent(),
    this.lang = const Value.absent(),
    this.dailyDate = const Value.absent(),
    this.dailyId = const Value.absent(),
    this.firstRunMoveCount = const Value.absent(),
    this.firstRunDurationMs = const Value.absent(),
    this.firstRunStars = const Value.absent(),
    this.firstRunCompletedAtUtcMs = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DailyEntriesCompanion.insert({
    required String guestId,
    required String lang,
    required String dailyDate,
    required String dailyId,
    required int firstRunMoveCount,
    required int firstRunDurationMs,
    required int firstRunStars,
    required int firstRunCompletedAtUtcMs,
    required DailySyncStatus syncStatus,
    this.rowid = const Value.absent(),
  }) : guestId = Value(guestId),
       lang = Value(lang),
       dailyDate = Value(dailyDate),
       dailyId = Value(dailyId),
       firstRunMoveCount = Value(firstRunMoveCount),
       firstRunDurationMs = Value(firstRunDurationMs),
       firstRunStars = Value(firstRunStars),
       firstRunCompletedAtUtcMs = Value(firstRunCompletedAtUtcMs),
       syncStatus = Value(syncStatus);
  static Insertable<DailyEntry> custom({
    Expression<String>? guestId,
    Expression<String>? lang,
    Expression<String>? dailyDate,
    Expression<String>? dailyId,
    Expression<int>? firstRunMoveCount,
    Expression<int>? firstRunDurationMs,
    Expression<int>? firstRunStars,
    Expression<int>? firstRunCompletedAtUtcMs,
    Expression<String>? syncStatus,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (guestId != null) 'guest_id': guestId,
      if (lang != null) 'lang': lang,
      if (dailyDate != null) 'daily_date': dailyDate,
      if (dailyId != null) 'daily_id': dailyId,
      if (firstRunMoveCount != null) 'first_run_move_count': firstRunMoveCount,
      if (firstRunDurationMs != null)
        'first_run_duration_ms': firstRunDurationMs,
      if (firstRunStars != null) 'first_run_stars': firstRunStars,
      if (firstRunCompletedAtUtcMs != null)
        'first_run_completed_at_utc_ms': firstRunCompletedAtUtcMs,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DailyEntriesCompanion copyWith({
    Value<String>? guestId,
    Value<String>? lang,
    Value<String>? dailyDate,
    Value<String>? dailyId,
    Value<int>? firstRunMoveCount,
    Value<int>? firstRunDurationMs,
    Value<int>? firstRunStars,
    Value<int>? firstRunCompletedAtUtcMs,
    Value<DailySyncStatus>? syncStatus,
    Value<int>? rowid,
  }) {
    return DailyEntriesCompanion(
      guestId: guestId ?? this.guestId,
      lang: lang ?? this.lang,
      dailyDate: dailyDate ?? this.dailyDate,
      dailyId: dailyId ?? this.dailyId,
      firstRunMoveCount: firstRunMoveCount ?? this.firstRunMoveCount,
      firstRunDurationMs: firstRunDurationMs ?? this.firstRunDurationMs,
      firstRunStars: firstRunStars ?? this.firstRunStars,
      firstRunCompletedAtUtcMs:
          firstRunCompletedAtUtcMs ?? this.firstRunCompletedAtUtcMs,
      syncStatus: syncStatus ?? this.syncStatus,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (guestId.present) {
      map['guest_id'] = Variable<String>(guestId.value);
    }
    if (lang.present) {
      map['lang'] = Variable<String>(lang.value);
    }
    if (dailyDate.present) {
      map['daily_date'] = Variable<String>(dailyDate.value);
    }
    if (dailyId.present) {
      map['daily_id'] = Variable<String>(dailyId.value);
    }
    if (firstRunMoveCount.present) {
      map['first_run_move_count'] = Variable<int>(firstRunMoveCount.value);
    }
    if (firstRunDurationMs.present) {
      map['first_run_duration_ms'] = Variable<int>(firstRunDurationMs.value);
    }
    if (firstRunStars.present) {
      map['first_run_stars'] = Variable<int>(firstRunStars.value);
    }
    if (firstRunCompletedAtUtcMs.present) {
      map['first_run_completed_at_utc_ms'] = Variable<int>(
        firstRunCompletedAtUtcMs.value,
      );
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(
        $DailyEntriesTable.$convertersyncStatus.toSql(syncStatus.value),
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DailyEntriesCompanion(')
          ..write('guestId: $guestId, ')
          ..write('lang: $lang, ')
          ..write('dailyDate: $dailyDate, ')
          ..write('dailyId: $dailyId, ')
          ..write('firstRunMoveCount: $firstRunMoveCount, ')
          ..write('firstRunDurationMs: $firstRunDurationMs, ')
          ..write('firstRunStars: $firstRunStars, ')
          ..write('firstRunCompletedAtUtcMs: $firstRunCompletedAtUtcMs, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DailyAttemptsTable extends DailyAttempts
    with TableInfo<$DailyAttemptsTable, DailyAttempt> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DailyAttemptsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _guestIdMeta = const VerificationMeta(
    'guestId',
  );
  @override
  late final GeneratedColumn<String> guestId = GeneratedColumn<String>(
    'guest_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _langMeta = const VerificationMeta('lang');
  @override
  late final GeneratedColumn<String> lang = GeneratedColumn<String>(
    'lang',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dailyDateMeta = const VerificationMeta(
    'dailyDate',
  );
  @override
  late final GeneratedColumn<String> dailyDate = GeneratedColumn<String>(
    'daily_date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _attemptNoMeta = const VerificationMeta(
    'attemptNo',
  );
  @override
  late final GeneratedColumn<int> attemptNo = GeneratedColumn<int>(
    'attempt_no',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _moveCountMeta = const VerificationMeta(
    'moveCount',
  );
  @override
  late final GeneratedColumn<int> moveCount = GeneratedColumn<int>(
    'move_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _durationMsMeta = const VerificationMeta(
    'durationMs',
  );
  @override
  late final GeneratedColumn<int> durationMs = GeneratedColumn<int>(
    'duration_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _starsMeta = const VerificationMeta('stars');
  @override
  late final GeneratedColumn<int> stars = GeneratedColumn<int>(
    'stars',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _completedAtUtcMsMeta = const VerificationMeta(
    'completedAtUtcMs',
  );
  @override
  late final GeneratedColumn<int> completedAtUtcMs = GeneratedColumn<int>(
    'completed_at_utc_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    guestId,
    lang,
    dailyDate,
    attemptNo,
    moveCount,
    durationMs,
    stars,
    completedAtUtcMs,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'daily_attempt';
  @override
  VerificationContext validateIntegrity(
    Insertable<DailyAttempt> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('guest_id')) {
      context.handle(
        _guestIdMeta,
        guestId.isAcceptableOrUnknown(data['guest_id']!, _guestIdMeta),
      );
    } else if (isInserting) {
      context.missing(_guestIdMeta);
    }
    if (data.containsKey('lang')) {
      context.handle(
        _langMeta,
        lang.isAcceptableOrUnknown(data['lang']!, _langMeta),
      );
    } else if (isInserting) {
      context.missing(_langMeta);
    }
    if (data.containsKey('daily_date')) {
      context.handle(
        _dailyDateMeta,
        dailyDate.isAcceptableOrUnknown(data['daily_date']!, _dailyDateMeta),
      );
    } else if (isInserting) {
      context.missing(_dailyDateMeta);
    }
    if (data.containsKey('attempt_no')) {
      context.handle(
        _attemptNoMeta,
        attemptNo.isAcceptableOrUnknown(data['attempt_no']!, _attemptNoMeta),
      );
    } else if (isInserting) {
      context.missing(_attemptNoMeta);
    }
    if (data.containsKey('move_count')) {
      context.handle(
        _moveCountMeta,
        moveCount.isAcceptableOrUnknown(data['move_count']!, _moveCountMeta),
      );
    } else if (isInserting) {
      context.missing(_moveCountMeta);
    }
    if (data.containsKey('duration_ms')) {
      context.handle(
        _durationMsMeta,
        durationMs.isAcceptableOrUnknown(data['duration_ms']!, _durationMsMeta),
      );
    } else if (isInserting) {
      context.missing(_durationMsMeta);
    }
    if (data.containsKey('stars')) {
      context.handle(
        _starsMeta,
        stars.isAcceptableOrUnknown(data['stars']!, _starsMeta),
      );
    } else if (isInserting) {
      context.missing(_starsMeta);
    }
    if (data.containsKey('completed_at_utc_ms')) {
      context.handle(
        _completedAtUtcMsMeta,
        completedAtUtcMs.isAcceptableOrUnknown(
          data['completed_at_utc_ms']!,
          _completedAtUtcMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_completedAtUtcMsMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {guestId, lang, dailyDate, attemptNo};
  @override
  DailyAttempt map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DailyAttempt(
      guestId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}guest_id'],
      )!,
      lang: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}lang'],
      )!,
      dailyDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}daily_date'],
      )!,
      attemptNo: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}attempt_no'],
      )!,
      moveCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}move_count'],
      )!,
      durationMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_ms'],
      )!,
      stars: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}stars'],
      )!,
      completedAtUtcMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}completed_at_utc_ms'],
      )!,
    );
  }

  @override
  $DailyAttemptsTable createAlias(String alias) {
    return $DailyAttemptsTable(attachedDatabase, alias);
  }
}

class DailyAttempt extends DataClass implements Insertable<DailyAttempt> {
  final String guestId;
  final String lang;
  final String dailyDate;
  final int attemptNo;
  final int moveCount;
  final int durationMs;
  final int stars;
  final int completedAtUtcMs;
  const DailyAttempt({
    required this.guestId,
    required this.lang,
    required this.dailyDate,
    required this.attemptNo,
    required this.moveCount,
    required this.durationMs,
    required this.stars,
    required this.completedAtUtcMs,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['guest_id'] = Variable<String>(guestId);
    map['lang'] = Variable<String>(lang);
    map['daily_date'] = Variable<String>(dailyDate);
    map['attempt_no'] = Variable<int>(attemptNo);
    map['move_count'] = Variable<int>(moveCount);
    map['duration_ms'] = Variable<int>(durationMs);
    map['stars'] = Variable<int>(stars);
    map['completed_at_utc_ms'] = Variable<int>(completedAtUtcMs);
    return map;
  }

  DailyAttemptsCompanion toCompanion(bool nullToAbsent) {
    return DailyAttemptsCompanion(
      guestId: Value(guestId),
      lang: Value(lang),
      dailyDate: Value(dailyDate),
      attemptNo: Value(attemptNo),
      moveCount: Value(moveCount),
      durationMs: Value(durationMs),
      stars: Value(stars),
      completedAtUtcMs: Value(completedAtUtcMs),
    );
  }

  factory DailyAttempt.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DailyAttempt(
      guestId: serializer.fromJson<String>(json['guestId']),
      lang: serializer.fromJson<String>(json['lang']),
      dailyDate: serializer.fromJson<String>(json['dailyDate']),
      attemptNo: serializer.fromJson<int>(json['attemptNo']),
      moveCount: serializer.fromJson<int>(json['moveCount']),
      durationMs: serializer.fromJson<int>(json['durationMs']),
      stars: serializer.fromJson<int>(json['stars']),
      completedAtUtcMs: serializer.fromJson<int>(json['completedAtUtcMs']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'guestId': serializer.toJson<String>(guestId),
      'lang': serializer.toJson<String>(lang),
      'dailyDate': serializer.toJson<String>(dailyDate),
      'attemptNo': serializer.toJson<int>(attemptNo),
      'moveCount': serializer.toJson<int>(moveCount),
      'durationMs': serializer.toJson<int>(durationMs),
      'stars': serializer.toJson<int>(stars),
      'completedAtUtcMs': serializer.toJson<int>(completedAtUtcMs),
    };
  }

  DailyAttempt copyWith({
    String? guestId,
    String? lang,
    String? dailyDate,
    int? attemptNo,
    int? moveCount,
    int? durationMs,
    int? stars,
    int? completedAtUtcMs,
  }) => DailyAttempt(
    guestId: guestId ?? this.guestId,
    lang: lang ?? this.lang,
    dailyDate: dailyDate ?? this.dailyDate,
    attemptNo: attemptNo ?? this.attemptNo,
    moveCount: moveCount ?? this.moveCount,
    durationMs: durationMs ?? this.durationMs,
    stars: stars ?? this.stars,
    completedAtUtcMs: completedAtUtcMs ?? this.completedAtUtcMs,
  );
  DailyAttempt copyWithCompanion(DailyAttemptsCompanion data) {
    return DailyAttempt(
      guestId: data.guestId.present ? data.guestId.value : this.guestId,
      lang: data.lang.present ? data.lang.value : this.lang,
      dailyDate: data.dailyDate.present ? data.dailyDate.value : this.dailyDate,
      attemptNo: data.attemptNo.present ? data.attemptNo.value : this.attemptNo,
      moveCount: data.moveCount.present ? data.moveCount.value : this.moveCount,
      durationMs: data.durationMs.present
          ? data.durationMs.value
          : this.durationMs,
      stars: data.stars.present ? data.stars.value : this.stars,
      completedAtUtcMs: data.completedAtUtcMs.present
          ? data.completedAtUtcMs.value
          : this.completedAtUtcMs,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DailyAttempt(')
          ..write('guestId: $guestId, ')
          ..write('lang: $lang, ')
          ..write('dailyDate: $dailyDate, ')
          ..write('attemptNo: $attemptNo, ')
          ..write('moveCount: $moveCount, ')
          ..write('durationMs: $durationMs, ')
          ..write('stars: $stars, ')
          ..write('completedAtUtcMs: $completedAtUtcMs')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    guestId,
    lang,
    dailyDate,
    attemptNo,
    moveCount,
    durationMs,
    stars,
    completedAtUtcMs,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DailyAttempt &&
          other.guestId == this.guestId &&
          other.lang == this.lang &&
          other.dailyDate == this.dailyDate &&
          other.attemptNo == this.attemptNo &&
          other.moveCount == this.moveCount &&
          other.durationMs == this.durationMs &&
          other.stars == this.stars &&
          other.completedAtUtcMs == this.completedAtUtcMs);
}

class DailyAttemptsCompanion extends UpdateCompanion<DailyAttempt> {
  final Value<String> guestId;
  final Value<String> lang;
  final Value<String> dailyDate;
  final Value<int> attemptNo;
  final Value<int> moveCount;
  final Value<int> durationMs;
  final Value<int> stars;
  final Value<int> completedAtUtcMs;
  final Value<int> rowid;
  const DailyAttemptsCompanion({
    this.guestId = const Value.absent(),
    this.lang = const Value.absent(),
    this.dailyDate = const Value.absent(),
    this.attemptNo = const Value.absent(),
    this.moveCount = const Value.absent(),
    this.durationMs = const Value.absent(),
    this.stars = const Value.absent(),
    this.completedAtUtcMs = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DailyAttemptsCompanion.insert({
    required String guestId,
    required String lang,
    required String dailyDate,
    required int attemptNo,
    required int moveCount,
    required int durationMs,
    required int stars,
    required int completedAtUtcMs,
    this.rowid = const Value.absent(),
  }) : guestId = Value(guestId),
       lang = Value(lang),
       dailyDate = Value(dailyDate),
       attemptNo = Value(attemptNo),
       moveCount = Value(moveCount),
       durationMs = Value(durationMs),
       stars = Value(stars),
       completedAtUtcMs = Value(completedAtUtcMs);
  static Insertable<DailyAttempt> custom({
    Expression<String>? guestId,
    Expression<String>? lang,
    Expression<String>? dailyDate,
    Expression<int>? attemptNo,
    Expression<int>? moveCount,
    Expression<int>? durationMs,
    Expression<int>? stars,
    Expression<int>? completedAtUtcMs,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (guestId != null) 'guest_id': guestId,
      if (lang != null) 'lang': lang,
      if (dailyDate != null) 'daily_date': dailyDate,
      if (attemptNo != null) 'attempt_no': attemptNo,
      if (moveCount != null) 'move_count': moveCount,
      if (durationMs != null) 'duration_ms': durationMs,
      if (stars != null) 'stars': stars,
      if (completedAtUtcMs != null) 'completed_at_utc_ms': completedAtUtcMs,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DailyAttemptsCompanion copyWith({
    Value<String>? guestId,
    Value<String>? lang,
    Value<String>? dailyDate,
    Value<int>? attemptNo,
    Value<int>? moveCount,
    Value<int>? durationMs,
    Value<int>? stars,
    Value<int>? completedAtUtcMs,
    Value<int>? rowid,
  }) {
    return DailyAttemptsCompanion(
      guestId: guestId ?? this.guestId,
      lang: lang ?? this.lang,
      dailyDate: dailyDate ?? this.dailyDate,
      attemptNo: attemptNo ?? this.attemptNo,
      moveCount: moveCount ?? this.moveCount,
      durationMs: durationMs ?? this.durationMs,
      stars: stars ?? this.stars,
      completedAtUtcMs: completedAtUtcMs ?? this.completedAtUtcMs,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (guestId.present) {
      map['guest_id'] = Variable<String>(guestId.value);
    }
    if (lang.present) {
      map['lang'] = Variable<String>(lang.value);
    }
    if (dailyDate.present) {
      map['daily_date'] = Variable<String>(dailyDate.value);
    }
    if (attemptNo.present) {
      map['attempt_no'] = Variable<int>(attemptNo.value);
    }
    if (moveCount.present) {
      map['move_count'] = Variable<int>(moveCount.value);
    }
    if (durationMs.present) {
      map['duration_ms'] = Variable<int>(durationMs.value);
    }
    if (stars.present) {
      map['stars'] = Variable<int>(stars.value);
    }
    if (completedAtUtcMs.present) {
      map['completed_at_utc_ms'] = Variable<int>(completedAtUtcMs.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DailyAttemptsCompanion(')
          ..write('guestId: $guestId, ')
          ..write('lang: $lang, ')
          ..write('dailyDate: $dailyDate, ')
          ..write('attemptNo: $attemptNo, ')
          ..write('moveCount: $moveCount, ')
          ..write('durationMs: $durationMs, ')
          ..write('stars: $stars, ')
          ..write('completedAtUtcMs: $completedAtUtcMs, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DailyStreaksTable extends DailyStreaks
    with TableInfo<$DailyStreaksTable, DailyStreak> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DailyStreaksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _guestIdMeta = const VerificationMeta(
    'guestId',
  );
  @override
  late final GeneratedColumn<String> guestId = GeneratedColumn<String>(
    'guest_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _currentStreakMeta = const VerificationMeta(
    'currentStreak',
  );
  @override
  late final GeneratedColumn<int> currentStreak = GeneratedColumn<int>(
    'current_streak',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _bestStreakMeta = const VerificationMeta(
    'bestStreak',
  );
  @override
  late final GeneratedColumn<int> bestStreak = GeneratedColumn<int>(
    'best_streak',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastCompletedDateMeta = const VerificationMeta(
    'lastCompletedDate',
  );
  @override
  late final GeneratedColumn<String> lastCompletedDate =
      GeneratedColumn<String>(
        'last_completed_date',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  @override
  List<GeneratedColumn> get $columns => [
    guestId,
    currentStreak,
    bestStreak,
    lastCompletedDate,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'daily_streak';
  @override
  VerificationContext validateIntegrity(
    Insertable<DailyStreak> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('guest_id')) {
      context.handle(
        _guestIdMeta,
        guestId.isAcceptableOrUnknown(data['guest_id']!, _guestIdMeta),
      );
    } else if (isInserting) {
      context.missing(_guestIdMeta);
    }
    if (data.containsKey('current_streak')) {
      context.handle(
        _currentStreakMeta,
        currentStreak.isAcceptableOrUnknown(
          data['current_streak']!,
          _currentStreakMeta,
        ),
      );
    }
    if (data.containsKey('best_streak')) {
      context.handle(
        _bestStreakMeta,
        bestStreak.isAcceptableOrUnknown(data['best_streak']!, _bestStreakMeta),
      );
    }
    if (data.containsKey('last_completed_date')) {
      context.handle(
        _lastCompletedDateMeta,
        lastCompletedDate.isAcceptableOrUnknown(
          data['last_completed_date']!,
          _lastCompletedDateMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {guestId};
  @override
  DailyStreak map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DailyStreak(
      guestId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}guest_id'],
      )!,
      currentStreak: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}current_streak'],
      )!,
      bestStreak: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}best_streak'],
      )!,
      lastCompletedDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_completed_date'],
      ),
    );
  }

  @override
  $DailyStreaksTable createAlias(String alias) {
    return $DailyStreaksTable(attachedDatabase, alias);
  }
}

class DailyStreak extends DataClass implements Insertable<DailyStreak> {
  final String guestId;
  final int currentStreak;
  final int bestStreak;
  final String? lastCompletedDate;
  const DailyStreak({
    required this.guestId,
    required this.currentStreak,
    required this.bestStreak,
    this.lastCompletedDate,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['guest_id'] = Variable<String>(guestId);
    map['current_streak'] = Variable<int>(currentStreak);
    map['best_streak'] = Variable<int>(bestStreak);
    if (!nullToAbsent || lastCompletedDate != null) {
      map['last_completed_date'] = Variable<String>(lastCompletedDate);
    }
    return map;
  }

  DailyStreaksCompanion toCompanion(bool nullToAbsent) {
    return DailyStreaksCompanion(
      guestId: Value(guestId),
      currentStreak: Value(currentStreak),
      bestStreak: Value(bestStreak),
      lastCompletedDate: lastCompletedDate == null && nullToAbsent
          ? const Value.absent()
          : Value(lastCompletedDate),
    );
  }

  factory DailyStreak.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DailyStreak(
      guestId: serializer.fromJson<String>(json['guestId']),
      currentStreak: serializer.fromJson<int>(json['currentStreak']),
      bestStreak: serializer.fromJson<int>(json['bestStreak']),
      lastCompletedDate: serializer.fromJson<String?>(
        json['lastCompletedDate'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'guestId': serializer.toJson<String>(guestId),
      'currentStreak': serializer.toJson<int>(currentStreak),
      'bestStreak': serializer.toJson<int>(bestStreak),
      'lastCompletedDate': serializer.toJson<String?>(lastCompletedDate),
    };
  }

  DailyStreak copyWith({
    String? guestId,
    int? currentStreak,
    int? bestStreak,
    Value<String?> lastCompletedDate = const Value.absent(),
  }) => DailyStreak(
    guestId: guestId ?? this.guestId,
    currentStreak: currentStreak ?? this.currentStreak,
    bestStreak: bestStreak ?? this.bestStreak,
    lastCompletedDate: lastCompletedDate.present
        ? lastCompletedDate.value
        : this.lastCompletedDate,
  );
  DailyStreak copyWithCompanion(DailyStreaksCompanion data) {
    return DailyStreak(
      guestId: data.guestId.present ? data.guestId.value : this.guestId,
      currentStreak: data.currentStreak.present
          ? data.currentStreak.value
          : this.currentStreak,
      bestStreak: data.bestStreak.present
          ? data.bestStreak.value
          : this.bestStreak,
      lastCompletedDate: data.lastCompletedDate.present
          ? data.lastCompletedDate.value
          : this.lastCompletedDate,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DailyStreak(')
          ..write('guestId: $guestId, ')
          ..write('currentStreak: $currentStreak, ')
          ..write('bestStreak: $bestStreak, ')
          ..write('lastCompletedDate: $lastCompletedDate')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(guestId, currentStreak, bestStreak, lastCompletedDate);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DailyStreak &&
          other.guestId == this.guestId &&
          other.currentStreak == this.currentStreak &&
          other.bestStreak == this.bestStreak &&
          other.lastCompletedDate == this.lastCompletedDate);
}

class DailyStreaksCompanion extends UpdateCompanion<DailyStreak> {
  final Value<String> guestId;
  final Value<int> currentStreak;
  final Value<int> bestStreak;
  final Value<String?> lastCompletedDate;
  final Value<int> rowid;
  const DailyStreaksCompanion({
    this.guestId = const Value.absent(),
    this.currentStreak = const Value.absent(),
    this.bestStreak = const Value.absent(),
    this.lastCompletedDate = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DailyStreaksCompanion.insert({
    required String guestId,
    this.currentStreak = const Value.absent(),
    this.bestStreak = const Value.absent(),
    this.lastCompletedDate = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : guestId = Value(guestId);
  static Insertable<DailyStreak> custom({
    Expression<String>? guestId,
    Expression<int>? currentStreak,
    Expression<int>? bestStreak,
    Expression<String>? lastCompletedDate,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (guestId != null) 'guest_id': guestId,
      if (currentStreak != null) 'current_streak': currentStreak,
      if (bestStreak != null) 'best_streak': bestStreak,
      if (lastCompletedDate != null) 'last_completed_date': lastCompletedDate,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DailyStreaksCompanion copyWith({
    Value<String>? guestId,
    Value<int>? currentStreak,
    Value<int>? bestStreak,
    Value<String?>? lastCompletedDate,
    Value<int>? rowid,
  }) {
    return DailyStreaksCompanion(
      guestId: guestId ?? this.guestId,
      currentStreak: currentStreak ?? this.currentStreak,
      bestStreak: bestStreak ?? this.bestStreak,
      lastCompletedDate: lastCompletedDate ?? this.lastCompletedDate,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (guestId.present) {
      map['guest_id'] = Variable<String>(guestId.value);
    }
    if (currentStreak.present) {
      map['current_streak'] = Variable<int>(currentStreak.value);
    }
    if (bestStreak.present) {
      map['best_streak'] = Variable<int>(bestStreak.value);
    }
    if (lastCompletedDate.present) {
      map['last_completed_date'] = Variable<String>(lastCompletedDate.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DailyStreaksCompanion(')
          ..write('guestId: $guestId, ')
          ..write('currentStreak: $currentStreak, ')
          ..write('bestStreak: $bestStreak, ')
          ..write('lastCompletedDate: $lastCompletedDate, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DailyPuzzleCacheRowsTable extends DailyPuzzleCacheRows
    with TableInfo<$DailyPuzzleCacheRowsTable, DailyPuzzleCacheRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DailyPuzzleCacheRowsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _langMeta = const VerificationMeta('lang');
  @override
  late final GeneratedColumn<String> lang = GeneratedColumn<String>(
    'lang',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dailyDateMeta = const VerificationMeta(
    'dailyDate',
  );
  @override
  late final GeneratedColumn<String> dailyDate = GeneratedColumn<String>(
    'daily_date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _puzzleJsonMeta = const VerificationMeta(
    'puzzleJson',
  );
  @override
  late final GeneratedColumn<String> puzzleJson = GeneratedColumn<String>(
    'puzzle_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fetchedAtUtcMsMeta = const VerificationMeta(
    'fetchedAtUtcMs',
  );
  @override
  late final GeneratedColumn<int> fetchedAtUtcMs = GeneratedColumn<int>(
    'fetched_at_utc_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    lang,
    dailyDate,
    puzzleJson,
    fetchedAtUtcMs,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'daily_puzzle_cache';
  @override
  VerificationContext validateIntegrity(
    Insertable<DailyPuzzleCacheRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('lang')) {
      context.handle(
        _langMeta,
        lang.isAcceptableOrUnknown(data['lang']!, _langMeta),
      );
    } else if (isInserting) {
      context.missing(_langMeta);
    }
    if (data.containsKey('daily_date')) {
      context.handle(
        _dailyDateMeta,
        dailyDate.isAcceptableOrUnknown(data['daily_date']!, _dailyDateMeta),
      );
    } else if (isInserting) {
      context.missing(_dailyDateMeta);
    }
    if (data.containsKey('puzzle_json')) {
      context.handle(
        _puzzleJsonMeta,
        puzzleJson.isAcceptableOrUnknown(data['puzzle_json']!, _puzzleJsonMeta),
      );
    } else if (isInserting) {
      context.missing(_puzzleJsonMeta);
    }
    if (data.containsKey('fetched_at_utc_ms')) {
      context.handle(
        _fetchedAtUtcMsMeta,
        fetchedAtUtcMs.isAcceptableOrUnknown(
          data['fetched_at_utc_ms']!,
          _fetchedAtUtcMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_fetchedAtUtcMsMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {lang, dailyDate};
  @override
  DailyPuzzleCacheRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DailyPuzzleCacheRow(
      lang: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}lang'],
      )!,
      dailyDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}daily_date'],
      )!,
      puzzleJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}puzzle_json'],
      )!,
      fetchedAtUtcMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}fetched_at_utc_ms'],
      )!,
    );
  }

  @override
  $DailyPuzzleCacheRowsTable createAlias(String alias) {
    return $DailyPuzzleCacheRowsTable(attachedDatabase, alias);
  }
}

class DailyPuzzleCacheRow extends DataClass
    implements Insertable<DailyPuzzleCacheRow> {
  final String lang;
  final String dailyDate;
  final String puzzleJson;
  final int fetchedAtUtcMs;
  const DailyPuzzleCacheRow({
    required this.lang,
    required this.dailyDate,
    required this.puzzleJson,
    required this.fetchedAtUtcMs,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['lang'] = Variable<String>(lang);
    map['daily_date'] = Variable<String>(dailyDate);
    map['puzzle_json'] = Variable<String>(puzzleJson);
    map['fetched_at_utc_ms'] = Variable<int>(fetchedAtUtcMs);
    return map;
  }

  DailyPuzzleCacheRowsCompanion toCompanion(bool nullToAbsent) {
    return DailyPuzzleCacheRowsCompanion(
      lang: Value(lang),
      dailyDate: Value(dailyDate),
      puzzleJson: Value(puzzleJson),
      fetchedAtUtcMs: Value(fetchedAtUtcMs),
    );
  }

  factory DailyPuzzleCacheRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DailyPuzzleCacheRow(
      lang: serializer.fromJson<String>(json['lang']),
      dailyDate: serializer.fromJson<String>(json['dailyDate']),
      puzzleJson: serializer.fromJson<String>(json['puzzleJson']),
      fetchedAtUtcMs: serializer.fromJson<int>(json['fetchedAtUtcMs']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'lang': serializer.toJson<String>(lang),
      'dailyDate': serializer.toJson<String>(dailyDate),
      'puzzleJson': serializer.toJson<String>(puzzleJson),
      'fetchedAtUtcMs': serializer.toJson<int>(fetchedAtUtcMs),
    };
  }

  DailyPuzzleCacheRow copyWith({
    String? lang,
    String? dailyDate,
    String? puzzleJson,
    int? fetchedAtUtcMs,
  }) => DailyPuzzleCacheRow(
    lang: lang ?? this.lang,
    dailyDate: dailyDate ?? this.dailyDate,
    puzzleJson: puzzleJson ?? this.puzzleJson,
    fetchedAtUtcMs: fetchedAtUtcMs ?? this.fetchedAtUtcMs,
  );
  DailyPuzzleCacheRow copyWithCompanion(DailyPuzzleCacheRowsCompanion data) {
    return DailyPuzzleCacheRow(
      lang: data.lang.present ? data.lang.value : this.lang,
      dailyDate: data.dailyDate.present ? data.dailyDate.value : this.dailyDate,
      puzzleJson: data.puzzleJson.present
          ? data.puzzleJson.value
          : this.puzzleJson,
      fetchedAtUtcMs: data.fetchedAtUtcMs.present
          ? data.fetchedAtUtcMs.value
          : this.fetchedAtUtcMs,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DailyPuzzleCacheRow(')
          ..write('lang: $lang, ')
          ..write('dailyDate: $dailyDate, ')
          ..write('puzzleJson: $puzzleJson, ')
          ..write('fetchedAtUtcMs: $fetchedAtUtcMs')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(lang, dailyDate, puzzleJson, fetchedAtUtcMs);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DailyPuzzleCacheRow &&
          other.lang == this.lang &&
          other.dailyDate == this.dailyDate &&
          other.puzzleJson == this.puzzleJson &&
          other.fetchedAtUtcMs == this.fetchedAtUtcMs);
}

class DailyPuzzleCacheRowsCompanion
    extends UpdateCompanion<DailyPuzzleCacheRow> {
  final Value<String> lang;
  final Value<String> dailyDate;
  final Value<String> puzzleJson;
  final Value<int> fetchedAtUtcMs;
  final Value<int> rowid;
  const DailyPuzzleCacheRowsCompanion({
    this.lang = const Value.absent(),
    this.dailyDate = const Value.absent(),
    this.puzzleJson = const Value.absent(),
    this.fetchedAtUtcMs = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DailyPuzzleCacheRowsCompanion.insert({
    required String lang,
    required String dailyDate,
    required String puzzleJson,
    required int fetchedAtUtcMs,
    this.rowid = const Value.absent(),
  }) : lang = Value(lang),
       dailyDate = Value(dailyDate),
       puzzleJson = Value(puzzleJson),
       fetchedAtUtcMs = Value(fetchedAtUtcMs);
  static Insertable<DailyPuzzleCacheRow> custom({
    Expression<String>? lang,
    Expression<String>? dailyDate,
    Expression<String>? puzzleJson,
    Expression<int>? fetchedAtUtcMs,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (lang != null) 'lang': lang,
      if (dailyDate != null) 'daily_date': dailyDate,
      if (puzzleJson != null) 'puzzle_json': puzzleJson,
      if (fetchedAtUtcMs != null) 'fetched_at_utc_ms': fetchedAtUtcMs,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DailyPuzzleCacheRowsCompanion copyWith({
    Value<String>? lang,
    Value<String>? dailyDate,
    Value<String>? puzzleJson,
    Value<int>? fetchedAtUtcMs,
    Value<int>? rowid,
  }) {
    return DailyPuzzleCacheRowsCompanion(
      lang: lang ?? this.lang,
      dailyDate: dailyDate ?? this.dailyDate,
      puzzleJson: puzzleJson ?? this.puzzleJson,
      fetchedAtUtcMs: fetchedAtUtcMs ?? this.fetchedAtUtcMs,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (lang.present) {
      map['lang'] = Variable<String>(lang.value);
    }
    if (dailyDate.present) {
      map['daily_date'] = Variable<String>(dailyDate.value);
    }
    if (puzzleJson.present) {
      map['puzzle_json'] = Variable<String>(puzzleJson.value);
    }
    if (fetchedAtUtcMs.present) {
      map['fetched_at_utc_ms'] = Variable<int>(fetchedAtUtcMs.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DailyPuzzleCacheRowsCompanion(')
          ..write('lang: $lang, ')
          ..write('dailyDate: $dailyDate, ')
          ..write('puzzleJson: $puzzleJson, ')
          ..write('fetchedAtUtcMs: $fetchedAtUtcMs, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncQueueRowsTable extends SyncQueueRows
    with TableInfo<$SyncQueueRowsTable, SyncQueueRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncQueueRowsTable(this.attachedDatabase, [this._alias]);
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
  @override
  late final GeneratedColumnWithTypeConverter<SyncQueueKind, String> kind =
      GeneratedColumn<String>(
        'kind',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<SyncQueueKind>($SyncQueueRowsTable.$converterkind);
  static const VerificationMeta _idempotencyKeyMeta = const VerificationMeta(
    'idempotencyKey',
  );
  @override
  late final GeneratedColumn<String> idempotencyKey = GeneratedColumn<String>(
    'idempotency_key',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _payloadJsonMeta = const VerificationMeta(
    'payloadJson',
  );
  @override
  late final GeneratedColumn<String> payloadJson = GeneratedColumn<String>(
    'payload_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<SyncQueueState, String> state =
      GeneratedColumn<String>(
        'state',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<SyncQueueState>($SyncQueueRowsTable.$converterstate);
  static const VerificationMeta _attemptCountMeta = const VerificationMeta(
    'attemptCount',
  );
  @override
  late final GeneratedColumn<int> attemptCount = GeneratedColumn<int>(
    'attempt_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _postParkAttemptCountMeta =
      const VerificationMeta('postParkAttemptCount');
  @override
  late final GeneratedColumn<int> postParkAttemptCount = GeneratedColumn<int>(
    'post_park_attempt_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _nextAttemptAtUtcMsMeta =
      const VerificationMeta('nextAttemptAtUtcMs');
  @override
  late final GeneratedColumn<int> nextAttemptAtUtcMs = GeneratedColumn<int>(
    'next_attempt_at_utc_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastErrorMeta = const VerificationMeta(
    'lastError',
  );
  @override
  late final GeneratedColumn<String> lastError = GeneratedColumn<String>(
    'last_error',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtUtcMsMeta = const VerificationMeta(
    'createdAtUtcMs',
  );
  @override
  late final GeneratedColumn<int> createdAtUtcMs = GeneratedColumn<int>(
    'created_at_utc_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtUtcMsMeta = const VerificationMeta(
    'updatedAtUtcMs',
  );
  @override
  late final GeneratedColumn<int> updatedAtUtcMs = GeneratedColumn<int>(
    'updated_at_utc_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    kind,
    idempotencyKey,
    payloadJson,
    state,
    attemptCount,
    postParkAttemptCount,
    nextAttemptAtUtcMs,
    lastError,
    createdAtUtcMs,
    updatedAtUtcMs,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_queue';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncQueueRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('idempotency_key')) {
      context.handle(
        _idempotencyKeyMeta,
        idempotencyKey.isAcceptableOrUnknown(
          data['idempotency_key']!,
          _idempotencyKeyMeta,
        ),
      );
    }
    if (data.containsKey('payload_json')) {
      context.handle(
        _payloadJsonMeta,
        payloadJson.isAcceptableOrUnknown(
          data['payload_json']!,
          _payloadJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_payloadJsonMeta);
    }
    if (data.containsKey('attempt_count')) {
      context.handle(
        _attemptCountMeta,
        attemptCount.isAcceptableOrUnknown(
          data['attempt_count']!,
          _attemptCountMeta,
        ),
      );
    }
    if (data.containsKey('post_park_attempt_count')) {
      context.handle(
        _postParkAttemptCountMeta,
        postParkAttemptCount.isAcceptableOrUnknown(
          data['post_park_attempt_count']!,
          _postParkAttemptCountMeta,
        ),
      );
    }
    if (data.containsKey('next_attempt_at_utc_ms')) {
      context.handle(
        _nextAttemptAtUtcMsMeta,
        nextAttemptAtUtcMs.isAcceptableOrUnknown(
          data['next_attempt_at_utc_ms']!,
          _nextAttemptAtUtcMsMeta,
        ),
      );
    }
    if (data.containsKey('last_error')) {
      context.handle(
        _lastErrorMeta,
        lastError.isAcceptableOrUnknown(data['last_error']!, _lastErrorMeta),
      );
    }
    if (data.containsKey('created_at_utc_ms')) {
      context.handle(
        _createdAtUtcMsMeta,
        createdAtUtcMs.isAcceptableOrUnknown(
          data['created_at_utc_ms']!,
          _createdAtUtcMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_createdAtUtcMsMeta);
    }
    if (data.containsKey('updated_at_utc_ms')) {
      context.handle(
        _updatedAtUtcMsMeta,
        updatedAtUtcMs.isAcceptableOrUnknown(
          data['updated_at_utc_ms']!,
          _updatedAtUtcMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_updatedAtUtcMsMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SyncQueueRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncQueueRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      kind: $SyncQueueRowsTable.$converterkind.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}kind'],
        )!,
      ),
      idempotencyKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}idempotency_key'],
      ),
      payloadJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload_json'],
      )!,
      state: $SyncQueueRowsTable.$converterstate.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}state'],
        )!,
      ),
      attemptCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}attempt_count'],
      )!,
      postParkAttemptCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}post_park_attempt_count'],
      )!,
      nextAttemptAtUtcMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}next_attempt_at_utc_ms'],
      )!,
      lastError: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_error'],
      ),
      createdAtUtcMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at_utc_ms'],
      )!,
      updatedAtUtcMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at_utc_ms'],
      )!,
    );
  }

  @override
  $SyncQueueRowsTable createAlias(String alias) {
    return $SyncQueueRowsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<SyncQueueKind, String, String> $converterkind =
      const EnumNameConverter<SyncQueueKind>(SyncQueueKind.values);
  static JsonTypeConverter2<SyncQueueState, String, String> $converterstate =
      const EnumNameConverter<SyncQueueState>(SyncQueueState.values);
}

class SyncQueueRow extends DataClass implements Insertable<SyncQueueRow> {
  final int id;
  final SyncQueueKind kind;

  /// `"{firebaseUid}|{lang}|{dailyDate}"`; null while awaiting Anonymous Auth.
  final String? idempotencyKey;
  final String payloadJson;
  final SyncQueueState state;
  final int attemptCount;
  final int postParkAttemptCount;
  final int nextAttemptAtUtcMs;
  final String? lastError;
  final int createdAtUtcMs;
  final int updatedAtUtcMs;
  const SyncQueueRow({
    required this.id,
    required this.kind,
    this.idempotencyKey,
    required this.payloadJson,
    required this.state,
    required this.attemptCount,
    required this.postParkAttemptCount,
    required this.nextAttemptAtUtcMs,
    this.lastError,
    required this.createdAtUtcMs,
    required this.updatedAtUtcMs,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    {
      map['kind'] = Variable<String>(
        $SyncQueueRowsTable.$converterkind.toSql(kind),
      );
    }
    if (!nullToAbsent || idempotencyKey != null) {
      map['idempotency_key'] = Variable<String>(idempotencyKey);
    }
    map['payload_json'] = Variable<String>(payloadJson);
    {
      map['state'] = Variable<String>(
        $SyncQueueRowsTable.$converterstate.toSql(state),
      );
    }
    map['attempt_count'] = Variable<int>(attemptCount);
    map['post_park_attempt_count'] = Variable<int>(postParkAttemptCount);
    map['next_attempt_at_utc_ms'] = Variable<int>(nextAttemptAtUtcMs);
    if (!nullToAbsent || lastError != null) {
      map['last_error'] = Variable<String>(lastError);
    }
    map['created_at_utc_ms'] = Variable<int>(createdAtUtcMs);
    map['updated_at_utc_ms'] = Variable<int>(updatedAtUtcMs);
    return map;
  }

  SyncQueueRowsCompanion toCompanion(bool nullToAbsent) {
    return SyncQueueRowsCompanion(
      id: Value(id),
      kind: Value(kind),
      idempotencyKey: idempotencyKey == null && nullToAbsent
          ? const Value.absent()
          : Value(idempotencyKey),
      payloadJson: Value(payloadJson),
      state: Value(state),
      attemptCount: Value(attemptCount),
      postParkAttemptCount: Value(postParkAttemptCount),
      nextAttemptAtUtcMs: Value(nextAttemptAtUtcMs),
      lastError: lastError == null && nullToAbsent
          ? const Value.absent()
          : Value(lastError),
      createdAtUtcMs: Value(createdAtUtcMs),
      updatedAtUtcMs: Value(updatedAtUtcMs),
    );
  }

  factory SyncQueueRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncQueueRow(
      id: serializer.fromJson<int>(json['id']),
      kind: $SyncQueueRowsTable.$converterkind.fromJson(
        serializer.fromJson<String>(json['kind']),
      ),
      idempotencyKey: serializer.fromJson<String?>(json['idempotencyKey']),
      payloadJson: serializer.fromJson<String>(json['payloadJson']),
      state: $SyncQueueRowsTable.$converterstate.fromJson(
        serializer.fromJson<String>(json['state']),
      ),
      attemptCount: serializer.fromJson<int>(json['attemptCount']),
      postParkAttemptCount: serializer.fromJson<int>(
        json['postParkAttemptCount'],
      ),
      nextAttemptAtUtcMs: serializer.fromJson<int>(json['nextAttemptAtUtcMs']),
      lastError: serializer.fromJson<String?>(json['lastError']),
      createdAtUtcMs: serializer.fromJson<int>(json['createdAtUtcMs']),
      updatedAtUtcMs: serializer.fromJson<int>(json['updatedAtUtcMs']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'kind': serializer.toJson<String>(
        $SyncQueueRowsTable.$converterkind.toJson(kind),
      ),
      'idempotencyKey': serializer.toJson<String?>(idempotencyKey),
      'payloadJson': serializer.toJson<String>(payloadJson),
      'state': serializer.toJson<String>(
        $SyncQueueRowsTable.$converterstate.toJson(state),
      ),
      'attemptCount': serializer.toJson<int>(attemptCount),
      'postParkAttemptCount': serializer.toJson<int>(postParkAttemptCount),
      'nextAttemptAtUtcMs': serializer.toJson<int>(nextAttemptAtUtcMs),
      'lastError': serializer.toJson<String?>(lastError),
      'createdAtUtcMs': serializer.toJson<int>(createdAtUtcMs),
      'updatedAtUtcMs': serializer.toJson<int>(updatedAtUtcMs),
    };
  }

  SyncQueueRow copyWith({
    int? id,
    SyncQueueKind? kind,
    Value<String?> idempotencyKey = const Value.absent(),
    String? payloadJson,
    SyncQueueState? state,
    int? attemptCount,
    int? postParkAttemptCount,
    int? nextAttemptAtUtcMs,
    Value<String?> lastError = const Value.absent(),
    int? createdAtUtcMs,
    int? updatedAtUtcMs,
  }) => SyncQueueRow(
    id: id ?? this.id,
    kind: kind ?? this.kind,
    idempotencyKey: idempotencyKey.present
        ? idempotencyKey.value
        : this.idempotencyKey,
    payloadJson: payloadJson ?? this.payloadJson,
    state: state ?? this.state,
    attemptCount: attemptCount ?? this.attemptCount,
    postParkAttemptCount: postParkAttemptCount ?? this.postParkAttemptCount,
    nextAttemptAtUtcMs: nextAttemptAtUtcMs ?? this.nextAttemptAtUtcMs,
    lastError: lastError.present ? lastError.value : this.lastError,
    createdAtUtcMs: createdAtUtcMs ?? this.createdAtUtcMs,
    updatedAtUtcMs: updatedAtUtcMs ?? this.updatedAtUtcMs,
  );
  SyncQueueRow copyWithCompanion(SyncQueueRowsCompanion data) {
    return SyncQueueRow(
      id: data.id.present ? data.id.value : this.id,
      kind: data.kind.present ? data.kind.value : this.kind,
      idempotencyKey: data.idempotencyKey.present
          ? data.idempotencyKey.value
          : this.idempotencyKey,
      payloadJson: data.payloadJson.present
          ? data.payloadJson.value
          : this.payloadJson,
      state: data.state.present ? data.state.value : this.state,
      attemptCount: data.attemptCount.present
          ? data.attemptCount.value
          : this.attemptCount,
      postParkAttemptCount: data.postParkAttemptCount.present
          ? data.postParkAttemptCount.value
          : this.postParkAttemptCount,
      nextAttemptAtUtcMs: data.nextAttemptAtUtcMs.present
          ? data.nextAttemptAtUtcMs.value
          : this.nextAttemptAtUtcMs,
      lastError: data.lastError.present ? data.lastError.value : this.lastError,
      createdAtUtcMs: data.createdAtUtcMs.present
          ? data.createdAtUtcMs.value
          : this.createdAtUtcMs,
      updatedAtUtcMs: data.updatedAtUtcMs.present
          ? data.updatedAtUtcMs.value
          : this.updatedAtUtcMs,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncQueueRow(')
          ..write('id: $id, ')
          ..write('kind: $kind, ')
          ..write('idempotencyKey: $idempotencyKey, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('state: $state, ')
          ..write('attemptCount: $attemptCount, ')
          ..write('postParkAttemptCount: $postParkAttemptCount, ')
          ..write('nextAttemptAtUtcMs: $nextAttemptAtUtcMs, ')
          ..write('lastError: $lastError, ')
          ..write('createdAtUtcMs: $createdAtUtcMs, ')
          ..write('updatedAtUtcMs: $updatedAtUtcMs')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    kind,
    idempotencyKey,
    payloadJson,
    state,
    attemptCount,
    postParkAttemptCount,
    nextAttemptAtUtcMs,
    lastError,
    createdAtUtcMs,
    updatedAtUtcMs,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncQueueRow &&
          other.id == this.id &&
          other.kind == this.kind &&
          other.idempotencyKey == this.idempotencyKey &&
          other.payloadJson == this.payloadJson &&
          other.state == this.state &&
          other.attemptCount == this.attemptCount &&
          other.postParkAttemptCount == this.postParkAttemptCount &&
          other.nextAttemptAtUtcMs == this.nextAttemptAtUtcMs &&
          other.lastError == this.lastError &&
          other.createdAtUtcMs == this.createdAtUtcMs &&
          other.updatedAtUtcMs == this.updatedAtUtcMs);
}

class SyncQueueRowsCompanion extends UpdateCompanion<SyncQueueRow> {
  final Value<int> id;
  final Value<SyncQueueKind> kind;
  final Value<String?> idempotencyKey;
  final Value<String> payloadJson;
  final Value<SyncQueueState> state;
  final Value<int> attemptCount;
  final Value<int> postParkAttemptCount;
  final Value<int> nextAttemptAtUtcMs;
  final Value<String?> lastError;
  final Value<int> createdAtUtcMs;
  final Value<int> updatedAtUtcMs;
  const SyncQueueRowsCompanion({
    this.id = const Value.absent(),
    this.kind = const Value.absent(),
    this.idempotencyKey = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.state = const Value.absent(),
    this.attemptCount = const Value.absent(),
    this.postParkAttemptCount = const Value.absent(),
    this.nextAttemptAtUtcMs = const Value.absent(),
    this.lastError = const Value.absent(),
    this.createdAtUtcMs = const Value.absent(),
    this.updatedAtUtcMs = const Value.absent(),
  });
  SyncQueueRowsCompanion.insert({
    this.id = const Value.absent(),
    required SyncQueueKind kind,
    this.idempotencyKey = const Value.absent(),
    required String payloadJson,
    required SyncQueueState state,
    this.attemptCount = const Value.absent(),
    this.postParkAttemptCount = const Value.absent(),
    this.nextAttemptAtUtcMs = const Value.absent(),
    this.lastError = const Value.absent(),
    required int createdAtUtcMs,
    required int updatedAtUtcMs,
  }) : kind = Value(kind),
       payloadJson = Value(payloadJson),
       state = Value(state),
       createdAtUtcMs = Value(createdAtUtcMs),
       updatedAtUtcMs = Value(updatedAtUtcMs);
  static Insertable<SyncQueueRow> custom({
    Expression<int>? id,
    Expression<String>? kind,
    Expression<String>? idempotencyKey,
    Expression<String>? payloadJson,
    Expression<String>? state,
    Expression<int>? attemptCount,
    Expression<int>? postParkAttemptCount,
    Expression<int>? nextAttemptAtUtcMs,
    Expression<String>? lastError,
    Expression<int>? createdAtUtcMs,
    Expression<int>? updatedAtUtcMs,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (kind != null) 'kind': kind,
      if (idempotencyKey != null) 'idempotency_key': idempotencyKey,
      if (payloadJson != null) 'payload_json': payloadJson,
      if (state != null) 'state': state,
      if (attemptCount != null) 'attempt_count': attemptCount,
      if (postParkAttemptCount != null)
        'post_park_attempt_count': postParkAttemptCount,
      if (nextAttemptAtUtcMs != null)
        'next_attempt_at_utc_ms': nextAttemptAtUtcMs,
      if (lastError != null) 'last_error': lastError,
      if (createdAtUtcMs != null) 'created_at_utc_ms': createdAtUtcMs,
      if (updatedAtUtcMs != null) 'updated_at_utc_ms': updatedAtUtcMs,
    });
  }

  SyncQueueRowsCompanion copyWith({
    Value<int>? id,
    Value<SyncQueueKind>? kind,
    Value<String?>? idempotencyKey,
    Value<String>? payloadJson,
    Value<SyncQueueState>? state,
    Value<int>? attemptCount,
    Value<int>? postParkAttemptCount,
    Value<int>? nextAttemptAtUtcMs,
    Value<String?>? lastError,
    Value<int>? createdAtUtcMs,
    Value<int>? updatedAtUtcMs,
  }) {
    return SyncQueueRowsCompanion(
      id: id ?? this.id,
      kind: kind ?? this.kind,
      idempotencyKey: idempotencyKey ?? this.idempotencyKey,
      payloadJson: payloadJson ?? this.payloadJson,
      state: state ?? this.state,
      attemptCount: attemptCount ?? this.attemptCount,
      postParkAttemptCount: postParkAttemptCount ?? this.postParkAttemptCount,
      nextAttemptAtUtcMs: nextAttemptAtUtcMs ?? this.nextAttemptAtUtcMs,
      lastError: lastError ?? this.lastError,
      createdAtUtcMs: createdAtUtcMs ?? this.createdAtUtcMs,
      updatedAtUtcMs: updatedAtUtcMs ?? this.updatedAtUtcMs,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(
        $SyncQueueRowsTable.$converterkind.toSql(kind.value),
      );
    }
    if (idempotencyKey.present) {
      map['idempotency_key'] = Variable<String>(idempotencyKey.value);
    }
    if (payloadJson.present) {
      map['payload_json'] = Variable<String>(payloadJson.value);
    }
    if (state.present) {
      map['state'] = Variable<String>(
        $SyncQueueRowsTable.$converterstate.toSql(state.value),
      );
    }
    if (attemptCount.present) {
      map['attempt_count'] = Variable<int>(attemptCount.value);
    }
    if (postParkAttemptCount.present) {
      map['post_park_attempt_count'] = Variable<int>(
        postParkAttemptCount.value,
      );
    }
    if (nextAttemptAtUtcMs.present) {
      map['next_attempt_at_utc_ms'] = Variable<int>(nextAttemptAtUtcMs.value);
    }
    if (lastError.present) {
      map['last_error'] = Variable<String>(lastError.value);
    }
    if (createdAtUtcMs.present) {
      map['created_at_utc_ms'] = Variable<int>(createdAtUtcMs.value);
    }
    if (updatedAtUtcMs.present) {
      map['updated_at_utc_ms'] = Variable<int>(updatedAtUtcMs.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncQueueRowsCompanion(')
          ..write('id: $id, ')
          ..write('kind: $kind, ')
          ..write('idempotencyKey: $idempotencyKey, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('state: $state, ')
          ..write('attemptCount: $attemptCount, ')
          ..write('postParkAttemptCount: $postParkAttemptCount, ')
          ..write('nextAttemptAtUtcMs: $nextAttemptAtUtcMs, ')
          ..write('lastError: $lastError, ')
          ..write('createdAtUtcMs: $createdAtUtcMs, ')
          ..write('updatedAtUtcMs: $updatedAtUtcMs')
          ..write(')'))
        .toString();
  }
}

class $KvRowsTable extends KvRows with TableInfo<$KvRowsTable, KvRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $KvRowsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueJsonMeta = const VerificationMeta(
    'valueJson',
  );
  @override
  late final GeneratedColumn<String> valueJson = GeneratedColumn<String>(
    'value_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _schemaVersionMeta = const VerificationMeta(
    'schemaVersion',
  );
  @override
  late final GeneratedColumn<int> schemaVersion = GeneratedColumn<int>(
    'schema_version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, valueJson, schemaVersion];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'kv';
  @override
  VerificationContext validateIntegrity(
    Insertable<KvRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value_json')) {
      context.handle(
        _valueJsonMeta,
        valueJson.isAcceptableOrUnknown(data['value_json']!, _valueJsonMeta),
      );
    } else if (isInserting) {
      context.missing(_valueJsonMeta);
    }
    if (data.containsKey('schema_version')) {
      context.handle(
        _schemaVersionMeta,
        schemaVersion.isAcceptableOrUnknown(
          data['schema_version']!,
          _schemaVersionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_schemaVersionMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  KvRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return KvRow(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      valueJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value_json'],
      )!,
      schemaVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}schema_version'],
      )!,
    );
  }

  @override
  $KvRowsTable createAlias(String alias) {
    return $KvRowsTable(attachedDatabase, alias);
  }
}

class KvRow extends DataClass implements Insertable<KvRow> {
  final String key;
  final String valueJson;
  final int schemaVersion;
  const KvRow({
    required this.key,
    required this.valueJson,
    required this.schemaVersion,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value_json'] = Variable<String>(valueJson);
    map['schema_version'] = Variable<int>(schemaVersion);
    return map;
  }

  KvRowsCompanion toCompanion(bool nullToAbsent) {
    return KvRowsCompanion(
      key: Value(key),
      valueJson: Value(valueJson),
      schemaVersion: Value(schemaVersion),
    );
  }

  factory KvRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return KvRow(
      key: serializer.fromJson<String>(json['key']),
      valueJson: serializer.fromJson<String>(json['valueJson']),
      schemaVersion: serializer.fromJson<int>(json['schemaVersion']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'valueJson': serializer.toJson<String>(valueJson),
      'schemaVersion': serializer.toJson<int>(schemaVersion),
    };
  }

  KvRow copyWith({String? key, String? valueJson, int? schemaVersion}) => KvRow(
    key: key ?? this.key,
    valueJson: valueJson ?? this.valueJson,
    schemaVersion: schemaVersion ?? this.schemaVersion,
  );
  KvRow copyWithCompanion(KvRowsCompanion data) {
    return KvRow(
      key: data.key.present ? data.key.value : this.key,
      valueJson: data.valueJson.present ? data.valueJson.value : this.valueJson,
      schemaVersion: data.schemaVersion.present
          ? data.schemaVersion.value
          : this.schemaVersion,
    );
  }

  @override
  String toString() {
    return (StringBuffer('KvRow(')
          ..write('key: $key, ')
          ..write('valueJson: $valueJson, ')
          ..write('schemaVersion: $schemaVersion')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, valueJson, schemaVersion);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is KvRow &&
          other.key == this.key &&
          other.valueJson == this.valueJson &&
          other.schemaVersion == this.schemaVersion);
}

class KvRowsCompanion extends UpdateCompanion<KvRow> {
  final Value<String> key;
  final Value<String> valueJson;
  final Value<int> schemaVersion;
  final Value<int> rowid;
  const KvRowsCompanion({
    this.key = const Value.absent(),
    this.valueJson = const Value.absent(),
    this.schemaVersion = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  KvRowsCompanion.insert({
    required String key,
    required String valueJson,
    required int schemaVersion,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       valueJson = Value(valueJson),
       schemaVersion = Value(schemaVersion);
  static Insertable<KvRow> custom({
    Expression<String>? key,
    Expression<String>? valueJson,
    Expression<int>? schemaVersion,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (valueJson != null) 'value_json': valueJson,
      if (schemaVersion != null) 'schema_version': schemaVersion,
      if (rowid != null) 'rowid': rowid,
    });
  }

  KvRowsCompanion copyWith({
    Value<String>? key,
    Value<String>? valueJson,
    Value<int>? schemaVersion,
    Value<int>? rowid,
  }) {
    return KvRowsCompanion(
      key: key ?? this.key,
      valueJson: valueJson ?? this.valueJson,
      schemaVersion: schemaVersion ?? this.schemaVersion,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (valueJson.present) {
      map['value_json'] = Variable<String>(valueJson.value);
    }
    if (schemaVersion.present) {
      map['schema_version'] = Variable<int>(schemaVersion.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('KvRowsCompanion(')
          ..write('key: $key, ')
          ..write('valueJson: $valueJson, ')
          ..write('schemaVersion: $schemaVersion, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $PlayersTable players = $PlayersTable(this);
  late final $SettingsRowsTable settingsRows = $SettingsRowsTable(this);
  late final $JourneyProgressRowsTable journeyProgressRows =
      $JourneyProgressRowsTable(this);
  late final $PersonalBestsTable personalBests = $PersonalBestsTable(this);
  late final $DailyEntriesTable dailyEntries = $DailyEntriesTable(this);
  late final $DailyAttemptsTable dailyAttempts = $DailyAttemptsTable(this);
  late final $DailyStreaksTable dailyStreaks = $DailyStreaksTable(this);
  late final $DailyPuzzleCacheRowsTable dailyPuzzleCacheRows =
      $DailyPuzzleCacheRowsTable(this);
  late final $SyncQueueRowsTable syncQueueRows = $SyncQueueRowsTable(this);
  late final $KvRowsTable kvRows = $KvRowsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    players,
    settingsRows,
    journeyProgressRows,
    personalBests,
    dailyEntries,
    dailyAttempts,
    dailyStreaks,
    dailyPuzzleCacheRows,
    syncQueueRows,
    kvRows,
  ];
}

typedef $$PlayersTableCreateCompanionBuilder =
    PlayersCompanion Function({
      required String guestId,
      Value<String?> firebaseUid,
      required int createdAtUtcMs,
      Value<int> rowid,
    });
typedef $$PlayersTableUpdateCompanionBuilder =
    PlayersCompanion Function({
      Value<String> guestId,
      Value<String?> firebaseUid,
      Value<int> createdAtUtcMs,
      Value<int> rowid,
    });

class $$PlayersTableFilterComposer
    extends Composer<_$AppDatabase, $PlayersTable> {
  $$PlayersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get guestId => $composableBuilder(
    column: $table.guestId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get firebaseUid => $composableBuilder(
    column: $table.firebaseUid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAtUtcMs => $composableBuilder(
    column: $table.createdAtUtcMs,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PlayersTableOrderingComposer
    extends Composer<_$AppDatabase, $PlayersTable> {
  $$PlayersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get guestId => $composableBuilder(
    column: $table.guestId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get firebaseUid => $composableBuilder(
    column: $table.firebaseUid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAtUtcMs => $composableBuilder(
    column: $table.createdAtUtcMs,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PlayersTableAnnotationComposer
    extends Composer<_$AppDatabase, $PlayersTable> {
  $$PlayersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get guestId =>
      $composableBuilder(column: $table.guestId, builder: (column) => column);

  GeneratedColumn<String> get firebaseUid => $composableBuilder(
    column: $table.firebaseUid,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAtUtcMs => $composableBuilder(
    column: $table.createdAtUtcMs,
    builder: (column) => column,
  );
}

class $$PlayersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PlayersTable,
          Player,
          $$PlayersTableFilterComposer,
          $$PlayersTableOrderingComposer,
          $$PlayersTableAnnotationComposer,
          $$PlayersTableCreateCompanionBuilder,
          $$PlayersTableUpdateCompanionBuilder,
          (Player, BaseReferences<_$AppDatabase, $PlayersTable, Player>),
          Player,
          PrefetchHooks Function()
        > {
  $$PlayersTableTableManager(_$AppDatabase db, $PlayersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PlayersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PlayersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PlayersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> guestId = const Value.absent(),
                Value<String?> firebaseUid = const Value.absent(),
                Value<int> createdAtUtcMs = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PlayersCompanion(
                guestId: guestId,
                firebaseUid: firebaseUid,
                createdAtUtcMs: createdAtUtcMs,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String guestId,
                Value<String?> firebaseUid = const Value.absent(),
                required int createdAtUtcMs,
                Value<int> rowid = const Value.absent(),
              }) => PlayersCompanion.insert(
                guestId: guestId,
                firebaseUid: firebaseUid,
                createdAtUtcMs: createdAtUtcMs,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PlayersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PlayersTable,
      Player,
      $$PlayersTableFilterComposer,
      $$PlayersTableOrderingComposer,
      $$PlayersTableAnnotationComposer,
      $$PlayersTableCreateCompanionBuilder,
      $$PlayersTableUpdateCompanionBuilder,
      (Player, BaseReferences<_$AppDatabase, $PlayersTable, Player>),
      Player,
      PrefetchHooks Function()
    >;
typedef $$SettingsRowsTableCreateCompanionBuilder =
    SettingsRowsCompanion Function({
      required String guestId,
      Value<bool> soundEnabled,
      Value<bool> hapticsEnabled,
      Value<String> language,
      Value<int> rowid,
    });
typedef $$SettingsRowsTableUpdateCompanionBuilder =
    SettingsRowsCompanion Function({
      Value<String> guestId,
      Value<bool> soundEnabled,
      Value<bool> hapticsEnabled,
      Value<String> language,
      Value<int> rowid,
    });

class $$SettingsRowsTableFilterComposer
    extends Composer<_$AppDatabase, $SettingsRowsTable> {
  $$SettingsRowsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get guestId => $composableBuilder(
    column: $table.guestId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get soundEnabled => $composableBuilder(
    column: $table.soundEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get hapticsEnabled => $composableBuilder(
    column: $table.hapticsEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get language => $composableBuilder(
    column: $table.language,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SettingsRowsTableOrderingComposer
    extends Composer<_$AppDatabase, $SettingsRowsTable> {
  $$SettingsRowsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get guestId => $composableBuilder(
    column: $table.guestId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get soundEnabled => $composableBuilder(
    column: $table.soundEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get hapticsEnabled => $composableBuilder(
    column: $table.hapticsEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get language => $composableBuilder(
    column: $table.language,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SettingsRowsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SettingsRowsTable> {
  $$SettingsRowsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get guestId =>
      $composableBuilder(column: $table.guestId, builder: (column) => column);

  GeneratedColumn<bool> get soundEnabled => $composableBuilder(
    column: $table.soundEnabled,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get hapticsEnabled => $composableBuilder(
    column: $table.hapticsEnabled,
    builder: (column) => column,
  );

  GeneratedColumn<String> get language =>
      $composableBuilder(column: $table.language, builder: (column) => column);
}

class $$SettingsRowsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SettingsRowsTable,
          SettingsRow,
          $$SettingsRowsTableFilterComposer,
          $$SettingsRowsTableOrderingComposer,
          $$SettingsRowsTableAnnotationComposer,
          $$SettingsRowsTableCreateCompanionBuilder,
          $$SettingsRowsTableUpdateCompanionBuilder,
          (
            SettingsRow,
            BaseReferences<_$AppDatabase, $SettingsRowsTable, SettingsRow>,
          ),
          SettingsRow,
          PrefetchHooks Function()
        > {
  $$SettingsRowsTableTableManager(_$AppDatabase db, $SettingsRowsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SettingsRowsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SettingsRowsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SettingsRowsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> guestId = const Value.absent(),
                Value<bool> soundEnabled = const Value.absent(),
                Value<bool> hapticsEnabled = const Value.absent(),
                Value<String> language = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SettingsRowsCompanion(
                guestId: guestId,
                soundEnabled: soundEnabled,
                hapticsEnabled: hapticsEnabled,
                language: language,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String guestId,
                Value<bool> soundEnabled = const Value.absent(),
                Value<bool> hapticsEnabled = const Value.absent(),
                Value<String> language = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SettingsRowsCompanion.insert(
                guestId: guestId,
                soundEnabled: soundEnabled,
                hapticsEnabled: hapticsEnabled,
                language: language,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SettingsRowsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SettingsRowsTable,
      SettingsRow,
      $$SettingsRowsTableFilterComposer,
      $$SettingsRowsTableOrderingComposer,
      $$SettingsRowsTableAnnotationComposer,
      $$SettingsRowsTableCreateCompanionBuilder,
      $$SettingsRowsTableUpdateCompanionBuilder,
      (
        SettingsRow,
        BaseReferences<_$AppDatabase, $SettingsRowsTable, SettingsRow>,
      ),
      SettingsRow,
      PrefetchHooks Function()
    >;
typedef $$JourneyProgressRowsTableCreateCompanionBuilder =
    JourneyProgressRowsCompanion Function({
      required String guestId,
      Value<int> highestUnlockedLevel,
      Value<String> completedLevelsCsv,
      Value<int> rowid,
    });
typedef $$JourneyProgressRowsTableUpdateCompanionBuilder =
    JourneyProgressRowsCompanion Function({
      Value<String> guestId,
      Value<int> highestUnlockedLevel,
      Value<String> completedLevelsCsv,
      Value<int> rowid,
    });

class $$JourneyProgressRowsTableFilterComposer
    extends Composer<_$AppDatabase, $JourneyProgressRowsTable> {
  $$JourneyProgressRowsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get guestId => $composableBuilder(
    column: $table.guestId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get highestUnlockedLevel => $composableBuilder(
    column: $table.highestUnlockedLevel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get completedLevelsCsv => $composableBuilder(
    column: $table.completedLevelsCsv,
    builder: (column) => ColumnFilters(column),
  );
}

class $$JourneyProgressRowsTableOrderingComposer
    extends Composer<_$AppDatabase, $JourneyProgressRowsTable> {
  $$JourneyProgressRowsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get guestId => $composableBuilder(
    column: $table.guestId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get highestUnlockedLevel => $composableBuilder(
    column: $table.highestUnlockedLevel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get completedLevelsCsv => $composableBuilder(
    column: $table.completedLevelsCsv,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$JourneyProgressRowsTableAnnotationComposer
    extends Composer<_$AppDatabase, $JourneyProgressRowsTable> {
  $$JourneyProgressRowsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get guestId =>
      $composableBuilder(column: $table.guestId, builder: (column) => column);

  GeneratedColumn<int> get highestUnlockedLevel => $composableBuilder(
    column: $table.highestUnlockedLevel,
    builder: (column) => column,
  );

  GeneratedColumn<String> get completedLevelsCsv => $composableBuilder(
    column: $table.completedLevelsCsv,
    builder: (column) => column,
  );
}

class $$JourneyProgressRowsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $JourneyProgressRowsTable,
          JourneyProgressRow,
          $$JourneyProgressRowsTableFilterComposer,
          $$JourneyProgressRowsTableOrderingComposer,
          $$JourneyProgressRowsTableAnnotationComposer,
          $$JourneyProgressRowsTableCreateCompanionBuilder,
          $$JourneyProgressRowsTableUpdateCompanionBuilder,
          (
            JourneyProgressRow,
            BaseReferences<
              _$AppDatabase,
              $JourneyProgressRowsTable,
              JourneyProgressRow
            >,
          ),
          JourneyProgressRow,
          PrefetchHooks Function()
        > {
  $$JourneyProgressRowsTableTableManager(
    _$AppDatabase db,
    $JourneyProgressRowsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$JourneyProgressRowsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$JourneyProgressRowsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$JourneyProgressRowsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> guestId = const Value.absent(),
                Value<int> highestUnlockedLevel = const Value.absent(),
                Value<String> completedLevelsCsv = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => JourneyProgressRowsCompanion(
                guestId: guestId,
                highestUnlockedLevel: highestUnlockedLevel,
                completedLevelsCsv: completedLevelsCsv,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String guestId,
                Value<int> highestUnlockedLevel = const Value.absent(),
                Value<String> completedLevelsCsv = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => JourneyProgressRowsCompanion.insert(
                guestId: guestId,
                highestUnlockedLevel: highestUnlockedLevel,
                completedLevelsCsv: completedLevelsCsv,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$JourneyProgressRowsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $JourneyProgressRowsTable,
      JourneyProgressRow,
      $$JourneyProgressRowsTableFilterComposer,
      $$JourneyProgressRowsTableOrderingComposer,
      $$JourneyProgressRowsTableAnnotationComposer,
      $$JourneyProgressRowsTableCreateCompanionBuilder,
      $$JourneyProgressRowsTableUpdateCompanionBuilder,
      (
        JourneyProgressRow,
        BaseReferences<
          _$AppDatabase,
          $JourneyProgressRowsTable,
          JourneyProgressRow
        >,
      ),
      JourneyProgressRow,
      PrefetchHooks Function()
    >;
typedef $$PersonalBestsTableCreateCompanionBuilder =
    PersonalBestsCompanion Function({
      required String guestId,
      required String levelId,
      required int bestMoveCount,
      required int stars,
      required bool isPerfect,
      required int firstCompletedAtUtcMs,
      Value<int> rowid,
    });
typedef $$PersonalBestsTableUpdateCompanionBuilder =
    PersonalBestsCompanion Function({
      Value<String> guestId,
      Value<String> levelId,
      Value<int> bestMoveCount,
      Value<int> stars,
      Value<bool> isPerfect,
      Value<int> firstCompletedAtUtcMs,
      Value<int> rowid,
    });

class $$PersonalBestsTableFilterComposer
    extends Composer<_$AppDatabase, $PersonalBestsTable> {
  $$PersonalBestsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get guestId => $composableBuilder(
    column: $table.guestId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get levelId => $composableBuilder(
    column: $table.levelId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get bestMoveCount => $composableBuilder(
    column: $table.bestMoveCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get stars => $composableBuilder(
    column: $table.stars,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isPerfect => $composableBuilder(
    column: $table.isPerfect,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get firstCompletedAtUtcMs => $composableBuilder(
    column: $table.firstCompletedAtUtcMs,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PersonalBestsTableOrderingComposer
    extends Composer<_$AppDatabase, $PersonalBestsTable> {
  $$PersonalBestsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get guestId => $composableBuilder(
    column: $table.guestId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get levelId => $composableBuilder(
    column: $table.levelId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get bestMoveCount => $composableBuilder(
    column: $table.bestMoveCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get stars => $composableBuilder(
    column: $table.stars,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isPerfect => $composableBuilder(
    column: $table.isPerfect,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get firstCompletedAtUtcMs => $composableBuilder(
    column: $table.firstCompletedAtUtcMs,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PersonalBestsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PersonalBestsTable> {
  $$PersonalBestsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get guestId =>
      $composableBuilder(column: $table.guestId, builder: (column) => column);

  GeneratedColumn<String> get levelId =>
      $composableBuilder(column: $table.levelId, builder: (column) => column);

  GeneratedColumn<int> get bestMoveCount => $composableBuilder(
    column: $table.bestMoveCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get stars =>
      $composableBuilder(column: $table.stars, builder: (column) => column);

  GeneratedColumn<bool> get isPerfect =>
      $composableBuilder(column: $table.isPerfect, builder: (column) => column);

  GeneratedColumn<int> get firstCompletedAtUtcMs => $composableBuilder(
    column: $table.firstCompletedAtUtcMs,
    builder: (column) => column,
  );
}

class $$PersonalBestsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PersonalBestsTable,
          PersonalBest,
          $$PersonalBestsTableFilterComposer,
          $$PersonalBestsTableOrderingComposer,
          $$PersonalBestsTableAnnotationComposer,
          $$PersonalBestsTableCreateCompanionBuilder,
          $$PersonalBestsTableUpdateCompanionBuilder,
          (
            PersonalBest,
            BaseReferences<_$AppDatabase, $PersonalBestsTable, PersonalBest>,
          ),
          PersonalBest,
          PrefetchHooks Function()
        > {
  $$PersonalBestsTableTableManager(_$AppDatabase db, $PersonalBestsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PersonalBestsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PersonalBestsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PersonalBestsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> guestId = const Value.absent(),
                Value<String> levelId = const Value.absent(),
                Value<int> bestMoveCount = const Value.absent(),
                Value<int> stars = const Value.absent(),
                Value<bool> isPerfect = const Value.absent(),
                Value<int> firstCompletedAtUtcMs = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PersonalBestsCompanion(
                guestId: guestId,
                levelId: levelId,
                bestMoveCount: bestMoveCount,
                stars: stars,
                isPerfect: isPerfect,
                firstCompletedAtUtcMs: firstCompletedAtUtcMs,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String guestId,
                required String levelId,
                required int bestMoveCount,
                required int stars,
                required bool isPerfect,
                required int firstCompletedAtUtcMs,
                Value<int> rowid = const Value.absent(),
              }) => PersonalBestsCompanion.insert(
                guestId: guestId,
                levelId: levelId,
                bestMoveCount: bestMoveCount,
                stars: stars,
                isPerfect: isPerfect,
                firstCompletedAtUtcMs: firstCompletedAtUtcMs,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PersonalBestsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PersonalBestsTable,
      PersonalBest,
      $$PersonalBestsTableFilterComposer,
      $$PersonalBestsTableOrderingComposer,
      $$PersonalBestsTableAnnotationComposer,
      $$PersonalBestsTableCreateCompanionBuilder,
      $$PersonalBestsTableUpdateCompanionBuilder,
      (
        PersonalBest,
        BaseReferences<_$AppDatabase, $PersonalBestsTable, PersonalBest>,
      ),
      PersonalBest,
      PrefetchHooks Function()
    >;
typedef $$DailyEntriesTableCreateCompanionBuilder =
    DailyEntriesCompanion Function({
      required String guestId,
      required String lang,
      required String dailyDate,
      required String dailyId,
      required int firstRunMoveCount,
      required int firstRunDurationMs,
      required int firstRunStars,
      required int firstRunCompletedAtUtcMs,
      required DailySyncStatus syncStatus,
      Value<int> rowid,
    });
typedef $$DailyEntriesTableUpdateCompanionBuilder =
    DailyEntriesCompanion Function({
      Value<String> guestId,
      Value<String> lang,
      Value<String> dailyDate,
      Value<String> dailyId,
      Value<int> firstRunMoveCount,
      Value<int> firstRunDurationMs,
      Value<int> firstRunStars,
      Value<int> firstRunCompletedAtUtcMs,
      Value<DailySyncStatus> syncStatus,
      Value<int> rowid,
    });

class $$DailyEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $DailyEntriesTable> {
  $$DailyEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get guestId => $composableBuilder(
    column: $table.guestId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lang => $composableBuilder(
    column: $table.lang,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dailyDate => $composableBuilder(
    column: $table.dailyDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dailyId => $composableBuilder(
    column: $table.dailyId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get firstRunMoveCount => $composableBuilder(
    column: $table.firstRunMoveCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get firstRunDurationMs => $composableBuilder(
    column: $table.firstRunDurationMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get firstRunStars => $composableBuilder(
    column: $table.firstRunStars,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get firstRunCompletedAtUtcMs => $composableBuilder(
    column: $table.firstRunCompletedAtUtcMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<DailySyncStatus, DailySyncStatus, String>
  get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );
}

class $$DailyEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $DailyEntriesTable> {
  $$DailyEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get guestId => $composableBuilder(
    column: $table.guestId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lang => $composableBuilder(
    column: $table.lang,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dailyDate => $composableBuilder(
    column: $table.dailyDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dailyId => $composableBuilder(
    column: $table.dailyId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get firstRunMoveCount => $composableBuilder(
    column: $table.firstRunMoveCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get firstRunDurationMs => $composableBuilder(
    column: $table.firstRunDurationMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get firstRunStars => $composableBuilder(
    column: $table.firstRunStars,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get firstRunCompletedAtUtcMs => $composableBuilder(
    column: $table.firstRunCompletedAtUtcMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DailyEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $DailyEntriesTable> {
  $$DailyEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get guestId =>
      $composableBuilder(column: $table.guestId, builder: (column) => column);

  GeneratedColumn<String> get lang =>
      $composableBuilder(column: $table.lang, builder: (column) => column);

  GeneratedColumn<String> get dailyDate =>
      $composableBuilder(column: $table.dailyDate, builder: (column) => column);

  GeneratedColumn<String> get dailyId =>
      $composableBuilder(column: $table.dailyId, builder: (column) => column);

  GeneratedColumn<int> get firstRunMoveCount => $composableBuilder(
    column: $table.firstRunMoveCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get firstRunDurationMs => $composableBuilder(
    column: $table.firstRunDurationMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get firstRunStars => $composableBuilder(
    column: $table.firstRunStars,
    builder: (column) => column,
  );

  GeneratedColumn<int> get firstRunCompletedAtUtcMs => $composableBuilder(
    column: $table.firstRunCompletedAtUtcMs,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<DailySyncStatus, String> get syncStatus =>
      $composableBuilder(
        column: $table.syncStatus,
        builder: (column) => column,
      );
}

class $$DailyEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DailyEntriesTable,
          DailyEntry,
          $$DailyEntriesTableFilterComposer,
          $$DailyEntriesTableOrderingComposer,
          $$DailyEntriesTableAnnotationComposer,
          $$DailyEntriesTableCreateCompanionBuilder,
          $$DailyEntriesTableUpdateCompanionBuilder,
          (
            DailyEntry,
            BaseReferences<_$AppDatabase, $DailyEntriesTable, DailyEntry>,
          ),
          DailyEntry,
          PrefetchHooks Function()
        > {
  $$DailyEntriesTableTableManager(_$AppDatabase db, $DailyEntriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DailyEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DailyEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DailyEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> guestId = const Value.absent(),
                Value<String> lang = const Value.absent(),
                Value<String> dailyDate = const Value.absent(),
                Value<String> dailyId = const Value.absent(),
                Value<int> firstRunMoveCount = const Value.absent(),
                Value<int> firstRunDurationMs = const Value.absent(),
                Value<int> firstRunStars = const Value.absent(),
                Value<int> firstRunCompletedAtUtcMs = const Value.absent(),
                Value<DailySyncStatus> syncStatus = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DailyEntriesCompanion(
                guestId: guestId,
                lang: lang,
                dailyDate: dailyDate,
                dailyId: dailyId,
                firstRunMoveCount: firstRunMoveCount,
                firstRunDurationMs: firstRunDurationMs,
                firstRunStars: firstRunStars,
                firstRunCompletedAtUtcMs: firstRunCompletedAtUtcMs,
                syncStatus: syncStatus,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String guestId,
                required String lang,
                required String dailyDate,
                required String dailyId,
                required int firstRunMoveCount,
                required int firstRunDurationMs,
                required int firstRunStars,
                required int firstRunCompletedAtUtcMs,
                required DailySyncStatus syncStatus,
                Value<int> rowid = const Value.absent(),
              }) => DailyEntriesCompanion.insert(
                guestId: guestId,
                lang: lang,
                dailyDate: dailyDate,
                dailyId: dailyId,
                firstRunMoveCount: firstRunMoveCount,
                firstRunDurationMs: firstRunDurationMs,
                firstRunStars: firstRunStars,
                firstRunCompletedAtUtcMs: firstRunCompletedAtUtcMs,
                syncStatus: syncStatus,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DailyEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DailyEntriesTable,
      DailyEntry,
      $$DailyEntriesTableFilterComposer,
      $$DailyEntriesTableOrderingComposer,
      $$DailyEntriesTableAnnotationComposer,
      $$DailyEntriesTableCreateCompanionBuilder,
      $$DailyEntriesTableUpdateCompanionBuilder,
      (
        DailyEntry,
        BaseReferences<_$AppDatabase, $DailyEntriesTable, DailyEntry>,
      ),
      DailyEntry,
      PrefetchHooks Function()
    >;
typedef $$DailyAttemptsTableCreateCompanionBuilder =
    DailyAttemptsCompanion Function({
      required String guestId,
      required String lang,
      required String dailyDate,
      required int attemptNo,
      required int moveCount,
      required int durationMs,
      required int stars,
      required int completedAtUtcMs,
      Value<int> rowid,
    });
typedef $$DailyAttemptsTableUpdateCompanionBuilder =
    DailyAttemptsCompanion Function({
      Value<String> guestId,
      Value<String> lang,
      Value<String> dailyDate,
      Value<int> attemptNo,
      Value<int> moveCount,
      Value<int> durationMs,
      Value<int> stars,
      Value<int> completedAtUtcMs,
      Value<int> rowid,
    });

class $$DailyAttemptsTableFilterComposer
    extends Composer<_$AppDatabase, $DailyAttemptsTable> {
  $$DailyAttemptsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get guestId => $composableBuilder(
    column: $table.guestId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lang => $composableBuilder(
    column: $table.lang,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dailyDate => $composableBuilder(
    column: $table.dailyDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get attemptNo => $composableBuilder(
    column: $table.attemptNo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get moveCount => $composableBuilder(
    column: $table.moveCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get stars => $composableBuilder(
    column: $table.stars,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get completedAtUtcMs => $composableBuilder(
    column: $table.completedAtUtcMs,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DailyAttemptsTableOrderingComposer
    extends Composer<_$AppDatabase, $DailyAttemptsTable> {
  $$DailyAttemptsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get guestId => $composableBuilder(
    column: $table.guestId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lang => $composableBuilder(
    column: $table.lang,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dailyDate => $composableBuilder(
    column: $table.dailyDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get attemptNo => $composableBuilder(
    column: $table.attemptNo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get moveCount => $composableBuilder(
    column: $table.moveCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get stars => $composableBuilder(
    column: $table.stars,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get completedAtUtcMs => $composableBuilder(
    column: $table.completedAtUtcMs,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DailyAttemptsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DailyAttemptsTable> {
  $$DailyAttemptsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get guestId =>
      $composableBuilder(column: $table.guestId, builder: (column) => column);

  GeneratedColumn<String> get lang =>
      $composableBuilder(column: $table.lang, builder: (column) => column);

  GeneratedColumn<String> get dailyDate =>
      $composableBuilder(column: $table.dailyDate, builder: (column) => column);

  GeneratedColumn<int> get attemptNo =>
      $composableBuilder(column: $table.attemptNo, builder: (column) => column);

  GeneratedColumn<int> get moveCount =>
      $composableBuilder(column: $table.moveCount, builder: (column) => column);

  GeneratedColumn<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get stars =>
      $composableBuilder(column: $table.stars, builder: (column) => column);

  GeneratedColumn<int> get completedAtUtcMs => $composableBuilder(
    column: $table.completedAtUtcMs,
    builder: (column) => column,
  );
}

class $$DailyAttemptsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DailyAttemptsTable,
          DailyAttempt,
          $$DailyAttemptsTableFilterComposer,
          $$DailyAttemptsTableOrderingComposer,
          $$DailyAttemptsTableAnnotationComposer,
          $$DailyAttemptsTableCreateCompanionBuilder,
          $$DailyAttemptsTableUpdateCompanionBuilder,
          (
            DailyAttempt,
            BaseReferences<_$AppDatabase, $DailyAttemptsTable, DailyAttempt>,
          ),
          DailyAttempt,
          PrefetchHooks Function()
        > {
  $$DailyAttemptsTableTableManager(_$AppDatabase db, $DailyAttemptsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DailyAttemptsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DailyAttemptsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DailyAttemptsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> guestId = const Value.absent(),
                Value<String> lang = const Value.absent(),
                Value<String> dailyDate = const Value.absent(),
                Value<int> attemptNo = const Value.absent(),
                Value<int> moveCount = const Value.absent(),
                Value<int> durationMs = const Value.absent(),
                Value<int> stars = const Value.absent(),
                Value<int> completedAtUtcMs = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DailyAttemptsCompanion(
                guestId: guestId,
                lang: lang,
                dailyDate: dailyDate,
                attemptNo: attemptNo,
                moveCount: moveCount,
                durationMs: durationMs,
                stars: stars,
                completedAtUtcMs: completedAtUtcMs,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String guestId,
                required String lang,
                required String dailyDate,
                required int attemptNo,
                required int moveCount,
                required int durationMs,
                required int stars,
                required int completedAtUtcMs,
                Value<int> rowid = const Value.absent(),
              }) => DailyAttemptsCompanion.insert(
                guestId: guestId,
                lang: lang,
                dailyDate: dailyDate,
                attemptNo: attemptNo,
                moveCount: moveCount,
                durationMs: durationMs,
                stars: stars,
                completedAtUtcMs: completedAtUtcMs,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DailyAttemptsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DailyAttemptsTable,
      DailyAttempt,
      $$DailyAttemptsTableFilterComposer,
      $$DailyAttemptsTableOrderingComposer,
      $$DailyAttemptsTableAnnotationComposer,
      $$DailyAttemptsTableCreateCompanionBuilder,
      $$DailyAttemptsTableUpdateCompanionBuilder,
      (
        DailyAttempt,
        BaseReferences<_$AppDatabase, $DailyAttemptsTable, DailyAttempt>,
      ),
      DailyAttempt,
      PrefetchHooks Function()
    >;
typedef $$DailyStreaksTableCreateCompanionBuilder =
    DailyStreaksCompanion Function({
      required String guestId,
      Value<int> currentStreak,
      Value<int> bestStreak,
      Value<String?> lastCompletedDate,
      Value<int> rowid,
    });
typedef $$DailyStreaksTableUpdateCompanionBuilder =
    DailyStreaksCompanion Function({
      Value<String> guestId,
      Value<int> currentStreak,
      Value<int> bestStreak,
      Value<String?> lastCompletedDate,
      Value<int> rowid,
    });

class $$DailyStreaksTableFilterComposer
    extends Composer<_$AppDatabase, $DailyStreaksTable> {
  $$DailyStreaksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get guestId => $composableBuilder(
    column: $table.guestId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get currentStreak => $composableBuilder(
    column: $table.currentStreak,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get bestStreak => $composableBuilder(
    column: $table.bestStreak,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastCompletedDate => $composableBuilder(
    column: $table.lastCompletedDate,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DailyStreaksTableOrderingComposer
    extends Composer<_$AppDatabase, $DailyStreaksTable> {
  $$DailyStreaksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get guestId => $composableBuilder(
    column: $table.guestId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get currentStreak => $composableBuilder(
    column: $table.currentStreak,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get bestStreak => $composableBuilder(
    column: $table.bestStreak,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastCompletedDate => $composableBuilder(
    column: $table.lastCompletedDate,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DailyStreaksTableAnnotationComposer
    extends Composer<_$AppDatabase, $DailyStreaksTable> {
  $$DailyStreaksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get guestId =>
      $composableBuilder(column: $table.guestId, builder: (column) => column);

  GeneratedColumn<int> get currentStreak => $composableBuilder(
    column: $table.currentStreak,
    builder: (column) => column,
  );

  GeneratedColumn<int> get bestStreak => $composableBuilder(
    column: $table.bestStreak,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastCompletedDate => $composableBuilder(
    column: $table.lastCompletedDate,
    builder: (column) => column,
  );
}

class $$DailyStreaksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DailyStreaksTable,
          DailyStreak,
          $$DailyStreaksTableFilterComposer,
          $$DailyStreaksTableOrderingComposer,
          $$DailyStreaksTableAnnotationComposer,
          $$DailyStreaksTableCreateCompanionBuilder,
          $$DailyStreaksTableUpdateCompanionBuilder,
          (
            DailyStreak,
            BaseReferences<_$AppDatabase, $DailyStreaksTable, DailyStreak>,
          ),
          DailyStreak,
          PrefetchHooks Function()
        > {
  $$DailyStreaksTableTableManager(_$AppDatabase db, $DailyStreaksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DailyStreaksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DailyStreaksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DailyStreaksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> guestId = const Value.absent(),
                Value<int> currentStreak = const Value.absent(),
                Value<int> bestStreak = const Value.absent(),
                Value<String?> lastCompletedDate = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DailyStreaksCompanion(
                guestId: guestId,
                currentStreak: currentStreak,
                bestStreak: bestStreak,
                lastCompletedDate: lastCompletedDate,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String guestId,
                Value<int> currentStreak = const Value.absent(),
                Value<int> bestStreak = const Value.absent(),
                Value<String?> lastCompletedDate = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DailyStreaksCompanion.insert(
                guestId: guestId,
                currentStreak: currentStreak,
                bestStreak: bestStreak,
                lastCompletedDate: lastCompletedDate,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DailyStreaksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DailyStreaksTable,
      DailyStreak,
      $$DailyStreaksTableFilterComposer,
      $$DailyStreaksTableOrderingComposer,
      $$DailyStreaksTableAnnotationComposer,
      $$DailyStreaksTableCreateCompanionBuilder,
      $$DailyStreaksTableUpdateCompanionBuilder,
      (
        DailyStreak,
        BaseReferences<_$AppDatabase, $DailyStreaksTable, DailyStreak>,
      ),
      DailyStreak,
      PrefetchHooks Function()
    >;
typedef $$DailyPuzzleCacheRowsTableCreateCompanionBuilder =
    DailyPuzzleCacheRowsCompanion Function({
      required String lang,
      required String dailyDate,
      required String puzzleJson,
      required int fetchedAtUtcMs,
      Value<int> rowid,
    });
typedef $$DailyPuzzleCacheRowsTableUpdateCompanionBuilder =
    DailyPuzzleCacheRowsCompanion Function({
      Value<String> lang,
      Value<String> dailyDate,
      Value<String> puzzleJson,
      Value<int> fetchedAtUtcMs,
      Value<int> rowid,
    });

class $$DailyPuzzleCacheRowsTableFilterComposer
    extends Composer<_$AppDatabase, $DailyPuzzleCacheRowsTable> {
  $$DailyPuzzleCacheRowsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get lang => $composableBuilder(
    column: $table.lang,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dailyDate => $composableBuilder(
    column: $table.dailyDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get puzzleJson => $composableBuilder(
    column: $table.puzzleJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get fetchedAtUtcMs => $composableBuilder(
    column: $table.fetchedAtUtcMs,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DailyPuzzleCacheRowsTableOrderingComposer
    extends Composer<_$AppDatabase, $DailyPuzzleCacheRowsTable> {
  $$DailyPuzzleCacheRowsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get lang => $composableBuilder(
    column: $table.lang,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dailyDate => $composableBuilder(
    column: $table.dailyDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get puzzleJson => $composableBuilder(
    column: $table.puzzleJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get fetchedAtUtcMs => $composableBuilder(
    column: $table.fetchedAtUtcMs,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DailyPuzzleCacheRowsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DailyPuzzleCacheRowsTable> {
  $$DailyPuzzleCacheRowsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get lang =>
      $composableBuilder(column: $table.lang, builder: (column) => column);

  GeneratedColumn<String> get dailyDate =>
      $composableBuilder(column: $table.dailyDate, builder: (column) => column);

  GeneratedColumn<String> get puzzleJson => $composableBuilder(
    column: $table.puzzleJson,
    builder: (column) => column,
  );

  GeneratedColumn<int> get fetchedAtUtcMs => $composableBuilder(
    column: $table.fetchedAtUtcMs,
    builder: (column) => column,
  );
}

class $$DailyPuzzleCacheRowsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DailyPuzzleCacheRowsTable,
          DailyPuzzleCacheRow,
          $$DailyPuzzleCacheRowsTableFilterComposer,
          $$DailyPuzzleCacheRowsTableOrderingComposer,
          $$DailyPuzzleCacheRowsTableAnnotationComposer,
          $$DailyPuzzleCacheRowsTableCreateCompanionBuilder,
          $$DailyPuzzleCacheRowsTableUpdateCompanionBuilder,
          (
            DailyPuzzleCacheRow,
            BaseReferences<
              _$AppDatabase,
              $DailyPuzzleCacheRowsTable,
              DailyPuzzleCacheRow
            >,
          ),
          DailyPuzzleCacheRow,
          PrefetchHooks Function()
        > {
  $$DailyPuzzleCacheRowsTableTableManager(
    _$AppDatabase db,
    $DailyPuzzleCacheRowsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DailyPuzzleCacheRowsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DailyPuzzleCacheRowsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$DailyPuzzleCacheRowsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> lang = const Value.absent(),
                Value<String> dailyDate = const Value.absent(),
                Value<String> puzzleJson = const Value.absent(),
                Value<int> fetchedAtUtcMs = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DailyPuzzleCacheRowsCompanion(
                lang: lang,
                dailyDate: dailyDate,
                puzzleJson: puzzleJson,
                fetchedAtUtcMs: fetchedAtUtcMs,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String lang,
                required String dailyDate,
                required String puzzleJson,
                required int fetchedAtUtcMs,
                Value<int> rowid = const Value.absent(),
              }) => DailyPuzzleCacheRowsCompanion.insert(
                lang: lang,
                dailyDate: dailyDate,
                puzzleJson: puzzleJson,
                fetchedAtUtcMs: fetchedAtUtcMs,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DailyPuzzleCacheRowsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DailyPuzzleCacheRowsTable,
      DailyPuzzleCacheRow,
      $$DailyPuzzleCacheRowsTableFilterComposer,
      $$DailyPuzzleCacheRowsTableOrderingComposer,
      $$DailyPuzzleCacheRowsTableAnnotationComposer,
      $$DailyPuzzleCacheRowsTableCreateCompanionBuilder,
      $$DailyPuzzleCacheRowsTableUpdateCompanionBuilder,
      (
        DailyPuzzleCacheRow,
        BaseReferences<
          _$AppDatabase,
          $DailyPuzzleCacheRowsTable,
          DailyPuzzleCacheRow
        >,
      ),
      DailyPuzzleCacheRow,
      PrefetchHooks Function()
    >;
typedef $$SyncQueueRowsTableCreateCompanionBuilder =
    SyncQueueRowsCompanion Function({
      Value<int> id,
      required SyncQueueKind kind,
      Value<String?> idempotencyKey,
      required String payloadJson,
      required SyncQueueState state,
      Value<int> attemptCount,
      Value<int> postParkAttemptCount,
      Value<int> nextAttemptAtUtcMs,
      Value<String?> lastError,
      required int createdAtUtcMs,
      required int updatedAtUtcMs,
    });
typedef $$SyncQueueRowsTableUpdateCompanionBuilder =
    SyncQueueRowsCompanion Function({
      Value<int> id,
      Value<SyncQueueKind> kind,
      Value<String?> idempotencyKey,
      Value<String> payloadJson,
      Value<SyncQueueState> state,
      Value<int> attemptCount,
      Value<int> postParkAttemptCount,
      Value<int> nextAttemptAtUtcMs,
      Value<String?> lastError,
      Value<int> createdAtUtcMs,
      Value<int> updatedAtUtcMs,
    });

class $$SyncQueueRowsTableFilterComposer
    extends Composer<_$AppDatabase, $SyncQueueRowsTable> {
  $$SyncQueueRowsTableFilterComposer({
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

  ColumnWithTypeConverterFilters<SyncQueueKind, SyncQueueKind, String>
  get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get idempotencyKey => $composableBuilder(
    column: $table.idempotencyKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<SyncQueueState, SyncQueueState, String>
  get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<int> get attemptCount => $composableBuilder(
    column: $table.attemptCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get postParkAttemptCount => $composableBuilder(
    column: $table.postParkAttemptCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get nextAttemptAtUtcMs => $composableBuilder(
    column: $table.nextAttemptAtUtcMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAtUtcMs => $composableBuilder(
    column: $table.createdAtUtcMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAtUtcMs => $composableBuilder(
    column: $table.updatedAtUtcMs,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncQueueRowsTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncQueueRowsTable> {
  $$SyncQueueRowsTableOrderingComposer({
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

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get idempotencyKey => $composableBuilder(
    column: $table.idempotencyKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get attemptCount => $composableBuilder(
    column: $table.attemptCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get postParkAttemptCount => $composableBuilder(
    column: $table.postParkAttemptCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get nextAttemptAtUtcMs => $composableBuilder(
    column: $table.nextAttemptAtUtcMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAtUtcMs => $composableBuilder(
    column: $table.createdAtUtcMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAtUtcMs => $composableBuilder(
    column: $table.updatedAtUtcMs,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncQueueRowsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncQueueRowsTable> {
  $$SyncQueueRowsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<SyncQueueKind, String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get idempotencyKey => $composableBuilder(
    column: $table.idempotencyKey,
    builder: (column) => column,
  );

  GeneratedColumn<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<SyncQueueState, String> get state =>
      $composableBuilder(column: $table.state, builder: (column) => column);

  GeneratedColumn<int> get attemptCount => $composableBuilder(
    column: $table.attemptCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get postParkAttemptCount => $composableBuilder(
    column: $table.postParkAttemptCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get nextAttemptAtUtcMs => $composableBuilder(
    column: $table.nextAttemptAtUtcMs,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastError =>
      $composableBuilder(column: $table.lastError, builder: (column) => column);

  GeneratedColumn<int> get createdAtUtcMs => $composableBuilder(
    column: $table.createdAtUtcMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get updatedAtUtcMs => $composableBuilder(
    column: $table.updatedAtUtcMs,
    builder: (column) => column,
  );
}

class $$SyncQueueRowsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncQueueRowsTable,
          SyncQueueRow,
          $$SyncQueueRowsTableFilterComposer,
          $$SyncQueueRowsTableOrderingComposer,
          $$SyncQueueRowsTableAnnotationComposer,
          $$SyncQueueRowsTableCreateCompanionBuilder,
          $$SyncQueueRowsTableUpdateCompanionBuilder,
          (
            SyncQueueRow,
            BaseReferences<_$AppDatabase, $SyncQueueRowsTable, SyncQueueRow>,
          ),
          SyncQueueRow,
          PrefetchHooks Function()
        > {
  $$SyncQueueRowsTableTableManager(_$AppDatabase db, $SyncQueueRowsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncQueueRowsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncQueueRowsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncQueueRowsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<SyncQueueKind> kind = const Value.absent(),
                Value<String?> idempotencyKey = const Value.absent(),
                Value<String> payloadJson = const Value.absent(),
                Value<SyncQueueState> state = const Value.absent(),
                Value<int> attemptCount = const Value.absent(),
                Value<int> postParkAttemptCount = const Value.absent(),
                Value<int> nextAttemptAtUtcMs = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<int> createdAtUtcMs = const Value.absent(),
                Value<int> updatedAtUtcMs = const Value.absent(),
              }) => SyncQueueRowsCompanion(
                id: id,
                kind: kind,
                idempotencyKey: idempotencyKey,
                payloadJson: payloadJson,
                state: state,
                attemptCount: attemptCount,
                postParkAttemptCount: postParkAttemptCount,
                nextAttemptAtUtcMs: nextAttemptAtUtcMs,
                lastError: lastError,
                createdAtUtcMs: createdAtUtcMs,
                updatedAtUtcMs: updatedAtUtcMs,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required SyncQueueKind kind,
                Value<String?> idempotencyKey = const Value.absent(),
                required String payloadJson,
                required SyncQueueState state,
                Value<int> attemptCount = const Value.absent(),
                Value<int> postParkAttemptCount = const Value.absent(),
                Value<int> nextAttemptAtUtcMs = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                required int createdAtUtcMs,
                required int updatedAtUtcMs,
              }) => SyncQueueRowsCompanion.insert(
                id: id,
                kind: kind,
                idempotencyKey: idempotencyKey,
                payloadJson: payloadJson,
                state: state,
                attemptCount: attemptCount,
                postParkAttemptCount: postParkAttemptCount,
                nextAttemptAtUtcMs: nextAttemptAtUtcMs,
                lastError: lastError,
                createdAtUtcMs: createdAtUtcMs,
                updatedAtUtcMs: updatedAtUtcMs,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncQueueRowsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SyncQueueRowsTable,
      SyncQueueRow,
      $$SyncQueueRowsTableFilterComposer,
      $$SyncQueueRowsTableOrderingComposer,
      $$SyncQueueRowsTableAnnotationComposer,
      $$SyncQueueRowsTableCreateCompanionBuilder,
      $$SyncQueueRowsTableUpdateCompanionBuilder,
      (
        SyncQueueRow,
        BaseReferences<_$AppDatabase, $SyncQueueRowsTable, SyncQueueRow>,
      ),
      SyncQueueRow,
      PrefetchHooks Function()
    >;
typedef $$KvRowsTableCreateCompanionBuilder =
    KvRowsCompanion Function({
      required String key,
      required String valueJson,
      required int schemaVersion,
      Value<int> rowid,
    });
typedef $$KvRowsTableUpdateCompanionBuilder =
    KvRowsCompanion Function({
      Value<String> key,
      Value<String> valueJson,
      Value<int> schemaVersion,
      Value<int> rowid,
    });

class $$KvRowsTableFilterComposer
    extends Composer<_$AppDatabase, $KvRowsTable> {
  $$KvRowsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get valueJson => $composableBuilder(
    column: $table.valueJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get schemaVersion => $composableBuilder(
    column: $table.schemaVersion,
    builder: (column) => ColumnFilters(column),
  );
}

class $$KvRowsTableOrderingComposer
    extends Composer<_$AppDatabase, $KvRowsTable> {
  $$KvRowsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get valueJson => $composableBuilder(
    column: $table.valueJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get schemaVersion => $composableBuilder(
    column: $table.schemaVersion,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$KvRowsTableAnnotationComposer
    extends Composer<_$AppDatabase, $KvRowsTable> {
  $$KvRowsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get valueJson =>
      $composableBuilder(column: $table.valueJson, builder: (column) => column);

  GeneratedColumn<int> get schemaVersion => $composableBuilder(
    column: $table.schemaVersion,
    builder: (column) => column,
  );
}

class $$KvRowsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $KvRowsTable,
          KvRow,
          $$KvRowsTableFilterComposer,
          $$KvRowsTableOrderingComposer,
          $$KvRowsTableAnnotationComposer,
          $$KvRowsTableCreateCompanionBuilder,
          $$KvRowsTableUpdateCompanionBuilder,
          (KvRow, BaseReferences<_$AppDatabase, $KvRowsTable, KvRow>),
          KvRow,
          PrefetchHooks Function()
        > {
  $$KvRowsTableTableManager(_$AppDatabase db, $KvRowsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$KvRowsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$KvRowsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$KvRowsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String> valueJson = const Value.absent(),
                Value<int> schemaVersion = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => KvRowsCompanion(
                key: key,
                valueJson: valueJson,
                schemaVersion: schemaVersion,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String key,
                required String valueJson,
                required int schemaVersion,
                Value<int> rowid = const Value.absent(),
              }) => KvRowsCompanion.insert(
                key: key,
                valueJson: valueJson,
                schemaVersion: schemaVersion,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$KvRowsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $KvRowsTable,
      KvRow,
      $$KvRowsTableFilterComposer,
      $$KvRowsTableOrderingComposer,
      $$KvRowsTableAnnotationComposer,
      $$KvRowsTableCreateCompanionBuilder,
      $$KvRowsTableUpdateCompanionBuilder,
      (KvRow, BaseReferences<_$AppDatabase, $KvRowsTable, KvRow>),
      KvRow,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$PlayersTableTableManager get players =>
      $$PlayersTableTableManager(_db, _db.players);
  $$SettingsRowsTableTableManager get settingsRows =>
      $$SettingsRowsTableTableManager(_db, _db.settingsRows);
  $$JourneyProgressRowsTableTableManager get journeyProgressRows =>
      $$JourneyProgressRowsTableTableManager(_db, _db.journeyProgressRows);
  $$PersonalBestsTableTableManager get personalBests =>
      $$PersonalBestsTableTableManager(_db, _db.personalBests);
  $$DailyEntriesTableTableManager get dailyEntries =>
      $$DailyEntriesTableTableManager(_db, _db.dailyEntries);
  $$DailyAttemptsTableTableManager get dailyAttempts =>
      $$DailyAttemptsTableTableManager(_db, _db.dailyAttempts);
  $$DailyStreaksTableTableManager get dailyStreaks =>
      $$DailyStreaksTableTableManager(_db, _db.dailyStreaks);
  $$DailyPuzzleCacheRowsTableTableManager get dailyPuzzleCacheRows =>
      $$DailyPuzzleCacheRowsTableTableManager(_db, _db.dailyPuzzleCacheRows);
  $$SyncQueueRowsTableTableManager get syncQueueRows =>
      $$SyncQueueRowsTableTableManager(_db, _db.syncQueueRows);
  $$KvRowsTableTableManager get kvRows =>
      $$KvRowsTableTableManager(_db, _db.kvRows);
}
