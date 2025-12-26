AE = Artificial.Everywhere
LOI = LandsOfIllusions
PAA = PixelArtAcademy
LM = PixelArtAcademy.LearnMode

Goal = LM.PixelArtFundamentals.Fundamentals.Goals.Pinball
Pinball = PAA.Pixeltosh.Programs.Pinball

class Goal.OpenPinballMachine extends Goal.Task
  @id: -> "#{Goal.id()}.OpenPinballMachine"
  @goal: -> Goal

  @directive: -> "Open your pinball machine"

  @instructions: -> """
    In the Pixeltosh app, open the Pinball Creation Kit drive and open the My Pinball Machine file.
  """

  @interests: -> ['pinball', 'gaming']

  @requiredInterests: -> ['smooth curve (pixel art)']

  @studyPlanBuilding: -> 'SimCitySubway'

  @initialize()

  @completedConditions: -> LM.PixelArtFundamentals.Fundamentals.state 'openedPinballMachine'
  
  reset: ->
    super arguments...
    
    LM.PixelArtFundamentals.Fundamentals.state 'openedPinballMachine', false
  
class Goal.DrawBall extends Goal.AssetsTask
  @id: -> "#{Goal.id()}.DrawBall"
  @goal: -> Goal

  @directive: -> "Draw the ball"

  @instructions: -> """
    In the Drawing app, find the Pinball project and turn the ball sprite into a circle.
  """
  
  @predecessors: -> [Goal.OpenPinballMachine]
  
  @studyPlanBuilding: -> 'SimCityWaterPump'
  
  @initialize()
  
  @unlockedAssets: -> [
    Pinball.Assets.Ball
    Pinball.Assets.Plunger
  ]
  
  Task = @
  
  class @RedrawBall extends PAA.PixelPad.Systems.Instructions.Instruction
    @id: -> "#{Task.id()}.RedrawBall"
    
    @message: -> """
      Oh no! It looks like the ball is a cube! Change it to a sphere in the Drawing app so it will roll.
    """
    
    @activeConditions: ->
      return unless Task.getAdventureInstance().active()
      
      # Show when we're in the active Pinball program.
      return unless os = PAA.PixelPad.Apps.Pixeltosh.getOS()
      program = os.activeProgram()
      return unless program instanceof PAA.Pixeltosh.Programs.Pinball
      program.projectId() is PAA.Pixeltosh.Programs.Pinball.state 'activeProjectId'
    
    @delayDuration: -> 5
    
    @initialize()
    
    faceClass: -> PAA.Pixeltosh.Instructions.FaceClasses.OhNo
    
class Goal.PlayBall extends Goal.Task
  @id: -> "#{Goal.id()}.PlayBall"
  @goal: -> Goal

  @directive: -> "Try out the new ball"

  @instructions: -> """
    Return to the pinball machine and test how the new ball moves on the playfield.
  """
  
  @predecessors: -> [Goal.DrawBall]

  @studyPlanBuilding: -> 'SimCityPark'

  @initialize()

  @completedConditions: ->
    return unless ballTravelExtents = Pinball.state 'ballTravelExtents'
    
    # The ball must have reached into the top third.
    ballTravelExtents.z.min < Pinball.SceneManager.shortPlayfieldDepth / 3
    
  reset: ->
    super arguments...
    
    Pinball.resetBallExtents()
  
class Goal.DrawPlayfield extends Goal.AssetsTask
  @id: -> "#{Goal.id()}.DrawPlayfield"
  @goal: -> Goal

  @directive: -> "Change the playfield"

  @instructions: -> """
    In the Pinball project, draw a curve at the top of the playfield to redirect the ball from the shooter lane into the main playfield area.
  """
  
  @predecessors: -> [Goal.PlayBall]

  @studyPlanBuilding: -> 'SimCityCommercial3'

  @initialize()
  
  @onActive: ->
    super arguments...
    
    # Make sure we get a fresh start on the extents in case the ball bounced out of the shooter lane by chance.
    # We do this in this step instead of the next since completedConditions can otherwise run before onActive.
    Pinball.resetBallExtents()
  
  @unlockedAssets: -> [
    Pinball.Assets.Playfield
  ]
  
class Goal.PlayPlayfield extends Goal.Task
  @id: -> "#{Goal.id()}.PlayPlayfield"
  @goal: -> Goal

  @directive: -> "Test the new playfield"

  @instructions: -> """
    Back on the Pixeltosh, plunge the ball strong enough to shoot it around the newly drawn curve.
  """
  
  @predecessors: -> [Goal.DrawPlayfield]

  @studyPlanBuilding: -> 'SimCityCommercial4'

  @initialize()

  @completedConditions: ->
    return unless ballTravelExtents = Pinball.state 'ballTravelExtents'
    
    # The ball must have reached into the left third.
    ballTravelExtents.x.min < Pinball.SceneManager.playfieldWidth / 3
  
  reset: ->
    super arguments...
    
    Pinball.resetBallExtents()
    
class Goal.DrawGobbleHole extends Goal.AssetsTask
  @id: -> "#{Goal.id()}.DrawGobbleHole"
  @goal: -> Goal

  @directive: -> "Draw the gobble hole"

  @instructions: -> """
    In the Pinball project, redraw the Gobble hole sprite to any shape you want.
  """
  
  @predecessors: -> [Goal.PlayPlayfield]

  @studyPlanBuilding: -> 'SimCityIndustrial1'

  @initialize()
  
  @unlockedAssets: -> [
    Pinball.Assets.GobbleHole
  ]
  
class Goal.PlayGobbleHole extends Goal.Task
  @id: -> "#{Goal.id()}.PlayGobbleHole"
  @goal: -> Goal

  @directive: -> "Score some points"

  @instructions: -> """
    Use the Edit mode of Pinball Creation Kit to place a gobble hole (or more) on the playfield and play until you get some points on the scoreboard.
  """
  
  @predecessors: -> [Goal.DrawGobbleHole]

  @studyPlanBuilding: -> 'SimCityIndustrial2'

  @initialize()

  @completedConditions: ->
    @playfieldHasPart(Pinball.Parts.GobbleHole) and Pinball.state 'highScore'
  
  reset: ->
    super arguments...
    
    LM.PixelArtFundamentals.Fundamentals.state 'highScore', 0
    
class Goal.AddPins extends Goal.Task
  @id: -> "#{Goal.id()}.AddPins"
  @goal: -> Goal
  
  @directive: -> "Add pins"
  
  @instructions: -> """
    Add pins to your playfield to make the ball's trajectory more interesting.
    You can do this in two ways. In Edit mode, drag individual pins onto the playfield.
    Alternatively, draw 1×1 or 2×2 pixel dots directly on the Playfield sprite.
  """
  
  @predecessors: -> [Goal.PlayGobbleHole]
  
  @groupNumber: -> -1
  
  @studyPlanBuilding: -> 'SimCityIndustrial3'
  
  @initialize()
  
  @completedConditions: ->
    return unless activeProjectId = PAA.Pixeltosh.Programs.Pinball.Project.state 'activeProjectId'
    return unless project = PAA.Practice.Project.documents.findOne activeProjectId

    # See if there are any pin parts on the playfield.
    for playfieldPartId, partData of project.playfield
      return true if partData.type is Pinball.Parts.Pin.id()
      
    # Alternatively, pins could be drawn as isolated points on the playfield bitmap.
    # HACK: To prevent lag with running the evaluation, only do this when the editor is not active.
    return if PAA.PixelPad.Apps.Drawing.Editor.getEditor()?.drawingActive()
    return unless playfieldAsset = _.find project.assets, (asset) => asset.id is Pinball.Assets.Playfield.id()
    return unless playfieldBitmap = LOI.Assets.Bitmap.versionedDocuments.getDocumentForId playfieldAsset.bitmapId
    
    pixelArtEvaluation = new PAA.Practice.PixelArtEvaluation playfieldBitmap
    isolatedPointFound = _.find pixelArtEvaluation.layers[0].points, (point) => not point.neighbors.length
    pixelArtEvaluation.destroy()
    
    isolatedPointFound

class Goal.DrawBallTrough extends Goal.AssetsTask
  @id: -> "#{Goal.id()}.DrawBallTrough"
  @goal: -> Goal

  @directive: -> "Draw the drain"

  @instructions: -> """
    Similar to the gobble hole, the drain is an area that catches the ball, except it scores no points.
    You can use it as an additional hole shape that usually appears at the bottom of the playfield.
  """
  
  @predecessors: -> [Goal.PlayGobbleHole]
  
  @groupNumber: -> 1

  @studyPlanBuilding: -> 'SimCityIndustrial4'

  @initialize()
  
  @unlockedAssets: -> [
    Pinball.Assets.BallTrough
  ]
  
class Goal.PlayBallTrough extends Goal.Task
  @id: -> "#{Goal.id()}.PlayBallTrough"
  @goal: -> Goal

  @directive: -> "Add the drain"

  @instructions: -> """
    Place the drain onto the playfield.
    Additionally, you can redraw the playfield to guide the ball to the drain at the bottom.
  """
  
  @predecessors: -> [Goal.DrawBallTrough]
  
  @groupNumber: -> 1

  @studyPlanBuilding: -> 'SimCityOffice1'

  @initialize()

  @completedConditions: -> @playfieldHasPart Pinball.Parts.BallTrough
  
class Goal.DrawBumper extends Goal.AssetsTask
  @id: -> "#{Goal.id()}.DrawBumper"
  @goal: -> Goal

  @directive: -> "Draw a bumper"

  @instructions: -> """
    Draw a design for the Bumper sprite. A spring will be placed along the outline to bounce the ball away.
  """
  
  @predecessors: -> [
    Goal.AddPins
    Goal.PlayBallTrough
  ]

  @studyPlanBuilding: -> 'SimCityOffice2'

  @initialize()
  
  @unlockedAssets: -> [
    Pinball.Assets.Bumper
  ]
  
class Goal.PlayBumper extends Goal.Task
  @id: -> "#{Goal.id()}.PlayBumper"
  @goal: -> Goal

  @directive: -> "Place bumpers on the playfield"

  @instructions: -> """
    Make some space on the playfield by removing parts if needed.
    Place multiple bumpers and adjust the bounciness of their springs on the Settings tab.
  """
  
  @predecessors: -> [Goal.DrawBumper]

  @studyPlanBuilding: -> 'SimCityOffice3'

  @initialize()

  @completedConditions: -> @playfieldHasPart Pinball.Parts.Bumper
  
class Goal.DrawGate extends Goal.AssetsTask
  @id: -> "#{Goal.id()}.DrawGate"
  @goal: -> Goal

  @directive: -> "Draw a gate"

  @instructions: -> """
    To prevent the ball from returning to the shooter lane, we'll need a gate.
    In the Pinball project, modify the Gate sprite as desired.
  """
  
  @predecessors: -> [Goal.PlayBumper]

  @studyPlanBuilding: -> 'TransportTycoonHouse'

  @initialize()
  
  @unlockedAssets: -> [
    Pinball.Assets.Gate
  ]
  
class Goal.PlayGate extends Goal.Task
  @id: -> "#{Goal.id()}.PlayGate"
  @goal: -> Goal

  @directive: -> "Add a gate to the shooter lane"

  @instructions: -> """
    Place the gate at the exit of the shooter lane and rotate it so the ball can go out but not in.
  """
  
  @predecessors: -> [Goal.DrawGate]

  @studyPlanBuilding: -> 'TransportTycoonCinema'

  @initialize()

  @completedConditions: -> @playfieldHasPart Pinball.Parts.Gate
  
class Goal.RemoveGobbleHoles extends Goal.Task
  @id: -> "#{Goal.id()}.RemoveGobbleHoles"
  @goal: -> Goal

  @directive: -> "Remove gobble holes"

  @instructions: -> """
    The time of mechanical pinball machines is coming to an end.
    With new ways to score points, remove the gobble holes from the playfield to make way for flippers.
  """
  
  @predecessors: -> [Goal.PlayGate]

  @studyPlanBuilding: -> 'SimCityChurch'

  @initialize()

  @completedConditions: -> not @playfieldHasPart Pinball.Parts.GobbleHole
  
class Goal.DrawFlipper extends Goal.AssetsTask
  @id: -> "#{Goal.id()}.DrawFlipper"
  @goal: -> Goal

  @directive: -> "Draw a flipper"

  @instructions: -> """
    Flippers have arrived! Draw a desired shape for the left flipper as it will appear in its resting state.
  """
  
  @predecessors: -> [Goal.RemoveGobbleHoles]

  @studyPlanBuilding: -> 'SimCityWindTurbine'

  @initialize()
  
  @unlockedAssets: -> [
    Pinball.Assets.Flipper
  ]
  
class Goal.PlayFlipper extends Goal.Task
  @id: -> "#{Goal.id()}.PlayFlipper"
  @goal: -> Goal

  @directive: -> "Play with flippers"

  @instructions: -> """
    Add two flippers at the bottom of the playfield. Use the Edit menu to flip a left flipper into a right one.
    On the Settings tab, adjust the angle range to suit your flipper.
  """
  
  @predecessors: -> [Goal.DrawFlipper]

  @studyPlanBuilding: -> 'SimCityResidential1'

  @initialize()

  @completedConditions: ->
    return unless activeProjectId = PAA.Pixeltosh.Programs.Pinball.Project.state 'activeProjectId'
    return unless project = PAA.Practice.Project.documents.findOne activeProjectId
    
    leftFound = false
    rightFound = false
    
    for playfieldPartId, partData of project.playfield when partData.type is Pinball.Parts.Flipper.id()
      if partData.flipped
        rightFound = true
        
      else
        leftFound = true
    
    leftFound and rightFound
  
class Goal.DrawLowerThird extends Goal.RedrawPlayfieldTask
  @id: -> "#{Goal.id()}.DrawLowerThird"
  @goal: -> Goal

  @directive: -> "Modernize the lower third"

  @instructions: -> """
    With flippers in your arsenal, draw a more modern layout for the lower third of your playfield.
    A typical arrangement has outer and inner lanes, as well as slingshots.
    Edit the Playfield sprite until you are happy with how the design plays.
  """
  
  @predecessors: -> [Goal.PlayFlipper]

  @studyPlanBuilding: -> 'SimCityResidential2'

  @initialize()

class Goal.ActiveBumpers extends Goal.Task
  @id: -> "#{Goal.id()}.ActiveBumpers"
  @goal: -> Goal
  
  @directive: -> "Give bumpers some kick"
  
  @instructions: -> """
    You can now turn static bumpers into active ones.
    Select a bumper you placed on the playfield and click on the Settings tab in the editor.
    Click on the active option to turn it into a bumper that will forcefully kick the ball away from it, increasing the game's excitement.
    If you want, use this opportunity to update your bumper drawing as well.
  """
  
  @predecessors: -> [Goal.DrawUpperThird]

  @studyPlanBuilding: -> 'SimCityResidential5'

  @initialize()
  
  @completedConditions: ->
    # Find a bumper with active set to true.
    return unless activeProjectId = PAA.Pixeltosh.Programs.Pinball.Project.state 'activeProjectId'
    return unless project = PAA.Practice.Project.documents.findOne activeProjectId
    
    for playfieldPartId, partData of project.playfield
      return true if partData.type is Pinball.Parts.Bumper.id() and partData.active
    
    false

class Goal.DrawUpperThird extends Goal.RedrawPlayfieldTask
  @id: -> "#{Goal.id()}.DrawUpperThird"
  @goal: -> Goal
  
  @directive: -> "Streamline the upper third"
  
  @instructions: -> """
    On your Playfield sprite, use smooth curves to draw lanes along which the ball can travel across the upper part of the playfield.
    Aim the lane entrances and exits in the direction of the flippers.
    The upper third also usually provides a place for multiple bumpers to kick the ball between them.
  """
  
  @predecessors: -> [Goal.DrawLowerThird]
  
  @studyPlanBuilding: -> 'SimCityResidential3'

  @initialize()

class Goal.DrawSpinningTarget extends Goal.AssetsTask
  @id: -> "#{Goal.id()}.DrawSpinningTarget"
  @goal: -> Goal
  
  @directive: -> "Draw a spinning target"
  
  @instructions: -> """
    Draw a design for the Spinning target sprite. You can also adjust its size as desired.
  """
  
  @predecessors: -> [Goal.ActiveBumpers]

  @studyPlanBuilding: -> 'SimCityResidential6'

  @initialize()
  
  @unlockedAssets: -> [
    Pinball.Assets.SpinningTarget
  ]

class Goal.PlaySpinningTarget extends Goal.Task
  @id: -> "#{Goal.id()}.PlaySpinningTarget"
  @goal: -> Goal
  
  @directive: -> "Get the target spinning"
  
  @instructions: -> """
    Add a spinning target or multiple of them to your playfield.
    Set the points based on the difficulty of hitting them and play the game to rank up a lot of points.
  """
  
  @predecessors: -> [Goal.DrawSpinningTarget]

  @studyPlanBuilding: -> 'SimCityCommercial1'

  @initialize()
  
  @completedConditions: -> @playfieldHasPart Pinball.Parts.SpinningTarget
