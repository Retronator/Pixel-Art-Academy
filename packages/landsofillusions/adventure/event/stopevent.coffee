LOI = LandsOfIllusions

# Represents an event that stops simulation on the server.
class LOI.Adventure.StopEvent extends LOI.Adventure.Event
  # Override if the stop event expires after some time.
  @expirationRealTimeDuration: -> null
  expirationRealTimeDuration: -> @constructor.expirationRealTimeDuration()

  simulateAtTime: ->
    return unless expirationRealTimeDuration = @expirationRealTimeDuration()

    eventRealTimeStart = super.getTime()
    new Date eventRealTimeStart + expirationRealTimeDuration

  process: ->
    return unless expirationTime = @simulateAtTime()

    # If it's past the expiration time, return true to signal this event was processed and should be removed.
    new Date() >= expirationTime
