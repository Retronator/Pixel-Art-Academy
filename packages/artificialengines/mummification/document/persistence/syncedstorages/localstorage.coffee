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

  loadDocumentForId: (documentClass, documentId) ->
    new Promise (resolve) =>
      documentJson = localStorage.getItem "#{@options.storageKey}.#{documentId}"
      document = EJSON.parse documentJson if documentJson and documentJson isnt 'undefined'
      resolve document
  
  loadDocumentsForProfileId: (documentClass, profileId) ->
    new Promise (resolve) =>
      documents = []
      
      for documentId, entry of @directory when entry.profileId is profileId
        documentJson = localStorage.getItem "#{@options.storageKey}.#{documentId}"
        documents.push EJSON.parse documentJson if documentJson and documentJson isnt 'undefined'
        
      resolve documents
  
  saveInternal: (document) ->
    new Promise (resolve) =>
      documentJson = EJSON.stringify document
      localStorage.setItem "#{@options.storageKey}.#{document._id}", documentJson
  
      @directory[document._id] = _.pick document, 'profileId'
      @_saveDirectory()
      
      resolve()
      
  deleteInternal: (document) ->
    new Promise (resolve) =>
      localStorage.removeItem "#{@options.storageKey}.#{document._id}"
  
      delete @directory[document._id]
      @_saveDirectory()

      resolve()
      
  _saveDirectory: ->
    directoryJson = EJSON.stringify @directory
    localStorage.setItem @options.storageKey, directoryJson
