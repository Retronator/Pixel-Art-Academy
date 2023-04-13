AC = Artificial.Control
AM = Artificial.Mirage
PAA = PixelArtAcademy
LOI = LandsOfIllusions

class PAA.Practice.Challenges.Drawing.TutorialBitmap.BriefComponent extends AM.Component
  @register 'PixelArtAcademy.Practice.Challenges.Drawing.TutorialBitmap.BriefComponent'

  constructor: (@tutorialBitmap) ->
    super arguments...
    
  onCreated: ->
    super arguments...
    
    @parent = @ancestorComponentWith 'editAsset'
    
  onRendered: ->
    super arguments...
  
    # Allow cheating with the F1 key.
    $(document).on 'keydown.pixelartacademy-practice-challenges-drawing-tutorialbitmap-briefcomponent', (event) => @onKeyDown event

  onDestroyed: ->
    super arguments...
  
    $(document).off '.pixelartacademy-practice-challenges-drawing-tutorialbitmap-briefcomponent'

  events: ->
    super(arguments...).concat
      'click .start-button': @onClickStartButton
      'click .reset-button': @onClickResetButton

  onClickStartButton: (event) ->
    @parent.editAsset()

  onClickResetButton: (event) ->
    PAA.Practice.Challenges.Drawing.TutorialBitmap.reset @tutorialBitmap.id(), @tutorialBitmap.bitmapId()
    
  onKeyDown: (event) ->
    @tutorialBitmap.solve() if event.which is AC.Keys.f1
