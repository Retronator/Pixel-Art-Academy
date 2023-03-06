AB = Artificial.Base
AE = Artificial.Everywhere
AM = Artificial.Mummification
Persistence = AM.Document.Persistence

class Persistence.PersistentCollection extends Mongo.Collection
  constructor: (@documentClass, options) ->
    super null, transform: (document) => new @documentClass document
  
    @find({}).observe
      added: (document) => @_informStorages document, 'added'
      changed: (document) => @_informStorages document, 'changed'
      removed: (document) => @_informStorages document, 'removed'
      
  _informStorages: (document, methodName) ->
    return unless syncedStorageIds = Persistence.profiles[document.profileId]?.syncedStorageIds
    Persistence.syncedStorages[syncedStorageId][methodName] document for syncedStorageId in syncedStorageIds
    return
    
  loadDocumentForId: (profileId, documentId) ->
    return unless syncedStorageIds = Persistence.profiles[document.profileId]?.syncedStorageIds
    
    # Retrieve a fresh version of the document from all synced storages and perform any necessary conflict resolution.
    loadPromises = (Persistence.syncedStorages[syncedStorageId].loadDocumentForId @documentClass, documentId for syncedStorageId in syncedStorageIds)
  
    Promise.all(loadPromises).then (documentClones) =>
      lastEditTime = null
      conflict = false
      for documentClone in documentClones when documentClone
        lastEditTime = documentClone.lastEditTime unless lastEditTime
        if lastEditTime isnt documentClone.lastEditTime
          conflict = true
          break

      unless conflict
        @_addDocument documentClone
        return documentClone
        
      # TODO: Perform conflict resolution.
      console.log "Conflicting documents", documentClones
      
      null
  
  loadDocumentsForProfileId: (profileId) ->
    return unless syncedStorageIds = Persistence.profiles[document.profileId]?.syncedStorageIds
    
    # Retrieve fresh version of the documents from all synced storages and perform any necessary conflict resolution.
    loadPromises = (Persistence.syncedStorages[syncedStorageId].loadDocumentsForProfileId @documentClass, profileId for syncedStorageId in syncedStorageIds)
    
    Promise.all(loadPromises).then (documentGroups) =>
      documentClonesById = {}
      
      for documents in documentGroups
        for document in documents
          documentClonesById[document._id] ?= []
          documentClonesById[document._id].push document
      
      documents = []
      
      for documentId, documentClones of documentClonesById
        lastEditTime = null
        conflict = false
        
        for documentClone in documentClones
          lastEditTime = documentClone.lastEditTime unless lastEditTime
          if lastEditTime isnt documentClone.lastEditTime
            conflict = true
            break
      
        unless conflict
          @_addDocument document
          documents.push document
          continue
      
        # TODO: Perform conflict resolution.
        console.log "Conflicting documents", documentClones
        
      documents
      
  _addDocument: (document) ->
    @upsert document._id, document
