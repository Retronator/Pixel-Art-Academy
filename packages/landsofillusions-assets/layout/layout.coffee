AM = Artificial.Mirage
LOI = LandsOfIllusions

class LOI.Assets.Layout extends BlazeComponent
  @register 'LandsOfIllusions.Assets.Layout'

  @image: (parameters) ->
    # TODO: Add image thumbnail.

  onCreated: ->
    super arguments...

    @display = new AM.Display
      safeAreaWidth: 350
      safeAreaHeight: 350
      minScale: 2

  loading: ->
    Meteor.loggingIn()
