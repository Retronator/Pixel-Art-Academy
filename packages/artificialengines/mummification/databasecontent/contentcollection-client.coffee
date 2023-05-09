AB = Artificial.Base
AE = Artificial.Everywhere
AM = Artificial.Mummification

decoder = null
Pako = require 'pako'

class AM.DatabaseContent.ContentCollection extends AM.Collection
  constructor: (documentClass) ->
    super null

    decoder ?= new TextDecoder
    
    @documentClass = documentClass
    
    # Separate Meteor-handled documents if persistence didn't do it yet, so we can manage them ourselves.
    unless @documentClass.serverDocuments
      @documentClass.serverDocuments = @documentClass.documents
      @documentClass.documents = new AM.Collection null, transform: (document) => new documentClass document

    # Observe changes to information documents.
    @find({}).observe
      added: (document) => @_handleDocument document._id
      changed: (document) => @_handleDocument document._id
      removed: (document) => @_handleDocument document._id
  
    # Observe changes of main documents.
    @documentClass.documents.find({}).observe
      added: (document) => @_handleDocument document._id
      changed: (document) => @_handleDocument document._id
      removed: (document) => @_handleDocument document._id
  
    # Observe changes of server documents.
    @documentClass.serverDocuments.find({}).observe
      added: (document) => @_handleDocument document._id
      changed: (document) => @_handleDocument document._id
      removed: (document) => @_handleDocument document._id
  
    @_documentLoaders = {}
    @_loadedDocuments = {}
    
  initialize: (informationDocuments) ->
    # Insert all information documents.
    for informationDocument in informationDocuments
      informationDocument._subscriptionsCount = 0
      informationDocument._documentClassId = @documentClass.id()
      @insert informationDocument
    
  subscribeToDocument: (documentId) ->
    @_changeSubscriptionCount documentId, 1
  
  unsubscribeFromDocument: (documentId) ->
    @_changeSubscriptionCount documentId, -1
    
  _changeSubscriptionCount: (documentId, change) ->
    informationDocument = @findOne documentId
    @update documentId, $set: _subscriptionsCount: informationDocument._subscriptionsCount + change
  
  _handleDocument: (documentId) ->
    document = @documentClass.documents.findOne documentId
    serverDocument = @documentClass.serverDocuments.findOne documentId
    informationDocument = @findOne documentId
    
    # We should always upsert the server document (it has priority since it's changeable).
    if serverDocument
      @documentClass.documents.upsert serverDocument._id, serverDocument
      
      # See if this document is part of database content and was inserted from there.
      if informationDocument?._localInsert
        # Remove the loaded document to free up memory.
        @_unloadDocument documentId
      
        # Mark that the document comes from the server so we can clean up appropriately.
        @update documentId, $set: _localInsert: false
        
      return
    
    # See if we need to remove the document.
    if document
      # We should clean up the server document if it was removed.
      unless informationDocument?._localInsert
        # If this document is part of database content and subscriptions
        # still require it, we should replace it with that.
        if informationDocument?._subscriptionsCount > 0
          @_insertDocumentLocally informationDocument
          
        else
          @documentClass.documents.remove documentId
        
      # We should remove the document when subscriptions don't require it
      else if informationDocument?._subscriptionsCount is 0
        # Remove the document from the documents collection since we inserted it locally.
        @documentClass.documents.remove documentId
    
        # Mark that we've cleaned up the insert.
        @update documentId, $set: _localInsert: false
        
        # Remove the loaded document to free up memory.
        @_unloadDocument documentId

    # We should insert the document when subscriptions require it but it's not present.
    else if informationDocument?._subscriptionsCount > 0
      @_insertDocumentLocally informationDocument
      
  _insertDocumentLocally: (informationDocument) ->
    # Load the document if necessary.
    unless loadedDocument = @_loadedDocuments[informationDocument._id]
      @_loadDocument informationDocument
    
      # We can simply quit here since we'll be called again once the document has loaded.
      return
  
    @documentClass.documents.upsert loadedDocument._id, loadedDocument
  
    # Mark that we've performed the insert so we'll also clean up when we don't need the document anymore.
    @update informationDocument._id, $set: _localInsert: true

  _loadDocument: (informationDocument) ->
    # Nothing to do if we've already loaded the document.
    return if @_loadedDocuments[informationDocument._id]
    
    # If we have a loader active, just set that its result is needed.
    if @_documentLoaders[informationDocument._id]
      @_documentLoaders[informationDocument._id].active = true
      return
  
    # Start a new loader.
    loader =
      active: true
      loading: true

    @_documentLoaders[informationDocument._id] = loader
  
    url = "/databasecontent/#{informationDocument.path}"
  
    fetch(url).then((response) => response.arrayBuffer()).then (compressedBinaryData) =>
      # Make sure we still need the document.
      if loader.active
        binaryData = Pako.ungzip compressedBinaryData
        
        @_loadedDocuments[informationDocument._id] = EJSON.parse decoder.decode binaryData
        @_handleDocument informationDocument._id
        
      # Remove the loader.
      delete @_documentLoaders[informationDocument._id]
      
  _unloadDocument: (documentId) ->
    # Remove the loaded document.
    delete @_loadedDocuments[documentId]
    
    # If the document is just being loaded, mark that we don't need the result anymore.
    @_documentLoaders[documentId]?.active = false
