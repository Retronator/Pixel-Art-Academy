LOI = LandsOfIllusions
HQ = Retronator.HQ

class HQ.Actors.Retro extends LOI.Character.Actor
  @id: -> 'Retronator.HQ.Actors.Retro'
  @fullName: -> "Matej 'Retro' Jan"
  @shortName: -> "Retro"
  @descriptiveName: -> "Matej '![Retro](talk to Retro)' Jan."
  @description: -> "It's Matej Jan a.k.a. Retro. He's the man behind Retronator and the developer of Pixel Art Academy."
  @color: ->
    hue: LOI.Assets.Palette.Atari2600.hues.red
    shade: LOI.Assets.Palette.Atari2600.characterShades.normal

  @defaultScriptUrl: -> 'retronator_retronator-hq/actors/retro/retro.script'
  @assetUrls: -> '/retronator/hq/actors/retro'

  @initialize()

  initializeScript: ->
    @setCurrentThings
      retro: HQ.Actors.Retro
      
    @setCallbacks
      Return: (complete) =>
        # Hook back into the Retro's main questions.
        store = LOI.adventure.getCurrentThing HQ.Store
        listener = store.getListener HQ.Store.RetroListener
        script = if LOI.characterId() then listener.characterScript else listener.userScript
        LOI.adventure.director.startScript script, label: 'MainQuestion'
    
        complete()
