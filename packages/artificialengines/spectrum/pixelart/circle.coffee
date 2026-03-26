AS = Artificial.Spectrum

class AS.PixelArt.Circle
  @perfectDiameters = [
    1
    2
    2.82
    4
    5
    5.84
    6.33
    7.62
    8.95
    9.48
    10.77
    12
    12.64
    13.92
    15
    15.55
    16.97
    18
    19
    19.84
    20.59
    21.95
    23
    23.53
    24.74
    25.97
    26.69
    27.9
    28.85
    29.69
    30.6
  ]  
  
  @getShape: (diameter) ->
    # See which size we need to have to fill a circle with this diameter.
    size = Math.floor diameter

    biggerSize = size + 1
    biggerSizeCenter = (biggerSize - 1) / 2
    biggerSizeOffset = biggerSizeCenter - Math.floor biggerSizeCenter

    # Maximum distance to be filled must be smaller than the radius so that the bigger size would be fully filled.
    radius = diameter / 2
    maxDistance = Math.sqrt biggerSizeCenter ** 2 + biggerSizeOffset ** 2
    size = biggerSize if maxDistance < radius

    center = (size - 1) / 2

    for x in [0...size]
      for y in [0...size]
        distance = Math.sqrt (x - center) ** 2 + (y - center) ** 2
        distance < radius
