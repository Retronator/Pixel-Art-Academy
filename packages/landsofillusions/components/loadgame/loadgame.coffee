AB = Artificial.Babel
AC = Artificial.Control
AM = Artificial.Mirage
LOI = LandsOfIllusions

class LOI.Components.LoadGame extends AM.Component
  @id: -> 'LandsOfIllusions.Components.LoadGame'
  @register @id()

  @url: -> 'loadgame'
  
  @version: -> '0.0.1'
  
  constructor: (@options) ->
    super arguments...
    
    @activatable = new LOI.Components.Mixins.Activatable()
    
    @profiles = new ComputedField => []
    
  mixins: -> [@activatable]
  
  onCreated: ->
    super arguments...
  
    # Which profile is shown left-most. Allows to scroll through options.
    @firstProfileOffset = new ReactiveField 0
    
  show: ->
    LOI.adventure.showActivatableModalDialog
      dialog: @
      dontRender: true

  profilesStyle: ->
    offset = @firstProfileOffset()

    left: "-#{offset * 75}rem"

  profileActiveClass: ->
    profile = @currentData()

    'active' if profile?._id is LOI.adventure.profileId()

  nextButtonVisibleClass: ->
    'visible' if @firstProfileOffset() < @profiles().length - 1

  previousButtonVisibleClass: ->
    'visible' if @firstProfileOffset() > 0

  events: ->
    super(arguments...).concat
      'click .profile': @onClickProfile
      'click .previous-button': @onClickPreviousButton
      'click .next-button': @onClickNextButton

  onClickProfile: (event) ->
    profile = @currentData()
    
  onClickPreviousButton: (event) ->
    newIndex = Math.max 0, @firstProfileOffset() - 1

    @firstProfileOffset newIndex

  onClickNextButton: (event) ->
    newIndex = Math.min @profiles().length - 2, @firstProfileOffset() + 1

    @firstProfileOffset newIndex
