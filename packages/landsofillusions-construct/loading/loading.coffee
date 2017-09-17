LOI = LandsOfIllusions

Vocabulary = LOI.Parser.Vocabulary

class LOI.Construct.Loading extends LOI.Adventure.Location
  @id: -> 'LandsOfIllusions.Construct.Loading'
  @url: -> 'construct'
  @region: -> LOI.Construct

  @version: -> '0.0.1'

  @fullName: -> "The Loader program"
  @shortName: -> "Loader"
  @description: ->
    "
      You find yourself in an open white space, extending into infinity.
      Two red armchairs and an old-fashioned cathode ray tube television are the only items you can see.
    "
  
  @initialize()

  constructor: ->
    super

    $('body').addClass('construct')

  destroy: ->
    super

    $('body').removeClass('construct')

  things: -> [
    LOI.Construct.Loading.TV
  ]
