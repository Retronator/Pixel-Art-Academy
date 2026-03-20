AE = Artificial.Everywhere
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Challenges.Drawing.PixelArtReadability extends PAA.Practice.Project.Thing
  # icons: object with the icons the player started drawing
  #   {label}: the name of the image classification label for this subject
  #     sizes:
  #       8/16/32: object with data for this size
  #         bitmapId: ID of the bitmap representing this subject size
  #         completed: auto-updated field if the player completed this size for this subject
  #     completedAny: auto-updated field if the player completed any of the size for this subject
  #     completedAll: auto-updated field if the player completed all of the sizes for this subject
  # completedCounts:
  #   8/16/32: auto-updated integer count how many icons of this size has been completed
  @id: -> 'PixelArtAcademy.Challenges.Drawing.PixelArtReadability'

  @fullName: -> "Pixel art readability"

  @initialize()

  @completed: ->
    # To complete the challenge, you have to have completed at least one 16x16 icon.
    completedCounts = @state 'completedCounts'
    completedCounts?[16]
    
  @addIcon: (label, size) ->
    icons = @state 'icons'
    icons ?= {}
    icons[label] ?=
      sizes: {}
      completedAny: false
      completedAll: false
      
    bitmapId = await @_createBitmap label, size
      
    icons[label].sizes[size] =
      bitmapId: bitmapId
      completed: false
    
    @state 'icons', icons
    
  @_createBitmap: (label, size) ->
    new Promise (resolve, reject) =>
      # Load the black palette.
      blackPalette = await new Promise (resolve) =>
        Tracker.autorun (computation) =>
          LOI.Assets.Palette.forName.subscribeContent LOI.Assets.Palette.SystemPaletteNames.Black
          return unless palette = LOI.Assets.Palette.documents.findOne name: LOI.Assets.Palette.SystemPaletteNames.Black
          computation.stop()
          resolve palette
  
      # Create an empty bitmap.
      creationTime = new Date()
      
      bitmapData =
        versioned: true
        profileId: LOI.adventure.profileId()
        creationTime: creationTime
        lastEditTime: creationTime
        name: "#{_.titleCase label} #{size}"
        bounds:
          fixed: true
          left: 0
          right: size - 1
          top: 0
          bottom: size - 1
        pixelFormat: new LOI.Assets.Bitmap.PixelFormat 'flags', 'paletteColor'
        palette:
          _id: blackPalette._id
        properties:
          pixelArtScaling: true
          readabilityAnalysis:
            regions: [
              targetLabel: label
            ]
          
      resolve LOI.Assets.Bitmap.documents.insert bitmapData

  destroy: ->
    super arguments...
    
    @_iconSelection?.destroy()
    
  assetsData: -> []

  assets: ->
    @_iconSelection ?= Tracker.nonreactive => new PAA.Challenges.Drawing.PixelArtReadability.IconSelection @
    [@_iconSelection]
    
  content: ->
    return unless chapter = LOI.adventure.getCurrentChapter PAA.LearnMode.PixelArtFundamentals.Fundamentals
    chapter.getContent PAA.LearnMode.PixelArtFundamentals.Fundamentals.Content.DrawingChallenges.PixelArtReadability
