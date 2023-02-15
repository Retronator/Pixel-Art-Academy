globals = @

INSTANCES = parseInt(process.env.PEERDB_INSTANCES ? 1)
INSTANCE = parseInt(process.env.PEERDB_INSTANCE ? 0)

throw new Error "Invalid number of instances: #{ INSTANCES }" unless 0 <= INSTANCES <= share.UNMISTAKABLE_CHARS.length
throw new Error "Invalid instance index: #{ INSTANCE }" unless (INSTANCES is 0 and INSTANCE is 0) or 0 <= INSTANCE < INSTANCES

MESSAGES_TTL = 60 # seconds

# We augment the cursor so that it matches our extra method in documents manager.
MeteorCursor = Object.getPrototypeOf(MongoInternals.defaultRemoteCollectionDriver().mongo.find()).constructor
MeteorCursor::exists = ->
  # You can only observe a tailable cursor.
  throw new Error "Cannot call exists on a tailable cursor" if @_cursorDescription.options.tailable

  unless @_synchronousCursorForExists
    # A special cursor with limit forced to 1 and fields to only _id.
    cursorDescription = _.clone @_cursorDescription
    cursorDescription.options = _.clone cursorDescription.options
    cursorDescription.options.limit = 1
    cursorDescription.options.fields =
      _id: 1
    @_synchronousCursorForExists = @_mongo._createSynchronousCursor cursorDescription,
      selfForIteration: @
      useTransform: false

  @_synchronousCursorForExists._rewind()
  !!@_synchronousCursorForExists._nextObject()

# Fields:
#   created
#   type
#   data
# We use a lower case collection name to signal it is a system collection
globals.Document.Messages = new Mongo.Collection 'peerdb.messages'

# Auto-expire messages after MESSAGES_TTL seconds
globals.Document.Messages._ensureIndex
  created: 1
,
  expireAfterSeconds: MESSAGES_TTL

class globals.Document extends globals.Document
  @updateAll: ->
    sendMessage 'updateAll'

sendMessage = (type, data) ->
  globals.Document.Messages.insert
    created: new Date()
    type: type
    data: data

share.setupMessages = ->
  initializing = true

  globals.Document.Messages.find({}).observeChanges
    added: (id, fields) ->
      return if initializing

      switch fields.type
        when 'updateAll'
          globals.Document._updateAll()
        else
          Log.error "Unknown message type '#{ fields.type }': " + util.inspect _.extend({}, {_id: id}, fields), false, null

  initializing = false

globals.Document.instanceDisabled = INSTANCES is 0
globals.Document.instances = INSTANCES
globals.Document.instance = INSTANCE

Document = globals.Document

assert globals.Document._ReferenceField.prototype instanceof globals.Document._TargetedFieldsObservingField
assert globals.Document._GeneratedField.prototype instanceof globals.Document._TargetedFieldsObservingField
