AM = Artificial.Mirage
AEc = Artificial.Echo
LOI = LandsOfIllusions
PAA = PixelArtAcademy
FM = FataMorgana

class PAA.PixelPad.Apps.Drawing.Editor.Desktop.PixelArtGrading extends LOI.View
  @id: -> 'PixelArtAcademy.PixelPad.Apps.Drawing.Editor.Desktop.PixelArtGrading'
  @register @id()

  @template: -> @constructor.id()
  
  @Audio = new LOI.Assets.Audio.Namespace @id(),
    # Loaded from the PixelArtAcademy.PixelPad.Apps.Drawing.Editor.Desktop namespace.
    subNamespace: true
    variables:
      flipPaper: AEc.ValueTypes.Trigger
      
  @CriteriaNames:
    PixelPerfectDiagonals: 'Pixel-perfect diagonals'
    SmoothCurves: 'Smooth curves'
    ConsistentLineWidth: 'Consistent line width'

  constructor: ->
    super arguments...

    @active = new ReactiveField false
    
  onCreated: ->
    super arguments...
    
    @desktop = @ancestorComponentOfType PAA.PixelPad.Apps.Drawing.Editor.Desktop
    
    @pixelArtGradingProperty = new ComputedField =>
      @interface.getLoaderForActiveFile()?.asset().properties?.pixelArtGrading
    
    @editable = new ComputedField => @pixelArtGradingProperty()?.editable
    
    @criteria = new ComputedField =>
      return unless pixelArtGradingProperty = @pixelArtGradingProperty()
      editable = @editable()
      
      criteria = []
      
      for criterion of PAA.Practice.PixelArtGrading.Criteria
        criterionProperty = _.lowerFirst criterion
        
        # Show only existing criteria when not editable (and all otherwise so we can toggle them on and off).
        continue unless editable or pixelArtGradingProperty[criterionProperty]?
        
        criteria.push
          name: @constructor.CriteriaNames[criterion]
          grade: pixelArtGradingProperty[criterionProperty]?.score
      
      criteria
    
    # Automatically enter focused mode when active.
    @autorun (computation) =>
      @desktop.focusedMode @active()
    
    # Automatically deactivate when exiting focused mode.
    @autorun (computation) =>
      @active false unless @desktop.focusedMode()

  activeClass: ->
    'active' if @active()
    
  gradePercentage: ->
    criterion = @currentData()
    return unless criterion.grade?
    
    "#{Math.floor criterion.grade * 100}%"
    
  letterGrade: ->
    grade = @pixelArtGradingProperty()?.grade or 0
    PAA.Practice.PixelArtGrading.getLetterGrade grade
  
  events: ->
    super(arguments...).concat
      'click': @onClick
    
  onClick: (event) ->
    return if @active()

    @active true
