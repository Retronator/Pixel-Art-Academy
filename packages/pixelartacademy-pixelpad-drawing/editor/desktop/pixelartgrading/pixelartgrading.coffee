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

  constructor: ->
    super arguments...

    @active = new ReactiveField false
    
    @criteria = [
      name: 'Pixel-perfect diagonals'
      grade: 1
    ,
      name: 'Smooth curves'
      grade: 0.78
    ]
    
    @editable = true
    
  onCreated: ->
    super arguments...
    
    @desktop = @ancestorComponentOfType PAA.PixelPad.Apps.Drawing.Editor.Desktop
    
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
    
    "#{Math.floor criterion.grade * 100}%"
  
  events: ->
    super(arguments...).concat
      'click': @onClick
    
  onClick: (event) ->
    return if @active()

    @active true
