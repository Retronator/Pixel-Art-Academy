AB = Artificial.Base
AE = Artificial.Everywhere
AM = Artificial.Mummification

class AM.Document.Versioning.VersionedCollection extends AM.Document.Versioning.VersionedCollection
  constructor: ->
    super arguments...
    
    @operationExecuted = new AB.Event
    @operationExecuted.addHandler @, @onOperationExecuted
  
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

  _handleLoaders: ->
    @documentClass.documents.find({}).observe
      added: (document) =>
        # Only load versioned documents.
        return unless document.versioned
        
        @_loaders[document._id] = new AM.Document.Versioning.VersionedDocumentLoader @, document._id
        
        @_loadersUpdatedDependency.changed()
      
      removed: (document) =>
        @_loaders[document._id].destroy()
        delete @_loaders[document._id]
        
        @_loadersUpdatedDependency.changed()

  onOperationExecuted: (document, operation, changedFields) ->
    # Tell the loader that the document was externally updated.
    loader = @_loaders[document._id]
    loader.updated()
