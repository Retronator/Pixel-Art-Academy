AM = Artificial.Mirage
PAA = PixelArtAcademy

class PAA.PixelBoy.App extends AM.Component

  displayName: ->
    throw new Meteor.Error 'unimplemented', "You must specify app's display name."

  urlName: ->
    throw new Meteor.Error 'unimplemented', "You must specify app's url name."
