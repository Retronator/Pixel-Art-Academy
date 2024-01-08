AC = Artificial.Control

# A helper to normalize wheel events into discrete callbacks with a specific timeout.
class AC.DiscreteWheelEventListener
  constructor: (@options) ->
    @_scrollingFunction = (event) => @_onWheel event
    @options.$element.on 'wheel', @_scrollingFunction
    
    @_lastDeltaAmount = 0
    @_lastSign = 0
    @_lastEventTime = 0
    @_lastCallbackTime = 0
    
  destroy: ->
    @options.$element.off 'wheel', @_onWheel
    
  _onWheel: (event) ->
    delta = event.originalEvent.deltaY
    amount = Math.abs delta
    sign = Math.sign delta
    time = Date.now()
    
    # If more than timeout has passed since the last event (not callback), assume the value is zero by now.
    if time > @_lastEventTime + @options.timeout * 1000
      @_lastDeltaAmount = 0
      @_lastSign = 0
    
    # If the sign changed, immediately fire the event.
    if sign isnt @_lastSign
      @_callback sign
      
    # Otherwise, only react once timeout has passed.
    else if time > @_lastCallbackTime + @options.timeout * 1000
      # Only react if the amount is increasing to ignore smooth scrolling fade out.
      @_callback sign if amount > @_lastDeltaAmount
    
    # Update last values.
    @_lastDeltaAmount = amount
    @_lastSign = sign
    @_lastEventTime = time

  _callback: (sign) ->
    return unless sign
    
    @options.callback sign
    @_lastCallbackTime = Date.now()
