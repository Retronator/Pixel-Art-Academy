AE = Artificial.Everywhere
AM = Artificial.Mirage
LOI = LandsOfIllusions
HQ = Retronator.HQ
RA = Retronator.Accounts
RS = Retronator.Store

Vocabulary = LOI.Parser.Vocabulary

class HQ.ArtStudio.ContextWithArtworks extends HQ.ArtStudio.ContextWithArtworks
  constructor: ->
    super

    @artistsInfo =
      alexandraHood: name: first: 'Alexandra', last: 'Hood'
      gabrielleBrickey: name: first: 'Gabrielle', last: 'Brickey'
      hendryRoesly: name: first: 'Hendry', last: 'Roesly'
      jorgeMonreal: name: first: 'Jorge', last: 'Monreal'
      matejJan: name: first: 'Matej', last: 'Jan'
      mayaPixelskaya: pseudonym: 'Maya Pixelskaya'
      octaviNavarro: name: first: 'Octavi', last: 'Navarro'
      sylvainSarrailh: name: first: 'Sylvain', last: 'Sarrailh'

    @artworksInfo =
    
      # Alexandra Hood
    
      aBrutallySoftWoman:
        artistInfo: @artistsInfo.alexandraHood
        title: 'A Brutally Soft Woman'
        caption: "Graphite on cartridge paper, 11.5 × 16.5 inches"
      alexKaylynn:
        artistInfo: @artistsInfo.alexandraHood
        title: 'Alex + Kaylynn'
        caption: "Graphite on Bristol paper, 9 × 12 inches"
      aquaticIi:
        artistInfo: @artistsInfo.alexandraHood
        title: 'Aquatic II'
        caption: "Micron pen on brown cotton rag paper, 5 × 5 inches (deckle edge unfeatured)"
      aquaticIii:
        artistInfo: @artistsInfo.alexandraHood
        title: 'Aquatic III'
        caption: "Micron pen on brown cotton rag paper, 5 × 5 inches (deckle edge unfeatured)"
      aquaticV:
        artistInfo: @artistsInfo.alexandraHood
        title: 'Aquatic V'
        caption: "Micron pen on brown cotton rag paper, 5 × 5 inches (deckle edge unfeatured)"
      blackLab:
        artistInfo: @artistsInfo.alexandraHood
        title: 'Black Lab'
        caption: "Graphite on Bristol paper, 9 × 12 inches"
      blueLandscape:
        artistInfo: @artistsInfo.alexandraHood
        title: 'Blue Landscape'
        caption: "Oil on canvas, 18 × 24 inches"
      concreteFeet:
        artistInfo: @artistsInfo.alexandraHood
        title: 'Concrete Feet'
        caption: "Oil on canvas, 18 × 24 inches"
      botanicalIii:
        artistInfo: @artistsInfo.alexandraHood
        title: 'Botanical III'
        caption: "Micron pen on cotton rag paper (light green), 5 × 5 inches"
      botanicalIx:
        artistInfo: @artistsInfo.alexandraHood
        title: 'Botanical IX'
        caption: "Micron pen on 100% Cotton Rag Paper, 5 × 5 inches"
      botanicalV:
        artistInfo: @artistsInfo.alexandraHood
        title: 'Botanical V'
        caption: "Micron pen on cotton rag paper (light green), 5 × 5 inches"
      everybodyWantsToRuleTheWorld:
        artistInfo: @artistsInfo.alexandraHood
        title: 'Everybody Wants to Rule the World'
        caption: "Oil on canvas, 30 × 40 inches"
      evilIsLoveSpelledBackwards:
        artistInfo: @artistsInfo.alexandraHood
        title: 'Evil Is Love Spelled Backwards'
        caption: "Charcoal on paper, 16 × 20 inches"
      humanAnatomyStudies:
        artistInfo: @artistsInfo.alexandraHood
        title: 'Human Anatomy Studies'
        caption: "Pencil in sketchbook"
      nineToFive:
        artistInfo: @artistsInfo.alexandraHood
        title: 'Nine to Five'
        caption: "Oil on canvas, 20 × 20 inches"
      pop:
        artistInfo: @artistsInfo.alexandraHood
        title: 'Pop!'
        caption: "Oil on canvas, 18 × 24 inches"
      selfPortraitWithHair:
        artistInfo: @artistsInfo.alexandraHood
        title: 'Self Portrait With Hair'
        caption: "Graphite on Bristol board, 16 × 20 inches"
      withersFamily:
        artistInfo: @artistsInfo.alexandraHood
        title: 'Withers Family'
        caption: "Graphite on Bristol paper (mechanical pencils), 6 × 9 inches"
  
      # Gabrielle Brickey

      angel:
        artistInfo: @artistsInfo.gabrielleBrickey
        title: 'Angel'
        caption: "Graphite (mechanical pencils, 3H & 4B lead), colored Copic markers, and white gel pen on paper, 6 × 5 inches"
      bouguereauStudy:
        artistInfo: @artistsInfo.gabrielleBrickey
        title: 'Bouguereau Study'
        caption: "Grey pastel pencils, chalks, charcoal, and white charcoal on grey paper, 9 × 12 inches"
      inAFeeling:
        artistInfo: @artistsInfo.gabrielleBrickey
        title: 'In a Feeling'
        caption: "Charcoal on grey paper, 9 × 12 inches"
      inAMoment:
        artistInfo: @artistsInfo.gabrielleBrickey
        title: 'In a Moment'
        caption: "Charcoal on grey paper, 9 × 12 inches"
      oilPainting:
        artistInfo: @artistsInfo.gabrielleBrickey
        title: 'Oil Painting'
        caption: "Oil on linen, 8 × 12 inches"
      weCaughtOnFire:
        artistInfo: @artistsInfo.gabrielleBrickey
        title: ':we caught on fire:'
        caption: "Pastels on light tan paper, 9 × 12 inches"

      # Hendry Roesly

      day9:
        artistInfo: @artistsInfo.hendryRoesly
        title: 'Day 9'
        caption: "Pen, graphite, and markers on paper"
      desert:
        artistInfo: @artistsInfo.hendryRoesly
        title: 'Desert'
        caption: "Pen and graphite on paper"
      kuria:
        artistInfo: @artistsInfo.hendryRoesly
        title: 'Kuria'
        caption: "Pen and graphite on paper"
      survivor:
        artistInfo: @artistsInfo.hendryRoesly
        title: 'Survivor'
        caption: "Pen and markers on paper"

      # Jorge Monreal

      adventureTime:
        artistInfo: @artistsInfo.jorgeMonreal
        title: 'Adventure time'
        caption: "Acrylic on canvas, 19.7 × 15.7 inches"
      blueGirl2:
        artistInfo: @artistsInfo.jorgeMonreal
        title: 'Blue girl 2'
        caption: "Acrylic on canvas, 19.7 × 15.7 inches"
      skullGirl3:
        artistInfo: @artistsInfo.jorgeMonreal
        title: 'Skull girl 3'
        caption: "Acrylic on canvas, 31.5 × 23.6 inches"

      # Matej Jan

      africa:
        artistInfo: @artistsInfo.matejJan
        title: 'Africa'
        caption: "Soft pastels on velour paper, 8.3 × 11.7 inches"
      blonde:
        artistInfo: @artistsInfo.matejJan
        title: 'Blonde'
        caption: "Digital (Watercolor on WaterColor Paper, ArtRage 3 Studio Pro, Wacom Intuos 2), 1080 × 1620 pixels"
        nonPixelArt: true
      blueBottle:
        artistInfo: @artistsInfo.matejJan
        title: 'Blue Bottle'
        caption: "Conté Crayon on black paper, 12 × 18 inches"
      bust:
        artistInfo: @artistsInfo.matejJan
        title: 'Bust'
        caption: "Conté Crayon on paper, 12 × 18 inches"
      cardinalCity:
        artistInfo: @artistsInfo.matejJan
        title: 'Cardinal City'
        caption: """
          Mixed media on tan paper panel
          (Paper Mate Flair felt tip pen, Prismacolor warm grey markers, red and white chalk pencils, Gelly Roll white gel pen, Molotov white acrylic pen),
          40 × 32 inches
        """
      cardinalCityTools:
        artistInfo: @artistsInfo.matejJan
        title: 'Cardinal City tools'
        caption: """
          Tools used for Cardinal City
          (Paper Mate Flair felt tip pen, Prismacolor warm grey markers, white chalk pencil, Molotov white acrylic pen, Gelly Roll white gel pen, not pictured: red chalk pencil)
        """
      dayAtTheBeach:
        artistInfo: @artistsInfo.matejJan
        title: 'Day at the Beach'
        caption: "Watercolors on paper, 24 × 18 inches"
      desertMatejJan:
        artistInfo: @artistsInfo.matejJan
        title: 'Desert'
        caption: "Digital (Oil Brush on Smooth Canvas, ArtRage 3 Studio Pro, Wacom Intuos 2), 1600 × 900 pixels"
        nonPixelArt: true
      desolation:
        artistInfo: @artistsInfo.matejJan
        title: 'Desolation'
        caption: "Oil on canvas (cold wax medium, palette knife application), 36 × 24 inches"
      giveMeTheSky:
        artistInfo: @artistsInfo.matejJan
        title: 'Give me the Sky'
        caption: "Digital (Chalk on Sketch Paper, ArtRage 3 Studio Pro, Wacom Intuos 2), 3000 × 2000 pixels"
        nonPixelArt: true
      lotusEspritTurbo:
        artistInfo: @artistsInfo.matejJan
        title: 'Lotus Esprit Turbo'
        caption: "Soft pastels on dark grey paper, 16.5 × 11.7 inches"
      handStudy:
        artistInfo: @artistsInfo.matejJan
        title: 'Hand Study'
        caption: "Graphite and white chalk on Toned Tan paper, 9 × 12 inches"
      hillary:
        artistInfo: @artistsInfo.matejJan
        title: 'Hillary'
        caption: "Graphite on paper, 6 × 8 inches"
      inventory:
        artistInfo: @artistsInfo.matejJan
        title: 'Inventory'
        caption: "Drawing tools test sheet, 9 × 12 inches (crop)"
      kaley:
        artistInfo: @artistsInfo.matejJan
        title: 'Kaley'
        caption: "Colored pencils on paper, 8.3 × 11.7 inches"
      lioness:
        artistInfo: @artistsInfo.matejJan
        title: 'Lioness'
        caption: "Digital (Acrylic brush, GIMP, Wacom Intuos 2), 2343 × 2343 pixels"
        nonPixelArt: true
      memchu:
        artistInfo: @artistsInfo.matejJan
        title: 'Memchu'
        caption: "Watercolors and graphite on paper, 24 × 18 inches"
      neukomWip1:
        artistInfo: @artistsInfo.matejJan
        title: 'Neukom'
        url: '/retronator/hq/locations/artstudio/artworks/matej-jan-neukom-wip-1.jpg'
        caption: "Step 1: pencil base"
      neukomWip2:
        artistInfo: @artistsInfo.matejJan
        title: 'Neukom'
        url: '/retronator/hq/locations/artstudio/artworks/matej-jan-neukom-wip-2.jpg'
        caption: "Step 2: pen lineart"
      neukomWip3:
        artistInfo: @artistsInfo.matejJan
        title: 'Neukom'
        url: '/retronator/hq/locations/artstudio/artworks/matej-jan-neukom-wip-3.jpg'
        caption: "Step 3: pencil cast shadows"
      neukom:
        artistInfo: @artistsInfo.matejJan
        title: 'Neukom'
        url: '/retronator/hq/locations/artstudio/artworks/matej-jan-neukom.jpg'
        caption: "Graphite, pen, and watercolor pencils on paper, 18 × 24 inches"
      night21:
        artistInfo: @artistsInfo.matejJan
        title: 'Night 21'
        caption: "Digital (Classic Pencil on Paper Grain, Linea Sketch, iPad Pro, Apple Pencil), 2048 × 2732 pixels"
        nonPixelArt: true
      reignite6:
        artistInfo: @artistsInfo.matejJan
        title: 'Reignite 6'
        caption: "Digital (Oil Brush on Canvas, ArtRage for iOS, iPad Pro, Apple Pencil), 1152 × 2048 pixels"
        nonPixelArt: true
      octobitDay2Astronaut:
        artistInfo: @artistsInfo.matejJan
        title: 'Octobit day 2: Astronaut'
        caption: "Digital (HD Index Painting technique, Photoshop, Astropad, Apple Pencil), 340 × 192 pixels"
      retropolisInternationalSpacestationMainTower:
        artistInfo: @artistsInfo.matejJan
        title: 'Retropolis International Spacestation: Main Tower'
        caption: "Digital (white Classic Pencil on Blueprint, Linea Sketch, iPad Pro, Apple Pencil), 2732 × 2048 pixels"
        nonPixelArt: true
      rodin:
        artistInfo: @artistsInfo.matejJan
        title: 'Rodin'
        caption: "Charcoal on paper (pencils and sticks), 18 × 24 inches"
      skogsra:
        artistInfo: @artistsInfo.matejJan
        title: 'Skogsra'
        caption: "Graphite on Bristol vellum paper (mechanical pencils, Pentel 0.5mm 3H & 4B lead), 9 × 12 inches"

      # Maya Pixelskaya

      streetFighterConverseChucks:
        artistInfo: @artistsInfo.mayaPixelskaya
        title: 'Street Fighter Converse chucks'
        caption: "Fabric paint on fabric"
      streetFighterIiTriptych:
        artistInfo: @artistsInfo.mayaPixelskaya
        title: 'Street Fighter II triptych'
        caption: "Acrylic on canvas, 11.8 × 11.8 inches (each canvas)"

      # Octavi Navarro

      escape:
        artistInfo: @artistsInfo.octaviNavarro
        title: 'Escape'
        caption: "Acrylic on board, 23.6 × 15.7 inches"
      pumpkinRoad:
        artistInfo: @artistsInfo.octaviNavarro
        title: 'Pumpkin Road'
        caption: "Acrylic on board, 15.7 × 23.6 inches"

      # Sylvain Sarrailh

      amazing:
        artistInfo: @artistsInfo.sylvainSarrailh
        title: 'Amazing'
        caption: "Digital (Photoshop), 1728 × 972 pixels"
        nonPixelArt: true
      forestOfLiarsSunsetOnTheWoodBridge:
        artistInfo: @artistsInfo.sylvainSarrailh
        title: 'Forest of Liars: Sunset on the wood bridge'
        caption: "Digital (Photoshop), 1000 × 1483 pixels"
        nonPixelArt: true
      theForgottenEmpire:
        artistInfo: @artistsInfo.sylvainSarrailh
        title: 'The Forgotten Empire'
        caption: "Digital (Photoshop), 1536 × 864 pixels"
        nonPixelArt: true
      unchartedBookCover:
        artistInfo: @artistsInfo.sylvainSarrailh
        title: 'Uncharted Book Cover'
        caption: "Digital (Photoshop), 1004 × 1418 pixels"
        nonPixelArt: true
