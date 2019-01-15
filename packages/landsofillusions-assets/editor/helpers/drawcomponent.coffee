FM = FataMorgana
LOI = LandsOfIllusions

class LOI.Assets.Editor.Helpers.DrawComponent extends FM.Helper
  constructor: ->
    super arguments...

    @enabledData = @data.child 'enabled'

    @enabled = new ComputedField =>
      @enabledData.value() ? true

  toggle: ->
    @enabledData.value not @enabled()

  destroy: ->
    super arguments...

    @enabled.stop()
