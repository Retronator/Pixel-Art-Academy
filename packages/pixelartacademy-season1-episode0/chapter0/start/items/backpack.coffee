LOI = LandsOfIllusions
C0 = PixelArtAcademy.Season1.Episode0.Chapter0

Vocabulary = LOI.Parser.Vocabulary

class C0.Start.Backpack extends LOI.Adventure.Thing
  @id: -> 'PixelArtAcademy.Season1.Episode0.Chapter0.Start.Backpack'
  @register @id()

  @version: -> '0.0.1'

  @fullName: -> "backpack"

  @description: ->
    "
      It's your backpack with important things you brought from the mainland.
    "

  @translations: ->
    openHint: "You can (open it)[open backpack] to see its contents."

  @initialize()
  
  description: ->
    opened = @stateObject 'opened'
    
    return @constructor.description() unless opened

    "#{@constructor.description()} #{@translations().openHint}"

  @listenerClasses: -> [
    @Listener
  ]

  class @Listener extends LOI.Adventure.Listener
    @scriptUrls: -> [
      'retronator_pixelartacademy-season1-episode0/chapter0/start/items/backpack.script'
    ]

    class @Scripts.Backpack extends LOI.Adventure.Script
      @id: -> 'PixelArtAcademy.Season1.Episode0.Chapter1.Immigration.Backpack'
      @initialize()

    @initialize()

    onCommand: (commandResponse) ->
      backpack = @options.parent

      commandResponse.onPhrase
        form: [[Vocabulary.Keys.Verbs.Get], backpack.avatar]
        action: =>
          inInventory = backpack.stateObject 'inInventory'
  
          if inInventory
            LOI.adventure.director.startScript @scripts[@constructor.Scripts.Backpack.id()], 'AlreadyInInventory'
            return

          backpack.stateObject 'inInventory', true

          true

      commandResponse.onPhrase
        form: [[Vocabulary.Keys.Verbs.Open, Vocabulary.Keys.Verbs.Use], backpack.avatar]
        action: =>
          opened = backpack.stateObject 'opened'

          if opened
            LOI.adventure.director.startScript @scripts[@constructor.Scripts.Backpack.id()], 'AlreadyOpened'
            return

          inInventory = backpack.stateObject 'inInventory'

          unless inInventory
            LOI.adventure.director.startScript @scripts[@constructor.Scripts.Backpack.id()], 'OpenOutsideInventory'
            return

          backpack.stateObject 'opened', true

          true
