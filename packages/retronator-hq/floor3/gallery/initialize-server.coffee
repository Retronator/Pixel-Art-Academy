PADB = PixelArtDatabase

Document.startup ->
  return if Meteor.settings.startEmpty

  PADB.create
    artist: name: first: 'Matej', last: 'Jan', nickname: 'Retro'
    artworks: [
      type: PADB.Artwork.Types.Image
      title: 'Tribute'
      completionDate: year: 2012, month: 2, day: 22
      image:
        url: '/retronator/hq/locations/gallery/artworks/matej-jan-tribute.png'
        pixelScale: 1
    ,
      type: PADB.Artwork.Types.Image
      title: 'Pixel China Mountains'
      completionDate: year: 2013, month: 9, day: 2
      image:
        url: '/retronator/hq/locations/gallery/artworks/matej-jan-pixelchinamountains.gif'
        pixelScale: 1
    ,
      type: PADB.Artwork.Types.Image
      title: 'Pixel Spectrum'
      completionDate: year: 2012, month: 7, day: 1
      image:
        url: '/retronator/hq/locations/gallery/artworks/matej-jan-pixelspectrum.png'
        pixelScale: 1
    ,
      type: PADB.Artwork.Types.Image
      title: 'Pixel 64'
      completionDate: year: 2013, month: 1, day: 8
      image:
        url: '/retronator/hq/locations/gallery/artworks/matej-jan-pixel64.png'
        pixelScale: 1
    ,
      type: PADB.Artwork.Types.Image
      title: 'Pixelberry Pi'
      completionDate: year: 2017, month: 6, day: 18
      image:
        url: '/retronator/hq/locations/gallery/artworks/matej-jan-pixelberrypi.png'
        pixelScale: 1
    ,
      type: PADB.Artwork.Types.Image
      title: 'Mountain Lake'
      completionDate: year: 2018, month: 5, day: 17
      image:
        url: '/retronator/hq/locations/gallery/artworks/matej-jan-mountainlake.png'
        pixelScale: 1
    ,
      type: PADB.Artwork.Types.Image
      title: 'Mountain Pass'
      completionDate: year: 2018, month: 6, day: 16
      image:
        url: '/retronator/hq/locations/gallery/artworks/matej-jan-mountainpass.png'
        pixelScale: 1
    ,
      type: PADB.Artwork.Types.Image
      title: 'Savanna'
      completionDate: year: 2018, month: 9, day: 29
      image:
        url: '/retronator/hq/locations/gallery/artworks/matej-jan-savanna.png'
        pixelScale: 1
    ,
      type: PADB.Artwork.Types.Image
      title: 'ZX Cosmopolis'
      completionDate: year: 2017, month: 5, day: 29
      startDate: year: 2008, month: 5, day: 7
      image:
        url: '/retronator/hq/locations/gallery/artworks/matej-jan-zxcosmopolis.png'
        pixelScale: 1
    ]
