LOI = LandsOfIllusions

class PixelArtAcademy.LearnMode
  @debug = false

  constructor: ->
    # Create the learn-mode url capture.
    Retronator.App.addPublicPage 'pixelart.academy/learn-mode/:parameter1?/:parameter2?/:parameter3?/:parameter4?/:parameter5?', @constructor.Adventure

if Meteor.isServer
  LOI.initializePackage
    id: 'retronator:pixelartacademy-learnmode'
    assets: Assets
  
  # Export assets in the pixelartacademy folder.
  LOI.Assets.addToExport 'pixelartacademy'

if Meteor.isClient
  window.LM = PixelArtAcademy.LearnMode
