LOI = LandsOfIllusions
HQ = Retronator.HQ

class HQ.Actors.Burra extends LOI.Character.Actor
  @id: -> 'Retronator.HQ.Actors.Burra'
  @fullName: -> "Sarah 'Burra' Burrough"
  @shortName: -> "Burra"
  @descriptiveName: -> "Sarah '![Burra](talk to Burra)' Burrough."
  @description: -> "It's Sarah Burrough a.k.a. Burra."
  @pronouns: -> LOI.Avatar.Pronouns.Feminine
  @color: ->
    hue: LOI.Assets.Palette.Atari2600.hues.green
    shade: LOI.Assets.Palette.Atari2600.characterShades.darkest

  @assetUrls: -> '/retronator/hq/actors/burra'

  @translations: ->
    translations =
      greet: 'She greets you from across the counter.'

    # She's the _____ at Retronator.
    shesTheDescriptions = [
      "receptionist"
      "front of house"
      "customer service"
      "femme fatale"
      "overlord of Pixel Art Academy"
      "marketing dandy"
      "knitter"
      "expert tea drinker"
      "guest blogger"
      "troll slayer"
      "administrator extraordinaire"
      "meet and greeter"
      "British stereotype"
    ]

    shesTheDescriptions = ("She is the #{description} at Retronator." for description in shesTheDescriptions)

    sheIsDescriptions = [
      "a weather obsessive"
      "plotting like it’s Game of Thrones"
      "trying to work out if Retro is real"
      "Mrs. Joe Manganiello"
      "a Moneypenny wannabe"
    ]

    sheIsDescriptions = ("She is #{description}." for description in sheIsDescriptions)

    descriptions = _.flatten [
      shesTheDescriptions
      sheIsDescriptions
      "She loves cake."
    ]

    @_descriptionsCount = descriptions.length

    for description, index in descriptions
      translations["description#{index}"] = description

    translations

  @initialize()

  description: ->
    # Pick one of the descriptions on random.
    index = Random.choice [0...@constructor._descriptionsCount]

    extraDescription = @translations()["description#{index}"]

    "#{super arguments...} #{extraDescription}"
