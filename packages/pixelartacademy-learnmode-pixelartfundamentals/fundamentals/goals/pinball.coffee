LOI = LandsOfIllusions
PAA = PixelArtAcademy
LM = PixelArtAcademy.LearnMode

class LM.PixelArtFundamentals.Fundamentals.Goals.Pinball extends PAA.Learning.Goal
  @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Goals.Pinball'

  @displayName: -> "Pinball"

  @chapter: -> LM.PixelArtFundamentals.Fundamentals

  Goal = @
  
  class @OpenPinballMachine extends PAA.Learning.Task.Automatic
    @id: -> "#{Goal.id()}.OpenPinballMachine"
    @goal: -> Goal

    @directive: -> "Open your pinball machine"

    @instructions: -> """
      In the Pixeltosh app, open the Pinball Creation Kit drive and open the Pinball Machine file.
    """

    @interests: -> ['pinball', 'gaming']

    @requiredInterests: -> ['smooth curve (pixel art)']

    @initialize()

    @completedConditions: -> LM.PixelArtFundamentals.Fundamentals.state 'openedPinballMachine'
    
  class @DrawBall extends PAA.Learning.Task.Automatic
    @id: -> "#{Goal.id()}.DrawBall"
    @goal: -> Goal

    @directive: -> "Draw the ball"

    @instructions: -> """
      In the Drawing app, find the Pinball project and turn the ball sprite into a circle.
    """
    
    @predecessors: -> [Goal.OpenPinballMachine]
    
    @initialize()

    @completedConditions: ->
    
  class @PlayBall extends PAA.Learning.Task.Automatic
    @id: -> "#{Goal.id()}.PlayBall"
    @goal: -> Goal

    @directive: -> "Try out the new ball"

    @instructions: -> """
      Return to the pinball machine and test how the new ball moves on the playfield.
    """
    
    @predecessors: -> [Goal.DrawBall]

    @initialize()

    @completedConditions: ->
    
  class @DrawPlayfield extends PAA.Learning.Task.Automatic
    @id: -> "#{Goal.id()}.DrawPlayfield"
    @goal: -> Goal

    @directive: -> "Change the playfield"

    @instructions: -> """
      In the Pinball project, draw a curve at the top of the playfield to redirect the ball from the shooter lane into the main playfield area.
    """
    
    @predecessors: -> [Goal.PlayBall]

    @initialize()

    @completedConditions: ->
    
  class @PlayPlayfield extends PAA.Learning.Task.Automatic
    @id: -> "#{Goal.id()}.PlayPlayfield"
    @goal: -> Goal

    @directive: -> "Test the new playfield"

    @instructions: -> """
      Back on the Pixeltosh, plunge the ball strong enough to shoot it around the newly drawn curve.
    """
    
    @predecessors: -> [Goal.DrawPlayfield]

    @initialize()

    @completedConditions: ->
    
  class @DrawGobbleHole extends PAA.Learning.Task.Automatic
    @id: -> "#{Goal.id()}.DrawGobbleHole"
    @goal: -> Goal

    @directive: -> "Draw the gobble hole"

    @instructions: -> """
      In the Pinball project, redraw the Gobble hole sprite to any shape you want.
    """
    
    @predecessors: -> [Goal.PlayPlayfield]

    @initialize()

    @completedConditions: ->
    
  class @PlayGobbleHole extends PAA.Learning.Task.Automatic
    @id: -> "#{Goal.id()}.PlayGobbleHole"
    @goal: -> Goal

    @directive: -> "Score some points"

    @instructions: -> """
      Use the Edit mode of Pinball Creation Kit to place a gobble hole (or more) on the playfield and play until you get some points on the scoreboard.
    """
    
    @predecessors: -> [Goal.DrawGobbleHole]

    @initialize()

    @completedConditions: ->
  
  class @AddPins extends PAA.Learning.Task.Automatic
    @id: -> "#{Goal.id()}.AddPins"
    @goal: -> Goal
    
    @directive: -> "Add pins"
    
    @instructions: -> """
      You can add pins to your playfield in two ways to make the ball's trajectory more interesting.
      In Edit mode, drag individual pins onto the playfield.
      Alternatively, draw 1×1 or 2×2 pixel dots directly on the playfield sprite.
    """
    
    @predecessors: -> [Goal.PlayGobbleHole]
    
    @initialize()
    
    @completedConditions: ->

  class @DrawBallTrough extends PAA.Learning.Task.Automatic
    @id: -> "#{Goal.id()}.DrawBallTrough"
    @goal: -> Goal

    @directive: -> "Draw the ball trough"

    @instructions: -> """
      Similar to the gobble hole, the ball trough is an opening that drains the ball, except it scores no points.
      You can use it as an additional hole shape that usually appears at the bottom of the playfield.
    """
    
    @predecessors: -> [Goal.AddPins]

    @initialize()

    @completedConditions: ->
    
  class @PlayBallTrough extends PAA.Learning.Task.Automatic
    @id: -> "#{Goal.id()}.PlayBallTrough"
    @goal: -> Goal

    @directive: -> "Add the ball trough"

    @instructions: -> """
      Place the ball trough onto the playfield.
      Additionally, you can redraw the playfield to guide the ball to the ball trough at the bottom.
    """
    
    @predecessors: -> [Goal.DrawBallTrough]

    @initialize()

    @completedConditions: ->
    
  class @DrawBumper extends PAA.Learning.Task.Automatic
    @id: -> "#{Goal.id()}.DrawBumper"
    @goal: -> Goal

    @directive: -> "Draw a bumper"

    @instructions: -> """
      Draw a design for the Bumper sprite. A spring will be placed along the outline to bounce the ball away strongly.
    """
    
    @predecessors: -> [Goal.PlayBallTrough]

    @initialize()

    @completedConditions: ->
    
  class @PlayBumper extends PAA.Learning.Task.Automatic
    @id: -> "#{Goal.id()}.PlayBumper"
    @goal: -> Goal

    @directive: -> "Place bumpers on the playfield"

    @instructions: -> """
    """
    
    @predecessors: -> [Goal.DrawBumper]

    @initialize()

    @completedConditions: ->
    
  class @DrawGate extends PAA.Learning.Task.Automatic
    @id: -> "#{Goal.id()}.DrawGate"
    @goal: -> Goal

    @directive: -> "Draw a gate"

    @instructions: -> """
      To prevent the ball from returning to the shooting late, we'll need a gate.
      In the Pinball project, modify the Gate sprite as desired.
    """
    
    @predecessors: -> [Goal.PlayBumper]

    @initialize()

    @completedConditions: ->
    
  class @PlayGate extends PAA.Learning.Task.Automatic
    @id: -> "#{Goal.id()}.PlayGate"
    @goal: -> Goal

    @directive: -> "Add a gate to the shooting lane"

    @instructions: -> """
      Place the gate at the exit of the shooting lane and rotate it so the ball can go out but not in.
    """
    
    @predecessors: -> [Goal.DrawGate]

    @initialize()

    @completedConditions: ->
    
  class @RemoveGobbleHoles extends PAA.Learning.Task.Automatic
    @id: -> "#{Goal.id()}.RemoveGobbleHoles"
    @goal: -> Goal

    @directive: -> "Remove gobble holes"

    @instructions: -> """
      The time of mechanical pinball machines is coming to an end.
      With new ways to score points, remove the gobble holes from the playfield to make way for flippers.
    """
    
    @predecessors: -> [Goal.PlayGate]

    @initialize()

    @completedConditions: ->
    
  class @DrawFlipper extends PAA.Learning.Task.Automatic
    @id: -> "#{Goal.id()}.DrawFlipper"
    @goal: -> Goal

    @directive: -> "Draw a flipper"

    @instructions: -> """
      Flippers have arrived! Draw a desired shape for the left flipper as it will appear in its resting state.
    """
    
    @predecessors: -> [Goal.RemoveGobbleHoles]

    @initialize()

    @completedConditions: ->
    
  class @PlayFlipper extends PAA.Learning.Task.Automatic
    @id: -> "#{Goal.id()}.PlayFlipper"
    @goal: -> Goal

    @directive: -> "Play with flippers"

    @instructions: -> """
      Add two flippers at the bottom of the playfield. Use the flip edit option to turn the left flipper into a right one.
    """
    
    @predecessors: -> [Goal.DrawFlipper]

    @initialize()

    @completedConditions: ->
    
  class @DrawLowerThird extends PAA.Learning.Task.Automatic
    @id: -> "#{Goal.id()}.DrawLowerThird"
    @goal: -> Goal

    @directive: -> "Modernize the lower third"

    @instructions: -> """
      With flippers in your arsenal, draw a more modern layout for the lower third of your playfield.
      A typical arrangement has outer and inner lanes, as well as slingshots.
    """
    
    @predecessors: -> [Goal.PlayFlipper]

    @initialize()

    @completedConditions: ->
    
  class @DrawUpperThird extends PAA.Learning.Task.Automatic
    @id: -> "#{Goal.id()}.DrawUpperThird"
    @goal: -> Goal

    @directive: -> "Streamline the upper third"

    @instructions: -> """
      Your flippers can bounce the ball with great speeds back to the top.
      On your Playfield sprite, draw smooth curves to create lanes along which the ball can travel and return to the flippers.
    """
    
    @predecessors: -> [Goal.DrawLowerThird]

    @initialize()

    @completedConditions: ->
  
  class @ActiveBumpers extends PAA.Learning.Task.Automatic
    @id: -> "#{Goal.id()}.ActiveBumpers"
    @goal: -> Goal
    
    @directive: -> "Give bumpers some kick"
    
    @instructions: -> """
      On the Settings tab in the editor, you can now turn static bumpers into active ones.
      They will forcefully kick the ball away from them, increasing the game's excitement.
      If you want, use this opportunity to update the design of your bumper and refine the playfield to provide a place for multiple bumpers to kick the ball between them.
    """
    
    @predecessors: -> [Goal.DrawUpperThird]
  
    @initialize()
    
    @completedConditions: ->
  
  class @DrawSpinningTarget extends PAA.Learning.Task.Automatic
    @id: -> "#{Goal.id()}.DrawSpinningTarget"
    @goal: -> Goal
    
    @directive: -> "Draw a spinning target"
    
    @instructions: -> """
      Draw a design for the Spinning target sprite. You can also adjust its size as desired.
    """
    
    @predecessors: -> [Goal.ActiveBumpers]
  
    @initialize()
    
    @completedConditions: ->
  
  class @PlaySpinningTarget extends PAA.Learning.Task.Automatic
    @id: -> "#{Goal.id()}.PlaySpinningTarget"
    @goal: -> Goal
    
    @directive: -> "Get the target spinning"
    
    @instructions: -> """
      Add a spinning target or multiple of them to your playfield.
      Set the points based on the difficulty of hitting them and play the game to rank up a lot of points.
    """
    
    @predecessors: -> [Goal.DrawSpinningTarget]
  
    @initialize()
    
    @completedConditions: ->

  @tasks: -> [
    @OpenPinballMachine
    @DrawBall
    @PlayBall
    @DrawPlayfield
    @PlayPlayfield
    @DrawGobbleHole
    @PlayGobbleHole
    @AddPins
    @DrawBallTrough
    @PlayBallTrough
    @DrawBumper
    @PlayBumper
    @DrawGate
    @PlayGate
    @RemoveGobbleHoles
    @DrawFlipper
    @PlayFlipper
    @DrawLowerThird
    @DrawUpperThird
    @ActiveBumpers
    @DrawSpinningTarget
    @PlaySpinningTarget
  ]

  @finalTasks: -> [
    @PlaySpinningTarget
  ]

  @initialize()
