AM = Artificial.Mirage
PAA = PixelArtAcademy
LOI = LandsOfIllusions
C1 = PixelArtAcademy.Season1.Episode1.Chapter1

class C1.Challenges.Drawing.PixelArtSoftware.CopyReference.BriefComponent extends AM.Component
  @register 'PixelArtAcademy.Season1.Episode1.Chapter1.Challenges.Drawing.PixelArtSoftware.CopyReference.BriefComponent'

  @restrictedPaletteName: ->
    @paletteName?()

  constructor: (@sprite) ->
    super
    
  onCreated: ->
    super
    
    @parent = @ancestorComponentWith 'editAsset'

  canEdit: ->
    PAA.PixelBoy.Apps.Drawing.state('editorId')?

  canDownloadAndUpload: ->
    PAA.PixelBoy.Apps.Drawing.state('externalSoftware')?

  customPaletteColorsString: ->
    count = 0
    count += ramp.shades.length for ramp in @sprite.customPalette().ramps

    "#{count} color#{if count > 1 then 's' else ''}"

  events: ->
    super.concat
      'click .edit-button': @onClickEditButton
      'click .assets-button': @onClickAssetsButton

  onClickEditButton: (event) ->
    @parent.editAsset()

  onClickAssetsButton: (event) ->
    @parent.showSecondPage()
