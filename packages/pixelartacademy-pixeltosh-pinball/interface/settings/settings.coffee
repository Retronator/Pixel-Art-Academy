LOI = LandsOfIllusions
PAA = PixelArtAcademy
Pinball = PAA.Pixeltosh.Programs.Pinball

class Pinball.Interface.Settings extends LOI.View
  @id: -> 'PixelArtAcademy.Pixeltosh.Programs.Pinball.Interface.Settings'
  @register @id()
  
  onCreated: ->
    super arguments...
    
    @os = @interface.parent
    @pinball = @os.getProgram Pinball
    
    @selectedPart = new ReactiveField null
    
    @autorun (computation) =>
      selectedPart = @pinball.editorManager()?.selectedPart() or @pinball.sceneManager()?.getPartOfType Pinball.Parts.Playfield
      
      # Blur the current editable input to save any edits before we render a different part.
      document.activeElement?.blur()
      
      Meteor.setTimeout =>
        @selectedPart selectedPart
      
    @settings = new ComputedField =>
      return unless selectedPart = @selectedPart()
      
      for property, setting of selectedPart.settings()
        do (property, setting) =>
          setting: setting
          load: => selectedPart.data()?[property]
          save: (value) =>
            @pinball.editorManager().updatePart selectedPart, "#{property}": value
  
  settingsDisplayed: ->
    setting = @currentData().setting
    return true unless setting.enabledCondition
    
    data = @selectedPart().data()
    setting.enabledCondition data
