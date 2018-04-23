LOI = LandsOfIllusions

# An indication of time from a character's perspective. The time point is stored
# as a floating point value of number of days that passed since the start of the game.
class LOI.GameDate
  constructor: (value) ->
    if _.isNumber value
      @_time = value

    else if value instanceof LOI.GameDate
      @_time = value.getTime()

    else if _.isObject value
      {day, hours, minutes, seconds} = value
      @_time = (day or 0) - 1 + ((hours or 0) + ((minutes or 0) + (seconds or 0) / 60) / 60) / 24

  # Returns the internal value indicating the number of days passed in the game.
  getTime: ->
    @_time

  # Returns the fractional value of time elapsed since start of the current day.
  getTimeInDay: ->
    @_time - @getDay() + 1

  # Return on which consecutive day of the game we are, starting with day 1.
  getDay: ->
    Math.floor(@_time) + 1

  getHours: ->
    # Get the fractional time in the day.
    hoursInDay = @getTimeInDay()

    # Expand the fraction to 24 hours.
    Math.floor hoursInDay * 24

  getMinutes: ->
    # Get the fractional time in the day without the hour component.
    minutesInDay = @getTimeInDay() - @getHours() / 24

    # Expand the fraction to 24 * 60 minutes.
    Math.floor minutesInDay * 24 * 60
    
  getSeconds: ->
    # Get the fractional time in the day without the hour or minutes component.
    secondsInDay = @getTimeInDay() - (@getHours() / 24 + @getMinutes() / (24 * 60))

    # Expand the fraction to 24 * 60 * 60 minutes.
    Math.round secondsInDay * (24 * 60 * 60)

  # Returns the next time at which the time within the date will match the given date.
  next: (value) ->
    nextGameDate = new LOI.GameDate value
    nextTimeInDay = nextGameDate.getTimeInDay()

    # Is the next time coming up on the current day?
    dayOffset = if nextTimeInDay > @getTimeInDay() then 0 else 1

    # Take the current or next day with the time in the day as given in the value.
    nextTime = Math.floor(@_time) + dayOffset + nextTimeInDay

    # Return a GameDate instance.
    new LOI.GameDate nextTime

  # Utility

  @typeName: -> 'LOI.GameDate'
  typeName: -> @constructor.typeName()

  toJSONValue: ->
    EJSON.stringify @getTime()

  clone: ->
    new LOI.GameDate @getTime()

  @equals: (a, b) ->
    return false unless a and b
    a.getTime() is b.getTime()

  equals: (other) ->
    @constructor.equals @, other

  toString: ->
    "#{@typeName()}{Day #{@getDay()}, #{@getHours()}:#{@getMinutes()}:#{@getSeconds()}}"

EJSON.addType LOI.GameDate.typeName(), (json) ->
  new LOI.GameDate EJSON.parse json
