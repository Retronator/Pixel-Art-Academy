PAA = PixelArtAcademy

class PAA.Artworks

  # Upload limits.
  Slingshot.fileRestrictions 'artworks',
    maxSize: 10 * 1024 * 1024 # 10 MB
    allowedFileTypes: [
      'image/png'
      'image/jpeg'
      'image/gif'
    ]
