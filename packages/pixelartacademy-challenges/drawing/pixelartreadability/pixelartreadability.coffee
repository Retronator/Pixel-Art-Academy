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
