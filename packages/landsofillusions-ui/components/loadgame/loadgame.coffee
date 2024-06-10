AB = Artificial.Babel
AC = Artificial.Control
AM = Artificial.Mirage
AEc = Artificial.Echo
LOI = LandsOfIllusions

Persistence = Artificial.Mummification.Document.Persistence

profileWidth = 80

class LOI.Components.LoadGame extends LOI.Component
  @id: -> 'LandsOfIllusions.Components.LoadGame'
  @register @id()

  @url: -> 'loadgame'
  
  @version: -> '0.0.1'
  
  @Audio = new LOI.Assets.Audio.Namespace @id(),
    variables:
      load: AEc.ValueTypes.Boolean
      loadPan: AEc.ValueTypes.Number
  
  constructor: (@options) ->
    super arguments...
    
    @activatable = new LOI.Components.Mixins.Activatable
    @loadingVisible = new ReactiveField false
    @loadingTextVisible = new ReactiveField false
  
  mixins: -> super(arguments...).concat @activatable
  
  onCreated: ->
    super arguments...

    @profiles = new ComputedField => Persistence.Profile.documents.fetch syncedStorages: $ne: {}
    @maxFirstProfileOffset = new ComputedField => @profiles().length - 4

    # Which profile is shown left-most. Allows to scroll through options.
    @firstProfileOffset = new ReactiveField 0
    
    @loadingProfileId = new ReactiveField null
    
  show: ->
    @firstProfileOffset 0

    LOI.adventure.showActivatableModalDialog
      dialog: @
      dontRender: true

  onActivate: (finishedActivatingCallback) ->
    await _.waitForSeconds 0.5
    finishedActivatingCallback()

  onDeactivate: (finishedDeactivatingCallback) ->
    await _.waitForSeconds 0.5
    @loadingVisible false
    finishedDeactivatingCallback()

  profilesStyle: ->
    offset = @firstProfileOffset()

    left: "-#{offset * profileWidth}rem"

  profileActiveClass: ->
    profile = @currentData()

    'active' if profile?._id is LOI.adventure.profileId()

  nextButtonDisabledAttribute: ->
    disabled: true if @firstProfileOffset() is @maxFirstProfileOffset()

  previousButtonDisabledAttribute: ->
    disabled: true if @firstProfileOffset() is 0

  nextButtonVisibleClass: ->
    'visible' if @maxFirstProfileOffset() > 0

  previousButtonVisibleClass: ->
    'visible' if @maxFirstProfileOffset() > 0

  activeClass: ->
    profile = @currentData()
    'active' if @loadingProfileId() is profile._id or LOI.adventure.profileId() is profile._id

  profileName: ->
    profile = @currentData()
    profile.displayName or profile._id
    
  loadingVisibleClass: ->
    'visible' if @loadingVisible()
  
  loadingTextVisibleClass: ->
    'visible' if @loadingTextVisible()

  events: ->
    super(arguments...).concat
      'click .profile': @onClickProfile
      'click .previous-button': @onClickPreviousButton
      'click .next-button': @onClickNextButton

  onClickProfile: (event) ->
    profile = @currentData()

    @loadingProfileId profile._id
    
    @audio.loadPan AEc.getPanForElement event.target
    @audio.load true
    await _.waitForSeconds 0.5
    
    @loadingVisible true
    await _.waitForSeconds 0.5
    @loadingTextVisible true
    
    loadPromise = LOI.adventure.loadGame(profile._id).catch (error) =>
      LOI.adventure.showDialogMessage """
        Unfortunately the disk seems to be corrupt. It's almost certainly my fault, I'm sorry!
        If you report this bug, this could be of help: #{error.reason}
      """
      
      @loadingVisible false
      @loadingTextVisible false
      @loadingProfileId null
      @audio.load false
    
    # When the audio is on, make loading last a while to hear the sweet floppy drive sounds.
    await _.waitForSeconds 2.5 if LOI.adventure.audioManager.enabled()
    
    await loadPromise
    @loadingProfileId null
    
    @audio.load false
    @loadingTextVisible false

    @callFirstWith null, 'deactivate' if LOI.adventure.profileId()
    
  onClickPreviousButton: (event) ->
    newIndex = Math.max 0, @firstProfileOffset() - 4

    @firstProfileOffset newIndex

  onClickNextButton: (event) ->
    newIndex = Math.min @maxFirstProfileOffset(), @firstProfileOffset() + 4

    @firstProfileOffset newIndex
