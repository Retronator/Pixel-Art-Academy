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
    LOI.Avatar.initialize drink

  @createDrink: (drinkType) ->
    new LOI.Avatar @DrinkTypes[drinkType]

  @listeners: -> [
    @Listener
  ]

  @translations: ->
    fullName: "bottle of {{drinkName}}"
    emptyName: "empty bottle"
    fullDescription: "It says it contains {{drinkName}} and even has the exact time of bottling."
    emptyDescription: "It says to return the empty bottle to a vending machine or collection station."

  @initialize()

  constructor: ->
    super

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

  class @Listener extends LOI.Adventure.Listener
    @scriptUrls: -> [
      'retronator_pixelartacademy-items/bottle/bottle.script'
    ]

    class @Script extends LOI.Adventure.Script
      @id: -> 'PixelArtAcademy.Items.Bottle'
      @initialize()

      initialize: ->
        @setCallbacks
          Drink: (complete) =>
            bottle = @options.parent
            bottle.state 'drinkType', null
            complete()

    @initialize()

    onCommand: (commandResponse) ->
      bottle = @options.parent

      commandResponse.onPhrase
        form: [[Vocabulary.Keys.Verbs.DrinkFrom, Vocabulary.Keys.Verbs.Use], bottle.avatar]
        action: =>
          @_drink()

      drink = bottle.drink()

      if drink
        commandResponse.onPhrase
          form: [[Vocabulary.Keys.Verbs.Drink, Vocabulary.Keys.Verbs.Use], drink]
          action: =>
            @_drink()

    _drink: ->
      bottle = @options.parent

      if bottle.isEmpty()
        LOI.adventure.director.startScript @scripts[@constructor.Script.id()], label: 'DrinkFromEmpty'

      else
        LOI.adventure.director.startScript @scripts[@constructor.Script.id()], label: 'Drink'
