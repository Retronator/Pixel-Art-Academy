AM = Artificial.Mirage
AEc = Artificial.Echo
LOI = LandsOfIllusions
PAA = PixelArtAcademy
FM = FataMorgana

PAG = PAA.Practice.PixelArtGrading

class PAA.PixelPad.Apps.Drawing.Editor.Desktop.PixelArtGrading.EvenDiagonals extends LOI.View
  @id: -> 'PixelArtAcademy.PixelPad.Apps.Drawing.Editor.Desktop.PixelArtGrading.EvenDiagonals'
  @register @id()
  
  @CriteriaNames:
    SegmentLengths: "Segment lengths"
    EndSegments: "End segments"
  
  @CategoryNames:
    SegmentLengths:
      Even: "Even (A)"
      Alternating: "Alternating (B–C)"
      Broken: "Broken (D–F)"
    EndSegments:
      Matching: "Matching (A)"
      Shorter: "Shorter (B–F)"
    
  @CategoryEnumerationNames:
    SegmentLengths: 'PointSegmentLengths'
    EndSegments: 'EndPointSegmentLengths'
  
  onCreated: ->
    super arguments...
    
    @pixelArtGrading = @ancestorComponentOfType PAA.PixelPad.Apps.Drawing.Editor.Desktop.PixelArtGrading

    @evenDiagonalsProperty = new ComputedField =>
      @pixelArtGrading.bitmap()?.properties?.pixelArtGrading?.evenDiagonals
      
    @editable = new ComputedField => @evenDiagonalsProperty()?.editable ? @pixelArtGrading.pixelArtGradingProperty()?.editable
    
    @criteria = new ComputedField =>
      return unless evenDiagonalsProperty = @evenDiagonalsProperty()
      editable = @editable()
      
      criteria = []
      
      for criterion of PAG.Criteria.EvenDiagonals
        criterionProperty = _.lowerFirst criterion
        
        # Show only existing criteria when not editable (and all otherwise so we can toggle them on and off).
        continue unless editable or evenDiagonalsProperty[criterionProperty]?
        
        categories = for category of PAG.Line.Part.StraightLine[@constructor.CategoryEnumerationNames[criterion]]
          propertyName: _.lowerFirst category
          name: @constructor.CategoryNames[criterion][category]
          count: 0
        
        criteria.push
          propertyPath: "evenDiagonals.#{criterionProperty}"
          name: @constructor.CriteriaNames[criterion]
          enabled: evenDiagonalsProperty[criterionProperty]?
          score: evenDiagonalsProperty[criterionProperty]?.score
          categories: categories
      
      criteria
    
  scorePercentage: (value) ->
    return unless value?
    
    "#{Math.floor value * 100}%"
