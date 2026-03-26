AB = Artificial.Base
AE = Artificial.Everywhere
AM = Artificial.Mummification
Persistence = AM.Document.Persistence

class Persistence.SyncedStorage
  @id: -> throw new AE.NotImplementedException "A synced storage must provide an ID for the kind of storage it is."
  id: -> @constructor.id()
  
  constructor: (@options = {}) ->
    if @options.differentialSave
      @_documentsCache = {}
  
    if @options.throttledChanges
      @_throttledChanges = {}
      
  ready: -> throw new AE.NotImplementedException "A synced storage must specify when it has supplied the profiles and is ready to provide documents."

  loadDocumentsForProfileId: (profileId, options) ->
    @loadDocumentsForProfileIdInternal(profileId, options).then (documents) =>
      if @options.differentialSave
        @_documentsCache[document._id] = _.cloneDeep document for document in documents
    
      documents
  
  added: (document) ->
    @addedInternal document
  
    @_documentsCache[document._id] = _.cloneDeep document if @options.differentialSave
  
  changed: (document) ->
    if @options.throttledChanges
      documentClassId = document.constructor.id()
      @_throttledChanges[documentClassId] ?= {}
      @_throttledChanges[documentClassId][document._id] ?= changed: => @_changed @_throttledChanges[documentClassId][document._id].latest
      @_throttledChanges[documentClassId][document._id].latest = document
      @_throttledChanges[documentClassId][document._id].changed()
      
    else
      @_changed document
    
  _changed: (document) ->
    document = _.objectDifference @_documentsCache[document._id], document if @options.differentialSave
    
    @changedInternal document
    
    @_documentsCache[document._id] = _.cloneDeep document if @options.differentialSave
  
  removed: (document) ->
    @removedInternal document
    
    delete @_documentsCache[document._id] if @options.differentialSave
    
  flushChanges: ->
    changedPromises = []
    
    for documentClassId, documents of @_throttledChanges
      for documentId, document of documents
        changedPromises.push document.changed.flush()
        
    Promise.all changedPromises

  loadDocumentsForProfileIdInternal: (profileId) ->
    # Override and return a promise that will resolve with the loaded documents.
    throw new AE.NotImplementedException "You must provide a way to load documents from the storage."

  addedInternal: (document) ->
    # Override and return a promise that will resolve when the document was added.
    throw new AE.NotImplementedException "You must provide a way to add a document to storage."

  changedInternal: (document) ->
    # Override and return a promise that will resolve when the document was added.
    throw new AE.NotImplementedException "You must provide a way to add a document to storage."

  removedInternal: (document) ->
    # Override and return a promise that will resolve when the document was deleted.
    throw new AE.NotImplementedException "You must provide a way to delete a document from storage."
