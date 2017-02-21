AM = Artificial.Mirage
LOI = LandsOfIllusions

class LOI.Adventure extends LOI.Adventure
  _initializeTime: ->
    @_time = new ReactiveField null

    @_gameTimeInterval = Meteor.setInterval =>
      # Only increase time when the page and interface is active.
      return if document.hidden or not @interface.active()

      # Read last time from game state.
      return unless gameState = @gameState()
      lastTime = gameState.time or 0

      # Add one second.
      newTime = lastTime + 1

      # Update time in game state, but don't trigger reactivity (no need to update the database just for time increase)/.
      gameState.time = newTime

      # Instead, if things need to be reactive to time, they will depend on the time reactive field.
      @_time newTime

      console.log "Adventure time: ", newTime if LOI.debug
    ,
      1000

  time: ->
    console.log "Returned time", @_time() if LOI.debug
    @_time()

  resetTime: ->
    @_time null
