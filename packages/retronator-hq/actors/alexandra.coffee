LOI = LandsOfIllusions
PAA = PixelArtAcademy
HQ = Retronator.HQ

Vocabulary = LOI.Parser.Vocabulary

class HQ.Actors.Alexandra extends LOI.Adventure.Thing
  @id: -> 'Retronator.HQ.Actors.Alexandra'
  @fullName: -> "Alexandra Hood"
  @shortName: -> "Alexandra"
  @description: -> "It's Alexandra Hood, resident artist and coffee drinker at Retronator."
  @color: ->
    hue: LOI.Assets.Palette.Atari2600.hues.olive
    shade: LOI.Assets.Palette.Atari2600.characterShades.darker

  @initialize()

  @defaultScriptUrl: -> 'retronator_retronator-hq/actors/alexandra.script'

  initializeScript: ->
    @setCurrentThings
      alexandra: HQ.Actors.Alexandra
      
    @setCallbacks
      QuickSketches: (complete) =>
        drawings = LOI.adventure.getCurrentThing HQ.ArtStudio.Drawings

        if LOI.adventure.currentContext() is drawings
          drawings.moveFocus HQ.ArtStudio.Drawings.FocusPoints.Sketches

        else
          # We enable dialogue mode so scrolling is disabled.
          drawings.dialogueMode true

          drawings.setFocus HQ.ArtStudio.Drawings.FocusPoints.Sketches

          # Pause current node so we can enter the context.
          LOI.adventure.director.pauseCurrentNode()
          LOI.adventure.enterContext drawings

        # Continue the script in the context.
        complete()

      PencilsRealistic: (complete) =>
        drawings = LOI.adventure.getCurrentThing HQ.ArtStudio.Drawings
        drawings.moveFocus HQ.ArtStudio.Drawings.FocusPoints.Realistic
        complete()

      PencilsCharcoal: (complete) =>
        drawings = LOI.adventure.getCurrentThing HQ.ArtStudio.Drawings
        drawings.moveFocus HQ.ArtStudio.Drawings.FocusPoints.Charcoal
        complete()

  onCommand: (commandResponse) ->
    return unless alexandra = LOI.adventure.getCurrentThing HQ.Actors.Alexandra

    commandResponse.onPhrase
      form: [Vocabulary.Keys.Verbs.TalkTo, alexandra]
      action: => @startScript()
