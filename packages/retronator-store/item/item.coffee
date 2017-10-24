AE = Artificial.Everywhere
AB = Artificial.Babel
AM = Artificial.Mummification
RS = Retronator.Store

class RS.Item extends AM.Document
  @id: -> 'Retronator.Store.Item'
  # type: constructor type for inheritance
  # catalogKey: unique string for this item
  # name: translation document with the name
  #   _id
  # description: translation document with the description
  #   _id
  # price: the minimum price in USD to purchase this item or null if it can't be bought separately (outside of a bundle)
  # items: array of items if this is a bundle
  #   _id
  #   catalogKey
  # isGiftable: can this item be purchased for someone else
  # {extraData}: any extra data set for the item
  @type: @id()
  @register @type, @

  @Meta
    name: @id()
    fields: =>
      name: @ReferenceField AB.Translation, [], false
      description: @ReferenceField AB.Translation, [], false
      items: [@ReferenceField 'self', ['catalogKey']]
      
  @all: 'Retronator.Store.Item.all'

  # Inserts an item into the database.
  @create: (documentData) ->
    # Transform name and descriptions into translation documents.
    documentData.name =
      _id: @_createTranslation documentData.catalogKey, 'name', documentData.name

    documentData.description =
      _id: @_createTranslation documentData.catalogKey, 'description', documentData.description

    # Transform items from catalog keys to objects with ids.
    if documentData.items
      items = []

      for itemCatalogKey in documentData.items
        item = RS.Item.documents.findOne catalogKey: itemCatalogKey
        throw new AE.ArgumentException "The item with catalog key #{itemCatalogKey} does not exist." unless item

        items.push
          _id: item._id

      documentData.items = items
      
    # If no type is set, we're not using inheritance so default to current constructor.
    documentData.type = @type
    
    # Upsert the document with its catalog key.
    RS.Item.documents.upsert catalogKey: documentData.catalogKey, documentData

  # Inserts an item for an inherited item with metadata set on the class.
  @createSelf: ->
    @create @
    
  @_createTranslation: (catalogKey, key, defaultText) ->
    namespace = "Retronator.Store.Items.#{catalogKey}"
    AB.createTranslation namespace, key, defaultText

  validateEligibility: ->
    # Override this with custom logic that tests whether the current user is eligible to buy this.

  _throwEligibilityException: (details) ->
    throw new AE.ArgumentException "You are not eligible to purchase #{@debugName()}.", details

  debugName: ->
    @name.refresh()?.translate().text or @catalogKey

  refresh: ->
    super

    # Also refresh bundled items.
    item.refresh() for item in @items if @items
