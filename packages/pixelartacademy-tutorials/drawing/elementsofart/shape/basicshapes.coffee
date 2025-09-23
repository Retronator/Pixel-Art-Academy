AC = Artificial.Control
LOI = LandsOfIllusions
PAA = PixelArtAcademy

InterfaceMarking = PAA.PixelPad.Systems.Instructions.InterfaceMarking

class PAA.Tutorials.Drawing.ElementsOfArt.Shape.BasicShapes extends PAA.Tutorials.Drawing.ElementsOfArt.Shape.Asset
  @displayName: -> "Basic shapes"
  
  @description: -> """
    To start learning how to draw, you only need to be able to draw 3 basic shapes.
  """
  
  @fixedDimensions: -> width: 109, height: 46
  
  @initialize()
  
  availableToolKeys: ->
    [
      PAA.Practice.Software.Tools.ToolKeys.Eraser
      PAA.Practice.Software.Tools.ToolKeys.Zoom
      PAA.Practice.Software.Tools.ToolKeys.MoveCanvas
      PAA.Practice.Software.Tools.ToolKeys.Undo
      PAA.Practice.Software.Tools.ToolKeys.Redo
      PAA.Practice.Software.Tools.ToolKeys.Line
      PAA.Practice.Software.Tools.ToolKeys.Rectangle
      PAA.Practice.Software.Tools.ToolKeys.Ellipse
    ]
  
  Asset = @
  
  class @Ruler1 extends PAA.Tutorials.Drawing.Instructions.StepInstruction
    @id: -> "#{Asset.id()}.Ruler1"
    @assetClass: -> Asset
    
    @stepNumber: -> 1
    
    @message: -> """
      Use the ruler to draw a rectangle.
    """
    
    @activeConditions: ->
      return unless super arguments...
      
      # Show when rectangle tool is not active.
      editor = @getEditor()
      activeTool = editor.interface.activeTool()
      
      activeTool not instanceof LOI.Assets.SpriteEditor.Tools.Rectangle
    
    @initialize()
    
    markup: ->
      arrowBase = InterfaceMarking.arrowBase()
      
      [
        interface:
          selector: ".fatamorgana-toolbox .tool.rectangle"
          bounds:
            x: 10
            y: 20
            width: 20
            height: 35
          markings: [
            line: _.extend {}, arrowBase,
              points: [
                x: 25, y: 46
              ,
                x: 16, y: 26, bezierControlPoints: [
                  x: 20, y: 41
                ,
                  x: 16, y: 36
                ]
              ]
          ]
      ]
  
  class @Draw1 extends PAA.Tutorials.Drawing.Instructions.StepInstruction
    @id: -> "#{Asset.id()}.Draw1"
    @assetClass: -> Asset
    
    @stepNumber: -> 1
    
    @message: -> """
      Click and drag from a corner to start drawing.
    """
    
    @activeConditions: ->
      return unless super arguments...
      
      # Show when we're using the rectangle.
      editor = @getEditor()
      activeTool = editor.interface.activeTool()
      
      activeTool instanceof LOI.Assets.SpriteEditor.Tools.Rectangle
    
    @completedConditions: ->
      # Only show until we've tried drawing.
      editor = @getEditor()
      activeTool = editor.interface.activeTool()
      
      return unless activeTool instanceof LOI.Assets.SpriteEditor.Tools.Rectangle
      
      activeTool.drawingActive()
    
    @resetCompletedConditions: ->
      not @getActiveAsset()
    
    @initialize()
    
  class @Ruler2 extends PAA.Tutorials.Drawing.Instructions.StepInstruction
    @id: -> "#{Asset.id()}.Ruler2"
    @assetClass: -> Asset
    
    @stepNumber: -> 2
    
    @message: -> """
      Use the edge of the ruler to draw the lines of the triangle.
    """
    
    @activeConditions: ->
      return unless super arguments...
      
      # Show when rectangle tool is not active.
      editor = @getEditor()
      activeTool = editor.interface.activeTool()
      
      activeTool not instanceof LOI.Assets.SpriteEditor.Tools.Line
    
    @initialize()
    
    markup: ->
      arrowBase = InterfaceMarking.arrowBase()
      
      [
        interface:
          selector: ".fatamorgana-toolbox .tool.line"
          bounds:
            x: 0
            y: 20
            width: 20
            height: 45
          markings: [
            line: _.extend {}, arrowBase,
              points: [
                x: 15, y: 57
              ,
                x: 5, y: 38, bezierControlPoints: [
                  x: 10, y: 52
                ,
                  x: 5, y: 48
                ]
              ]
          ]
      ]
  
  class @Draw2 extends PAA.Tutorials.Drawing.Instructions.StepInstruction
    @id: -> "#{Asset.id()}.Draw2"
    @assetClass: -> Asset
    
    @stepNumber: -> 2
    
    @message: -> """
      Click and drag to draw a line.
    """
    
    @activeConditions: ->
      return unless super arguments...
      
      # Show when using the line tool.
      editor = @getEditor()
      activeTool = editor.interface.activeTool()
      
      activeTool instanceof LOI.Assets.SpriteEditor.Tools.Line
      
    @completedConditions: ->
      # Only show until we've tried drawing.
      editor = @getEditor()
      activeTool = editor.interface.activeTool()
      
      return unless activeTool instanceof LOI.Assets.SpriteEditor.Tools.Line
      
      activeTool.drawingActive()
      
    @resetCompletedConditions: ->
      not @getActiveAsset()

    @initialize()
    
  class @Ruler3 extends PAA.Tutorials.Drawing.Instructions.StepInstruction
    @id: -> "#{Asset.id()}.Ruler3"
    @assetClass: -> Asset
    
    @stepNumber: -> 3
    
    @message: -> """
      Use the ruler to draw an ellipse.
    """
    
    @activeConditions: ->
      return unless super arguments...
      
      # Show when ellipse tool is not active.
      editor = @getEditor()
      activeTool = editor.interface.activeTool()
      
      activeTool not instanceof LOI.Assets.SpriteEditor.Tools.Ellipse
    
    @initialize()
    
    markup: ->
      arrowBase = InterfaceMarking.arrowBase()
      
      [
        interface:
          selector: ".fatamorgana-toolbox .tool.ellipse"
          bounds:
            x: 10
            y: 20
            width: 20
            height: 35
          markings: [
            line: _.extend {}, arrowBase,
              points: [
                x: 25, y: 46
              ,
                x: 16, y: 26, bezierControlPoints: [
                  x: 20, y: 41
                ,
                  x: 16, y: 36
                ]
              ]
          ]
      ]
  
  class @Draw3 extends PAA.Tutorials.Drawing.Instructions.StepInstruction
    @id: -> "#{Asset.id()}.Draw3"
    @assetClass: -> Asset
    
    @stepNumber: -> 3
    
    @message: -> """
      Click and drag to start drawing.
    """
    
    @activeConditions: ->
      return unless super arguments...
      
      # Show when we're using the ellipse.
      editor = @getEditor()
      activeTool = editor.interface.activeTool()
      
      activeTool instanceof LOI.Assets.SpriteEditor.Tools.Ellipse
    
    @completedConditions: ->
      # Only show until we've tried drawing.
      editor = @getEditor()
      activeTool = editor.interface.activeTool()
      
      return unless activeTool instanceof LOI.Assets.SpriteEditor.Tools.Ellipse
      
      activeTool.drawingActive()
    
    @resetCompletedConditions: ->
      not @getActiveAsset()
    
    @initialize()

  class @Movement extends PAA.Tutorials.Drawing.Instructions.StepInstruction
    @id: -> "#{Asset.id()}.Movement"
    @assetClass: -> Asset
    
    @stepNumber: -> 3
    
    @message: -> """
      Hold space to reposition the shape.
    """
    
    @activeConditions: ->
      return unless super arguments...
      
      # Show when we're using the ellipse.
      editor = @getEditor()
      activeTool = editor.interface.activeTool()
      
      return unless activeTool instanceof LOI.Assets.SpriteEditor.Tools.Ellipse
      
      activeTool.drawingActive()
    
    @completedConditions: ->
      # Only show until we've tried moving.
      editor = @getEditor()
      activeTool = editor.interface.activeTool()
      
      return unless activeTool instanceof LOI.Assets.SpriteEditor.Tools.Ellipse
      
      activeTool.movementActive()
    
    @resetCompletedConditions: ->
      not @getActiveAsset()
    
    @initialize()

  class @Constrain extends PAA.Tutorials.Drawing.Instructions.StepInstruction
    @id: -> "#{Asset.id()}.Constrain"
    @assetClass: -> Asset
    
    @stepNumber: -> 3
    
    @message: -> """
      Hold shift to constrain it to a circle.
    """
    
    @activeConditions: ->
      return unless super arguments...
      
      # Show when we're using the ellipse.
      editor = @getEditor()
      activeTool = editor.interface.activeTool()
      
      return unless activeTool instanceof LOI.Assets.SpriteEditor.Tools.Ellipse
      return if activeTool.movementActive()
      
      activeTool.drawingActive()
    
    @completedConditions: ->
      # Only show until we've tried moving.
      editor = @getEditor()
      activeTool = editor.interface.activeTool()
      
      return unless activeTool instanceof LOI.Assets.SpriteEditor.Tools.Ellipse
      return unless activeTool.drawingActive()
      
      keyboardState = AC.Keyboard.getState()
      keyboardState.isKeyDown AC.Keys.shift
    
    @resetCompletedConditions: ->
      not @getActiveAsset()
    
    @initialize()
