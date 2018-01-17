AE = Artificial.Everywhere
AM = Artificial.Mirage
LOI = LandsOfIllusions

class LOI.Components.Menu.Items extends AM.Component
  @register 'LandsOfIllusions.Components.Menu.Items'

  @Screens:
    MainMenu: 'MainMenu'
    Settings: 'Settings'

  constructor: (@options = {}) ->
    super

    @currentScreen = new ReactiveField @constructor.Screens.MainMenu

  onRendered: ->
    super

  aboutVisible: ->
    # About is visible on the landing page.
    @options.landingPage

  pressVisible: ->
    # Same as about.
    @aboutVisible()

  smallprintVisible: ->
    # Always shown.
    true

  newVisible: ->
    # New game is visible only on the landing page.
    @options.landingPage

  continueVisible: ->
    # Continue is visible when we're not on the landing page.
    not @options.landingPage

  loadVisible: ->
    # Load game is visible when user is not logged in.
    not Retronator.user()

  saveVisible: ->
    # Always hidden.
    return false

    # Legacy: Save game is visible when a guest isn't on the landing page.
    return if Retronator.user()

    not @options.landingPage

  accountVisible: ->
    # Account is visible for logged in users.
    Retronator.user()

  quitVisible: ->
    # Quit is visible when you are not on the landing page or if you're logged in.
    not @options.landingPage or Retronator.user()

  inMainMenu: ->
    @currentScreen() is @constructor.Screens.MainMenu

  inSettings: ->
    @currentScreen() is @constructor.Screens.Settings

  isFullscreen: ->
    AM.Window.isFullscreen()

  events: ->
    super.concat
      'click .continue': @onClickContinue
      'click .new': @onClickNew
      'click .load': @onClickLoad
      'click .save': @onClickSave
      'click .account': @onClickAccount
      'click .fullscreen': @onClickFullscreen
      'click .settings': @onClickSettings
      'click .quit': @onClickQuit
      'click .back': @onClickBack

  onClickContinue: (event) ->
    LOI.adventure.menu.hideMenu()

  onClickNew: (event) ->
    # Scroll down to help the player understand they should scroll down to begin.
    LOI.adventure.interface.narrative.scroll()

  onClickLoad: (event) ->
    if @options.landingPage
      # On the landing page we can directly load.
      LOI.adventure.loadGame()
  
    else
      # Warn user they will lose progress.
      dialog = new LOI.Components.Dialog
        message: "You will lose current game progress if you load another game."
        buttons: [
          text: "Continue"
          value: true
        ,
          text: "Cancel"
        ]

      LOI.adventure.showActivatableModalDialog
        dialog: dialog
        callback: =>
          LOI.adventure.loadGame() if dialog.result

  onClickSave: (event) ->
    LOI.adventure.saveGame()

  onClickAccount: (event) ->
    LOI.adventure.menu.account.show()

  onClickFullscreen: (event) ->
    if AM.Window.isFullscreen()
      AM.Window.exitFullscreen()

    else
      AM.Window.enterFullscreen()

    # Do a late UI resize to accommodate any fullscreen transitions.
    Meteor.setTimeout =>
      LOI.adventure.interface.resize()
    ,
      1000

  onClickSettings: (event) ->
    @currentScreen @constructor.Screens.Settings

  onClickQuit: (event) ->
    if Retronator.user()
      LOI.adventure.quitGame()

    else
      # Notify the player that they will lose the current game state.
      dialog = new LOI.Components.Dialog
        message: "You will lose current game progress if you quit."
        buttons: [
          text: "Quit"
          value: true
        ,
          text: "Cancel"
        ]

      LOI.adventure.showActivatableModalDialog
        dialog: dialog
        callback: =>
          LOI.adventure.quitGame() if dialog.result
  
  onClickBack: (event) ->
    @currentScreen @constructor.Screens.MainMenu
