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

  PADB.create
    artist: name: first: 'Alexandra', last: 'Hood'
    artworks: [
      type: PADB.Artwork.Types.Physical
      title: 'A Brutally Soft Woman'
      completionDate: year: 2017
      image: url: '/retronator/hq/locations/artstudio/drawings/artworks/alexandra-hood-a-brutally-soft-woman.jpg'
    ,
      type: PADB.Artwork.Types.Physical
      title: 'Alex + Kaylynn'
      completionDate: year: 2018
      image: url: '/retronator/hq/locations/artstudio/drawings/artworks/alexandra-hood-alex-kaylynn.jpg'
    ,
      type: PADB.Artwork.Types.Physical
      title: 'Aquatic II'
      completionDate: year: 2017
      image: url: '/retronator/hq/locations/artstudio/drawings/artworks/alexandra-hood-aquatic-ii.jpg'
    ,
      type: PADB.Artwork.Types.Physical
      title: 'Aquatic III'
      completionDate: year: 2017
      image: url: '/retronator/hq/locations/artstudio/drawings/artworks/alexandra-hood-aquatic-iii.jpg'
    ,
      type: PADB.Artwork.Types.Physical
      title: 'Aquatic V'
      completionDate: year: 2017
      image: url: '/retronator/hq/locations/artstudio/drawings/artworks/alexandra-hood-aquatic-v.jpg'
    ,
      type: PADB.Artwork.Types.Physical
      title: 'Black Lab'
      completionDate: year: 2017
      image: url: '/retronator/hq/locations/artstudio/drawings/artworks/alexandra-hood-black-lab.jpg'
    ,
      type: PADB.Artwork.Types.Physical
      title: 'Botanical III'
      completionDate: year: 2017
      image: url: '/retronator/hq/locations/artstudio/drawings/artworks/alexandra-hood-botanical-iii.jpg'
    ,
      type: PADB.Artwork.Types.Physical
      title: 'Botanical IX'
      completionDate: year: 2017
      image: url: '/retronator/hq/locations/artstudio/drawings/artworks/alexandra-hood-botanical-ix.jpg'
    ,
      type: PADB.Artwork.Types.Physical
      title: 'Botanical V'
      completionDate: year: 2017
      image: url: '/retronator/hq/locations/artstudio/drawings/artworks/alexandra-hood-botanical-v.jpg'
    ,
      type: PADB.Artwork.Types.Physical
      title: 'Evil Is Love Spelled Backwards'
      completionDate: year: 2013
      image: url: '/retronator/hq/locations/artstudio/drawings/artworks/alexandra-hood-evil-is-love-spelled-backwards.jpg'
    ,
      type: PADB.Artwork.Types.Physical
      title: 'Human Anatomy Studies'
      completionDate: year: 2014
      image: url: '/retronator/hq/locations/artstudio/drawings/artworks/alexandra-hood-human-anatomy-studies.jpg'
    ,
      type: PADB.Artwork.Types.Physical
      title: 'Self Portrait With Hair'
      completionDate: year: 2014
      image: url: '/retronator/hq/locations/artstudio/drawings/artworks/alexandra-hood-self-portrait-with-hair.jpg'
    ,
      type: PADB.Artwork.Types.Physical
      title: 'Withers Family'
      completionDate: year: 2017
      image: url: '/retronator/hq/locations/artstudio/drawings/artworks/alexandra-hood-withers-family.jpg'
    ]

  PADB.create
    artist: name: first: 'Matej', last: 'Jan'
    artworks: [
      type: PADB.Artwork.Types.Physical
      title: 'Cardinal City'
      completionDate: year: 2016, month: 9, day: 25
      startDate: year: 2016, month: 2, day: 4
      image: url: '/retronator/hq/locations/artstudio/drawings/artworks/matej-jan-cardinal-city.jpg'
    ,
      type: PADB.Artwork.Types.Physical
      title: 'Hand Study'
      completionDate: year: 2016, month: 7, day: 13
      representations: [
        type: PADB.Artwork.RepresentationTypes.Image
        url: '/retronator/hq/locations/artstudio/drawings/artworks/matej-jan-hand-study.jpg'
      ]
    ,
      type: PADB.Artwork.Types.Physical
      title: 'Hillary'
      completionDate: year: 2016, month: 6, day: 22
      image: url: '/retronator/hq/locations/artstudio/drawings/artworks/matej-jan-hillary.jpg'
    ,
      type: PADB.Artwork.Types.Physical
      title: 'Kaley'
      completionDate: year: 2012, month: 5, day: 7
      image: url: '/retronator/hq/locations/artstudio/drawings/artworks/matej-jan-kaley.jpg'
    ,
      type: PADB.Artwork.Types.Image
      title: 'Night 21'
      completionDate: year: 2017, month: 4, day: 4
      representations: [
        type: PADB.Artwork.RepresentationTypes.Image
        url: '/retronator/hq/locations/artstudio/drawings/artworks/matej-jan-night-21.jpg'
      ]
    ,
      type: PADB.Artwork.Types.Image
      title: 'Retropolis International Spacestation: Main Tower'
      completionDate: year: 2017, month: 2, day: 21
      representations: [
        type: PADB.Artwork.RepresentationTypes.Image
        url: '/retronator/hq/locations/artstudio/drawings/artworks/matej-jan-retropolis-international-spacestation-main-tower.jpg'
      ]
    ,
      type: PADB.Artwork.Types.Physical
      title: 'Rodin'
      completionDate: year: 2016, month: 6, day: 29
      image: url: '/retronator/hq/locations/artstudio/drawings/artworks/matej-jan-rodin.jpg'
    ,
      type: PADB.Artwork.Types.Physical
      title: 'Skogsra'
      completionDate: year: 2015, month: 4, day: 23
      image: url: '/retronator/hq/locations/artstudio/drawings/artworks/matej-jan-skogsra.jpg'
    ]
