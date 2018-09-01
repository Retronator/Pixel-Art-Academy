AE = Artificial.Everywhere
LOI = LandsOfIllusions
PAA = PixelArtAcademy
C1 = PixelArtAcademy.Season1.Episode1.Chapter1

class C1.Challenges.Drawing.PixelArtSoftware.CopyReference extends PAA.Practice.Challenges.Drawing.TutorialSprite
  @displayName: -> "Copy the reference"

  @description: -> """
      Use the editor or software of your choice to recreate the provided reference.
    """

  @bitmap: -> "" # Empty sprite

  @goalImageUrl: -> "/pixelartacademy/season1/episode1/chapter1/challenges/drawing/pixelartsoftware/#{@imageName()}.png"

  @imageName: -> throw new AE.NotImplementedException "You must provide the image name for the asset."

  @references: -> [
    image:
      url: "/pixelartacademy/season1/episode1/chapter1/challenges/drawing/pixelartsoftware/#{@imageName()}-reference.png"
    displayOptions:
      imageOnly: true
  ]

  @customPaletteImageUrl: ->
    return null if @restrictedPaletteName()

    "/pixelartacademy/season1/episode1/chapter1/challenges/drawing/pixelartsoftware/#{@imageName()}-template.png"

  @briefComponentClass: ->
    # Note: We need to fully qualify the name instead of using @constructor
    # since we're overriding with a class with the same name.
    C1.Challenges.Drawing.PixelArtSoftware.CopyReference.BriefComponent

  @initialize()

  editorOptions: ->
    references:
      upload:
        enabled: false
      storage:
        enabled: false

  editorDrawComponents: ->
    # We send an empty array so we don't show the on-canvas reference.
    []
