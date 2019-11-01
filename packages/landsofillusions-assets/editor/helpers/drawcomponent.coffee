FM = FataMorgana
LOI = LandsOfIllusions

class LOI.Assets.Editor.Helpers.DrawComponent extends FM.Helper
  # enabled: boolean whether this component should be drawn
  @enabledByDefault: ->
    # Override to not draw this component by default.
    true

  constructor: ->
    super arguments...

    @enabledData = @data.child 'enabled'

    @enabled = new ComputedField =>
      @enabledData.value() ? @constructor.enabledByDefault()

  toggle: ->
    @enabledData.value not @enabled()

  destroy: ->
    super arguments...

    @enabled.stop()
