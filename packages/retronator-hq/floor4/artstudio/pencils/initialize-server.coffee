PADB = PixelArtDatabase

Document.startup ->
  return if Meteor.settings.startEmpty

  PADB.create
    artist: name: first: 'Matej', last: 'Jan'
    artworks: [
      type: PADB.Artwork.Types.Physical
      title: 'Inventory'
      completionDate: year: 2016, month: 7, day: 3
      representations: [
        type: PADB.Artwork.RepresentationTypes.Image
        url: '/retronator/hq/locations/artstudio/pencils/artworks/matej-jan-inventory.jpg'
      ]
    ]
