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

  events: ->
    super.concat
      'click .edit-button': @onClickEditButton
      'click .reset-button': @onClickResetButton

  onClickEditButton: (event) ->
    @parent.editAsset()

  onClickResetButton: (event) ->
    PAA.Practice.Challenges.Drawing.TutorialSprite.reset @sprite.id(), @sprite.spriteId()
