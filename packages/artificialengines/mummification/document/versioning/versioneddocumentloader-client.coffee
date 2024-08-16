AB = Artificial.Base
AE = Artificial.Everywhere
AM = Artificial.Mummification

class AM.Document.Versioning.VersionedDocumentLoader
  constructor: (@versionedCollection, @id) ->
    @_documentLoadedDependency = new Tracker.Dependency
    @_documentUpdatedDependency = new Tracker.Dependency
    
    @_loadInitialState()
    
  getDocument: (reactive) ->
    @_documentLoadedDependency.depend()
    @_documentUpdatedDependency.depend() if reactive
    @_document
    
  updated: ->
    @_documentUpdatedDependency.changed()

  reportExecuteActionError: ->
    # Executing an action on the document resulted in an error so we need to reload it freshly from the source.
    @_loadInitialState()
  
  reportNonVersionedChange: ->
    # Document was updated without a versioned action so we need to reload it freshly from the source.
    @_loadInitialState()
    
  _loadInitialState: ->
    @_document = null
    
    Tracker.autorun (computation) =>
      return unless @_document = @versionedCollection.documentClass.documents.findOne @id
      computation.stop()
  
      # Apply defaults.
      _.defaults @_document,
        historyPosition: 0
      
      @_document.initialize?()

      @_documentLoadedDependency.changed()
