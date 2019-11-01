# Creates an autorun that gets executed only after all other recomputations are done.
Tracker.delayedAutorun = (method) ->
  autorunHandle = null
  needsDelay = true
  stopCalled = false

  callMethodWithDelay = ->
    Tracker.nonreactive ->
      autorunHandle?.stop()
      autorunHandle = Tracker.autorun (computation) ->
        if needsDelay
          # Wait until recomputation before calling the method.
          Tracker.afterFlush ->
            # Quit recursion if stop was called.
            return if stopCalled

            # Mark that flush has finished and we don't need to delay any more.
            needsDelay = false

            # Restart the call.
            callMethodWithDelay()

          return

        # No delay was needed so we can call the method, registering the necessary dependencies for its recomputation.
        method computation

        # Now we should be waiting for another end of recomputations before running again.
        needsDelay = true

  # Start recursive calls.
  callMethodWithDelay()

  # Return a persistent handle that wraps around and mimics the inner changing autorun handle.
  stop: =>
    autorunHandle?.stop()
    stopCalled = true
