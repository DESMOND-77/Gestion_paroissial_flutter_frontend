// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cached_entity.dart';

// **************************************************************************
// _IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, invalid_use_of_protected_member, lines_longer_than_80_chars, constant_identifier_names, avoid_js_rounded_ints, no_leading_underscores_for_local_identifiers, require_trailing_commas, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_in_if_null_operators, library_private_types_in_public_api, prefer_const_constructors
// ignore_for_file: type=lint

extension GetCachedEntityCollection on Isar {
  IsarCollection<int, CachedEntity> get cachedEntitys => this.collection();
}

final CachedEntitySchema = IsarGeneratedSchema(
  schema: IsarSchema(
    name: 'CachedEntity',
    idName: 'id',
    embedded: false,
    properties: [
      IsarPropertySchema(
        name: 'entityType',
        type: IsarType.string,
      ),
      IsarPropertySchema(
        name: 'entityId',
        type: IsarType.long,
      ),
      IsarPropertySchema(
        name: 'dataJson',
        type: IsarType.string,
      ),
      IsarPropertySchema(
        name: 'syncedAt',
        type: IsarType.dateTime,
      ),
    ],
    indexes: [
      IsarIndexSchema(
        name: 'entityType',
        properties: [
          "entityType",
        ],
        unique: false,
        hash: false,
      ),
    ],
  ),
  converter: IsarObjectConverter<int, CachedEntity>(
    serialize: serializeCachedEntity,
    deserialize: deserializeCachedEntity,
    deserializeProperty: deserializeCachedEntityProp,
  ),
  getEmbeddedSchemas: () => [],
);

@isarProtected
int serializeCachedEntity(IsarWriter writer, CachedEntity object) {
  IsarCore.writeString(writer, 1, object.entityType);
  IsarCore.writeLong(writer, 2, object.entityId);
  IsarCore.writeString(writer, 3, object.dataJson);
  IsarCore.writeLong(writer, 4, object.syncedAt.toUtc().microsecondsSinceEpoch);
  return object.id;
}

@isarProtected
CachedEntity deserializeCachedEntity(IsarReader reader) {
  final object = CachedEntity();
  object.id = IsarCore.readId(reader);
  object.entityType = IsarCore.readString(reader, 1) ?? '';
  object.entityId = IsarCore.readLong(reader, 2);
  object.dataJson = IsarCore.readString(reader, 3) ?? '';
  {
    final value = IsarCore.readLong(reader, 4);
    if (value == -9223372036854775808) {
      object.syncedAt =
          DateTime.fromMillisecondsSinceEpoch(0, isUtc: true).toLocal();
    } else {
      object.syncedAt =
          DateTime.fromMicrosecondsSinceEpoch(value, isUtc: true).toLocal();
    }
  }
  return object;
}

@isarProtected
dynamic deserializeCachedEntityProp(IsarReader reader, int property) {
  switch (property) {
    case 0:
      return IsarCore.readId(reader);
    case 1:
      return IsarCore.readString(reader, 1) ?? '';
    case 2:
      return IsarCore.readLong(reader, 2);
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

sealed class _CachedEntityUpdate {
  bool call({
    required int id,
    String? entityType,
    int? entityId,
    String? dataJson,
    DateTime? syncedAt,
  });
}

class _CachedEntityUpdateImpl implements _CachedEntityUpdate {
  const _CachedEntityUpdateImpl(this.collection);

  final IsarCollection<int, CachedEntity> collection;

  @override
  bool call({
    required int id,
    Object? entityType = ignore,
    Object? entityId = ignore,
    Object? dataJson = ignore,
    Object? syncedAt = ignore,
  }) {
    return collection.updateProperties([
          id
        ], {
          if (entityType != ignore) 1: entityType as String?,
          if (entityId != ignore) 2: entityId as int?,
          if (dataJson != ignore) 3: dataJson as String?,
          if (syncedAt != ignore) 4: syncedAt as DateTime?,
        }) >
        0;
  }
}

sealed class _CachedEntityUpdateAll {
  int call({
    required List<int> id,
    String? entityType,
    int? entityId,
    String? dataJson,
    DateTime? syncedAt,
  });
}

class _CachedEntityUpdateAllImpl implements _CachedEntityUpdateAll {
  const _CachedEntityUpdateAllImpl(this.collection);

  final IsarCollection<int, CachedEntity> collection;

  @override
  int call({
    required List<int> id,
    Object? entityType = ignore,
    Object? entityId = ignore,
    Object? dataJson = ignore,
    Object? syncedAt = ignore,
  }) {
    return collection.updateProperties(id, {
      if (entityType != ignore) 1: entityType as String?,
      if (entityId != ignore) 2: entityId as int?,
      if (dataJson != ignore) 3: dataJson as String?,
      if (syncedAt != ignore) 4: syncedAt as DateTime?,
    });
  }
}

extension CachedEntityUpdate on IsarCollection<int, CachedEntity> {
  _CachedEntityUpdate get update => _CachedEntityUpdateImpl(this);

  _CachedEntityUpdateAll get updateAll => _CachedEntityUpdateAllImpl(this);
}

sealed class _CachedEntityQueryUpdate {
  int call({
    String? entityType,
    int? entityId,
    String? dataJson,
    DateTime? syncedAt,
  });
}

class _CachedEntityQueryUpdateImpl implements _CachedEntityQueryUpdate {
  const _CachedEntityQueryUpdateImpl(this.query, {this.limit});

  final IsarQuery<CachedEntity> query;
  final int? limit;

  @override
  int call({
    Object? entityType = ignore,
    Object? entityId = ignore,
    Object? dataJson = ignore,
    Object? syncedAt = ignore,
  }) {
    return query.updateProperties(limit: limit, {
      if (entityType != ignore) 1: entityType as String?,
      if (entityId != ignore) 2: entityId as int?,
      if (dataJson != ignore) 3: dataJson as String?,
      if (syncedAt != ignore) 4: syncedAt as DateTime?,
    });
  }
}

extension CachedEntityQueryUpdate on IsarQuery<CachedEntity> {
  _CachedEntityQueryUpdate get updateFirst =>
      _CachedEntityQueryUpdateImpl(this, limit: 1);

  _CachedEntityQueryUpdate get updateAll => _CachedEntityQueryUpdateImpl(this);
}

class _CachedEntityQueryBuilderUpdateImpl implements _CachedEntityQueryUpdate {
  const _CachedEntityQueryBuilderUpdateImpl(this.query, {this.limit});

  final QueryBuilder<CachedEntity, CachedEntity, QOperations> query;
  final int? limit;

  @override
  int call({
    Object? entityType = ignore,
    Object? entityId = ignore,
    Object? dataJson = ignore,
    Object? syncedAt = ignore,
  }) {
    final q = query.build();
    try {
      return q.updateProperties(limit: limit, {
        if (entityType != ignore) 1: entityType as String?,
        if (entityId != ignore) 2: entityId as int?,
        if (dataJson != ignore) 3: dataJson as String?,
        if (syncedAt != ignore) 4: syncedAt as DateTime?,
      });
    } finally {
      q.close();
    }
  }
}

extension CachedEntityQueryBuilderUpdate
    on QueryBuilder<CachedEntity, CachedEntity, QOperations> {
  _CachedEntityQueryUpdate get updateFirst =>
      _CachedEntityQueryBuilderUpdateImpl(this, limit: 1);

  _CachedEntityQueryUpdate get updateAll =>
      _CachedEntityQueryBuilderUpdateImpl(this);
}

extension CachedEntityQueryFilter
    on QueryBuilder<CachedEntity, CachedEntity, QFilterCondition> {
  QueryBuilder<CachedEntity, CachedEntity, QAfterFilterCondition> idEqualTo(
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

  QueryBuilder<CachedEntity, CachedEntity, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<CachedEntity, CachedEntity, QAfterFilterCondition>
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

  QueryBuilder<CachedEntity, CachedEntity, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<CachedEntity, CachedEntity, QAfterFilterCondition>
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

  QueryBuilder<CachedEntity, CachedEntity, QAfterFilterCondition> idBetween(
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

  QueryBuilder<CachedEntity, CachedEntity, QAfterFilterCondition>
      entityTypeEqualTo(
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

  QueryBuilder<CachedEntity, CachedEntity, QAfterFilterCondition>
      entityTypeGreaterThan(
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

  QueryBuilder<CachedEntity, CachedEntity, QAfterFilterCondition>
      entityTypeGreaterThanOrEqualTo(
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

  QueryBuilder<CachedEntity, CachedEntity, QAfterFilterCondition>
      entityTypeLessThan(
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

  QueryBuilder<CachedEntity, CachedEntity, QAfterFilterCondition>
      entityTypeLessThanOrEqualTo(
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

  QueryBuilder<CachedEntity, CachedEntity, QAfterFilterCondition>
      entityTypeBetween(
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

  QueryBuilder<CachedEntity, CachedEntity, QAfterFilterCondition>
      entityTypeStartsWith(
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

  QueryBuilder<CachedEntity, CachedEntity, QAfterFilterCondition>
      entityTypeEndsWith(
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

  QueryBuilder<CachedEntity, CachedEntity, QAfterFilterCondition>
      entityTypeContains(String value, {bool caseSensitive = true}) {
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

  QueryBuilder<CachedEntity, CachedEntity, QAfterFilterCondition>
      entityTypeMatches(String pattern, {bool caseSensitive = true}) {
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

  QueryBuilder<CachedEntity, CachedEntity, QAfterFilterCondition>
      entityTypeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(
          property: 1,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<CachedEntity, CachedEntity, QAfterFilterCondition>
      entityTypeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(
          property: 1,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<CachedEntity, CachedEntity, QAfterFilterCondition>
      entityIdEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(
          property: 2,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<CachedEntity, CachedEntity, QAfterFilterCondition>
      entityIdGreaterThan(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 2,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<CachedEntity, CachedEntity, QAfterFilterCondition>
      entityIdGreaterThanOrEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 2,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<CachedEntity, CachedEntity, QAfterFilterCondition>
      entityIdLessThan(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(
          property: 2,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<CachedEntity, CachedEntity, QAfterFilterCondition>
      entityIdLessThanOrEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 2,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<CachedEntity, CachedEntity, QAfterFilterCondition>
      entityIdBetween(
    int lower,
    int upper,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 2,
          lower: lower,
          upper: upper,
        ),
      );
    });
  }

  QueryBuilder<CachedEntity, CachedEntity, QAfterFilterCondition>
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

  QueryBuilder<CachedEntity, CachedEntity, QAfterFilterCondition>
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

  QueryBuilder<CachedEntity, CachedEntity, QAfterFilterCondition>
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

  QueryBuilder<CachedEntity, CachedEntity, QAfterFilterCondition>
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

  QueryBuilder<CachedEntity, CachedEntity, QAfterFilterCondition>
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

  QueryBuilder<CachedEntity, CachedEntity, QAfterFilterCondition>
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

  QueryBuilder<CachedEntity, CachedEntity, QAfterFilterCondition>
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

  QueryBuilder<CachedEntity, CachedEntity, QAfterFilterCondition>
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

  QueryBuilder<CachedEntity, CachedEntity, QAfterFilterCondition>
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

  QueryBuilder<CachedEntity, CachedEntity, QAfterFilterCondition>
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

  QueryBuilder<CachedEntity, CachedEntity, QAfterFilterCondition>
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

  QueryBuilder<CachedEntity, CachedEntity, QAfterFilterCondition>
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

  QueryBuilder<CachedEntity, CachedEntity, QAfterFilterCondition>
      syncedAtEqualTo(
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

  QueryBuilder<CachedEntity, CachedEntity, QAfterFilterCondition>
      syncedAtGreaterThan(
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

  QueryBuilder<CachedEntity, CachedEntity, QAfterFilterCondition>
      syncedAtGreaterThanOrEqualTo(
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

  QueryBuilder<CachedEntity, CachedEntity, QAfterFilterCondition>
      syncedAtLessThan(
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

  QueryBuilder<CachedEntity, CachedEntity, QAfterFilterCondition>
      syncedAtLessThanOrEqualTo(
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

  QueryBuilder<CachedEntity, CachedEntity, QAfterFilterCondition>
      syncedAtBetween(
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

extension CachedEntityQueryObject
    on QueryBuilder<CachedEntity, CachedEntity, QFilterCondition> {}

extension CachedEntityQuerySortBy
    on QueryBuilder<CachedEntity, CachedEntity, QSortBy> {
  QueryBuilder<CachedEntity, CachedEntity, QAfterSortBy> sortById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(0);
    });
  }

  QueryBuilder<CachedEntity, CachedEntity, QAfterSortBy> sortByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(0, sort: Sort.desc);
    });
  }

  QueryBuilder<CachedEntity, CachedEntity, QAfterSortBy> sortByEntityType(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        1,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<CachedEntity, CachedEntity, QAfterSortBy> sortByEntityTypeDesc(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        1,
        sort: Sort.desc,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<CachedEntity, CachedEntity, QAfterSortBy> sortByEntityId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(2);
    });
  }

  QueryBuilder<CachedEntity, CachedEntity, QAfterSortBy> sortByEntityIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(2, sort: Sort.desc);
    });
  }

  QueryBuilder<CachedEntity, CachedEntity, QAfterSortBy> sortByDataJson(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        3,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<CachedEntity, CachedEntity, QAfterSortBy> sortByDataJsonDesc(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        3,
        sort: Sort.desc,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<CachedEntity, CachedEntity, QAfterSortBy> sortBySyncedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(4);
    });
  }

  QueryBuilder<CachedEntity, CachedEntity, QAfterSortBy> sortBySyncedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(4, sort: Sort.desc);
    });
  }
}

extension CachedEntityQuerySortThenBy
    on QueryBuilder<CachedEntity, CachedEntity, QSortThenBy> {
  QueryBuilder<CachedEntity, CachedEntity, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(0);
    });
  }

  QueryBuilder<CachedEntity, CachedEntity, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(0, sort: Sort.desc);
    });
  }

  QueryBuilder<CachedEntity, CachedEntity, QAfterSortBy> thenByEntityType(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(1, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CachedEntity, CachedEntity, QAfterSortBy> thenByEntityTypeDesc(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(1, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CachedEntity, CachedEntity, QAfterSortBy> thenByEntityId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(2);
    });
  }

  QueryBuilder<CachedEntity, CachedEntity, QAfterSortBy> thenByEntityIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(2, sort: Sort.desc);
    });
  }

  QueryBuilder<CachedEntity, CachedEntity, QAfterSortBy> thenByDataJson(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(3, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CachedEntity, CachedEntity, QAfterSortBy> thenByDataJsonDesc(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(3, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CachedEntity, CachedEntity, QAfterSortBy> thenBySyncedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(4);
    });
  }

  QueryBuilder<CachedEntity, CachedEntity, QAfterSortBy> thenBySyncedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(4, sort: Sort.desc);
    });
  }
}

extension CachedEntityQueryWhereDistinct
    on QueryBuilder<CachedEntity, CachedEntity, QDistinct> {
  QueryBuilder<CachedEntity, CachedEntity, QAfterDistinct> distinctByEntityType(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(1, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CachedEntity, CachedEntity, QAfterDistinct>
      distinctByEntityId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(2);
    });
  }

  QueryBuilder<CachedEntity, CachedEntity, QAfterDistinct> distinctByDataJson(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(3, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CachedEntity, CachedEntity, QAfterDistinct>
      distinctBySyncedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(4);
    });
  }
}

extension CachedEntityQueryProperty1
    on QueryBuilder<CachedEntity, CachedEntity, QProperty> {
  QueryBuilder<CachedEntity, int, QAfterProperty> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(0);
    });
  }

  QueryBuilder<CachedEntity, String, QAfterProperty> entityTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(1);
    });
  }

  QueryBuilder<CachedEntity, int, QAfterProperty> entityIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(2);
    });
  }

  QueryBuilder<CachedEntity, String, QAfterProperty> dataJsonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(3);
    });
  }

  QueryBuilder<CachedEntity, DateTime, QAfterProperty> syncedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(4);
    });
  }
}

extension CachedEntityQueryProperty2<R>
    on QueryBuilder<CachedEntity, R, QAfterProperty> {
  QueryBuilder<CachedEntity, (R, int), QAfterProperty> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(0);
    });
  }

  QueryBuilder<CachedEntity, (R, String), QAfterProperty> entityTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(1);
    });
  }

  QueryBuilder<CachedEntity, (R, int), QAfterProperty> entityIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(2);
    });
  }

  QueryBuilder<CachedEntity, (R, String), QAfterProperty> dataJsonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(3);
    });
  }

  QueryBuilder<CachedEntity, (R, DateTime), QAfterProperty> syncedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(4);
    });
  }
}

extension CachedEntityQueryProperty3<R1, R2>
    on QueryBuilder<CachedEntity, (R1, R2), QAfterProperty> {
  QueryBuilder<CachedEntity, (R1, R2, int), QOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(0);
    });
  }

  QueryBuilder<CachedEntity, (R1, R2, String), QOperations>
      entityTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(1);
    });
  }

  QueryBuilder<CachedEntity, (R1, R2, int), QOperations> entityIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(2);
    });
  }

  QueryBuilder<CachedEntity, (R1, R2, String), QOperations> dataJsonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(3);
    });
  }

  QueryBuilder<CachedEntity, (R1, R2, DateTime), QOperations>
      syncedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(4);
    });
  }
}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, invalid_use_of_protected_member, lines_longer_than_80_chars, constant_identifier_names, avoid_js_rounded_ints, no_leading_underscores_for_local_identifiers, require_trailing_commas, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_in_if_null_operators, library_private_types_in_public_api, prefer_const_constructors
// ignore_for_file: type=lint

extension GetSyncMetadataEntityCollection on Isar {
  IsarCollection<int, SyncMetadataEntity> get syncMetadataEntitys =>
      this.collection();
}

final SyncMetadataEntitySchema = IsarGeneratedSchema(
  schema: IsarSchema(
    name: 'SyncMetadataEntity',
    idName: 'id',
    embedded: false,
    properties: [
      IsarPropertySchema(
        name: 'entityType',
        type: IsarType.string,
      ),
      IsarPropertySchema(
        name: 'lastSyncAt',
        type: IsarType.dateTime,
      ),
    ],
    indexes: [
      IsarIndexSchema(
        name: 'entityType',
        properties: [
          "entityType",
        ],
        unique: true,
        hash: false,
      ),
    ],
  ),
  converter: IsarObjectConverter<int, SyncMetadataEntity>(
    serialize: serializeSyncMetadataEntity,
    deserialize: deserializeSyncMetadataEntity,
    deserializeProperty: deserializeSyncMetadataEntityProp,
  ),
  getEmbeddedSchemas: () => [],
);

@isarProtected
int serializeSyncMetadataEntity(IsarWriter writer, SyncMetadataEntity object) {
  IsarCore.writeString(writer, 1, object.entityType);
  IsarCore.writeLong(
      writer, 2, object.lastSyncAt.toUtc().microsecondsSinceEpoch);
  return object.id;
}

@isarProtected
SyncMetadataEntity deserializeSyncMetadataEntity(IsarReader reader) {
  final object = SyncMetadataEntity();
  object.id = IsarCore.readId(reader);
  object.entityType = IsarCore.readString(reader, 1) ?? '';
  {
    final value = IsarCore.readLong(reader, 2);
    if (value == -9223372036854775808) {
      object.lastSyncAt =
          DateTime.fromMillisecondsSinceEpoch(0, isUtc: true).toLocal();
    } else {
      object.lastSyncAt =
          DateTime.fromMicrosecondsSinceEpoch(value, isUtc: true).toLocal();
    }
  }
  return object;
}

@isarProtected
dynamic deserializeSyncMetadataEntityProp(IsarReader reader, int property) {
  switch (property) {
    case 0:
      return IsarCore.readId(reader);
    case 1:
      return IsarCore.readString(reader, 1) ?? '';
    case 2:
      {
        final value = IsarCore.readLong(reader, 2);
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

sealed class _SyncMetadataEntityUpdate {
  bool call({
    required int id,
    String? entityType,
    DateTime? lastSyncAt,
  });
}

class _SyncMetadataEntityUpdateImpl implements _SyncMetadataEntityUpdate {
  const _SyncMetadataEntityUpdateImpl(this.collection);

  final IsarCollection<int, SyncMetadataEntity> collection;

  @override
  bool call({
    required int id,
    Object? entityType = ignore,
    Object? lastSyncAt = ignore,
  }) {
    return collection.updateProperties([
          id
        ], {
          if (entityType != ignore) 1: entityType as String?,
          if (lastSyncAt != ignore) 2: lastSyncAt as DateTime?,
        }) >
        0;
  }
}

sealed class _SyncMetadataEntityUpdateAll {
  int call({
    required List<int> id,
    String? entityType,
    DateTime? lastSyncAt,
  });
}

class _SyncMetadataEntityUpdateAllImpl implements _SyncMetadataEntityUpdateAll {
  const _SyncMetadataEntityUpdateAllImpl(this.collection);

  final IsarCollection<int, SyncMetadataEntity> collection;

  @override
  int call({
    required List<int> id,
    Object? entityType = ignore,
    Object? lastSyncAt = ignore,
  }) {
    return collection.updateProperties(id, {
      if (entityType != ignore) 1: entityType as String?,
      if (lastSyncAt != ignore) 2: lastSyncAt as DateTime?,
    });
  }
}

extension SyncMetadataEntityUpdate on IsarCollection<int, SyncMetadataEntity> {
  _SyncMetadataEntityUpdate get update => _SyncMetadataEntityUpdateImpl(this);

  _SyncMetadataEntityUpdateAll get updateAll =>
      _SyncMetadataEntityUpdateAllImpl(this);
}

sealed class _SyncMetadataEntityQueryUpdate {
  int call({
    String? entityType,
    DateTime? lastSyncAt,
  });
}

class _SyncMetadataEntityQueryUpdateImpl
    implements _SyncMetadataEntityQueryUpdate {
  const _SyncMetadataEntityQueryUpdateImpl(this.query, {this.limit});

  final IsarQuery<SyncMetadataEntity> query;
  final int? limit;

  @override
  int call({
    Object? entityType = ignore,
    Object? lastSyncAt = ignore,
  }) {
    return query.updateProperties(limit: limit, {
      if (entityType != ignore) 1: entityType as String?,
      if (lastSyncAt != ignore) 2: lastSyncAt as DateTime?,
    });
  }
}

extension SyncMetadataEntityQueryUpdate on IsarQuery<SyncMetadataEntity> {
  _SyncMetadataEntityQueryUpdate get updateFirst =>
      _SyncMetadataEntityQueryUpdateImpl(this, limit: 1);

  _SyncMetadataEntityQueryUpdate get updateAll =>
      _SyncMetadataEntityQueryUpdateImpl(this);
}

class _SyncMetadataEntityQueryBuilderUpdateImpl
    implements _SyncMetadataEntityQueryUpdate {
  const _SyncMetadataEntityQueryBuilderUpdateImpl(this.query, {this.limit});

  final QueryBuilder<SyncMetadataEntity, SyncMetadataEntity, QOperations> query;
  final int? limit;

  @override
  int call({
    Object? entityType = ignore,
    Object? lastSyncAt = ignore,
  }) {
    final q = query.build();
    try {
      return q.updateProperties(limit: limit, {
        if (entityType != ignore) 1: entityType as String?,
        if (lastSyncAt != ignore) 2: lastSyncAt as DateTime?,
      });
    } finally {
      q.close();
    }
  }
}

extension SyncMetadataEntityQueryBuilderUpdate
    on QueryBuilder<SyncMetadataEntity, SyncMetadataEntity, QOperations> {
  _SyncMetadataEntityQueryUpdate get updateFirst =>
      _SyncMetadataEntityQueryBuilderUpdateImpl(this, limit: 1);

  _SyncMetadataEntityQueryUpdate get updateAll =>
      _SyncMetadataEntityQueryBuilderUpdateImpl(this);
}

extension SyncMetadataEntityQueryFilter
    on QueryBuilder<SyncMetadataEntity, SyncMetadataEntity, QFilterCondition> {
  QueryBuilder<SyncMetadataEntity, SyncMetadataEntity, QAfterFilterCondition>
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

  QueryBuilder<SyncMetadataEntity, SyncMetadataEntity, QAfterFilterCondition>
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

  QueryBuilder<SyncMetadataEntity, SyncMetadataEntity, QAfterFilterCondition>
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

  QueryBuilder<SyncMetadataEntity, SyncMetadataEntity, QAfterFilterCondition>
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

  QueryBuilder<SyncMetadataEntity, SyncMetadataEntity, QAfterFilterCondition>
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

  QueryBuilder<SyncMetadataEntity, SyncMetadataEntity, QAfterFilterCondition>
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

  QueryBuilder<SyncMetadataEntity, SyncMetadataEntity, QAfterFilterCondition>
      entityTypeEqualTo(
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

  QueryBuilder<SyncMetadataEntity, SyncMetadataEntity, QAfterFilterCondition>
      entityTypeGreaterThan(
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

  QueryBuilder<SyncMetadataEntity, SyncMetadataEntity, QAfterFilterCondition>
      entityTypeGreaterThanOrEqualTo(
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

  QueryBuilder<SyncMetadataEntity, SyncMetadataEntity, QAfterFilterCondition>
      entityTypeLessThan(
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

  QueryBuilder<SyncMetadataEntity, SyncMetadataEntity, QAfterFilterCondition>
      entityTypeLessThanOrEqualTo(
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

  QueryBuilder<SyncMetadataEntity, SyncMetadataEntity, QAfterFilterCondition>
      entityTypeBetween(
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

  QueryBuilder<SyncMetadataEntity, SyncMetadataEntity, QAfterFilterCondition>
      entityTypeStartsWith(
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

  QueryBuilder<SyncMetadataEntity, SyncMetadataEntity, QAfterFilterCondition>
      entityTypeEndsWith(
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

  QueryBuilder<SyncMetadataEntity, SyncMetadataEntity, QAfterFilterCondition>
      entityTypeContains(String value, {bool caseSensitive = true}) {
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

  QueryBuilder<SyncMetadataEntity, SyncMetadataEntity, QAfterFilterCondition>
      entityTypeMatches(String pattern, {bool caseSensitive = true}) {
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

  QueryBuilder<SyncMetadataEntity, SyncMetadataEntity, QAfterFilterCondition>
      entityTypeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(
          property: 1,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<SyncMetadataEntity, SyncMetadataEntity, QAfterFilterCondition>
      entityTypeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(
          property: 1,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<SyncMetadataEntity, SyncMetadataEntity, QAfterFilterCondition>
      lastSyncAtEqualTo(
    DateTime value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(
          property: 2,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<SyncMetadataEntity, SyncMetadataEntity, QAfterFilterCondition>
      lastSyncAtGreaterThan(
    DateTime value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 2,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<SyncMetadataEntity, SyncMetadataEntity, QAfterFilterCondition>
      lastSyncAtGreaterThanOrEqualTo(
    DateTime value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 2,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<SyncMetadataEntity, SyncMetadataEntity, QAfterFilterCondition>
      lastSyncAtLessThan(
    DateTime value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(
          property: 2,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<SyncMetadataEntity, SyncMetadataEntity, QAfterFilterCondition>
      lastSyncAtLessThanOrEqualTo(
    DateTime value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 2,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<SyncMetadataEntity, SyncMetadataEntity, QAfterFilterCondition>
      lastSyncAtBetween(
    DateTime lower,
    DateTime upper,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 2,
          lower: lower,
          upper: upper,
        ),
      );
    });
  }
}

extension SyncMetadataEntityQueryObject
    on QueryBuilder<SyncMetadataEntity, SyncMetadataEntity, QFilterCondition> {}

extension SyncMetadataEntityQuerySortBy
    on QueryBuilder<SyncMetadataEntity, SyncMetadataEntity, QSortBy> {
  QueryBuilder<SyncMetadataEntity, SyncMetadataEntity, QAfterSortBy>
      sortById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(0);
    });
  }

  QueryBuilder<SyncMetadataEntity, SyncMetadataEntity, QAfterSortBy>
      sortByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(0, sort: Sort.desc);
    });
  }

  QueryBuilder<SyncMetadataEntity, SyncMetadataEntity, QAfterSortBy>
      sortByEntityType({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        1,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<SyncMetadataEntity, SyncMetadataEntity, QAfterSortBy>
      sortByEntityTypeDesc({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        1,
        sort: Sort.desc,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<SyncMetadataEntity, SyncMetadataEntity, QAfterSortBy>
      sortByLastSyncAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(2);
    });
  }

  QueryBuilder<SyncMetadataEntity, SyncMetadataEntity, QAfterSortBy>
      sortByLastSyncAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(2, sort: Sort.desc);
    });
  }
}

extension SyncMetadataEntityQuerySortThenBy
    on QueryBuilder<SyncMetadataEntity, SyncMetadataEntity, QSortThenBy> {
  QueryBuilder<SyncMetadataEntity, SyncMetadataEntity, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(0);
    });
  }

  QueryBuilder<SyncMetadataEntity, SyncMetadataEntity, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(0, sort: Sort.desc);
    });
  }

  QueryBuilder<SyncMetadataEntity, SyncMetadataEntity, QAfterSortBy>
      thenByEntityType({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(1, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SyncMetadataEntity, SyncMetadataEntity, QAfterSortBy>
      thenByEntityTypeDesc({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(1, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SyncMetadataEntity, SyncMetadataEntity, QAfterSortBy>
      thenByLastSyncAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(2);
    });
  }

  QueryBuilder<SyncMetadataEntity, SyncMetadataEntity, QAfterSortBy>
      thenByLastSyncAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(2, sort: Sort.desc);
    });
  }
}

extension SyncMetadataEntityQueryWhereDistinct
    on QueryBuilder<SyncMetadataEntity, SyncMetadataEntity, QDistinct> {
  QueryBuilder<SyncMetadataEntity, SyncMetadataEntity, QAfterDistinct>
      distinctByEntityType({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(1, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SyncMetadataEntity, SyncMetadataEntity, QAfterDistinct>
      distinctByLastSyncAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(2);
    });
  }
}

extension SyncMetadataEntityQueryProperty1
    on QueryBuilder<SyncMetadataEntity, SyncMetadataEntity, QProperty> {
  QueryBuilder<SyncMetadataEntity, int, QAfterProperty> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(0);
    });
  }

  QueryBuilder<SyncMetadataEntity, String, QAfterProperty>
      entityTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(1);
    });
  }

  QueryBuilder<SyncMetadataEntity, DateTime, QAfterProperty>
      lastSyncAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(2);
    });
  }
}

extension SyncMetadataEntityQueryProperty2<R>
    on QueryBuilder<SyncMetadataEntity, R, QAfterProperty> {
  QueryBuilder<SyncMetadataEntity, (R, int), QAfterProperty> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(0);
    });
  }

  QueryBuilder<SyncMetadataEntity, (R, String), QAfterProperty>
      entityTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(1);
    });
  }

  QueryBuilder<SyncMetadataEntity, (R, DateTime), QAfterProperty>
      lastSyncAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(2);
    });
  }
}

extension SyncMetadataEntityQueryProperty3<R1, R2>
    on QueryBuilder<SyncMetadataEntity, (R1, R2), QAfterProperty> {
  QueryBuilder<SyncMetadataEntity, (R1, R2, int), QOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(0);
    });
  }

  QueryBuilder<SyncMetadataEntity, (R1, R2, String), QOperations>
      entityTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(1);
    });
  }

  QueryBuilder<SyncMetadataEntity, (R1, R2, DateTime), QOperations>
      lastSyncAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(2);
    });
  }
}
