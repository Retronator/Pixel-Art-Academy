AE = Artificial.Everywhere
AEc = Artificial.Echo
LOI = LandsOfIllusions

class LOI.Assets.Engine.Audio
  @Global = new LOI.Assets.Audio.Namespace 'LandsOfIllusions.Global'

  @initialize: (audioManager) ->
    @Global.load audioManager
