AE = Artificial.Everywhere
AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy
Pinball = PAA.Pixeltosh.Programs.Pinball

class Pinball.Interface.Settings.Boolean extends AM.Component
  @id: -> 'PixelArtAcademy.Pixeltosh.Programs.Pinball.Interface.Settings.Boolean'
  @register @id()
  
  onCreated: ->
    super arguments...
    
    settingOptions = @data()
    @input = new @constructor.Input settingOptions

  class @Input extends AM.DataInputComponent
    constructor: (@settingOptions) ->
      super arguments...
      
      @type = AM.DataInputComponent.Types.Checkbox

    load: ->
      @settingOptions.load()
      
    save: (value) ->
      value = null if _.isNaN value
      
      @settingOptions.save value
