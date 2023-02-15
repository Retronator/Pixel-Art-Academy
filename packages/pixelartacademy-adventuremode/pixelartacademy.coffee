AT = Artificial.Telepathy
AB = Artificial.Base
LOI = LandsOfIllusions

class PixelArtAcademy extends PixelArtAcademy
  constructor: ->
    super arguments...
    
    # Create the main adventure engine url capture.
    Retronator.App.addPublicPage 'pixelart.academy/:parameter1?/:parameter2?/:parameter3?/:parameter4?/:parameter5?', @constructor.Adventure

  @TimelineIds:
    # Dream sequence from the intro episode.
    DareToDream: 'DareToDream'

if Meteor.isServer
  LOI.initializePackage
    id: 'retronator_pixelartacademy-adventuremode'
    assets: Assets

  # Export assets in the pixelartacademy folder.
  LOI.Assets.addToExport 'pixelartacademy'
