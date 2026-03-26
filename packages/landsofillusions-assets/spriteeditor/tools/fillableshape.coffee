AE = Artificial.Everywhere
AC = Artificial.Control
AM = Artificial.Mummification
FM = FataMorgana
LOI = LandsOfIllusions

class LOI.Assets.SpriteEditor.Tools.FillableShape extends LOI.Assets.SpriteEditor.Tools.Shape
  # filled: boolean whether the shape should be filled
  onActivated: (toolWasRestored) ->
    super arguments...
    
    @data.set 'filled', false unless toolWasRestored
    
  onReactivated: ->
    @data.set 'filled', not @data.get 'filled'
