AM = Artificial.Mirage
AEc = Artificial.Echo
LOI = LandsOfIllusions
PAA = PixelArtAcademy
FM = FataMorgana

PAE = PAA.Practice.PixelArtEvaluation
Markup = PAA.Practice.Helpers.Drawing.Markup

class PAA.PixelPad.Apps.Drawing.Editor.Desktop.PixelArtEvaluation.Overview extends LOI.View
  @id: -> 'PixelArtAcademy.PixelPad.Apps.Drawing.Editor.Desktop.PixelArtEvaluation.Overview'
  @register @id()
  
  @CriteriaNames:
    PixelPerfectLines: "Pixel-perfect lines"
    EvenDiagonals: "Even diagonals"
    SmoothCurves: "Smooth curves"
    ConsistentLineWidth: "Consistent line width"
  
  onCreated: ->
    super arguments...
    
    @pixelArtEvaluation = @ancestorComponentOfType PAA.PixelPad.Apps.Drawing.Editor.Desktop.PixelArtEvaluation
    
    @editable = new ComputedField => @pixelArtEvaluation.editable()
    @unlockable = new ComputedField => @pixelArtEvaluation.pixelArtEvaluationProperty()?.unlockable
    
    @criteria = new ComputedField =>
      return unless pixelArtEvaluationProperty = @pixelArtEvaluation.pixelArtEvaluationProperty()
      criteria = []
      
      pixelArtEvaluationCriteria = pixelArtEvaluationProperty.allowedCriteria or PAA.Practice.Project.Asset.Bitmap.state('unlockedPixelArtEvaluationCriteria') or []
      
      if @unlockable()
        # Note: We need to use concat since we don't want to modify the array we got from the state.
        pixelArtEvaluationCriteria = pixelArtEvaluationCriteria.concat PAA.Practice.Project.Asset.Bitmap.state('unlockablePixelArtEvaluationCriteria') or []
      
      for criterion of PAE.Criteria
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
    PAE.getLetterGrade @pixelArtEvaluation.pixelArtEvaluationProperty().score

  events: ->
    super(arguments...).concat
      'click .criterion .name-area, click .criterion .score': @onClickCriterion
      
  onClickCriterion: (event) ->
    criterion = @currentData()
    @pixelArtEvaluation.setCriterion criterion.id
