AB = Artificial.Base
AE = Artificial.Everywhere
AM = Artificial.Mummification
Persistence = AM.Document.Persistence

class Persistence.SyncedStorages.IndexedDB extends Persistence.SyncedStorage
  @id: -> 'IndexedDB'

  constructor: (@options) ->
    super arguments...

    throw new AE.ArgumentNullException 'Database name must be provided.' unless @options?.databaseName?

    @_ready = new ReactiveField false
    
    @initialize()

  initialize: ->
    throw new AE.ExternalException 'IndexedDB is not supported in this browser.' unless indexedDB?

    @database = await @_openDatabase()
    
    # Send all profiles to persistence.
    profiles = []
    
    for record in await @_getAllByIndex 'documentClassId', Persistence.Profile.id()
      profiles.push EJSON.parse record.documentJson
    
    Persistence.addProfiles @constructor.id(), profiles

    @_ready true

  ready: -> @_ready()

  loadDocumentsForProfileIdInternal: (profileId, options = {}) ->
    syncedStorageId = @constructor.id()
    persistenceProfileDocumentClassId = Persistence.Profile.id()

    documents = {}

    documentRecords = await @_getAllByIndex 'profileId', profileId
    _.remove documentRecords, (record) => record.documentClassId is persistenceProfileDocumentClassId

    totalDocumentsCount = documentRecords.length
    loadedDocumentsCount = 0

    for record in documentRecords
      documents[record.documentClassId] ?= {}
      documents[record.documentClassId][record.id] = "#{syncedStorageId}": EJSON.parse record.documentJson

      loadedDocumentsCount++
      options.onProgress? loadedDocumentsCount / totalDocumentsCount

    documents

  addedInternal: (document) -> @_save document
  changedInternal: (document) -> @_save document
  removedInternal: (document) -> @_delete document

  _save: (document) ->
    record =
      id: document._id
      documentClassId: document.constructor.id()
      profileId: if document instanceof Persistence.Profile then document._id else document.profileId
      documentJson: EJSON.stringify document.getSourceData()

    transaction = @_startTransaction 'readwrite'
    transaction.objectStore('documents').put record

    await @_transactionPromise transaction

  _delete: (document) ->
    if document instanceof Persistence.Profile
      documentRecords = await @_getAllByIndex 'profileId', document._id

      transaction = @_startTransaction 'readwrite'
      documentsStore = transaction.objectStore 'documents'

      for record in documentRecords
        documentsStore.delete record.id

    else
      transaction = @_startTransaction 'readwrite'
      transaction.objectStore('documents').delete document._id

    await @_transactionPromise transaction

  _openDatabase: ->
    new Promise (resolve, reject) =>
      openRequest = indexedDB.open @options.databaseName, 1

      openRequest.onupgradeneeded = (event) =>
        database = event.target.result

        if database.objectStoreNames.contains 'documents'
          documentsStore = event.target.transaction.objectStore 'documents'
        
        else
          documentsStore = database.createObjectStore 'documents', keyPath: 'id'

        documentsStore.createIndex 'documentClassId', 'documentClassId' unless documentsStore.indexNames.contains 'documentClassId'
        documentsStore.createIndex 'profileId', 'profileId' unless documentsStore.indexNames.contains 'profileId'
  
      openRequest.onsuccess = =>
        resolve openRequest.result
  
      openRequest.onerror = =>
        reject openRequest.error

  _getAllByIndex: (indexName, key) ->
    transaction = @_startTransaction()
    request = transaction.objectStore('documents').index(indexName).getAll key

    @_requestPromise request

  _startTransaction: (mode = 'readonly') ->
    @database.transaction ['documents'], mode

  _requestPromise: (request) ->
    new Promise (resolve, reject) ->
      request.onsuccess = ->
        resolve request.result

      request.onerror = ->
        reject request.error

  _transactionPromise: (transaction) ->
    new Promise (resolve, reject) ->
      transaction.oncomplete = ->
        resolve()

      transaction.onerror = ->
        reject transaction.error

      transaction.onabort = ->
        reject transaction.error
