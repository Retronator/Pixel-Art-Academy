LOI = LandsOfIllusions
LM = PixelArtAcademy.LearnMode

class LM.Design extends LOI.Adventure.Episode
  # unlocked: boolean whether this episode's content is instantly available
  @id: -> 'PixelArtAcademy.LearnMode.Design'

  @fullName: -> "Design"

  @chapters: -> [
    @Fundamentals
  ]

  @startSection: -> @Start
  
  @initialize()
  
if Meteor.isServer
  LOI.initializePackage
    id: 'retronator_pixelartacademy-learnmode-design'
    assets: Assets
