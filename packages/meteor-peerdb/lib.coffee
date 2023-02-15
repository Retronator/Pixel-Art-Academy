import util from 'util'

globals = @

RESERVED_FIELDS = ['document', 'parent', 'schema', 'migrations']
INVALID_TARGET = "Invalid target document"
MAX_RETRIES = 1000

# From Meteor's random/random.js
share.UNMISTAKABLE_CHARS = '23456789ABCDEFGHJKLMNPQRSTWXYZabcdefghijkmnopqrstuvwxyz'

# TODO: Support also other types of _id generation (like ObjectID)
# TODO: We could do also a hash of an ID and then split, this would also prevent any DOS attacks by forcing IDs of a particular form
PREFIX = share.UNMISTAKABLE_CHARS.split ''

class codeMinimizedTest

@CODE_MINIMIZED = codeMinimizedTest.name and codeMinimizedTest.name isnt 'codeMinimizedTest'

isPlainObject = (obj) ->
  if not _.isObject(obj) or _.isArray(obj) or _.isFunction(obj)
    return false

  if obj.constructor isnt Object
    return false

  return true

deepExtend = (obj, args...) ->
  _.each args, (source) ->
    _.each source, (value, key) ->
      if obj[key] and value and isPlainObject(obj[key]) and isPlainObject(value)
        obj[key] = deepExtend obj[key], value
      else
        obj[key] = value
  obj

setPath = (object, path, value) ->
  outputObject = object

  segments = path.split '.'
  for segment, i in segments
    if _.isObject object
      if i is segments.length - 1
        object[segment] = value
        break
      else if segment not of object
        object[segment] = {}
      object = object[segment]
    else
      throw new Error "Path '#{path}' crosses a non-object."

  outputObject

removeUndefined = (obj) ->
  assert isPlainObject obj

  res = {}
  for key, value of obj
    if _.isUndefined value
      continue
    else if isPlainObject value
      res[key] = removeUndefined value
    else
      res[key] = value
  res

startsWith = (string, start) ->
  string.lastIndexOf(start, 0) is 0

removePrefix = (string, prefix) ->
  string.substring prefix.length

getCollection = (name, document, replaceParent) ->
  transform = (doc) -> new document doc

  if _.isString(name)
    if Document._collections[name]
      methodHandlers = Document._collections[name]._connection.method_handlers or Document._collections[name]._connection._methodHandlers
      for method of methodHandlers
        if startsWith method, Document._collections[name]._prefix
          if replaceParent
            delete methodHandlers[method]
          else
            throw new Error "Reuse of a collection without replaceParent set"
      if Document._collections[name]._connection.registerStore
        if replaceParent
          delete Document._collections[name]._connection._stores[name]
        else
          throw new Error "Reuse of a collection without replaceParent set"
    collection = new Mongo.Collection name, transform: transform
    Document._collections[name] = collection
  else if name is null
    collection = new Mongo.Collection name, transform: transform
  else
    collection = name
    if collection._peerdb and not replaceParent
      throw new Error "Reuse of a collection without replaceParent set"
    collection._transform = LocalCollection.wrapTransform transform
    collection._peerdb = true

  collection

fieldsToProjection = (fields) ->
  projection =
    _id: 1 # In the case we want only id, that is, detect deletions
  if _.isArray fields
    for field in fields
      if _.isString field
        projection[field] = 1
      else
        _.extend projection, field
  else if _.isObject fields
    _.extend projection, fields
  else
    throw new Error "Invalid fields: #{ fields }"
  projection

extractValue = (obj, path) ->
  while path.length
    obj = obj[path[0]]
    path = path[1..]
  obj

isModifiableCollection = (collection) ->
  if Meteor.isClient
    collection._connection is null
  else
    collection._connection in [null, Meteor.server]

isServerCollection = (collection) ->
  Meteor.isServer and collection._connection is Meteor.server

# We augment the cursor so that it matches our extra method in documents manager.
LocalCollection.Cursor::exists = ->
  # We just have to limit the query temporary. For limited and unsorted queries
  # there is already a fast path in _getRawObjects. Same for single ID queries.
  # We cannot do much if it is a sorted query (Minimongo does not have indexes).
  # The only combination we could optimize further is an unsorted query with skip
  # and instead of generating a set of all documents and then doing a slice, we
  # could traverse at most skip number of documents.
  originalLimit = @limit
  @limit = 1
  try
    return !!@count()
  finally
    @limit = originalLimit

class globals.Document
  # TODO: When we will require all fields to be specified and have validator support to validate new objects, we can also run validation here and check all data, reference fields and others
  @objectify: (parent, ancestorArray, obj, fields) ->
    throw new Error "Document does not match schema, not a plain object" unless isPlainObject obj

    for name, field of fields
      # Not all fields are necessary provided
      continue unless obj[name]

      path = if parent then "#{ parent }.#{ name }" else name

      if field instanceof globals.Document._ReferenceField
        throw new Error "Document does not match schema, sourcePath does not match: #{ field.sourcePath } vs. #{ path }" if field.sourcePath isnt path

        if field.isArray
          throw new Error "Document does not match schema, not an array" unless _.isArray obj[name]
          obj[name] = _.map obj[name], (o) => new field.targetDocument o
        else
          throw new Error "Document does not match schema, ancestorArray does not match: #{ field.ancestorArray } vs. #{ ancestorArray }" if field.ancestorArray isnt ancestorArray
          throw new Error "Document does not match schema, not a plain object" unless isPlainObject obj[name]
          obj[name] = new field.targetDocument obj[name]

      else if isPlainObject field
        if _.isArray obj[name]
          throw new Error "Document does not match schema, an unexpected array" unless _.some field, (f) => f.ancestorArray is path
          throw new Error "Document does not match schema, nested arrays are not supported" if ancestorArray
          obj[name] = _.map obj[name], (o) => @objectify path, path, o, field
        else
          throw new Error "Document does not match schema, expected an array" if _.some field, (f) => f.ancestorArray is path
          obj[name] = @objectify path, ancestorArray, obj[name], field

    obj

  constructor: (doc) ->
    _.extend @, @constructor.objectify '', null, (doc or {}), (@constructor?.Meta?.fields or {})

  @_setDelayedCheck: ->
    return unless globals.Document._delayed.length

    @_clearDelayedCheck()

    globals.Document._delayedCheckTimeout = Meteor.setTimeout ->
      if globals.Document._delayed.length
        delayed = [] # Display friendly list of delayed documents
        for document in globals.Document._delayed
          delayed.push "#{ document.Meta._name } from #{ document.Meta._location }"
        Log.error "Not all delayed document definitions were successfully retried:\n#{ delayed.join('\n') }"
    , 1000 # ms

  @_clearDelayedCheck: ->
    Meteor.clearTimeout globals.Document._delayedCheckTimeout if globals.Document._delayedCheckTimeout

  @_processTriggers: (triggers) ->
    assert triggers
    assert isPlainObject triggers

    for name, trigger of triggers
      throw new Error "Trigger names cannot contain '.' (for #{ name } trigger from #{ @Meta._location })" if name.indexOf('.') isnt -1

      if trigger instanceof globals.Document._Trigger
        trigger.contributeToClass @, name
      else
        throw new Error "Invalid value for trigger (for #{ name } trigger from #{ @Meta._location })"

    triggers

  @_processFieldsOrGenerators: (isGenerator, fields, parent, ancestorArray) ->
    assert fields
    assert isPlainObject fields

    ancestorArray = ancestorArray or null

    if isGenerator
      resourceName = "Generator"
      lowerCaseResourceName = "generator"
    else
      resourceName = "Field"
      lowerCaseResourceName = "field"

    res = {}
    for name, field of fields
      throw new Error "#{ resourceName } names cannot contain '.' (for #{ name } from #{ @Meta._location })" if name.indexOf('.') isnt -1

      path = if parent then "#{ parent }.#{ name }" else name
      array = ancestorArray

      if _.isArray field
        throw new Error "Array #{ lowerCaseResourceName } has to contain exactly one element, not #{ field.length } (for #{ path } from #{ @Meta._location })" if field.length isnt 1
        field = field[0]

        if array
          # TODO: Support nested arrays
          # See: https://jira.mongodb.org/browse/SERVER-831
          throw new Error "#{ resourceName } cannot be in a nested array (for #{ path } from #{ @Meta._location })"

        array = path

      if field instanceof globals.Document._Field
        throw new Error "Not a generated field among generators (for #{ name } from #{ @Meta._location })" if isGenerator and not field instanceof globals.Document._GeneratedField

        field.contributeToClass @, path, array
        res[name] = field
      else if _.isObject field
        res[name] = @_processFieldsOrGenerators isGenerator, field, path, array
      else
        throw new Error "Invalid value for #{ lowerCaseResourceName } (for #{ path } from #{ @Meta._location })"

    res

  @_processFields: (fields, parent, ancestorArray) ->
    @_processFieldsOrGenerators false, fields, parent, ancestorArray

  @_processGenerators: (generators, parent, ancestorArray) ->
    @_processFieldsOrGenerators true, generators, parent, ancestorArray

  @_fieldsUseDocument: (fields, document) ->
    assert fields
    assert isPlainObject fields

    for name, field of fields
      if field instanceof globals.Document._TargetedFieldsObservingField
        return true if field.sourceDocument is document
        return true if field.targetDocument is document
      else if field instanceof globals.Document._Field
        return true if field.sourceDocument is document
      else
        assert isPlainObject field
        return true if @_fieldsUseDocument field, document

    false

  @_retryAllUsing: (document) ->
    documents = globals.Document.list
    globals.Document.list = []

    for doc in documents
      if @_fieldsUseDocument doc.Meta.fields, document
        delete doc.Meta._replaced
        delete doc.Meta._listIndex
        @_addDelayed doc
      else if @_fieldsUseDocument doc.Meta.generators, document
        delete doc.Meta._replaced
        delete doc.Meta._listIndex
        @_addDelayed doc
      else
        globals.Document.list.push doc
        doc.Meta._listIndex = globals.Document.list.length - 1

  @_retryDelayed: (throwErrors) ->
    @_clearDelayedCheck()

    # We store the delayed list away, so that we can iterate over it
    delayed = globals.Document._delayed
    # And set it back to the empty list, we will add to it again as necessary
    globals.Document._delayed = []

    for document in delayed
      delete document.Meta._delayIndex

    processedCount = 0

    for document in delayed
      assert not document.Meta._listIndex?

      if document.Meta._replaced
        continue

      try
        triggers = document.Meta._triggers.call document, {}
        if triggers and isPlainObject triggers
          document.Meta.triggers = document._processTriggers triggers
      catch e
        if not throwErrors and (e.message is INVALID_TARGET or e instanceof ReferenceError)
          @_addDelayed document
          continue
        else
          throw new Error "Invalid triggers (from #{ document.Meta._location }): #{ e.stringOf?() or e }\n---#{ if e.stack then "#{ e.stack }\n---" else '' }"

      throw new Error "No triggers returned (from #{ document.Meta._location })" unless triggers
      throw new Error "Returned triggers should be a plain object (from #{ document.Meta._location })" unless isPlainObject triggers

      try
        generators = document.Meta._generators.call document, {}
        if generators and isPlainObject generators
          document.Meta.generators = document._processGenerators generators
      catch e
        if not throwErrors and (e.message is INVALID_TARGET or e instanceof ReferenceError)
          @_addDelayed document
          continue
        else
          throw new Error "Invalid generators (from #{ document.Meta._location }): #{ e.stringOf?() or e }\n---#{ if e.stack then "#{ e.stack }\n---" else '' }"

      throw new Error "No generators returned (from #{ document.Meta._location })" unless generators
      throw new Error "Returned generators should be a plain object (from #{ document.Meta._location })" unless isPlainObject generators

      try
        fields = document.Meta._fields.call document, {}
        if fields and isPlainObject fields
          # We run _processFields first, so that _reverseFields for this document is populated as well
          document._processFields fields

          reverseFields = {}
          for reverse in document.Meta._reverseFields
            setPath reverseFields, reverse.reverseName, [globals.Document.ReferenceField reverse.sourceDocument, reverse.reverseFields]

          # And now we run _processFields for real on all fields
          document.Meta.fields = document._processFields deepExtend fields, reverseFields
      catch e
        if not throwErrors and (e.message is INVALID_TARGET or e instanceof ReferenceError)
          @_addDelayed document
          continue
        else
          throw new Error "Invalid fields (from #{ document.Meta._location }): #{ e.stringOf?() or e }\n---#{ if e.stack then "#{ e.stack }\n---" else '' }"

      throw new Error "No fields returned (from #{ document.Meta._location })" unless fields
      throw new Error "Returned fields should be a plain object (from #{ document.Meta._location })" unless isPlainObject fields

      # Local documents cannot have replaceParent set.
      if document.Meta.replaceParent and not document.Meta.parent?._replaced
        throw new Error "Replace parent set, but no parent known (from #{ document.Meta._location })" unless document.Meta.parent

        document.Meta.parent._replaced = true

        if document.Meta.parent._listIndex?
          globals.Document.list.splice document.Meta.parent._listIndex, 1
          delete document.Meta.parent._listIndex

          # Renumber documents
          for doc, i in globals.Document.list
            doc.Meta._listIndex = i

        else if document.Meta.parent._delayIndex?
          globals.Document._delayed.splice document.Meta.parent._delayIndex, 1
          delete document.Meta.parent._delayIndex

          # Renumber documents
          for doc, i in globals.Document._delayed
            doc.Meta._delayIndex = i

        @_retryAllUsing document.Meta.parent.document

      unless document.Meta.local
        globals.Document.list.push document
        document.Meta._listIndex = globals.Document.list.length - 1

      delete document.Meta._delayIndex

      assert not document.Meta._replaced

      unless document.Meta.local
        # If a document is defined after PeerDB has started we have to setup observers for it.
        globals.Document._setupObservers() if globals.Document.hasStarted()

      processedCount++

    @_setDelayedCheck()

    processedCount

  @_addDelayed: (document) ->
    @_clearDelayedCheck()

    assert not document.Meta._replaced
    assert not document.Meta._listIndex?

    globals.Document._delayed.push document
    document.Meta._delayIndex = globals.Document._delayed.length - 1

    @_setDelayedCheck()

  @_validateTriggers: (document) ->
    for name, trigger of document.Meta.triggers
      if trigger instanceof globals.Document._Trigger
        trigger.validate()
      else
        throw new Error "Invalid trigger (for #{ name } trigger from #{ document.Meta._location })"

  @_validateFieldsOrGenerators: (obj) ->
    for name, field of obj
      if field instanceof globals.Document._Field
        field.validate()
      else
        @_validateFieldsOrGenerators field

  @Meta: (meta) ->
    for field in RESERVED_FIELDS or startsWith field, '_'
      throw "Reserved meta field name: #{ field }" if field of meta

    if meta.abstract
      throw new Error "name cannot be set in abstract document" if meta.name
      throw new Error "replaceParent cannot be set in abstract document" if meta.replaceParent
      throw new Error "Abstract document with a parent" if @Meta._name
    else
      throw new Error "Missing document name" unless meta.name
      throw new Error "replaceParent set without a parent" if meta.replaceParent and not @Meta._name

    if meta.local
      throw new Error "replaceParent cannot be set when local is set" if meta.replaceParent

    name = meta.name
    currentTriggers = meta.triggers or (ts) -> ts
    currentGenerators = meta.generators or (gs) -> gs
    currentFields = meta.fields or (fs) -> fs
    meta = _.omit meta, 'name', 'triggers', 'generators', 'fields'

    parentMeta = @Meta

    if parentMeta._triggers
      triggers = (ts) ->
        newTs = parentMeta._triggers.call @, ts
        removeUndefined _.extend ts, newTs, currentTriggers.call @, newTs
    else
      triggers = currentTriggers

    meta._triggers = triggers # Triggers function

    if parentMeta._generators
      generators = (gs) ->
        newGs = parentMeta._generators.call @, gs
        removeUndefined deepExtend gs, newGs, currentGenerators.call @, newGs
    else
      generators = currentGenerators

    meta._generators = generators # Generators function

    if parentMeta._fields
      fields = (fs) ->
        newFs = parentMeta._fields.call @, fs
        removeUndefined deepExtend fs, newFs, currentFields.call @, newFs
    else
      fields = currentFields

    meta._fields = fields # Fields function

    if not meta.abstract
      meta._name = name # "name" is a reserved property name on functions in some environments (eg. node.js), so we use "_name"
      # For easier debugging and better error messages
      if CODE_MINIMIZED
        meta._location = '<code_minimized>'
      else
        if Meteor.isServer
          meta._location = Promise.await(StackTrace.getCaller())?.toString() or '<unknown>'
        else
          meta._location = '<unknown>'
          # We ignore potential errors and assign the location asynchronously.
          StackTrace.getCaller().then (caller) =>
            meta._location = caller?.toString() or '<unknown>'
      meta.document = @

      if meta.collection is null or meta.collection
        meta.collection = getCollection meta.collection, @, meta.replaceParent
      else if parentMeta.collection?._peerdb
        meta.collection = getCollection parentMeta.collection, @, meta.replaceParent
      else
        meta.collection = getCollection "#{ name }s", @, meta.replaceParent

      if @Meta._name
        meta.parent = parentMeta

      if not meta.replaceParent
        # If we are not replacing the parent, we override _reverseFields with an empty set
        # because we want reverse fields only on exact target document and not its children.
        meta._reverseFields = []
      else
        meta._reverseFields = _.clone parentMeta._reverseFields

      if not meta.replaceParent
        # If we are not replacing the parent, we create a new list of migrations
        meta.migrations = []

    clonedParentMeta = -> parentMeta.apply @, arguments
    filteredParentMeta = _.omit parentMeta, '_listIndex', '_delayIndex', '_replaced', '_observersSetup', 'parent', 'replaceParent', 'abstract', 'local'
    @Meta = _.extend clonedParentMeta, filteredParentMeta, meta

    if not meta.abstract
      assert @Meta._reverseFields

      @documents = new @_Manager @Meta

      @_addDelayed @
      @_retryDelayed()

  @list: []
  @_delayed: []
  @_delayedCheckTimeout: null
  @_collections: {}

  @validateAll: ->
    for document in globals.Document.list
      throw new Error "Missing fields (from #{ document.Meta._location })" unless document.Meta.fields
      @_validateTriggers document
      @_validateFieldsOrGenerators document.Meta.generators
      @_validateFieldsOrGenerators document.Meta.fields

  @defineAll: (dontThrowDelayedErrors) ->
    for i in [0..MAX_RETRIES]
      if i is MAX_RETRIES
        throw new Error "Possible infinite loop" unless dontThrowDelayedErrors
        break

      globals.Document._retryDelayed not dontThrowDelayedErrors

      break unless globals.Document._delayed.length

    globals.Document.validateAll()

    assert dontThrowDelayedErrors or globals.Document._delayed.length is 0

  prepared = false
  prepareList = []
  started = false
  startList = []

  @prepare: (f) ->
    if prepared
      f()
    else
      prepareList.push f

  @runPrepare: ->
    assert not prepared
    prepared = true

    prepare() for prepare in prepareList
    return

  @startup: (f) ->
    if started
      f()
    else
      startList.push f

  @runStartup: ->
    assert not started
    started = true

    start() for start in startList
    return

  @hasStarted: ->
    started

  # TODO: Should we add retry?
  @_observerCallback: (limitToPrefix, f) ->
    return (obj, args...) ->
      try
        if limitToPrefix
          # We call f only if the first character of id is in share.PREFIX. By that we allow each instance to
          # operate only on a subset of documents, allowing simple coordination while scaling.
          id = if _.isObject obj then obj._id else obj
          f obj, args... if id[0] in PREFIX
        else
          f obj, args...
      catch e
        Log.error "PeerDB exception: #{ e }: #{ util.inspect args, depth: 10 }"
        Log.error e.stack

  @_sourceFieldProcessDeleted: (field, id, ancestorSegments, pathSegments, value) ->
    if ancestorSegments.length
      assert ancestorSegments[0] is pathSegments[0]
      @_sourceFieldProcessDeleted field, id, ancestorSegments[1..], pathSegments[1..], value[ancestorSegments[0]]
    else
      value = [value] unless _.isArray value

      ids = (extractValue(v, pathSegments)._id for v in value when extractValue(v, pathSegments)?._id)

      assert field.reverseName

      query =
        _id:
          $nin: ids
      query["#{ field.reverseName }._id"] = id

      update = {}
      update[field.reverseName] =
        _id: id

      field.targetCollection.update query, {$pull: update}, multi: true

  @_sourceFieldUpdated: (isGenerator, id, name, value, field, originalValue) ->
    # TODO: Should we check if field still exists but just value is undefined, so that it is the same as null? Or can this happen only when removing the field?
    if _.isUndefined value
      if field and field.reverseName and isModifiableCollection field.targetCollection
        @_sourceFieldProcessDeleted field, id, [], name.split('.')[1..], originalValue
      return

    if isGenerator
      field = field or @Meta.generators[name]
    else
      field = field or @Meta.fields[name]

    # We should be subscribed only to those updates which are defined in @Meta.generators or @Meta.fields
    assert field

    originalValue = originalValue or value

    if field instanceof globals.Document._ObservingField
      if field.ancestorArray and name is field.ancestorArray
        unless _.isArray value
          Log.error "Document '#{ @Meta._name }' '#{ id }' field '#{ name }' was updated with a non-array value: #{ util.inspect value }"
          return
      else
        value = [value]

      for v in value
        field.updatedWithValue id, v

      if field.reverseName and isModifiableCollection field.targetCollection
        # In updatedWithValue we added possible new entry/ies to reverse fields, but here
        # we have also to remove those which were maybe removed from the value and are
        # not referencing anymore a document which got added the entry to its reverse
        # field in the past. So we make sure that only those documents which are still in
        # the value have the entry in their reverse fields by creating a query which pulls
        # the entry from all other.

        pathSegments = name.split('.')

        if field.ancestorArray
          ancestorSegments = field.ancestorArray.split('.')

          assert ancestorSegments[0] is pathSegments[0]

          @_sourceFieldProcessDeleted field, id, ancestorSegments[1..], pathSegments[1..], originalValue
        else
          @_sourceFieldProcessDeleted field, id, [], pathSegments[1..], originalValue

    else if field not instanceof globals.Document._Field
      value = [value] unless _.isArray value

      # A trick to get reverse fields correctly cleaned up when the last element is removed from the
      # array of reference fields which have a reverse field defined. If the array is empty, the loop
      # below would not run, so we change it to an array with an empty object, which runs the loop
      # for one iteration, but makes all values (v[n]) undefined, which means that the first condition
      # of this method is met, and if field has reverseName defined, then _sourceFieldProcessDeleted
      # is called, correctly cleaning up the reverse field.
      value = [{}] unless value.length

      # If value is an array but it should not be, we cannot do much else.
      # Same goes if the value does not match structurally fields.
      for v in value
        for n, f of field
          # TODO: Should we skip calling @_sourceFieldUpdated if we already called it with exactly the same parameters this run?
          @_sourceFieldUpdated isGenerator, id, "#{ name }.#{ n }", v[n], f, originalValue

  @_sourceUpdated: (isGenerator, id, fields) ->
    for name, value of fields
      @_sourceFieldUpdated isGenerator, id, name, value

  @_setupSourceObservers: (updateAll) ->
    for [fields, isGenerator] in [[@Meta.fields, false], [@Meta.generators, true]]
      do (fields, isGenerator) =>
        return if _.isEmpty fields

        indexes = []
        sourceFields = {}
        sourceFieldsLimitedToPrefix = {}

        # We use isModifiableCollection to optimize so that we do not even setup observers
        # for fields which deal with unmodifiable collections.
        sourceFieldsWalker = (obj) ->
          for name, field of obj
            if field instanceof globals.Document._ObservingField
              if field instanceof globals.Document._ReferenceField
                if field.reverseName
                  if isModifiableCollection(field.sourceCollection) or isModifiableCollection(field.targetCollection)
                    # Limit to PREFIX only when both collections are server side. Otherwise there is a collection
                    # which is local only to this instance and we want to process all documents for it. Alternatively,
                    # there is a collection through a connection, in which case we are conservative and also process
                    # all documents for it. We do not necessary know if connections are shared between instances.
                    if isServerCollection(field.sourceCollection) and isServerCollection(field.targetCollection)
                      sourceFieldsLimitedToPrefix[field.sourcePath] = 1
                    else
                      sourceFields[field.sourcePath] = 1

                    index = {}
                    index["#{ field.sourcePath }._id"] = 1
                    indexes.push index
                else
                  if isModifiableCollection field.sourceCollection
                    if isServerCollection field.sourceCollection
                      sourceFieldsLimitedToPrefix[field.sourcePath] = 1
                    else
                      sourceFields[field.sourcePath] = 1

                    index = {}
                    index["#{ field.sourcePath }._id"] = 1
                    indexes.push index
              else
                if isModifiableCollection field.sourceCollection
                  if isServerCollection field.sourceCollection
                    sourceFieldsLimitedToPrefix[field.sourcePath] = 1
                  else
                    sourceFields[field.sourcePath] = 1
            else if field not instanceof globals.Document._Field
              sourceFieldsWalker field

        sourceFieldsWalker fields

        unless updateAll
          for index in indexes
            @Meta.collection._ensureIndex index if Meteor.isServer and @Meta.collection._connection is Meteor.server

        # Source or target collections are modifiable collections.
        unless _.isEmpty sourceFields
          initializing = true

          observers =
            added: globals.Document._observerCallback false, (id, fields) =>
              @_sourceUpdated isGenerator, id, fields if updateAll or not initializing

          unless updateAll
            observers.changed = globals.Document._observerCallback false, (id, fields) =>
              @_sourceUpdated isGenerator, id, fields

          handle = @Meta.collection.find({}, fields: sourceFields).observeChanges observers

          initializing = false

          handle.stop() if updateAll

        # Source or target collections are modifiable collections.
        unless _.isEmpty sourceFieldsLimitedToPrefix
          initializingLimitedToPrefix = true

          observers =
            added: globals.Document._observerCallback true, (id, fields) =>
              @_sourceUpdated isGenerator, id, fields if updateAll or not initializingLimitedToPrefix

          unless updateAll
            observers.changed = globals.Document._observerCallback true, (id, fields) =>
              @_sourceUpdated isGenerator, id, fields

          handle = @Meta.collection.find({}, fields: sourceFieldsLimitedToPrefix).observeChanges observers

          initializingLimitedToPrefix = false

          handle.stop() if updateAll

  @_updateAll: ->
    # It is only reasonable to run anything if this instance
    # is not disabled. Otherwise we would still go over all
    # documents, just we would not process any.
    return if globals.Document.instanceDisabled

    Log.info "Updating all references..."
    @_setupObservers true
    Log.info "Done"

  @_setupObservers: (updateAll) ->
    setupTriggerObserves = (triggers) =>
      for name, trigger of triggers
        trigger._setupObservers()

    setupTargetObservers = (fields) =>
      for name, field of fields
        # There are no arrays anymore here, just objects (for subdocuments) or fields
        if field instanceof @_TargetedFieldsObservingField
          field._setupTargetObservers updateAll
        else if field not instanceof @_Field
          setupTargetObservers field

    for document in @list
      if updateAll
        # For fields we pass updateAll on.
        setupTargetObservers document.Meta.fields
        setupTargetObservers document.Meta.generators
        document._setupSourceObservers true

      else
        # For each document we should setup observers only once.
        continue if document.Meta._observersSetup
        document.Meta._observersSetup = true

        # We setup triggers only when we are not updating all.
        setupTriggerObserves document.Meta.triggers
        setupTargetObservers document.Meta.fields
        setupTargetObservers document.Meta.generators
        document._setupSourceObservers false

    return

  @Trigger: (args...) ->
    new @_Trigger args...

  @ReferenceField: (args...) ->
    new @_ReferenceField args...

  @GeneratedField: (args...) ->
    new @_GeneratedField args...

  @usedBy: ->
    fields = []

    fieldsWalker = (document, obj) =>
      for name, field of obj
        if field instanceof globals.Document._ReferenceField
          if field.targetDocument is @
            assert field.sourceDocument is document
            fields.push
              field: field
              document: field.sourceDocument
              path: field.sourcePath
        else if field not instanceof globals.Document._Field
          fieldsWalker document, field

    for document in @list
      fieldsWalker document, document.Meta.fields

    return fields

class globals.Document._Trigger
  # Arguments:
  #   fields
  #   fields, trigger, triggerOnUnmodifiable
  constructor: (@fields, @trigger, @triggerOnUnmodifiable) ->
    @fields ?= []

  contributeToClass: (@document, @name) =>
    @_metaLocation = @document.Meta._location
    @collection = @document.Meta.collection

  validate: =>
    # TODO: Should these be simply asserts?
    throw new Error "Missing meta location" unless @_metaLocation
    throw new Error "Missing name (from #{ @_metaLocation })" unless @name
    throw new Error "Missing document (for #{ @name} trigger from #{ @_metaLocation })" unless @document
    throw new Error "Missing collection (for #{ @name} trigger from #{ @_metaLocation })" unless @collection
    throw new Error "Document not defined (for #{ @name} trigger from #{ @_metaLocation })" unless @document.Meta._listIndex?

    assert not @document.Meta._replaced
    assert not @document.Meta._delayIndex?
    assert.equal @document.Meta.document, @document
    assert.equal @document.Meta.document.Meta, @document.Meta

  _setupObservers: =>
    return unless isModifiableCollection(@collection) or @triggerOnUnmodifiable

    initializing = true

    limitToPrefix = isServerCollection @collection

    queryFields = fieldsToProjection @fields
    @collection.find({}, fields: queryFields).observe
      added: globals.Document._observerCallback limitToPrefix, (document) =>
        @trigger document, null unless initializing

      changed: globals.Document._observerCallback limitToPrefix, (newDocument, oldDocument) =>
        @trigger newDocument, oldDocument

      removed: globals.Document._observerCallback limitToPrefix, (oldDocument) =>
        @trigger null, oldDocument

    initializing = false

class globals.Document._Field
  contributeToClass: (@sourceDocument, @sourcePath, @ancestorArray) =>
    @_metaLocation = @sourceDocument.Meta._location
    @sourceCollection = @sourceDocument.Meta.collection

  validate: =>
    # TODO: Should these be simply asserts?
    throw new Error "Missing meta location" unless @_metaLocation
    throw new Error "Missing source path (from #{ @_metaLocation })" unless @sourcePath
    throw new Error "Missing source document (for #{ @sourcePath } from #{ @_metaLocation })" unless @sourceDocument
    throw new Error "Missing source collection (for #{ @sourcePath } from #{ @_metaLocation })" unless @sourceCollection
    throw new Error "Source document not defined (for #{ @sourcePath } from #{ @_metaLocation })" unless @sourceDocument.Meta._listIndex?

    assert not @sourceDocument.Meta._replaced
    assert not @sourceDocument.Meta._delayIndex?
    assert.equal @sourceDocument.Meta.document, @sourceDocument
    assert.equal @sourceDocument.Meta.document.Meta, @sourceDocument.Meta

class globals.Document._ObservingField extends globals.Document._Field

class globals.Document._TargetedFieldsObservingField extends globals.Document._ObservingField
  # Arguments:
  #   targetDocument, fields
  constructor: (targetDocument, @fields) ->
    super()

    @fields ?= []

    if targetDocument is 'self'
      @targetDocument = 'self'
      @targetCollection = null
    else if _.isFunction(targetDocument) and targetDocument.prototype instanceof globals.Document
      @targetDocument = targetDocument
      @targetCollection = targetDocument.Meta.collection
    else
      throw new Error INVALID_TARGET

  contributeToClass: (sourceDocument, sourcePath, ancestorArray) =>
    super sourceDocument, sourcePath, ancestorArray

    if @targetDocument is 'self'
      @targetDocument = @sourceDocument
      @targetCollection = @sourceCollection

    # Helpful values to know where and what the field is
    @inArray = @ancestorArray and startsWith @sourcePath, @ancestorArray
    @isArray = @ancestorArray and @sourcePath is @ancestorArray
    @arraySuffix = removePrefix @sourcePath, @ancestorArray if @inArray

  validate: =>
    super()

    throw new Error "Missing target document (for #{ @sourcePath } from #{ @_metaLocation })" unless @targetDocument
    throw new Error "Missing target collection (for #{ @sourcePath } from #{ @_metaLocation })" unless @targetCollection
    throw new Error "Target document not defined (for #{ @sourcePath } from #{ @_metaLocation })" unless @targetDocument.Meta._listIndex?

    assert not @targetDocument.Meta._replaced
    assert not @targetDocument.Meta._delayIndex?
    assert.equal @targetDocument.Meta.document, @targetDocument
    assert.equal @targetDocument.Meta.document.Meta, @targetDocument.Meta

  _setupTargetObservers: (updateAll) =>
    return unless isModifiableCollection @sourceCollection

    initializing = true

    # Limit to PREFIX only when both collections are server side. Otherwise there is a collection
    # which is local only to this instance and we want to process all documents for it. Alternatively,
    # there is a collection through a connection, in which case we are conservative and also process
    # all documents for it. We do not necessary know if connections are shared between instances.
    limitToPrefix = isServerCollection(@targetCollection) and isServerCollection(@sourceCollection)

    observers =
      added: globals.Document._observerCallback limitToPrefix, (id, fields) =>
        @updateSource id, fields if updateAll or not initializing

    unless updateAll
      observers.changed = globals.Document._observerCallback limitToPrefix, (id, fields) =>
        @updateSource id, fields

      observers.removed = globals.Document._observerCallback limitToPrefix, (id) =>
        @removeSource id

    referenceFields = fieldsToProjection @fields
    handle = @targetCollection.find({}, fields: referenceFields).observeChanges observers

    initializing = false

    handle.stop() if updateAll

class globals.Document._ReferenceField extends globals.Document._TargetedFieldsObservingField
  # Arguments:
  #   targetDocument, fields
  #   targetDocument, fields, required
  #   targetDocument, fields, required, reverseName
  #   targetDocument, fields, required, reverseName, reverseFields
  constructor: (targetDocument, fields, @required, @reverseName, @reverseFields) ->
    super targetDocument, fields

    @required ?= true
    @reverseName ?= null
    @reverseFields ?= []

  contributeToClass: (sourceDocument, sourcePath, ancestorArray) =>
    super sourceDocument, sourcePath, ancestorArray

    throw new Error "Reference field directly in an array cannot be optional (for #{ @sourcePath } from #{ @_metaLocation })" if @ancestorArray and @sourcePath is @ancestorArray and not @required

    return unless @reverseName

    return if @sourceDocument.Meta.local

    # We return now because contributeToClass will be retried sooner or later with replaced document again
    return if @targetDocument.Meta._replaced

    for reverse in @targetDocument.Meta._reverseFields
      return if _.isEqual(reverse.reverseName, @reverseName) and _.isEqual(reverse.reverseFields, @reverseFields) and reverse.sourceDocument is @sourceDocument

    @targetDocument.Meta._reverseFields.push @

    # If target document is already defined, we queue it for a retry.
    # We do not queue children, because or children replace a parent
    # (and reverse fields will be defined there), or reference is
    # pointing to this target document and we want reverse defined
    # only once and only on exact target document and not its
    # children.
    if @targetDocument.Meta._listIndex?
      globals.Document.list.splice @targetDocument.Meta._listIndex, 1

      delete @targetDocument.Meta._replaced
      delete @targetDocument.Meta._listIndex

      # Renumber documents
      for doc, i in globals.Document.list
        doc.Meta._listIndex = i

      globals.Document._addDelayed @targetDocument

  _setupTargetObservers: (updateAll) =>
    if not updateAll
      index = {}
      index["#{ @sourcePath }._id"] = 1
      @sourceCollection._ensureIndex index if Meteor.isServer and @sourceCollection._connection is Meteor.server

      if @reverseName
        index = {}
        index["#{ @reverseName }._id"] = 1
        @targetCollection._ensureIndex index if Meteor.isServer and @targetCollection._connection is Meteor.server

    super updateAll

  updateSource: (id, fields) =>
    # Just to be sure
    return if _.isEmpty fields

    selector = {}
    update = {}

    if @inArray
      for field, value of fields
        path = "#{ @ancestorArray }.$#{ @arraySuffix }.#{ field }"

        if _.isUndefined value
          update.$unset ?= {}
          update.$unset[path] = ''
        else
          update.$set ?= {}
          update.$set[path] = value

        # We cannot use top-level $or with $elemMatch
        # See: https://jira.mongodb.org/browse/SERVER-11537
        selector[@ancestorArray] ?= {}
        selector[@ancestorArray].$elemMatch ?=
          $or: []

        s = {}
        # We have to repeat id selector here as well
        # See: https://jira.mongodb.org/browse/SERVER-11536
        s["#{ @arraySuffix }._id".substring(1)] = id
        # Remove initial dot with substring(1)
        if _.isUndefined value
          s["#{ @arraySuffix }.#{ field }".substring(1)] =
            $exists: true
        else
          s["#{ @arraySuffix }.#{ field }".substring(1)] =
            $ne: value

        selector[@ancestorArray].$elemMatch.$or.push s

      # $ operator updates only the first matching element in the array,
      # so we have to loop until nothing changes
      # See: https://jira.mongodb.org/browse/SERVER-1243
      loop
        break unless @sourceCollection.update selector, update, multi: true

    else
      selector["#{ @sourcePath }._id"] = id

      for field, value of fields
        path = "#{ @sourcePath }.#{ field }"

        s = {}
        if _.isUndefined value
          update.$unset ?= {}
          update.$unset[path] = ''

          s[path] =
            $exists: true
        else
          update.$set ?= {}
          update.$set[path] = value

          s[path] =
            $ne: value

        selector.$or ?= []
        selector.$or.push s

      @sourceCollection.update selector, update, multi: true

  removeSource: (id) =>
    selector = {}
    selector["#{ @sourcePath }._id"] = id

    # If it is an array or a required field of a subdocument is in an array, we remove references from an array
    if @isArray or (@required and @inArray)
      update =
        $pull: {}
      update.$pull[@ancestorArray] = {}
      # @arraySuffix starts with a dot, so with .substring(1) we always remove a dot
      update.$pull[@ancestorArray]["#{ @arraySuffix or '' }._id".substring(1)] = id

      @sourceCollection.update selector, update, multi: true

    # If it is an optional field of a subdocument in an array, we set it to null
    else if not @required and @inArray
      path = "#{ @ancestorArray }.$#{ @arraySuffix }"
      update =
        $set: {}
      update.$set[path] = null

      # $ operator updates only the first matching element in the array.
      # So we have to loop until nothing changes.
      # See: https://jira.mongodb.org/browse/SERVER-1243
      loop
        break unless @sourceCollection.update selector, update, multi: true

    # If it is an optional reference, we set it to null
    else if not @required
      update =
        $set: {}
      update.$set[@sourcePath] = null

      @sourceCollection.update selector, update, multi: true

    # Else, we remove the whole document
    else
      @sourceCollection.remove selector

  updatedWithValue: (id, value) =>
    referenceFields = fieldsToProjection @fields

    if isModifiableCollection @sourceCollection
      unless _.isObject(value) and _.isString(value._id)
        # Optional field
        return if _.isNull(value) and not @required

        # TODO: This is not triggered if required field simply do not exist or is set to undefined (does MongoDB support undefined value?)
        Log.error "Document '#{ @sourceDocument.Meta._name }' '#{ id }' field '#{ @sourcePath }' was updated with an invalid value: #{ util.inspect value }"
        return

      target = @targetCollection.findOne value._id,
        fields: referenceFields
        transform: null

      unless target
        Log.error "Document '#{ @sourceDocument.Meta._name }' '#{ id }' field '#{ @sourcePath }' is referencing a nonexistent document '#{ value._id }'"
        # TODO: Should we call reference.removeSource here? And remove from reverse fields?
        return

      # Only _id is requested, we do not have to do anything, we just wanted to check for existence of the referenced document.
      unless _.isEmpty @fields
        # We omit _id because that field cannot be changed, or even $set to the same value, but is in target
        @updateSource target._id, _.omit target, '_id'

    return unless @reverseName

    return unless isModifiableCollection @targetCollection

    # TODO: Current code is run too many times, for any update of source collection reverse field is updated

    # We add other fields (@reverseFields) to the reverse field array only the first time,
    # when we are adding the new subdocument to the array. Keeping them updated later on is done
    # by reference fields configured through Meta._reverseFields. This assures subdocuments in
    # the reverse field array always match the schema, from the very beginning.

    selector =
      _id: value._id
    selector["#{ @reverseName }._id"] =
      $ne: id

    update = {}
    update[@reverseName] =
      _id: id

    # Only _id is requested, we do not have to do anything more
    unless _.isEmpty @reverseFields
      referenceFields = fieldsToProjection @reverseFields
      source = @sourceCollection.findOne id,
        fields: referenceFields
        transform: null

      unless source
        Log.error "Document '#{ @sourceDocument.Meta._name }' '#{ id }' document disappeared while fetching reverse fields for field '#{ @sourcePath }' ('#{ @reverseName }')"
        # TODO: Should we call reference.removeSource here? And remove from reverse fields?

        # No need adding it to the reverse field because it does not exist anymore.
        return

      update[@reverseName] = source

    @targetCollection.update selector,
      $addToSet: update

class globals.Document._GeneratedField extends globals.Document._TargetedFieldsObservingField
  # Arguments:
  #   targetDocument, fields
  #   targetDocument, fields, generator
  constructor: (targetDocument, fields, @generator) ->
    super targetDocument, fields

  _updateSourceField: (id, fields) =>
    [selector, sourceValue] = @generator fields

    return unless selector

    if @isArray and not _.isArray sourceValue
      Log.error "Generated field '#{ @sourcePath }' defined as an array with selector '#{ selector }' was updated with a non-array value: #{ util.inspect sourceValue }"
      return

    if not @isArray and _.isArray sourceValue
      Log.error "Generated field '#{ @sourcePath }' not defined as an array with selector '#{ selector }' was updated with an array value: #{ util.inspect sourceValue }"
      return

    update = {}
    if _.isUndefined sourceValue
      update.$unset = {}
      update.$unset[@sourcePath] = ''
    else
      update.$set = {}
      update.$set[@sourcePath] = sourceValue

    @sourceCollection.update selector, update, multi: true

  _updateSourceNestedArray: (id, fields) =>
    assert @arraySuffix # Should be non-null

    values = @generator fields

    unless _.isArray values
      Log.error "Value returned from the generator for field '#{ @sourcePath }' is not a nested array despite field being nested in an array: #{ util.inspect values }"
      return

    for [selector, sourceValue], i in values
      continue unless selector

      if _.isArray sourceValue
        Log.error "Generated field '#{ @sourcePath }' not defined as an array with selector '#{ selector }' was updated with an array value: #{ util.inspect sourceValue }"
        continue

      path = "#{ @ancestorArray }.#{ i }#{ @arraySuffix }"

      update = {}
      if _.isUndefined sourceValue
        update.$unset = {}
        update.$unset[path] = ''
      else
        update.$set = {}
        update.$set[path] = sourceValue

      break unless @sourceCollection.update selector, update, multi: true

  updateSource: (id, fields) =>
    if _.isEmpty fields
      fields._id = id
    # TODO: Not completely correct when @fields contain multiple fields from same subdocument or objects with projections (they will be counted only once) - because Meteor always passed whole subdocuments we could count only top-level fields in @fields, merged with objects?
    else if _.size(fields) isnt @fields.length
      targetFields = fieldsToProjection @fields
      fields = @targetCollection.findOne id,
        fields: targetFields
        transform: null

      # There is a slight race condition here, document could be deleted in meantime.
      # In such case we set fields as they are when document is deleted.
      unless fields
        fields =
          _id: id
    else
      fields._id = id

    # Only if we are updating value nested in a subdocument of an array we operate
    # on the array. Otherwise we simply set whole array to the value returned.
    if @inArray and not @isArray
      @_updateSourceNestedArray id, fields
    else
      @_updateSourceField id, fields

  removeSource: (id) =>
    @updateSource id, {}

  updatedWithValue: (id, value) =>
    # Do nothing. Code should not be updating generated field by itself anyway.

class globals.Document._Manager
  constructor: (@meta) ->

  find: (args...) =>
    # Keep in mind that find() (return all docs) behaves differently from find(undefined) (return 0 docs).
    @meta.collection.find args...

  findOne: (args...) =>
    # Keep in mind that findOne() (return one doc) behaves differently from findOne(undefined) (return 0 docs).
    @meta.collection.findOne args...

  insert: (args...) =>
    @meta.collection.insert args...

  bulkInsert: (docs, options, callback) =>
    if _.isFunction options
      callback = options
      options = {}

    # A list of optional reference fields which should not be delayed. By default, all optional
    # references are delayed. Reference fields inside arrays are always delayed.
    options ?= {}
    options.dontDelay ?= []
    referencesInclude = {}
    referencesExclude = {}

    fieldsWalker = (obj) ->
      for name, field of obj
        if field instanceof globals.Document._ReferenceField
          if not field.required or field.isArray
            unless field.sourcePath in options.dontDelay
              referencesInclude[field.sourcePath] = field
              referencesExclude[field.sourcePath] = 0
          else if field.inArray
            assert field.required
            referencesInclude[field.ancestorArray] = field
            referencesExclude[field.ancestorArray] = 0
        else if field not instanceof globals.Document._Field
          fieldsWalker field

    fieldsWalker @meta.fields

    # Fix duplicate references in case of array fields. Keep only the shortest common prefix.
    for path, value of referencesExclude
      for comparedPath, value of referencesExclude
        continue if path is comparedPath

        if path.substr(0, comparedPath.length) is comparedPath
          delete referencesExclude[path]
          delete referencesInclude[path]
          break

    referencesExcludeProjection = LocalCollection._compileProjection referencesExclude
    referencesIncludeModification = (document) ->
      # We can't use _compileProjection here as this would cause top-level fields to
      # be overwritten when updating subfields.
      result = {}
      for path, field of referencesInclude
        if field.inArray
          # If the reference is in an array, we should update the parent.
          path = field.ancestorArray
          assert not result[path]

        value = _.reduce path.split('.'), ((doc, atom) -> doc?[atom]), document
        if _.isUndefined value
          # Explicit null is needed on the client as otherwise the reference will be absent.
          value = if field.isArray or field.inArray then [] else null

        result[path] = value

      result

    enclosing = DDP._CurrentInvocation.get()
    alreadyInSimulation = enclosing && enclosing.isSimulation

    if Meteor.isServer or alreadyInSimulation
      try
        # We first insert documents without any optional or in-array references set.
        # This allows us to have all documents in the database before we start to
        # add references so that PeerDB does not complain or even remove documents
        # because of a missing referenced document.
        ids = for doc in docs
          # If document has an _id, then we try to be smart and delay references.
          doc = referencesExcludeProjection doc if '_id' of doc

          @insert doc

        # And now add also the references between documents.
        for doc in docs when '_id' of doc
          @update doc._id,
            $set: referencesIncludeModification doc

      catch error
        if callback
          callback error
          return null
        throw error

      callback? null, ids
      return ids

    # The same on the client (outside a simulation), but callback-style.
    else
      unless callback
        # Default callback. Same as Meteor's.
        callback = (error) =>
          Meteor._debug "bulkInsert failed: #{ error.reason or error.stack }" if error

      # To cover the edge case and always call a callback.
      unless docs.length
        callback null, []
        return []

      # We are using a dict so that we can write to these variables inside
      # callbacks. CoffeeScript otherwise makes new local variables instead.
      callbackClosure =
        error: null
        counter: docs.length

      ids = for doc in docs
        doc = referencesExcludeProjection doc if '_id' of doc

        @insert doc, (error, id) =>
          # We store only the first error.
          callbackClosure.error = error if error and not callbackClosure.error
          callbackClosure.counter--

          return unless callbackClosure.counter is 0

          return callback callbackClosure.error if callbackClosure.error

          finalCallback = ->
            if ids.length isnt docs.length
              # There might be an (unconfirmed) edge case where the last insert's callback is called before
              # the last insert returns, and if the same repeats with the update, ids might not yet be complete.
              assert.equal ids.length, docs.length - 1
              callback null, ids.concat [id]
            else
              callback null, ids

          anyUpdate = false
          callbackClosure.counter = docs.length

          # And now add also the references between documents.
          for doc in docs
            unless '_id' of doc
              callbackClosure.counter--
            else
              anyUpdate = true

              @update doc._id,
                $set: referencesIncludeModification doc
              ,
                (error) =>
                  # We store only the first error.
                  callbackClosure.error = error if error and not callbackClosure.error
                  callbackClosure.counter--

                  return unless callbackClosure.counter is 0

                  return callback callbackClosure.error if callbackClosure.error

                  finalCallback()

          # Catching the edge case when no document had an _id field, so no update is called and no callback is called.
          finalCallback() unless anyUpdate

      return ids

  update: (args...) =>
    @meta.collection.update args...

  upsert: (args...) =>
    @meta.collection.upsert args...

  remove: (args...) =>
    @meta.collection.remove args...

  exists: (query, options) =>
    # exists() (check all docs) behaves differently from exists(undefined) (check 0 docs).
    query ?= {} unless arguments.length
    options ?= {}

    # We want only a top-level extend here.
    _.extend options,
      fields:
        _id: 1
      transform: null

    !!@meta.collection.findOne query, options

Meteor.startup ->
  if globals.Document.instances > 1
    range = share.UNMISTAKABLE_CHARS.length / globals.Document.instances
    PREFIX = PREFIX[Math.round(globals.Document.instance * range)...Math.round((globals.Document.instance + 1) * range)]

  # To try delayed references one last time, throwing any exceptions
  # (Otherwise setupObservers would trigger strange exceptions anyway)
  globals.Document.defineAll()

  # We first have to setup messages, so that migrations can run properly
  # (if they call updateAll, the message should be listened for)
  share.setupMessages() unless globals.Document.instanceDisabled

  globals.Document.runPrepare()

  if globals.Document.instanceDisabled
    Log.info "Skipped observers"
    # To make sure everything is really skipped
    PREFIX = []
  else
    if globals.Document.instances is 1
      Log.info "Enabling observers..."
    else
      Log.info "Enabling observers, instance #{ globals.Document.instance }/#{ globals.Document.instances }, matching ID prefix: #{ PREFIX.join '' }"
    globals.Document._setupObservers()
    Log.info "Done"

  globals.Document.runStartup()

Document = globals.Document

assert globals.Document._ReferenceField.prototype instanceof globals.Document._TargetedFieldsObservingField
assert globals.Document._GeneratedField.prototype instanceof globals.Document._TargetedFieldsObservingField
