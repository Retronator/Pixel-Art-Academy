AE = Artificial.Everywhere
AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy

Vocabulary = LOI.Parser.Vocabulary
Directions = Vocabulary.Keys.Directions

class PAA.Items.Map.Node extends AM.Component
  @register 'PixelArtAcademy.Items.Map.Node'
  
  onCreated: ->
    super

    location = @data()

    @map = @ancestorComponent PAA.Items.Map

    @size = new ComputedField =>
      location = @data()
      return unless mapSize = @map.size()

      # Get the map width in game pixels.
      scale = LOI.adventure.interface.display.scale()
      mapWidth = mapSize.width() / scale
      mapHeight = mapSize.height() / scale

      # Nodes should take 1/3 of the mini-map width, with two 9px gaps in between.
      width = Math.floor (mapWidth - 2 * 9) / 3
      height = 17
      nodeGap = 9
      outerNodeGap = 3

      center =
        left: mapWidth / 2
        top: mapHeight / 2

      left = center.left - width * 0.5
      top = center.top - height * 0.5

      switch location.direction
        when Directions.Northwest, Directions.West, Directions.Southwest
          left = center.left - width * 1.5 - nodeGap

        when Directions.Northeast, Directions.East, Directions.Southeast
          left = center.left + width * 0.5 + nodeGap

      switch location.direction
        when Directions.Northwest, Directions.North, Directions.Northeast
          top = center.top - height * 1.5 - nodeGap

        when Directions.Southwest, Directions.South, Directions.Southeast
          top = center.top + height * 0.5 + nodeGap

      if location.specialDirection and not location.direction
        switch location.specialDirection
          when Directions.Up, Directions.In
            top = center.top - height * 1.5 - nodeGap
            top -= height + nodeGap + outerNodeGap if @map.anyNorthLocations()

          when Directions.Down, Directions.Out
            top = center.top + height * 0.5 + nodeGap
            top += height + nodeGap + outerNodeGap if @map.anySouthLocations()

      new AE.Rectangle left, top, width, height
    ,
      EJSON.equals

  onRendered: ->
    super

    Meteor.setTimeout =>
      @$('.pixelartacademy-items-map-node').addClass('visible')
    ,
      500

  name: ->
    location = @data()
    _.deburr location.avatar.shortName()

  directionClass: ->
    location = @data()

    @_makeDirectionClass location.direction

  specialDirectionClass: ->
    location = @data()

    @_makeDirectionClass location.specialDirection

  _makeDirectionClass: (directionId) ->
    return unless directionId

    # Remove "Direction." part
    directionClass = directionId.substring directionId.indexOf('.') + 1

    _.toLower directionClass

  currentClass: ->
    location = @data()

    'current' if location.current

  nodeStyle: ->
    return unless size = @size()?.toDimensions()

    width: "#{size.width}rem"
    height: "#{size.height}rem"
    top: "#{size.top}rem"
    left: "#{size.left}rem"
