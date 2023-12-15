AM = Artificial.Mirage
AEc = Artificial.Echo
LOI = LandsOfIllusions
PAA = PixelArtAcademy
FM = FataMorgana

PAG = PAA.Practice.PixelArtGrading
Markup = PAA.Practice.Helpers.Drawing.Markup

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
      
      unlockedPixelArtGradingCriteria = PAA.Practice.Project.Asset.Bitmap.state('unlockedPixelArtGradingCriteria') or []
      
      for criterion of PAG.Criteria
        criterionProperty = _.lowerFirst criterion
        
        # Show only existing criteria when not editable (and unlocked otherwise so we can toggle them on and off).
        continue unless criterion in unlockedPixelArtGradingCriteria or pixelArtGradingProperty[criterionProperty]?
        
        criteria.push
          id: criterion
          property: criterionProperty
          propertyPath: criterionProperty
          name: @constructor.CriteriaNames[criterion]
          enabled: pixelArtGradingProperty[criterionProperty]?
          score: pixelArtGradingProperty[criterionProperty]?.score
      
      criteria
  
  scorePercentage: (value) -> Markup.percentage value
  
  hasFinalScore: ->
    @pixelArtGrading.pixelArtGradingProperty()?.score?
    
  letterGrade: ->
    PAG.getLetterGrade @pixelArtGrading.pixelArtGradingProperty().score

  events: ->
    super(arguments...).concat
      'click .criterion .name-area, click .criterion .score': @onClickCriterion
      
  onClickCriterion: (event) ->
    criterion = @currentData()
    @pixelArtGrading.activate criterion.id
