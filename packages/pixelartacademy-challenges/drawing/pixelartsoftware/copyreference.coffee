AE = Artificial.Everywhere
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Challenges.Drawing.PixelArtSoftware.CopyReference extends PAA.Practice.Challenges.Drawing.TutorialBitmap
  @displayName: -> "Copy the reference"

  @description: -> """
      Use the editor or software of your choice to recreate the provided reference.
    """

  @bitmap: -> "" # Empty bitmap

  @goalImageUrl: -> "/pixelartacademy/challenges/drawing/pixelartsoftware/#{@imageName()}.png"

  @imageName: -> throw new AE.NotImplementedException "You must provide the image name for the asset."

  @references: -> [
    image:
      url: "/pixelartacademy/challenges/drawing/pixelartsoftware/#{@imageName()}-reference.png"
    displayOptions:
      imageOnly: true
  ]

  @customPaletteImageUrl: ->
    return null if @restrictedPaletteName()

    "/pixelartacademy/challenges/drawing/pixelartsoftware/#{@imageName()}-template.png"

  @briefComponentClass: ->
    # Note: We need to fully qualify the name instead of using @constructor
    # since we're overriding with a class with the same name.
    PAA.Challenges.Drawing.PixelArtSoftware.CopyReference.BriefComponent
  
  constructor: ->
    super arguments...

    # Allow to manually provide user bitmap data.
    @manualUserBitmapData = new ReactiveField null
    
    # We override the component that shows the goal state with a custom one that only shows drawn errors.
    @engineComponent = new @constructor.ErrorEngineComponent
      userBitmapData: =>
        manualUserBitmapData = @manualUserBitmapData()
        return manualUserBitmapData if manualUserBitmapData
        
        return unless bitmapId = @bitmapId()
        LOI.Assets.Bitmap.documents.findOne bitmapId

      bitmapData: =>
        return unless goalPixels = @goalPixels()
        return unless bitmapId = @bitmapId()

        # Take same overall bitmap data (bounds, palette) as bitmap used for drawing, but exclude the pixels.
        bitmapData = LOI.Assets.Bitmap.documents.findOne bitmapId,
          fields:
            'layers': false

        return unless bitmapData

        # Replace pixels with the goal state.
        bitmapData.layers = [pixels: goalPixels]

        bitmapData
        
    @uploadMode = new ReactiveField false

    @_clipboardPageComponent = new PAA.Challenges.Drawing.PixelArtSoftware.CopyReference.ClipboardPageComponent @

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
    "/pixelartacademy/challenges/drawing/pixelartsoftware/#{@constructor.imageName()}-template.png"

  referenceUrl: ->
    @constructor.references()[0].image.url
