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
    
  onRendered: ->
    super arguments...
  
    # Allow cheating with the F2 key.
    $(document).on 'keydown.pixelartacademy-practice-tutorials-drawing-tutorialbitmap-briefcomponent', (event) => @onKeyDown event

  onDestroyed: ->
    super arguments...
  
    $(document).off '.pixelartacademy-practice-tutorials-drawing-tutorialbitmap-briefcomponent'

  started: ->
    @tutorialBitmap.bitmap().historyPosition
    
  events: ->
    super(arguments...).concat
      'click .start-button': @onClickStartButton
      'click .reset-button': @onClickResetButton

  onClickStartButton: (event) ->
    @parent.editAsset()

  onClickResetButton: (event) ->
    PAA.Practice.Tutorials.Drawing.Assets.TutorialBitmap.reset @tutorialBitmap.tutorial, @tutorialBitmap.id(), @tutorialBitmap.bitmapId()
    
  onKeyDown: (event) ->
    if event.which is AC.Keys.f2
      @tutorialBitmap.solve()
      event.preventDefault()
