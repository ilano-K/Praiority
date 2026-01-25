// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_preferences_model.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetUserPreferencesModelCollection on Isar {
  IsarCollection<UserPreferencesModel> get userPreferencesModels =>
      this.collection();
}

const UserPreferencesModelSchema = CollectionSchema(
  name: r'UserPreferencesModel',
  id: 3603656307210587948,
  properties: {
    r'endWorkHours': PropertySchema(
      id: 0,
      name: r'endWorkHours',
      type: IsarType.string,
    ),
    r'isSetupComplete': PropertySchema(
      id: 1,
      name: r'isSetupComplete',
      type: IsarType.bool,
    ),
    r'startWorkHours': PropertySchema(
      id: 2,
      name: r'startWorkHours',
      type: IsarType.string,
    ),
    r'userId': PropertySchema(
      id: 3,
      name: r'userId',
      type: IsarType.string,
    )
  },
  estimateSize: _userPreferencesModelEstimateSize,
  serialize: _userPreferencesModelSerialize,
  deserialize: _userPreferencesModelDeserialize,
  deserializeProp: _userPreferencesModelDeserializeProp,
  idName: r'id',
  indexes: {
    r'userId': IndexSchema(
      id: -2005826577402374815,
      name: r'userId',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'userId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _userPreferencesModelGetId,
  getLinks: _userPreferencesModelGetLinks,
  attach: _userPreferencesModelAttach,
  version: '3.1.0+1',
);

int _userPreferencesModelEstimateSize(
  UserPreferencesModel object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.endWorkHours.length * 3;
  bytesCount += 3 + object.startWorkHours.length * 3;
  bytesCount += 3 + object.userId.length * 3;
  return bytesCount;
}

void _userPreferencesModelSerialize(
  UserPreferencesModel object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.endWorkHours);
  writer.writeBool(offsets[1], object.isSetupComplete);
  writer.writeString(offsets[2], object.startWorkHours);
  writer.writeString(offsets[3], object.userId);
}

UserPreferencesModel _userPreferencesModelDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = UserPreferencesModel();
  object.endWorkHours = reader.readString(offsets[0]);
  object.id = id;
  object.isSetupComplete = reader.readBool(offsets[1]);
  object.startWorkHours = reader.readString(offsets[2]);
  object.userId = reader.readString(offsets[3]);
  return object;
}

P _userPreferencesModelDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readBool(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _userPreferencesModelGetId(UserPreferencesModel object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _userPreferencesModelGetLinks(
    UserPreferencesModel object) {
  return [];
}

void _userPreferencesModelAttach(
    IsarCollection<dynamic> col, Id id, UserPreferencesModel object) {
  object.id = id;
}

extension UserPreferencesModelByIndex on IsarCollection<UserPreferencesModel> {
  Future<UserPreferencesModel?> getByUserId(String userId) {
    return getByIndex(r'userId', [userId]);
  }

  UserPreferencesModel? getByUserIdSync(String userId) {
    return getByIndexSync(r'userId', [userId]);
  }

  Future<bool> deleteByUserId(String userId) {
    return deleteByIndex(r'userId', [userId]);
  }

  bool deleteByUserIdSync(String userId) {
    return deleteByIndexSync(r'userId', [userId]);
  }

  Future<List<UserPreferencesModel?>> getAllByUserId(
      List<String> userIdValues) {
    final values = userIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'userId', values);
  }

  List<UserPreferencesModel?> getAllByUserIdSync(List<String> userIdValues) {
    final values = userIdValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'userId', values);
  }

  Future<int> deleteAllByUserId(List<String> userIdValues) {
    final values = userIdValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'userId', values);
  }

  int deleteAllByUserIdSync(List<String> userIdValues) {
    final values = userIdValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'userId', values);
  }

  Future<Id> putByUserId(UserPreferencesModel object) {
    return putByIndex(r'userId', object);
  }

  Id putByUserIdSync(UserPreferencesModel object, {bool saveLinks = true}) {
    return putByIndexSync(r'userId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByUserId(List<UserPreferencesModel> objects) {
    return putAllByIndex(r'userId', objects);
  }

  List<Id> putAllByUserIdSync(List<UserPreferencesModel> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'userId', objects, saveLinks: saveLinks);
  }
}

extension UserPreferencesModelQueryWhereSort
    on QueryBuilder<UserPreferencesModel, UserPreferencesModel, QWhere> {
  QueryBuilder<UserPreferencesModel, UserPreferencesModel, QAfterWhere>
      anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension UserPreferencesModelQueryWhere
    on QueryBuilder<UserPreferencesModel, UserPreferencesModel, QWhereClause> {
  QueryBuilder<UserPreferencesModel, UserPreferencesModel, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<UserPreferencesModel, UserPreferencesModel, QAfterWhereClause>
      idNotEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<UserPreferencesModel, UserPreferencesModel, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<UserPreferencesModel, UserPreferencesModel, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<UserPreferencesModel, UserPreferencesModel, QAfterWhereClause>
      idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<UserPreferencesModel, UserPreferencesModel, QAfterWhereClause>
      userIdEqualTo(String userId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'userId',
        value: [userId],
      ));
    });
  }

  QueryBuilder<UserPreferencesModel, UserPreferencesModel, QAfterWhereClause>
      userIdNotEqualTo(String userId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'userId',
              lower: [],
              upper: [userId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'userId',
              lower: [userId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'userId',
              lower: [userId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'userId',
              lower: [],
              upper: [userId],
              includeUpper: false,
            ));
      }
    });
  }
}

extension UserPreferencesModelQueryFilter on QueryBuilder<UserPreferencesModel,
    UserPreferencesModel, QFilterCondition> {
  QueryBuilder<UserPreferencesModel, UserPreferencesModel,
      QAfterFilterCondition> endWorkHoursEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'endWorkHours',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserPreferencesModel, UserPreferencesModel,
      QAfterFilterCondition> endWorkHoursGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'endWorkHours',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserPreferencesModel, UserPreferencesModel,
      QAfterFilterCondition> endWorkHoursLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'endWorkHours',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserPreferencesModel, UserPreferencesModel,
      QAfterFilterCondition> endWorkHoursBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'endWorkHours',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserPreferencesModel, UserPreferencesModel,
      QAfterFilterCondition> endWorkHoursStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'endWorkHours',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserPreferencesModel, UserPreferencesModel,
      QAfterFilterCondition> endWorkHoursEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'endWorkHours',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserPreferencesModel, UserPreferencesModel,
          QAfterFilterCondition>
      endWorkHoursContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'endWorkHours',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserPreferencesModel, UserPreferencesModel,
          QAfterFilterCondition>
      endWorkHoursMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'endWorkHours',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserPreferencesModel, UserPreferencesModel,
      QAfterFilterCondition> endWorkHoursIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'endWorkHours',
        value: '',
      ));
    });
  }

  QueryBuilder<UserPreferencesModel, UserPreferencesModel,
      QAfterFilterCondition> endWorkHoursIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'endWorkHours',
        value: '',
      ));
    });
  }

  QueryBuilder<UserPreferencesModel, UserPreferencesModel,
      QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<UserPreferencesModel, UserPreferencesModel,
      QAfterFilterCondition> idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<UserPreferencesModel, UserPreferencesModel,
      QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<UserPreferencesModel, UserPreferencesModel,
      QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<UserPreferencesModel, UserPreferencesModel,
      QAfterFilterCondition> isSetupCompleteEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isSetupComplete',
        value: value,
      ));
    });
  }

  QueryBuilder<UserPreferencesModel, UserPreferencesModel,
      QAfterFilterCondition> startWorkHoursEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'startWorkHours',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserPreferencesModel, UserPreferencesModel,
      QAfterFilterCondition> startWorkHoursGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'startWorkHours',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserPreferencesModel, UserPreferencesModel,
      QAfterFilterCondition> startWorkHoursLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'startWorkHours',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserPreferencesModel, UserPreferencesModel,
      QAfterFilterCondition> startWorkHoursBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'startWorkHours',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserPreferencesModel, UserPreferencesModel,
      QAfterFilterCondition> startWorkHoursStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'startWorkHours',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserPreferencesModel, UserPreferencesModel,
      QAfterFilterCondition> startWorkHoursEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'startWorkHours',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserPreferencesModel, UserPreferencesModel,
          QAfterFilterCondition>
      startWorkHoursContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'startWorkHours',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserPreferencesModel, UserPreferencesModel,
          QAfterFilterCondition>
      startWorkHoursMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'startWorkHours',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserPreferencesModel, UserPreferencesModel,
      QAfterFilterCondition> startWorkHoursIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'startWorkHours',
        value: '',
      ));
    });
  }

  QueryBuilder<UserPreferencesModel, UserPreferencesModel,
      QAfterFilterCondition> startWorkHoursIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'startWorkHours',
        value: '',
      ));
    });
  }

  QueryBuilder<UserPreferencesModel, UserPreferencesModel,
      QAfterFilterCondition> userIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'userId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserPreferencesModel, UserPreferencesModel,
      QAfterFilterCondition> userIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'userId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserPreferencesModel, UserPreferencesModel,
      QAfterFilterCondition> userIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'userId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserPreferencesModel, UserPreferencesModel,
      QAfterFilterCondition> userIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'userId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserPreferencesModel, UserPreferencesModel,
      QAfterFilterCondition> userIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'userId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserPreferencesModel, UserPreferencesModel,
      QAfterFilterCondition> userIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'userId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserPreferencesModel, UserPreferencesModel,
          QAfterFilterCondition>
      userIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'userId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserPreferencesModel, UserPreferencesModel,
          QAfterFilterCondition>
      userIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'userId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserPreferencesModel, UserPreferencesModel,
      QAfterFilterCondition> userIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'userId',
        value: '',
      ));
    });
  }

  QueryBuilder<UserPreferencesModel, UserPreferencesModel,
      QAfterFilterCondition> userIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'userId',
        value: '',
      ));
    });
  }
}

extension UserPreferencesModelQueryObject on QueryBuilder<UserPreferencesModel,
    UserPreferencesModel, QFilterCondition> {}

extension UserPreferencesModelQueryLinks on QueryBuilder<UserPreferencesModel,
    UserPreferencesModel, QFilterCondition> {}

extension UserPreferencesModelQuerySortBy
    on QueryBuilder<UserPreferencesModel, UserPreferencesModel, QSortBy> {
  QueryBuilder<UserPreferencesModel, UserPreferencesModel, QAfterSortBy>
      sortByEndWorkHours() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endWorkHours', Sort.asc);
    });
  }

  QueryBuilder<UserPreferencesModel, UserPreferencesModel, QAfterSortBy>
      sortByEndWorkHoursDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endWorkHours', Sort.desc);
    });
  }

  QueryBuilder<UserPreferencesModel, UserPreferencesModel, QAfterSortBy>
      sortByIsSetupComplete() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSetupComplete', Sort.asc);
    });
  }

  QueryBuilder<UserPreferencesModel, UserPreferencesModel, QAfterSortBy>
      sortByIsSetupCompleteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSetupComplete', Sort.desc);
    });
  }

  QueryBuilder<UserPreferencesModel, UserPreferencesModel, QAfterSortBy>
      sortByStartWorkHours() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startWorkHours', Sort.asc);
    });
  }

  QueryBuilder<UserPreferencesModel, UserPreferencesModel, QAfterSortBy>
      sortByStartWorkHoursDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startWorkHours', Sort.desc);
    });
  }

  QueryBuilder<UserPreferencesModel, UserPreferencesModel, QAfterSortBy>
      sortByUserId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.asc);
    });
  }

  QueryBuilder<UserPreferencesModel, UserPreferencesModel, QAfterSortBy>
      sortByUserIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.desc);
    });
  }
}

extension UserPreferencesModelQuerySortThenBy
    on QueryBuilder<UserPreferencesModel, UserPreferencesModel, QSortThenBy> {
  QueryBuilder<UserPreferencesModel, UserPreferencesModel, QAfterSortBy>
      thenByEndWorkHours() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endWorkHours', Sort.asc);
    });
  }

  QueryBuilder<UserPreferencesModel, UserPreferencesModel, QAfterSortBy>
      thenByEndWorkHoursDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endWorkHours', Sort.desc);
    });
  }

  QueryBuilder<UserPreferencesModel, UserPreferencesModel, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<UserPreferencesModel, UserPreferencesModel, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<UserPreferencesModel, UserPreferencesModel, QAfterSortBy>
      thenByIsSetupComplete() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSetupComplete', Sort.asc);
    });
  }

  QueryBuilder<UserPreferencesModel, UserPreferencesModel, QAfterSortBy>
      thenByIsSetupCompleteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSetupComplete', Sort.desc);
    });
  }

  QueryBuilder<UserPreferencesModel, UserPreferencesModel, QAfterSortBy>
      thenByStartWorkHours() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startWorkHours', Sort.asc);
    });
  }

  QueryBuilder<UserPreferencesModel, UserPreferencesModel, QAfterSortBy>
      thenByStartWorkHoursDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startWorkHours', Sort.desc);
    });
  }

  QueryBuilder<UserPreferencesModel, UserPreferencesModel, QAfterSortBy>
      thenByUserId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.asc);
    });
  }

  QueryBuilder<UserPreferencesModel, UserPreferencesModel, QAfterSortBy>
      thenByUserIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.desc);
    });
  }
}

extension UserPreferencesModelQueryWhereDistinct
    on QueryBuilder<UserPreferencesModel, UserPreferencesModel, QDistinct> {
  QueryBuilder<UserPreferencesModel, UserPreferencesModel, QDistinct>
      distinctByEndWorkHours({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'endWorkHours', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<UserPreferencesModel, UserPreferencesModel, QDistinct>
      distinctByIsSetupComplete() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isSetupComplete');
    });
  }

  QueryBuilder<UserPreferencesModel, UserPreferencesModel, QDistinct>
      distinctByStartWorkHours({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'startWorkHours',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<UserPreferencesModel, UserPreferencesModel, QDistinct>
      distinctByUserId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'userId', caseSensitive: caseSensitive);
    });
  }
}

extension UserPreferencesModelQueryProperty on QueryBuilder<
    UserPreferencesModel, UserPreferencesModel, QQueryProperty> {
  QueryBuilder<UserPreferencesModel, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<UserPreferencesModel, String, QQueryOperations>
      endWorkHoursProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'endWorkHours');
    });
  }

  QueryBuilder<UserPreferencesModel, bool, QQueryOperations>
      isSetupCompleteProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isSetupComplete');
    });
  }

  QueryBuilder<UserPreferencesModel, String, QQueryOperations>
      startWorkHoursProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'startWorkHours');
    });
  }

  QueryBuilder<UserPreferencesModel, String, QQueryOperations>
      userIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'userId');
    });
  }
}
