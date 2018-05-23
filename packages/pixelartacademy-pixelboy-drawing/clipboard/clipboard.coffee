AE = Artificial.Everywhere
AM = Artificial.Mirage
AB = Artificial.Base
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PixelArtAcademy.PixelBoy.Apps.Drawing.Clipboard extends AM.Component
  @register 'PixelArtAcademy.PixelBoy.Apps.Drawing.Clipboard'
  
  constructor: (@drawing) ->
    super

  editorActive: ->
    @drawing.editor().active()

  asset: ->
    @drawing.portfolio().displayedAsset()?.asset

  events: ->
    super.concat
      'click .edit-button': @onClickEditButton

  onClickEditButton: (event) ->
    AB.Router.setParameter 'parameter4', 'edit'
