AE = Artificial.Everywhere
AM = Artificial.Mummification
PADB = PixelArtDatabase

PADB.create = (options) ->
  if options.artist
    artist = PADB.Artist.create options.artist

    if options.profiles
      if _.isArray options.profiles
        for profile in options.profiles
          PADB.Profile.create _.extend {artist: _id: artist._id}, profile

      else
        profileFields =
          twitter: PADB.Profile.PlatformTypes.Twitter

        for profileField, platformType of profileFields when options.profiles[profileField]
          PADB.Profile.create
            platformType: platformType
            username: options.profiles[profileField]
            artist: artist

    if options.artworks
      for artwork in options.artworks
        PADB.Artwork.create _.extend {authors: [_id: artist._id]}, artwork
