DirectCollection
================

Meteor smart package which provides [blocking](https://github.com/peerlibrary/meteor-blocking) (using
[fibers](https://github.com/laverdet/node-fibers)) MongoDB API for direct/native access to collections.
It wraps native node.js MongoDB API into an interface similar to Meteor, but allowing direct access to
collections, even if they are not defined through Meteor. It reuses Meteor database connection.

It is useful when you want direct access to MongoDB, not bounded by collections defined in Meteor,
but you are working inside Meteor and would like a similar coding style and access to other Meteor
functions which might not work well in callbacks.

Installation
------------

```
meteor add retronator:directcollection
```

API
---

Create a direct collection:

```
var directCollection = new DirectCollection(name, makeNewID, databaseUrl);
```

It accepts three arguments, name of MongoDB collection, function which returns a document ID which will be used
when inserting documents without `_id` field (default is `Random.id()`) and an optional database URL that can
be used for connecting to external databases.

Available collection methods:

* `findToArray(selector, options)` – returns an array of documents
* `findEach(selector, options, eachCallback)` – calls `eachCallback` for each document
* `count(selector, options)` – returns the count
* `findOne(selector, options)` – returns one document
* `insert(document)` – returns document `_id`
* `update(selector, modifier, options)` – returns number of updated documents
* `remove(selector)` – returns number of removed documents
* `renameCollection(newName, options)` – renames the collection
* `findAndModify(selector, sort, document, options)` – modifies and returns a single document

Available class methods:

* `command(selector, options, databaseUrl)` – executes a command against a Meteor database

Related projects
----------------

* [mongo-direct](http://atmospherejs.com/package/mongo-direct) – extends `Meteor.Collection` with methods for direct/native access
