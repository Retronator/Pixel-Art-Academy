LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Tutorials.Drawing.PixelArtTools.Helpers.Lines extends PAA.Practice.Tutorials.Drawing.Assets.TutorialBitmap
  @id: -> 'PixelArtAcademy.Tutorials.Drawing.PixelArtTools.Helpers.Lines'

  @displayName: -> "Lines"

  @description: -> """
      Learn how to quickly draw lines with the pencil tool.
    """

  @fixedDimensions: -> width: 57, height: 32
  @restrictedPaletteName: -> LOI.Assets.Palette.SystemPaletteNames.black
  
  @imageUrl: ->
    "/pixelartacademy/tutorials/drawing/pixelarttools/helpers/720.png"
    
  @goalImageUrl: ->
    "/pixelartacademy/tutorials/drawing/pixelarttools/helpers/720-goal.png"

  @bitmapInfo: -> "Artwork from 720° (ZX Spectrum), Atari, 1987"

  @initialize()

  availableToolKeys: -> [
    PAA.Practice.Software.Tools.ToolKeys.Pencil
    PAA.Practice.Software.Tools.ToolKeys.Eraser
    PAA.Practice.Software.Tools.ToolKeys.Zoom
    PAA.Practice.Software.Tools.ToolKeys.MoveCanvas
  ]
  
  Asset = @
  
  class @Tool extends PAA.Tutorials.Drawing.Instructions.Instruction
    @id: -> "#{Asset.id()}.Tool"
    @assetClass: -> Asset
    
    @message: -> """
        Select the pencil to start drawing as usual.
      """

    @activeConditions: ->
      return unless asset = @getActiveAsset()
      not asset.completed()
      
    @completedConditions: ->
      editor = @getEditor()
      editor.interface.activeToolId() is LOI.Assets.SpriteEditor.Tools.Pencil.id()
    
    @resetCompletedCondition: ->
      not @getActiveAsset()
    
    @initialize()
  
  class @LineStart extends PAA.Tutorials.Drawing.Instructions.Instruction
    @id: -> "#{Asset.id()}.LineStart"
    @assetClass: -> Asset
  
    @message: -> """
        Click on a pixel where the line should start.
      """

    @activeConditions: ->
      return unless asset = @getActiveAsset()
      return if asset.completed()
      
      # Show when the pencil tool doesn't have a last pixel coordinate.
      editor = @getEditor()
      tool = editor.interface.activeTool()
      return unless tool instanceof LOI.Assets.SpriteEditor.Tools.Pencil
      pencil = tool
      
      not pencil.lastPixelCoordinates()
      
    @initialize()
  
  class @Error extends PAA.Tutorials.Drawing.Instructions.Instruction
    @id: -> "#{Asset.id()}.Error"
    @assetClass: -> Asset
  
    @message: -> """
        Release the mouse button to mark this point as the start of the line.
      """
  
    @activeConditions: ->
      return unless asset = @getActiveAsset()
      return if asset.completed()
    
      # Show when the pencil tool doesn't have a last pixel coordinate.
      editor = @getEditor()
      tool = editor.interface.activeTool()
      return unless tool instanceof LOI.Assets.SpriteEditor.Tools.Pencil
      pencil = tool
    
      pencil.lastStrokeCoordinates()
      
    @delayDuration: -> 0.5
    
    @priority: -> 1
  
    @initialize()
    
  class @LineDraw extends PAA.Tutorials.Drawing.Instructions.Instruction
    @id: -> "#{Asset.id()}.LineDraw"
    @assetClass: -> Asset
    
    @message: -> """
        Move to the end pixel and hold the shift key to make a line preview appear.
      """
    
    @activeConditions: ->
      return unless asset = @getActiveAsset()
      return if asset.completed()
  
      # Show when the pencil tool isn't drawing a line.
      editor = @getEditor()
      tool = editor.interface.activeTool()
      return unless tool instanceof LOI.Assets.SpriteEditor.Tools.Pencil
      pencil = tool

      not pencil.drawLine()

    @initialize()
    
    completedConditions: ->
      # Don't show this instruction after the first line was placed.
      @instructions.getInstruction(Asset.LineEnd).completed()
    
  class @LineEnd extends PAA.Tutorials.Drawing.Instructions.Instruction
    @id: -> "#{Asset.id()}.LineEnd"
    @assetClass: -> Asset
    
    @message: -> """
        Click on the end pixel to place down the line.
      """
    
    @activeConditions: ->
      return unless asset = @getActiveAsset()
      return if asset.completed()
      
      # Show when the pencil tool is drawing a line.
      editor = @getEditor()
      tool = editor.interface.activeTool()
      return unless tool instanceof LOI.Assets.SpriteEditor.Tools.Pencil
      pencil = tool
      
      pencil.drawLine()
    
    @initialize()
    
    onActivate: ->
      super arguments...
  
      asset = @getActiveAsset()
      bitmap = asset.bitmap()
    
      @_historyPosition = bitmap.historyPosition
  
    completedConditions: ->
      return unless @activeConditions()
      
      # Wait until the action was made.
      asset = @getActiveAsset()
      bitmap = asset.bitmap()
      bitmap.historyPosition > @_historyPosition
  
  class @LineSequence extends PAA.Tutorials.Drawing.Instructions.Instruction
    @id: -> "#{Asset.id()}.LineSequence"
    @assetClass: -> Asset
    
    @message: -> """
        You can keep holding the shift key to connect multiple lines in a row.
      """
    
    @activeConditions: ->
      return unless asset = @getActiveAsset()
      return if asset.completed()
      
      # Show when the pencil tool is drawing a line.
      editor = @getEditor()
      tool = editor.interface.activeTool()
      return unless tool instanceof LOI.Assets.SpriteEditor.Tools.Pencil
      pencil = tool
      
      pencil.drawLine()

    @priority: -> -1
    
    @initialize()
    
    onActivate: ->
      super arguments...
      
      asset = @getActiveAsset()
      bitmap = asset.bitmap()
      
      @_historyPosition = bitmap.historyPosition
    
    completedConditions: ->
      return unless @activeConditions()
      
      # Wait until two consecutive pencil draw line actions were made.
      asset = @getActiveAsset()
      bitmap = asset.bitmap()
      bitmap.historyPosition is @_historyPosition + 2