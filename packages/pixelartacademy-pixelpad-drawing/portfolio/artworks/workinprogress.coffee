AE = Artificial.Everywhere
PAA = PixelArtAcademy
PADB = PixelArtDatabase

class PAA.PixelPad.Apps.Drawing.Portfolio.Artworks.WorkInProgress extends PAA.Practice.AssetsProviderThing
  @id: -> 'PixelArtAcademy.PixelPad.Apps.Drawing.Portfolio.Artworks.WorkInProgress'

  @fullName: -> "Work in progress"

  @initialize()

  constructor: (@section) ->
    super arguments...

    @_newArtworkAsset = new PAA.PixelPad.Apps.Drawing.Portfolio.NewArtwork
    @_importArtworkAsset = new PAA.PixelPad.Apps.Drawing.Portfolio.ImportArtwork
    
    @assets = new AE.LiveComputedField =>
      assets = []
      
      # Get all WIP artworks.
      artworkIds = @section.artworkIds()
      
      wipArtworks = PADB.Artwork.documents.fetch
        _id: $in: artworkIds
        wip: true
      ,
        sort:
          startDate: 1
        
      for artwork, assetIndex in wipArtworks
        assets.push asset if asset = @section.getArtworkAsset artwork._id

      if PAA.PixelPad.Apps.Drawing.canCreateArtworks()
        assets.push @_newArtworkAsset

        # TODO: Enable uploading of artworks.
        # assets.push @_importArtworkAsset

      assets

  destroy: ->
    super arguments...
    
    @_newArtworkAsset.destroy()
    @_importArtworkAsset.destroy()

    @assets.stop()
