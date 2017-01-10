AE = Artificial.Everywhere
AM = Artificial.Mirage
LOI = LandsOfIllusions

class LOI.Components.Menu.Items extends AM.Component
  @register 'LandsOfIllusions.Components.Menu.Items'

  @Screens:
    MainMenu: 'MainMenu'
    Settings: 'Settings'

  constructor: (@options) ->
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
    # Quit is visible when you are not on the landing page.
    not @options.landingPage

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
      'click .account': @onClickAccount
      'click .fullscreen': @onClickFullscreen
      'click .settings': @onClickSettings
      'click .quit': @onClickQuit
      'click .back': @onClickBack

  onClickContinue: (event) ->
    @options.adventure.menu.hideMenu()

  onClickNew: (event) ->
    # Scroll down to help the player understand they should scroll down to begin.
    @options.adventure.interface.narrative.scroll()

  onClickLoad: (event) ->
    # Wait until user is logged in.
    userAutorun = Tracker.autorun (computation) =>
      return unless user = Retronator.user()
      computation.stop()

      # Wait also until the game state has been loaded.
      Tracker.autorun (computation) =>
        return unless @options.adventure.gameStateSubsription.ready()
        computation.stop()

        databaseState = LOI.GameState.documents.findOne 'user._id': user._id

        if databaseState
          # Move user to the last location saved to the state. We do this only on load so that multiple players using
          # the same account can move independently, at least inside the current session (they will get synced again on
          # reload).
          @options.adventure.currentLocationId databaseState.state.currentLocationId

        else
          # TODO: Show dialog informing the user we're saving the local game state.
          LOI.GameState.insertForCurrentUser @options.adventure.localGameState.state(), =>
            # Now that the local state has been transferred, clear it for next player.
            @options.adventure.clearLocalGameState()

      @options.adventure.menu.signIn.activatable.deactivate()

    @options.adventure.menu.showModalDialog
      dialog: @options.adventure.menu.signIn
      callback: =>
        # User has returned from the load screen.
        userAutorun.stop()

  onClickAccount: (event) ->
    @options.adventure.menu.account.show()

  onClickFullscreen: (event) ->
    if AM.Window.isFullscreen()
      AM.Window.exitFullscreen()

    else
      AM.Window.enterFullscreen()

    # Do a late UI resize to accommodate any fullscreen transitions.
    Meteor.setTimeout =>
      @options.adventure.interface.resize()
    ,
      1000

  onClickSettings: (event) ->
    @currentScreen @constructor.Screens.Settings

  onClickQuit: (event) ->
    # Close the menu.
    @options.adventure.menu.hideMenu()

    # Reset the local game state, so when we logout it will kick in.
    @options.adventure.clearLocalGameState()

    # Log out.
    @options.adventure.logout()

    # Go to the terrace and scroll to top.
    @options.adventure.goToLocation Retropolis.Spaceport.Locations.Terrace
    @options.adventure.interface.scrollTo position: 0

  onClickBack: (event) ->
    @currentScreen @constructor.Screens.MainMenu
