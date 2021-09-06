PeerDB Migrations
=================

Meteor smart package which provides migrations for [PeerDB](https://github.com/peerlibrary/meteor-peerdb)
reactive database layer.

Adding this package to your [Meteor](http://www.meteor.com/) application enables migrations on all documents defined
using PeerDB.

Server side only.

Installation
------------

```
meteor add peerlibrary:peerdb-migrations
```

Migrations
----------

In any large project your documents' schemas will evolve through time. While MongoDB does not really enforce
any schema, your program logic might require one. It is error prone to allow documents with various versions
of schemas to exist at the same time and it makes your program code more complicated.

To address this, PeerDB migrations provide you with a way to define schema migrations. They are applied
automatically on a startup of your application to migrate any documents as necessary. To know which documents
are at which schema version, PeerDB migrations add a `_schema` field to all PeerDB documents with a
[semantic version](http://semver.org/) number. This allows recovery of partially migrated collections and
importing documents with a different schema version.

To define a migration, extend a class `Document.PatchMigration`, `Document.MinorMigration`, or
`Document.MajorMigration`, depending on whether your schema change is a backwards-compatible bug fix,
you are adding functionality in a backwards-compatible manner, or you are making an incompatible
change, respectively. By default migrations just update the schema version:

```coffee
class Migration extends Document.PatchMigration
  name: "Migration not really doing anything with data"

  forward: (document, collection, currentSchema, newSchema) =>
    migrated: 0
    all: collection.update {_schema: currentSchema}, {$set: _schema: newSchema}, {multi: true}

  backward: (document, collection, currentSchema, oldSchema) =>
    migrated: 0
    all: collection.update {_schema: currentSchema}, {$set: _schema: oldSchema}, {multi: true}

Post.addMigration new Migration()
```

The base migrations class uses the migration definitions above. You have to define both `forward` and `backward`
methods, but you can leave them undefined to use inherited definitions. Methods should return an
object containing `migrated` and `all` counts. `migrated` is the count of all documents which were migrated,
while `all` includes documents which were not really migrated (maybe because they were not applicable
for the given migration), but they still exist in the collection and only their schema version was updated.
The method must update the schema version on all documents in a collection. (An easy pattern is to first migrate
applicable documents and then call `super` for the rest, returning the combined counts.)

Inside a migration method you should use [DirectCollection](https://github.com/peerlibrary/meteor-directcollection),
provided to you as a `collection` argument. If you need access to other collections in your migrations,
you should use `DirectCollection` as well. `DirectCollection` is a library which provides a Meteor-like API for accessing
MongoDB, but bypasses Meteor completely, allowing you direct interaction with the database. This is necessary
in migrations because collection names could be changing during migrations and Meteor cannot really handle that.

You should call `addMigration` in the order you want migrations to be applied. The easiest way to assure that is
to create a directory `server/migrations/` in your project and have multiple files with `XXXX-description.coffee`
filenames, where `XXXX` is a consecutive number for the order you want, each file adding one migration.

There are some migration classes predefined:

* `AddReferenceFieldsMigration` – you are adding fields to a reference to be synced and you want to trigger resyncing of fields
* `RemoveReferenceFieldsMigration` – you are removing fields from a reference and you want to trigger resyncing of fields
* `AddGeneratedFieldsMigration` – you are adding auto-generated fields and you want to trigger generation of fields - you should pass a list of field names
* `ModifyGeneratedFieldsMigration` – you are modifying auto-generated fields and you want to trigger regeneration of fields - you should pass a list of field names
* `RemoveGeneratedFieldsMigration` – you are removing auto-generated fields - you should pass a list of field names
* `AddOptionalFieldsMigration` – you are adding optional fields - you should pass a list of field names
* `AddRequiredFieldsMigration` – you are adding required fields - you should pass a map between new field names and their initial values
* `RemoveFieldsMigration` – you are removing fields - you should pass a map between field names to be removed, and their values which should be set when reverting the migration
* `RenameFieldsMigration` – you are renaming fields - you should pass a map between current field names and the new names

To rename a collection backing the document, use `renameCollectionMigration`:

```
Post.renameCollectionMigration 'oldPosts', 'Posts'
```

Settings
--------

### `PEERDB_MIGRATIONS_DISABLED=` ###

If you want migrations to not run, set `PEERDB_MIGRATIONS_DISABLED` to a true value. Recommended setting is that only
*one* web-facing instance has migrations enabled and all other, including PeerDB instances, have them disabled. This
prevents any possible conflicts which could happen because of running migrations in parallel (but you are writing all
your migrations in a way that conflicts will never happen, using the
[Update If Current pattern](http://docs.mongodb.org/manual/tutorial/isolate-sequence-of-operations/#update-if-current),
aren't you?).

Disabling migrations just disables running them; documents are still populated with the `_schema` field.

Examples
--------

See migrations in:
 * [PeerLibrary](https://github.com/peerlibrary/peerlibrary/tree/development/server/migrations)
 * [PeerMind](https://github.com/peer/mind/tree/master/packages/core/migrations)
