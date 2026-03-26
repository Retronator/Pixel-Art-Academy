AS = Artificial.Spectrum
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
      AS.PixelArt.Circle.getShape diameter

    else
      size = Math.round diameter
  
      for x in [0...size]
        for y in [0...size]
          true
