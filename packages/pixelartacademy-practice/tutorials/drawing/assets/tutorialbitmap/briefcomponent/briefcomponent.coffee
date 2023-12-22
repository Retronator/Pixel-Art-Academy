AC = Artificial.Control
AM = Artificial.Mirage
PAA = PixelArtAcademy
LOI = LandsOfIllusions

class PAA.Practice.Tutorials.Drawing.Assets.TutorialBitmap.BriefComponent extends AM.Component
  @register 'PixelArtAcademy.Practice.Tutorials.Drawing.Assets.TutorialBitmap.BriefComponent'

  constructor: (@tutorialBitmap) ->
    super arguments...
    
  onCreated: ->
    super arguments...
    
    @parent = @ancestorComponentWith 'editAsset'

  started: ->
    @tutorialBitmap.bitmap().historyPosition
    
  events: ->
    super(arguments...).concat
      'click .start-button': @onClickStartButton
      'click .reset-button': @onClickResetButton

  onClickStartButton: (event) ->
    @parent.editAsset()

  onClickResetButton: (event) ->
    @tutorialBitmap.constructor.reset @tutorialBitmap.tutorial, @tutorialBitmap.id(), @tutorialBitmap.bitmapId()
