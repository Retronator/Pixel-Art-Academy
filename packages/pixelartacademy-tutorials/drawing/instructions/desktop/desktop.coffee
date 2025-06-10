AB = Artificial.Babel
AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Tutorials.Drawing.Instructions.Desktop extends PAA.PixelPad.Systems.Instructions
  @id: -> 'PixelArtAcademy.Tutorials.Drawing.Instructions.Desktop'

  @version: -> '0.1.0'

  @register @id()
  template: -> @constructor.id()

  @fullName: -> "Desktop editor drawing instructions"
  @description: ->
    "
      System for on-demand display of information in the Drawing app with the Desktop editor.
    "

  @initialize()

  constructor: ->
    super arguments...
  
    @headerHeight = 14
    @animationDuration = 0.35
  
  interactableClass: ->
    editor = PAA.PixelPad.Apps.Drawing.Editor.getEditor()
    'interactable' unless editor?.interface.activeTool()?.isEngaged()
  
  focusedModeClass: ->
    editor = PAA.PixelPad.Apps.Drawing.Editor.getEditor()
    'focused-mode' if editor.focusedMode()
    
  instructionsStyle: ->
    switch @displayState()
      when @constructor.DisplayState.Open
        value = "calc(-#{@contentHeight()}px - #{@headerHeight}rem)"
      
      when @constructor.DisplayState.Closed
        value = "-#{@headerHeight}rem"
      
      else
        value = "#{@hideTop}rem"
    
    "#{if @displaySide() is @constructor.DisplaySide.Top then 'bottom' else 'top'}": value
