LOI = LandsOfIllusions

class LOI.Character.Part.Property.Array extends LOI.Character.Part.Property
  # An array property is a node with fields numbered 0 to count
  # node
  #   fields
  #     count: total number of elements in the array
  #     0
  #     1
  #     ...
  constructor: (@options = {}) ->
    super

    @type = 'array'

    return unless @options.dataLocation

    @parts = new ReactiveField []

    # Instantiate array parts that are in the data.
    @_arrayAutorun = Tracker.autorun =>
      partsNode = @options.dataLocation()
      return unless partsNode

      return unless fields = partsNode.data()?.fields

      parts = for index in [0..fields.count]
        partData = fields[index]

        LOI.Character.Part.Types[partData.type].create
          dataLocation: @options.dataLocation.child index

      @parts parts

  destroy: ->
    super

    @_arrayAutorun.stop()
