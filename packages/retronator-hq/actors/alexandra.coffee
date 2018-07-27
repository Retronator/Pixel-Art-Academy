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
    focus = (contextClass, focusPoint, completeCallback, completeCallbackDelayIfNoMove) =>
      context = LOI.adventure.currentContext()

      if context instanceof contextClass
        context.moveFocus
          focusPoint: focusPoint
          completeCallback: => completeCallback? context

      else
        context = new contextClass

        # We enable dialogue mode so scrolling is disabled.
        context.dialogueMode true

        context.setFocus focusPoint

        # Pause current node so we can enter the context.
        LOI.adventure.director.pauseCurrentNode()
        LOI.adventure.enterContext context

        if completeCallback
          Meteor.setTimeout =>
            completeCallback context
          ,
            completeCallbackDelayIfNoMove

      # Return context.
      context

    @setCurrentThings
      alexandra: HQ.Actors.Alexandra
      
    @setCallbacks
      Sketches: (complete) =>
        focus HQ.ArtStudio.Northwest, HQ.ArtStudio.Northwest.FocusPoints.Sketches
        complete()

      SketchesHighlight: (complete) =>
        northwest = LOI.adventure.currentContext()
        northwest.highlight HQ.ArtStudio.Northwest.HighlightGroups.Sketches
        complete()

      PencilsPortraits: (complete) =>
        focus HQ.ArtStudio.Northwest, HQ.ArtStudio.Northwest.FocusPoints.Realistic
        complete()

      PencilsPortraitsHighlight: (complete) =>
        northwest = LOI.adventure.currentContext()
        northwest.moveFocus
          focusPoint: HQ.ArtStudio.Northwest.FocusPoints.Realistic
          completeCallback: =>
            northwest.highlight HQ.ArtStudio.Northwest.HighlightGroups.PencilsPortraits

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
        northwest = focus HQ.ArtStudio.Northwest, HQ.ArtStudio.Northwest.FocusPoints.Realistic
        northwest.highlight HQ.ArtStudio.Northwest.HighlightGroups.PencilsMechanical
        complete()

      PencilsEdgeShading: (complete) =>
        northwest = LOI.adventure.currentContext()
        northwest.highlight HQ.ArtStudio.Northwest.HighlightGroups.PencilsEdgeShading
        complete()

      PencilsColored: (complete) =>
        northwest = focus HQ.ArtStudio.Northwest, HQ.ArtStudio.Northwest.FocusPoints.Realistic
        northwest.highlight HQ.ArtStudio.Northwest.HighlightGroups.PencilsColored
        complete()

      PencilsCharcoal: (complete) =>
        focus HQ.ArtStudio.Northwest, HQ.ArtStudio.Northwest.FocusPoints.Charcoal, (context) =>
          context.highlight HQ.ArtStudio.Northwest.HighlightGroups.Charcoal
        ,
          2000

        complete()

      Pens: (complete) =>
        focus HQ.ArtStudio.Northeast, HQ.ArtStudio.Northeast.FocusPoints.BackWall
        complete()

      PensHighlight: (complete) =>
        northeast = LOI.adventure.currentContext()
        northeast.highlight HQ.ArtStudio.Northeast.HighlightGroups.Pens
        complete()

      PensCombine: (complete) =>
        focus HQ.ArtStudio.Northeast, HQ.ArtStudio.Northeast.FocusPoints.Pens
        complete()

      PensCombineHighlight: (complete) =>
        northeast = LOI.adventure.currentContext()
        northeast.highlight HQ.ArtStudio.Northeast.HighlightGroups.PensCombine
        complete()

      Markers: (complete) =>
        focus HQ.ArtStudio.Northeast, HQ.ArtStudio.Northeast.FocusPoints.Markers
        complete()

      MarkersHighlight: (complete) =>
        northeast = LOI.adventure.currentContext()
        northeast.highlight HQ.ArtStudio.Northeast.HighlightGroups.Markers
        complete()

      MarkersCombine: (complete) =>
        focus HQ.ArtStudio.Northeast, HQ.ArtStudio.Northeast.FocusPoints.CardinalCity, (context) =>
          context.highlight HQ.ArtStudio.Northeast.HighlightGroups.MarkersCombine
        ,
          0
        complete()

      Pastels: (complete) =>
        focus HQ.ArtStudio.Southwest, HQ.ArtStudio.Southwest.FocusPoints.Pastels, (context) =>
          context.highlight HQ.ArtStudio.Southwest.HighlightGroups.Pastels
        ,
          2000
        complete()

      PastelsWall: (complete) =>
        focus HQ.ArtStudio.Northwest, HQ.ArtStudio.Northwest.FocusPoints.Pastels
        complete()

      PastelsWallHighlight: (complete) =>
        northwest = LOI.adventure.currentContext()
        northwest.highlight HQ.ArtStudio.Northwest.HighlightGroups.Pastels
        complete()

  onCommand: (commandResponse) ->
    return unless alexandra = LOI.adventure.getCurrentThing HQ.Actors.Alexandra

    commandResponse.onPhrase
      form: [Vocabulary.Keys.Verbs.TalkTo, alexandra]
      action: => @startScript()
