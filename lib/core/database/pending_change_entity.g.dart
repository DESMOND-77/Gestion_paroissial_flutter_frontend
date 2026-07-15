// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pending_change_entity.dart';

// **************************************************************************
// _IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, invalid_use_of_protected_member, lines_longer_than_80_chars, constant_identifier_names, avoid_js_rounded_ints, no_leading_underscores_for_local_identifiers, require_trailing_commas, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_in_if_null_operators, library_private_types_in_public_api, prefer_const_constructors
// ignore_for_file: type=lint

extension GetPendingChangeEntityCollection on Isar {
  IsarCollection<int, PendingChangeEntity> get pendingChangeEntitys =>
      this.collection();
}

final PendingChangeEntitySchema = IsarGeneratedSchema(
  schema: IsarSchema(
    name: 'PendingChangeEntity',
    idName: 'id',
    embedded: false,
    properties: [
      IsarPropertySchema(
        name: 'syncCollection',
        type: IsarType.string,
      ),
      IsarPropertySchema(
        name: 'entityId',
        type: IsarType.string,
      ),
      IsarPropertySchema(
        name: 'dataJson',
        type: IsarType.string,
      ),
      IsarPropertySchema(
        name: 'queuedAt',
        type: IsarType.dateTime,
      ),
    ],
    indexes: [
      IsarIndexSchema(
        name: 'syncCollection',
        properties: [
          "syncCollection",
        ],
        unique: false,
        hash: false,
      ),
    ],
  ),
  converter: IsarObjectConverter<int, PendingChangeEntity>(
    serialize: serializePendingChangeEntity,
    deserialize: deserializePendingChangeEntity,
    deserializeProperty: deserializePendingChangeEntityProp,
  ),
  getEmbeddedSchemas: () => [],
);

@isarProtected
int serializePendingChangeEntity(
    IsarWriter writer, PendingChangeEntity object) {
  IsarCore.writeString(writer, 1, object.syncCollection);
  IsarCore.writeString(writer, 2, object.entityId);
  IsarCore.writeString(writer, 3, object.dataJson);
  IsarCore.writeLong(writer, 4, object.queuedAt.toUtc().microsecondsSinceEpoch);
  return object.id;
}

@isarProtected
PendingChangeEntity deserializePendingChangeEntity(IsarReader reader) {
  final object = PendingChangeEntity();
  object.id = IsarCore.readId(reader);
  object.syncCollection = IsarCore.readString(reader, 1) ?? '';
  object.entityId = IsarCore.readString(reader, 2) ?? '';
  object.dataJson = IsarCore.readString(reader, 3) ?? '';
  {
    final value = IsarCore.readLong(reader, 4);
    if (value == -9223372036854775808) {
      object.queuedAt =
          DateTime.fromMillisecondsSinceEpoch(0, isUtc: true).toLocal();
    } else {
      object.queuedAt =
          DateTime.fromMicrosecondsSinceEpoch(value, isUtc: true).toLocal();
    }
  }
  return object;
}

@isarProtected
dynamic deserializePendingChangeEntityProp(IsarReader reader, int property) {
  switch (property) {
    case 0:
      return IsarCore.readId(reader);
    case 1:
      return IsarCore.readString(reader, 1) ?? '';
    case 2:
      return IsarCore.readString(reader, 2) ?? '';
    case 3:
      return IsarCore.readString(reader, 3) ?? '';
    case 4:
      {
        final value = IsarCore.readLong(reader, 4);
        if (value == -9223372036854775808) {
          return DateTime.fromMillisecondsSinceEpoch(0, isUtc: true).toLocal();
        } else {
          return DateTime.fromMicrosecondsSinceEpoch(value, isUtc: true)
              .toLocal();
        }
      }
    default:
      throw ArgumentError('Unknown property: $property');
  }
}

sealed class _PendingChangeEntityUpdate {
  bool call({
    required int id,
    String? syncCollection,
    String? entityId,
    String? dataJson,
    DateTime? queuedAt,
  });
}

class _PendingChangeEntityUpdateImpl implements _PendingChangeEntityUpdate {
  const _PendingChangeEntityUpdateImpl(this.collection);

  final IsarCollection<int, PendingChangeEntity> collection;

  @override
  bool call({
    required int id,
    Object? syncCollection = ignore,
    Object? entityId = ignore,
    Object? dataJson = ignore,
    Object? queuedAt = ignore,
  }) {
    return collection.updateProperties([
          id
        ], {
          if (syncCollection != ignore) 1: syncCollection as String?,
          if (entityId != ignore) 2: entityId as String?,
          if (dataJson != ignore) 3: dataJson as String?,
          if (queuedAt != ignore) 4: queuedAt as DateTime?,
        }) >
        0;
  }
}

sealed class _PendingChangeEntityUpdateAll {
  int call({
    required List<int> id,
    String? syncCollection,
    String? entityId,
    String? dataJson,
    DateTime? queuedAt,
  });
}

class _PendingChangeEntityUpdateAllImpl
    implements _PendingChangeEntityUpdateAll {
  const _PendingChangeEntityUpdateAllImpl(this.collection);

  final IsarCollection<int, PendingChangeEntity> collection;

  @override
  int call({
    required List<int> id,
    Object? syncCollection = ignore,
    Object? entityId = ignore,
    Object? dataJson = ignore,
    Object? queuedAt = ignore,
  }) {
    return collection.updateProperties(id, {
      if (syncCollection != ignore) 1: syncCollection as String?,
      if (entityId != ignore) 2: entityId as String?,
      if (dataJson != ignore) 3: dataJson as String?,
      if (queuedAt != ignore) 4: queuedAt as DateTime?,
    });
  }
}

extension PendingChangeEntityUpdate
    on IsarCollection<int, PendingChangeEntity> {
  _PendingChangeEntityUpdate get update => _PendingChangeEntityUpdateImpl(this);

  _PendingChangeEntityUpdateAll get updateAll =>
      _PendingChangeEntityUpdateAllImpl(this);
}

sealed class _PendingChangeEntityQueryUpdate {
  int call({
    String? syncCollection,
    String? entityId,
    String? dataJson,
    DateTime? queuedAt,
  });
}

class _PendingChangeEntityQueryUpdateImpl
    implements _PendingChangeEntityQueryUpdate {
  const _PendingChangeEntityQueryUpdateImpl(this.query, {this.limit});

  final IsarQuery<PendingChangeEntity> query;
  final int? limit;

  @override
  int call({
    Object? syncCollection = ignore,
    Object? entityId = ignore,
    Object? dataJson = ignore,
    Object? queuedAt = ignore,
  }) {
    return query.updateProperties(limit: limit, {
      if (syncCollection != ignore) 1: syncCollection as String?,
      if (entityId != ignore) 2: entityId as String?,
      if (dataJson != ignore) 3: dataJson as String?,
      if (queuedAt != ignore) 4: queuedAt as DateTime?,
    });
  }
}

extension PendingChangeEntityQueryUpdate on IsarQuery<PendingChangeEntity> {
  _PendingChangeEntityQueryUpdate get updateFirst =>
      _PendingChangeEntityQueryUpdateImpl(this, limit: 1);

  _PendingChangeEntityQueryUpdate get updateAll =>
      _PendingChangeEntityQueryUpdateImpl(this);
}

class _PendingChangeEntityQueryBuilderUpdateImpl
    implements _PendingChangeEntityQueryUpdate {
  const _PendingChangeEntityQueryBuilderUpdateImpl(this.query, {this.limit});

  final QueryBuilder<PendingChangeEntity, PendingChangeEntity, QOperations>
      query;
  final int? limit;

  @override
  int call({
    Object? syncCollection = ignore,
    Object? entityId = ignore,
    Object? dataJson = ignore,
    Object? queuedAt = ignore,
  }) {
    final q = query.build();
    try {
      return q.updateProperties(limit: limit, {
        if (syncCollection != ignore) 1: syncCollection as String?,
        if (entityId != ignore) 2: entityId as String?,
        if (dataJson != ignore) 3: dataJson as String?,
        if (queuedAt != ignore) 4: queuedAt as DateTime?,
      });
    } finally {
      q.close();
    }
  }
}

extension PendingChangeEntityQueryBuilderUpdate
    on QueryBuilder<PendingChangeEntity, PendingChangeEntity, QOperations> {
  _PendingChangeEntityQueryUpdate get updateFirst =>
      _PendingChangeEntityQueryBuilderUpdateImpl(this, limit: 1);

  _PendingChangeEntityQueryUpdate get updateAll =>
      _PendingChangeEntityQueryBuilderUpdateImpl(this);
}

extension PendingChangeEntityQueryFilter on QueryBuilder<PendingChangeEntity,
    PendingChangeEntity, QFilterCondition> {
  QueryBuilder<PendingChangeEntity, PendingChangeEntity, QAfterFilterCondition>
      idEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(
          property: 0,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<PendingChangeEntity, PendingChangeEntity, QAfterFilterCondition>
      idGreaterThan(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 0,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<PendingChangeEntity, PendingChangeEntity, QAfterFilterCondition>
      idGreaterThanOrEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 0,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<PendingChangeEntity, PendingChangeEntity, QAfterFilterCondition>
      idLessThan(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(
          property: 0,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<PendingChangeEntity, PendingChangeEntity, QAfterFilterCondition>
      idLessThanOrEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 0,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<PendingChangeEntity, PendingChangeEntity, QAfterFilterCondition>
      idBetween(
    int lower,
    int upper,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 0,
          lower: lower,
          upper: upper,
        ),
      );
    });
  }

  QueryBuilder<PendingChangeEntity, PendingChangeEntity, QAfterFilterCondition>
      syncCollectionEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(
          property: 1,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PendingChangeEntity, PendingChangeEntity, QAfterFilterCondition>
      syncCollectionGreaterThan(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 1,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PendingChangeEntity, PendingChangeEntity, QAfterFilterCondition>
      syncCollectionGreaterThanOrEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 1,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PendingChangeEntity, PendingChangeEntity, QAfterFilterCondition>
      syncCollectionLessThan(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(
          property: 1,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PendingChangeEntity, PendingChangeEntity, QAfterFilterCondition>
      syncCollectionLessThanOrEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 1,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PendingChangeEntity, PendingChangeEntity, QAfterFilterCondition>
      syncCollectionBetween(
    String lower,
    String upper, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 1,
          lower: lower,
          upper: upper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PendingChangeEntity, PendingChangeEntity, QAfterFilterCondition>
      syncCollectionStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        StartsWithCondition(
          property: 1,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PendingChangeEntity, PendingChangeEntity, QAfterFilterCondition>
      syncCollectionEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EndsWithCondition(
          property: 1,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PendingChangeEntity, PendingChangeEntity, QAfterFilterCondition>
      syncCollectionContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        ContainsCondition(
          property: 1,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PendingChangeEntity, PendingChangeEntity, QAfterFilterCondition>
      syncCollectionMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        MatchesCondition(
          property: 1,
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PendingChangeEntity, PendingChangeEntity, QAfterFilterCondition>
      syncCollectionIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(
          property: 1,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<PendingChangeEntity, PendingChangeEntity, QAfterFilterCondition>
      syncCollectionIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(
          property: 1,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<PendingChangeEntity, PendingChangeEntity, QAfterFilterCondition>
      entityIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(
          property: 2,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PendingChangeEntity, PendingChangeEntity, QAfterFilterCondition>
      entityIdGreaterThan(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 2,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PendingChangeEntity, PendingChangeEntity, QAfterFilterCondition>
      entityIdGreaterThanOrEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 2,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PendingChangeEntity, PendingChangeEntity, QAfterFilterCondition>
      entityIdLessThan(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(
          property: 2,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PendingChangeEntity, PendingChangeEntity, QAfterFilterCondition>
      entityIdLessThanOrEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 2,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PendingChangeEntity, PendingChangeEntity, QAfterFilterCondition>
      entityIdBetween(
    String lower,
    String upper, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 2,
          lower: lower,
          upper: upper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PendingChangeEntity, PendingChangeEntity, QAfterFilterCondition>
      entityIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        StartsWithCondition(
          property: 2,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PendingChangeEntity, PendingChangeEntity, QAfterFilterCondition>
      entityIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EndsWithCondition(
          property: 2,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PendingChangeEntity, PendingChangeEntity, QAfterFilterCondition>
      entityIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        ContainsCondition(
          property: 2,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PendingChangeEntity, PendingChangeEntity, QAfterFilterCondition>
      entityIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        MatchesCondition(
          property: 2,
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PendingChangeEntity, PendingChangeEntity, QAfterFilterCondition>
      entityIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(
          property: 2,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<PendingChangeEntity, PendingChangeEntity, QAfterFilterCondition>
      entityIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(
          property: 2,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<PendingChangeEntity, PendingChangeEntity, QAfterFilterCondition>
      dataJsonEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(
          property: 3,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PendingChangeEntity, PendingChangeEntity, QAfterFilterCondition>
      dataJsonGreaterThan(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 3,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PendingChangeEntity, PendingChangeEntity, QAfterFilterCondition>
      dataJsonGreaterThanOrEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 3,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PendingChangeEntity, PendingChangeEntity, QAfterFilterCondition>
      dataJsonLessThan(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(
          property: 3,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PendingChangeEntity, PendingChangeEntity, QAfterFilterCondition>
      dataJsonLessThanOrEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 3,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PendingChangeEntity, PendingChangeEntity, QAfterFilterCondition>
      dataJsonBetween(
    String lower,
    String upper, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 3,
          lower: lower,
          upper: upper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PendingChangeEntity, PendingChangeEntity, QAfterFilterCondition>
      dataJsonStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        StartsWithCondition(
          property: 3,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PendingChangeEntity, PendingChangeEntity, QAfterFilterCondition>
      dataJsonEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EndsWithCondition(
          property: 3,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PendingChangeEntity, PendingChangeEntity, QAfterFilterCondition>
      dataJsonContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        ContainsCondition(
          property: 3,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PendingChangeEntity, PendingChangeEntity, QAfterFilterCondition>
      dataJsonMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        MatchesCondition(
          property: 3,
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PendingChangeEntity, PendingChangeEntity, QAfterFilterCondition>
      dataJsonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(
          property: 3,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<PendingChangeEntity, PendingChangeEntity, QAfterFilterCondition>
      dataJsonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(
          property: 3,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<PendingChangeEntity, PendingChangeEntity, QAfterFilterCondition>
      queuedAtEqualTo(
    DateTime value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(
          property: 4,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<PendingChangeEntity, PendingChangeEntity, QAfterFilterCondition>
      queuedAtGreaterThan(
    DateTime value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 4,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<PendingChangeEntity, PendingChangeEntity, QAfterFilterCondition>
      queuedAtGreaterThanOrEqualTo(
    DateTime value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 4,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<PendingChangeEntity, PendingChangeEntity, QAfterFilterCondition>
      queuedAtLessThan(
    DateTime value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(
          property: 4,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<PendingChangeEntity, PendingChangeEntity, QAfterFilterCondition>
      queuedAtLessThanOrEqualTo(
    DateTime value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 4,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<PendingChangeEntity, PendingChangeEntity, QAfterFilterCondition>
      queuedAtBetween(
    DateTime lower,
    DateTime upper,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 4,
          lower: lower,
          upper: upper,
        ),
      );
    });
  }
}

extension PendingChangeEntityQueryObject on QueryBuilder<PendingChangeEntity,
    PendingChangeEntity, QFilterCondition> {}

extension PendingChangeEntityQuerySortBy
    on QueryBuilder<PendingChangeEntity, PendingChangeEntity, QSortBy> {
  QueryBuilder<PendingChangeEntity, PendingChangeEntity, QAfterSortBy>
      sortById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(0);
    });
  }

  QueryBuilder<PendingChangeEntity, PendingChangeEntity, QAfterSortBy>
      sortByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(0, sort: Sort.desc);
    });
  }

  QueryBuilder<PendingChangeEntity, PendingChangeEntity, QAfterSortBy>
      sortBySyncCollection({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        1,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<PendingChangeEntity, PendingChangeEntity, QAfterSortBy>
      sortBySyncCollectionDesc({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        1,
        sort: Sort.desc,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<PendingChangeEntity, PendingChangeEntity, QAfterSortBy>
      sortByEntityId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        2,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<PendingChangeEntity, PendingChangeEntity, QAfterSortBy>
      sortByEntityIdDesc({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        2,
        sort: Sort.desc,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<PendingChangeEntity, PendingChangeEntity, QAfterSortBy>
      sortByDataJson({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        3,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<PendingChangeEntity, PendingChangeEntity, QAfterSortBy>
      sortByDataJsonDesc({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        3,
        sort: Sort.desc,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<PendingChangeEntity, PendingChangeEntity, QAfterSortBy>
      sortByQueuedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(4);
    });
  }

  QueryBuilder<PendingChangeEntity, PendingChangeEntity, QAfterSortBy>
      sortByQueuedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(4, sort: Sort.desc);
    });
  }
}

extension PendingChangeEntityQuerySortThenBy
    on QueryBuilder<PendingChangeEntity, PendingChangeEntity, QSortThenBy> {
  QueryBuilder<PendingChangeEntity, PendingChangeEntity, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(0);
    });
  }

  QueryBuilder<PendingChangeEntity, PendingChangeEntity, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(0, sort: Sort.desc);
    });
  }

  QueryBuilder<PendingChangeEntity, PendingChangeEntity, QAfterSortBy>
      thenBySyncCollection({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(1, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PendingChangeEntity, PendingChangeEntity, QAfterSortBy>
      thenBySyncCollectionDesc({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(1, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PendingChangeEntity, PendingChangeEntity, QAfterSortBy>
      thenByEntityId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(2, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PendingChangeEntity, PendingChangeEntity, QAfterSortBy>
      thenByEntityIdDesc({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(2, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PendingChangeEntity, PendingChangeEntity, QAfterSortBy>
      thenByDataJson({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(3, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PendingChangeEntity, PendingChangeEntity, QAfterSortBy>
      thenByDataJsonDesc({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(3, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PendingChangeEntity, PendingChangeEntity, QAfterSortBy>
      thenByQueuedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(4);
    });
  }

  QueryBuilder<PendingChangeEntity, PendingChangeEntity, QAfterSortBy>
      thenByQueuedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(4, sort: Sort.desc);
    });
  }
}

extension PendingChangeEntityQueryWhereDistinct
    on QueryBuilder<PendingChangeEntity, PendingChangeEntity, QDistinct> {
  QueryBuilder<PendingChangeEntity, PendingChangeEntity, QAfterDistinct>
      distinctBySyncCollection({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(1, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PendingChangeEntity, PendingChangeEntity, QAfterDistinct>
      distinctByEntityId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(2, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PendingChangeEntity, PendingChangeEntity, QAfterDistinct>
      distinctByDataJson({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(3, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PendingChangeEntity, PendingChangeEntity, QAfterDistinct>
      distinctByQueuedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(4);
    });
  }
}

extension PendingChangeEntityQueryProperty1
    on QueryBuilder<PendingChangeEntity, PendingChangeEntity, QProperty> {
  QueryBuilder<PendingChangeEntity, int, QAfterProperty> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(0);
    });
  }

  QueryBuilder<PendingChangeEntity, String, QAfterProperty>
      syncCollectionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(1);
    });
  }

  QueryBuilder<PendingChangeEntity, String, QAfterProperty> entityIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(2);
    });
  }

  QueryBuilder<PendingChangeEntity, String, QAfterProperty> dataJsonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(3);
    });
  }

  QueryBuilder<PendingChangeEntity, DateTime, QAfterProperty>
      queuedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(4);
    });
  }
}

extension PendingChangeEntityQueryProperty2<R>
    on QueryBuilder<PendingChangeEntity, R, QAfterProperty> {
  QueryBuilder<PendingChangeEntity, (R, int), QAfterProperty> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(0);
    });
  }

  QueryBuilder<PendingChangeEntity, (R, String), QAfterProperty>
      syncCollectionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(1);
    });
  }

  QueryBuilder<PendingChangeEntity, (R, String), QAfterProperty>
      entityIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(2);
    });
  }

  QueryBuilder<PendingChangeEntity, (R, String), QAfterProperty>
      dataJsonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(3);
    });
  }

  QueryBuilder<PendingChangeEntity, (R, DateTime), QAfterProperty>
      queuedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(4);
    });
  }
}

extension PendingChangeEntityQueryProperty3<R1, R2>
    on QueryBuilder<PendingChangeEntity, (R1, R2), QAfterProperty> {
  QueryBuilder<PendingChangeEntity, (R1, R2, int), QOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(0);
    });
  }

  QueryBuilder<PendingChangeEntity, (R1, R2, String), QOperations>
      syncCollectionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(1);
    });
  }

  QueryBuilder<PendingChangeEntity, (R1, R2, String), QOperations>
      entityIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(2);
    });
  }

  QueryBuilder<PendingChangeEntity, (R1, R2, String), QOperations>
      dataJsonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(3);
    });
  }

  QueryBuilder<PendingChangeEntity, (R1, R2, DateTime), QOperations>
      queuedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(4);
    });
  }
}
