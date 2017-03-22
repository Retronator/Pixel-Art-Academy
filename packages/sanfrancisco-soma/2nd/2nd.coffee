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
      You found yourself on 2nd Street in San Francisco. Companies such as LinkedIn and Zipcar have offices here …
      as well as Retronator. Retronator headquarters sport a café, store, gallery and a coworking space. It's all very
      inviting 
    "
  
  @initialize()

  constructor: ->
    super

  things: -> [
    Soma.SecondStreet.RetronatorHQ
  ]

  exits: ->
    "#{Vocabulary.Keys.Directions.Southwest}": Soma.MosconeCenter
    "#{Vocabulary.Keys.Directions.In}": Retronator.HQ.Cafe
