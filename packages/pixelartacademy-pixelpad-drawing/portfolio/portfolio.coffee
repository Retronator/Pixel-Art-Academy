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
  
  @Sections:
    Tutorials: 'Tutorials'
    Challenges: 'Challenges'
    Projects: 'Projects'
    Artworks: 'Artworks'

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

  _assetScale: (asset) ->
    maxSize = 70
    size = Math.max asset.width(), asset.height()
    displayScale = LOI.adventure.interface.display.scale()

    unless asset.pixelArtScaling()
      # Without pixel art scaling, make the image fit into the 70px.
      maxWindowPixelSize = 70 * displayScale
      displaySize = Math.min size, maxWindowPixelSize
      return displaySize / size / displayScale
    
    # with pixel art scaling, scale the image as much as possible (up to 6) while remaining under 70px.
    return 1 if _.isNaN size
    
    scale = 1

    if size > maxSize
      # The asset is bigger than our maximum size, so we will need to scale downwards. We start
      # operating in effective scale to still have integer magnification compared to window pixels.
      maxEffectiveSize = maxSize * displayScale
      
      effectiveScale = displayScale
      effectiveScale-- while size * effectiveScale > maxEffectiveSize
    
      return effectiveScale / displayScale if effectiveScale > 0
      
      # We need to reduce scale below 1 effective pixel so we start dividing by integer amounts below 1.
      divisor = 1
      divisor++ while size / divisor > maxEffectiveSize
      
      effectiveScale = 1 / divisor
      return effectiveScale / displayScale

    scale++ while scale < 6 and (scale + 1) * size < maxSize

    scale

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

  assetHoveredClass: ->
    assetData = @currentData()

    'hovered' if assetData is @hoveredAsset()
    
  assetLastHoveredClass: ->
    assetData = @currentData()
    
    'last-hovered' if assetData is @lastHoveredAsset()

  assetActiveClass: ->
    assetData = @currentData()

    'active' if assetData is @activeAsset()

  selectedEditorClass: ->
    editor = @currentData()
    selectedEditorId = @drawing.state('editorId') or null

    'selected' if selectedEditorId is editor.id()

  selectedSoftwareClass: ->
    software = @currentData()
    selectedSoftware = @drawing.state('externalSoftware') or null

    'selected' if selectedSoftware is software.value

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
      'click .pixel-boy .editor': @onClickPixelPadEditor
      'click .external .editor': @onClickExternalEditor

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
    assetData = @currentData()
    @hoveredAsset assetData
    @lastHoveredAsset assetData
    
    @audio.assetPan AEc.getPanForElement event.target
    @_assetHoverUnlessFirst assetData

  onPointerLeaveAsset: (event) ->
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

  _goToClickedAsset: ->
    assetData = @currentData()
    
    # Check if there is a custom click handler.
    if assetData.asset.onClick
      assetData.asset.onClick()
      return

    # Set active asset URL.
    AB.Router.changeParameter 'parameter3', assetData.asset.urlParameter()

  onClickPixelPadEditor: (event) ->
    editor = @currentData()
    @drawing.state 'editorId', editor.id()

  onClickExternalEditor: (event) ->
    program = @currentData()
    @drawing.state 'externalSoftware', program.value
  
  onKeyDown: (event) ->
    # To get into cheating mode, you have to have shift pressed (and alt released),
    # to prevent accidental cheating when quitting on windows with alf-F4.
    if AC.Keyboard.isShortcutDown event, {key: AC.Keys.f2, shift: true}
      return unless asset = @activeAsset()?.asset
      
      return unless stepAreas = asset.stepAreas?()
      
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
      return unless activeGroup.thing?.assets() and activeGroup.thing.state 'assets'
      
      cheating = =>
        assets = activeGroup.thing.assets()
        assetsData = activeGroup.thing.state 'assets'
        
        cheatMore = false
        
        while uncompletedAssetData = _.find assetsData, (assetData) => not assetData.completed and _.find assets, (asset) => asset.id() is assetData.id
          console.log "Completing", uncompletedAssetData.id
          
          uncompletedAsset = _.find assets, (asset) => asset.id() is uncompletedAssetData.id
          uncompletedAsset.solve()
          uncompletedAssetData.completed = true
          
          cheatMore = true
        
        if cheatMore
          activeGroup.thing.state 'assets', assetsData
          Meteor.setTimeout cheating, 100
        
        else
          console.log "Cheating commenced!"
      
      cheating()
      
      event.preventDefault()
