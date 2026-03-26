AB = Artificial.Base
AE = Artificial.Everywhere
AM = Artificial.Mummification

class AM.Document.Versioning.VersionedCollection extends AM.Document.Versioning.VersionedCollection
  constructor: ->
    super arguments...
    
    # Use to subscribe to individual operations being executed (including during partial actions).
    @operationExecuted = new AB.Event @
    @operationExecuted.addHandler @, @onOperationExecuted
    
    # Use to subscribe to operations executed in batches (no partial actions).
    @operationsExecuted = new AB.Event @
  
    @_loaders = {}
    @_loadersUpdatedDependency = new Tracker.Dependency
    
    @_handleLoaders()
    
  getDocumentForId: (id, reactive = true) ->
    if @_loaders[id]
      @_loaders[id].getDocument reactive
    
    else
      @_loadersUpdatedDependency.depend()
      null

  reportExecuteActionError: (id) ->
    @_loaders[id].reportExecuteActionError()
    
  reportNonVersionedChange: (id) ->
    @_loaders[id].reportNonVersionedChange()

  _handleLoaders: ->
    @documentClass.documents.find({}).observe
      added: (document) =>
        # Only load versioned documents.
        return unless document.versioned
        
        @_loaders[document._id] = new AM.Document.Versioning.VersionedDocumentLoader @, document._id
        
        @_loadersUpdatedDependency.changed()
      
      removed: (document) =>
        delete @_loaders[document._id]
        
        @_loadersUpdatedDependency.changed()

  onOperationExecuted: (document, operation, changedFields) ->
    # Tell the loader that the document was externally updated.
    loader = @_loaders[document._id]
    loader.updated()
