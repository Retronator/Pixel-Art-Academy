AE = Artificial.Everywhere
AM = Artificial.Mirage
LOI = LandsOfIllusions
HQ = Retronator.HQ
RA = Retronator.Accounts
RS = Retronator.Store

Vocabulary = LOI.Parser.Vocabulary

class HQ.ArtStudio.Pencils extends HQ.ArtStudio.ContextWithArtworks
  @id: -> 'Retronator.HQ.ArtStudio.Pencils'

  @register @id()
  template: -> @constructor.id()

  @version: -> '0.0.1'

  @initialize()

  @HighlightGroups:
    Inventory: ['inventory']

  constructor: ->
    super
    
    # Pencils context only appears in dialogue mode.
    @dialogueMode true
    
    @sceneSize =
      width: 480
      height: 240

    @_focusPoint = x: 0.5, y: 0.6

  onCreated: ->
    super

    @handVisible = new ReactiveField false

  showHand: ->
    @handVisible true

  sceneStyle: ->
    hiddenHeight = @sceneSize.height - @illustrationHeight()

    top: "-#{hiddenHeight * 0.6}rem"

  _updateSceneStyle: -> # Override to do nothing since we position via the style helper.

  handVisibleClass: ->
    'visible' if @handVisible()
