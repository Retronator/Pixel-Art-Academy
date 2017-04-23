LOI = LandsOfIllusions
Soma = SanFrancisco.Soma

Vocabulary = LOI.Parser.Vocabulary

class Soma.SecondStreet extends LOI.Adventure.Location
  @id: -> 'SanFrancisco.Soma.SecondStreet'
  @url: -> 'sf/2nd-street'
  @scriptUrls: -> [
  ]

  @version: -> '0.0.1'

  @fullName: -> "2nd Street"
  @description: ->
    "
      You find yourself on 2nd Street in San Francisco. Companies such as LinkedIn and Zipcar have offices here …
      as well as Retronator. Retronator headquarters holds a café, store, gallery and a coworking space. It's all very
      enticing and inviting you to ![go in](in).
    "
  
  @initialize()

  constructor: ->
    super

  things: -> [
    Soma.SecondStreet.RetronatorHQ
    Soma.SecondStreet.ArtistSign
  ]

  exits: ->
    "#{Vocabulary.Keys.Directions.Southwest}": Soma.MosconeCenter
    "#{Vocabulary.Keys.Directions.In}": Retronator.HQ.Cafe
    "#{Vocabulary.Keys.Directions.West}": Retronator.HQ.Cafe
