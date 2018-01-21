LOI = LandsOfIllusions
PAA = PixelArtAcademy
C1 = PixelArtAcademy.Season1.Episode1.Chapter1
HQ = Retronator.HQ

Vocabulary = LOI.Parser.Vocabulary

class C1.PixelBoy.Store extends LOI.Adventure.Scene
  @id: -> 'PixelArtAcademy.Season1.Episode1.Chapter1.PixelBoy.Store'

  @location: -> HQ.Store

  @initialize()

  @listeners: ->
    super.concat [
      @StoreListener
    ]

  # Listener

  class @StoreListener extends LOI.Adventure.Listener

    @scriptUrls: -> [
      'retronator_pixelartacademy-season1-episode1/chapter1/sections/pixelboy/scenes/store.script'
    ]

    class @Script extends LOI.Adventure.Script
      @id: -> 'PixelArtAcademy.Season1.Episode1.Chapter1.PixelBoy.Store'
      @initialize()

    @initialize()

    onScriptsLoaded: ->
      @script = @scripts[@constructor.Script.id()]

      @script.setCurrentThings retro: HQ.Actors.Retro

      @script.setCallbacks
        GivePixelBoy: (complete) =>
          PixelArtAcademy.PixelBoy.state 'inInventory', true

          # Remove PixelBoy from the cart.
          cartItems = HQ.Items.ShoppingCart.state 'contents'
          _.remove cartItems, (cartItem) -> cartItem.item is PAA.PixelBoy.id()
          HQ.Items.ShoppingCart.state 'contents', cartItems

          ephemeralState = @script.ephemeralState()
          ephemeralState.shoppingCart = cartItems

          complete()

        CartCheckContinue: (complete) =>
          complete()

          if @_storeCartCheckResponse
            @_storeCartCheckResponse.continue()
            @_storeCartCheckResponse = null

          else
            store = LOI.adventure.getCurrentThing HQ.Store
            script = store.listeners[1].characterScript
            LOI.adventure.director.startScript script, label: 'AfterCartCheck'

    onStoreCartCheck: (storeCartCheckResponse) ->
      # Check if character is buying the PixelBoy. 
      cartItems = HQ.Items.ShoppingCart.state 'contents'
      pixelBoyItem = _.find cartItems, (cartItem) -> cartItem.item is PAA.PixelBoy.id()

      unless pixelBoyItem
        storeCartCheckResponse.continue()
        return

      # Tell the character they'll get it for free.
      @_storeCartCheckResponse = storeCartCheckResponse

      # See if the character has already introduced themselves.
      label = if @script.state 'IntroductionDone' then 'GetPixelBoyFree' else 'GetPixelBoyFreeNotIntroduced'

      LOI.adventure.director.startScript @script, {label}

    onChoicePlaceholder: (choicePlaceholderResponse) ->
      return unless choicePlaceholderResponse.scriptId is HQ.Store.RetroListener.CharacterScript.id()
      return unless choicePlaceholderResponse.placeholderId is 'MainQuestion'

      # Add one of the choices depending if the player got the PixelBoy in the cart.
      cartItems = HQ.Items.ShoppingCart.state 'contents'
      pixelBoyItem = _.find cartItems, (cartItem) -> cartItem.item is PAA.PixelBoy.id()

      if pixelBoyItem
        if @script.state 'IntroductionDone'
          choiceLabel = 'HereIsThePixelBoyChoice'

      else
        choiceLabel = 'PickUpPixelBoyChoice'

      choicePlaceholderResponse.addChoice @script.startNode.labels[choiceLabel].next if choiceLabel

      # Also let our script know which of these is it (for branching further down the line).
      ephemeralState = @script.ephemeralState()
      ephemeralState.pixelBoyInCart = pixelBoyItem?
