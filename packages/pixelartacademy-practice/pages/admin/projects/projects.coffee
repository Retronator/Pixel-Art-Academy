AB = Artificial.Base
AM = Artificial.Mirage
PAA = PixelArtAcademy
Persistence = Artificial.Mummification.Document.Persistence

class PAA.Practice.Pages.Admin.Projects extends AM.Component
  @id: -> 'PixelArtAcademy.Practice.Pages.Admin.Projects'
  @register @id()

  @insertPublicProject = new AB.Method name: "#{@id()}.insertPublicProject"
  
  onCreated: ->
    super arguments...
    
    PAA.Practice.Project.all.subscribe @
    
    unless Persistence.hasSyncedStorage Persistence.SyncedStorages.LocalStorage.id()
      Persistence.registerSyncedStorage new Persistence.SyncedStorages.LocalStorage storageKey: "Retronator"
    
  profiles: ->
    Persistence.Profile.documents.fetch()
    
  projects: ->
    PAA.Practice.Project.documents.fetch()
    
  events: ->
    super(arguments...).concat
      'click .load-profile-button': @onClickLoadProfileButton
      'click .create-public-copy-button': @onClickCreatePublicCopyButton
  
  onClickLoadProfileButton: (event) ->
    profile = @currentData()
    
    Persistence.loadProfile profile.profileId
    
  onClickCreatePublicCopyButton: (event) ->
    project = _.cloneDeep @currentData()
    projectName = @$('.public-project-name').val()
    
    assets = {}
    
    project._id = Random.id()
    project.name = projectName
    project.assets = for asset in project.assets
      newAsset = _.pick asset, ['id', 'type']
      if asset.bitmapId
        bitmap = LOI.Assets.Bitmap.documents.findOne asset.bitmapId
        
        bitmap.name = "#{projectName}/#{_.kebabCase asset.id}"
        bitmap._id = Random.id()
        delete bitmap.profileId
        bitmap.historyPosition = 0
        bitmap.history = []

        assets[bitmap._id] = bitmap
        
        newAsset.bitmapId = bitmap._id
        
      newAsset
    
    @constructor.insertPublicProject project, assets
