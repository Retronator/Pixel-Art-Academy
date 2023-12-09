AM = Artificial.Mirage
AEc = Artificial.Echo
LOI = LandsOfIllusions
PAA = PixelArtAcademy
FM = FataMorgana

PAG = PAA.Practice.PixelArtGrading

class PAA.PixelPad.Apps.Drawing.Editor.Desktop.PixelArtGrading.Overview extends LOI.View
  @id: -> 'PixelArtAcademy.PixelPad.Apps.Drawing.Editor.Desktop.PixelArtGrading.Overview'
  @register @id()
  
  @CriteriaNames:
    ConsistentLineWidth: "Consistent line width"
    EvenDiagonals: "Even diagonals"
    SmoothCurves: "Smooth curves"
  
  onCreated: ->
    super arguments...
    
    @pixelArtGrading = @ancestorComponentOfType PAA.PixelPad.Apps.Drawing.Editor.Desktop.PixelArtGrading
    
    @editable = new ComputedField => @pixelArtGrading.pixelArtGradingProperty()?.editable
    
    @criteria = new ComputedField =>
      return unless pixelArtGradingProperty = @pixelArtGrading.pixelArtGradingProperty()
      editable = @editable()
      
      criteria = []
      
      for criterion of PAG.Criteria
        criterionProperty = _.lowerFirst criterion
        
        # Show only existing criteria when not editable (and all otherwise so we can toggle them on and off).
        continue unless editable or pixelArtGradingProperty[criterionProperty]?
        
        criteria.push
          id: criterion
          propertyPath: criterionProperty
          name: @constructor.CriteriaNames[criterion]
          score: pixelArtGradingProperty[criterionProperty]?.score
      
      criteria
  
  scorePercentage: (value) ->
    return unless value?
    
    "#{Math.floor value * 100}%"
    
  letterGrade: ->
    grade = @pixelArtGrading.pixelArtGradingProperty()?.grade or 0
    PAG.getLetterGrade grade

  events: ->
    super(arguments...).concat
      'click .criterion .name-area, click .criterion .grade': @onClickCriterion
      'mouseenter .criterion .name-area, mouseenter .criterion .grade': @onMouseEnterCriterion
      'mouseleave .criterion .name-area, mouseleave .criterion .grade': @onMouseLeaveCriterion
      
  onClickCriterion: (event) ->
    criterion = @currentData()
    @pixelArtGrading.activeCriterion criterion.id
  
  onMouseEnterCriterion: (event) ->
    criterion = @currentData()
    @pixelArtGrading.hoveredCriterion criterion.id
  
  onMouseLeaveCriterion: (event) ->
    @pixelArtGrading.hoveredCriterion null
