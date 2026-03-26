AB = Artificial.Base
LOI = LandsOfIllusions
PAA = PixelArtAcademy
PADB = PixelArtDatabase

class PAA.Practice.Artworks
  @id: -> 'PixelArtAcademy.Practice.Artworks'
  
  @maxSize = 4096
  
  @insert: (artworkInfo) ->
    # Create the bitmap asset.
    creationTime = new Date()
    profileId = LOI.adventure.profileId()

    bitmapData =
      versioned: true
      profileId: profileId
      creationTime: creationTime
      lastEditTime: creationTime
      
    if artworkInfo.size
      bitmapData.bounds =
        fixed: true
        left: 0
        top: 0
        right: artworkInfo.size.width - 1
        bottom: artworkInfo.size.height - 1
        
    bitmapData.palette = _id: artworkInfo.paletteId if artworkInfo.paletteId
    bitmapData.properties = artworkInfo.properties if artworkInfo.properties
    
    bitmapData.pixelFormat = new LOI.Assets.Bitmap.PixelFormat 'flags'
    bitmapData.pixelFormat.addAttribute if artworkInfo.paletteId then 'paletteColor' else 'directColor'
    bitmapData.pixelFormat.addAttribute 'alpha' unless artworkInfo.paletteId
    bitmapData.pixelFormat.addAttribute 'normal' if artworkInfo.properties?.normals
  
    # Insert the document.
    bitmapId = LOI.Assets.Bitmap.documents.insert bitmapData
    
    # Create the artist if needed.
    artist = PADB.Artist.documents.findOne {profileId}
    
    unless artist
      artist = PADB.Artist.create
        profileId: profileId
        lastEditTime: creationTime
  
    # Create the artwork.
    artworkData =
      profileId: profileId
      lastEditTime: creationTime
      type: PADB.Artwork.Types.Image
      title: artworkInfo.title
      startDate: creationTime
      wip: true
      authors: [_id: artist._id]
      image: url: "#{LOI.Assets.Bitmap.imageUrl()}?id=#{bitmapId}"
      representations: [
        url: "#{LOI.Assets.Bitmap.documentUrl()}?id=#{bitmapId}"
        type: PADB.Artwork.RepresentationTypes.Document
      ]
  
    # Create the artwork and return the artwork.
    PADB.Artwork.create artworkData
    
  @remove: (artwork) ->
    # Remove the bitmap.
    bitmapId = artwork.image.url.split('id=')[1]
    LOI.Assets.Bitmap.documents.remove bitmapId
    
    # Remove the artwork.
    PADB.Artwork.documents.remove artwork._id
