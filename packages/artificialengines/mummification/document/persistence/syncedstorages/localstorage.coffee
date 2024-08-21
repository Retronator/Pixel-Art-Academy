AB = Artificial.Base
AE = Artificial.Everywhere
AM = Artificial.Mummification
Persistence = AM.Document.Persistence

class Persistence.SyncedStorages.LocalStorage extends Persistence.SyncedStorage
  @id: -> 'LocalStorage'
  
  constructor: (@options) ->
    super arguments...
    
    throw new AE.ArgumentNullException 'Storage key must be provided.' unless @options?.storageKey?
    
    directoryJson = localStorage.getItem @options.storageKey
    @directory = if directoryJson and directoryJson isnt 'undefined' then EJSON.parse directoryJson else {}
    
    # Send all profiles to persistence.
    profiles = []
    
    profileClassId = Persistence.Profile.id()
    for documentId of @directory[profileClassId]
      documentJson = localStorage.getItem @_getDocumentStorageKey profileClassId, documentId
  
      if documentJson and documentJson isnt 'undefined'
        profiles.push EJSON.parse documentJson
      
    Persistence.addProfiles @constructor.id(), profiles

  ready: -> true
  
  loadDocumentsForProfileIdInternal: (profileId, options) ->
    syncedStorageId = @constructor.id()
    
    new Promise (resolve) =>
      documents = {}
  
      # Count number of documents that need to be loaded.
      persistenceProfileDocumentClassId = Persistence.Profile.id()
      totalDocumentsCount = 0
      loadedDocumentsCount = 0

      for documentClassId, documentClassArea of @directory when documentClassId isnt persistenceProfileDocumentClassId
        for documentId, entry of documentClassArea when entry.profileId is profileId
          totalDocumentsCount++

      # Perform the actual loading.
      for documentClassId, documentClassArea of @directory when documentClassId isnt persistenceProfileDocumentClassId
        documents[documentClassId] = {}
        
        for documentId, entry of documentClassArea when entry.profileId is profileId
          documentJson = localStorage.getItem @_getDocumentStorageKey documentClassId, documentId
          
          if documentJson and documentJson isnt 'undefined'
            documents[documentClassId][documentId] = "#{syncedStorageId}": EJSON.parse documentJson
          
          loadedDocumentsCount++
          options.onProgress loadedDocumentsCount / totalDocumentsCount
      
      resolve documents
  
  addedInternal: (document) -> @_save document
  changedInternal: (document) -> @_save document
  removedInternal: (document) -> @_delete document
  
  _save: (document) ->
    new Promise (resolve) =>
      documentJson = EJSON.stringify document.getSourceData()
      localStorage.setItem @_getDocumentStorageKey(document), documentJson
  
      @_getDirectoryAreaForDocument(document)[document._id] = _.pick document, 'profileId'
      @_saveDirectory()
      
      resolve()
      
  _getDocumentStorageKey: (documentOrDocumentClassId, documentId) ->
    if _.isObject documentOrDocumentClassId
      document = documentOrDocumentClassId
      documentClassId = document.constructor.id()
      documentId = document._id
    
    else
      documentClassId = documentOrDocumentClassId
      
    "#{@options.storageKey}.#{documentClassId}.#{documentId}"
    
  _getDirectoryAreaForDocument: (document) ->
    documentClassId = document.constructor.id()
    @directory[documentClassId] ?= {}
    @directory[documentClassId]
    
  _delete: (document) ->
    new Promise (resolve) =>
      localStorage.removeItem "#{@options.storageKey}.#{document._id}"
  
      delete @_getDirectoryAreaForDocument(document)[document._id]
      @_saveDirectory()

      resolve()
      
  _saveDirectory: ->
    directoryJson = EJSON.stringify @directory
    localStorage.setItem @options.storageKey, directoryJson
