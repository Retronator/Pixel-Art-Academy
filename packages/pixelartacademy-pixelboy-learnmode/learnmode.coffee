AB = Artificial.Babel
AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.PixelBoy.Apps.LearnMode extends PAA.PixelBoy.App
  # started: boolean whether the player has read the instructions
  # unlockedApps: array of app IDs unlocked by the player
  # completionDisplayType: how to display progress to the user, required by default
  @id: -> 'PixelArtAcademy.PixelBoy.Apps.LearnMode'
  @url: -> 'learnmode'

  @version: -> '0.0.3'

  @register @id()
  template: -> @constructor.id()

  @fullName: -> "Learn Mode"
  @description: ->
    "
      An app to track progress through Learn Mode content.
    "

  @initialize()

  @CompletionDisplayTypes:
    RequiredUnits: 'RequiredUnits'
    TotalPercentage: 'TotalPercentage'

  @isAppUnlocked: (appId) ->
    unlockedApps = @state('unlockedApps') or []
    appId in unlockedApps

  constructor: ->
    super arguments...

    @instructions = new ReactiveField null
    @progress = new ReactiveField null

    @scrolledToBottom = new ReactiveField false

  onCreated: ->
    super arguments...

    @instructions new @constructor.Instructions @
    @progress new @constructor.Progress @

    @setFixedPixelBoySize 229, 230

  onRendered: ->
    super arguments...

    @_app = @$('.app')[0]
    @_calculateScrolledToBottom()

  _calculateScrolledToBottom: ->
    @scrolledToBottom @_app.offsetHeight + @_app.scrollTop >= @_app.scrollHeight

  completionDisplayType: ->
    @state('completionDisplayType') or @constructor.CompletionDisplayTypes.RequiredUnits

  instructionsVisible: ->
    not PAA.PixelBoy.Apps.LearnMode.state 'started'

  instructionsVisibleClass: ->
    'instructions-visible' if @instructionsVisible()

  allowsShortcutsTable: ->
    # Shortcuts table is in its place when we're showing the instructions or if we scrolled to bottom of the main page.
    @instructionsVisible() or @scrolledToBottom()

  unlockApp: (appId) ->
    # Return to home screen.
    @os.go()

    unlockedApps = @state('unlockedApps') or []
    return if appId in unlockedApps

    # After the home screen has displayed, unlock the new app.
    homeScreenDisplayTime = 0.75 + @os.currentApps().length * 0.15

    await new _.waitForSeconds homeScreenDisplayTime

    unlockedApps.push appId
    @state 'unlockedApps', unlockedApps

  events: ->
    super(arguments...).concat
      'scroll .app': @onScrollApp

  onScrollApp: (event) ->
    @_calculateScrolledToBottom()
