FM = FataMorgana
LOI = LandsOfIllusions

class LOI.Assets.MeshEditor.Helpers.LightVisibility extends FM.Helper
  # directSurface: boolean whether to show direct light sources reflected from surfaces
  # directSubsurface: boolean whether to show direct light scattered from materials
  # indirectSurface: boolean whether to show the indirect reflected from surfaces
  # indirectSubsurface: boolean whether to show the indirect scattered from materials
  @id: -> 'LandsOfIllusions.Assets.MeshEditor.Helpers.LightVisibility'
  @initialize()

  directSurface: -> @data.get('directSurface') ? true
  setDirectSurface: (value) -> @data.set 'directSurface', value

  directSubsurface: -> @data.get('directSubsurface') ? true
  setDirectSubsurface: (value) -> @data.set 'directSubsurface', value

  indirectSurface: -> @data.get('indirectSurface') ? true
  setIndirectSurface: (value) -> @data.set 'indirectSurface', value

  indirectSubsurface: -> @data.get('indirectSubsurface') ? true
  setIndirectSubsurface: (value) -> @data.set 'indirectSubsurface', value
