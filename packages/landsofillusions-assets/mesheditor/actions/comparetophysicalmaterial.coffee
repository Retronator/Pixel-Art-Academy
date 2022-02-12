AC = Artificial.Control
FM = FataMorgana
LOI = LandsOfIllusions

class LOI.Assets.MeshEditor.Actions.CompareToPhysicalMaterial extends FM.Action
  # boolean if physical material should be used instead of the universal material
  @id: -> 'LandsOfIllusions.Assets.MeshEditor.Actions.CompareToPhysicalMaterial'
  @displayName: -> "Compare to Physical Material"

  @initialize()

  constructor: ->
    super arguments...

  active: -> @data.value()

  execute: ->
    @data.value not @data.value()
