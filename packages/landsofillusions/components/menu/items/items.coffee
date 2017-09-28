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
    # Save game is visible when a guest isn't on the landing page.
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
    # If the player could save the game, warn them about losing progress.
    if @saveVisible()
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

    else
      LOI.adventure.loadGame()

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
    # If the player could save the game, warn them about losing progress.
    if @saveVisible()
      dialog = new LOI.Components.Dialog
        message: "You will lose current game progress if you quit without saving. Proceed?"
        buttons: [
          text: "Quit"
          value: true
        ,
          text: "Cancel"
        ]

      LOI.adventure.showActivatableModalDialog
        dialog: dialog
        callback: =>
          @_quit() if dialog.result

    else
      @_quit()

  _quit: ->
    # Close the menu.
    LOI.adventure.menu.hideMenu()

    # Remove other modal menus.
    LOI.adventure.removeModalDialog dialogOptions.dialog for dialogOptions in LOI.adventure.modalDialogs()

    # Reset the local game state, so when we logout it will kick in.
    LOI.adventure.clearLocalGameState()

    # Log out.
    LOI.adventure.logout
      callback: =>
        # Reset the interface.
        LOI.adventure.interface.resetInterface()

        # Clear active item.
        LOI.adventure.activeItemId null

        # Clear character and location to trigger location changes.
        LOI.switchCharacter null
        LOI.adventure.playerLocationId null

        # Reset game time.
        LOI.adventure.resetTime()

        # Cleanup storyline classes.
        LOI.adventure.resetEpisodes()

        # Cleanup running scripts.
        LOI.adventure.director.stopAllScripts()

        # Go to the terrace and scroll to top.
        LOI.adventure.playerLocationId Retropolis.Spaceport.AirportTerminal.Terrace.id()
        LOI.adventure.playerTimelineId PixelArtAcademy.TimelineIds.DareToDream

        LOI.adventure.interface.scroll position: 0

  onClickBack: (event) ->
    @currentScreen @constructor.Screens.MainMenu
