AE = Artificial.Everywhere
LOI = LandsOfIllusions
PAA = PixelArtAcademy

Vocabulary = LOI.Parser.Vocabulary

class PAA.Items.StillLifeItems.Item extends LOI.Adventure.Item
  @collected: -> @state 'collected'

  @assetsPath: -> throw new AE.NotImplementedException "You must provide an asset path where the icon for the item is found."

  @unlessCollected: ->
    if @collected() then null else @

  displayInInventory: -> false

  # Listener

  onCommand: (commandResponse) ->
    item = @options.parent

    commandResponse.onPhrase
      form: [Vocabulary.Keys.Verbs.Get, item.avatar]
      action: =>
        item.state 'collected', true

        PAA.Items.StillLifeItems.addItemOfType item.id()

        # Report OK to the user.
        true
