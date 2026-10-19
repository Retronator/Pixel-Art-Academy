AE = Artificial.Everywhere
AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy
Pinball = PAA.Pixeltosh.Programs.Pinball

class Pinball.Project extends PAA.Practice.Project.Thing
  # Project document fields
  # playfield: an object with all the pinball parts on the playfield
  #   {playfieldPartId}: a random ID of this part instance
  #     type: the thing id of the pinball part
  #     position: the position of the part on the playfield in meters, (0, 0) is top-left
  #       x, y
  #     rotationAngle: the angle
  #     flipped: boolean whether the part mesh should be mirrored horizontally
  #     ...
  @id: -> 'PixelArtAcademy.Pixeltosh.Programs.Pinball.Project'
  
  @fullName: -> "Pinball"

  @iconUrl: -> @versionedUrl "/pixelartacademy/pixeltosh/programs/pinball/icon-project.png"
  @program: -> Pinball

  @assetsProviderClass: -> @AssetsProvider

  @visible: -> PAA.LearnMode.PixelArtFundamentals.Fundamentals.Goals.Pinball.OpenPinballMachine.completed()

  @editable: -> PAA.LearnMode.PixelArtFundamentals.Fundamentals.Goals.Pinball.PlayGate.completed()

  content: ->
    return unless chapter = LOI.adventure.getCurrentChapter PAA.LearnMode.PixelArtFundamentals.Fundamentals
    chapter.getContent PAA.LearnMode.PixelArtFundamentals.Fundamentals.Content.Projects.Pinball
