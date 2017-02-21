LOI = LandsOfIllusions
C1 = PixelArtAcademy.Season1.Episode0.Chapter1

Vocabulary = LOI.Parser.Vocabulary

class C1.Items.Backpack extends LOI.Adventure.Thing
  @id: -> 'PixelArtAcademy.Season1.Episode0.Chapter1.Items.Backpack'
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

  @defaultScriptUrl: -> 'retronator_pixelartacademy-season1-episode0/chapter1/items/backpack.script'

  onCommand: (commandResponse) ->
    backpack = @options.parent

    commandResponse.onPhrase
      form: [[Vocabulary.Keys.Verbs.Get], backpack.avatar]
      action: =>
        if backpack.state 'inInventory'
          @startScript label: 'AlreadyInInventory'
          return

        backpack.state 'inInventory', true

        true

    useOutsideInventory = =>
      return false if backpack.state 'inInventory'

      @startScript label: 'UseOutsideInventory'
      true

    commandResponse.onPhrase
      form: [[Vocabulary.Keys.Verbs.Open, Vocabulary.Keys.Verbs.Use, Vocabulary.Keys.Verbs.LookIn], backpack.avatar]
      action: =>
        return if useOutsideInventory()

        if backpack.state 'opened'
          @startScript label: 'AlreadyOpened'
          return

        backpack.state 'opened', true

        true

    commandResponse.onPhrase
      form: [[Vocabulary.Keys.Verbs.Close], backpack.avatar]
      action: =>
        return if useOutsideInventory()

        unless backpack.state 'opened'
          @startScript label: 'AlreadyClosed'
          return

        backpack.state 'opened', false

        true
