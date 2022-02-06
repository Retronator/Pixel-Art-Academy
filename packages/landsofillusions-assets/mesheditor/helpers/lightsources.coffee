FM = FataMorgana
LOI = LandsOfIllusions

class LOI.Assets.MeshEditor.Helpers.LightSources extends FM.Helper
  # lights: boolean whether to light the scene with geometric lights
  # lightmap: boolean whether to light the scene with the lightmap
  # environmentMaps: boolean whether to light the scene with environment maps
  # environmentRenders: boolean whether to light the scene with environment renders
  @id: -> 'LandsOfIllusions.Assets.MeshEditor.Helpers.LightSources'
  @initialize()

  lights: -> @data.get('lights') ? true
  setLights: (value) -> @data.set 'lights', value

  lightmap: -> @data.get('lightmap') ? true
  setLightmap: (value) -> @data.set 'lightmap', value

  environmentMaps: -> @data.get('environmentMaps') ? true
  setEnvironmentMaps: (value) -> @data.set 'environmentMaps', value

  environmentRenders: -> @data.get('environmentRenders') ? true
  setEnvironmentRenders: (value) -> @data.set 'environmentRenders', value
