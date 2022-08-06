AB = Artificial.Base
AE = Artificial.Everywhere
AM = Artificial.Mummification

class AM.Document.Versioning.VersionedCollection extends AM.Document.Versioning.VersionedCollection
  constructor: ->
    super arguments...
    
    @operationExecuted = new AB.Event
    
    @_loaders = {}
    @_loadersUpdatedDependency = new Tracker.Dependency
    
    @_handleLoaders()
    
  getDocumentForId: (id) ->
    if @_loaders[id]
      @_loaders[id].getDocument()
    
    else
      @_loadersUpdatedDependency.depend()
    
  _handleLoaders: ->
    @documentClass.documents.find({}).observe
      added: (document) ->
        # Only load versioned documents.
        return unless document.versioned
        
        @_loaders[document._id] = new AM.Document.Versioning.VersionedDocumentLoader @, document._id
        
        @_loadersUpdatedDependency.changed()
      
      removed: (document) ->
        @_loaders[document._id].destroy()
        delete @_loaders[document._id]
        
        @_loadersUpdatedDependency.changed()
