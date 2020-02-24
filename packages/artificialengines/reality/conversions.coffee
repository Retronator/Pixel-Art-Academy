AR = Artificial.Reality

class AR.Conversions
  @kelvinsToCelsius: (celsius) ->
    celsius + 273.16 # K

  @radiansToDegrees: (radians) ->
    radians / Math.PI * 180

  @degreesToRadians: (degrees) ->
    degrees / 180 * Math.PI
