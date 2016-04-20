AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Adventure extends AM.Component
  @register 'PixelArtAcademy.Adventure'

  constructor: (@pixelArtAcademy) ->
    super

    # Create pixel scaling display.
    @display = new Artificial.Mirage.Display @pixelArtAcademy,
      safeAreaWidth: 320
      safeAreaHeight: 240
      minScale: 2
      minAspectRatio: 1

    @items =
      pixelBoy: new PAA.PixelBoy

    @locations =
      dorm: new PAA.Adventure.Locations.Dorm

    @inventory = _.values @items

    @currentLocation = new ReactiveField @locations.dorm.keyName()
    @activatedItem = new ReactiveField null

  onCreated: ->
    super

    $('html').addClass('pixel-art-academy-style-adventure')
    @pixelArtAcademy.components.add @display
    @pixelArtAcademy.components.add item for item in @inventory

  onRendered: ->
    # Handle url changes.
    @autorun =>
      mainParameter = FlowRouter.getParam 'parameter1'

      # We only want to react to router changes.
      Tracker.nonreactive =>
        # Find if this is an item or location.
        for key, location of @locations
          if mainParameter is location.keyName()
            # We are at a location.
            @currentLocation location

        for key, item of @items
          if mainParameter is item.keyName()
            # We are trying to use this item. Deactivate the one we might have been using before first.
            existing = @activatedItem()
            existing?.deactivate()

            @activatedItem item
            item.activate()

  onDestroyed: ->
    super

    $('html').removeClass('pixel-art-academy-style-adventure')

    # TODO: fix removal of components
    # @pixelArtAcademy.components.remove @display
    # @pixelArtAcademy.components.remove item for item in @inventory

  @goToLocation: (locationKeyName) ->
    FlowRouter.go 'adventure', parameter1: locationKeyName

  @activateItem: (itemKeyName) ->
    FlowRouter.go 'adventure', parameter1: itemKeyName

  fontSize: ->
    @display.scale()

  drawInventoryItem: ->
    item = @currentData()
    item.draw @currentComponent()

  events: ->
    super.concat
      'click .inventory .item .activate-button': @onClickInventoryItemActivateButton
      'click .inventory .item .deactivate-button': @onClickInventoryItemDectivateButton

  onClickInventoryItemActivateButton: ->
    item = @currentData()
    item.activate()

  onClickInventoryItemDectivateButton: ->
    item = @currentData()
    item.deactivate()
