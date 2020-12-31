AM = Artificial.Mirage
LOI = LandsOfIllusions

class LOI.Pages.Loading extends AM.Component
  @register 'LandsOfIllusions.Pages.Loading'

  onCreated: ->
    super arguments...

    # Create pixel scaling display.
    @display = new AM.Display
      safeAreaWidth: 320
      safeAreaHeight: 240
      minScale: 2

  onRendered: ->
    super arguments...

    Meteor.setTimeout =>
      return unless @isRendered()
      @$('.loading').addClass 'visible'
    ,
      1000
