AE = Artificial.Everywhere
LOI = LandsOfIllusions
PAA = PixelArtAcademy

Vocabulary = LOI.Parser.Vocabulary

class PAA.Items.StillLifeItems.Item extends LOI.Adventure.Item
  @collected: -> @state 'collected'

  @assetsPath: -> throw new AE.NotImplementedException "You must provide an asset path where the icon for the item is found."

  @unlessCollected: ->
    if @collected() then null else @

  isVisible: -> false

  @stillLifeItemType: ->
    # Override in inherited classes to return the parent id, which is the actual type.
    @id()

  stillLifeItemType: -> @constructor.stillLifeItemType()

  # Listener

  onCommand: (commandResponse) ->
    item = @options.parent

    # You can pick up items that are in the location (to prevent picking up items in the inventory).
    currentLocationThings = LOI.adventure.currentLocationThings()
    containers = _.filter currentLocationThings, (thing) => thing instanceof PAA.Items.StillLifeItems.Container

    if item in currentLocationThings
      commandResponse.onPhrase
        form: [Vocabulary.Keys.Verbs.Get, item]
        action: =>
          # See if this item comes from a container.
          for container in containers
            containerItems = container.constructor.items()

            itemInContainer = _.find containerItems, (containerItem) -> containerItem.type is item.id() and containerItem.id is item._id

            if itemInContainer
              # The item comes from a container, so we need to remove it from there.
              container.constructor.removeItem itemInContainer.id

              # Add exactly the item with this ID to the still life items.
              PAA.Items.StillLifeItems.addItem itemInContainer.id, itemInContainer.type

              # Report OK to the user.
              return true

          # By default we just mark item as collected in the state (which will make it disappear if set so).
          item.state 'collected', true

          # See if the item is a copy.
          if item.copyId
            PAA.Items.StillLifeItems.addItem item.copyId, item.id()

          else
            # We have a generic item, so just add one of its type to the items.
            PAA.Items.StillLifeItems.addItemOfType item.stillLifeItemType?() or item.id()

          # Report OK to the user.
          true

    # You can place an inventory item into a container.
    currentInventoryThings = LOI.adventure.currentInventoryThings()

    if item in currentInventoryThings
      for container in containers
        do (container) =>
          commandResponse.onPhrase
            form: [Vocabulary.Keys.Verbs.PutIn, item, container]
            action: =>
              container.constructor.addItem item.copyId, item.id()
              PAA.Items.StillLifeItems.removeItem item.copyId

              # Report OK to the user.
              true
