AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy
FM = FataMorgana

class PAA.PixelBoy.Apps.Drawing.Editor.Easel.Frame extends FM.View
  @id: -> 'PixelArtAcademy.PixelBoy.Apps.Drawing.Editor.Easel.Frame'
  @register @id()
  
  @template: -> @constructor.id()
  
  onCreated: ->
    super arguments...

    @easel = @interface.ancestorComponentOfType PAA.PixelBoy.Apps.Drawing.Editor.Easel
  
    # Reactively add tools and actions.
    toolRequirements =
      "#{LOI.Assets.SpriteEditor.Tools.Pencil.id()}": PAA.Practice.Software.Tools.ToolKeys.Pencil
      "#{LOI.Assets.SpriteEditor.Tools.Eraser.id()}": PAA.Practice.Software.Tools.ToolKeys.Eraser
      "#{LOI.Assets.SpriteEditor.Tools.ColorFill.id()}": PAA.Practice.Software.Tools.ToolKeys.ColorFill
      "#{LOI.Assets.SpriteEditor.Tools.ColorPicker.id()}": PAA.Practice.Software.Tools.ToolKeys.ColorPicker
  
    @autorun (computation) =>
      tools = [
        LOI.Assets.Editor.Tools.Arrow.id()
      ]
    
      tools.push toolId for toolId, toolKey of toolRequirements when @easel.toolIsAvailable toolKey
    
      Tracker.nonreactive =>
        frameData = @data()
        frameData.set "toolbox.tools", tools

  toolboxData:  ->
    frameData = @data()
    frameData.child "toolbox"
