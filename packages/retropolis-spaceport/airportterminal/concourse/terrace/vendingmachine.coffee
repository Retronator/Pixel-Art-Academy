LOI = LandsOfIllusions
PAA = PixelArtAcademy
RS = Retropolis.Spaceport

Vocabulary = LOI.Parser.Vocabulary
Verbs = Vocabulary.Keys.Verbs

class RS.AirportTerminal.Terrace.VendingMachine extends LOI.Adventure.Item
  @id: -> 'Retropolis.Spaceport.AirshipTerminal.Terrace.VendingMachine'
  @fullName: -> "vending machine"
  @nameAutoCorrectStyle: -> LOI.Avatar.NameAutoCorrectStyle.Name
  @description: ->
    "
      It seems to dispense beverages.
    "
  @color: ->
    hue: LOI.Assets.Palette.Atari2600.hues.cyan
    shade: LOI.Assets.Palette.Atari2600.characterShades.normal

  @dialogDeliveryType: -> LOI.Avatar.DialogDeliveryType.Displaying
  @dialogTextTransform: -> LOI.Avatar.DialogTextTransform.Uppercase

  @initialize()

  # Script

  @defaultScriptUrl: -> 'retronator_retropolis-spaceport/airportterminal/concourse/terrace/vendingmachine.script'

  initializeScript: ->
    machine = @options.parent

    @setThings {machine}

    @setCallbacks
      PrepareDrink: (complete) =>
        drinkType = @ephemeralState 'drinkType'
        drink = PAA.Items.Bottle.createDrink drinkType

        @ephemeralState 'drink', drink

        complete()

      ReceiveBottle: (complete) =>
        drinkType = @ephemeralState 'drinkType'

        PAA.Items.Bottle.state 'drinkType', drinkType
        PAA.Items.Bottle.state 'inInventory', true

        complete()

      ReturnBottle: (complete) =>
        PAA.Items.Bottle.state 'inInventory', false
        complete()

  # Listener

  @avatars: ->
    bottle: PAA.Items.Bottle

  onCommand: (commandResponse) ->
    machine = @options.parent

    commandResponse.onPhrase
      form: [Vocabulary.Keys.Verbs.Use, machine.avatar]
      action: => @startScript()

    _returnBottle = => @startScript label: 'ReturnBottle'

    commandResponse.onPhrase
      form: [Vocabulary.Keys.Verbs.Return, @avatars.bottle]
      action: => _returnBottle()

    commandResponse.onPhrase
      form: [[Verbs.ReturnTo, Verbs.GiveTo, Verbs.UseWith, Verbs.UseIn], @avatars.bottle, machine.avatar]
      action: => _returnBottle()
