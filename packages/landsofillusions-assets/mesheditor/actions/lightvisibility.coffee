AC = Artificial.Control
FM = FataMorgana
LOI = LandsOfIllusions

class LOI.Assets.MeshEditor.Actions.LightVisibility extends FM.Action
  _helper: ->
    @interface.getHelperForActiveFile LOI.Assets.MeshEditor.Helpers.LightVisibility

class LOI.Assets.MeshEditor.Actions.DirectSurfaceReflectionsVisible extends LOI.Assets.MeshEditor.Actions.LightVisibility
  @id: -> 'LandsOfIllusions.Assets.MeshEditor.Actions.DirectSurfaceReflectionsVisible'
  @displayName: -> "Show direct light surface reflections"

  @initialize()

  active: ->
    @_helper()?.directSurface()

  execute: ->
    helper = @_helper()
    helper.setDirectSurface not helper.directSurface()

class LOI.Assets.MeshEditor.Actions.DirectSubsurfaceScatteringVisible extends LOI.Assets.MeshEditor.Actions.LightVisibility
  @id: -> 'LandsOfIllusions.Assets.MeshEditor.Actions.DirectSubsurfaceScatteringVisible'
  @displayName: -> "Show direct light subsurface scattering"

  @initialize()

  active: ->
    @_helper()?.directSubsurface()

  execute: ->
    helper = @_helper()
    helper.setDirectSubsurface not helper.directSubsurface()

class LOI.Assets.MeshEditor.Actions.IndirectSurfaceReflectionsVisible extends LOI.Assets.MeshEditor.Actions.LightVisibility
  @id: -> 'LandsOfIllusions.Assets.MeshEditor.Actions.IndirectSurfaceReflectionsVisible'
  @displayName: -> "Show indirect light surface reflections"

  @initialize()

  active: ->
    @_helper()?.indirectSurface()

  execute: ->
    helper = @_helper()
    helper.setIndirectSurface not helper.indirectSurface()

class LOI.Assets.MeshEditor.Actions.IndirectSubsurfaceScatteringVisible extends LOI.Assets.MeshEditor.Actions.LightVisibility
  @id: -> 'LandsOfIllusions.Assets.MeshEditor.Actions.IndirectSubsurfaceScatteringVisible'
  @displayName: -> "Show indirect light subsurface scattering"

  @initialize()

  active: ->
    @_helper()?.indirectSubsurface()

  execute: ->
    helper = @_helper()
    helper.setIndirectSubsurface not helper.indirectSubsurface()

class LOI.Assets.MeshEditor.Actions.EmissiveVisible extends LOI.Assets.MeshEditor.Actions.LightVisibility
  @id: -> 'LandsOfIllusions.Assets.MeshEditor.Actions.EmissiveVisible'
  @displayName: -> "Show emissive light"

  @initialize()

  active: ->
    @_helper()?.emissive()

  execute: ->
    helper = @_helper()
    helper.setEmissive not helper.emissive()
