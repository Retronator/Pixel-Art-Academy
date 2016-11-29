LOI = LandsOfIllusions
HQ = Retronator.HQ
PAA = PixelArtAcademy

Vocabulary = LOI.Adventure.Parser.Vocabulary

Action = LOI.Adventure.Ability.Action
Talking = LOI.Adventure.Ability.Talking

class HQ.Locations.Store.Checkout extends LOI.Adventure.Location
  @id: -> 'Retronator.HQ.Locations.Store.Checkout'
  @url: -> 'retronator/store/checkout'
  @scriptUrls: -> [
    'retronator_hq/locations/store/checkout/retro.script'
  ]

  @fullName: -> "Retronator Store checkout counter"
  @shortName: -> "checkout"
  @description: ->
    "
      You come to the counter and the cashier gives you a warm smile. On the wall there is a display similar
      to the one in the lobby. 
    "

  @initialize()

  constructor: ->
    super

  initialState: ->
    things = {}
    things[PAA.Cast.Retro.id()] = displayOrder: 0

    exits = {}
    exits[Vocabulary.Keys.Directions.South] = HQ.Locations.Store.id()

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
        ReceiveReceipt: (complete) =>
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
          complete()

        Checkout: (complete) =>
          @options.adventure.scriptHelpers.itemInteraction
            item: Retronator.HQ.Locations.Store.Checkout.Receipt
            callback: =>
              complete()

        RemoveReceipt: (complete) =>
          @options.adventure.scriptHelpers.removeItemFromInventory item: HQ.Locations.Store.Checkout.Receipt
          complete()
