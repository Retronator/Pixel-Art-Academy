LOI = LandsOfIllusions

Vocabulary = LOI.Parser.Vocabulary

class LOI.Construct.Loading extends LOI.Adventure.Location
  @id: -> 'LandsOfIllusions.Construct.Loading'
  @url: -> 'loader'
  @region: -> LOI.Construct

  @version: -> '0.0.1'

  @fullName: -> "The Loader program"
  @shortName: -> "Loader"
  @description: ->
    "
      You find yourself in an open white space, extending into infinity.
    "
  
  @initialize()

  constructor: ->
    super

    $('body').addClass('construct')

  destroy: ->
    super

    $('body').removeClass('construct')
