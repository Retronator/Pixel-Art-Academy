AS = Artificial.Spectrum

# Returns a 2D matrix for displacing pixel values when dithering.
AS.PixelArt.getDitherThresholdMap = (size) ->
  switch size
    when 2
      ditherThresholdMap = [
        [0, 2]
        [3, 1]
      ]

    when 4
      ditherThresholdMap = [
        [ 0,  8,  2, 10]
        [12,  4, 14,  6]
        [ 3, 11,  1,  9]
        [15,  7, 13,  5]
      ]

    when 8
      ditherThresholdMap = [
        [ 0, 32,  8, 40,  2, 34, 10, 42]
        [48, 16, 56, 24, 50, 18, 58, 26]
        [12, 44,  4, 36, 14, 46,  6, 38]
        [60, 28, 52, 20, 62, 30, 54, 22]
        [ 3, 35, 11, 43,  1, 33,  9, 41]
        [51, 19, 59, 27, 49, 17, 57, 25]
        [15, 47,  7, 39, 13, 45,  5, 37]
        [63, 31, 55, 23, 61, 29, 53, 21]
      ]

  for row in ditherThresholdMap
    for value, index in row
      row[index] = (value + 0.5) / size ** 2

  ditherThresholdMap
