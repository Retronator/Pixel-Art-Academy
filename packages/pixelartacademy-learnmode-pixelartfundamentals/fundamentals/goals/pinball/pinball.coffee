AE = Artificial.Everywhere
LOI = LandsOfIllusions
PAA = PixelArtAcademy
LM = PixelArtAcademy.LearnMode

class LM.PixelArtFundamentals.Fundamentals.Goals.Pinball extends PAA.Learning.Goal
  @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Goals.Pinball'

  @displayName: -> "Pinball"

  @chapter: -> LM.PixelArtFundamentals.Fundamentals

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
    @ActiveBumpers
    @DrawUpperThird
    @DrawSpinningTarget
    @PlaySpinningTarget
  ]

  @finalTasks: -> [
    @PlaySpinningTarget
  ]

  @initialize()
  
  reset: ->
    super arguments...
    
    PAA.Pixeltosh.Programs.Pinball.Project.end()

  Goal = @
  
  class @Task extends PAA.Learning.Task.Automatic
    @playfieldHasPart: (partClass) ->
      return unless activeProjectId = PAA.Pixeltosh.Programs.Pinball.Project.state 'activeProjectId'
      return unless project = PAA.Practice.Project.documents.findOne activeProjectId
      
      for playfieldPartId, partData of project.playfield
        return true if partData.type is partClass.id()
      
      false
    
    activeNotificationId: -> Goal.WIPNotification.id()

  class @RedrawPlayfieldTask extends @Task
    onActive: ->
      # Note: 'return unless' should not be necessary at this point, but since of legacy bugs some assets
      # might be missing and won't be fixed until the pinball machine is opened on the Pixeltosh.
      return unless activeProjectId = PAA.Pixeltosh.Programs.Pinball.Project.state 'activeProjectId'
      return unless project = PAA.Practice.Project.documents.findOne activeProjectId
      
      return unless asset = _.find project.assets, (asset) => asset.id is PAA.Pixeltosh.Programs.Pinball.Assets.Playfield.id()
      return unless bitmap = LOI.Assets.Bitmap.documents.findOne asset.bitmapId
      
      @_historyPositionOnActive = bitmap.historyPosition
      
    completedConditions: ->
      return unless activeProjectId = PAA.Pixeltosh.Programs.Pinball.Project.state 'activeProjectId'
      return unless project = PAA.Practice.Project.documents.findOne activeProjectId
      
      return unless asset = _.find project.assets, (asset) => asset.id is PAA.Pixeltosh.Programs.Pinball.Assets.Playfield.id()
      return unless bitmap = LOI.Assets.Bitmap.documents.findOne asset.bitmapId
      
      # Wait until the history position has changed.
      bitmap.historyPosition isnt @_historyPositionOnActive
  
  class @WIPNotification extends PAA.PixelPad.Systems.Notifications.Notification
    @id: -> "#{Goal.id()}.WIPNotification"
    
    @message: -> """
      The Pinball project still has many rough edges. I'll do my best to fix any breaking bugs you encounter.

      I wish I had time to put in better instructions and more playfield parts as well. Let me know if you'd like that too!
    """
    
    @displayStyle: -> @DisplayStyles.IfIdle
    
    @retroClasses: ->
      head: PAA.PixelPad.Systems.Notifications.Retro.HeadClasses.HardHat
      body: PAA.PixelPad.Systems.Notifications.Retro.BodyClasses.Wrench
    
    @retroClassesDisplayed: ->
      head: PAA.PixelPad.Systems.Notifications.Retro.HeadClasses.HardHatPuffed
      face: PAA.PixelPad.Systems.Notifications.Retro.FaceClasses.Yikes
    
    @initialize()
