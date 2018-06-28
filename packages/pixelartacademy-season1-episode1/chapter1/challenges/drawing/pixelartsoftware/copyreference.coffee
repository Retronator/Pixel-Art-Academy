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

  # We'll provide a custom handling for goal bitmap, so we set this one to a dummy value that is different than empty.
  @goalBitmap: -> "0"

  @image: -> throw new AE.NotImplementedException "You must provide the image name for the asset."

  @references: -> [
    "/pixelartacademy/season1/episode1/chapter1/challenges/drawing/pixelartsoftware/#{@image()}-reference.png"
  ]

  @customPaletteImageUrl: ->
    return null if @restrictedPaletteName()

    "/pixelartacademy/season1/episode1/chapter1/challenges/drawing/pixelartsoftware/#{@image()}-template.png"

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
