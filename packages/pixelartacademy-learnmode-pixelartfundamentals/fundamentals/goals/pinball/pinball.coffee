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
      activeProjectId = PAA.Pixeltosh.Programs.Pinball.Project.state 'activeProjectId'
      project = PAA.Practice.Project.documents.findOne activeProjectId
      
      asset = _.find project.assets, (asset) => asset.id is PAA.Pixeltosh.Programs.Pinball.Assets.Playfield.id()
      bitmap = LOI.Assets.Bitmap.documents.findOne asset.bitmapId
      
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
      The Pinball project is still a work in progress. I plan to add better instructions and the editor has many rough edges.

      I wish I had time to put in more playfield parts as well, but at least I hope to fix major bugs before the Early Access release.
    """
    
    @displayStyle: -> @DisplayStyles.IfIdle
    
    @initialize()
