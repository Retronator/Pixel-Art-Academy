FM = FataMorgana
LOI = LandsOfIllusions

class LOI.Assets.SpriteEditor.Helpers.Brush extends FM.Helper
  # diameter: the size of the brush
  # round: boolean whether this is a round instead of a square brush
  @id: -> 'LandsOfIllusions.Assets.SpriteEditor.Helpers.Brush'
  @initialize()
  
  constructor: ->
    super arguments...

    @aliasedShape = new ComputedField =>
      @aliasedShapeForDiameter @diameter()
    ,
      EJSON.equals

    @aliasedSize = new ComputedField =>
      @aliasedShape().length

  diameter: -> @data.get('diameter') or 1
  round: -> @data.get 'round'

  setDiameter: (diameter) -> @data.set 'diameter', diameter
  setRound: (round) -> @data.set 'round', round

  aliasedShapeForDiameter: (diameter) ->
    if round = @round()
      # See which size we need to have to fill a circle with this diameter.
      size = Math.floor diameter

      biggerSize = size + 1
      biggerSizeCenter = (biggerSize - 1) / 2
      biggerSizeOffset = biggerSizeCenter - Math.floor biggerSizeCenter

      # Maximum distance to be filled must be smaller than the radius so that the bigger size would be fully filled.
      radius = diameter / 2
      maxDistance = Math.sqrt(Math.pow(biggerSizeCenter, 2) + Math.pow(biggerSizeOffset, 2))
      size = biggerSize if maxDistance < radius

      center = (size - 1) / 2

    else
      size = Math.round diameter

    for x in [0...size]
      for y in [0...size]
        if round
          distance = Math.sqrt(Math.pow(x - center, 2) + Math.pow(y - center, 2))
          distance < radius

        else
          true
