AB = Artificial.Babel
AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.PixelBoy.Apps.AdmissionWeek extends PAA.PixelBoy.App
  # startDay: game day when the player started admission week
  # unlockedApps: array of app IDs unlocked by the player
  @id: -> 'PixelArtAcademy.PixelBoy.Apps.AdmissionWeek'
  @url: -> 'admissionweek'

  @version: -> '0.0.3-wip'

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

    @scrolledToBottom = new ReactiveField false

  onCreated: ->
    super arguments...

    @instructions new @constructor.Instructions @
    @dayView new @constructor.DayView @

    @setFixedPixelBoySize 229, 230

  onRendered: ->
    super arguments...

    @_app = @$('.app')[0]
    @_calculateScrolledToBottom()

  _calculateScrolledToBottom: ->
    @scrolledToBottom @_app.offsetHeight + @_app.scrollTop >= @_app.scrollHeight

  instructionsVisible: ->
    not PAA.PixelBoy.Apps.AdmissionWeek.state 'startDay'

  allowsShortcutsTable: ->
    # Shortcuts table is in its place when we're showing the instructions or if we scrolled to bottom of the main page.
    @instructionsVisible() or @scrolledToBottom()

  currentDay: ->
    return unless gameTime = LOI.adventure.gameTime()

    1 + Math.floor gameTime.getDay() - @state 'startDay'

  unlockApp: (appId) ->
    # Return to home screen.
    @os.go()

    unlockedApps = @state('unlockedApps') or []
    return if appId in unlockedApps

    # After a second, unlock the new app.
    Meteor.setTimeout =>
      unlockedApps.push appId
      @state 'unlockedApps', unlockedApps
    ,
      1000

  events: ->
    super(arguments...).concat
      'scroll .app': @onScrollApp

  onScrollApp: (event) ->
    @_calculateScrolledToBottom()
