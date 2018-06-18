AB = Artificial.Babel
AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.PixelBoy.Apps.Pico8.Drawer extends AM.Component
  @id: -> 'PixelArtAcademy.PixelBoy.Apps.Pico8.Drawer'
  @register @id()

  constructor: (@pico8) ->
    super

    @opened = new ReactiveField false

  onRendered: ->
    super

    # Open the drawer on app launch.
    Meteor.setTimeout =>
      @opened true
    ,
      500

  openedClass: ->
    'opened' if @opened()
