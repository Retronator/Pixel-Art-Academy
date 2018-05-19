AE = Artificial.Everywhere
AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PixelArtAcademy.PixelBoy.Apps.Drawing.Portfolio extends AM.Component
  @register 'PixelArtAcademy.PixelBoy.Apps.Drawing.Portfolio'
  
  @Sections:
    Projects: 'Projects'
    Artworks: 'Artworks'

  constructor: (@drawing) ->
    super

    @sectionHeight = 21
    @initialGroupHeight = 17
    @inactiveGroupHeight = 3
    @activeGroupHeight = 150

  onCreated: ->
    super

    @workbenchLocation = new PAA.Practice.Project.Workbench

    @currentProjects = new ComputedField =>
      new LOI.Adventure.Situation
        location: @workbenchLocation
        timelineId: LOI.adventure.currentTimelineId()

    @currentSection = new ReactiveField null, (a, b) => a is b
    @currentGroup = new ReactiveField null, (a, b) => a is b
      
    # Subscribe to character's projects.
    PAA.Practice.Project.forCharacterId.subscribe @, LOI.characterId()

  sections: ->
    # Get projects from the workbench. Note: we expect things to be instances, so
    # they have to be added as instances in the workbench scene, and not as classes.
    projects = @currentProjects().things()

    projectGroups = for project, index in projects
      assets = for asset, assetIndex in project.assets()
        asset: asset
        index: assetIndex

      index: index
      name: project.fullName()
      project: project
      assets: assets

    projectsSection =
      index: 0
      nameKey: @constructor.Sections.Projects
      groups: projectGroups

    artworksSection =
      index: 1
      nameKey: @constructor.Sections.Artworks
      groups: []

    [projectsSection, artworksSection]

  sectionActiveClass: ->
    section = @currentData()

    'active' if @currentSection() is section

  groupInSectionActiveClass: ->
    section = @currentData()

    'group-in-section-active' if  @currentSection() is section and @currentGroup()

  sectionStyle: ->
    section = @currentData()
    active = @currentSection() is section

    width = 292 - 4 * (1 - section.index)

    style =
      width: "#{width}rem"

    if active
      if @currentGroup()
        height = @sectionHeight + (section.groups.length - 1) * @inactiveGroupHeight + @activeGroupHeight

      else
        height = @sectionHeight + section.groups.length * @initialGroupHeight

      style.height = "#{height}rem"

    style

  groupStyle: ->
    group = @currentData()
    section = @parentDataWith 'groups'

    width: "#{270 - 3 * (section.groups.length - group.index - 1)}rem"

  groupActiveClass: ->
    group = @currentData()

    'active' if @currentGroup() is group

  briefStyle: ->
    asset = @currentData()
    project = @parentDataWith 'assets'

    zIndex = project.assets.length - asset.index

    zIndex: zIndex

  assetStyle: ->
    assetData = @currentData()
    project = @parentDataWith 'assets'
    zoom = @_assetZoom assetData.asset

    zIndex = project.assets.length - assetData.index

    zIndex: zIndex
    width: "#{assetData.asset.width() * zoom + 12}rem"

  spriteStyle: ->
    assetData = @currentData()
    zoom = @_assetZoom assetData.asset

    width: "#{assetData.asset.width() * zoom}rem"
    height: "#{assetData.asset.height() * zoom}rem"

  _assetZoom: (asset) ->
    # Zoom the sprite as much as possible while remaining under 88px.
    zoom = 1
    maxSize = Math.max asset.width(), asset.height()

    zoom++ while (zoom + 1) * maxSize < 88

    zoom

  spriteImage: ->
    assetData = @currentData()
    return unless spriteId = assetData.asset.spriteId()

    new LOI.Assets.Components.SpriteImage
      spriteId: => spriteId
      loadPalette: true

  coverStyle: ->
    top = 56

    if section = @currentSection()
      if @currentGroup()
        top += (section.groups.length - 1) * @inactiveGroupHeight + @activeGroupHeight

      else
        top += section.groups.length * @initialGroupHeight

    top: "#{top}rem"

  events: ->
    super.concat
      'click .section': @onClickSection
      'click .group': @onClickGroup
      'click': @onClick

  onClickSection: (event) ->
    section = @currentData()
    return if section is @currentSection()

    @currentSection section

    # Reset group if we click on the name, but not one of the inner groups.
    # In that case the group handler will activate a new group in this new section.
    @currentGroup null unless $(event.target).closest('.group').length

  onClickGroup: (event) ->
    group = @currentData()
    @currentGroup group

  onClick: (event) ->
    # If we click outside a group, close current group.
    if @currentGroup() and not $(event.target).closest('.group').length
      @currentGroup null
      return

    # If we click outside a section, close current section.
    @currentSection null if @currentSection() and not $(event.target).closest('.section').length

