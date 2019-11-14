AE = Artificial.Everywhere
AM = Artificial.Mirage
LOI = LandsOfIllusions
HQ = Retronator.HQ
RA = Retronator.Accounts
RS = Retronator.Store

Vocabulary = LOI.Parser.Vocabulary

class HQ.Store.Shelf extends LOI.Adventure.Item
  template: -> 'Retronator.HQ.Store.Shelf'

  # This is a listener-only object.
  isVisible: -> false

  constructor: ->
    super arguments...

  onCreated: ->
    super arguments...

    # Get all store items data.
    @_itemsSubscription = RS.Item.all.subscribe @

    # Get all user's transactions and payments so we can determine which store items they are
    # eligible for. Payments are needed to determine if the user has a kickstarter pledge.
    @subscribe RS.Transaction.forCurrentUser
    RS.Payment.forCurrentUser.subscribe @

    @_thingAvatars = []
    @_thingItems = new ComputedField =>
      # Destroy previous avatars.
      avatar.destroy() for avatar in @_thingAvatars
      @_thingAvatars = []
      
      thingItems = []

      for thing in @things()
        thingId = _.thingId thing
        thingClass = LOI.Adventure.Thing.getClassForId thingId
        continue unless thingClass

        # Create the item's avatar to provide name and description translations.
        avatar = thingClass.createAvatar()
        @_thingAvatars.push avatar

        translationKeys = LOI.Adventure.Thing.Avatar.translationKeys

        thingItems.push
          name: avatar.getTranslation(translationKeys.storeName) or avatar.getTranslation(translationKeys.fullName)
          description: avatar.getTranslation translationKeys.storeDescription
          catalogKey: thingId
          storeSeller: thingClass.storeSeller?()
          storeUrl: thingClass.storeUrl?()

      thingItems

  onDeactivate: (finishedDeactivatingCallback) ->
    Meteor.setTimeout =>
      finishedDeactivatingCallback()
    ,
      500

  shoppingCart: ->
    RS.shoppingCart

  # Override with specific shelf items.    
  catalogKeys: -> []
  things: -> []

  storeItems: ->
    _.flattenDeep [
      @_thingItems()
      @_databaseItems()
    ]

  _databaseItems: ->
    return [] unless @_itemsSubscription.ready()

    items = RS.Item.documents.find
      price:
        $exists: true
    ,
      sort:
        price: 1

    # Show only items that are supposed to be on this shelf.
    items = _.filter items.fetch(), (item) =>
      item.catalogKey in @catalogKeys()

    # Cast the items to enable any extra functionality.
    items = (item.cast() for item in items)

    # Refresh all the items to populate bundle sub-items.
    item.refresh() for item in items

    console.log "Shelf displaying items", items if HQ.debug

    items

  canBuyFromShelf: -> true # Override to apply shelf-wide buying limit.

  canBuy: ->
    item = @currentData()

    return unless @canBuyFromShelf()

    # You can always buy things without eligibility function.
    return true unless item.validateEligibility

    # We need to perform validation with inherited child's code, so first do a cast.
    item = item.cast()

    try
      item.validateEligibility()

    catch error
      return false

    true

  canBuyClass: ->
    'can-buy' if @canBuy()

  events: ->
    super(arguments...).concat
      'click .add-to-cart-button': @onClickAddToCartButton

  onClickAddToCartButton: (event) ->
    item = @currentData()

    # See if any listener prevents the adding.
    results = for listener in LOI.adventure.currentListeners()
      addToCartResponse = new @constructor.AddToCartResponse catalogKey: item.catalogKey

      listener.onAddToCartAttempt? addToCartResponse

      {addToCartResponse, listener}

    # See if adding was prevented.
    for result in results when result.addToCartResponse.wasAddingPrevented()
      # Return from looking at the shelf.
      LOI.adventure.goToItem null
      return

    # Add the shopping cart to player inventory tablet.
    HQ.Items.ShoppingCart.state 'inInventory', true

    # Add the item's ID to the shopping cart state.
    HQ.Items.ShoppingCart.addItem item.catalogKey

    # Switch display to shopping cart.
    LOI.adventure.goToItem HQ.Items.ShoppingCart

  # Listener

  onCommand: (commandResponse) ->
    shelf = @options.parent

    commandResponse.onPhrase
      form: [
        [
          Vocabulary.Keys.Verbs.LookAt
          Vocabulary.Keys.Verbs.Use
          Vocabulary.Keys.Verbs.Buy
          Vocabulary.Keys.Verbs.Get
        ]
        shelf.avatar
      ]
      priority: 1
      action: =>
        LOI.adventure.goToItem shelf

  # Add to cart response captures the listener's response for the attempt to add an item from the shelf.
  class @AddToCartResponse
    constructor: (@options) ->
      @catalogKey = @options.catalogKey

      @_addingPrevented = false

    # Call to indicate that adding to cart should not succeed.
    preventAdding: ->
      @_addingPrevented = true

    wasAddingPrevented: ->
      @_addingPrevented
