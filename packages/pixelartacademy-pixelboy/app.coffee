AM = Artificial.Mirage
LOI = LandsOfIllusions

class LOI.PixelBoy.App extends AM.Component

  displayName: ->
    throw new Meteor.Error 'unimplemented', "You must specify app's display name."

  urlName: ->
    throw new Meteor.Error 'unimplemented', "You must specify app's url name."
