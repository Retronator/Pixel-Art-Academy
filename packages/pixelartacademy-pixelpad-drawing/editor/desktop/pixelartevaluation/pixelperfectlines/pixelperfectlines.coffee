AM = Artificial.Mirage
AEc = Artificial.Echo
LOI = LandsOfIllusions
PAA = PixelArtAcademy
FM = FataMorgana

PAE = PAA.Practice.PixelArtEvaluation
Markup = PAA.Practice.Helpers.Drawing.Markup

class PAA.PixelPad.Apps.Drawing.Editor.Desktop.PixelArtEvaluation.PixelPerfectLines extends LOI.View
  @id: -> 'PixelArtAcademy.PixelPad.Apps.Drawing.Editor.Desktop.PixelArtEvaluation.PixelPerfectLines'
  @register @id()
  
  @CriteriaNames:
    Doubles: "Doubles"
    Corners: "Corners"
  
  onCreated: ->
    super arguments...
    
    @pixelArtEvaluation = @ancestorComponentOfType PAA.PixelPad.Apps.Drawing.Editor.Desktop.PixelArtEvaluation

    @pixelPerfectLinesProperty = new ComputedField =>
      @pixelArtEvaluation.bitmap()?.properties?.pixelArtEvaluation?.pixelPerfectLines
      
    @editable = new ComputedField => @pixelPerfectLinesProperty()?.editable ? @pixelArtEvaluation.editable()
    
    @criteria = new ComputedField =>
      pixelPerfectLinesProperty = @pixelPerfectLinesProperty()
      editable = @editable()
      
      criteria = []
      
      for criterion of PAE.Subcriteria.PixelPerfectLines
        criterionProperty = _.lowerFirst criterion
        
        # Show only existing criteria when not editable (and all otherwise so we can toggle them on and off).
        continue unless editable or pixelPerfectLinesProperty?[criterionProperty]?
        
        criteria.push
          id: criterion
          parentId: PAE.Criteria.PixelPerfectLines
          property: criterionProperty
          propertyPath: "pixelPerfectLines.#{criterionProperty}"
          name: @constructor.CriteriaNames[criterion]
          enabled: pixelPerfectLinesProperty?[criterionProperty]?
          count: pixelPerfectLinesProperty?[criterionProperty]?.count
      
      criteria
  
  events: ->
    super(arguments...).concat
      'pointerenter .criterion .count': @onPointerEnterCriterion
      'pointerleave .criterion .count': @onPointerLeaveCriterion
  
  onPointerEnterCriterion: (event) ->
    criterion = @currentData()

    @pixelArtEvaluation.hoveredFilterValue criterion.id
  
  onPointerLeaveCriterion: (event) ->
    @pixelArtEvaluation.hoveredFilterValue null
