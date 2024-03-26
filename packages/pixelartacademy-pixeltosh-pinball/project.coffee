AE = Artificial.Everywhere
AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy
Pinball = PAA.Pixeltosh.Programs.Pinball

class Pinball.Project extends PAA.Practice.Project.Thing
  # activeProjectId: ID of the project that is currently active
  
  # Project document fields
  # playfield: an object with all the pinball parts on the playfield
  #   {playfieldPartId}: a random ID of this part instance
  #     type: the thing id of the pinball part
  #     position: the position of the part on the playfield in meters, (0, 0) is top-left
  #       x, y
  #     rotationAngle: the angle
  #     flipped: boolean whether the part mesh should be mirrored horizontally
  #     ...
  @id: -> 'PixelArtAcademy.Pixeltosh.Programs.Pinball'
  
  @fullName: -> "Pinball"

  @iconUrl: -> @versionedUrl "/pixelartacademy/pixeltosh/programs/pinball/icon-project.png"
  @program: -> Pinball

  @initialize()

  constructor: ->
    super arguments...

    @assets = new ComputedField =>
      [
        new Pinball.Assets.Ball @
        new Pinball.Assets.Playfield @
      ]
    ,
      true

  destroy: ->
    @assets.stop()
    
  content: ->
    return unless chapter = LOI.adventure.getCurrentChapter PAA.LearnMode.PixelArtFundamentals.Fundamentals
    chapter.getContent PAA.LearnMode.PixelArtFundamentals.Fundamentals.Content.Projects.PinballCreationKit
