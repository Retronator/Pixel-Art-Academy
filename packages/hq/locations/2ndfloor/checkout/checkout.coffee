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

  @initialState: ->
    things = {}
    things[PAA.Cast.Retro.id()] = displayOrder: 0
    things[HQ.Actors.ElevatorButton.id()] = displayOrder: 1

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
        AnalyzeShoppingCart: (complete) =>
          shoppingCart = []
          tablet = @options.adventure.inventory[HQ.Items.Tablet.id()]
          
          if tablet
            shoppingCartApp = tablet.apps[HQ.Items.Tablet.Apps.ShoppingCart.id()]
            shoppingCart = shoppingCartApp?.state().contents

          buyingBaseGame = false
          buyingAlphaAccess = false

          console.log "Analyzing shopping cart", shoppingCart

          for item in shoppingCart
            switch item.catalogKey
              when RS.Items.CatalogKeys.Bundles.PixelArtAcademy.PreOrder.BasicGame, RS.Items.CatalogKeys.Bundles.PixelArtAcademy.PreOrder.FullGame, RS.Items.CatalogKeys.Bundles.PixelArtAcademy.PreOrder.AlphaAccess
                buyingBaseGame = true

            switch item.catalogKey
              when RS.Items.CatalogKeys.Bundles.PixelArtAcademy.PreOrder.AlphaAccessUpgrade, RS.Items.CatalogKeys.Bundles.PixelArtAcademy.PreOrder.AlphaAccess
                buyingAlphaAccess = true

          ephemeralState = retroDialog.ephemeralState()
          ephemeralState.shoppingCart = shoppingCart
          ephemeralState.buyingBaseGame = buyingBaseGame
          ephemeralState.buyingAlphaAccess = buyingAlphaAccess
          complete()

        Checkout: (complete) =>
          # Create receipt from shopping cart contents.
          gameState = @options.adventure.gameState()
          shoppingCart = gameState.locations[HQ.Locations.Store.id()].things[HQ.Locations.Store.ShoppingCart.id()]

          @options.adventure.scriptHelpers.addItemToInventory
            item: HQ.Locations.Store.Checkout.Receipt
            state:
              contents: shoppingCart.contents
              tip:
                amount: 0
                message: null

          @options.adventure.gameState.updated()

          @options.adventure.scriptHelpers.itemInteraction
            item: Retronator.HQ.Locations.Store.Checkout.Receipt
            callback: =>
              complete()

    # Elevator button
    HQ.Actors.ElevatorButton.setupButton
      location: @
      floor: 2
