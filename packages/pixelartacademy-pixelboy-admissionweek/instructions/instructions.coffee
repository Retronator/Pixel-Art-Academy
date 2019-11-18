AB = Artificial.Babel
AE = Artificial.Everywhere
AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.PixelBoy.Apps.AdmissionWeek.Instructions extends AM.Component
  @id: -> 'PixelArtAcademy.PixelBoy.Apps.AdmissionWeek.Instructions'
  @version: -> '0.1.0'

  @register @id()
  template: -> @constructor.id()

  constructor: (@admissionWeek) ->
    super arguments...

  onCreated: ->
    super arguments...

    # Start on the instructions screen if admission week hasn't been started.
    @visible = new ReactiveField not PAA.PixelBoy.Apps.AdmissionWeek.state 'startDay'

  visibleClass: ->
    'visible' if @visible()

  events: ->
    super(arguments...).concat
      'click .start-button': @onClickStartButton

  onClickStartButton: (event) ->
    # Mark current game day as start day of admission week.
    PAA.PixelBoy.Apps.AdmissionWeek.state 'startDay', LOI.adventure.gameTime().getDay()

    # Close instructions.
    @visible false
