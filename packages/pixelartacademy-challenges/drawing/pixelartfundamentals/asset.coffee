AE = Artificial.Everywhere
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Challenges.Drawing.PixelFundamentals.EvenDiagonals extends PAA.Practice.Tutorials.Drawing.Assets.TutorialBitmap
  @criterion: -> throw new AE.NotImplementedException "You must provide which pixel art grading criterion this challenge unlocks."
  
  constructor: ->
    super arguments...
    
    # Listen to the completed change to determine if enabling even diagonals criterion can be granted.
    @_completedAutorun = Tracker.autorun =>
      completed = @completed()
      
      Tracker.nonreactive =>
        Bitmap = PAA.Practice.Project.Asset.Bitmap
        criterion = @constructor.criterion()
        
        unlockedPixelArtGradingCriteria = Bitmap.state('unlockedPixelArtGradingCriteria') or []
        
        return if completed and criterion in unlockedPixelArtGradingCriteria
        return unless completed or criterion in unlockedPixelArtGradingCriteria
        
        if completed
          unlockedPixelArtGradingCriteria.push criterion
        
        else
          _.pull unlockedPixelArtGradingCriteria, criterion
        
        Bitmap.state 'unlockedPixelArtGradingCriteria', unlockedPixelArtGradingCriteria
  
  destroy: ->
    super arguments...
    
    @_completedAutorun.stop()
    
  class @EnableGrading extends PAA.PixelPad.Systems.Instructions.Instruction
    @criterion: -> throw new AE.NotImplementedException "You must provide which pixel art grading criterion this challenge unlocks."

    @activeDisplayState: ->
      # We only want a pop-up without a normal instruction message.
      PAA.PixelPad.Systems.Instructions.DisplayState.Hidden
    
    @activeConditions: ->
      return unless asset = @getActiveAsset()
      
      # Show when the asset is completed.
      asset.completed()
    
    @initialize()
    
    onActivate: ->
      super arguments...
      
      criterion = Asset.criterion()
      criterionName = PAA.PixelPad.Apps.Drawing.Editor.Desktop.PixelArtGrading.Overview.CriteriaNames[criterion]
      
      dialog = new LOI.Components.Dialog
        message: """
            Well done! You now have access to grading #{_.toLower criterionName} in previous pixel art tutorials.
            Do you want to automatically turn it on for relevant lessons?
          """
        moreInfo: "You can come back to this challenge to enable it at a later point."
        buttons: [
          text: "Yes"
          value: true
        ,
          text: "No"
        ]
      
      LOI.adventure.showActivatableModalDialog
        dialog: dialog
        callback: =>
          return unless dialog.result

          PAA.Tutorials.Drawing.PixelArtFundamentals.enablePixelArtGrading criterion
    
