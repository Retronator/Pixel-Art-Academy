AM = Artificial.Mirage
AEc = Artificial.Echo
LOI = LandsOfIllusions
PAA = PixelArtAcademy
FM = FataMorgana

PAG = PAA.Practice.PixelArtEvaluation
Markup = PAA.Practice.Helpers.Drawing.Markup

class PAA.PixelPad.Apps.Drawing.Editor.Desktop.PixelArtEvaluation.Overview extends LOI.View
  @id: -> 'PixelArtAcademy.PixelPad.Apps.Drawing.Editor.Desktop.PixelArtEvaluation.Overview'
  @register @id()
  
  @CriteriaNames:
    PixelPerfectLines: "Pixel-perfect lines"
    ConsistentLineWidth: "Consistent line width"
    EvenDiagonals: "Even diagonals"
    SmoothCurves: "Smooth curves"
  
  onCreated: ->
    super arguments...
    
    @pixelArtEvaluation = @ancestorComponentOfType PAA.PixelPad.Apps.Drawing.Editor.Desktop.PixelArtEvaluation
    
    @editable = new ComputedField => @pixelArtEvaluation.pixelArtEvaluationProperty()?.editable
    
    @criteria = new ComputedField =>
      return unless pixelArtEvaluationProperty = @pixelArtEvaluation.pixelArtEvaluationProperty()
      editable = @editable()
      
      criteria = []
      
      pixelArtEvaluationCriteria = pixelArtEvaluationProperty.allowedCriteria or PAA.Practice.Project.Asset.Bitmap.state('unlockedPixelArtEvaluationCriteria') or []
      
      for criterion of PAG.Criteria
        criterionProperty = _.lowerFirst criterion
        
        # Show only existing criteria when not editable (and unlocked otherwise so we can toggle them on and off).
        continue unless criterion in pixelArtEvaluationCriteria or pixelArtEvaluationProperty[criterionProperty]?
        
        criteria.push
          id: criterion
          property: criterionProperty
          propertyPath: criterionProperty
          name: @constructor.CriteriaNames[criterion]
          enabled: pixelArtEvaluationProperty[criterionProperty]?
          score: pixelArtEvaluationProperty[criterionProperty]?.score
      
      criteria
  
  scorePercentage: (value) -> Markup.percentage value
  
  hasFinalScore: ->
    @pixelArtEvaluation.pixelArtEvaluationProperty()?.score?
    
  letterGrade: ->
    PAG.getLetterGrade @pixelArtEvaluation.pixelArtEvaluationProperty().score

  events: ->
    super(arguments...).concat
      'click .criterion .name-area, click .criterion .score': @onClickCriterion
      
  onClickCriterion: (event) ->
    criterion = @currentData()
    @pixelArtEvaluation.setCriterion criterion.id
