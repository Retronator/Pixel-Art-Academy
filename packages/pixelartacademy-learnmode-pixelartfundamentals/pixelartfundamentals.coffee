LOI = LandsOfIllusions
LM = PixelArtAcademy.LearnMode

class LM.PixelArtFundamentals extends LOI.Adventure.Episode
  @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals'

  @fullName: -> "Pixel art fundamentals"

  @chapters: -> [
    @Fundamentals
  ]

  @scenes: -> []
  
  @startSection: -> @Start
  
  @initialize()
  
  @pinballEnabled: ->
    PAA.Learning.Task.getAdventureInstanceForId(LM.PixelArtFundamentals.Fundamentals.Goals.Jaggies.SmoothCurves.id())?.completed()

if Meteor.isServer
  LOI.initializePackage
    id: 'retronator_pixelartacademy-learnmode-pixelartfundamentals'
    assets: Assets
