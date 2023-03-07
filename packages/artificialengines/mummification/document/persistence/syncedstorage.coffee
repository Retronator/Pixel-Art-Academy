AB = Artificial.Base
AE = Artificial.Everywhere
AM = Artificial.Mummification
Persistence = AM.Document.Persistence

class Persistence.SyncedStorage
  @id: -> throw new AE.NotImplementedException "A synced storage must provide an ID for the kind of storage it is."
  id: -> @constructor.id()
  
  constructor: (@options = {}) ->
    @_save = (document) =>
      document = _.objectDifference @_documentsCache[document._id], document if @options.differentialSave
      @saveInternal document
    
    if @options.throttledSave
      @_save = _.throttle @_save, @options.throttledSave
      
    if @options.incrementalSave
      @_documentsCache = {}

  loadDocumentForId: (documentClass, documentId) ->
    @loadDocumentForIdInternal(documentClass, documentId).then (document) =>
      if @options.incrementalSave
        @_documentsCache[document._id] = _.cloneDeep document
        
      document

  loadDocumentsForProfileId: (documentClass, profileId) ->
    @loadDocumentsForProfileIdInternal(documentClass, profileId).then (documents) =>
      if @options.incrementalSave
        @_documentsCache[document._id] = _.cloneDeep document for document in documents
    
      documents
      
  added: (document) -> @_save document
  changed: (document) -> @_save document
  removed: (document) -> @deleteInternal document
  
  loadDocumentForIdInternal: (documentClass, documentId) ->
    # Override and return a promise that will resolve with the loaded document.
    throw new AE.NotImplementedException "You must provide a way to load a document from the storage."

  loadDocumentsForProfileIdInternal: (documentClass, profileId) ->
    # Override and return a promise that will resolve with the loaded documents.
    throw new AE.NotImplementedException "You must provide a way to load a document from the storage."
    
  saveInternal: (document) ->
    # Override and return a promise that will resolve when the document was saved.
    throw new AE.NotImplementedException "You must provide a way to save a document to storage."

  deleteInternal: (document) ->
    # Override and return a promise that will resolve when the document was deleted.
    throw new AE.NotImplementedException "You must provide a way to delete a document from storage."
