LOI = LandsOfIllusions
PAA = PixelArtAcademy
HQ = Retronator.HQ
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

  @listeners: ->
    super(arguments...).concat [
      @RetroListener
    ]

  @initialize()

  @startRetroPixelArtScript: ->
    retro = LOI.adventure.getCurrentThing HQ.Actors.Retro
    script = retro.listeners[0].scripts[HQ.Actors.Retro.id()]
    LOI.adventure.director.startScript script, label: 'PixelArt'

  constructor: ->
    super arguments...

    # Elevator button
    @elevatorButton = new HQ.Items.ElevatorButton
      location: @
      floor: 2

    @retro = LOI.adventure.getThing HQ.Store.Retro

    RS.Item.all.subscribe @
    @subscribe RA.User.registeredEmailsForCurrentUser
    @subscribe RS.Transaction.forCurrentUser

    # We need payments to determine Kickstarter tier eligibility.
    RS.Payment.forCurrentUser.subscribe @

  things: ->
    newestTableItem = @retro.newestTableItem()

    inventoryScene = _.find LOI.adventure.currentScenes(), (scene) -> scene instanceof HQ.Scenes.Inventory

    things = _.flattenDeep [
      @constructor.Table
      @retro
      newestTableItem
      newestTableItem?.interactions
      HQ.Store.Display
      HQ.Store.Shelves
      inventoryScene?.cart() unless HQ.Items.ShoppingCart.state 'inInventory'
      @elevatorButton
    ]
    
    unless LOI.characterId()
      things.push [
        HQ.Store.Shelf.Game
        HQ.Store.Shelf.Upgrades
      ]...
      
    things

  exits: ->
    HQ.Elevator.addElevatorExit
      floor: 2
    ,
      "#{Vocabulary.Keys.Directions.Up}": HQ.GalleryWest
      "#{Vocabulary.Keys.Directions.East}": @constructor.Bookshelves
      "#{Vocabulary.Keys.Directions.Down}": HQ.Cafe
      "#{Vocabulary.Keys.Directions.Southeast}": HQ.Cafe

  class @RetroListener extends LOI.Adventure.Listener
    @id: -> "Retronator.HQ.Store.Retro"

    @scriptUrls: -> [
      'retronator_retronator-hq/floor2/store/store.script'
      'retronator_retronator-hq/floor2/store/store-character.script'
    ]

    class @UserScript extends LOI.Adventure.Script
      @id: -> "Retronator.HQ.Store"
      @initialize()

      initialize: ->
        @setCurrentThings
          retro: HQ.Store.Retro

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
              tier = RS.Item.documents.findOne(catalogKey: tierKey)?.cast()

              unless tier
                console.warn "Item for tier", tierKey, "not found."
                eligibleBackerTiers.push false
                continue

              try
                tier.validateEligibility()

              catch error
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
              @ephemeralState().transactionCompleted = receipt.transactionCompleted
              @ephemeralState().purchaseErrorAfterPurchase = receipt.purchaseErrorAfterCharge()

              # Return to location.
              display.view HQ.Store.Display.Views.Center
              display.showReceiptSupporters false
              LOI.adventure.deactivateActiveItem()

              complete()

          ReadPixelArtAcademyPosts: (complete) =>
            patreon = window.open 'https://www.patreon.com/retro/posts?filters[tag]=Pixel%20Art%20Academy', '_blank'

            # Make sure opening the page worked.
            unless patreon
              complete()
              return

            patreon.focus()

            # Wait for our window to get focus.
            $(window).on 'focus.patreon', =>
              complete()
              $(window).off '.patreon'

          VisitPatreon: (complete) =>
            patreon = window.open 'https://www.patreon.com/retro', '_blank'
            patreon.focus()

            # Make sure opening the page worked.
            unless patreon
              complete()
              return

            # Wait for our window to get focus.
            $(window).on 'focus.patreon', =>
              complete()
              $(window).off '.patreon'

          ReadStudyGuide: (complete) =>
            studyGuide = window.open 'https://retropolis.city/academy-of-art/study-guide', '_blank'
            studyGuide.focus()

            # Make sure opening the page worked.
            unless studyGuide
              complete()
              return

            # Wait for our window to get focus.
            $(window).on 'focus.study-guide', =>
              complete()
              $(window).off '.study-guide'

          PixelArt: (complete) =>
            HQ.Store.startRetroPixelArtScript()
            complete()

    class @CharacterScript extends LOI.Adventure.Script
      @id: -> "Retronator.HQ.StoreCharacter"
      @initialize()

      initialize: ->
        @setCurrentThings retro: HQ.Actors.Retro

        @setCallbacks
          AnalyzeCharacter: (complete) =>
            shoppingCart = HQ.Items.ShoppingCart.state 'contents' or []

            ephemeralState = @ephemeralState()
            ephemeralState.hasShoppingCart = HQ.Items.ShoppingCart.state 'inInventory'
            ephemeralState.shoppingCart = shoppingCart

            console.log "Analyzed character and set ephemeral state to", ephemeralState if HQ.debug

            complete()

          DoCartCheck: (complete) =>
            complete()

            # See if any listener wants to handle anything before items are being bought.
            listeners = _.clone LOI.adventure.currentListeners()

            processListeners = =>
              unless listeners.length
                # We've processed all the listeners, resume the script.
                LOI.adventure.director.startScript @, label: 'AfterCartCheck'
                return

              listener = listeners.shift()

              if listener.onStoreCartCheck
                listener.onStoreCartCheck new HQ.Store.StoreCartCheckResponse => processListeners()
                
              else
                processListeners()

            # Start processing listeners.
            processListeners()

          CheckoutShoppingCart: (complete) =>
            HQ.Items.ShoppingCart.state 'atCheckout', true
            complete()

          RemoveShoppingCart: (complete) =>
            HQ.Items.ShoppingCart.state 'atCheckout', false
            HQ.Items.ShoppingCart.state 'inInventory', false
            complete()

          Checkout: (complete) =>
            # Move all things into inventory.
            cartItems = HQ.Items.ShoppingCart.state()?.contents or []

            for cartItem in cartItems
              thingId = _.thingId cartItem.item
              thingClass = LOI.Adventure.Thing.getClassForId thingId

              unless thingClass
                console.warn "Trying to buy", thingId, "which is not a Thing."
                continue

              # Place the thing in the inventory.
              thingClass.state 'inInventory', true

            # Clear the shopping cart.
            HQ.Items.ShoppingCart.clearItems()

            complete()
            
          PixelArt: (complete) =>
            HQ.Store.startRetroPixelArtScript()
            complete()

          GetRaspberry: (complete) =>
            PAA.Items.StillLifeItems.addItemOfType PAA.Items.StillLifeItems.Raspberry
            PAA.Items.StillLifeItems.addItemOfType PAA.Items.StillLifeItems.Raspberry.Leaf
            complete()

          AnotherRaspberry: (complete) =>
            PAA.Items.StillLifeItems.addItemOfType PAA.Items.StillLifeItems.Raspberry
            complete()

    @initialize()

    onScriptsLoaded: ->
      @userScript = @scripts[@constructor.UserScript.id()]
      @characterScript = @scripts[@constructor.CharacterScript.id()]

    onCommand: (commandResponse) ->
      if retro = LOI.adventure.getCurrentThing HQ.Store.Retro
        commandResponse.onPhrase
          form: [Vocabulary.Keys.Verbs.TalkTo, retro.avatar]
          action: =>
            LOI.adventure.enterContext HQ.Store.Counter
            script = if LOI.character() then @characterScript else @userScript
            LOI.adventure.director.startScript script

      if table = LOI.adventure.getCurrentThing HQ.Store.Table
        commandResponse.onPhrase
          form: [[Vocabulary.Keys.Verbs.LookAt, Vocabulary.Keys.Verbs.Use], table.avatar]
          priority: 1
          action: =>
            LOI.adventure.goToLocation table

  # Cart check response notifies the listener that items are about to be purchased.
  class @StoreCartCheckResponse
    constructor: (@callback) ->

    # Call to indicate it's time to continue with the checkout script.
    continue: ->
      @callback()
