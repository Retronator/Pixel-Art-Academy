LOI = LandsOfIllusions
LM = PixelArtAcademy.LearnMode

class LM.Intro extends LOI.Adventure.Episode
  @id: -> 'PixelArtAcademy.LearnMode.Intro'

  @fullName: -> "Learn Mode introduction"

  @chapters: -> [
    @Tutorial
  ]

  @scenes: -> [
    @PixelBoy
    @Apps
    @Editors
    @DrawingChallenges
  ]
  
  @startSection: -> @Start
  
  @initialize()

if Meteor.isServer
  LOI.initializePackage
    id: 'retronator_pixelartacademy-learnmode-intro'
    assets: Assets
