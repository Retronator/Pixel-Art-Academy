AE = Artificial.Everywhere
AM = Artificial.Mummification

class AM.DatabaseContent extends AM.DatabaseContent
  @_publishHandlers = {}
  @_subscriptions = {}
  
  @initialized = new ReactiveField false
  
  @subscribe: (name, parameters...) ->
    # Try to find an existing subscription and activate it.
    if subscription = _.find @_subscriptions[name], (subscription) => not subscription.active and EJSON.equals subscription.parameters, parameters
      subscriptionId = subscription.id
      subscription.active = true

    else
      # Create a new subscription.
      subscriptionId = Random.id()
      subscription =
        id: subscriptionId
        parameters: EJSON.clone parameters
        active: true
        subscribedDocuments: null
        stop: =>
          throw new AE.InvalidOperationException "Multiple stop calls to the same subscription." unless @_subscriptions[name][subscriptionId]

          # Remove the subscription so we can't be stopped multiple times.
          delete @_subscriptions[name][subscriptionId]

          # If we're stopped before initialization happened, there's nothing to do.
          return unless subscription.subscribedDocuments

          # Mark that the subscription is not requiring this document anymore.
          for documentClassId, documentIds of subscription.subscribedDocuments
            documentClass = AM.Document.getClassForId documentClassId
            Tracker.nonreactive => documentClass.contentDocuments.unsubscribeFromDocument documentId for documentId in documentIds

      # If we're already initialized, we can immediately subscribe to the documents.
      subscription.subscribedDocuments = @_subscribeToDocuments @_publishHandlers[name], parameters... if @initialized()

      @_subscriptions[name][subscription.id] = subscription
      
    # If we're running in reactive context, stop the subscription if it's not active after a recomputation.
    if Tracker.active
      Tracker.onInvalidate =>
        subscription.active = false

        Tracker.afterFlush =>
          unless subscription.active
            # Note: We make sure the subscription hasn't been stopped yet, so we look for it again via name and id.
            @_subscriptions[name][subscriptionId]?.stop()
      
    # Return a handle that the subscriber can use to stop the subscription.
    stop: =>
      # Note: We make sure the wrapped subscription hasn't been stopped yet
      # from another handle, so we look for it again via name and id.
      @_subscriptions[name][subscriptionId]?.stop()
    
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
      
      unless documentClass
        console.warn "Unknown class #{documentClassId} in database content."
        continue
        
      continue unless documentClass.contentDocuments
      
      documentClass.contentDocuments.initialize directory.documents[documentClassId]

    # Subscribe to documents of any existing subscriptions.
    for subscriptionName, subscriptions of @_subscriptions
      for subscriptionId, subscription of subscriptions
        subscription.subscribedDocuments = @_subscribeToDocuments @_publishHandlers[subscriptionName], subscription.parameters...

    @initialized true

  @initializeDocumentClass: (documentClass) ->
    documentClass.contentDocuments = new @ContentCollection documentClass
