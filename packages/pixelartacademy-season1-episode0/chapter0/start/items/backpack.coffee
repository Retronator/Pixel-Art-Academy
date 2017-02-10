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
    openHint: "You can ![open it](open backpack) to see its contents."

  @initialize()

  description: ->
    opened = @state 'opened'

    return super if opened

    "#{super} #{@translations().openHint}"

  @listenerClasses: -> [
    @Listener
  ]

  class @Listener extends LOI.Adventure.Listener
    @scriptUrls: -> [
      'retronator_pixelartacademy-season1-episode0/chapter0/start/items/backpack.script'
    ]

    class @Scripts.Backpack extends LOI.Adventure.Script
      @id: -> 'PixelArtAcademy.Season1.Episode0.Chapter0.Start.Backpack'
      @initialize()

    @initialize()

    onCommand: (commandResponse) ->
      backpack = @options.parent

      commandResponse.onPhrase
        form: [[Vocabulary.Keys.Verbs.Get], backpack.avatar]
        action: =>
          inInventory = backpack.state 'inInventory'

          if inInventory
            LOI.adventure.director.startScript @scripts[@constructor.Scripts.Backpack.id()], label: 'AlreadyInInventory'
            return

          backpack.state 'inInventory', true

          true

      commandResponse.onPhrase
        form: [[Vocabulary.Keys.Verbs.Open, Vocabulary.Keys.Verbs.Use], backpack.avatar]
        action: =>
          opened = backpack.state 'opened'

          if opened
            LOI.adventure.director.startScript @scripts[@constructor.Scripts.Backpack.id()], label: 'AlreadyOpened'
            return

          inInventory = backpack.state 'inInventory'

          unless inInventory
            LOI.adventure.director.startScript @scripts[@constructor.Scripts.Backpack.id()], label: 'UseOutsideInventory'
            return

          backpack.state 'opened', true

          true

      commandResponse.onPhrase
        form: [[Vocabulary.Keys.Verbs.Close], backpack.avatar]
        action: =>
          opened = backpack.state 'opened'

          unless opened
            LOI.adventure.director.startScript @scripts[@constructor.Scripts.Backpack.id()], label: 'AlreadyClosed'
            return

          inInventory = backpack.state 'inInventory'

          unless inInventory
            LOI.adventure.director.startScript @scripts[@constructor.Scripts.Backpack.id()], label: 'UseOutsideInventory'
            return

          backpack.state 'opened', false

          true
