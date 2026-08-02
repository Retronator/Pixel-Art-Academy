AE = Artificial.Everywhere
PAA = PixelArtAcademy

class PAA.PixelPad.Apps.Drawing.Portfolio.GroupsProvider
  constructor: (thingsProvider, level) ->
    @_assetInstancesByThingId = {}
    @_assetsByThingId = {}
    
    # Note: This is the main place to control reactivity and only recreate groups when things or folders change.
    @_things = new ReactiveField [], _.arraysHaveSameValues
    @_folderIds = new ReactiveField [], _.arraysHaveSameValues
    
    @_folderInformationProviderByFolderId = {}
    @_folderThingsByFolderId = {}
    @_groupsProvidersByFolderId = {}
    
    @_providerAutorun = Tracker.autorun (computation) =>
      things = _.clone thingsProvider()
      folders = _.remove things, (sectionThing) => sectionThing instanceof PAA.PixelPad.Apps.Drawing.Portfolio.Folder
      
      @_things things
      
      folderInstancesById = {}
      
      for folder in folders
        folderInstancesById[folder.id()] ?= []
        folderInstancesById[folder.id()].push folder
        
      @_folderIds _.keys folderInstancesById
      
      for folderId, folderInstances of folderInstancesById
        # We take the first instance to act as the provider of the information for this group.
        @_folderInformationProviderByFolderId[folderId] = folderInstances[0]
        
        # Note: We don't want to use _.arraysHaveSameValues since folder
        # things can change without a change in folder instance.
        @_folderThingsByFolderId[folderId] ?= new ReactiveField []
        @_folderThingsByFolderId[folderId] _.flatten (folderInstance.things for folderInstance in folderInstances)
    
    @groups = new AE.LiveComputedField =>
      groups = []

      # Turn things into groups.
      groupIndex = 0
      
      for thing in @_things()
        do (thing) =>
          thingId = thing.id()
          
          @_assetInstancesByThingId[thingId] ?= Tracker.nonreactive =>
            field = new AE.LiveComputedField =>
              thing.assets()
            ,
              _.arraysHaveSameValues
            
            # Add the captured thing for assertion purposes.
            field.thing = thing
            field

          # Double check that instances are stable until destruction.
          unless @_assetInstancesByThingId[thingId].thing is thing
            console.warn "Portfolio groups provider received a different thing instance with the same ID.", thingId, thingInstance, thing
          
          @_assetsByThingId[thingId] ?= Tracker.nonreactive => new AE.LiveComputedField =>
            for asset, assetIndex in @_assetInstancesByThingId[thingId]() when asset.urlParameter()
              PAA.PixelPad.Apps.Drawing.Portfolio.AssetData.getForAsset asset, assetIndex
          ,
            _.arraysHaveSameValues
          
          groups.push
            level: level
            thing: thing
            index: groupIndex
            name: => thing.fullName()
            noAssetsInstructions: => thing.noAssetsInstructions?()
            assets: @_assetsByThingId[thingId]
            content: => thing.content?()
          
        groupIndex++
      
      # Turn folders into groups, merged by folder ID.
      for folderId in @_folderIds()
        folder = @_folderInformationProviderByFolderId[folderId]
        @_groupsProvidersByFolderId[folderId] ?= Tracker.nonreactive => new @constructor @_folderThingsByFolderId[folderId], level + 1

        do (folder) =>
          groups.push
            level: level
            index: groupIndex
            name: => folder.displayName()
            groupsProvider: @_groupsProvidersByFolderId[folderId]
            groups: @_groupsProvidersByFolderId[folderId].groups
      
        groupIndex++
      
      groups

  destroy: ->
    @_providerAutorun.stop()
    @groups.stop()
    
    assetInstances.stop() for thingId, assetInstances of @_assetInstancesByThingId
    assets.stop() for thingId, assets of @_assetsByThingId

    @_folderInformationProviderByFolderId = null
    groupsProvider.destroy() for folderId, groupsProvider of @_groupsProvidersByFolderId
