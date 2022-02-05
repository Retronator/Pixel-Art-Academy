AE = Artificial.Everywhere
AS = Artificial.Spectrum
AR = Artificial.Reality

class AS.Color.XYZ.ColorMatchingFunctions
  @initialize: (table) ->
    @table = AE.CSVParser.parse table
    values = [[], [], []]

    for row in @table
      # Transform text to numbers.
      values[i - 1].push parseFloat row[i] for i in [1..3]

    @x = new AR.Optics.Spectrum.UniformlySampled.Range380To780Spacing5 values[0]
    @y = new AR.Optics.Spectrum.UniformlySampled.Range380To780Spacing5 values[1]
    @z = new AR.Optics.Spectrum.UniformlySampled.Range380To780Spacing5 values[2]

    @integrals =
      x: _.sum values[0]
      y: _.sum values[1]
      z: _.sum values[2]
