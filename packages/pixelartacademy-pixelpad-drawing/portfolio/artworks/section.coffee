AE = Artificial.Everywhere
PAA = PixelArtAcademy
PADB = PixelArtDatabase

class PAA.PixelPad.Apps.Drawing.Portfolio.Artworks.Section
  constructor: ->
    @nameKey = PAA.PixelPad.Apps.Drawing.Portfolio.Sections.Artworks
    @isSection = true
  
    # Create artwork assets.
    @_artworkAssets = {}
    @_artworkAssetsDependency = new Tracker.Dependency
  
    @artworkIds = new AE.LiveComputedField =>
      return [] unless artworks = PAA.PixelPad.Apps.Drawing.state 'artworks'
      artwork.artworkId for artwork in artworks
  
    @_artworksDictionary = new AE.ReactiveDictionary =>
      artworkIds = @artworkIds()
      artworksDictionary = {}
      
      PADB.Artwork.documents.find(_id: $in: artworkIds).forEach (artwork) =>
        artworksDictionary[artwork._id] = artwork
  
      artworksDictionary
    ,
      added: (artworkId) =>
        @_artworkAssets[artworkId] = new PAA.PixelPad.Apps.Drawing.Portfolio.Artworks.Asset artworkId
        @_artworkAssetsDependency.changed()
  
      removed: (artworkId) =>
        @_artworkAssets[artworkId].destroy()
        delete @_artworkAssets[artworkId]
        @_artworkAssetsDependency.changed()
        
    # Provide groups.
    @workInProgress = new PAA.PixelPad.Apps.Drawing.Portfolio.Artworks.WorkInProgress @
    
    @things = new AE.LiveComputedField =>
      things = []
      things.push @workInProgress if @workInProgress.assets().length
      things
    
    @groupsProvider = new PAA.PixelPad.Apps.Drawing.Portfolio.GroupsProvider @things, 0
    @groups = @groupsProvider.groups

  destroy: ->
    @artworkIds.stop()
    @_artworksDictionary.stop()
    @workInProgress.destroy()
    @things.stop()
    @groupsProvider.destroy()

  getArtworkAsset: (artworkId) ->
    @_artworkAssetsDependency.depend()
    @_artworkAssets[artworkId]
