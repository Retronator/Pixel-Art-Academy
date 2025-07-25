AB = Artificial.Base
AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Pico8.Cartridges.Invasion.DesignDocument.Choice extends AM.Component
  @id: -> "PixelArtAcademy.Pico8.Cartridges.Invasion.DesignDocument.Choice"
  @register @id()
  
  onCreated: ->
    super arguments...
    
    @designDocument = @parentComponent()
    
    @value = new ComputedField =>
      choice = @data()
      
      if choice.value
        choice.value()
        
      else if choice.property
        @designDocument.getDesignValue choice.property
      
    @manualEditing = new ReactiveField false
  
  editing: -> @manualEditing() or not @chosenText()?
  
  chosenText: ->
    choice = @data()
    value = @value()
    
    return unless option = _.find choice.options, (option) => value is option.value
    
    option.text
  
  events: ->
    super(arguments...).concat
      'click .option': @onClickOption
      'click .chosen-choice': @onClickChosenChoice
  
  onClickOption: (event) ->
    choice = @data()
    option = @currentData()
    
    if option.designValues
      for property, value of option.designValues
        @designDocument.setDesignValue property, value
    
    else if choice.property
      @designDocument.setDesignValue choice.property, option.value
    
    @manualEditing false
  
  onClickChosenChoice: (event) ->
    @manualEditing true
    
    Tracker.afterFlush =>
      @designDocument.window.scrollToElement @$('.choice')[0]
