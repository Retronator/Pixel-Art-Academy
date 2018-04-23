AM = Artificial.Mirage
LOI = LandsOfIllusions

class PixelArtAcademy.PixelBoy.Apps.Drawing.Sprite extends AM.Component
  @register 'PixelArtAcademy.PixelBoy.Apps.Drawing.Sprite'

  constructor: (@drawing) ->
    super

    @spriteData = new ComputedField =>
      spriteId = @drawing.spriteId()
      LOI.Assets.Sprite.documents.findOne spriteId,
        fields:
          name: 1

    @currentIndex = new ReactiveField null

    @colorMap = new ReactiveField null

  onCreated: ->
    super

    @colorMap new PixelArtAcademy.PixelBoy.Apps.Drawing.Components.ColorMap
      assetId: @drawing.spriteId
      assetClassName: 'Sprite'
      palette: @drawing.palette

  # Helpers

  renderColorMap: ->
    @colorMap()?.renderComponent(@currentComponent()) or null

  # Events

  events: ->
    super.concat
      'change .name-input': @onChangeName
      'click .clear': @onClickClear
      'click .delete': @onClickDelete

  onChangeName: (event) ->
    Meteor.call 'spriteUpdate', @spriteData()._id,
      $set:
        name: $(event.target).val()

  onClickClear: (event) ->
    Meteor.call 'spriteClear', @spriteData()._id

  onClickDelete: (event) ->
    Meteor.call 'spriteRemove', @spriteData()._id
