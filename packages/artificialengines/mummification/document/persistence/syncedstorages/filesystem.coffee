AB = Artificial.Base
AE = Artificial.Everywhere
AM = Artificial.Mummification
Persistence = AM.Document.Persistence

class Persistence.SyncedStorages.FileSystem extends Persistence.SyncedStorage
  @id: -> 'FileSystem'
  
  constructor: (@options) ->
    super arguments...

    throw new AE.ArgumentNullException 'Relative directory path must be provided.' unless @options?.relativeDirectoryPath?
  
    @_ready = new ReactiveField false

    @initialize()

  initialize: ->
    applicationPaths = await Desktop.call 'filesystem', 'getApplicationPaths'
    @storagePath = "#{applicationPaths.userData}/#{@options.relativeDirectoryPath}"

    @directory = {}
    @directoryPath = "#{@storagePath}/directory.json"

    try
      directoryResponse = await Desktop.fetchFile @directoryPath

    catch error
      console.error "Error while fetching file system database directory.", error
      return

    unless directoryResponse.ok
      console.log "No file system database directory was present."
      return

    @directory = await directoryResponse.json()

    # Send all profiles to persistence.
    profiles = []

    profileClassId = Persistence.Profile.id()
    for documentId of @directory[profileClassId]
      if document = await @_load @_getDocumentPath profileClassId, documentId
        profiles.push document

    Persistence.addProfiles @constructor.id(), profiles
  
    @_ready true
    
  ready: -> @_ready()

  loadDocumentsForProfileId: (profileId) ->
    syncedStorageId = @constructor.id()

    new Promise (resolve) =>
      documents = {}

      for documentClassId, documentClassArea of @directory when documentClassId isnt Persistence.Profile.id()
        documents[documentClassId] = {}

        for documentId, entry of documentClassArea when entry.profileId is profileId
          if document = await @_load @_getDocumentPath documentClassId, documentId
            documents[documentClassId][documentId] = "#{syncedStorageId}": document

      resolve documents

  addedInternal: (document) -> @_add document
  changedInternal: (document) -> @_update document
  removedInternal: (document) -> @_delete document

  _add: (document) ->
    @_getDirectoryAreaForDocument(document)[document._id] = _.pick document, 'profileId'
    writeDirectoryPromise = @_saveDirectory()
    updatePromise = @_update document

    Promise.all [updatePromise, writeDirectoryPromise]

  _update: (document) ->
    path = @_getDocumentPath document
    documentJson = EJSON.stringify document.getSourceData()
    error = await Desktop.call 'filesystem', 'writeFile', path, documentJson
    throw new AE.ExternalException "Writing document to the file system failed.", path, error if error

  _getDocumentPath: (documentOrDocumentClassId, documentId) ->
    if _.isObject documentOrDocumentClassId
      document = documentOrDocumentClassId
      documentClassId = document.constructor.id()
      documentId = document._id

    else
      documentClassId = documentOrDocumentClassId

    "#{@storagePath}/#{documentClassId}/#{documentId}.json"

  _getDirectoryAreaForDocument: (document) ->
    documentClassId = document.constructor.id()
    @directory[documentClassId] ?= {}
    @directory[documentClassId]

  _load: (path) ->
    try
      response = await Desktop.fetchFile path

    catch error
      console.error "Error while fetching file system file.", path, error
      return

    unless response.ok
      console.error "Requested file system file does not exist.", path, response
      return

    documentJson = await response.text()
    EJSON.parse documentJson

  _delete: (document) ->
    delete @_getDirectoryAreaForDocument(document)[document._id]
    writeDirectoryPromise = @_saveDirectory()

    path = @_getDocumentPath document
    deleteDocumentPromise = Desktop.call 'filesystem', 'deleteFile', path

    Promise.all [deleteDocumentPromise, writeDirectoryPromise]

  _saveDirectory: ->
    directoryJson = EJSON.stringify @directory
    await Desktop.call 'filesystem', 'writeFile', @directoryPath, directoryJson
