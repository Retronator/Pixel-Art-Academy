AB = Artificial.Babel
AE = Artificial.Everywhere
AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.PixelBoy.Apps.LearnMode.Progress extends AM.Component
  @id: -> 'PixelArtAcademy.PixelBoy.Apps.LearnMode.Progress'
  @version: -> '0.1.0'

  template: -> @constructor.id()

  constructor: (@learnMode) ->
    super arguments...

  onCreated: ->
    super arguments...

  visibleClass: ->
    'visible' if @learnMode.state 'started'

  events: ->
    super(arguments...).concat
      'click .app-unlock-button': @onClickAppUnlockButton

  onClickAppUnlockButton: (event) ->
    app = @currentData()
    @learnMode.unlockApp app._id
