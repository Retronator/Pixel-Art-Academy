AM = Artificial.Mirage
AEc = Artificial.Echo
LOI = LandsOfIllusions
PAA = PixelArtAcademy
FM = FataMorgana

PAE = PAA.Practice.PixelArtEvaluation
Markup = PAA.Practice.Helpers.Drawing.Markup

class PAA.PixelPad.Apps.Drawing.Editor.Desktop.PixelArtEvaluation.ConsistentLineWidth extends LOI.View
  @id: -> 'PixelArtAcademy.PixelPad.Apps.Drawing.Editor.Desktop.PixelArtEvaluation.ConsistentLineWidth'
  @register @id()
  
  @CriteriaNames:
    IndividualConsistency: 'Individual line width'
    GlobalConsistency: 'Uniform line type'
  
  @CategoryNames:
    IndividualConsistency:
      Consistent: "Consistent (A)"
      Varying: "Varying (B–F)"
    GlobalConsistency:
      Thin: 'Thin'
      Thick: 'Thick'
      Wide: 'Wide'
      Varying: 'Varying'
  
  onCreated: ->
    super arguments...
    
    @pixelArtEvaluation = @ancestorComponentOfType PAA.PixelPad.Apps.Drawing.Editor.Desktop.PixelArtEvaluation

    @consistentLineWidthProperty = new ComputedField =>
      @pixelArtEvaluation.bitmap()?.properties?.pixelArtEvaluation?.consistentLineWidth
      
    @editable = new ComputedField => @consistentLineWidthProperty()?.editable ? @pixelArtEvaluation.editable()
    
    @criteria = new ComputedField =>
      consistentLineWidthProperty = @consistentLineWidthProperty()
      editable = @editable()
      
      criteria = []
      
      for criterion of PAE.Subcriteria.ConsistentLineWidth
        criterionProperty = _.lowerFirst criterion
        
        # Show only existing criteria when not editable (and all otherwise so we can toggle them on and off).
        continue unless editable or consistentLineWidthProperty?[criterionProperty]?
        
        if enabled = consistentLineWidthProperty?[criterionProperty]?
          categories = for category, name of @constructor.CategoryNames[criterion]
            id: category
            name: name
            count: consistentLineWidthProperty[criterionProperty].counts[_.lowerFirst category]
            
        else
          categories = null
        
        criteria.push
          id: criterion
          parentId: PAE.Criteria.ConsistentLineWidth
          property: criterionProperty
          propertyPath: "consistentLineWidth.#{criterionProperty}"
          name: @constructor.CriteriaNames[criterion]
          enabled: enabled
          score: consistentLineWidthProperty?[criterionProperty]?.score
          categories: categories
      
      criteria
  
  scorePercentage: (value) -> Markup.percentage value
  
  events: ->
    super(arguments...).concat
      'pointerenter .category .count': @onPointerEnterCategory
      'pointerleave .category .count': @onPointerLeaveCategory
  
  onPointerEnterCategory: (event) ->
    category = @currentData()
    criterion = Template.parentData()

    @pixelArtEvaluation.hoveredFilterValue
      criterion: criterion.id
      value: category.id
  
  onPointerLeaveCategory: (event) ->
    @pixelArtEvaluation.hoveredFilterValue null
