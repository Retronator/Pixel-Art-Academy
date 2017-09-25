LOI = LandsOfIllusions
HQ = Retronator.HQ
PAA = PixelArtAcademy
RS = Retronator.Store
RA = Retronator.Accounts

Vocabulary = LOI.Parser.Vocabulary

class HQ.Store extends LOI.Adventure.Location
  @id: -> 'Retronator.HQ.Store'
  @url: -> 'retronator/store'
  @region: -> HQ

  @version: -> '0.0.1'

  @fullName: -> "Retronator Store"
  @shortName: -> "store"
  @description: ->
    "
      At the top of the stairs, the floor opens onto a store that gives you that warm, bookstore feeling.
      The place owner, Retro, is sitting behind a long desk that doubles as the store checkout area.
      Yellow walls and pixel art decals immediately brighten your day. Stairs continue up to the gallery and
      you can see bookshelves further out to the east.
    "

  @defaultScriptUrl: -> 'retronator_retronator-hq/floor2/store/store.script'

  @initialize()

  constructor: ->
    super

    # Elevator button
    @elevatorButton = new HQ.Items.ElevatorButton
      location: @
      floor: 2

    @shelves = new HQ.Store.Shelves

    @subscribe RS.Transactions.Item.all
    @subscribe RA.User.registeredEmailsForCurrentUser
    @subscribe RS.Transactions.Transaction.forCurrentUser

  destroy: ->
    super

  things: -> [
    HQ.Actors.Retro
    HQ.Store.Display
    HQ.Store.Shelf.Game
    HQ.Store.Shelf.Upgrades
    HQ.Store.Shelves
    @elevatorButton
  ]

  exits: ->
    HQ.Elevator.addElevatorExit
      floor: 2
    ,
      "#{Vocabulary.Keys.Directions.East}": @constructor.Bookshelves
      "#{Vocabulary.Keys.Directions.Up}": HQ.GalleryWest
      "#{Vocabulary.Keys.Directions.Down}": HQ.Cafe

  # Script

  initializeScript: ->
    @setCurrentThings
      retro: HQ.Actors.Retro
  
    @setCallbacks
      AnalyzeUser: (complete) =>
        shoppingCart = HQ.Items.ShoppingCart.state()?.contents or []

        buyingBaseGame = false
        buyingAlphaAccess = false

        console.log "Analyzing shopping cart", shoppingCart if HQ.debug

        PreOrderKeys = RS.Items.CatalogKeys.Bundles.PixelArtAcademy.PreOrder

        for cartItem in shoppingCart
          switch cartItem.item
            when PreOrderKeys.BasicGame, PreOrderKeys.FullGame, PreOrderKeys.AlphaAccess
              buyingBaseGame = true

          switch cartItem.item
            when PreOrderKeys.AlphaAccessUpgrade, PreOrderKeys.AlphaAccess
              buyingAlphaAccess = true

        KickstarterKeys = RS.Items.CatalogKeys.Bundles.PixelArtAcademy.Kickstarter

        eligibleBackerTiers = []

        kickstarterTierKeys = [KickstarterKeys.BasicGame, KickstarterKeys.FullGame, KickstarterKeys.AlphaAccess]

        for tierKey in kickstarterTierKeys
          tier = RS.Transactions.Item.documents.findOne(catalogKey: tierKey)?.cast()

          unless tier
            console.warn "Item for tier", tierKey, "not found."
            eligibleBackerTiers.push false
            continue

          try
            tier.validateEligibility()

          catch
            eligibleBackerTiers.push false
            continue

          # Make sure any kickstarter tier is not already in the shopping cart.
          inCart = _.find shoppingCart, (cartItem) => cartItem.item in kickstarterTierKeys

          eligibleBackerTiers.push not inCart

        noRewardBacker = true in eligibleBackerTiers

        ephemeralState = @ephemeralState()
        ephemeralState.hasShoppingCart = HQ.Items.ShoppingCart.state 'inInventory'
        ephemeralState.shoppingCart = shoppingCart
        ephemeralState.buyingBaseGame = buyingBaseGame
        ephemeralState.buyingAlphaAccess = buyingAlphaAccess
        ephemeralState.noRewardBacker = noRewardBacker
        ephemeralState.eligibleBackerTiers = eligibleBackerTiers

        console.log "Analyzed user and set ephemeral state to", ephemeralState if HQ.debug

        complete()

      AddTierToCart: (complete) =>
        ephemeralState = @ephemeralState()
        KickstarterKeys = RS.Items.CatalogKeys.Bundles.PixelArtAcademy.Kickstarter

        # We search from highest down to find the first available tier.
        for tierKey, i in [KickstarterKeys.AlphaAccess, KickstarterKeys.FullGame, KickstarterKeys.BasicGame]
          if ephemeralState.eligibleBackerTiers[2 - i]
            HQ.Items.ShoppingCart.addItem tierKey

            # We added the tier, don't add others.
            break

        complete()
        
      CheckoutShoppingCart: (complete) =>
        HQ.Items.ShoppingCart.state 'atCheckout', true
        complete()

      ReturnShoppingCart: (complete) =>
        HQ.Items.ShoppingCart.state 'atCheckout', false
        complete()

      RemoveShoppingCart: (complete) =>
        HQ.Items.ShoppingCart.state 'atCheckout', false
        HQ.Items.ShoppingCart.state 'inInventory', false
        complete()

      AddReceipt: (complete) =>
        HQ.Items.Receipt.state 'inInventory', true
        complete()
        
      RemoveReceipt: (complete) =>
        HQ.Items.Receipt.state 'inInventory', false
        complete()

      Checkout: (complete) =>
        receipt = LOI.adventure.getCurrentThing HQ.Items.Receipt
        
        # Look at display.
        display = LOI.adventure.getCurrentThing HQ.Store.Display
        display.view HQ.Store.Display.Views.Left
        display.showReceiptSupporters true
        
        LOI.adventure.goToItem display

        # Reset canceled status.
        receipt.transactionCompleted = false

        # Activate the receipt so it gets overlaid.
        receipt.activate()

        # Wait until the receipt is deactivated
        Tracker.autorun (computation) =>
          return unless receipt.deactivated()
          computation.stop()

          # Let the script know if transaction succeeded or not.
          @ephemeralState().transactionCanceled = not receipt.transactionCompleted

          # Return to location.
          display.view HQ.Store.Display.Views.Center
          display.showReceiptSupporters false
          LOI.adventure.deactivateCurrentItem()

          complete()

  # Listener

  onCommand: (commandResponse) ->
    return unless retro = LOI.adventure.getCurrentThing HQ.Actors.Retro

    commandResponse.onPhrase
      form: [Vocabulary.Keys.Verbs.TalkTo, retro.avatar]
      action: => @startScript label: 'RetroDialog'
