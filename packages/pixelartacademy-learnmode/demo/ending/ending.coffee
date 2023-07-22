AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy
LM = PixelArtAcademy.LearnMode

class LM.Demo.Ending extends AM.Component
  @register 'PixelArtAcademy.LearnMode.Demo.Ending'
  
  mixins: -> [@activatable]
  
  constructor: (@options) ->
    super arguments...

    @activatable = new LOI.Components.Mixins.Activatable()
    
  onDeactivate: (finishedDeactivatingCallback) ->
    Meteor.setTimeout =>
      finishedDeactivatingCallback()
    ,
      500
