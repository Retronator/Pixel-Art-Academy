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
    @groupHeight = 17

  onCreated: ->
    super

    @workbenchLocation = new PAA.Practice.Project.Workbench

    @currentProjects = new ComputedField =>
      new LOI.Adventure.Situation
        location: @workbenchLocation
        timelineId: LOI.adventure.currentTimelineId()

    @currentSection = new ReactiveField null, (a, b) => a is b

  sections: ->
    # Get projects from the workbench.
    projects = @currentProjects().things()

    projectGroups = for project, index in projects
      index: index
      name: project.fullName()

    projectGroups = [
      index: 0
      name: "Snake game"
    ,
      index: 1
      name: "Fake assignment"
    ,
      index: 2
      name: "Secret project"
    ]

    projectsSection =
      index: 0
      nameKey: @constructor.Sections.Projects
      groups: projectGroups

    artworksSection =
      index: 1
      nameKey: @constructor.Sections.Artworks
      groups: [
        index: 0
        name: "Daily practice"
      ,
        index: 1
        name: "Isometric"
      ,
        index: 3
        name: "Pixel Computers"
      ,
        index: 4
        name: "ZX Spectrum"
      ,
        index: 5
        name: "Pixel Art Academy"
      ]

    [projectsSection, artworksSection]

  sectionActiveClass: ->
    section = @currentData()

    'active' if @currentSection() is section

  sectionStyle: ->
    section = @currentData()
    active = @currentSection() is section

    width = 292 - 2 * (1 - section.index)

    style =
      width: "#{width}rem"

    if active
      height = @sectionHeight + section.groups.length * @groupHeight
      style.height = "#{height}rem"

    style

  groupStyle: ->
    group = @currentData()
    section = @parentDataWith 'groups'

    width: "#{250 - 4 * (section.groups.length - group.index - 1)}rem"

  coverStyle: ->
    top = 56

    if section = @currentSection()
      top += section.groups.length * @groupHeight - 2

    top: "#{top}rem"

  events: ->
    super.concat
      'click .section': @onClickSection

  onClickSection: ->
    section = @currentData()
    @currentSection section
