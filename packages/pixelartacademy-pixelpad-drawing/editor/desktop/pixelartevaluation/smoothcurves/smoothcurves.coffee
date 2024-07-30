AM = Artificial.Mirage
AEc = Artificial.Echo
LOI = LandsOfIllusions
PAA = PixelArtAcademy
FM = FataMorgana

PAE = PAA.Practice.PixelArtEvaluation
Markup = PAA.Practice.Helpers.Drawing.Markup

class PAA.PixelPad.Apps.Drawing.Editor.Desktop.PixelArtEvaluation.SmoothCurves extends LOI.View
  @id: -> 'PixelArtAcademy.PixelPad.Apps.Drawing.Editor.Desktop.PixelArtEvaluation.SmoothCurves'
  @register @id()
  
  @CriteriaNames:
    AbruptSegmentLengthChanges: 'Abrupt length changes'
    StraightParts: 'Straight parts'
    InflectionPoints: 'Inflection points'
    
  @CategoryNames:
    AbruptSegmentLengthChanges:
      Minor: 'Minor (B–D)'
      Major: 'Major (F)'
    StraightParts:
      End: 'At the ends (A-C)'
      Middle: 'In the middle (A-F)'
    InflectionPoints:
      Isolated: 'Isolated (A)'
      Sparse: 'Sparse (B–D)'
      Dense: 'Dense (F)'

  onCreated: ->
    super arguments...
    
    @pixelArtEvaluation = @ancestorComponentOfType PAA.PixelPad.Apps.Drawing.Editor.Desktop.PixelArtEvaluation

    @smoothCurvesProperty = new ComputedField =>
      @pixelArtEvaluation.bitmap()?.properties?.pixelArtEvaluation?.smoothCurves
      
    @editable = new ComputedField => @smoothCurvesProperty()?.editable ? @pixelArtEvaluation.editable()
    
    @criteria = new ComputedField =>
      smoothCurvesProperty = @smoothCurvesProperty()
      editable = @editable()
      
      criteria = []
      
      for criterion of PAE.Subcriteria.SmoothCurves
        criterionProperty = _.lowerFirst criterion
        
        # Show only existing criteria when not editable (and all otherwise so we can toggle them on and off).
        continue unless editable or smoothCurvesProperty?[criterionProperty]?
        
        if enabled = smoothCurvesProperty?[criterionProperty]?
          categories = for category of PAE.Line.Part.Curve[criterion]
            id: category
            name: @constructor.CategoryNames[criterion][category]
            count: smoothCurvesProperty[criterionProperty].counts[_.lowerFirst category]
        
        else
          categories = null
        
        criteria.push
          id: criterion
          parentId: PAE.Criteria.SmoothCurves
          property: criterionProperty
          propertyPath: "smoothCurves.#{criterionProperty}"
          name: @constructor.CriteriaNames[criterion]
          enabled: enabled
          score: smoothCurvesProperty?[criterionProperty]?.score
          categories: categories
      
      criteria
      
  scorePercentage: (value) -> Markup.percentage value
  
  events: ->
    super(arguments...).concat
      'pointerenter .score, pointerenter .count': @onPointerEnterScoreOrCount
      'pointerleave .score, pointerleave .count': @onPointerLeaveScoreOrCount
  
  onPointerEnterScoreOrCount: (event) ->
    criterionOrCategory = @currentData()

    @pixelArtEvaluation.hoveredFilterValue criterionOrCategory.id
  
  onPointerLeaveScoreOrCount: (event) ->
    @pixelArtEvaluation.hoveredFilterValue null
