LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Tutorials.Drawing.PixelArtTools.Helpers.Zoom extends PAA.Practice.Tutorials.Drawing.Assets.TutorialBitmap
  @id: -> 'PixelArtAcademy.Tutorials.Drawing.PixelArtTools.Helpers.Zoom'

  @displayName: -> "Zoom"

  @description: -> """
      Working on bigger images requires you to zoom in and out to make drawing easier.

      Shortcuts: Mouse scroll or Cmd/ctrl with +/-
    """

  @fixedDimensions: -> width: 64, height: 40
  @restrictedPaletteName: -> LOI.Assets.Palette.SystemPaletteNames.black

  @bitmapString: -> """
      |                    0000
      |                   000 000 0 000000000000000000
      |                 000 00 0000000000000    00000000
      |      00000     00000000 0     00  0    0 0    000    00000
      |     0    00   0 000000 00  0      0    0  0    0 0  00    0
      |     0    00000 0 000000 0  00000000 0     0     0 0000    0
      |      0000000 000 000 0 00        0 0    0 0     0000000000
      |             00    000000         0 0    0  0     0 0
      |             00    000000         00  0  00 0     00 0
      |            00      0 00           0  0  000       00 0
      |           0000 0000000000000       000000        000000
      |         00  0 0 0000000000  00 0 00 0000 00  000000 0 000
      |       00     0  00000000000  00 0  0    0  00 0 0      0 0
      |    000    0 0000             00000000000000000 0 0    0 0 0
      |  00    0 0 0000 0 0 0 0 0 0 0 0 0 0 0 0 000000  0 0        00
      | 0   0 0 0 0000000000000000000000000000000000000  0 0 0 0     0
      |0       0 0                                                    0
      |0  0 0 0 0 0   0 0     0               0 0 0   0 0 0 0 0 0 0 0 0
      |0 0 0 0 0 0 0 0 0 0 0 0                 0 0 0 0 0 0 0 0 0 0 0000
      |000000000000000000000000               000000000000000000000000
      |  0 0 0 0    00000000000               000000000000    0 0 0 000
      |  00 0 00    00000000000               000000000000    00 0 0 00
      | 00000000000000000000000               0000000000000000000000000
      | 00 0 0 0 0 000000000000               0000000000000 0 0 0 0 0 0
      | 00000000000000000000000               0000000000000000000000000
      |0                     0                                       00
      |0    0 0 0 0 0 0 0 0 0 0               0 0 0 0 0 0 0 0 0 0 0 0 0
      |0 0           0 0 0 0 00               00 0 0 0 0 0 0 0 0 0 0 00
      |00 0 0 0 0 0   0   0 0 0               0 0 0     0     0 0 0 0 0
      |0       0 0 0000 0000000               000000 0000 00 0000000000
      |00 0 0 0 0  000000000000               000000000000000 0 0 0 0 0
      | 0  0 0 0 00000000000000               0000000000000000000000000
      | 0 0 0 0 0 00000000000000000000000000000000000000000 0 0 0 0 00
      | 00 0 000000000000000000000000000000000000000000000000000000000
      | 00000 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 000000
      | 00000000000000000000000000000000000000000000000000000000000000
      | 00 00000000000000000000000000000000000000000000000000000000000
      | 0 00000000000  00000000000000000000000000000000 00000000000000
      | 00 0 00000000                                   00000000000000
      |  00000000000                                     000000000000
    """

  @goalBitmapString: -> """
      |                    0000
      |                   000 000 0 000000000000000000
      |                 000 00 0000000000000    00000000
      |      00000     00000000 0     00  0    0 0    000    00000
      |     0    00   0 000000 00  0      0    0  0    0 0  00    0
      |     0    00000 0 000000 0  00000000 0     0     0 0000    0
      |      0000000 000 000 0 00        0 0    0 0     0000000000
      |             00    000000         0 0    0  0     0 0
      |             00    000000         00  0  00 0     00 0
      |            00      0 00           0  0  000       00 0
      |           0000 0000000000000       000000        000000
      |         00  0 0 0000000000  00 0 00 0000 00  000000 0 000
      |       00     0  00000000000  00 0  0    0  00 0 0      0 0
      |    000    0 0000             00000000000000000 0 0    0 0 0
      |  00    0 0 0000 0 0 0 0 0 0 0 0 0 0 0 0 000000  0 0        00
      | 0   0 0 0 0000000000000000000000000000000000000  0 0 0 0     0
      |0       0 0                                                    0
      |0  0 0 0 0 0   0 0     0   0 0 0 0 0 0 0 0 0   0 0 0 0 0 0 0 0 0
      |0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 000 0 0 0 0 0 0 0 0 0 0 0 0 0 0000
      |000000000000000000000000000000  0000000000000000000000000000000
      |  0 0 0 0    0000000000000000 0  000000000000000000    0 0 0 000
      |  00 0 00    000000000000000000 0000000000000000000    00 0 0 00
      | 0000000000000000000000000000    0 00000000000000000000000000000
      | 00 0 0 0 0 00000000000000000 0   000000000000000000 0 0 0 0 0 0
      | 00000000000000000000000000000 0 0000000000000000000000000000000
      |0                     0   0   0 000   0                       00
      |0    0 0 0 0 0 0 0 0 0 00000000000000000 0 0 0 0 0 0 0 0 0 0 0 0
      |0 0           0 0 0 0 00  0  0  0 0    00 0 0 0 0 0 0 0 0 0 0 00
      |00 0 0 0 0 0   0   0 0 0    0    0 0   0 0 0     0     0 0 0 0 0
      |0       0 0 0000 0000000  0      0     000000 0000 00 0000000000
      |00 0 0 0 0  000000000000   0 00  0 0   000000000000000 0 0 0 0 0
      | 0  0 0 0 00000000000000               0000000000000000000000000
      | 0 0 0 0 0 00000000000000000000000000000000000000000 0 0 0 0 00
      | 00 0 000000000000000000000000000000000000000000000000000000000
      | 00000 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 000000
      | 00000000000000000000000000000000000000000000000000000000000000
      | 00 00000000000000000000000000000000000000000000000000000000000
      | 0 00000000000  00000000000000000000000000000000 00000000000000
      | 00 0 00000000                                   00000000000000
      |  00000000000                                     000000000000
    """

  @bitmapInfo: -> "Artwork from Out Run (ZX Spectrum), Probe Software, 1987"

  availableToolKeys: -> [
    PAA.Practice.Software.Tools.ToolKeys.Pencil
    PAA.Practice.Software.Tools.ToolKeys.Eraser
    PAA.Practice.Software.Tools.ToolKeys.ColorFill
    PAA.Practice.Software.Tools.ToolKeys.Zoom
    PAA.Practice.Software.Tools.ToolKeys.MoveCanvas
  ]

  @initialize()
  
  Asset = @
  
  class @Instruction extends PAA.Tutorials.Drawing.Instructions.Instruction
    @id: -> "#{Asset.id()}.Instruction"
    @assetClass: -> Asset
    
    @message: -> """
      Use the plus and minus buttons on the calculator to zoom in and out.

      Shortcuts: Mouse scroll or Cmd/ctrl with +/-
    """
    
    @activeConditions: ->
      return unless asset = @getActiveAsset()
      not asset.completed()
  
    @initialize()
  
    onActivate: ->
      super arguments...
    
      drawingEditor = @getEditor()
      pixelCanvasEditor = drawingEditor.interface.getEditorForActiveFile()
      @_initialScale = pixelCanvasEditor.camera().scale()
  
    completedConditions: ->
      drawingEditor = @getEditor()
      pixelCanvasEditor = drawingEditor.interface.getEditorForActiveFile()
      @_initialScale isnt pixelCanvasEditor.camera().scale()
