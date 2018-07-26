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
      Sketches: (complete) =>
        drawings = LOI.adventure.getCurrentThing HQ.ArtStudio.Drawings

        # We enable dialogue mode so scrolling is disabled.
        drawings.dialogueMode true

        if LOI.adventure.currentContext() is drawings
          drawings.moveFocus HQ.ArtStudio.Drawings.FocusPoints.Sketches

        else
          drawings.setFocus HQ.ArtStudio.Drawings.FocusPoints.Sketches

          # Pause current node so we can enter the context.
          LOI.adventure.director.pauseCurrentNode()
          LOI.adventure.enterContext drawings

        # Continue the script in the context.
        complete()

      SketchesHighlight: (complete) =>
        drawings = LOI.adventure.getCurrentThing HQ.ArtStudio.Drawings
        drawings.highlight HQ.ArtStudio.Drawings.HighlightGroups.Sketches
        complete()

      PencilsPortraits: (complete) =>
        drawings = LOI.adventure.getCurrentThing HQ.ArtStudio.Drawings

        if LOI.adventure.currentContext() is drawings
          drawings.moveFocus HQ.ArtStudio.Drawings.FocusPoints.Realistic

        else
          drawings.setFocus HQ.ArtStudio.Drawings.FocusPoints.Realistic

          # Pause current node so we can enter the context.
          LOI.adventure.director.pauseCurrentNode()
          LOI.adventure.enterContext drawings

        complete()

      PencilsPortraitsHighlight: (complete) =>
        drawings = LOI.adventure.getCurrentThing HQ.ArtStudio.Drawings
        drawings.moveFocus
          focusPoint: HQ.ArtStudio.Drawings.FocusPoints.Realistic
          completeCallback: =>
            drawings.highlight HQ.ArtStudio.Drawings.HighlightGroups.PencilsPortraits

        complete()

      Pencils: (complete) =>
        # Pause current node so we can enter the context.
        LOI.adventure.director.pauseCurrentNode()
        LOI.adventure.enterContext HQ.ArtStudio.Pencils

        Tracker.autorun (computation) =>
          context = LOI.adventure.currentContext()
          return unless context instanceof HQ.ArtStudio.Pencils
          computation.stop()

          Meteor.setTimeout =>
            context.showHand()
          ,
            1000

        complete()

      PencilsHighlight: (complete) =>
        pencils = LOI.adventure.currentContext()
        pencils.highlight HQ.ArtStudio.Pencils.HighlightGroups.Inventory
        complete()

      PencilsMechanical: (complete) =>
        drawings = LOI.adventure.getCurrentThing HQ.ArtStudio.Drawings
        drawings.highlight HQ.ArtStudio.Drawings.HighlightGroups.PencilsMechanical
        complete()

      PencilsEdgeShading: (complete) =>
        drawings = LOI.adventure.getCurrentThing HQ.ArtStudio.Drawings
        drawings.highlight HQ.ArtStudio.Drawings.HighlightGroups.PencilsEdgeShading
        complete()

      PencilsColored: (complete) =>
        drawings = LOI.adventure.getCurrentThing HQ.ArtStudio.Drawings
        drawings.highlight HQ.ArtStudio.Drawings.HighlightGroups.PencilsColored
        complete()

      PencilsCharcoal: (complete) =>
        drawings = LOI.adventure.getCurrentThing HQ.ArtStudio.Drawings

        if LOI.adventure.currentContext() is drawings
          drawings.moveFocus
            focusPoint: HQ.ArtStudio.Drawings.FocusPoints.Charcoal
            completeCallback: =>
              drawings.highlight HQ.ArtStudio.Drawings.HighlightGroups.Charcoal

        else
          drawings.setFocus HQ.ArtStudio.Drawings.FocusPoints.Charcoal

          Meteor.setTimeout =>
            drawings.highlight HQ.ArtStudio.Drawings.HighlightGroups.Charcoal
          ,
            2000

          # Pause current node so we can enter the context.
          LOI.adventure.director.pauseCurrentNode()
          LOI.adventure.enterContext drawings

        complete()

  onCommand: (commandResponse) ->
    return unless alexandra = LOI.adventure.getCurrentThing HQ.Actors.Alexandra

    commandResponse.onPhrase
      form: [Vocabulary.Keys.Verbs.TalkTo, alexandra]
      action: => @startScript()
