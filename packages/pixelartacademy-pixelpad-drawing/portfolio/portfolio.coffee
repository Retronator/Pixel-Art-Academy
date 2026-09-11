AE = Artificial.Everywhere
AM = Artificial.Mirage
AB = Artificial.Base
AEc = Artificial.Echo
AC = Artificial.Control
LOI = LandsOfIllusions
PAA = PixelArtAcademy
LM = PixelArtAcademy.LearnMode

class PAA.PixelPad.Apps.Drawing.Portfolio extends LOI.Component
  @id: -> 'PixelArtAcademy.PixelPad.Apps.Drawing.Portfolio'
  
  @Sections =
    Tutorials: 'Tutorials'
    Challenges: 'Challenges'
    Projects: 'Projects'
    Artworks: 'Artworks'
    
  @AssetsAreaAnimationStates =
    Opened: 'Opened'
    Separated: 'Separated'
    Closed: 'Closed'

  # Subscriptions
  @artworksWithAssets = new AB.Subscription name: "#{@id()}.artworks"
  
  @Audio = new LOI.Assets.Audio.Namespace @id(),
    variables:
      sectionOpen: AEc.ValueTypes.Trigger
      sectionClose: AEc.ValueTypes.Trigger
      sectionHover:
        valueType: AEc.ValueTypes.Trigger
        throttle: 100
      groupOpen: AEc.ValueTypes.Trigger
      groupClose: AEc.ValueTypes.Trigger
      groupHover:
        valueType: AEc.ValueTypes.Trigger
        throttle: 100
      assetHover:
        valueType: AEc.ValueTypes.Trigger
        throttle: 100
      assetPan:
        valueType: AEc.ValueTypes.Number
      folderHover:
        valueType: AEc.ValueTypes.Trigger
        throttle: 200
      folderOpen: AEc.ValueTypes.Trigger
      folderClose: AEc.ValueTypes.Trigger
        
  constructor: (@drawing) ->
    super arguments...

    @sectionHeight = 23
    @maxInitialGroupHeight = 19
    @reducedGroupHeight = 10
    @minMinimizedGroupHeight = 2
    @maxMinimizedGroupHeight = 5
    @inactiveSectionGroupHeight = 4
    @inactiveSectionLastGroupHeight = 19
    @activeGroupHeight = 150
    @groupsMaxTotalHeight = 180
    @sectionsMargin = 13
    @sectionsMaxTotalHeight = 241 - 2 * @sectionsMargin
    @assetsAreaAnimationState = new ReactiveField null
    
  getNeighboringAsset: (assetIndexOffset) ->
    return unless @isCreated()
    return unless activeAsset = @activeAsset()
    return unless activeGroup = _.last @activeGroups()
    return unless activeGroup.assets
    
    # Locate the active asset in the current assets array instead of relying on its
    # stored index, since assets without URL parameters are filtered out of the group.
    activeGroupAssets = activeGroup.assets()
    activeAssetIndex = activeGroupAssets.indexOf activeAsset
    return if activeAssetIndex < 0
    
    activeGroupAssets[activeAssetIndex + assetIndexOffset]

  sectionActiveClass: ->
    section = @currentData()

    'active' if @activeSection() is section

  sectionSubgroupActiveClass: ->
    section = @currentData()

    'subgroup-active' if @activeSection() is section and @activeGroups().length
  
  assetGroupActiveClass: ->
    'asset-group-active' if @assetGroupIsActive()
  
  groupSubgroupActiveClass: ->
    group = @currentData()
    activeGroups = @activeGroups()
    
    'subgroup-active' if group in @activeGroups() and activeGroups[group.level + 1]

  sectionStyle: ->
    section = @currentData()
    activeSection = @activeSection()
    
    width = @sectionWidth section
    
    if section is activeSection
      height = @activeSectionHeight()
      
    else
      height = @inactiveSectionHeight()
      
    style =
      width: "#{width}rem"
      height: "#{height}rem"
    
    style
    
  sectionWidth: (section) ->
    292 - 4 * (@sections().length - section.index)

  groupStyle: ->
    group = @currentData()
    section = @parentDataWith 'isSection'
    
    activeSection = @activeSection()
    activeGroups = @activeGroups()
    
    width = @groupWidth group, 0
    
    if section is activeSection
      height = @groupHeight group, activeGroups
      
    else
      parent = @parentDataWith 'groups'
      
      if group is _.last parent.groups()
        height = @inactiveSectionLastGroupHeight
      
      else
        height = @inactiveSectionGroupHeight
      
    width: "#{width}rem"
    height: "#{height}rem"

  groupHeight: (group, activeGroups) ->
    if group in activeGroups
      # If the group has assets, it will display at active group height.
      return @activeGroupHeight if group.assets
      
      # The group must have other groups inside. See if a subgroup is active.
      subgroups = group.groups()
  
      if activeSubGroup = activeGroups[group.level + 1]
        # A child asset group is active. We have other groups collapsed and the active group at its desired height.
        @activeGroupHeaderHeight() + (subgroups.length - 1) * @inactiveGroupHeight() + @groupHeight activeSubGroup, activeGroups
      
      else
        # No subgroup is active. We have the title of this group plus all sub groups.
        @maxInitialGroupHeight + subgroups.length * @initialGroupHeight()
      
    else if group.level is activeGroups.length
      @initialGroupHeight()
      
    else
      @inactiveGroupHeight()
      
  groupWidth: (group, dataLevel) ->
    parentDataLevel = dataLevel
    
    loop
      parentDataLevel++
      return 0 unless parent = Template.parentData parentDataLevel
      break if parent?.groups
    
    parentWidth = if parent.isSection then @sectionWidth parent else @groupWidth parent, parentDataLevel
    
    parentWidth - 18 - 3 * (parent.groups().length - group.index - 1)

  groupActiveClass: ->
    group = @currentData()

    'active' if group in @activeGroups()
  
  assetsAreaAnimationClass: ->
    assetsProviderData = @currentData()
    
    if assetsAreaAnimationState = @assetsAreaAnimationState()
      if assetsAreaAnimationState.assetsProviderData is assetsProviderData
        return _.kebabCase assetsAreaAnimationState.state
    
    return unless assetsProviderData.thing.assetsProviders()
    return if assetsProviderData.thing.activeAssetsProvider() is assetsProviderData.assetsProvider

    _.kebabCase @constructor.AssetsAreaAnimationStates.Closed
  
  folderStyle: ->
    group = @currentData()
    left = -59 + group.assets().length * 1.5
    
    left: "calc(50% + #{left}rem)"

  briefStyle: ->
    assetData = @currentData()
    group = @parentDataWith 'assets'

    zIndex = group.assets().length - assetData.index

    zIndex: zIndex

  assetStyle: ->
    assetData = @currentData()
    group = @parentDataWith 'assets'

    zIndex = group.assets().length - assetData.index

    zIndex: zIndex
    width: "#{assetData.asset.width() * assetData.scale() + assetData.asset.portfolioBorderWidth() * 2}rem"

  coverStyle: ->
    sections = @sections()
    
    sectionsCount = sections.length
    
    activeSectionHeight = @activeSectionHeight()
    inactiveSectionHeight = @inactiveSectionHeight()

    if @activeSection()
      top = @sectionsMargin + (sectionsCount - 1) * inactiveSectionHeight + activeSectionHeight
        
    else
      top = @sectionsMargin + sectionsCount * inactiveSectionHeight

    top: "#{top}rem"
  
  sectionsVisible: ->
    # Only show sections when not in the editor to prevent updates while editing.
    not @drawing.editor().active()
  
  assetWaitingClass: ->
    assetData = @currentData()

    'waiting' if assetData is @waitingAsset()

  assetHoveredClass: ->
    assetData = @currentData()

    'hovered' if assetData is @hoveredAsset()
    
  assetLastHoveredClass: ->
    assetData = @currentData()
    
    'last-hovered' if assetData is @lastHoveredAsset()

  assetActiveClass: ->
    assetData = @currentData()

    'active' if assetData is @activeAsset()

  events: ->
    super(arguments...).concat
      'click .section': @onClickSection
      'click .group-header': @onClickGroupHeader
      'click': @onClick
      'pointerenter .section': @onPointerEnterSection
      'pointerenter .group-name': @onPointerEnterGroupName
      'pointerenter .asset': @onPointerEnterAsset
      'pointerleave .asset': @onPointerLeaveAsset
      'click .brief': @onClickBrief
      'click .asset': @onClickAsset
      'pointerenter .close-button': @onPointerEnterCloseButton
      'pointerleave .close-button': @onPointerLeaveCloseButton
      'click .close-button': @onClickCloseButton
      'pointerenter .assets-provider': @onPointerEnterAssetsProvider
      'pointerleave .assets-provider': @onPointerLeaveAssetsProvider
      'click .assets-provider': @onClickAssetsProvider

  onClickSection: (event) ->
    section = @currentData()

    clickInsideContent = $(event.target).closest('.content').length > 0

    if section is @activeSection()
      @activeSection null unless clickInsideContent

    else
      @activeSection section

      # Reset group if we click on the name, but not one of the inner groups.
      # In that case the group handler will activate a new group in this new section.
      @activeGroups [] unless clickInsideContent

  onClickGroupHeader: (event) ->
    group = @currentData()
    section = @parentDataWith 'isSection'
    
    # Only open the group if we have an active section or if the group is the only one in the section.
    return unless @activeSection() is section or section.groups().length is 1

    activeGroups = @activeGroups()
    newActiveGroups = activeGroups[0...group.level]
    
    if group is _.last activeGroups
      @activeGroups newActiveGroups

    else
      newActiveGroups.push group
      @activeGroups newActiveGroups

  onClick: (event) ->
    # If we click outside the clipboard, close current asset.
    if @activeAsset() and not $(event.target).closest('.clipboard').length
      @activeAsset null
      return

    # If we click outside a group, close current group.
    if @activeGroups().length and not $(event.target).closest('.group').length
      @activeGroups []

      # Don't let section close as well, if we were clicking inside the current section.
      event.stopPropagation() if @currentData() is @activeSection()
      return

    # If we click outside a section, close current section.
    @activeSection null if @activeSection() and not $(event.target).closest('.section').length
  
  onPointerEnterSection: (event) ->
    section = @currentData()
    return if section is @activeSection()
    
    @audio.sectionHover()
    
  onPointerEnterGroupName: (event) ->
    group = @currentData()
    return if group in @activeGroups()
    
    return unless activeSection = @activeSection()
    
    section = @parentDataWith 'groups'
    return unless section is activeSection
    
    @audio.groupHover()

  onPointerEnterAsset: (event) ->
    return if @assetsAreaAnimationState()
    
    assetData = @currentData()
    @hoveredAsset assetData
    @lastHoveredAsset assetData
    
    @audio.assetPan AEc.getPanForElement event.target
    @_assetHoverUnlessFirst assetData

  onPointerLeaveAsset: (event) ->
    return if @assetsAreaAnimationState()
    
    assetData = @hoveredAsset()
    @hoveredAsset null

    # Only trigger the hover sound when we're not leaving because of selecting an asset.
    @_assetHoverUnlessFirst assetData if assetData and not @activeAsset()
    
  _assetHoverUnlessFirst: (assetData) ->
    return unless assetData.index
    
    @audio.assetHover()

  onClickBrief: (event) ->
    @_goToClickedAsset()

  onClickAsset: (event) ->
    @_goToClickedAsset()
    
  onPointerEnterCloseButton: (event) ->
    return if @assetsAreaAnimationState()
    
    @audio.folderHover()
    
  onPointerLeaveCloseButton: (event) ->
    return if @assetsAreaAnimationState()
    
    @audio.folderHover()
    
  onClickCloseButton: (event) ->
    assetsProviderData = @currentData()
    
    @audio.folderClose()

    @assetsAreaAnimationState
      assetsProviderData: assetsProviderData
      state: @constructor.AssetsAreaAnimationStates.Separated
    
    await _.waitForSeconds 0.5
    
    @assetsAreaAnimationState
      assetsProviderData: assetsProviderData
      state: @constructor.AssetsAreaAnimationStates.Closed
      
    await _.waitForSeconds 0.5
    
    assetsProviderData.thing.deactivateAssetsProvider()
    @assetsAreaAnimationState null
  
  onPointerEnterAssetsProvider: (event) ->
    @audio.folderHover()
    
  onPointerLeaveAssetsProvider: (event) ->
    @audio.folderHover()
    
  onClickAssetsProvider: (event) ->
    assetsProviderData = @currentData()
    
    @audio.folderOpen()

    @assetsAreaAnimationState
      assetsProviderData: assetsProviderData
      state: @constructor.AssetsAreaAnimationStates.Separated

    await _.waitForSeconds 0.5
    
    @assetsAreaAnimationState
      assetsProviderData: assetsProviderData
      state: @constructor.AssetsAreaAnimationStates.Opened
      
    await _.waitForSeconds 0.5
    
    assetsProviderData.thing.activateAssetsProvider assetsProviderData.assetsProvider
    @assetsAreaAnimationState null

  _goToClickedAsset: ->
    assetData = @currentData()
    
    # Check if there is a custom click handler.
    if assetData.asset.onClick
      assetData.asset.onClick()
      return

    # Set active asset URL.
    AB.Router.changeParameter 'parameter3', assetData.asset.urlParameter()
  
  onKeyDown: (event) ->
    # To get into cheating mode, you have to have shift pressed (and alt released),
    # to prevent accidental cheating when quitting on windows with alf-F4.
    if AC.Keyboard.isShortcutDown event, {key: AC.Keys.f2, shift: true}
      return unless asset = @activeAsset()?.asset
      
      unless stepAreas = asset.stepAreas?()
        asset.solve?()
        event.preventDefault()
        return
      
      for stepArea in stepAreas when not stepArea.completed()
        activeStep = stepArea.steps()[stepArea.activeStepIndex()]
        
        activeStep.solve()
        event.preventDefault()
        break
      
    else if AC.Keyboard.isShortcutDown event, {key: AC.Keys.f3, shift: true}
      return unless asset = @activeAsset()?.asset
      
      asset.solveAndComplete?()
      event.preventDefault()
    
    else if AC.Keyboard.isShortcutDown event, {key: AC.Keys.f4, shift: true}
      console.log "Cheating commences …"
      
      return unless activeGroup = _.last @activeGroups()
      
      moreCheating = true
      
      while moreCheating
        break unless assets = activeGroup.thing?.assets()
        break unless assetsData = activeGroup.thing.state 'assets'
        
        moreCheating = false
        
        for assetData, assetIndex in assetsData when not assetData.completed
          continue unless asset = _.find assets, (asset) => asset.id() is assetData.id
          continue unless asset.solve
          
          console.log "Completing", assetData.id
          await asset.solve()
          assetsData[assetIndex] = _.extend {}, assetData, completed: true
          
          activeGroup.thing.state 'assets', assetsData
          await _.waitForSeconds 0.5
          
          moreCheating = true
          break
      
      console.log "Cheating commenced!"
      
      event.preventDefault()
