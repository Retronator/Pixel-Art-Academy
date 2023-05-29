AB = Artificial.Babel
AE = Artificial.Everywhere
AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.PixelBoy.Apps.LearnMode.Instructions extends AM.Component
  @id: -> 'PixelArtAcademy.PixelBoy.Apps.LearnMode.Instructions'
  @version: -> '0.1.0'

  @register @id()
  template: -> @constructor.id()

  constructor: (@learnMode) ->
    super arguments...

  onCreated: ->
    super arguments...

  visibleClass: ->
    'visible' if @learnMode.instructionsVisible()

  events: ->
    super(arguments...).concat
      'click .start-button': @onClickStartButton

  onClickStartButton: (event) ->
    PAA.PixelBoy.Apps.LearnMode.state 'started', true
