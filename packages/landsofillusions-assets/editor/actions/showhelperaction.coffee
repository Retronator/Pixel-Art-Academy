AE = Artificial.Everywhere
AC = Artificial.Control
FM = FataMorgana
LOI = LandsOfIllusions

class LOI.Assets.Editor.Actions.ShowHelperAction extends LOI.Assets.Editor.Actions.AssetAction
  @helperClass: -> throw new AE.NotImplementedException "Show helper action must specify the helper class."
    
  active: ->
    @_helper().enabled()

  execute: ->
    @_helper().toggle()

  _helper: ->
    @interface.getHelperForActiveFile @constructor.helperClass()
