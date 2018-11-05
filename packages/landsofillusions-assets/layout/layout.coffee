AM = Artificial.Mirage
LOI = LandsOfIllusions

class LOI.Assets.Layout extends BlazeComponent
  @register 'LandsOfIllusions.Assets.Layout'

  @image: (parameters) ->
    # TODO: Add image thumbnail.

  onCreated: ->
    super arguments...

    @display = new AM.Display
      minScale: 2
      maxScale: 2

  loading: ->
    Meteor.loggingIn()
