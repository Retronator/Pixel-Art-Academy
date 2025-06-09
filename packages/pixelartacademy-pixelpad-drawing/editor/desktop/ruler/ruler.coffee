AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy
FM = FataMorgana

class PAA.PixelPad.Apps.Drawing.Editor.Desktop.Ruler extends FM.View
  @id: -> 'PixelArtAcademy.PixelPad.Apps.Drawing.Editor.Desktop.Ruler'
  @register @id()
  
  onCreated: ->
    super arguments...
    
    @desktop = @interface.ancestorComponentOfType PAA.PixelPad.Apps.Drawing.Editor.Desktop
    
    activateAudio = (filled) =>
      if filled
        @desktop.audio.rulerActivateFilled()
      
      else
        @desktop.audio.rulerActivate()
  
    Tracker.triggerOnDefinedChange =>
      @interface.getOperator(LOI.Assets.SpriteEditor.Tools.Rectangle).data.get 'filled'
    ,
      activateAudio
    
    Tracker.triggerOnDefinedChange =>
      @interface.getOperator(LOI.Assets.SpriteEditor.Tools.Ellipse).data.get 'filled'
    ,
      activateAudio

  rectangleFilledClass: ->
    rectangle = @interface.getOperator LOI.Assets.SpriteEditor.Tools.Rectangle
    'filled' if rectangle.data.get 'filled'
    
  ellipseFilledClass: ->
    ellipse = @interface.getOperator LOI.Assets.SpriteEditor.Tools.Ellipse
    'filled' if ellipse.data.get 'filled'
