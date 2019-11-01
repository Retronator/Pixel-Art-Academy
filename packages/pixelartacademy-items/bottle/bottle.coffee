LOI = LandsOfIllusions
PAA = PixelArtAcademy

Vocabulary = LOI.Parser.Vocabulary

class PAA.Items.Bottle extends LOI.Adventure.Item
  @id: -> 'PixelArtAcademy.Items.Bottle'
  @fullName: -> "bottle"
  @description: ->
    "
      It's some sort of augmented glass bottle that has a digital ink label.
    "

  @DrinkTypes:
    AppleJuice:
      id: 'PixelArtAcademy.Items.Bottle.AppleJuice'
      fullName: "apple juice"

    LemonLimeJuice:
      id: 'PixelArtAcademy.Items.Bottle.LemonLimeJuice'
      fullName: "lemon-lime juice"

    Water:
      id: 'PixelArtAcademy.Items.Bottle.Water'
      fullName: "water"

  for id, drink of @DrinkTypes
    LOI.Adventure.Thing.Avatar.initialize drink

  @createDrink: (drinkType) ->
    new LOI.Adventure.Thing.Avatar @DrinkTypes[drinkType]

  @translations: ->
    fullName: "bottle of {{drinkName}}"
    emptyName: "empty bottle"
    fullDescription: "It says it contains {{drinkName}} and even has the exact time of bottling."
    emptyDescription: "It says to return the empty bottle to a vending machine or collection station."

  @initialize()

  constructor: ->
    super arguments...

    @drink = new ComputedField =>
      drinkType = @state 'drinkType'
      return unless drinkType

      @constructor.createDrink drinkType

  fullName: ->
    return unless @translations()

    if @isEmpty()
      @translations().emptyName

    else
      @translations()?.fullName.replace '{{drinkName}}', @drink().fullName()

  description: ->
    drinkType = @state 'drinkType'

    if @isEmpty()
      extraDescription = @translations().emptyDescription

    else
      return @avatar.description() unless fullDescription = @translations().fullDescription
      extraDescription = fullDescription.replace '{{drinkName}}', @drink().fullName()

    "#{@avatar.description()} #{extraDescription}"

  isEmpty: ->
    not @drink()

  @defaultScriptUrl: -> 'retronator_pixelartacademy-items/bottle/bottle.script'

  initializeScript: ->
    bottle = @options.parent

    @setCallbacks
      Drink: (complete) ->
        bottle.state 'drinkType', null
        bottle.state 'lastDrinkTime', LOI.adventure.time()

        complete()

  onCommand: (commandResponse) ->
    bottle = @options.parent

    drinkAction = =>
      @startScript label: if bottle.isEmpty() then 'DrinkFromEmpty' else 'Drink'

    commandResponse.onPhrase
      form: [[Vocabulary.Keys.Verbs.DrinkFrom, Vocabulary.Keys.Verbs.Use], bottle.avatar]
      action: => drinkAction()

    drinkAvatar = bottle.drink()

    if drinkAvatar
      commandResponse.onPhrase
        form: [[Vocabulary.Keys.Verbs.Drink, Vocabulary.Keys.Verbs.Use], drinkAvatar]
        action: => drinkAction()

      commandResponse.onPhrase
        form: [Vocabulary.Keys.Verbs.Drink]
        action: => drinkAction()
