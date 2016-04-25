AE = Artificial.Everywhere
AM = Artificial.Mirage
LOI = LandsOfIllusions

class PixelArtAcademy.PixelBoy.Apps.Drawing.Sprites extends AM.Component
  @register 'PixelArtAcademy.PixelBoy.Apps.Drawing.Sprites'

  constructor: (@drawing) ->
    super

    @spriteId = new ReactiveField null

  onCreated: ->
    super

    @autorun =>
      # Always close sprite selection menu when a new sprite is selected.
      @drawing.isInSpriteSelection @spriteId() is null

    @subscribe 'allSprites', =>
      # Always show the first sprite image if none is displayed.
      @autorun (computation) =>
        currentSpriteId = @spriteId()

        # Make sure the current sprite image exists.
        return if currentSpriteId and LOI.Assets.Sprite.documents.findOne currentSpriteId

        # Switch to the first sprite image on the display list.
        sprite = @sprites().fetch()[0]
        @spriteId sprite?._id or null

  sprites: ->
    LOI.Assets.Sprite.documents.find {},
      sort:
        name: 1
        _id: 1

  nameOrId: ->
    data = @currentData()
    data.name or "#{data._id.substring 0, 5}…"

  showDisplayButton: ->
    not @drawing.isInSpriteSelection() or @drawing.spriteId()

  activeClass: ->
    'active' if @currentData()._id is @spriteId()

  events: ->
    super.concat
      'click .add-sprite': @onClickAddSprite
      'click .sprite': @onClickSprite
      'click .display-button': @onClickDisplayButton

  onClickAddSprite: ->
    newId = Random.id()

    # Create a 16x16 sprite.
    Meteor.call 'spriteInsert', newId, 
      palette:
        name: LOI.Assets.Palette.systemPaletteNames.pico8
      bounds:
        left: 0
        right: 15
        top: 0
        bottom: 15

    # Switch editor to the new sprite image.
    @spriteId newId

  onClickSprite: ->
    @spriteId @currentData()._id
    @drawing.isInSpriteSelection false

  onClickDisplayButton: ->
    @drawing.isInSpriteSelection not @drawing.isInSpriteSelection()
