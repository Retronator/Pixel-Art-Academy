AB = Artificial.Base
AE = Artificial.Everywhere
AM = Artificial.Mummification

class AM.Document.Versioning.VersionedDocumentLoader
  constructor: (@versionedCollection, @id) ->
    @_documentLoadedDependency = new Tracker.Dependency
    @_documentUpdatedDependency = new Tracker.Dependency
    
    @_loadInitialState()
    
    @_latestHistorySubscriptionHandle = @versionedCollection.documentClass.latestHistoryForId.subscribe @id

    @versionedCollection.latestHistoryDocuments.find(@id).observe
      added: (@_latestHistory) => @_handleHistoryChanges()
      changed: (@_latestHistory) => @_handleHistoryChanges()
    
  destroy: ->
    @_latestHistorySubscriptionHandle.stop()
  
  getDocument: (reactive) ->
    @_documentLoadedDependency.depend()
    @_documentUpdatedDependency.depend() if reactive
    @_document
    
  updated: ->
    @_documentUpdatedDependency.changed()

  reportExecuteActionError: ->
    # Executing an action on the document resulted in an error so we need to reload it freshly from the server.
    @_loadInitialState()
    
  _loadInitialState: ->
    @_document = null
    
    @versionedCollection.documentClass.load @id, (error, result) =>
      return console.error error if error
  
      # Apply defaults.
      _.defaults result,
        historyStart: 0
        historyPosition: 0
        history: []
        historyArchive: []
      
      console.log "Reloaded", result

      # Create the document and initialize it if it requires it.
      @_document = new @versionedCollection.documentClass result
      @_document.initialize?()

      @_documentLoadedDependency.changed()
      
      # If we already got some history changes, handle them.
      @_handleHistoryChanges()
  
  _handleHistoryChanges: ->
    # Nothing to do if we didn't get the initial document or history state yet.
    return unless @_document and @_latestHistory
    
    # We only handle changes that are ahead of the client. If they are behind, we assume they are the client's
    # and rely on getting an exception when applying an action on an invalid version of the document.
    return if @_latestHistory.lastEditTime < @_document.lastEditTime
    
    # We must make sure our local document state reflects what it is on the server.
    # See how many actions (up to history position) are matching.
    matchingActionsCount = 0

    console.log "handling history changes", @_document.historyPosition, @_latestHistory.historyPosition
    
    for historyPosition in [@_latestHistory.historyStart...@_latestHistory.historyPosition]
      documentActionIndex = historyPosition - @_document.historyStart
      latestHistoryActionIndex = historyPosition - @_latestHistory.historyStart
      
      break unless documentAction = @_document.history[documentActionIndex]
      latestHistoryAction = @_latestHistory.history[latestHistoryActionIndex]

      # For efficiency we only compare hash codes.
      if documentAction.hashCode is latestHistoryAction.hashCode
        matchingActionsCount++
        
      else
        break
        
    # If history position matches and all previous actions match, there's nothing to do.
    return if @_latestHistory.historyPosition is @_document.historyPosition and matchingActionsCount is @_latestHistory.historyPosition - @_latestHistory.historyStart
    
    # If we don't have any matching actions, we can't roll back far enough to get to a synced state, so we have to reload the document from the server.
    # The exception is when we're actually trying to roll back to the start of history.
    unless matchingActionsCount or @_latestHistory.historyPosition is 0
      @_loadInitialState()
      return
    
    # If we have a partial action in progress, we need to roll back its effects.
    AM.Document.Versioning.executeOperations @_document, @_document.partialAction.backward if @_document.partialAction
    
    # Roll back all non-matching local actions.
    lastMatchingHistoryPosition = @_latestHistory.historyStart + matchingActionsCount
    
    for historyPosition in [@_document.historyPosition...lastMatchingHistoryPosition]
      documentActionIndex = historyPosition - @_document.historyStart - 1
      documentAction = @_document.history[documentActionIndex]
      
      AM.Document.Versioning.executeOperations @_document, documentAction.backward

    # Apply all non-matching latest actions.
    for historyPosition in [lastMatchingHistoryPosition...@_latestHistory.historyPosition]
      latestHistoryActionIndex = historyPosition - @_latestHistory.historyStart
      latestHistoryAction = @_latestHistory.history[latestHistoryActionIndex]
  
      AM.Document.Versioning.executeOperations @_document, latestHistoryAction.forward

    # If we have a partial action in progress, we need to apply its effects again.
    AM.Document.Versioning.executeOperations @_document, @_document.partialAction.forward if @_document.partialAction

    # Sync history fields.
    @_document.lastEditTime = @_latestHistory.lastEditTime
    @_document.historyPosition = @_latestHistory.historyPosition
  
    lastMatchingDocumentActionIndex = lastMatchingHistoryPosition - @_document.historyStart - 1
    lastMatchingLatestHistoryActionIndex = lastMatchingHistoryPosition - @_latestHistory.historyStart - 1
    
    newActions = @_latestHistory.history[lastMatchingLatestHistoryActionIndex + 1..]
    
    @_document.history.splice lastMatchingDocumentActionIndex + 1, @_document.history.length, newActions...

    # Report history changes.
    @updated()
