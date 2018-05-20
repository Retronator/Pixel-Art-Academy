AE = Artificial.Everywhere
AM = Artificial.Mirage
AB = Artificial.Base
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PixelArtAcademy.PixelBoy.Apps.Drawing.Clipboard extends AM.Component
  @register 'PixelArtAcademy.PixelBoy.Apps.Drawing.Clipboard'
  
  constructor: (@drawing) ->
    super

  activeAssetClass: ->
    'active-asset' if @asset() and not @editorActive()

  editorActiveClass: ->
    'editor-active' if @editorActive()

  editorActive: ->
    AB.Router.getParameter('parameter4') is 'edit'

  asset: ->
    @drawing.portfolio().activeAsset()?.asset

  events: ->
    super.concat
      'click .edit-button': @onClickEditButton

  onClickEditButton: (event) ->
    AB.Router.setParameter 'parameter4', 'edit'
