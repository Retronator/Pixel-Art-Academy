LOI = LandsOfIllusions
PAA = PixelArtAcademy
HQ = Retronator.HQ

Vocabulary = LOI.Parser.Vocabulary

class HQ.Actors.Alexandra extends LOI.Adventure.Thing
  @id: -> 'Retronator.HQ.Actors.Alexandra'
  @fullName: -> "Alexandra Hood"
  @shortName: -> "Alexandra"
  @descriptiveName: -> "![Alexandra](talk to Alexandra) Hood."
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
      DigitalEquipment: (complete) =>
        focus HQ.ArtStudio.Southeast, HQ.ArtStudio.Southeast.FocusPoints.DigitalEquipment
        complete()

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
        focus HQ.ArtStudio.Northwest, HQ.ArtStudio.Northwest.FocusPoints.Charcoal
        complete()

      PencilsCharcoalHighlight: (complete) =>
        LOI.adventure.currentContext().highlight HQ.ArtStudio.Northwest.HighlightGroups.Charcoal
        complete()

      Pens: (complete) =>
        focus HQ.ArtStudio.Northeast, HQ.ArtStudio.Northeast.FocusPoints.BackWall
        complete()

      PensHighlightAquaticBotanical: (complete) =>
        LOI.adventure.currentContext().highlight HQ.ArtStudio.Northeast.HighlightGroups.PensAquaticBotanical
        complete()

      PensHighlightInking: (complete) =>
        LOI.adventure.currentContext().highlight HQ.ArtStudio.Northeast.HighlightGroups.PensInk
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
        focus HQ.ArtStudio.Southwest, HQ.ArtStudio.Southwest.FocusPoints.Pastels
        complete()

      PastelsHighlight: (complete) =>
        LOI.adventure.currentContext().highlight HQ.ArtStudio.Southwest.HighlightGroups.Pastels
        complete()

      PastelsWall: (complete) =>
        focus HQ.ArtStudio.Northwest, HQ.ArtStudio.Northwest.FocusPoints.Pastels, (context) =>
          context.highlight HQ.ArtStudio.Northwest.HighlightGroups.Pastels
        ,
          1000
        complete()

      Painting: (complete) =>
        focus HQ.ArtStudio.Southwest, HQ.ArtStudio.Southwest.FocusPoints.All
        complete()

      PaintingHighlightOils: (complete) =>
        LOI.adventure.currentContext().highlight HQ.ArtStudio.Southwest.HighlightGroups.OilsWall
        complete()

      PaintingHighlightAcrylic: (complete) =>
        LOI.adventure.currentContext().highlight HQ.ArtStudio.Southwest.HighlightGroups.Acrylics
        complete()

      PaintingHighlightWatercolors: (complete) =>
        LOI.adventure.currentContext().highlight HQ.ArtStudio.Southwest.HighlightGroups.WatercolorsWall
        complete()

      PaintingWhyOils: (complete) =>
        focus HQ.ArtStudio.Southwest, HQ.ArtStudio.Southwest.FocusPoints.Oils
        complete()

      PaintingOils: (complete) =>
        # TODO: Back to Alexandra.
        complete()

      PaintingOilsSupplies: (complete) =>
        # TODO: Pan to supplies rack.
        complete()

      PaintingOilsDigital: (complete) =>
        # TODO: Pan to iPad.
        complete()

      PaintingAcrylics: (complete) =>
        focus HQ.ArtStudio.Southeast, HQ.ArtStudio.Southeast.FocusPoints.Acrylics, (context) =>
          context.highlight HQ.ArtStudio.Southeast.HighlightGroups.Acrylics
        ,
          2000
        complete()

      PaintingAcrylicsShoes: (complete) =>
        LOI.adventure.currentContext().highlight HQ.ArtStudio.Southeast.HighlightGroups.AcrylicsShoes
        complete()

      PaintingWatercolors: (complete) =>
        focus HQ.ArtStudio.Southwest, HQ.ArtStudio.Southwest.FocusPoints.WatercolorsTable
        complete()

      PaintingWatercolorsHighlight: (complete) =>
        LOI.adventure.currentContext().highlight HQ.ArtStudio.Southwest.HighlightGroups.WatercolorsTable
        complete()

      PaintingDigital: (complete) =>
        focus HQ.ArtStudio.Southeast, HQ.ArtStudio.Southeast.FocusPoints.Digital
        complete()

      PaintingDigitalHighlightEmulation: (complete) =>
        LOI.adventure.currentContext().highlight HQ.ArtStudio.Southeast.HighlightGroups.DigitalEmulation
        complete()

      PaintingDigitalHighlightUnique: (complete) =>
        LOI.adventure.currentContext().highlight HQ.ArtStudio.Southeast.HighlightGroups.DigitalUnique
        complete()

  onCommand: (commandResponse) ->
    return unless alexandra = LOI.adventure.getCurrentThing HQ.Actors.Alexandra

    commandResponse.onPhrase
      form: [Vocabulary.Keys.Verbs.TalkTo, alexandra]
      action: => @startScript()
