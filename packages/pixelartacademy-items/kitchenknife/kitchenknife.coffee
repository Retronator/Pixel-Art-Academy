LOI = LandsOfIllusions
PAA = PixelArtAcademy

Vocabulary = LOI.Parser.Vocabulary

class PAA.Items.KitchenKnife extends LOI.Adventure.Item
  @id: -> 'PixelArtAcademy.Items.KitchenKnife'
  @fullName: -> "kitchen knife"
  @shortName: -> "knife"
  @nameAutoCorrectStyle: -> LOI.Avatar.NameAutoCorrectStyle.Name
  @descriptiveName: -> "Kitchen ![knife](use knife)."
  @description: ->
    "
      It's an all-purpose kitchen knife. Great for cutting fruit in half.
    "

  @defaultScriptUrl: -> 'retronator_pixelartacademy-items/kitchenknife/kitchenknife.script'

  @initialize()

  # Listener

  @avatars: ->
    half: PAA.Items.KitchenKnife.Half

  onCommand: (commandResponse) ->
    kitchenKnife = @options.parent

    commandResponse.onPhrase
      form: [Vocabulary.Keys.Verbs.Get, kitchenKnife]
      action: =>
        @startScript label: 'CantGet'

    commandResponse.onPhrase
      form: [Vocabulary.Keys.Verbs.Use, kitchenKnife]
      action: =>
        @startScript label: 'CutWhat'

    # See if we have any things we can cut in half.
    addCutActions = (things, action) =>
      for thing in things
        thingClass = _.thingClass(thing)

        # We can only cut still life items that have a Half class defined.
        continue unless thingClass.prototype instanceof PAA.Items.StillLifeItems.Item and thingClass.Half

        do (thing) =>
          expandedAction = =>
            @script.ephemeralState 'thingToCut', thing.shortName()
            action thing

          commandResponse.onPhrase
            form: [Vocabulary.Keys.Verbs.UseWith, kitchenKnife, thing]
            action: expandedAction

          commandResponse.onPhrase
            form: [Vocabulary.Keys.Verbs.CutWith, thing, kitchenKnife]
            action: expandedAction

          commandResponse.onPhrase
            form: [Vocabulary.Keys.Verbs.Cut, thing]
            action: expandedAction

          commandResponse.onPhrase
            form: [Vocabulary.Keys.Verbs.CutIn, thing, @avatars.half]
            action: expandedAction

    addHalvesToStillLifeItems = (thing) =>
      thingHalfClass = _.thingClass(thing).Half
      PAA.Items.StillLifeItems.addItemOfType thingHalfClass for i in [1..2]

    addCutActions LOI.adventure.currentInventoryThings(), (thing) =>
      # Remove the thing we're cutting.
      PAA.Items.StillLifeItems.removeItem thing.copyId

      @startScript label: 'CutInventoryThingInHalf'

      addHalvesToStillLifeItems thing

    addCutActions LOI.adventure.currentLocationThings(), (thing) =>
      # Mark item as collected.
      thing.state 'collected', true

      # Start the cutting action.
      @startScript label: 'CutLocationThingInHalf'

      addHalvesToStillLifeItems thing
