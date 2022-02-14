FM = FataMorgana
LOI = LandsOfIllusions

class LOI.Assets.MeshEditor.Helpers.RestrictColors extends FM.Helper
  # ramps: boolean whether colors should be restricted to palette ramps
  # shades: boolean whether colors should be restricted to palette shades
  @id: -> 'LandsOfIllusions.Assets.MeshEditor.Helpers.RestrictRampColors'
  @initialize()

  ramps: -> @data.get('ramps') ? false
  setRamps: (value) -> @data.set 'ramps', value

  shades: -> @data.get('shades') ? false
  setShades: (value) -> @data.set 'shades', value

  toObject: ->
    _.defaults @data.value(),
      ramps: false
      shades: false
