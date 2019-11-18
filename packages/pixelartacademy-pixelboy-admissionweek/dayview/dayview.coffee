AB = Artificial.Babel
AE = Artificial.Everywhere
AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.PixelBoy.Apps.AdmissionWeek.DayView extends AM.Component
  @id: -> 'PixelArtAcademy.PixelBoy.Apps.AdmissionWeek.DayView'
  @version: -> '0.1.0'

  @register @id()
  template: -> @constructor.id()

  constructor: (@admissionWeek) ->
    super arguments...

  onCreated: ->
    super arguments...

  visibleClass: ->
    'visible' if @admissionWeek.state 'startDay'

  events: ->
    super(arguments...).concat
      'click .app-unlock-button': @onClickAppUnlockButton

  onClickAppUnlockButton: (event) ->
    app = @currentData()
