AB = Artificial.Base
AE = Artificial.Everywhere
PAA = PixelArtAcademy
PADB = PixelArtDatabase
LOI = LandsOfIllusions

PAA.Practice.Artworks.insert.method (characterId, artworkInfo) ->
  check characterId, Match.DocumentId
  check artworkInfo,
    assetClassName: Match.Where (name) ->
      name in [
        'Sprite'
      ]
    title: String
    size: Match.Optional
      width: Match.PositiveInteger
      height: Match.PositiveInteger
    paletteId: Match.Optional Match.DocumentId
    
  character = LOI.Authorize.characterAction characterId
  
  # Create the asset.
  assetData =
    authors: [_id: characterId]
    creationTime: new Date()
    
  if artworkInfo.size
    maxSize = PAA.Practice.Artworks.maxSizes[artworkInfo.assetClassName]
    if artworkInfo.size.width > maxSize or artworkInfo.size.height > maxSize
      throw new AE.ArgumentOutOfRangeException "The maximum size for a #{_.toLower artworkInfo.assetClassName} is #{maxSize}.", 'size'
    
    assetData.bounds =
      fixed: true
      left: 0
      top: 0
      right: artworkInfo.size.width - 1
      bottom: artworkInfo.size.height - 1
      
  assetData.palette = _id: artworkInfo.paletteId if artworkInfo.paletteId
  
  assetClass = LOI.Assets[artworkInfo.assetClassName]
  assetId = assetClass.documents.insert assetData
  
  # Create the artist if needed.
  unless artistId = character.artist?._id
    # On the client we can't continue since creating an artist is a server-only operation.
    return if Meteor.isClient
    
    artist = PADB.Artist.create
      characters: [_id: characterId]
  
    artistId = artist._id

  # Create the artwork.
  artworkData =
    type: PADB.Artwork.Types.Image
    title: artworkInfo.title
    startDate: assetData.creationTime
    wip: true
    authors: [_id: artistId]
    image: url: "#{assetClass.imageUrl()}?id=#{assetId}"
    representations: [
      url: "#{assetClass.documentUrl()}?id=#{assetId}"
      type: PADB.Artwork.RepresentationTypes.Document
    ]

  # Create the artwork and return the artwork ID.
  PADB.Artwork.documents.insert artworkData
