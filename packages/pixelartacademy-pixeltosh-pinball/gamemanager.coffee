AE = Artificial.Everywhere
AR = Artificial.Reality
LOI = LandsOfIllusions
PAA = PixelArtAcademy
Pinball = PAA.Pixeltosh.Programs.Pinball

class Pinball.GameManager
  @Modes:
    Edit: 'Edit'
    Test: 'Test'
    Play: 'Play'
  
  constructor: (@pinball) ->
    @mode = new ReactiveField @constructor.Modes.Edit

    @remainingBallsCount = new ReactiveField 0
    @ballNumber = new ReactiveField 0
    @score = new ReactiveField 0
    
    @balls = new ReactiveField []
    
    @liveBalls = new AE.LiveComputedField =>
      _.filter @balls(), (ball) => ball.state() is Pinball.Ball.States.Live
      
    # Handle running out of live balls.
    @_ballsAutorun = @pinball.autorun =>
      return unless @simulationActive()
      return if @liveBalls().length
  
      # See if we have any remaining balls.
      if remainingBallsCount = @remainingBallsCount()
        @remainingBallsCount remainingBallsCount - 1
        @spawnBalls()
        
      else if @mode() is @constructor.Modes.Test
        # Test mode always spawns extra balls.
        @spawnBalls()
        
  destroy: ->
    @liveBalls.stop()
    @_ballsAutorun.stop()

  edit: ->
    return unless @startMode @constructor.Modes.Edit
    
  test: ->
    @startMode @constructor.Modes.Test
    
  play: ->
    @startMode @constructor.Modes.Play
    
  startMode: (mode) ->
    return if @mode() is mode
    @mode mode
    @reset()

  reset: ->
    part.reset() for part in @pinball.sceneManager().parts()
    
    switch @mode()
      when @constructor.Modes.Edit
        @endSimulation()
        
      when @constructor.Modes.Test
        @remainingBallsCount 0
        @startSimulation()
      
      when @constructor.Modes.Play
        @remainingBallsCount 2
        @score 0
        @startSimulation()
  
  startSimulation: ->
    @_destroyBalls()
    @spawnBalls true
    
    part.onSimulationStarted?() for part in @pinball.sceneManager().parts()
  
  endSimulation: ->
    @_destroyBalls()

    part.onSimulationEnded?() for part in @pinball.sceneManager().parts()
  
  _destroyBalls: ->
    balls = @balls()
    @balls []
    
    Tracker.afterFlush =>
      ball.destroy() for ball in balls
    
    @ballNumber 0
  
  simulationActive: -> @mode() in [@constructor.Modes.Test, @constructor.Modes.Play]

  spawnBalls: (gameStart) ->
    balls = @balls()
    
    for part in @pinball.sceneManager().parts() when part instanceof Pinball.Parts.BallSpawner
      ballSpawner = part
      continue if ballSpawner.data().captive and not gameStart

      balls.push ballSpawner.spawnBall()

    @balls balls
    
    @ballNumber @ballNumber() + 1
  
  removeBall: (ball) ->
    balls = @balls()
    _.pull balls, ball
    @balls balls
    
    Tracker.afterFlush => ball.destroy()
    
  isGameOver: ->
    @remainingBallsCount() is 0 and @liveBalls().length is 0
    
  addPoints: (score) ->
    @score @score() + score
