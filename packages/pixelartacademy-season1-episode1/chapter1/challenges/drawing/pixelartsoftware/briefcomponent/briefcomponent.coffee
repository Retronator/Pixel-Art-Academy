AM = Artificial.Mirage
PAA = PixelArtAcademy
LOI = LandsOfIllusions
C1 = PixelArtAcademy.Season1.Episode1.Chapter1

class C1.Challenges.Drawing.PixelArtSoftware.CopyReference.BriefComponent extends AM.Component
  @register 'PixelArtAcademy.Season1.Episode1.Chapter1.Challenges.Drawing.PixelArtSoftware.CopyReference.BriefComponent'

  constructor: (@sprite) ->
    super
    
  onCreated: ->
    super
    
    @parent = @ancestorComponentWith 'editAsset'

  events: ->
    super.concat
      'click .edit-button': @onClickEditButton
      'click .reset-button': @onClickResetButton

  onClickEditButton: (event) ->
    @parent.editAsset()

  onClickResetButton: (event) ->
    PAA.Practice.Challenges.Drawing.TutorialSprite.reset @sprite.id(), @sprite.spriteId()
