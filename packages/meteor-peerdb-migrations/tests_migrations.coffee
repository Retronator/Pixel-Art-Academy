class MigrationTest extends Document
  # Other fields:
  #   test (which is later on renamed to "renamed")

  @Meta
    name: 'MigrationTest'

class Migration1 extends Document.PatchMigration
  name: "Migration 1"

MigrationTest.addMigration new Migration1()

class Migration2 extends Document.PatchMigration
  name: "Migration 2"

MigrationTest.addMigration new Migration2()

MigrationTest.renameCollectionMigration 'OlderMigrationTests', 'OldMigrationTests'

class Migration3 extends Document.MinorMigration
  name: "Migration 3"

MigrationTest.addMigration new Migration3()

class Migration4 extends Document.MajorMigration
  name: "Migration 4"

  forward: (document, collection, currentSchema, newSchema) ->
    count = collection.update {_schema: currentSchema}, {$rename: {test: 'renamed'}, $set: {_schema: newSchema}}, {multi: true}

    counts = super document, collection, currentSchema, newSchema
    counts.migrated += count
    counts.all += count
    counts

  backward: (document, collection, currentSchema, oldSchema) ->
    count = collection.update {_schema: currentSchema}, {$rename: {renamed: 'test'}, $set: {_schema: oldSchema}}, {multi: true}

    counts = super document, collection, currentSchema, oldSchema
    counts.migrated += count
    counts.all += count
    counts

MigrationTest.addMigration new Migration4()

MigrationTest.renameCollectionMigration 'OldMigrationTests', 'MigrationTests'

class Migration5 extends Document.MajorMigration
  name: "Migration 5"

MigrationTest.addMigration new Migration5()

class Migration6 extends Document.MinorMigration
  name: "Migration 6"

MigrationTest.addMigration new Migration6()

class Migration7 extends Document.MinorMigration
  name: "Migration 7"

MigrationTest.addMigration new Migration7()

class Migration8 extends Document.PatchMigration
  name: "Migration 8"

MigrationTest.addMigration new Migration8()

# Store away for testing.
_TestMigrationTest = MigrationTest

class MigrationTest extends MigrationTest
  @Meta
    name: 'MigrationTest'
    replaceParent: true

if Meteor.isServer
  # Initialize the database.
  MigrationTest.documents.remove {}

testDefinition = (test, count) ->
  test.equal MigrationTest.Meta._name, 'MigrationTest'
  test.equal MigrationTest.Meta.parent, _TestMigrationTest.Meta
  test.equal MigrationTest.Meta.document, MigrationTest
  test.equal MigrationTest.Meta.collection._name, 'MigrationTests'
  test.equal MigrationTest.Meta.schema, '5.2.1'
  test.equal _.pluck(MigrationTest.Meta.migrations, 'name'), ["Migration 1", "Migration 2", "Renaming collection from 'OlderMigrationTests' to 'OldMigrationTests'", "Migration 3", "Migration 4", "Renaming collection from 'OldMigrationTests' to 'MigrationTests'", "Migration 5", "Migration 6", "Migration 7", "Migration 8"]
  test.equal _.size(MigrationTest.Meta.fields), 0

  migrations = Document.Migrations.find().fetch()
  migrations = for migration in migrations
    delete migration._id
    delete migration.timestamp
    migration

  test.equal migrations, [
    serial: 1
    migrationName: null
    oldCollectionName: null
    newCollectionName: null
    oldVersion: null
    newVersion: null
    migrated: 0
    all: 0
  ,
    serial: 2
    migrationName: 'Migration 1'
    oldCollectionName: 'OlderMigrationTests'
    newCollectionName: 'OlderMigrationTests'
    oldVersion: '1.0.0'
    newVersion: '1.0.1'
    migrated: 0
    all: count
  ,
    serial: 3
    migrationName: 'Migration 2'
    oldCollectionName: 'OlderMigrationTests'
    newCollectionName: 'OlderMigrationTests'
    oldVersion: '1.0.1'
    newVersion: '1.0.2'
    migrated: 0
    all: count
  ,
    serial: 4
    migrationName: 'Renaming collection from \'OlderMigrationTests\' to \'OldMigrationTests\''
    oldCollectionName: 'OlderMigrationTests'
    newCollectionName: 'OldMigrationTests'
    oldVersion: '1.0.2'
    newVersion: '2.0.0'
    migrated: count
    all: count
  ,
    serial: 5
    migrationName: 'Migration 3'
    oldCollectionName: 'OldMigrationTests'
    newCollectionName: 'OldMigrationTests'
    oldVersion: '2.0.0'
    newVersion: '2.1.0'
    migrated: 0
    all: count
  ,
    serial: 6
    migrationName: 'Migration 4'
    oldCollectionName: 'OldMigrationTests'
    newCollectionName: 'OldMigrationTests'
    oldVersion: '2.1.0'
    newVersion: '3.0.0'
    migrated: count
    all: count
  ,
    serial: 7
    migrationName: 'Renaming collection from \'OldMigrationTests\' to \'MigrationTests\''
    oldCollectionName: 'OldMigrationTests'
    newCollectionName: 'MigrationTests'
    oldVersion: '3.0.0'
    newVersion: '4.0.0'
    migrated: count
    all: count
  ,
    serial: 8
    migrationName: 'Migration 5'
    oldCollectionName: 'MigrationTests'
    newCollectionName: 'MigrationTests'
    oldVersion: '4.0.0'
    newVersion: '5.0.0'
    migrated: 0
    all: count
  ,
    serial: 9
    migrationName: 'Migration 6'
    oldCollectionName: 'MigrationTests'
    newCollectionName: 'MigrationTests'
    oldVersion: '5.0.0'
    newVersion: '5.1.0'
    migrated: 0
    all: count
  ,
    serial: 10
    migrationName: 'Migration 7'
    oldCollectionName: 'MigrationTests'
    newCollectionName: 'MigrationTests'
    oldVersion: '5.1.0'
    newVersion: '5.2.0'
    migrated: 0
    all: count
  ,
    serial: 11
    migrationName: 'Migration 8'
    oldCollectionName: 'MigrationTests'
    newCollectionName: 'MigrationTests'
    oldVersion: '5.2.0'
    newVersion: '5.2.1'
    migrated: 0
    all: count
  ]

unless Document.migrationsDisabled
  testAsyncMulti 'peerdb-migrations - migrations', [
    (test, expect) ->
      db = MongoInternals.defaultRemoteCollectionDriver().mongo.db
      test.isTrue db

      # Reset migrated count.
      Document.Migrations.update({}, {$set: {migrated: 0, all: 0}}, {multi: true})

      # We ignore any error.
      db.dropCollection 'OlderMigrationTests', Meteor.bindEnvironment expect(->), (e) -> throw e
      db.dropCollection 'OldMigrationTests', Meteor.bindEnvironment expect(->), (e) -> throw e
      db.dropCollection 'MigrationTests', Meteor.bindEnvironment expect(->), (e) -> throw e

      testDefinition test, 0

      # We should be able to call migrate multiple times.
      MigrationTest.migrateForward(MigrationTest.Meta.migrations[MigrationTest.Meta.migrations.length - 1])

      testDefinition test, 0

      # We ignore any error.
      db.dropCollection 'OlderMigrationTests', Meteor.bindEnvironment expect(->), (e) -> throw e
      db.dropCollection 'OldMigrationTests', Meteor.bindEnvironment expect(->), (e) -> throw e
      db.dropCollection 'MigrationTests', Meteor.bindEnvironment expect(->), (e) -> throw e
  ,
    (test, expect) ->
      Document.Migrations.remove serial: $ne: 1

      collection = new DirectCollection 'OlderMigrationTests'
      id = Random.id()
      collection.insert {_id: id, _schema: '1.0.0', test: 'test field'}

      MigrationTest.migrateForward(MigrationTest.Meta.migrations[MigrationTest.Meta.migrations.length - 1])

      docs = MigrationTest.documents.find({},
        # So that we can use test.equal.
        transform: null
      ).fetch()
      test.equal docs,
        [
          _id: id
          _schema: '5.2.1'
          renamed: 'test field'
        ]

      testDefinition test, 1

      # We should be able to call migrate multiple times.
      MigrationTest.migrateForward(MigrationTest.Meta.migrations[MigrationTest.Meta.migrations.length - 1])

      testDefinition test, 1

      docs = MigrationTest.documents.find({},
        # So that we can use test.equal.
        transform: null
      ).fetch()
      test.equal docs,
        [
          _id: id
          _schema: '5.2.1'
          renamed: 'test field'
        ]

      # Insert without schema.
      MigrationTest.documents.insert {renamed: 'another field'}

      # Wait for observer to set the schema field.
      Meteor.setTimeout expect(), 200 # ms
  ,
    (test, expect) ->
      docs = MigrationTest.documents.find({renamed: 'another field'},
        # So that we can use test.equal.
        transform: null,
        fields:
          _id: 0
      ).fetch()
      test.equal docs,
        [
          _schema: '5.2.1'
          renamed: 'another field'
        ]
  ]
