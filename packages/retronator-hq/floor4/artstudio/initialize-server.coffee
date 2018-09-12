PADB = PixelArtDatabase

Document.startup ->
  return if Meteor.settings.startEmpty
  
  # Alexandra Hood

  PADB.create
    artist: name: first: 'Alexandra', last: 'Hood'
    artworks: [
      type: PADB.Artwork.Types.Physical
      title: 'A Brutally Soft Woman'
      completionDate: year: 2017
      image: url: '/retronator/hq/locations/artstudio/artworks/alexandra-hood-a-brutally-soft-woman.jpg'
    ,
      type: PADB.Artwork.Types.Physical
      title: 'Alex + Kaylynn'
      completionDate: year: 2018
      image: url: '/retronator/hq/locations/artstudio/artworks/alexandra-hood-alex-kaylynn.jpg'
    ,
      type: PADB.Artwork.Types.Physical
      title: 'Aquatic II'
      completionDate: year: 2017
      image: url: '/retronator/hq/locations/artstudio/artworks/alexandra-hood-aquatic-ii.jpg'
    ,
      type: PADB.Artwork.Types.Physical
      title: 'Aquatic III'
      completionDate: year: 2017
      image: url: '/retronator/hq/locations/artstudio/artworks/alexandra-hood-aquatic-iii.jpg'
    ,
      type: PADB.Artwork.Types.Physical
      title: 'Aquatic V'
      completionDate: year: 2017
      image: url: '/retronator/hq/locations/artstudio/artworks/alexandra-hood-aquatic-v.jpg'
    ,
      type: PADB.Artwork.Types.Physical
      title: 'Black Lab'
      completionDate: year: 2017
      image: url: '/retronator/hq/locations/artstudio/artworks/alexandra-hood-black-lab.jpg'
    ,
      type: PADB.Artwork.Types.Physical
      title: 'Blue Landscape'
      completionDate: year: 2015
      image: url: '/retronator/hq/locations/artstudio/artworks/alexandra-hood-blue-landscape.jpg'
    ,
      type: PADB.Artwork.Types.Physical
      title: 'Botanical III'
      completionDate: year: 2017
      image: url: '/retronator/hq/locations/artstudio/artworks/alexandra-hood-botanical-iii.jpg'
    ,
      type: PADB.Artwork.Types.Physical
      title: 'Botanical IX'
      completionDate: year: 2017
      image: url: '/retronator/hq/locations/artstudio/artworks/alexandra-hood-botanical-ix.jpg'
    ,
      type: PADB.Artwork.Types.Physical
      title: 'Botanical V'
      completionDate: year: 2017
      image: url: '/retronator/hq/locations/artstudio/artworks/alexandra-hood-botanical-v.jpg'
    ,
      type: PADB.Artwork.Types.Physical
      title: 'Concrete Feet'
      completionDate: year: 2014
      image: url: '/retronator/hq/locations/artstudio/artworks/alexandra-hood-concrete-feet.jpg'
    ,
      type: PADB.Artwork.Types.Physical
      title: 'Everybody Wants to Rule the World'
      completionDate: year: 2014
      image: url: '/retronator/hq/locations/artstudio/artworks/alexandra-hood-everybody-wants-to-rule-the-world.jpg'
    ,
      type: PADB.Artwork.Types.Physical
      title: 'Evil Is Love Spelled Backwards'
      completionDate: year: 2013
      image: url: '/retronator/hq/locations/artstudio/artworks/alexandra-hood-evil-is-love-spelled-backwards.jpg'
    ,
      type: PADB.Artwork.Types.Physical
      title: 'Human Anatomy Studies'
      completionDate: year: 2014
      image: url: '/retronator/hq/locations/artstudio/artworks/alexandra-hood-human-anatomy-studies.jpg'
    ,
      type: PADB.Artwork.Types.Physical
      title: 'Nine to Five'
      completionDate: year: 2014
      image: url: '/retronator/hq/locations/artstudio/artworks/alexandra-hood-nine-to-five.jpg'
    ,
      type: PADB.Artwork.Types.Physical
      title: 'Pop!'
      completionDate: year: 2012
      image: url: '/retronator/hq/locations/artstudio/artworks/alexandra-hood-pop.jpg'
    ,
      type: PADB.Artwork.Types.Physical
      title: 'Self Portrait With Hair'
      completionDate: year: 2014
      image: url: '/retronator/hq/locations/artstudio/artworks/alexandra-hood-self-portrait-with-hair.jpg'
    ,
      type: PADB.Artwork.Types.Physical
      title: 'Withers Family'
      completionDate: year: 2017
      image: url: '/retronator/hq/locations/artstudio/artworks/alexandra-hood-withers-family.jpg'
    ]

  # Gabrielle Brickey

  PADB.create
    artist: name: first: 'Gabrielle', last: 'Brickey'
    artworks: [
      type: PADB.Artwork.Types.Physical
      title: 'Angel'
      completionDate: year: 2012, month: 5, day: 16
      image: url: '/retronator/hq/locations/artstudio/artworks/gabrielle-brickey-angel.jpg'
    ,
      type: PADB.Artwork.Types.Physical
      title: 'Bouguereau Study'
      completionDate: year: 2013, month: 2, day: 15
      image: url: '/retronator/hq/locations/artstudio/artworks/gabrielle-brickey-bouguereau-study.jpg'
    ,
      type: PADB.Artwork.Types.Physical
      title: 'In a Feeling'
      completionDate: year: 2014, month: 4, day: 23
      image: url: '/retronator/hq/locations/artstudio/artworks/gabrielle-brickey-in-a-feeling.jpg'
    ,
      type: PADB.Artwork.Types.Physical
      title: 'In a Moment'
      completionDate: year: 2015, month: 2, day: 14
      image: url: '/retronator/hq/locations/artstudio/artworks/gabrielle-brickey-in-a-moment.jpg'
    ,
      type: PADB.Artwork.Types.Physical
      title: 'Oil Painting'
      completionDate: year: 2015, month: 10, day: 22
      image: url: '/retronator/hq/locations/artstudio/artworks/gabrielle-brickey-oil-painting.jpg'
    ,
      type: PADB.Artwork.Types.Physical
      title: ':we caught on fire:'
      completionDate: year: 2009, month: 10, day: 3
      image: url: '/retronator/hq/locations/artstudio/artworks/gabrielle-brickey-we-caught-on-fire.jpg'
    ]

  # Hendry Roesly
  
  PADB.create
    artist: name: first: 'Hendry', last: 'Roesly', nickname: 'Iceztiq'
    artworks: [
      type: PADB.Artwork.Types.Physical
      title: 'Day 9'
      completionDate: year: 2017, month: 10, day: 9
      image: url: '/retronator/hq/locations/artstudio/artworks/hendry-roesly-day-9.jpg'
    ,
      type: PADB.Artwork.Types.Physical
      title: 'Desert'
      completionDate: year: 2018, month: 4, day: 24
      image: url: '/retronator/hq/locations/artstudio/artworks/hendry-roesly-desert.png'
    ,
      type: PADB.Artwork.Types.Physical
      title: 'Kuria'
      completionDate: year: 2018, month: 4, day: 16
      image: url: '/retronator/hq/locations/artstudio/artworks/hendry-roesly-kuria.png'
    ,
      type: PADB.Artwork.Types.Physical
      title: 'Survivor'
      completionDate: year: 2018, month: 2, day: 17
      image: url: '/retronator/hq/locations/artstudio/artworks/hendry-roesly-survivor.jpg'
    ]

  # Jorge Monreal

  PADB.create
    artist: name: first: 'Jorge', last: 'Monreal'
    artworks: [
      type: PADB.Artwork.Types.Physical
      title: 'Adventure time'
      completionDate: year: 2012, month: 12, day: 27
      image: url: '/retronator/hq/locations/artstudio/artworks/jorge-monreal-adventure-time.jpg'
    ,
      type: PADB.Artwork.Types.Physical
      title: 'Blue girl 2'
      completionDate: year: 2013, month: 4, day: 24
      image: url: '/retronator/hq/locations/artstudio/artworks/jorge-monreal-blue-girl-2.jpg'
    ,
      type: PADB.Artwork.Types.Physical
      title: 'Skull girl 3'
      completionDate: year: 2011, month: 6, day: 19
      image: url: '/retronator/hq/locations/artstudio/artworks/jorge-monreal-skull-girl-3.jpg'
    ]

  # Matej Jan
    
  PADB.create
    artist: name: first: 'Matej', last: 'Jan', nickname: 'Retro'
    artworks: [
      type: PADB.Artwork.Types.Physical
      title: 'Africa'
      completionDate: year: 2012, month: 5, day: 14
      representations: [
        type: PADB.Artwork.RepresentationTypes.Image
        url: '/retronator/hq/locations/artstudio/artworks/matej-jan-africa.jpg'
      ]
    ,
      type: PADB.Artwork.Types.Image
      title: 'Blonde'
      completionDate: year: 2015, month: 2, day: 19
      image: url: '/retronator/hq/locations/artstudio/artworks/matej-jan-blonde.jpg'
    ,
      type: PADB.Artwork.Types.Physical
      title: 'Blue Bottle'
      completionDate: year: 2016, month: 7, day: 17
      image: url: '/retronator/hq/locations/artstudio/artworks/matej-jan-blue-bottle.jpg'
    ,
      type: PADB.Artwork.Types.Physical
      title: 'Bust'
      completionDate: year: 2016, month: 7, day: 6
      image: url: '/retronator/hq/locations/artstudio/artworks/matej-jan-bust.jpg'
    ,
      type: PADB.Artwork.Types.Physical
      title: 'Cardinal City'
      completionDate: year: 2016, month: 9, day: 25
      startDate: year: 2016, month: 2, day: 4
      image: url: '/retronator/hq/locations/artstudio/artworks/matej-jan-cardinal-city.jpg'
    ,
      type: PADB.Artwork.Types.Physical
      title: 'Cardinal City tools'
      completionDate: year: 2016, month: 2, day: 4
      image: url: '/retronator/hq/locations/artstudio/artworks/matej-jan-cardinal-city-tools.jpg'
    ,
      type: PADB.Artwork.Types.Physical
      title: 'Day at the Beach'
      completionDate: year: 2016, month: 8, day: 10
      image: url: '/retronator/hq/locations/artstudio/artworks/matej-jan-day-at-the-beach.jpg'
    ,
      type: PADB.Artwork.Types.Image
      title: 'Desert'
      completionDate: year: 2014, month: 11, day: 13
      image: url: '/retronator/hq/locations/artstudio/artworks/matej-jan-desert.jpg'
    ,
      type: PADB.Artwork.Types.Physical
      title: 'Desolation'
      completionDate: year: 2016, month: 8, day: 7
      image: url: '/retronator/hq/locations/artstudio/artworks/matej-jan-desolation.jpg'
    ,
      type: PADB.Artwork.Types.Image
      title: 'Give me the Sky'
      completionDate: year: 2013, month: 6, day: 29
      image: url: '/retronator/hq/locations/artstudio/artworks/matej-jan-give-me-the-sky.jpg'
    ,
      type: PADB.Artwork.Types.Physical
      title: 'Hand Study'
      completionDate: year: 2016, month: 7, day: 13
      representations: [
        type: PADB.Artwork.RepresentationTypes.Image
        url: '/retronator/hq/locations/artstudio/artworks/matej-jan-hand-study.jpg'
      ]
    ,
      type: PADB.Artwork.Types.Physical
      title: 'Hillary'
      completionDate: year: 2016, month: 6, day: 22
      image: url: '/retronator/hq/locations/artstudio/artworks/matej-jan-hillary.jpg'
    ,
      type: PADB.Artwork.Types.Physical
      title: 'Inventory'
      completionDate: year: 2016, month: 7, day: 3
      representations: [
        type: PADB.Artwork.RepresentationTypes.Image
        url: '/retronator/hq/locations/artstudio/artworks/matej-jan-inventory.jpg'
      ]
    ,
      type: PADB.Artwork.Types.Physical
      title: 'Kaley'
      completionDate: year: 2012, month: 5, day: 7
      image: url: '/retronator/hq/locations/artstudio/artworks/matej-jan-kaley.jpg'
    ,
      type: PADB.Artwork.Types.Image
      title: 'Lioness'
      completionDate: year: 2012, month: 8, day: 9
      image: url: '/retronator/hq/locations/artstudio/artworks/matej-jan-lioness.jpg'
    ,
      type: PADB.Artwork.Types.Physical
      title: 'Lotus Esprit Turbo'
      completionDate: year: 2012, month: 9, day: 3
      image: url: '/retronator/hq/locations/artstudio/artworks/matej-jan-lotus-esprit-turbo.jpg'
    ,
      type: PADB.Artwork.Types.Physical
      title: 'Memchu'
      completionDate: year: 2016, month: 7, day: 4
      startDate: year: 2016, month: 6, day: 29
      image: url: '/retronator/hq/locations/artstudio/artworks/matej-jan-memchu.jpg'
    ,
      type: PADB.Artwork.Types.Physical
      title: 'Neukom'
      completionDate: year: 2017, month: 7, day: 11
      wip: true
      image: url: '/retronator/hq/locations/artstudio/artworks/matej-jan-neukom-wip-1.jpg'
    ,
      type: PADB.Artwork.Types.Physical
      title: 'Neukom'
      completionDate: year: 2017, month: 7, day: 11
      wip: true
      image: url: '/retronator/hq/locations/artstudio/artworks/matej-jan-neukom-wip-2.jpg'
    ,
      type: PADB.Artwork.Types.Physical
      title: 'Neukom'
      completionDate: year: 2017, month: 7, day: 11
      wip: true
      image: url: '/retronator/hq/locations/artstudio/artworks/matej-jan-neukom-wip-3.jpg'
    ,
      type: PADB.Artwork.Types.Physical
      title: 'Neukom'
      completionDate: year: 2017, month: 7, day: 16
      startDate: year: 2017, month: 7, day: 11
      image: url: '/retronator/hq/locations/artstudio/artworks/matej-jan-neukom.jpg'
    ,
      type: PADB.Artwork.Types.Image
      title: 'Night 21'
      completionDate: year: 2017, month: 4, day: 4
      representations: [
        type: PADB.Artwork.RepresentationTypes.Image
        url: '/retronator/hq/locations/artstudio/artworks/matej-jan-night-21.jpg'
      ]
    ,
      type: PADB.Artwork.Types.Image
      title: 'Octobit day 2: Astronaut'
      completionDate: year: 2017, month: 10, day: 2
      image: url: '/retronator/hq/locations/artstudio/artworks/matej-jan-octobit-day-2-astronaut.png'
    ,
      type: PADB.Artwork.Types.Image
      title: 'Reignite 6'
      completionDate: year: 2017, month: 3, day: 31
      image: url: '/retronator/hq/locations/artstudio/artworks/matej-jan-reignite-6.jpg'
    ,
      type: PADB.Artwork.Types.Image
      title: 'Retropolis International Spacestation: Main Tower'
      completionDate: year: 2017, month: 2, day: 21
      representations: [
        type: PADB.Artwork.RepresentationTypes.Image
        url: '/retronator/hq/locations/artstudio/artworks/matej-jan-retropolis-international-spacestation-main-tower.jpg'
      ]
    ,
      type: PADB.Artwork.Types.Physical
      title: 'Rodin'
      completionDate: year: 2016, month: 6, day: 29
      image: url: '/retronator/hq/locations/artstudio/artworks/matej-jan-rodin.jpg'
    ,
      type: PADB.Artwork.Types.Physical
      title: 'Skogsra'
      completionDate: year: 2015, month: 4, day: 23
      image: url: '/retronator/hq/locations/artstudio/artworks/matej-jan-skogsra.jpg'
    ]

  # Maya Pixelskaya
  
  PADB.create
    artist: pseudonym: 'Maya Pixelskaya'
    artworks: [
      type: PADB.Artwork.Types.Physical
      title: 'Street Fighter Converse chucks'
      completionDate: year: 2011, month: 10, day: 4
      representations: [
        type: PADB.Artwork.RepresentationTypes.Image
        url: '/retronator/hq/locations/artstudio/artworks/maya-pixelskaya-street-fighter-converse-chucks.jpg'
      ]
    ,
      type: PADB.Artwork.Types.Physical
      title: 'Street Fighter II triptych'
      completionDate: year: 2013, month: 4, day: 10
      representations: [
        type: PADB.Artwork.RepresentationTypes.Image
        url: '/retronator/hq/locations/artstudio/artworks/maya-pixelskaya-street-fighter-ii-triptych.jpg'
      ]
    ]

  # Octavi Navarro

  PADB.create
    artist: name: first: 'Octavi', last: 'Navarro'
    artworks: [
      type: PADB.Artwork.Types.Physical
      title: 'Escape'
      completionDate: year: 2013
      image: url: '/retronator/hq/locations/artstudio/artworks/octavi-navarro-escape.jpg'
    ,
      type: PADB.Artwork.Types.Physical
      title: 'Pumpkin Road'
      completionDate: year: 2013
      image: url: '/retronator/hq/locations/artstudio/artworks/octavi-navarro-pumpkin-road.jpg'
    ]

  # Sylvain Sarrailh

  PADB.create
    artist: name: first: 'Sylvain', last: 'Sarrailh', nickname: 'Tohad'
    artworks: [
      type: PADB.Artwork.Types.Image
      title: 'Amazing'
      completionDate: year: 2017, month: 5, day: 18
      image: url: '/retronator/hq/locations/artstudio/artworks/sylvain-sarrailh-amazing.jpg'
    ,
      type: PADB.Artwork.Types.Image
      title: 'Forest of Liars: Sunset on the wood bridge'
      completionDate: year: 2018, month: 4, day: 30
      image: url: '/retronator/hq/locations/artstudio/artworks/sylvain-sarrailh-forest-of-liars-sunset-on-the-wood-bridge.jpg'
    ,
      type: PADB.Artwork.Types.Image
      title: 'The Forgotten Empire'
      completionDate: year: 2017, month: 2, day: 8
      image: url: '/retronator/hq/locations/artstudio/artworks/sylvain-sarrailh-the-forgotten-empire.jpg'
    ,
      type: PADB.Artwork.Types.Image
      title: 'Uncharted Book Cover'
      completionDate: year: 2018, month: 2, day: 15
      image: url: '/retronator/hq/locations/artstudio/artworks/sylvain-sarrailh-uncharted-book-cover.jpg'
    ]
