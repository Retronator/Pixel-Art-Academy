AE = Artificial.Everywhere
PAA = PixelArtAcademy

class PAA.PixelPad.Apps.Drawing.Portfolio.GroupsProvider
  constructor: (thingsProvider, level) ->
    @_assetsProviderDataByThingId = {}
    @_assetsProvidersDataByThingId = {}
    @_activeAssetsProviderDataByThingId = {}
    
    # Note: This is the main place to control reactivity and only recreate groups when things or folders change.
    @_things = new ReactiveField [], _.arraysHaveSameValues
    @_groupFolderIds = new ReactiveField [], _.arraysHaveSameValues
    
    @_groupFolderInformationProviderByGroupFolderId = {}
    @_groupFolderThingsByFolderId = {}
    @_groupsProvidersByGroupFolderId = {}
    
    @_providerAutorun = Tracker.autorun (computation) =>
      things = _.clone thingsProvider()
      groupFolders = _.remove things, (sectionThing) => sectionThing instanceof PAA.PixelPad.Apps.Drawing.Portfolio.GroupFolder
      
      @_things things
      
      groupFolderInstancesById = {}
      
      for groupFolder in groupFolders
        groupFolderInstancesById[groupFolder.id()] ?= []
        groupFolderInstancesById[groupFolder.id()].push groupFolder
        
      @_groupFolderIds _.keys groupFolderInstancesById
      
      for groupFolderId, groupFolderInstances of groupFolderInstancesById
        # We take the first instance to act as the provider of the information for this group.
        @_groupFolderInformationProviderByGroupFolderId[groupFolderId] = groupFolderInstances[0]
        
        # Note: We don't want to use _.arraysHaveSameValues since group
        # folder things can change without a change in folder instance.
        @_groupFolderThingsByFolderId[groupFolderId] ?= new ReactiveField []
        @_groupFolderThingsByFolderId[groupFolderId] _.flatten (folderInstance.things for folderInstance in groupFolderInstances)
    
    @groups = new AE.LiveComputedField =>
      groups = []

      # Turn things into groups.
      groupIndex = 0
      
      for thing in @_things()
        do (thing) =>
          thingId = thing.id()
          
          @_assetsProviderDataByThingId[thingId] ?= Tracker.nonreactive => PAA.PixelPad.Apps.Drawing.Portfolio.AssetsProviderData.getForAssetsProvider thing, thing, 0
          
          # Double check that assets provider source is stable until destruction.
          unless @_assetsProviderDataByThingId[thingId].thing is thing
            console.warn "Portfolio groups provider received a different thing instance with the same ID.", thingId, @_assetsProviderDataByThingId[thingId], thing
          
          @_assetsProvidersDataByThingId[thingId] ?= Tracker.nonreactive => new AE.LiveComputedField =>
            return unless assetsProviders = thing.assetsProviders()
            
            for assetsProvider, assetsProviderIndex in assetsProviders
              PAA.PixelPad.Apps.Drawing.Portfolio.AssetsProviderData.getForAssetsProvider assetsProvider, thing, assetsProviderIndex
          ,
            _.arraysHaveSameValues
          
          @_activeAssetsProviderDataByThingId[thingId] ?= Tracker.nonreactive => new AE.LiveComputedField =>
            return unless assetsProvider = thing.activeAssetsProvider()
            
            PAA.PixelPad.Apps.Drawing.Portfolio.AssetsProviderData.getForAssetsProvider assetsProvider, thing, 0
          
          groups.push
            level: level
            thing: thing
            index: groupIndex
            name: => thing.fullName()
            assets: @_assetsProviderDataByThingId[thingId].assets
            assetsProviders: @_assetsProvidersDataByThingId[thingId]
            activeAssetsProvider: @_activeAssetsProviderDataByThingId[thingId]
          
        groupIndex++
      
      # Turn folders into groups, merged by folder ID.
      for folderId in @_groupFolderIds()
        groupFolder = @_groupFolderInformationProviderByGroupFolderId[folderId]
        @_groupsProvidersByGroupFolderId[folderId] ?= Tracker.nonreactive => new @constructor @_groupFolderThingsByFolderId[folderId], level + 1

        do (groupFolder) =>
          groups.push
            level: level
            index: groupIndex
            name: => groupFolder.displayName()
            groupsProvider: @_groupsProvidersByGroupFolderId[folderId]
            groups: @_groupsProvidersByGroupFolderId[folderId].groups
      
        groupIndex++
      
      groups

  destroy: ->
    @_providerAutorun.stop()
    @groups.stop()
    
    @_groupFolderInformationProviderByGroupFolderId = null

    groupsProvider.destroy() for folderId, groupsProvider of @_groupsProvidersByGroupFolderId
