AM = Artificial.Mirage
LOI = LandsOfIllusions

class LOI.Adventure extends LOI.Adventure
  _initializeTime: ->
    # The amount of seconds of playtime that happened.
    @_time = new ReactiveField null

    # The current game time from the character's perspective.
    @_gameTime = new ReactiveField null

    @_gameTimeInterval = Meteor.setInterval =>
      # Only increase time when the page is active and we're not paused.
      return if document.hidden or @paused()

      # Read last playtime from game state.
      return unless gameState = @gameState()
      return unless readOnlyGameState = @readOnlyGameState()
      lastTime = gameState.time or 0
      
      # Game time gets pushed forward on the client (game time) as well as the server (simulated game time).
      lastGameTime = gameState.gameTime or 0
      lastSimulatedGameTime = readOnlyGameState.simulatedGameTime or 0

      lastGameTime = Math.max lastGameTime, lastSimulatedGameTime

      # Add one second.
      newTime = lastTime + 1

      speedFactor = gameState.gameTimeSpeedFactor or 1
      newGameTime = lastGameTime + speedFactor / (60 * 60 * 24)

      # Update time in game state, but don't trigger reactivity (no need to update the database just for time increase)/.
      gameState.time = newTime
      gameState.gameTime = newGameTime

      # Instead, if things need to be reactive to time, they will depend on the time reactive field.
      @_time newTime

      newGameTimeDate = new LOI.GameDate newGameTime
      @_gameTime newGameTimeDate

      console.log "Playtime:", newTime, "seconds, Game time:", newGameTimeDate.toString() if LOI.debug
    ,
      1000

  # Query this to see if adventure time is running or not.
  paused: ->
    # Game is paused when there are any modal dialogs.
    return true if LOI.adventure.modalDialogs().length

    # It's also paused when we're in any of the accounts-ui flows/dialogs.
    accountsUiSessionVariables = ['inChangePasswordFlow', 'inMessageOnlyFlow', 'resetPasswordToken', 'enrollAccountToken', 'justVerifiedEmail', 'justResetPassword', 'configureLoginServiceDialogVisible', 'configureOnDesktopVisible']
    for variable in accountsUiSessionVariables
      return true if Accounts._loginButtonsSession.get variable

    false

  time: ->
    console.log "Returned time", @_time() if LOI.debug
    @_time()

  resetTime: ->
    @_time null

  gameTime: ->
    @_gameTime()

  endDay: ->
    # Fast forward until 9 AM next day.
    gameState = @gameState()
    day = Math.floor gameState.gameTime

    gameState.gameTime = day + 1 + 9 / 24

    @gameState.updated()
