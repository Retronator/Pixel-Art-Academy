LOI = LandsOfIllusions
HQ = Retronator.HQ
PAA = PixelArtAcademy

Vocabulary = LOI.Parser.Vocabulary

class HQ.Store extends LOI.Adventure.Location
  @id: -> 'Retronator.HQ.Store'
  @url: -> 'retronator/store'
  @scriptUrls: -> [
    'retronator-hq/hq.script'
  ]

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
  
  @initialize()

  constructor: ->
    super

    # Elevator button
    @elevatorButton = new HQ.Items.ElevatorButton
      location: @
      floor: 2

  things: -> [
    PAA.Cast.Retro
    HQ.Store.Display
    HQ.Store.Shelf.Game
    HQ.Store.Shelf.Upgrades
    @elevatorButton
  ]

  exits: ->
    HQ.Elevator.addElevatorExit
      floor: 2
    ,
      "#{Vocabulary.Keys.Directions.East}": @constructor.Bookshelves
      "#{Vocabulary.Keys.Directions.Up}": HQ.GalleryWest
      "#{Vocabulary.Keys.Directions.Down}": HQ.Cafe

  initializeScript: ->
    @setCurrentThings
      retro: PAA.Cast.Retro
  
    @setCallbacks
      AnalyzeUser: (complete) =>
        shoppingCart = []
        tablet = LOI.adventure.inventory HQ.Items.Tablet
        
        if tablet
          shoppingCartApp = tablet.apps HQ.Items.Tablet.Apps.ShoppingCart
          shoppingCart = shoppingCartApp.state().contents if shoppingCartApp

        buyingBaseGame = false
        buyingAlphaAccess = false

        console.log "Analyzing shopping cart", shoppingCart if HQ.debug

        PreOrderKeys = RS.Items.CatalogKeys.Bundles.PixelArtAcademy.PreOrder

        if shoppingCart
          for cartItem in shoppingCart
            switch cartItem.item
              when PreOrderKeys.BasicGame, PreOrderKeys.FullGame, PreOrderKeys.AlphaAccess
                buyingBaseGame = true

            switch cartItem.item
              when PreOrderKeys.AlphaAccessUpgrade, PreOrderKeys.AlphaAccess
                buyingAlphaAccess = true

        KickstarterKeys = RS.Items.CatalogKeys.Bundles.PixelArtAcademy.Kickstarter

        eligibleBackerTiers = []

        for tierKey in [KickstarterKeys.BasicGame, KickstarterKeys.FullGame, KickstarterKeys.AlphaAccess]
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

          eligibleBackerTiers.push true

        noRewardBacker = true in eligibleBackerTiers

        ephemeralState = retroDialog.ephemeralState()
        ephemeralState.tablet = if tablet then true else false
        ephemeralState.hasShoppingCartApp = shoppingCartApp?
        ephemeralState.shoppingCart = shoppingCart
        ephemeralState.buyingBaseGame = buyingBaseGame
        ephemeralState.buyingAlphaAccess = buyingAlphaAccess
        ephemeralState.noRewardBacker = noRewardBacker
        ephemeralState.eligibleBackerTiers = eligibleBackerTiers

        console.log "Analyzed user and set ephemeral state to", ephemeralState if HQ.debug

        complete()

      Checkout: (complete) =>
        # Show the receipt on the tablet.
        tablet = LOI.adventure.inventory HQ.Items.Tablet
        tablet.state().os.activeAppId = HQ.Items.Tablet.Apps.ShoppingCart.id()

        shoppingCartApp = tablet.apps HQ.Items.Tablet.Apps.ShoppingCart
        shoppingCartApp.state().receiptVisible = true

        LOI.adventure.gameState.updated()
        
        # Look at display.
        LOI.adventure.goToItem HQ.Checkout.Display

        # Activate the tablet so it gets overlaid.
        tablet.activate()

        retroDialog.ephemeralState().transactionCanceled = false

        # Wait until the tablet is deactivated
        Tracker.autorun (computation) =>
          if tablet.deactivated()
            computation.stop()

            # If receipt is still visible, transaction was canceled.
            if shoppingCartApp.state().receiptVisible
              retroDialog.ephemeralState().transactionCanceled = true

              # Hide the receipt after this.
              shoppingCartApp.state().receiptVisible = false
              LOI.adventure.gameState.updated()

            # Return to location
            LOI.adventure.deactivateCurrentItem()

            complete()

  onCommand: (commandResponse) ->
    return unless retro = LOI.adventure.getCurrentThing PAA.Cast.Retro

    commandResponse.onPhrase
      form: [Vocabulary.Keys.Verbs.TalkTo, retro.avatar]
      action: => @startScript label: 'RetroDialog'
