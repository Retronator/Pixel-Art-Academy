AE = Artificial.Everywhere
AM = Artificial.Mirage
AB = Artificial.Base
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.PixelBoy.Apps.Drawing.Portfolio extends PixelArtAcademy.PixelBoy.Apps.Drawing.Portfolio
  # We call register here because it is the last in the inheritance chain.
  @register @id()

  @ExternalSoftware =
    Aseprite: 'Aseprite'
    PyxelEdit: 'Pyxel Edit'
    GraphicGale: 'Graphics Gale'
    ProMotion: 'Pro Motion'
    GRAFX2: 'GRAFX2'
    Photoshop: 'Photoshop'
    Gimp: 'GIMP'
    Krita: 'Krita'
    Pixaki: 'Pixaki'
    Dottable: 'Dottable'
    Pixly: 'Pixly'
    PixelArtStudio: 'Pixel Art Studio'
    
  onCreated: ->
    super

    sectionLocations =
      challenge: new PAA.Practice.Challenges.Drawing
      project: new PAA.Practice.Project.Workbench
    
    for sectionThingName, sectionLocation of sectionLocations
      do (sectionThingName, sectionLocation) =>
        groups = new ComputedField =>
          # Get groups from the section location. Note: we expect things to be instances, so
          # they have to be added as instances in the workbench scene, and not as classes.
          currentSituation = new LOI.Adventure.Situation
            location: sectionLocation

          sectionThings = currentSituation.things()

          for sectionThing, index in sectionThings
            do (sectionThing, index) =>
              assets = new ComputedField =>
                for asset, assetIndex in sectionThing.assets()
                  do (asset, assetIndex) =>
                    index: assetIndex
                    asset: asset
                    scale: => @_assetScale asset

              index: index
              name: => sectionThing.fullName()
              noAssetsInstructions: => sectionThing.noAssetsInstructions?()
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
      sections.push @challengesSection if @challengesSection.groups().length
      sections.push @artworksSection if @artworksSection.groups().length

      # If the active section is not present anymore, close the section.
      if @activeSection and not @activeSection() in sections
        @activeSection null
        @activeGroup null
        @hoveredAsset null

      # Update section indices.
      section.index = index for section, index in sections

      sections

    @settingsSection =
      nameKey: @constructor.Sections.Settings

    @autorun (computation) =>
      sections = @sections()
      @settingsSection.index = sections.length

    @activeSection = new ReactiveField null, (a, b) => a is b
    @activeGroup = new ReactiveField null, (a, b) => a is b

    # Clear stale active groups.
    @autorun (computation) =>
      return unless activeSection = @activeSection()
      return unless activeGroup = @activeGroup()
      newGroups = activeSection.groups()
      return if activeGroup in newGroups

      # See if we can find a group with the same name.
      name = activeGroup.name()
      sameNamedGroup = _.find newGroups, (group) => group.name() is name

      if sameNamedGroup
        # We found the same group so it must have just re-created.
        @activeGroup sameNamedGroup
        return

      # Seems like the active group is not valid anymore.
      @activeGroup null

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
    @displayedAsset = new ReactiveField null, (a, b) => a is b

    @autorun (computation) =>
      return unless activeAsset = @activeAsset()
      @displayedAsset activeAsset

    # Subscribe to character's projects.
    PAA.Practice.Project.forCharacterId.subscribe @, LOI.characterId()

    # Prepare settings.
    editors = new PAA.PixelBoy.Apps.Drawing.Editors
    
    currentEditorsSituation = new LOI.Adventure.Situation
      location: editors

    @_editors = {}

    @editors = new ComputedField =>
      editorClasses = currentEditorsSituation.things()
      editors = []

      for editorClass in editorClasses
        @_editors[editorClass.id()] ?= new editorClass
        editors.push @_editors[editorClass.id()]

      if editors.length
        editors.unshift
          id: => null
          fullName: 'None'

      editors
      
    @externalSoftware = ({value, fullName} for value, fullName of @constructor.ExternalSoftware)

    @externalSoftware.unshift
      value: null
      fullName: 'None'
  
    @externalSoftware.push
      value: 'other'
      fullName: 'Other software'

  onDestroyed: ->
    super
    
    editor.destroy?() for editor in @_editors
