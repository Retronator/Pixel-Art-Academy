AE = Artificial.Everywhere
AM = Artificial.Mummification
LOI = LandsOfIllusions
RA = Retronator.Accounts

class LOI.Assets.Asset extends LOI.Assets.Asset
  @id: -> 'LandsOfIllusions.Assets.Asset'
  # name: text identifier for the asset including the path
  # creationTime: time when the document was created
  # lastEditTime: time when last history item was added
  # authors: array of characters that are allowed to edit this asset or null if this is a system asset
  #   _id
  #   avatar
  #     fullName
  # editor: custom object with settings that do not get sent to normal users
  @Meta
    abstract: true
    fields: =>
      authors: [Document.ReferenceField LOI.Character, ['avatar.fullName']]

  # Set the class name of the asset by which we can reach the class by querying LOI.Assets. We can't simply use the
  # name parameter, because in production the name field has a minimized value. Must be set in child class.
  @className: null
  
  @documentUrl: -> "/landsofillusions/assets/#{_.toLower @className}.json"
  @imageUrl: -> "/landsofillusions/assets/#{_.toLower @className}.png"
  @cacheUrl: -> "/landsofillusions/assets/#{_.toLower @className}/cache.json"
  
  # Methods
  
  @insert: @method 'insert'
  @insertVersioned: @method 'insertVersioned'
  @update: @method 'update'
  @remove: @method 'remove'
  @duplicate: @method 'duplicate'
  @exists: @method 'exists'
  
  @executeAction: @method 'executeAction'
  @undo: @method 'undo'
  @redo: @method 'redo'
  @clearHistory: @method 'clearHistory'

  @getData: @method 'getData'

  # Subscriptions

  @forId: @subscription 'forId'
  @forIdVersioned: @subscription 'forIdVersioned'
  @forName: @subscription 'forName'
  @forPath: @subscription 'forPath'
  @all: @subscription 'all'

  @executePartialAction: (assetClassName, assetId, action) ->
    assetClass = LOI.Assets.Asset._requireAssetClass assetClassName
    asset = LOI.Assets.Asset._requireAsset assetId, assetClass
    
    AM.Document.Versioning.executePartialAction asset, action

  # Helper methods

  @_requireAssetClass = (assetClassName) ->
    assetClass = LOI.Assets[assetClassName]
    throw new AE.ArgumentException "Asset class name doesn't exist." unless assetClass

    assetClass

  @_requireAsset = (assetId, assetClass) ->
    if Meteor.isClient and assetClass.versionedDocuments
      asset = assetClass.versionedDocuments.getDocumentForId assetId
      
    else
      asset = assetClass.documents.findOne assetId

    throw new AE.ArgumentException "Asset does not exist." unless asset

    asset

  @_authorizeAssetAction: (asset) ->
    # See if user controls one of the author characters.
    authors = asset.authors or []
  
    for author in authors
      try
        LOI.Authorize.characterAction author._id
  
        # If error was not thrown, this author is controlled by the user and action is approved.
        return
  
      catch
        # This author is not controlled by the user.
        continue
  
    # No author was authorized. Only allow editing if the user is an admin.
    RA.authorizeAdmin()

  _applyOperation: (forward, backward) ->
    # Update last edit time.
    forward.$set ?= {}
    forward.$set.lastEditTime = new Date()

    if @lastEditTime
      backward.$set ?= {}
      backward.$set.lastEditTime = @lastEditTime

    else
      backward.$unset ?= {}
      backward.$unset.lastEditTime = true

    # Create the update modifier.
    modifier = _.cloneDeep forward

    # Add history step.
    historyPosition = @historyPosition or 0

    # Allow up to 2,000 history steps.
    throw new AE.ArgumentOutOfRangeException "Up to 2,000 history steps are allowed." if historyPosition > 2000

    modifier.$push ?= {}
    modifier.$push.history =
      $position: historyPosition
      $each: [EJSON.stringify {forward, backward}]
      $slice: historyPosition + 1

    modifier.$set ?= {}
    modifier.$set.historyPosition = historyPosition + 1

    @constructor.documents.update @_id, modifier

  _getLastHistory: ->
    return unless @historyPosition
    return unless @history?[@historyPosition - 1]

    EJSON.parse @history[@historyPosition - 1]

  _applyOperationAndConnectHistory: (forward, backward) ->
    # Mark the forward action of last history to be connected.
    lastHistory = @_getLastHistory()
    lastHistory.forward.connected = true

    @constructor.documents.update @_id,
      $set:
        "history.#{@historyPosition - 1}": EJSON.stringify lastHistory

    # Mark the backward action of the history to be connected.
    backward.connected = true

    @_applyOperation arguments...

  _applyOperationAndCombineHistory: (forward, combinedForward, combinedBackward) ->
    # Update last edit time.
    combinedForward.$set.lastEditTime = new Date()

    # Create the update modifier.
    modifier = _.cloneDeep forward

    # Replace history step.
    historyPosition = @historyPosition - 1

    modifier.$push ?= {}
    modifier.$push.history =
      $position: historyPosition
      $each: [
        EJSON.stringify
          forward: combinedForward
          backward: combinedBackward
      ]
      $slice: historyPosition + 1

    modifier.$set ?= {}
    modifier.$set.historyPosition = historyPosition + 1

    @constructor.documents.update @_id, modifier
