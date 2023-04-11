AE = Artificial.Everywhere
AM = Artificial.Mummification

class AM.DatabaseContent extends AM.DatabaseContent
  @_publishHandlers = {}
  @_subscriptions = {}
  
  @initialized = new ReactiveField false
  
  @subscribe: (name, parameters...) ->
    # Make sure we're initialized.
    unless @initialized()
      # In reactive context we can simply return to be called again later, otherwise throw an exception.
      return if Tracker.active
      throw new AE.InvalidOperationException "Database content hasn't finished initializing."
  
    # Try to find an existing subscription and activate it.
    if existingSubscription = _.find @_subscriptions[name], (subscription) -> not subscription.active and EJSON.equals subscription.parameters, parameters
      existingSubscription.active = true
    
    else
      # Create a new subscription.
      newSubscription =
        id: Random.id()
        parameters: EJSON.clone parameters
        active: true
        subscribedDocuments: @_subscribeToDocuments @_publishHandlers[name], parameters...
        stop: =>
          # Mark that the subscription is not requiring this document anymore.
          for documentClassId, documentIds of newSubscription.subscribedDocuments
            documentClass = AM.Document.getClassForId documentClassId
            documentClass.contentDocuments.unsubscribeFromDocument documentId for documentId in documentIds
          
          # Remove the subscription itself.
          _.remove @_subscriptions[name][newSubscription.id]
  
      @_subscriptions[name][newSubscription.id] = newSubscription
      
      # If we're running in reactive context, stop the subscription if it's not active after a recomputation.
      if Tracker.active
        Tracker.onInvalidate =>
          newSubscription.active = false
        
        Tracker.afterFlush =>
          newSubscription.stop() unless newSubscription.active
    
    # Return a handle that the subscriber can use to stop the subscription.
    stop: => newSubscription.stop()
    
  @_subscribeToDocuments: (handler, parameters ...) ->
    subscribedDocuments = {}
    
    cursors = handler parameters...
    cursors = [cursors] unless _.isArray cursors

    for cursor in cursors
      cursor.forEach (informationDocument) =>
        subscribedDocuments[informationDocument._documentClassId] ?= []
        subscribedDocuments[informationDocument._documentClassId].push informationDocument._id
      
        documentClass = AM.Document.getClassForId informationDocument._documentClassId
        documentClass.contentDocuments.subscribeToDocument informationDocument._id
  
    subscribedDocuments

  @publish: (name, handler) ->
    if name
      @_publishHandlers[name] = handler
      @_subscriptions[name] = {}
      
    else
      # Publications without a name are always active. Subscribe to it as soon as we've initialized.
      Tracker.autorun (computation) =>
        return unless @initialized()
        computation.stop()
        
        @_subscribeToDocuments handler

  @initialize: (directory) ->
    documentClassIds = _.keys directory.documents
    
    for documentClassId in documentClassIds
      documentClass = AM.Document.getClassForId documentClassId
      continue unless documentClass.contentDocuments
      
      documentClass.contentDocuments.initialize directory.documents[documentClassId]
  
    @initialized true

  @initializeDocumentClass: (documentClass) ->
    documentClass.contentDocuments = new @ContentCollection documentClass
