LOI = LandsOfIllusions
HQ = Retronator.HQ
PAA = PixelArtAcademy
RS = Retronator.Store

Vocabulary = LOI.Parser.Vocabulary

Action = LOI.Adventure.Ability.Action
Talking = LOI.Adventure.Ability.Talking

class HQ.Locations.Checkout extends LOI.Adventure.Location
  @id: -> 'Retronator.HQ.Locations.Store.Checkout'
  @url: -> 'retronator/checkout'
  @scriptUrls: -> [
    'retronator-hq/hq.script'
    'retronator-hq/locations/2ndfloor/checkout/retro.script'
    'retronator-hq/actors/elevatorbutton.script'
  ]

  @version: -> '0.0.1'

  @fullName: -> "Retronator Store checkout counter"
  @shortName: -> "checkout"
  @description: ->
    "
      At the top of the stairs, the floor opens onto a cafe-style co-working space/store hybrid that gives you that warm, 
      bookstore feeling. The place owner, Retro,
      is sitting behind a long desk that doubles as the store checkout area. Yellow walls and pixel art decals
      immediately brighten your day. You can see store shelves further out to the east.
    "

  @initialize()

  constructor: ->
    super

    HQ.Locations.Elevator.setupElevatorExit
      location: @
      floor: 2

    @_itemsSubscription = @subscribe RS.Transactions.Item.all

  destroy: ->
    super

    @_itemsSubscription.stop()

  things: ->
    [
      PAA.Cast.Retro.id()
      HQ.Locations.Checkout.Display.id()
      HQ.Actors.ElevatorButton.id()
    ]

  exits: ->
    exits = @elevatorExits()
    exits[Vocabulary.Keys.Directions.North] = HQ.Locations.Steps.id()
    exits[Vocabulary.Keys.Directions.Down] = HQ.Locations.Steps.id()
    exits[Vocabulary.Keys.Directions.East] = HQ.Locations.Store.id()
    exits

  onScriptsLoaded: ->
    # Retro
    Tracker.autorun (computation) =>
      return unless retro = @things PAA.Cast.Retro.id()
      computation.stop()

      retro.addAbility new Action
        verb: Vocabulary.Keys.Verbs.Talk
        action: =>
          @director().startScript retroDialog

      retroDialog = @scripts['Retronator.HQ.Locations.Store.Checkout.Scripts.Retro']
  
      retroDialog.setActors
        retro: retro
        
      retroDialog.setCallbacks
        AnalyzeUser: (complete) =>
          shoppingCart = []
          tablet = @options.adventure.inventory HQ.Items.Tablet
          
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
          tablet = @options.adventure.inventory HQ.Items.Tablet
          tablet.state().os.activeAppId = HQ.Items.Tablet.Apps.ShoppingCart.id()

          shoppingCartApp = tablet.apps HQ.Items.Tablet.Apps.ShoppingCart
          shoppingCartApp.state().receiptVisible = true

          @options.adventure.gameState.updated()
          
          # Look at display.
          @options.adventure.goToItem HQ.Locations.Checkout.Display

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
                @options.adventure.gameState.updated()

              # Return to location
              @options.adventure.deactivateCurrentItem()

              complete()

    # Elevator button
    HQ.Actors.ElevatorButton.setupButton
      location: @
      floor: 2
