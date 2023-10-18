AE = Artificial.Everywhere

# Based on ComputedField from PeerLibrary
# https://github.com/peerlibrary/meteor-computed-field
class AE.LiveComputedField
  constructor: (valueFunctions, equalsFunction) ->
    lastValue = null

    autorunHandle = Tracker.nonreactive -> Tracker.autorun (computation) ->
      value = valueFunctions()

      if lastValue
        lastValue.set value
        
      else
        lastValue = new ReactiveVar value, equalsFunction

    getter = ->
      # We always flush so that you get the most recent value. This is a noop if autorun was not invalidated.
      getter.flush()
      lastValue.get()

    # We mingle the prototype so that getter instanceof ComputedField is true.
    Object.setPrototypeOf getter, @constructor.prototype

    getter.toString = -> "LiveComputedField{#{@()}}"

    getter.apply = -> getter()

    getter.call = -> getter()

    getter.stop = ->
      autorunHandle?.stop()
      autorunHandle = null

    # Sometimes you want to force recomputation of the new value before the global Tracker flush is done.
    # This is a noop if autorun was not invalidated.
    getter.flush = -> Tracker.nonreactive -> autorunHandle.flush()
    
    # Return the getter instead of constructed object. Return must be explicit.
    return getter
