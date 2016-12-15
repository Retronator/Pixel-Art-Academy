LOI = LandsOfIllusions
HQ = Retronator.HQ
PAA = PixelArtAcademy
RS = Retronator.Store

Vocabulary = LOI.Adventure.Parser.Vocabulary

Action = LOI.Adventure.Ability.Action
Talking = LOI.Adventure.Ability.Talking

class HQ.Locations.Checkout extends LOI.Adventure.Location
  @id: -> 'Retronator.HQ.Locations.Store.Checkout'
  @url: -> 'retronator/checkout'
  @scriptUrls: -> [
    'retronator_hq/hq.script'
    'retronator_hq/locations/2ndfloor/checkout/retro.script'
    'retronator_hq/actors/elevatorbutton.script'
  ]

  @fullName: -> "Retronator Store checkout counter"
  @shortName: -> "checkout"
  @description: ->
    "
      At the top of the stairs, the floor opens onto a cafe-style co-working space/store hybrid that gives you that warm, 
      bookstore feeling. Ah, you feel at home already. The place owner, Retro,
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

  @initialState: ->
    things = {}
    things[PAA.Cast.Retro.id()] = displayOrder: 0
    things[HQ.Locations.Checkout.Display.id()] = displayOrder: 1
    things[HQ.Actors.ElevatorButton.id()] = displayOrder: 2

    exits = {}
    exits[Vocabulary.Keys.Directions.North] = HQ.Locations.Steps.id()
    exits[Vocabulary.Keys.Directions.Down] = HQ.Locations.Steps.id()
    exits[Vocabulary.Keys.Directions.East] = HQ.Locations.Store.id()

    _.merge {}, super,
      things: things
      exits: exits

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
            shoppingCart = shoppingCartApp?.state().contents

          buyingBaseGame = false
          buyingAlphaAccess = false

          console.log "Analyzing shopping cart", shoppingCart

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
          shoppingCartApp = tablet.apps HQ.Items.Tablet.Apps.ShoppingCart
          shoppingCartApp.state().receiptVisible = true
          @options.adventure.gameState.updated()
          
          # Look at display.
          LOI.Adventure.goToItem HQ.Locations.Checkout.Display

          # Activate the tablet so it gets overlaid.
          tablet.activate()

          # Wait until the tablet is deactivated
          Tracker.autorun (computation) =>
            if tablet.deactivated()
              computation.stop()

              # Return to location
              @options.adventure.deactivateCurrentItem()

              complete()

    # Elevator button
    HQ.Actors.ElevatorButton.setupButton
      location: @
      floor: 2
