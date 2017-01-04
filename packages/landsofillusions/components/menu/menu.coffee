AE = Artificial.Everywhere
AM = Artificial.Mirage
LOI = LandsOfIllusions

class LOI.Components.Menu extends AM.Component
  @register 'LandsOfIllusions.Components.Menu'

  @Screens:
    MainMenu: 'MainMenu'
    Settings: 'Settings'

  constructor: (@options) ->
    super

    @currentScreen = new ReactiveField @constructor.Screens.MainMenu

  onRendered: ->
    super

  newVisible: ->
    return false

    # New game is visible for the logged-out user.
    not Retronator.user()

  continueVisible: ->
    return false

    # Continue is visible for logged-in users that are not on the landing page.
    Retronator.user() and not @options.landingPage

  loadVisible: ->
    return false

    # Load game is visible when user is not logged in.
    not Retronator.user()

  quitVisible: ->
    return false

    # Quit is visible for logged in users.
    Retronator.user()

  inMainMenu: ->
    @currentScreen() is @constructor.Screens.MainMenu

  inSettings: ->
    @currentScreen() is @constructor.Screens.Settings

  isFullscreen: ->
    AM.Window.isFullscreen()

  events: ->
    super.concat
      'click .new': @onClickNew
      'click .load': @onClickLoad
      'click .fullscreen': @onClickFullscreen
      'click .settings': @onClickSettings
      'click .quit': @onClickQuit
      'click .back': @onClickBack

  onClickNew: (event) ->
    # Reset game state.
    state = @options.adventure.gameState()
    LOI.Adventure.resetGameState state
    @options.adventure.gameState.updated()

    # Start back at Retropolis landing page.
    if @options.adventure.currentLocationId() is PixelArtAcademy.LandingPage.Locations.Retropolis.id()
      # If we were already at Retropolis, scroll down to help the player understand they should scroll down to begin.
      @options.adventure.interface.narrative.scroll()

    else
      @options.adventure.goToLocation PixelArtAcademy.LandingPage.Locations.Retropolis

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

      @options.adventure.deactivateCurrentItem()

    @options.adventure.scriptHelpers.itemInteraction
      item: Retronator.HQ.Items.Wallet
      callback: =>
        # User has returned from the wallet.
        userAutorun.stop()

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
    # On quit we should log out and go back to the landing page.
    @options.adventure.logout()
    @options.adventure.goToLocation PixelArtAcademy.LandingPage.Locations.Retropolis

  onClickBack: (event) ->
    @currentScreen @constructor.Screens.MainMenu
