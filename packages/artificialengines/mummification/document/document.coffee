AB = Artificial.Base
AE = Artificial.Everywhere
AM = Artificial.Mummification

# Extended PeerDB document with common operations.
class AM.Document extends Document
  @id: -> throw new AE.NotImplementedException "You must specify document's id."
  
  @_documentClassesById = {}

  @Meta: (meta) ->
    super arguments...

    # This stores registered subclasses for this Document class.
    @_documentClassesByType = {}

    return if meta.abstract

    # This enables retrieval of all document classes in general.
    @_documentClassesById[@id()] = @

    # Referrers are incoming references from other documents.
    @_referrers = []

    # Analyze field references to add the referrers, after all documents have been defined.
    Document.prepare => @_analyzeFields @Meta.fields, ''

    # Add convenience method to find and fetch documents with one call.
    # We can't use => because arguments would be bound to the @Meta arguments.
    documents = @documents
    documents.fetch = ->
      cursor = documents.find arguments...
      cursor.fetch()

  @_analyzeFields: (source, path) ->
    for fieldName, field of source
      prefix = if path.length then "#{path}." else ''
      fieldPath = "#{prefix}#{fieldName}"

      if field instanceof Document._ReferenceField
        # Skip reverse fields.
        continue if _.find @Meta._reverseFields, (reverseField) => reverseField.reverseName is fieldPath

        # Inform the target document of the reference.
        field.targetDocument.addReferrer field

      else if field.constructor is Object
        @_analyzeFields field, fieldPath
  
  @Meta
    abstract: true
  
  @method: (name) ->
    return new AB.Method
      name: "#{@type or @id()}.#{name}"
  
  @subscription: (name, options) ->
    return new AM.DatabaseContent.Subscription _.extend {}, options,
      name: "#{@type or @id()}.#{name}"

  @getClassForId: (id) ->
    @_documentClassesById[id]

  # Returns all registered type names.
  @getClassIds: ->
    _.keys @_documentClassesById
  
  @registerType: (typeName, documentClass) ->
    throw new AE.ArgumentNullException "You must specify a document class." unless documentClass
    
    # Make sure the document class inherits from Document.
    throw new AE.ArgumentException "Provided document class is not a Document." unless documentClass.prototype instanceof Document
    
    # Save the document class to our map.
    @_documentClassesByType[typeName] = documentClass
    
  @getClassForType: (typeName) ->
    # Retrieve the document class from the map.
    @_documentClassesByType[typeName]

  # Returns all registered type names.
  @getTypes: ->
    _.keys @_documentClassesByType
    
  @enablePersistence: ->
    AM.Document.Persistence.initializeDocumentClass @
  
  @enableVersioning: ->
    @enablePersistence @
    AM.Document.Versioning.initializeDocumentClass @
    
  @enableDatabaseContent: ->
    AM.DatabaseContent.initializeDocumentClass @ if Meteor.isClient
  
  @getDocumentForId: (id) ->
    return unless document = @documents.findOne id

    return document unless document.versioned and @versionedDocuments

    @versionedDocuments.getDocumentForId id
  
  @addReferrer: (referenceField) ->
    @_referrers.push referenceField
    
  # Replaces all references to the document with sourceId to point to targetId instead.
  @substituteDocument: (sourceId, targetId) ->
    for referrer in @_referrers
      updatePath = referrer.sourcePath

      if referrer.inArray
        # In arrays, we need to place the positioning operator after the name of the array.
        pathParts = updatePath.split '.'

        ancestorArrayIndex = pathParts.indexOf referrer.ancestorArray
        pathParts[ancestorArrayIndex] += '.$'

        updatePath = pathParts.join '.'

      count = referrer.sourceDocument.documents.update
        "#{referrer.sourcePath}._id": sourceId
      ,
        $set:
          "#{updatePath}._id": targetId
      ,
        multi: true

      console.log "Substituted", referrer.sourceDocument.id(), referrer.sourcePath, sourceId, "with", updatePath, targetId, count, "times"
      
  @getPublishingDocuments: ->
    if Meteor.isServer
      # On the server, publishing happens from the database documents.
      @documents
      
    else
      # On the client, publishing happens from the content documents.
      @contentDocuments
      
  @getQueryDocuments: (publishingQuery) ->
    if Meteor.isServer or not publishingQuery
      # On the server or when doing normal (not publishing) queries, use the normal documents.
      @documents
      
    else
      # On the client, when doing a publishing query, query the content documents.
      @contentDocuments

  # Casting functionality based on implementation by @mitar.
  cast: (typeFieldName = 'type') ->
    throw new AE.InvalidOperationException "Document doesn't have the type field '#{typeFieldName}'." unless @[typeFieldName]

    # Get the constructor for the specified type.
    documentConstructor = @constructor.getClassForType @[typeFieldName]
    return null unless documentConstructor

    # We don't have to do anything if we're already created with the target constructor.
    return @ if @constructor is documentConstructor

    # Create a document clone with object data (all fields, excluding methods).
    documentData = {}
    for key, value of EJSON.clone @ when not _.isFunction value
      documentData[key] = value

    # Return the document with the correct class.
    new documentConstructor documentData

  # Refresh functionality based on implementation by @mitar.
  refresh: (fields) ->
    # Make sure the document was retrieved with its _id field.
    throw new AE.InvalidOperationException "Document is missing its _id field." unless @_id

    # Load the same document with new fields, but in raw form (only data is retrieved since transform is null).
    # We don't want PeerDB to create an object here since we'll only steal the document's field values.
    rawDocument = @constructor.documents.findOne @_id,
      fields: fields ? {}
      transform: null

    # Return rather than throw an error so that refresh can be repeated if it's performed inside a reactive context.
    # It might become later available if for example it's waiting on a subscription. We return the document to allow
    # chaining.
    return @ unless rawDocument

    # Make a list of all the fields that are present in the raw document,
    # to know which ones we want to copy from the constructed document.
    documentFields = _.keys rawDocument

    # We now construct a full object so that any sub-documents will be correct objects.
    document = new @constructor rawDocument

    for key, value of document when key in documentFields
      # Make sure the constructed object did not replace a field with a method.
      throw new AE.InvalidOperationException "Field #{key} has been overwritten with a method during refresh.", document if _.isFunction value

      # Transfer the value to ourselves.
      @[key] = value

    # Return the (refreshed) document to allow chaining.
    @

  is: (other) ->
    @_id is other._id

  getSourceData: -> @ # Override if you need to strip any runtime data from the document.
