LOI = LandsOfIllusions

class LOI.Character.Part.Property.Array extends LOI.Character.Part.Property
  # An array property is a node with fields giving the order (with a floating point number with _ instead of .) of its parts.
  # node
  #   fields
  #     {order1}
  #     {order2}
  #     ...
  constructor: (@options = {}) ->
    super arguments...

    @type = 'array'

    return unless @options.dataLocation

    @parts = new ReactiveField []

    @_partsByOrder = {}
    @partsByOrder = new ReactiveField @_partsByOrder

    # Instantiate array parts that are in the data.
    @_arrayAutorun = Tracker.autorun =>
      partsNode = @options.dataLocation()
      fields = partsNode?.data()?.fields

      unless fields
        # Clean any previous parts.
        @_partsByOrder = {}
        @partsByOrder {}
        @parts []
        return

      dotFields = {}
      for orderKey, value of fields
        dotFields[orderKey.replace '_', '.'] = value

      dotFieldKeys = _.map _.keys(dotFields), (orderKey) -> parseFloat orderKey
      orderedDotFieldKeys = _.sortBy dotFieldKeys, (key) -> key
      @_highestOrder = if orderedDotFieldKeys.length then _.last orderedDotFieldKeys else null

      partsByOrder = {}
      parts = for dotFieldKey in orderedDotFieldKeys
        fieldKey = "#{dotFieldKey}".replace '.', '_'

        # Create a property that reads from data location with this order key.
        partData = fields[fieldKey]
        part = @_partsByOrder[dotFieldKey]

        # If we have the part already, make sure it's of the correct type.
        unless part?.options.type is partData.type or not partData.type
          Tracker.nonreactive =>
            partDataLocation = @options.dataLocation.child fieldKey

            # Add array field meta data so that it will be preserved when
            # changing data in this field (e.g. when changing to templates).
            partDataLocation.setMetaData
              type: partData.type

            if partClass = LOI.Character.Part.getClassForType partData.type
              part = partClass.create
                dataLocation: partDataLocation
                parent: @

          # Add the _id field so that foreach knows to reuse/recreate the field.
          part._id = Random.id() if part

        partsByOrder[dotFieldKey] = part

        part

      # Clean out undefined parts that would appear in case any class type was missing.
      parts = _.without parts, undefined

      # Update local cache.
      @_partsByOrder = partsByOrder

      # Update reactive field.
      @partsByOrder partsByOrder

      # Update reactive parts array.
      @parts parts

  destroy: ->
    super arguments...

    @_arrayAutorun.stop()

  create: (options) ->
    newArray = super arguments...

    if @options.templateType
      # Override template type if we have set it.
      options.dataLocation.setTemplateMetaData
        type: @options.templateType

    newArray

  newPart: (type) ->
    newOrder = if @_highestOrder? then @_highestOrder + 1 else 0
    newField = "#{newOrder}".replace '.', '_'

    newDataLocation = @options.dataLocation.child newField

    # Set field meta data.
    newDataLocation.saveMetaData
      type: type

    if partClass = LOI.Character.Part.getClassForType type
      partClass.create
        dataLocation: newDataLocation
        parent: @

  reorderPart: (part, newPartIndex) ->
    oldPartIndex = @parts().indexOf part
    return if oldPartIndex is newPartIndex

    partPairs = _.toPairs @_partsByOrder
    partPair[0] = parseFloat partPair[0] for partPair in partPairs
    partPairs = _.sortBy partPairs, (pair) => pair[0]

    oldPartOrder = partPairs[oldPartIndex][0]

    # Remove moving part so we can calculate which parts we need to place the moving part in between.
    _.remove partPairs, (pair) => pair[1] is part

    if newPartIndex is 0
      newPartOrder = partPairs[newPartIndex][0] - 1

    else if newPartIndex >= partPairs.length
      newPartOrder = partPairs[partPairs.length - 1][0] + 1

    else
      newPartOrder = (partPairs[newPartIndex - 1][0] + partPairs[newPartIndex][0]) / 2

    partsNode = @options.dataLocation()
    fields = partsNode?.data()?.fields

    # Clone the moving part to the new order.
    oldPartField = "#{oldPartOrder}".replace '.', '_'
    movingPartData = fields[oldPartField]

    newPartField = "#{newPartOrder}".replace '.', '_'
    newLocation = @options.dataLocation.child newPartField

    # Send in the raw data value.
    newLocation movingPartData, true

    # Remove current part data.
    part.options.dataLocation.remove()
