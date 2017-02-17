LOI = LandsOfIllusions
C1 = PixelArtAcademy.Season1.Episode0.Chapter1

Vocabulary = LOI.Parser.Vocabulary

class C1.Suitcase extends LOI.Adventure.Thing
  @id: -> 'PixelArtAcademy.Season1.Episode0.Chapter1.Suitcase'
  @register @id()

  @version: -> '0.0.1'

  @fullName: -> "suitcase"

  @description: ->
    "
      The suitcase holds mainly your clothes and other necessities.
    "

  @listeners: -> [
    @Listener
  ]
    
  @initialize()

  @defaultScriptUrl: -> 'retronator_pixelartacademy-season1-episode0/chapter1/items/suitcase.script'

  onCommand: (commandResponse) ->
    suitcase = @options.parent

    commandResponse.onPhrase
      form: [[Vocabulary.Keys.Verbs.Get], suitcase.avatar]
      action: =>
        if suitcase.state 'inInventory'
          @startScript label: 'AlreadyInInventory'
          return

        suitcase.state 'inInventory', true

        true
