PADB = PixelArtDatabase

Document.startup ->
  return if Meteor.settings.startEmpty
  
  PADB.create
    artist:
      name:
        first: 'Gabrielle'
        last: 'Brickey'
        
    artworks: [
      type: PADB.Artwork.Types.Physical
      title: 'In a Feeling'
      completionDate:
        year: 2014
        month: 4
        day: 23
      image:
        url: '/retronator/hq/locations/artstudio/drawings/artworks/gabrielle-brickey-in-a-feeling.jpg'
    ,
      type: PADB.Artwork.Types.Physical
      title: 'In a Moment'
      completionDate:
        year: 2015
        month: 2
        day: 14
      image:
        url: '/retronator/hq/locations/artstudio/drawings/artworks/gabrielle-brickey-in-a-moment.jpg'
    ]

  PADB.Artist.create
    name:
      first: 'Alexandra'
      last: 'Hood'

  PADB.create
    artist:
      name:
        first: 'Matej'
        last: 'Jan'

    artworks: [
      type: PADB.Artwork.Types.Physical
      title: 'Skogsra'
      completionDate:
        year: 2015
        month: 4
        day: 23
      image:
        url: '/retronator/hq/locations/artstudio/drawings/artworks/matej-jan-skogsra.jpg'
    ]
