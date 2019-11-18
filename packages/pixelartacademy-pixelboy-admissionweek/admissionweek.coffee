AB = Artificial.Babel
AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.PixelBoy.Apps.AdmissionWeek extends PAA.PixelBoy.App
  # startDay: game day when the player started admission week
  # unlockedApps: array of app IDs unlocked by the player
  @id: -> 'PixelArtAcademy.PixelBoy.Apps.AdmissionWeek'
  @url: -> 'admissionweek'

  @version: -> '0.0.1'

  @register @id()
  template: -> @constructor.id()

  @fullName: -> "Admission Week"
  @description: ->
    "
      An app to navigate the Retropolis Academy of Art admission process.
    "

  @initialize()

  constructor: ->
    super arguments...

    @instructions = new ReactiveField null
    @dayView = new ReactiveField null

  onCreated: ->
    super arguments...

    @instructions new @constructor.Instructions @
    @dayView new @constructor.DayView @

    @setMinimumPixelBoySize()

  currentDay: ->
    return unless gameTime = LOI.adventure.gameTime()

    1 + Math.floor gameTime.getDay() - @state 'startDay'

  onBackButton: ->
    instructions = @instructions()
    return unless instructions.visible()

    # Directly quit if admission week hasn't been set.
    return unless @state 'startDay'

    # Admission week has been started, so just return to the day view.
    instructions.visible false

    # Inform that we've handled the back button.
    true
