LOI = LandsOfIllusions
PAA = PixelArtAcademy

Vocabulary = LOI.Adventure.Parser.Vocabulary

Action = LOI.Adventure.Ability.Action
Talking = LOI.Adventure.Ability.Talking

class PAA.LandingPage.Locations.Retropolis extends LOI.Adventure.Location
  @id: -> 'PixelArtAcademy.LandingPage.Locations.Retropolis'
  @url: -> ''
  @scriptUrls: -> [
  ]

  @fullName: -> "Retropolis Landing Page"
  @shortName: -> "Retropolis"
  @description: ->
    "
      You exit the Retropolis International Spaceport. A
      magnificent view of the city opens before you. Armed
      with a suitcase and a burning desire to become a
      pixel artist, you feel the adventure in the air.
    "
    
  @welcomeHostname = true
  @illustrationHeight: -> 1000

  @initialize()

  constructor: ->
    super

  @initialState: ->
    things = {}
    things[PAA.LandingPage.Items.About.id()] = {}

    exits = {}

    _.merge {}, super,
      things: things
      exits: exits
