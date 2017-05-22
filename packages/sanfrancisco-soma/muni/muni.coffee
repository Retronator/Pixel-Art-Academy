LOI = LandsOfIllusions
Soma = SanFrancisco.Soma

Vocabulary = LOI.Parser.Vocabulary

class Soma.Muni extends LOI.Adventure.Location
  @id: -> 'SanFrancisco.Soma.Muni'
  @url: -> 'sf/muni'
  @region: -> Soma

  @version: -> '0.0.1'

  @fullName: -> "Muni train"
  @shortName: -> "muni"
  @description: ->
    "
      You are on the Muni train, line T Third Street.
    "

  @defaultScriptUrl: -> 'retronator_sanfrancisco-soma/muni/muni.script'

  @initialize()
