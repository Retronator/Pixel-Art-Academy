AB = Artificial.Babel
AC = Artificial.Control
AM = Artificial.Mirage
LOI = LandsOfIllusions

Persistence = Artificial.Mummification.Document.Persistence

class LOI.Components.LoadGame extends AM.Component
  @id: -> 'LandsOfIllusions.Components.LoadGame'
  @register @id()

  @url: -> 'loadgame'
  
  @version: -> '0.0.1'
  
  constructor: (@options) ->
    super arguments...
    
    @activatable = new LOI.Components.Mixins.Activatable()
    
    @profiles = new ComputedField => Persistence.Profile.documents.fetch()
    
  mixins: -> [@activatable]
  
  onCreated: ->
    super arguments...
  
    # Which profile is shown left-most. Allows to scroll through options.
    @firstProfileOffset = new ReactiveField 0
    
  show: ->
    LOI.adventure.showActivatableModalDialog
      dialog: @
      dontRender: true

  onActivate: (finishedActivatingCallback) ->
    Meteor.setTimeout =>
      finishedActivatingCallback()
    ,
      500

  onDeactivate: (finishedDeactivatingCallback) ->
    Meteor.setTimeout =>
      finishedDeactivatingCallback()
    ,
      500

  profilesStyle: ->
    offset = @firstProfileOffset()

    left: "-#{offset * 76}rem"

  profileActiveClass: ->
    profile = @currentData()

    'active' if profile?._id is LOI.adventure.profileId()

  nextButtonVisibleClass: ->
    'visible' if @firstProfileOffset() < @profiles().length - 4

  previousButtonVisibleClass: ->
    'visible' if @firstProfileOffset() > 0

  activeClass: ->
    profile = @currentData()
    'active' if LOI.adventure.profileId() is profile._id

  events: ->
    super(arguments...).concat
      'click .profile': @onClickProfile
      'click .previous-button': @onClickPreviousButton
      'click .next-button': @onClickNextButton

  onClickProfile: (event) ->
    profile = @currentData()
    await LOI.adventure.loadGame profile._id

    await _.waitForSeconds 1
    @callFirstWith null, 'deactivate'
    
  onClickPreviousButton: (event) ->
    newIndex = Math.max 0, @firstProfileOffset() - 1

    @firstProfileOffset newIndex

  onClickNextButton: (event) ->
    newIndex = Math.min @profiles().length - 2, @firstProfileOffset() + 1

    @firstProfileOffset newIndex
