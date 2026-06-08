AE = Artificial.Everywhere
AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy
Chess = PAA.Pixeltosh.Programs.Chess

class Chess.Project.TwoDimensional extends Chess.Project
  # activeProjectId: ID of the project that is currently active
  @id: -> 'PixelArtAcademy.Pixeltosh.Programs.Chess.Project.TwoDimensional'
  
  @fullName: -> "Chess 2D"
  
  @initialize()

  content: ->
    return unless chapter = LOI.adventure.getCurrentChapter PAA.LearnMode.PixelArtFundamentals.Fundamentals
    chapter.getContent PAA.LearnMode.PixelArtFundamentals.Fundamentals.Content.Projects.Chess.TwoDimensional

class Chess.Project.ThreeDimensional extends Chess.Project
  # activeProjectId: ID of the project that is currently active
  @id: -> 'PixelArtAcademy.Pixeltosh.Programs.Chess.Project.ThreeDimensional'
  
  @fullName: -> "Chess 3D"
  
  @initialize()

  content: ->
    return unless chapter = LOI.adventure.getCurrentChapter PAA.LearnMode.PixelArtFundamentals.Fundamentals
    chapter.getContent PAA.LearnMode.PixelArtFundamentals.Fundamentals.Content.Projects.Chess.ThreeDimensional
