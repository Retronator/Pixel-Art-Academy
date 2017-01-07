PAA = PixelArtAcademy

class PAA.Practice
  
  # Upload limits.
  Slingshot.fileRestrictions 'checkIns',
    maxSize: 10 * 1024 * 1024 # 10 MB
    allowedFileTypes: [
      'image/png'
      'image/jpeg'
      'image/gif'
    ]
