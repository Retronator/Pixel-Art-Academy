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
  
  constructor: ->
    super

    # Allow to manually provide user sprite data.
    @manualUserSpriteData = new ReactiveField null
    
    # We override the component that shows the goal state with a custom one that only shows drawn errors.
    @engineComponent = new @constructor.ErrorEngineComponent
      userSpriteData: =>
        manualUserSpriteData = @manualUserSpriteData()
        return manualUserSpriteData if manualUserSpriteData
        
        return unless spriteId = @spriteId()
        LOI.Assets.Sprite.documents.findOne spriteId

      spriteData: =>
        return unless goalPixels = @goalPixels()
        return unless spriteId = @spriteId()

        # Take same overall sprite data (bounds, palette) as sprite used for drawing, but exclude the pixels.
        spriteData = LOI.Assets.Sprite.documents.findOne spriteId,
          fields:
            'layers': false

        return unless spriteData

        # Replace pixels with the goal state.
        spriteData.layers = [pixels: goalPixels]

        spriteData
        
    @uploadMode = new ReactiveField false

    @_clipboardPageComponent = new C1.Challenges.Drawing.PixelArtSoftware.CopyReference.ClipboardPageComponent @

  editorOptions: ->
    references:
      upload:
        enabled: false
      storage:
        enabled: false

  clipboardPageComponent: ->
    # We only show this page if we can upload.
    return unless PAA.PixelBoy.Apps.Drawing.state('externalSoftware')?
    
    @_clipboardPageComponent

  availableToolKeys: ->
    # When we're in upload mode, don't show any tools in the editor.
    if @uploadMode() then [] else null

  templateUrl: ->
    "/pixelartacademy/season1/episode1/chapter1/challenges/drawing/pixelartsoftware/#{@constructor.imageName()}-template.png"

  referenceUrl: ->
    @constructor.references()[0].image.url
