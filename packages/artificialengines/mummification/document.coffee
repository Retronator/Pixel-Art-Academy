AE = Artificial.Everywhere
AM = Artificial.Mummification

# Extended PeerDB document with common operations.
class AM.Document extends Document
  @Meta
    abstract: true

  @_documentClasses: {}

  # Casting functionality based on implementation by @mitar.
  cast: (typeFieldName = 'type') ->
    throw new AE.InvalidOperationException "Document doesn't have the type field '#{typeFieldName}'." unless @[typeFieldName]

    # Get the constructor for the specified type.
    documentConstructor = @constructor.getClass @[typeFieldName]
    return null unless documentConstructor

    # We don't have to do anything if we're already created with the target constructor.
    return @ if @constructor is documentConstructor

    # Create a document clone with object data (all fields, excluding methods).
    documentData = {}
    for key, value of EJSON.clone @ when not _.isFunction value
      documentData[key] = value

    # Return the document with the correct class.
    new documentConstructor documentData

  @register: (typeName, documentClass) ->
    throw new AE.ArgumentNullException "You must specify a document class." unless documentClass

    # Make sure the document class inherits from Document.
    throw new AE.ArgumentException "Provided document class is not a Document." unless documentClass.prototype instanceof Document

    # Save the document class to our map.
    @_documentClasses[typeName] = documentClass

  @getClass: (typeName) ->
    # Retrieve the document class from the map.
    @_documentClasses[typeName]

  # Refresh functionality based on implementation by @mitar.
  refresh: (fields) ->
    # Make sure the document was retrieved with its _id field.
    throw new AE.InvalidOperationException "Document is missing its _id field." unless @_id

    # Load the same document with new fields, but in raw form (only data is retrieved since transform is null).
    # We don't want PeerDB to create an object here since we'll only steal the document's field values.
    rawDocument = @constructor.documents.findOne @_id,
      fields: fields ? {}
      transform: null

    # Return rather than throw an error so that refresh can be repeated if it's performed inside a
    # reactive context. It might become later available if for example it's waiting on a subscription.
    return unless rawDocument

    # Make a list of all the fields that are present in the raw document,
    # to know which ones we want to copy from the constructed document.
    documentFields = _.keys rawDocument

    # We now construct a full object so that any sub-documents will be correct objects.
    document = new @constructor rawDocument

    for key, value of document when key in documentFields
      # Make sure the constructed object did not replace a field with a method.
      assert not _.isFunction value

      # Transfer the value to ourselves.
      @[key] = value

    # Return the (refreshed) document to allow chaining.
    @

  is: (other) ->
    @_id is other._id
