class PixelArtAcademy.LearnMode extends LOI.Adventure.Region
  @id: -> 'PixelArtAcademy.LearnMode'
  @debug = false
  
  @initialize()
  
  @scenes: -> [
  ]

  constructor: ->
    super arguments...
  
    # Create the learn-mode url capture.
    Retronator.App.addPublicPage 'pixelart.academy/learn-mode/:parameter1?/:parameter2?/:parameter3?/:parameter4?/:parameter5?', @constructor.Adventure
    
if Meteor.isServer
  LOI.initializePackage
    id: 'retronator:pixelartacademy-learnmode'
    assets: Assets
