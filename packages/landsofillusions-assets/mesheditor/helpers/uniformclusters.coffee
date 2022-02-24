FM = FataMorgana
LOI = LandsOfIllusions

class LOI.Assets.MeshEditor.Helpers.UniformClusters extends FM.Helper
  # lights: boolean whether lights' contribution is constant across a cluster
  # lightmap: boolean whether lightmap's contribution is constant across a cluster
  @id: -> 'LandsOfIllusions.Assets.MeshEditor.Helpers.LightUniformClustersEnabled'
  @initialize()

  lights: -> @data.get('lights') ? false
  setLights: (value) -> @data.set 'lights', value

  lightmap: -> @data.get('lightmap') ? false
  setLightmap: (value) -> @data.set 'lightmap', value

  toObject: ->
    _.defaults @data.value(),
      lights: false
      lightmap: false
