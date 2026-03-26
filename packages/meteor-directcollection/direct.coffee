import Future from 'fibers/future'

export class DirectCollection
  connections = {}

  constructor: (@name, @_makeNewID, @_databaseUrl) ->
    unless @_makeNewID
      @_makeNewID = -> Random.id()

  findToArray: (selector, options) =>
    options = {} unless options
    cursor = @_getCollection().find(selector, options)
    blocking(cursor, cursor.toArray)()

  findEach: (selector, options, eachCallback) =>
    if _.isFunction options
      eachCallback = options
      options = {}
    options = {} unless options

    cursor = @_getCollection().find(selector, options)

    nextObject = blocking(cursor, cursor.next or cursor.nextObject)

    while document = nextObject()
      eachCallback document

    return

  count: (selector, options) =>
    options = {} unless options
    collection = @_getCollection()
    blocking(collection, collection.count)(selector, options)

  findOne: (selector, options) =>
    options = {} unless options
    collection = @_getCollection()
    blocking(collection, collection.findOne)(selector, options)

  insert: (document) =>
    unless '_id' of document
      document = EJSON.clone document
      document._id = @_makeNewID()
    collection = @_getCollection()
    blocking(collection, collection.insert)(document, w: 1)
    return document._id

  update: (selector, modifier, options) =>
    options = {} unless options
    options.w ?= 1
    collection = @_getCollection()
    result = blocking(collection, collection.update)(selector, modifier, options)

    result = result.result if _.isObject(result) and result.result

    return result if options._returnObject or not _.isObject result

    result.modifiedCount

  remove: (selector, options) =>
    options = {} unless options
    options.w ?= 1
    collection = @_getCollection()
    result = blocking(collection, collection.remove)(selector, options)

    result = result.result if _.isObject(result) and result.result

    return result if options._returnObject or not _.isObject result

    result.deletedCount

  renameCollection: (newName, options) =>
    options = {} unless options
    collection = @_getCollection()
    blocking(collection, collection.rename)(newName, options)

  findAndModify: (selector, sort, document, options) =>
    options = {} unless options
    options.w ?= 1
    collection = @_getCollection()
    blocking(collection, collection.findAndModify)(selector, sort, document, options)

  createIndex: (fieldOrSpec, options) =>
    options = {} unless options
    options.w ?= 1
    collection = @_getCollection()
    blocking(collection, collection.createIndex)(fieldOrSpec, options)

  dropIndex: (indexName, options) =>
    options = {} unless options
    options.w ?= 1
    collection = @_getCollection()
    blocking(collection, collection.dropIndex)(indexName, options)

  @_getConnection: (databaseUrl) ->
    if databaseUrl?
      if not connections[databaseUrl]
        connections[databaseUrl] = new MongoInternals.RemoteCollectionDriver databaseUrl, {}

      connections[databaseUrl]
    else
      MongoInternals.defaultRemoteCollectionDriver()

  _getCollection: =>
    mongo = @constructor._getConnection(@_databaseUrl).mongo
    if mongo.rawCollection
      mongo.rawCollection @name
    else
      # _getCollection is for Meteor < 1.0.4.
      mongo._getCollection @name

  @_getDb: (databaseUrl) ->
    mongo = @_getConnection(databaseUrl).mongo
    # _withDb is for Meteor < 1.0.4.
    if mongo._withDb
      future = new Future()
      @_getConnection(databaseUrl).mongo._withDb (db) ->
        future.return db
      future.wait()
    else
      mongo.db

  @command: (selector, options, databaseUrl) ->
    options = {} unless options
    db = @_getDb databaseUrl
    blocking(db, db.command)(selector, options)
