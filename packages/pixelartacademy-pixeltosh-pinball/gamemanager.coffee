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
    
    @liveBalls = new ComputedField =>
      _.filter @balls(), (ball) => ball.state() is Pinball.Ball.States.Live

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
    @spawnBall()
  
  endSimulation: ->
    @_destroyBalls()
  
  _destroyBalls: ->
    ball.destroy() for ball in @balls()
    @balls []
    
    @ballNumber 0
  
  simulationActive: -> @mode() in [@constructor.Modes.Test, @constructor.Modes.Play]

  spawnBall: ->
    ballSpawner = _.find @pinball.sceneManager().parts(), (part) => part instanceof Pinball.Parts.BallSpawner
    
    balls = @balls()
    balls.push ballSpawner.spawnBall()
    @balls balls
    
    @ballNumber @ballNumber() + 1
  
  endBall: (ball) ->
    # Optionally remove the ball from the playfield.
    if ball
      balls = @balls()
      _.pull balls, ball
      @balls balls
    
    # See if we have any remaining balls.
    if remainingBallsCount = @remainingBallsCount()
      @remainingBallsCount remainingBallsCount - 1
      @spawnBall()
      
    else if @mode() is @constructor.Modes.Test
      # Test mode exists to edit mode automatically.
      @edit()
      
  isGameOver: ->
    @remainingBallsCount() is 0 and @liveBalls().length is 0
    
  addScore: (score) ->
    @score @score() + score
