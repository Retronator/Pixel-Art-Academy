AB = Artificial.Babel
AE = Artificial.Everywhere
AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.PixelPad.Apps.AdmissionWeek.Instructions extends AM.Component
  @id: -> 'PixelArtAcademy.PixelPad.Apps.AdmissionWeek.Instructions'
  @version: -> '0.1.0'

  @register @id()
  template: -> @constructor.id()

  constructor: (@admissionWeek) ->
    super arguments...

  onCreated: ->
    super arguments...

  visibleClass: ->
    'visible' if @admissionWeek.instructionsVisible()

  events: ->
    super(arguments...).concat
      'click .start-button': @onClickStartButton

  onClickStartButton: (event) ->
    # Mark current game day as start day of admission week.
    PAA.PixelPad.Apps.AdmissionWeek.state 'startDay', LOI.adventure.gameTime().getDay()