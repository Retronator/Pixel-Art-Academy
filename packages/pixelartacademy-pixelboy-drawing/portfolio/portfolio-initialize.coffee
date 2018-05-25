AE = Artificial.Everywhere
AM = Artificial.Mirage
AB = Artificial.Base
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PixelArtAcademy.PixelBoy.Apps.Drawing.Portfolio extends PixelArtAcademy.PixelBoy.Apps.Drawing.Portfolio
  # We call register here because it is the last in the inheritance chain.
  @register @id()

  constructor: (@drawing) ->
    super

    @sectionHeight = 21
    @initialGroupHeight = 17
    @inactiveGroupHeight = 3
    @activeGroupHeight = 150

  onCreated: ->
    super

    sectionLocations =
      challenge: new PAA.Practice.Challenges.Drawing
      project: new PAA.Practice.Project.Workbench
    
    for sectionThingName, sectionLocation of sectionLocations
      do (sectionThingName, sectionLocation) =>
        currentSituation = new LOI.Adventure.Situation
          location: sectionLocation

        groups = new ComputedField =>
          # Get projects from the workbench. Note: we expect things to be instances, so
          # they have to be added as instances in the workbench scene, and not as classes.
          sectionThings = currentSituation.things()

          for sectionThing, index in sectionThings
            do (sectionThing, index) =>
              assets = new ComputedField =>
                for asset, assetIndex in sectionThing.assets()
                  index: assetIndex
                  asset: asset
                  scale: => @_assetScale asset

              index: index
              name: => sectionThing.fullName()
              assets: assets

        section =
          nameKey: @constructor.Sections["#{_.upperFirst sectionThingName}s"]
          groups: groups

        @["#{sectionThingName}sSection"] = section

    @artworksSection =
      nameKey: @constructor.Sections.Artworks
      groups: => []
        
    @sections = new ComputedField =>
      sections = []

      sections.push @projectsSection if @projectsSection.groups().length
      sections.push @challengesSection
      sections.push @artworksSection if @artworksSection.groups().length

      # If the active section is not present anymore, close the section.
      if @activeSection and not @activeSection() in sections
        @activeSection null
        @activeGroup null
        @hoveredAsset null

      # Update section indices.
      section.index = index for section, index in sections

      sections

    @activeSection = new ReactiveField null, (a, b) => a is b
    @activeGroup = new ReactiveField null, (a, b) => a is b
    @hoveredAsset = new ReactiveField null, (a, b) => a is b

    @activeAsset = new ComputedField =>
      return unless spriteId = AB.Router.getParameter 'parameter3'

      # Find the asset that uses this sprite.
      for section in @sections()
        for group in section.groups()
          for assetData in group.assets()
            if assetData.asset.spriteId() is spriteId
              @activeSection section
              @activeGroup group
              return assetData

    # Displayed asset retains its value until another asset gets activated
    @displayedAsset = new ReactiveField null

    @autorun (computation) =>
      return unless activeAsset = @activeAsset()
      @displayedAsset activeAsset

    # Subscribe to character's projects.
    PAA.Practice.Project.forCharacterId.subscribe @, LOI.characterId()
