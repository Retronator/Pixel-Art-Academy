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
    @loadingProfileId = new ReactiveField null
    @autoLoadedProfileId = new ReactiveField null
    @showProfileLoadingPercentage = new ReactiveField false
    
    # Which profile is shown left-most. Allows to scroll through options.
    @firstProfileOffset = new ReactiveField 0
  
  mixins: -> super(arguments...).concat @activatable
  
  onCreated: ->
    super arguments...

    @profiles = new ComputedField => Persistence.Profile.documents.fetch syncedStorages: $ne: {}
    @maxFirstProfileOffset = new ComputedField => @profiles().length - 4

  show: (autoLoadProfileId) ->
    @autoLoadedProfileId autoLoadProfileId
    @firstProfileOffset 0

    LOI.adventure.showActivatableModalDialog
      dialog: @
      dontRender: true

    if autoLoadProfileId
      new Promise (resolve, reject) =>
        Tracker.autorun (computation) =>
          # Wait until persistence is ready so we have the profiles loaded.
          return unless Persistence.ready()
          computation.stop()
  
          if Persistence.Profile.documents.findOne autoLoadProfileId
            @loadProfile(autoLoadProfileId, false).then =>
              resolve()
              
          else
            console.log "Desired profile was not provided by any of the synced storages." if LOI.debug or LOI.Adventure.debugState
            @callFirstWith null, 'deactivate'
            reject()
    
  loadProfile: (profileId, animate = true) ->
    @loadingProfileId profileId
    @showProfileLoadingPercentage false
    
    loadPan = if animate then AEc.getPanForElement @$("[data-id=#{profileId}]")[0] else 0
    @audio.loadPan loadPan
    @audio.load true
    await _.waitForSeconds 0.5 if animate
    
    @loadingVisible true
    await _.waitForSeconds 0.5 if animate
    @loadingTextVisible true
    
    loadPromise = LOI.adventure.loadGame(profileId).catch (error) =>
      if LOI.adventure.loadingStoredProfile()
        LOI.adventure.showDialogMessage """
            Unfortunately, the last active save game was not able to be automatically loaded.
            The game will now restart from the menu, but if the problem persists,
            this info could be useful: #{error.reason}
          """
        
        , =>
          @callFirstWith null, 'deactivate'
      
      else
        LOI.adventure.showDialogMessage """
          Unfortunately, the disk seems to be corrupt. It's almost certainly my fault, I'll need to fix this!
          Backup of your save should have been created so it should be possible to recover some of your progress.
          Let me know and I'll help. This info could also be useful: #{error.reason}
        """
      
      @loadingVisible false
      @loadingTextVisible false
      @loadingProfileId null
      @audio.load false
      
    # Now that the profile has started loading, see if you should show the loading
    # percentage if it seems the game will load for more than half a second.
    await _.waitForSeconds 0.5
    @showProfileLoadingPercentage Persistence.profileLoadingPercentage() < 100
    
    # When the audio is on, make loading last a while to hear the sweet floppy drive sounds.
    await _.waitForSeconds 2 if LOI.adventure.audioManager.enabled()
    
    await loadPromise
    @loadingProfileId null
    
    @audio.load false
    @loadingTextVisible false
    
    @callFirstWith null, 'deactivate' if LOI.adventure.profileId()
  
  onActivate: (finishedActivatingCallback) ->
    await _.waitForSeconds 0.5
    finishedActivatingCallback()

  onDeactivate: (finishedDeactivatingCallback) ->
    await _.waitForSeconds 0.5
    @loadingVisible false
    finishedDeactivatingCallback()

  showBackButton: ->
    not (@loadingVisible() or @autoLoadedProfileId())
    
  profilesStyle: ->
    offset = @firstProfileOffset()

    left: "-#{offset * profileWidth}rem"

  nextButtonDisabledAttribute: ->
    disabled: true if @firstProfileOffset() is @maxFirstProfileOffset()

  previousButtonDisabledAttribute: ->
    disabled: true if @firstProfileOffset() is 0

  nextButtonVisibleClass: ->
    'visible' if @maxFirstProfileOffset() > 0

  previousButtonVisibleClass: ->
    'visible' if @maxFirstProfileOffset() > 0

  profileActiveClass: ->
    profile = @currentData()
    'active' if @loadingProfileId() is profile._id or LOI.adventure.profileId() is profile._id

  profileName: ->
    profile = @currentData()
    profile.displayName or profile._id
    
  loadingVisibleClass: ->
    'visible' if @loadingVisible()
  
  loadingTextVisibleClass: ->
    'visible' if @loadingTextVisible()
    
  profileLoadingPercentage: ->
    Math.floor Persistence.profileLoadingPercentage()

  events: ->
    super(arguments...).concat
      'click .profile': @onClickProfile
      'click .previous-button': @onClickPreviousButton
      'click .next-button': @onClickNextButton

  onClickProfile: (event) ->
    profile = @currentData()
    @loadProfile profile._id

  onClickPreviousButton: (event) ->
    newIndex = Math.max 0, @firstProfileOffset() - 4

    @firstProfileOffset newIndex

  onClickNextButton: (event) ->
    newIndex = Math.min @maxFirstProfileOffset(), @firstProfileOffset() + 4

    @firstProfileOffset newIndex
