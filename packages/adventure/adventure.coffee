AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Adventure extends AM.Component
  @register 'PixelArtAcademy.Adventure'

  constructor: (@pixelArtAcademy) ->
    super

    # Create pixel scaling display.
    @display = new Artificial.Mirage.Display @pixelArtAcademy,
      safeAreaWidth: 240
      safeAreaHeight: 180
      minScale: 2
      minAspectRatio: 2/3

    @items = [
      new PAA.PixelBoy
    ]
    
    @locations = [
      new PAA.Adventure.Locations.Dorm
    ]

    @inventory = @items.slice()

  onCreated: ->
    super

    $('html').addClass('pixel-art-academy-style-adventure')
    @pixelArtAcademy.components.add @display
    @pixelArtAcademy.components.add item for item in @inventory

  onDestroyed: ->
    super

    $('html').removeClass('pixel-art-academy-style-adventure')

    # TODO: fix removal of components
    # @pixelArtAcademy.components.remove @display
    # @pixelArtAcademy.components.remove item for item in @inventory

  @goToLocation: (locationKeyName) ->
    FlowRouter.go 'adventure', parameter1: locationKeyName

  fontSize: ->
    10 * @display.scale()

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
