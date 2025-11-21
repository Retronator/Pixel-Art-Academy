AE = Artificial.Everywhere
LOI = LandsOfIllusions
PAA = PixelArtAcademy
DrawQuickly = PAA.Pixeltosh.Programs.DrawQuickly

class DrawQuickly.Instructions
  class @Instruction extends PAA.PixelPad.Systems.Instructions.Instruction
    @getDrawQuickly: ->
      return unless os = PAA.PixelPad.Apps.Pixeltosh.getOS()
      program = os.activeProgram()
      return unless program instanceof DrawQuickly
      program
    
  class @RealisticModeTip extends @Instruction
    @id: -> "PixelArtAcademy.Pixeltosh.Programs.DrawQuickly.Instructions.RealisticModeTip"
    
    @message: -> """
      Try realistic drawing mode to practice any subjects you're unsure how to draw.
    """
      
    @activeConditions: ->
      return unless drawQuickly = @getDrawQuickly()
      
      # Show only on the splash screen.
      return unless game = drawQuickly.os.interface.getView DrawQuickly.Interface.Game
      return unless game.currentScreen() is DrawQuickly.Interface.Game.ScreenTypes.Splash
      
      # Show when you don't have a score, but not a 10/10 on any of the symbolic difficulties.
      symbolicDrawingData = DrawQuickly.state 'symbolicDrawing'
      
      for difficulty, difficultyProperty of DrawQuickly.SymbolicDrawing.DifficultyProperties
        anyScore = false
        bestScore = 0

        for speed, speedProperty of DrawQuickly.SymbolicDrawing.SpeedProperties
          score = symbolicDrawingData.bestScores?[difficultyProperty]?[speedProperty]
          
          if score?
            anyScore = true
            bestScore = Math.max bestScore, score
            
        return true if anyScore and bestScore < 10
        
      false
    
    @initialize()
    
    faceClass: -> PAA.Pixeltosh.Instructions.FaceClasses.Smirk
    
    customClass: -> 'pixelartacademy-pixeltosh-programs-drawquickly-instructions'
