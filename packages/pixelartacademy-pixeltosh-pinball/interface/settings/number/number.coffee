AE = Artificial.Everywhere
AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy
Pinball = PAA.Pixeltosh.Programs.Pinball

class Pinball.Interface.Settings.Number extends AM.Component
  @id: -> 'PixelArtAcademy.Pixeltosh.Programs.Pinball.Interface.Settings.Number'
  @register @id()
  
  onCreated: ->
    super arguments...
    
    settingOptions = @data()
    @input = new @constructor.Input settingOptions
    
  unit: ->
    settingOptions = @data()
    settingOptions.setting.unit

  class @Input extends AM.DataInputComponent
    constructor: (@settingOptions) ->
      super arguments...
      
      @realtime = false
      @type = AM.DataInputComponent.Types.Number
      @setting = @settingOptions.setting

      @customAttributes = {}
      for property in ['min', 'max', 'step']
        @customAttributes[property] = @setting[property] if @setting[property]?

      @placeholder = @setting.default

    load: ->
      @settingOptions.load()
      
    save: (value) ->
      value = null if _.isNaN value
      
      @settingOptions.save value
