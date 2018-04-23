LOI = LandsOfIllusions

# A helper for dealing with game time.
class LOI.Time
  # The factor at which time passes on the server when simulating game state changes.
  @simulateSpeed = 2
  
  # Constants
  @millisecondsInADay = 24 * 60 * 60 * 1000
  
  @millisecondsToDays: (milliseconds) ->
    milliseconds / @millisecondsInADay
    
  @daysToMilliseconds: (days) ->
    days * @millisecondsInADay

  # Calculates number of real time milliseconds that pass when game runs 
  # for the provided number of game days with the given speed factor.
  @gameTimeToRealTimeDuration: (gameTime, gameSpeed = 1) ->
    @daysToMilliseconds(gameTime) / gameSpeed

  # Calculates the number of game days that pass when playing 
  # the game for the given amount of milliseconds with the given speed factor.
  @realTimeToGameTimeDuration: (realTime, gameSpeed = 1) ->
    @millisecondsToDays(realTime) * gameSpeed
    
  # Calculates number of real time milliseconds that would have to pass 
  # for the server to simulate the provided number of game days.
  @simulatedGameTimeToRealTimeDuration: (gameTime) ->
    @gameTimeToRealTimeDuration gameTime, @simulateSpeed

  # Calculates the number of game days the server should simulate when 
  # the given amount of milliseconds have passed in real time.
  @realTimeToSimulatedGameTimeDuration: (realTime) ->
    @realTimeToGameTimeDuration realTime, @simulateSpeed
