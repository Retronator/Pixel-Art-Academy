AE = Artificial.Everywhere
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Challenges.Drawing.PixelArtReadability extends PAA.Practice.Thing
  # icons: object with the icons the player started drawing
  #   {label}: the name of the image classification label for this subject
  #     sizes:
  #       8/16/32: object with data for this size
  #         bitmapId: ID of the bitmap representing this subject size
  #         started: auto-updated field if the player started drawing this size for this subject
  #         completed: auto-updated field if the player completed this size for this subject
  # startedCounts:
  #    8/16/32: auto-updated integer count how many icons of this size have been started
  # completedCounts:
  #   8/16/32: auto-updated integer count how many icons of this size have been completed
  @id: -> 'PixelArtAcademy.Challenges.Drawing.PixelArtReadability'

  @fullName: -> "Pixel art readability"

  @initialize()

  @startedTotalCount: ->
    return 0 unless startedCounts = @state 'startedCounts'
    startedCounts[8] + startedCounts[16] + startedCounts[32]
    
  @addIcon: (label, size) ->
    icons = @state 'icons'
    icons ?= {}
    icons[label] ?= sizes: {}
    
    bitmapId = await @_createBitmap label, size
      
    icons[label].sizes[size] = {bitmapId}
    
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
      
  constructor: ->
    super arguments...
    
    @_countsAutorun = Tracker.autorun (computation) =>
      icons = @state 'icons'
      
      Tracker.nonreactive =>
        startedCounts = @state 'startedCounts'
        completedCounts = @state 'completedCounts'
        
        newStartedCounts = {8: 0, 16: 0, 32: 0}
        newCompletedCounts = {8: 0, 16: 0, 32: 0}
        
        for label, labelEntry of icons
          for size, icon of labelEntry.sizes
            newStartedCounts[size]++ if icon.started
            newCompletedCounts[size]++ if icon.completed
        
        @state 'startedCounts', newStartedCounts unless EJSON.equals startedCounts, newStartedCounts
        @state 'completedCounts', newCompletedCounts unless EJSON.equals completedCounts, newCompletedCounts

  destroy: ->
    super arguments...
    
    @_countsAutorun.stop()
    @_iconSelectionVolume1?.destroy()
    @_iconSelectionVolume2?.destroy()
    
  assetsData: -> []

  assets: ->
    @_iconSelectionVolume1 ?= Tracker.nonreactive => new PAA.Challenges.Drawing.PixelArtReadability.IconSelection.Volume1 @
    @_iconSelectionVolume2 ?= Tracker.nonreactive => new PAA.Challenges.Drawing.PixelArtReadability.IconSelection.Volume2 @
    
    [@_iconSelectionVolume1, @_iconSelectionVolume2]
    
  content: ->
    return unless chapter = LOI.adventure.getCurrentChapter PAA.LearnMode.PixelArtFundamentals.Fundamentals
    chapter.getContent PAA.LearnMode.PixelArtFundamentals.Fundamentals.Content.DrawingChallenges.PixelArtReadability
