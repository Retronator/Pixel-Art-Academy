WAIT_FOR_DATABASE_TIMEOUT = 2000 # ms

# The order of documents here tests delayed definitions

# Just to make sure things are sane
assert.equal Document._delayed.length, 0
assert _.isEqual Document.list, []
assert _.isEqual Document._collections, {}

globalTestTriggerCounters = {}

class Post extends Document
  # Other fields:
  #   body
  #   subdocument
  #     body
  #   nested
  #     body

  @Meta
    name: 'Post'
    fields: ->
      # We can reference other document
      author: @ReferenceField Person, ['username', 'displayName', 'field1', 'field2'], true, 'posts', ['body', 'subdocument.body', 'nested.body']
      # Or an array of documents
      subscribers: [@ReferenceField Person]
      # Fields can be arbitrary MongoDB projections, as an array
      reviewers: [@ReferenceField Person, [username: 1]]
      subdocument:
        # Fields can be arbitrary MongoDB projections, as an object
        person: @ReferenceField Person, {'username': 1, 'displayName': 1, 'field1': 1, 'field2': 1}, false, 'subdocument.posts', ['body', 'subdocument.body', 'nested.body']
      nested: [
        required: @ReferenceField Person, ['username', 'displayName', 'field1', 'field2'], true, 'nestedPosts', ['body', 'subdocument.body', 'nested.body']
        optional: @ReferenceField Person, ['username'], false
        slug: @GeneratedField 'self', ['body', 'nested.body'], (fields) ->
          for nested in fields.nested or []
            if _.isUndefined(fields.body) or _.isUndefined(nested.body)
              [fields._id, undefined]
            else if _.isNull(fields.body) or _.isNull(nested.body)
              [fields._id, null]
            else
              [fields._id, "nested-prefix-#{ fields.body.toLowerCase() }-#{ nested.body.toLowerCase() }-suffix"]
      ]
      slug: @GeneratedField 'self', ['body', 'subdocument.body'], (fields) ->
        if _.isUndefined(fields.body) or _.isUndefined(fields.subdocument?.body)
          [fields._id, undefined]
        else if _.isNull(fields.body) or _.isNull(fields.subdocument.body)
          [fields._id, null]
        else
          [fields._id, "prefix-#{ fields.body.toLowerCase() }-#{ fields.subdocument.body.toLowerCase() }-suffix"]
    generators: ->
      subdocument:
        slug: @GeneratedField 'self', ['body', 'subdocument.body'], (fields) ->
          if _.isUndefined(fields.body) or _.isUndefined(fields.subdocument?.body)
            [fields._id, undefined]
          else if _.isNull(fields.body) or _.isNull(fields.subdocument.body)
            [fields._id, null]
          else
            [fields._id, "subdocument-prefix-#{ fields.body.toLowerCase() }-#{ fields.subdocument.body.toLowerCase() }-suffix"]
      tags: [
        @GeneratedField 'self', ['body', 'subdocument.body', 'nested.body'], (fields) ->
          tags = []
          if fields.body and fields.subdocument?.body
            tags.push "tag-#{ tags.length }-prefix-#{ fields.body.toLowerCase() }-#{ fields.subdocument.body.toLowerCase() }-suffix"
          if fields.body and fields.nested and _.isArray fields.nested
            for nested in fields.nested when nested.body
              tags.push "tag-#{ tags.length }-prefix-#{ fields.body.toLowerCase() }-#{ nested.body.toLowerCase() }-suffix"
          [fields._id, tags]
      ]
    triggers: ->
      testTrigger: @Trigger ['body'], (newDocument, oldDocument) ->
        return unless newDocument?._id
        globalTestTriggerCounters[newDocument._id] = (globalTestTriggerCounters[newDocument._id] or 0) + 1

# Store away for testing
_TestPost = Post

# Extending delayed document
class Post extends Post
  @Meta
    name: 'Post'
    replaceParent: true
    fields: (fields) ->
      fields.subdocument.persons = [@ReferenceField Person, ['username', 'displayName', 'field1', 'field2'], true, 'subdocumentsPosts', ['body', 'subdocument.body', 'nested.body']]
      fields

# Store away for testing
_TestPost2 = Post

class User extends Document
  @Meta
    name: 'User'
    # Specifying collection directly
    collection: Meteor.users

class UserLink extends Document
  @Meta
    name: 'UserLink'
    fields: ->
      user: @ReferenceField User, ['username'], false

class PostLink extends Document
  @Meta
    name: 'PostLink'

# Store away for testing
_TestPostLink = PostLink

# To test extending when initial document has no fields
class PostLink extends PostLink
  @Meta
    name: 'PostLink'
    replaceParent: true
    fields: ->
      post: @ReferenceField Post, ['subdocument.person', 'subdocument.persons']

class CircularFirst extends Document
  # Other fields:
  #   content

  @Meta
    name: 'CircularFirst'

# Store away for testing
_TestCircularFirst = CircularFirst

# To test extending when initial document has no fields and fields will be delayed
class CircularFirst extends CircularFirst
  @Meta
    name: 'CircularFirst'
    replaceParent:  true
    fields: (fields) ->
      # We can reference circular documents
      fields.second = @ReferenceField CircularSecond, ['content'], true, 'reverseFirsts', ['content']
      fields

class CircularSecond extends Document
  # Other fields:
  #   content

  @Meta
    name: 'CircularSecond'
    fields: ->
      # But of course one should not be required so that we can insert without warnings
      first: @ReferenceField CircularFirst, ['content'], false, 'reverseSeconds', ['content']

class Person extends Document
  # Other fields:
  #   username
  #   displayName
  #   field1
  #   field2

  @Meta
    name: 'Person'
    generators: ->
      count: @GeneratedField 'self', ['posts', 'subdocument.posts', 'subdocumentsPosts', 'nestedPosts'], (fields) ->
        [fields._id, (fields.posts?.length or 0) + (fields.nestedPosts?.length or 0) + (fields.subdocument?.posts?.length or 0) + (fields.subdocumentsPosts?.length or 0)]

# Store away for testing
_TestPerson = Person

# To test if reverse fields *are* added to the extended class which replaces the parent
class Person extends Person
  @Meta
    name: 'Person'
    replaceParent: true

  formatName: ->
    "#{ @username }-#{ @displayName or "none" }"

# To test if reverse fields are *not* added to the extended class which replaces the parent
class SpecialPerson extends Person
  @Meta
    name: 'SpecialPerson'
    fields: ->
      # posts and nestedPosts don't exist, so we remove count field as well
      count: undefined

class RecursiveBase extends Document
  @Meta
    abstract: true
    fields: ->
      other: @ReferenceField 'self', ['content'], false, 'reverse', ['content']

class Recursive extends RecursiveBase
  # Other fields:
  #   content

  @Meta
    name: 'Recursive'

class IdentityGenerator extends Document
  # Other fields:
  #   source

  @Meta
    name: 'IdentityGenerator'
    generators: ->
      result: @GeneratedField 'self', ['source'], (fields) ->
        throw new Error "Test exception" if fields.source is 'exception'
        return [fields._id, fields.source]
      results: [
        @GeneratedField 'self', ['source'], (fields) ->
          return [fields._id, fields.source]
      ]

# Extending and renaming the class, this creates new collection as well
class SpecialPost extends Post
  @Meta
    name: 'SpecialPost'
    fields: ->
      special: @ReferenceField Person

# To test redefinig after fields already have a reference to an old document
class Post extends Post
  @Meta
    name: 'Post'
    replaceParent: true

# To test handling of subfield references in bulk insert
class SubfieldItem extends Document
  @Meta
    name: 'SubfieldItem'
    fields: ->
      toplevel:
        subitem: @ReferenceField 'self', [], false
      objectInArray: [
        subitem: @ReferenceField 'self', [], false
        subitem2: @ReferenceField 'self', []
      ]
      anArray: [@ReferenceField 'self', []]

class LocalPost extends Document
  # Other fields:
  #   body
  #   subdocument
  #     body
  #   nested
  #     body

  @Meta
    name: 'LocalPost'
    collection: null
    fields: ->
      author: @ReferenceField LocalPerson, ['username', 'displayName', 'field1', 'field2'], true, 'posts', ['body', 'subdocument.body', 'nested.body']
      subscribers: [@ReferenceField LocalPerson]
      reviewers: [@ReferenceField LocalPerson, [username: 1]]
      subdocument:
        person: @ReferenceField LocalPerson, {'username': 1, 'displayName': 1, 'field1': 1, 'field2': 1}, false, 'subdocument.posts', ['body', 'subdocument.body', 'nested.body']
        persons: [@ReferenceField LocalPerson, ['username', 'displayName', 'field1', 'field2'], true, 'subdocumentsPosts', ['body', 'subdocument.body', 'nested.body']]
        slug: @GeneratedField 'self', ['body', 'subdocument.body'], (fields) ->
          if _.isUndefined(fields.body) or _.isUndefined(fields.subdocument?.body)
            [fields._id, undefined]
          else if _.isNull(fields.body) or _.isNull(fields.subdocument.body)
            [fields._id, null]
          else
            [fields._id, "subdocument-prefix-#{ fields.body.toLowerCase() }-#{ fields.subdocument.body.toLowerCase() }-suffix"]
      nested: [
        required: @ReferenceField LocalPerson, ['username', 'displayName', 'field1', 'field2'], true, 'nestedPosts', ['body', 'subdocument.body', 'nested.body']
        optional: @ReferenceField LocalPerson, ['username'], false
        slug: @GeneratedField 'self', ['body', 'nested.body'], (fields) ->
          for nested in fields.nested or []
            if _.isUndefined(fields.body) or _.isUndefined(nested.body)
              [fields._id, undefined]
            else if _.isNull(fields.body) or _.isNull(nested.body)
              [fields._id, null]
            else
              [fields._id, "nested-prefix-#{ fields.body.toLowerCase() }-#{ nested.body.toLowerCase() }-suffix"]
      ]
      slug: @GeneratedField 'self', ['body', 'subdocument.body'], (fields) ->
        if _.isUndefined(fields.body) or _.isUndefined(fields.subdocument?.body)
          [fields._id, undefined]
        else if _.isNull(fields.body) or _.isNull(fields.subdocument.body)
          [fields._id, null]
        else
          [fields._id, "prefix-#{ fields.body.toLowerCase() }-#{ fields.subdocument.body.toLowerCase() }-suffix"]
      tags: [
        @GeneratedField 'self', ['body', 'subdocument.body', 'nested.body'], (fields) ->
          tags = []
          if fields.body and fields.subdocument?.body
            tags.push "tag-#{ tags.length }-prefix-#{ fields.body.toLowerCase() }-#{ fields.subdocument.body.toLowerCase() }-suffix"
          if fields.body and fields.nested and _.isArray fields.nested
            for nested in fields.nested when nested.body
              tags.push "tag-#{ tags.length }-prefix-#{ fields.body.toLowerCase() }-#{ nested.body.toLowerCase() }-suffix"
          [fields._id, tags]
      ]
    triggers: ->
      testTrigger: @Trigger ['body'], (newDocument, oldDocument) ->
        return unless newDocument?._id
        globalTestTriggerCounters[newDocument._id] = (globalTestTriggerCounters[newDocument._id] or 0) + 1

class LocalPerson extends Document
  # Other fields:
  #   username
  #   displayName
  #   field1
  #   field2

  @Meta
    name: 'LocalPerson'
    collection: null
    fields: ->
      count: @GeneratedField 'self', ['posts', 'subdocument.posts', 'subdocumentsPosts', 'nestedPosts'], (fields) ->
        [fields._id, (fields.posts?.length or 0) + (fields.nestedPosts?.length or 0) + (fields.subdocument?.posts?.length or 0) + (fields.subdocumentsPosts?.length or 0)]

  formatName: ->
    "#{ @username }-#{ @displayName or "none" }"

Document.defineAll()

# Just to make sure things are sane
assert.equal Document._delayed.length, 0

if Meteor.isServer
  # Initialize the database

  try
    Post.Meta.collection._dropCollection()
    User.Meta.collection._dropCollection()
    UserLink.Meta.collection._dropCollection()
    PostLink.Meta.collection._dropCollection()
    CircularFirst.Meta.collection._dropCollection()
    CircularSecond.Meta.collection._dropCollection()
    Person.Meta.collection._dropCollection()
    SpecialPerson.Meta.collection._dropCollection()
    Recursive.Meta.collection._dropCollection()
    IdentityGenerator.Meta.collection._dropCollection()
    SpecialPost.Meta.collection._dropCollection()
    SubfieldItem.Meta.collection._dropCollection()
  catch error
    throw error unless /ns not found/.test "#{error}"

  Meteor.publish null, ->
    Post.documents.find()
  # User is already published as Meteor.users
  Meteor.publish null, ->
    UserLink.documents.find()
  Meteor.publish null, ->
    PostLink.documents.find()
  Meteor.publish null, ->
    CircularFirst.documents.find()
  Meteor.publish null, ->
    CircularSecond.documents.find()
  Meteor.publish null, ->
    Person.documents.find()
  Meteor.publish null, ->
    Recursive.documents.find()
  Meteor.publish null, ->
    IdentityGenerator.documents.find()
  Meteor.publish null, ->
    SpecialPost.documents.find()
  Meteor.publish null, ->
    SubfieldItem.documents.find()

  Future = Npm.require 'fibers/future'

  Meteor.methods
    'wait-for-database': ->
      future = new Future()
      timeout = null
      newTimeout = ->
        Meteor.clearTimeout timeout if timeout
        timeout = Meteor.setTimeout ->
          timeout = null
          future.return() unless future.isResolved()
        , WAIT_FOR_DATABASE_TIMEOUT
      newTimeout()
      handles = []
      for document in Document.list
        do (document) ->
          handles.push document.documents.find({}).observeChanges
            added: (id, fields) ->
              newTimeout()
            changed: (id, fields) ->
              newTimeout()
            removed: (id) ->
              newTimeout()
      future.wait()
      for handle in handles
        handle.stop()

waitForDatabase = (test, expect) ->
  Meteor.call 'wait-for-database', expect (error) ->
    test.isFalse error, error?.toString?() or error

ALL = @ALL = [User, UserLink, CircularFirst, CircularSecond, SpecialPerson, Recursive, IdentityGenerator, SpecialPost, Post, Person, PostLink, SubfieldItem, LocalPost, LocalPerson]

testDocumentList = (test, list) ->
  test.equal Document.list, list, "expected: #{ (d.Meta._name for d in list) } vs. actual: #{ (d.Meta._name for d in Document.list) }"

intersectionObjects = (array, rest...) ->
  _.filter _.uniq(array), (item) ->
    _.every rest, (other) ->
      _.any other, (element) -> _.isEqual element, item

testSetEqual = (test, a, b) ->
  a ||= []
  b ||= []

  if a.length is b.length and intersectionObjects(a, b).length is a.length
    test.ok()
  else
    test.fail
      type: 'assert_set_equal'
      actual: JSON.stringify a
      expected: JSON.stringify b

testDefinition = (test) ->
  test.equal Post.Meta._name, 'Post'
  test.equal Post.Meta.parent, _TestPost2.Meta
  test.equal Post.Meta.document, Post
  test.equal Post.Meta.collection._name, 'Posts'
  test.equal _.size(Post.Meta.triggers), 1
  test.instanceOf Post.Meta.triggers.testTrigger, Post._Trigger
  test.equal Post.Meta.triggers.testTrigger.name, 'testTrigger'
  test.equal Post.Meta.triggers.testTrigger.document, Post
  test.equal Post.Meta.triggers.testTrigger.collection._name, 'Posts'
  test.equal Post.Meta.triggers.testTrigger.fields, ['body']
  test.equal _.size(Post.Meta.generators), 2
  test.equal _.size(Post.Meta.generators.subdocument), 1
  test.instanceOf Post.Meta.generators.subdocument.slug, Post._GeneratedField
  test.isNull Post.Meta.generators.subdocument.slug.ancestorArray, Post.Meta.generators.subdocument.slug.ancestorArray
  test.isTrue _.isFunction Post.Meta.generators.subdocument.slug.generator
  test.equal Post.Meta.generators.subdocument.slug.sourcePath, 'subdocument.slug'
  test.equal Post.Meta.generators.subdocument.slug.sourceDocument, Post
  test.equal Post.Meta.generators.subdocument.slug.targetDocument, Post
  test.equal Post.Meta.generators.subdocument.slug.sourceCollection._name, 'Posts'
  test.equal Post.Meta.generators.subdocument.slug.targetCollection._name, 'Posts'
  test.equal Post.Meta.generators.subdocument.slug.sourceDocument.Meta.collection._name, 'Posts'
  test.equal Post.Meta.generators.subdocument.slug.targetDocument.Meta.collection._name, 'Posts'
  test.equal Post.Meta.generators.subdocument.slug.fields, ['body', 'subdocument.body']
  test.isUndefined Post.Meta.generators.subdocument.slug.reverseName
  test.isUndefined Post.Meta.generators.subdocument.slug.reverseFields
  test.instanceOf Post.Meta.generators.tags, Post._GeneratedField
  test.equal Post.Meta.generators.tags.ancestorArray, 'tags'
  test.isTrue _.isFunction Post.Meta.generators.tags.generator
  test.equal Post.Meta.generators.tags.sourcePath, 'tags'
  test.equal Post.Meta.generators.tags.sourceDocument, Post
  test.equal Post.Meta.generators.tags.targetDocument, Post
  test.equal Post.Meta.generators.tags.sourceCollection._name, 'Posts'
  test.equal Post.Meta.generators.tags.targetCollection._name, 'Posts'
  test.equal Post.Meta.generators.tags.sourceDocument.Meta.collection._name, 'Posts'
  test.equal Post.Meta.generators.tags.targetDocument.Meta.collection._name, 'Posts'
  test.equal Post.Meta.generators.tags.fields, ['body', 'subdocument.body', 'nested.body']
  test.isUndefined Post.Meta.generators.tags.reverseName
  test.isUndefined Post.Meta.generators.tags.reverseFields
  test.equal _.size(Post.Meta.fields), 6
  test.instanceOf Post.Meta.fields.author, Post._ReferenceField
  test.isNull Post.Meta.fields.author.ancestorArray, Post.Meta.fields.author.ancestorArray
  test.isTrue Post.Meta.fields.author.required
  test.equal Post.Meta.fields.author.sourcePath, 'author'
  test.equal Post.Meta.fields.author.sourceDocument, Post
  test.equal Post.Meta.fields.author.targetDocument, Person
  test.equal Post.Meta.fields.author.sourceCollection._name, 'Posts'
  test.equal Post.Meta.fields.author.targetCollection._name, 'Persons'
  test.equal Post.Meta.fields.author.sourceDocument.Meta.collection._name, 'Posts'
  test.equal Post.Meta.fields.author.targetDocument.Meta.collection._name, 'Persons'
  test.equal Post.Meta.fields.author.fields, ['username', 'displayName', 'field1', 'field2']
  test.equal Post.Meta.fields.author.reverseName, 'posts'
  test.equal Post.Meta.fields.author.reverseFields, ['body', 'subdocument.body', 'nested.body']
  test.instanceOf Post.Meta.fields.subscribers, Post._ReferenceField
  test.equal Post.Meta.fields.subscribers.ancestorArray, 'subscribers'
  test.isTrue Post.Meta.fields.subscribers.required
  test.equal Post.Meta.fields.subscribers.sourcePath, 'subscribers'
  test.equal Post.Meta.fields.subscribers.sourceDocument, Post
  test.equal Post.Meta.fields.subscribers.targetDocument, Person
  test.equal Post.Meta.fields.subscribers.sourceCollection._name, 'Posts'
  test.equal Post.Meta.fields.subscribers.targetCollection._name, 'Persons'
  test.equal Post.Meta.fields.subscribers.sourceDocument.Meta.collection._name, 'Posts'
  test.equal Post.Meta.fields.subscribers.targetDocument.Meta.collection._name, 'Persons'
  test.equal Post.Meta.fields.subscribers.fields, []
  test.isNull Post.Meta.fields.subscribers.reverseName
  test.equal Post.Meta.fields.subscribers.reverseFields, []
  test.instanceOf Post.Meta.fields.reviewers, Post._ReferenceField
  test.equal Post.Meta.fields.reviewers.ancestorArray, 'reviewers'
  test.isTrue Post.Meta.fields.reviewers.required
  test.equal Post.Meta.fields.reviewers.sourcePath, 'reviewers'
  test.equal Post.Meta.fields.reviewers.sourceDocument, Post
  test.equal Post.Meta.fields.reviewers.targetDocument, Person
  test.equal Post.Meta.fields.reviewers.sourceCollection._name, 'Posts'
  test.equal Post.Meta.fields.reviewers.targetCollection._name, 'Persons'
  test.equal Post.Meta.fields.reviewers.sourceDocument.Meta.collection._name, 'Posts'
  test.equal Post.Meta.fields.reviewers.targetDocument.Meta.collection._name, 'Persons'
  test.equal Post.Meta.fields.reviewers.fields, [username: 1]
  test.isNull Post.Meta.fields.reviewers.reverseName
  test.equal Post.Meta.fields.reviewers.reverseFields, []
  test.equal _.size(Post.Meta.fields.subdocument), 2
  test.instanceOf Post.Meta.fields.subdocument.person, Post._ReferenceField
  test.isNull Post.Meta.fields.subdocument.person.ancestorArray, Post.Meta.fields.subdocument.person.ancestorArray
  test.isFalse Post.Meta.fields.subdocument.person.required
  test.equal Post.Meta.fields.subdocument.person.sourcePath, 'subdocument.person'
  test.equal Post.Meta.fields.subdocument.person.sourceDocument, Post
  test.equal Post.Meta.fields.subdocument.person.targetDocument, Person
  test.equal Post.Meta.fields.subdocument.person.sourceCollection._name, 'Posts'
  test.equal Post.Meta.fields.subdocument.person.targetCollection._name, 'Persons'
  test.equal Post.Meta.fields.subdocument.person.sourceDocument.Meta.collection._name, 'Posts'
  test.equal Post.Meta.fields.subdocument.person.targetDocument.Meta.collection._name, 'Persons'
  test.equal Post.Meta.fields.subdocument.person.fields, {'username': 1, 'displayName': 1, 'field1': 1, 'field2': 1}
  test.equal Post.Meta.fields.subdocument.person.reverseName, 'subdocument.posts'
  test.equal Post.Meta.fields.subdocument.person.reverseFields, ['body', 'subdocument.body', 'nested.body']
  test.instanceOf Post.Meta.fields.subdocument.persons, Post._ReferenceField
  test.equal Post.Meta.fields.subdocument.persons.ancestorArray, 'subdocument.persons'
  test.isTrue Post.Meta.fields.subdocument.persons.required
  test.equal Post.Meta.fields.subdocument.persons.sourcePath, 'subdocument.persons'
  test.equal Post.Meta.fields.subdocument.persons.sourceDocument, Post
  test.equal Post.Meta.fields.subdocument.persons.targetDocument, Person
  test.equal Post.Meta.fields.subdocument.persons.sourceCollection._name, 'Posts'
  test.equal Post.Meta.fields.subdocument.persons.targetCollection._name, 'Persons'
  test.equal Post.Meta.fields.subdocument.persons.sourceDocument.Meta.collection._name, 'Posts'
  test.equal Post.Meta.fields.subdocument.persons.targetDocument.Meta.collection._name, 'Persons'
  test.equal Post.Meta.fields.subdocument.persons.fields, ['username', 'displayName', 'field1', 'field2']
  test.equal Post.Meta.fields.subdocument.persons.reverseName, 'subdocumentsPosts'
  test.equal Post.Meta.fields.subdocument.persons.reverseFields, ['body', 'subdocument.body', 'nested.body']
  test.equal _.size(Post.Meta.fields.nested), 3
  test.instanceOf Post.Meta.fields.nested.required, Post._ReferenceField
  test.equal Post.Meta.fields.nested.required.ancestorArray, 'nested'
  test.isTrue Post.Meta.fields.nested.required.required
  test.equal Post.Meta.fields.nested.required.sourcePath, 'nested.required'
  test.equal Post.Meta.fields.nested.required.sourceDocument, Post
  test.equal Post.Meta.fields.nested.required.targetDocument, Person
  test.equal Post.Meta.fields.nested.required.sourceCollection._name, 'Posts'
  test.equal Post.Meta.fields.nested.required.targetCollection._name, 'Persons'
  test.equal Post.Meta.fields.nested.required.sourceDocument.Meta.collection._name, 'Posts'
  test.equal Post.Meta.fields.nested.required.targetDocument.Meta.collection._name, 'Persons'
  test.equal Post.Meta.fields.nested.required.fields, ['username', 'displayName', 'field1', 'field2']
  test.equal Post.Meta.fields.nested.required.reverseName, 'nestedPosts'
  test.equal Post.Meta.fields.nested.required.reverseFields, ['body', 'subdocument.body', 'nested.body']
  test.instanceOf Post.Meta.fields.nested.optional, Post._ReferenceField
  test.equal Post.Meta.fields.nested.optional.ancestorArray, 'nested'
  test.isFalse Post.Meta.fields.nested.optional.required
  test.equal Post.Meta.fields.nested.optional.sourcePath, 'nested.optional'
  test.equal Post.Meta.fields.nested.optional.sourceDocument, Post
  test.equal Post.Meta.fields.nested.optional.targetDocument, Person
  test.equal Post.Meta.fields.nested.optional.sourceCollection._name, 'Posts'
  test.equal Post.Meta.fields.nested.optional.targetCollection._name, 'Persons'
  test.equal Post.Meta.fields.nested.optional.sourceDocument.Meta.collection._name, 'Posts'
  test.equal Post.Meta.fields.nested.optional.targetDocument.Meta.collection._name, 'Persons'
  test.equal Post.Meta.fields.nested.optional.fields, ['username']
  test.isNull Post.Meta.fields.nested.optional.reverseName
  test.equal Post.Meta.fields.nested.optional.reverseFields, []
  test.instanceOf Post.Meta.fields.nested.slug, Post._GeneratedField
  test.equal Post.Meta.fields.nested.slug.ancestorArray, 'nested'
  test.isTrue _.isFunction Post.Meta.fields.nested.slug.generator
  test.equal Post.Meta.fields.nested.slug.sourcePath, 'nested.slug'
  test.equal Post.Meta.fields.nested.slug.sourceDocument, Post
  test.equal Post.Meta.fields.nested.slug.targetDocument, Post
  test.equal Post.Meta.fields.nested.slug.sourceCollection._name, 'Posts'
  test.equal Post.Meta.fields.nested.slug.targetCollection._name, 'Posts'
  test.equal Post.Meta.fields.nested.slug.sourceDocument.Meta.collection._name, 'Posts'
  test.equal Post.Meta.fields.nested.slug.targetDocument.Meta.collection._name, 'Posts'
  test.equal Post.Meta.fields.nested.slug.fields, ['body', 'nested.body']
  test.isUndefined Post.Meta.fields.nested.slug.reverseName
  test.isUndefined Post.Meta.fields.nested.slug.reverseFields
  test.instanceOf Post.Meta.fields.slug, Post._GeneratedField
  test.isNull Post.Meta.fields.slug.ancestorArray, Post.Meta.fields.slug.ancestorArray
  test.isTrue _.isFunction Post.Meta.fields.slug.generator
  test.equal Post.Meta.fields.slug.sourcePath, 'slug'
  test.equal Post.Meta.fields.slug.sourceDocument, Post
  test.equal Post.Meta.fields.slug.targetDocument, Post
  test.equal Post.Meta.fields.slug.sourceCollection._name, 'Posts'
  test.equal Post.Meta.fields.slug.targetCollection._name, 'Posts'
  test.equal Post.Meta.fields.slug.sourceDocument.Meta.collection._name, 'Posts'
  test.equal Post.Meta.fields.slug.targetDocument.Meta.collection._name, 'Posts'
  test.equal Post.Meta.fields.slug.fields, ['body', 'subdocument.body']
  test.isUndefined Post.Meta.fields.slug.reverseName
  test.isUndefined Post.Meta.fields.slug.reverseFields
  test.isTrue Post.Meta._observersSetup

  test.equal User.Meta._name, 'User'
  test.isFalse User.Meta.parent
  test.equal User.Meta.document, User
  test.equal User.Meta.collection._name, 'users'
  test.equal _.size(User.Meta.triggers), 0
  test.equal _.size(User.Meta.fields), 0
  test.isTrue User.Meta._observersSetup

  test.equal UserLink.Meta._name, 'UserLink'
  test.isFalse UserLink.Meta.parent
  test.equal UserLink.Meta.document, UserLink
  test.equal UserLink.Meta.collection._name, 'UserLinks'
  test.equal _.size(UserLink.Meta.triggers), 0
  test.equal _.size(UserLink.Meta.fields), 1
  test.instanceOf UserLink.Meta.fields.user, UserLink._ReferenceField
  test.isNull UserLink.Meta.fields.user.ancestorArray, UserLink.Meta.fields.user.ancestorArray
  test.isFalse UserLink.Meta.fields.user.required
  test.equal UserLink.Meta.fields.user.sourcePath, 'user'
  test.equal UserLink.Meta.fields.user.sourceDocument, UserLink
  test.equal UserLink.Meta.fields.user.targetDocument, User
  test.equal UserLink.Meta.fields.user.sourceCollection._name, 'UserLinks'
  test.equal UserLink.Meta.fields.user.targetCollection._name, 'users'
  test.equal UserLink.Meta.fields.user.sourceDocument.Meta.collection._name, 'UserLinks'
  test.equal UserLink.Meta.fields.user.fields, ['username']
  test.isNull UserLink.Meta.fields.user.reverseName
  test.equal UserLink.Meta.fields.user.reverseFields, []
  test.isTrue UserLink.Meta._observersSetup

  test.equal PostLink.Meta._name, 'PostLink'
  test.equal PostLink.Meta.parent, _TestPostLink.Meta
  test.equal PostLink.Meta.document, PostLink
  test.equal PostLink.Meta.collection._name, 'PostLinks'
  test.equal _.size(PostLink.Meta.triggers), 0
  test.equal _.size(PostLink.Meta.fields), 1
  test.instanceOf PostLink.Meta.fields.post, PostLink._ReferenceField
  test.isNull PostLink.Meta.fields.post.ancestorArray, PostLink.Meta.fields.post.ancestorArray
  test.isTrue PostLink.Meta.fields.post.required
  test.equal PostLink.Meta.fields.post.sourcePath, 'post'
  test.equal PostLink.Meta.fields.post.sourceDocument, PostLink
  test.equal PostLink.Meta.fields.post.targetDocument, Post
  test.equal PostLink.Meta.fields.post.sourceCollection._name, 'PostLinks'
  test.equal PostLink.Meta.fields.post.targetCollection._name, 'Posts'
  test.equal PostLink.Meta.fields.post.sourceDocument.Meta.collection._name, 'PostLinks'
  test.equal PostLink.Meta.fields.post.fields, ['subdocument.person', 'subdocument.persons']
  test.isNull PostLink.Meta.fields.post.reverseName
  test.equal PostLink.Meta.fields.post.reverseFields, []
  test.isTrue PostLink.Meta._observersSetup

  test.equal CircularFirst.Meta._name, 'CircularFirst'
  test.equal CircularFirst.Meta.parent, _TestCircularFirst.Meta
  test.equal CircularFirst.Meta.document, CircularFirst
  test.equal CircularFirst.Meta.collection._name, 'CircularFirsts'
  test.equal _.size(CircularFirst.Meta.triggers), 0
  test.equal _.size(CircularFirst.Meta.fields), 2
  test.instanceOf CircularFirst.Meta.fields.second, CircularFirst._ReferenceField
  test.isNull CircularFirst.Meta.fields.second.ancestorArray, CircularFirst.Meta.fields.second.ancestorArray
  test.isTrue CircularFirst.Meta.fields.second.required
  test.equal CircularFirst.Meta.fields.second.sourcePath, 'second'
  test.equal CircularFirst.Meta.fields.second.sourceDocument, CircularFirst
  test.equal CircularFirst.Meta.fields.second.targetDocument, CircularSecond
  test.equal CircularFirst.Meta.fields.second.sourceCollection._name, 'CircularFirsts'
  test.equal CircularFirst.Meta.fields.second.targetCollection._name, 'CircularSeconds'
  test.equal CircularFirst.Meta.fields.second.sourceDocument.Meta.collection._name, 'CircularFirsts'
  test.equal CircularFirst.Meta.fields.second.targetDocument.Meta.collection._name, 'CircularSeconds'
  test.equal CircularFirst.Meta.fields.second.fields, ['content']
  test.equal CircularFirst.Meta.fields.second.reverseName, 'reverseFirsts'
  test.equal CircularFirst.Meta.fields.second.reverseFields, ['content']
  test.instanceOf CircularFirst.Meta.fields.reverseSeconds, CircularFirst._ReferenceField
  test.equal CircularFirst.Meta.fields.reverseSeconds.ancestorArray, 'reverseSeconds'
  test.isTrue CircularFirst.Meta.fields.reverseSeconds.required
  test.equal CircularFirst.Meta.fields.reverseSeconds.sourcePath, 'reverseSeconds'
  test.equal CircularFirst.Meta.fields.reverseSeconds.sourceDocument, CircularFirst
  test.equal CircularFirst.Meta.fields.reverseSeconds.targetDocument, CircularSecond
  test.equal CircularFirst.Meta.fields.reverseSeconds.sourceCollection._name, 'CircularFirsts'
  test.equal CircularFirst.Meta.fields.reverseSeconds.targetCollection._name, 'CircularSeconds'
  test.equal CircularFirst.Meta.fields.reverseSeconds.sourceDocument.Meta.collection._name, 'CircularFirsts'
  test.equal CircularFirst.Meta.fields.reverseSeconds.targetDocument.Meta.collection._name, 'CircularSeconds'
  test.equal CircularFirst.Meta.fields.reverseSeconds.fields, ['content']
  test.isNull CircularFirst.Meta.fields.reverseSeconds.reverseName
  test.equal CircularFirst.Meta.fields.reverseSeconds.reverseFields, []
  test.isTrue CircularFirst.Meta._observersSetup

  test.equal CircularSecond.Meta._name, 'CircularSecond'
  test.isFalse CircularSecond.Meta.parent
  test.equal CircularSecond.Meta.document, CircularSecond
  test.equal CircularSecond.Meta.collection._name, 'CircularSeconds'
  test.equal _.size(CircularSecond.Meta.triggers), 0
  test.equal _.size(CircularSecond.Meta.fields), 2
  test.instanceOf CircularSecond.Meta.fields.first, CircularSecond._ReferenceField
  test.isNull CircularSecond.Meta.fields.first.ancestorArray, CircularSecond.Meta.fields.first.ancestorArray
  test.isFalse CircularSecond.Meta.fields.first.required
  test.equal CircularSecond.Meta.fields.first.sourcePath, 'first'
  test.equal CircularSecond.Meta.fields.first.sourceDocument, CircularSecond
  test.equal CircularSecond.Meta.fields.first.targetDocument, CircularFirst
  test.equal CircularSecond.Meta.fields.first.sourceCollection._name, 'CircularSeconds'
  test.equal CircularSecond.Meta.fields.first.targetCollection._name, 'CircularFirsts'
  test.equal CircularSecond.Meta.fields.first.sourceDocument.Meta.collection._name, 'CircularSeconds'
  test.equal CircularSecond.Meta.fields.first.targetDocument.Meta.collection._name, 'CircularFirsts'
  test.equal CircularSecond.Meta.fields.first.fields, ['content']
  test.equal CircularSecond.Meta.fields.first.reverseName, 'reverseSeconds'
  test.equal CircularSecond.Meta.fields.first.reverseFields, ['content']
  test.instanceOf CircularSecond.Meta.fields.reverseFirsts, CircularSecond._ReferenceField
  test.equal CircularSecond.Meta.fields.reverseFirsts.ancestorArray, 'reverseFirsts'
  test.isTrue CircularSecond.Meta.fields.reverseFirsts.required
  test.equal CircularSecond.Meta.fields.reverseFirsts.sourcePath, 'reverseFirsts'
  test.equal CircularSecond.Meta.fields.reverseFirsts.sourceDocument, CircularSecond
  test.equal CircularSecond.Meta.fields.reverseFirsts.targetDocument, CircularFirst
  test.equal CircularSecond.Meta.fields.reverseFirsts.sourceCollection._name, 'CircularSeconds'
  test.equal CircularSecond.Meta.fields.reverseFirsts.targetCollection._name, 'CircularFirsts'
  test.equal CircularSecond.Meta.fields.reverseFirsts.sourceDocument.Meta.collection._name, 'CircularSeconds'
  test.equal CircularSecond.Meta.fields.reverseFirsts.targetDocument.Meta.collection._name, 'CircularFirsts'
  test.equal CircularSecond.Meta.fields.reverseFirsts.fields, ['content']
  test.isNull CircularSecond.Meta.fields.reverseFirsts.reverseName
  test.equal CircularSecond.Meta.fields.reverseFirsts.reverseFields, []
  test.isTrue CircularSecond.Meta._observersSetup

  test.equal Person.Meta._name, 'Person'
  test.equal Person.Meta.parent, _TestPerson.Meta
  test.equal Person.Meta.document, Person
  test.equal Person.Meta.collection._name, 'Persons'
  test.equal _.size(Person.Meta.triggers), 0
  test.equal _.size(Person.Meta.generators), 1
  test.instanceOf Person.Meta.generators.count, Person._GeneratedField
  test.isNull Person.Meta.generators.count.ancestorArray, Person.Meta.generators.count.ancestorArray
  test.isTrue _.isFunction Person.Meta.generators.count.generator
  test.equal Person.Meta.generators.count.sourcePath, 'count'
  test.equal Person.Meta.generators.count.sourceDocument, Person
  test.equal Person.Meta.generators.count.targetDocument, Person
  test.equal Person.Meta.generators.count.sourceCollection._name, 'Persons'
  test.equal Person.Meta.generators.count.targetCollection._name, 'Persons'
  test.equal Person.Meta.generators.count.sourceDocument.Meta.collection._name, 'Persons'
  test.equal Person.Meta.generators.count.targetDocument.Meta.collection._name, 'Persons'
  test.equal Person.Meta.generators.count.fields, ['posts', 'subdocument.posts', 'subdocumentsPosts', 'nestedPosts']
  test.isUndefined Person.Meta.generators.count.reverseName
  test.isUndefined Person.Meta.generators.count.reverseFields
  test.equal _.size(Person.Meta.fields), 4
  test.instanceOf Person.Meta.fields.posts, Person._ReferenceField
  test.equal Person.Meta.fields.posts.ancestorArray, 'posts'
  test.isTrue Person.Meta.fields.posts.required
  test.equal Person.Meta.fields.posts.sourcePath, 'posts'
  test.equal Person.Meta.fields.posts.sourceDocument, Person
  test.equal Person.Meta.fields.posts.targetDocument, Post
  test.equal Person.Meta.fields.posts.sourceCollection._name, 'Persons'
  test.equal Person.Meta.fields.posts.targetCollection._name, 'Posts'
  test.equal Person.Meta.fields.posts.sourceDocument.Meta.collection._name, 'Persons'
  test.equal Person.Meta.fields.posts.targetDocument.Meta.collection._name, 'Posts'
  test.equal Person.Meta.fields.posts.fields, ['body', 'subdocument.body', 'nested.body']
  test.isNull Person.Meta.fields.posts.reverseName
  test.equal Person.Meta.fields.posts.reverseFields, []
  test.instanceOf Person.Meta.fields.nestedPosts, Person._ReferenceField
  test.equal Person.Meta.fields.nestedPosts.ancestorArray, 'nestedPosts'
  test.isTrue Person.Meta.fields.nestedPosts.required
  test.equal Person.Meta.fields.nestedPosts.sourcePath, 'nestedPosts'
  test.equal Person.Meta.fields.nestedPosts.sourceDocument, Person
  test.equal Person.Meta.fields.nestedPosts.targetDocument, Post
  test.equal Person.Meta.fields.nestedPosts.sourceCollection._name, 'Persons'
  test.equal Person.Meta.fields.nestedPosts.targetCollection._name, 'Posts'
  test.equal Person.Meta.fields.nestedPosts.sourceDocument.Meta.collection._name, 'Persons'
  test.equal Person.Meta.fields.nestedPosts.targetDocument.Meta.collection._name, 'Posts'
  test.equal Person.Meta.fields.nestedPosts.fields, ['body', 'subdocument.body', 'nested.body']
  test.isNull Person.Meta.fields.nestedPosts.reverseName
  test.equal Person.Meta.fields.nestedPosts.reverseFields, []
  test.instanceOf Person.Meta.fields.subdocument.posts, Person._ReferenceField
  test.equal Person.Meta.fields.subdocument.posts.ancestorArray, 'subdocument.posts'
  test.isTrue Person.Meta.fields.subdocument.posts.required
  test.equal Person.Meta.fields.subdocument.posts.sourcePath, 'subdocument.posts'
  test.equal Person.Meta.fields.subdocument.posts.sourceDocument, Person
  test.equal Person.Meta.fields.subdocument.posts.targetDocument, Post
  test.equal Person.Meta.fields.subdocument.posts.sourceCollection._name, 'Persons'
  test.equal Person.Meta.fields.subdocument.posts.targetCollection._name, 'Posts'
  test.equal Person.Meta.fields.subdocument.posts.sourceDocument.Meta.collection._name, 'Persons'
  test.equal Person.Meta.fields.subdocument.posts.targetDocument.Meta.collection._name, 'Posts'
  test.equal Person.Meta.fields.subdocument.posts.fields, ['body', 'subdocument.body', 'nested.body']
  test.isNull Person.Meta.fields.subdocument.posts.reverseName
  test.equal Person.Meta.fields.subdocument.posts.reverseFields, []
  test.instanceOf Person.Meta.fields.subdocumentsPosts, Person._ReferenceField
  test.equal Person.Meta.fields.subdocumentsPosts.ancestorArray, 'subdocumentsPosts'
  test.isTrue Person.Meta.fields.subdocumentsPosts.required
  test.equal Person.Meta.fields.subdocumentsPosts.sourcePath, 'subdocumentsPosts'
  test.equal Person.Meta.fields.subdocumentsPosts.sourceDocument, Person
  test.equal Person.Meta.fields.subdocumentsPosts.targetDocument, Post
  test.equal Person.Meta.fields.subdocumentsPosts.sourceCollection._name, 'Persons'
  test.equal Person.Meta.fields.subdocumentsPosts.targetCollection._name, 'Posts'
  test.equal Person.Meta.fields.subdocumentsPosts.sourceDocument.Meta.collection._name, 'Persons'
  test.equal Person.Meta.fields.subdocumentsPosts.targetDocument.Meta.collection._name, 'Posts'
  test.equal Person.Meta.fields.subdocumentsPosts.fields, ['body', 'subdocument.body', 'nested.body']
  test.isNull Person.Meta.fields.subdocumentsPosts.reverseName
  test.equal Person.Meta.fields.subdocumentsPosts.reverseFields, []
  test.isTrue Person.Meta._observersSetup

  test.equal SpecialPerson.Meta._name, 'SpecialPerson'
  test.equal SpecialPerson.Meta.parent, Person.Meta
  test.equal SpecialPerson.Meta.document, SpecialPerson
  test.equal SpecialPerson.Meta._name, 'SpecialPerson'
  test.equal SpecialPerson.Meta.collection._name, 'SpecialPersons'
  test.equal _.size(SpecialPerson.Meta.triggers), 0
  test.equal _.size(SpecialPerson.Meta.fields), 0
  test.isTrue SpecialPerson.Meta._observersSetup

  test.equal Recursive.Meta._name, 'Recursive'
  test.isFalse Recursive.Meta.parent
  test.equal Recursive.Meta.document, Recursive
  test.equal Recursive.Meta.collection._name, 'Recursives'
  test.equal _.size(Recursive.Meta.triggers), 0
  test.equal _.size(Recursive.Meta.fields), 2
  test.instanceOf Recursive.Meta.fields.other, Recursive._ReferenceField
  test.isNull Recursive.Meta.fields.other.ancestorArray, Recursive.Meta.fields.other.ancestorArray
  test.isFalse Recursive.Meta.fields.other.required
  test.equal Recursive.Meta.fields.other.sourcePath, 'other'
  test.equal Recursive.Meta.fields.other.sourceDocument, Recursive
  test.equal Recursive.Meta.fields.other.targetDocument, Recursive
  test.equal Recursive.Meta.fields.other.sourceCollection._name, 'Recursives'
  test.equal Recursive.Meta.fields.other.targetCollection._name, 'Recursives'
  test.equal Recursive.Meta.fields.other.sourceDocument.Meta.collection._name, 'Recursives'
  test.equal Recursive.Meta.fields.other.targetDocument.Meta.collection._name, 'Recursives'
  test.equal Recursive.Meta.fields.other.fields, ['content']
  test.equal Recursive.Meta.fields.other.reverseName, 'reverse'
  test.equal Recursive.Meta.fields.other.reverseFields, ['content']
  test.instanceOf Recursive.Meta.fields.reverse, Recursive._ReferenceField
  test.equal Recursive.Meta.fields.reverse.ancestorArray, 'reverse'
  test.isTrue Recursive.Meta.fields.reverse.required
  test.equal Recursive.Meta.fields.reverse.sourcePath, 'reverse'
  test.equal Recursive.Meta.fields.reverse.sourceDocument, Recursive
  test.equal Recursive.Meta.fields.reverse.targetDocument, Recursive
  test.equal Recursive.Meta.fields.reverse.sourceCollection._name, 'Recursives'
  test.equal Recursive.Meta.fields.reverse.targetCollection._name, 'Recursives'
  test.equal Recursive.Meta.fields.reverse.sourceDocument.Meta.collection._name, 'Recursives'
  test.equal Recursive.Meta.fields.reverse.targetDocument.Meta.collection._name, 'Recursives'
  test.equal Recursive.Meta.fields.reverse.fields, ['content']
  test.isNull Recursive.Meta.fields.reverse.reverseName
  test.equal Recursive.Meta.fields.reverse.reverseFields, []
  test.isTrue Recursive.Meta._observersSetup

  test.equal IdentityGenerator.Meta._name, 'IdentityGenerator'
  test.isFalse IdentityGenerator.Meta.parent
  test.equal IdentityGenerator.Meta.document, IdentityGenerator
  test.equal IdentityGenerator.Meta.collection._name, 'IdentityGenerators'
  test.equal _.size(IdentityGenerator.Meta.triggers), 0
  test.equal _.size(IdentityGenerator.Meta.generators), 2
  test.instanceOf IdentityGenerator.Meta.generators.result, IdentityGenerator._GeneratedField
  test.isNull IdentityGenerator.Meta.generators.result.ancestorArray, IdentityGenerator.Meta.generators.result.ancestorArray
  test.isTrue _.isFunction IdentityGenerator.Meta.generators.result.generator
  test.equal IdentityGenerator.Meta.generators.result.sourcePath, 'result'
  test.equal IdentityGenerator.Meta.generators.result.sourceDocument, IdentityGenerator
  test.equal IdentityGenerator.Meta.generators.result.targetDocument, IdentityGenerator
  test.equal IdentityGenerator.Meta.generators.result.sourceCollection._name, 'IdentityGenerators'
  test.equal IdentityGenerator.Meta.generators.result.targetCollection._name, 'IdentityGenerators'
  test.equal IdentityGenerator.Meta.generators.result.sourceDocument.Meta.collection._name, 'IdentityGenerators'
  test.equal IdentityGenerator.Meta.generators.result.targetDocument.Meta.collection._name, 'IdentityGenerators'
  test.equal IdentityGenerator.Meta.generators.result.fields, ['source']
  test.isUndefined IdentityGenerator.Meta.generators.result.reverseName
  test.isUndefined IdentityGenerator.Meta.generators.result.reverseFields
  test.instanceOf IdentityGenerator.Meta.generators.results, IdentityGenerator._GeneratedField
  test.equal IdentityGenerator.Meta.generators.results.ancestorArray, 'results'
  test.isTrue _.isFunction IdentityGenerator.Meta.generators.results.generator
  test.equal IdentityGenerator.Meta.generators.results.sourcePath, 'results'
  test.equal IdentityGenerator.Meta.generators.results.sourceDocument, IdentityGenerator
  test.equal IdentityGenerator.Meta.generators.results.targetDocument, IdentityGenerator
  test.equal IdentityGenerator.Meta.generators.results.sourceCollection._name, 'IdentityGenerators'
  test.equal IdentityGenerator.Meta.generators.results.targetCollection._name, 'IdentityGenerators'
  test.equal IdentityGenerator.Meta.generators.results.sourceDocument.Meta.collection._name, 'IdentityGenerators'
  test.equal IdentityGenerator.Meta.generators.results.targetDocument.Meta.collection._name, 'IdentityGenerators'
  test.equal IdentityGenerator.Meta.generators.results.fields, ['source']
  test.isUndefined IdentityGenerator.Meta.generators.results.reverseName
  test.isUndefined IdentityGenerator.Meta.generators.results.reverseFields
  test.equal _.size(IdentityGenerator.Meta.fields), 0
  test.isTrue IdentityGenerator.Meta._observersSetup

  test.equal SpecialPost.Meta._name, 'SpecialPost'
  test.equal SpecialPost.Meta.parent, _TestPost2.Meta
  test.equal SpecialPost.Meta.document, SpecialPost
  test.equal SpecialPost.Meta.collection._name, 'SpecialPosts'
  test.equal _.size(SpecialPost.Meta.triggers), 1
  test.instanceOf SpecialPost.Meta.triggers.testTrigger, SpecialPost._Trigger
  test.equal SpecialPost.Meta.triggers.testTrigger.name, 'testTrigger'
  test.equal SpecialPost.Meta.triggers.testTrigger.document, SpecialPost
  test.equal SpecialPost.Meta.triggers.testTrigger.collection._name, 'SpecialPosts'
  test.equal SpecialPost.Meta.triggers.testTrigger.fields, ['body']
  test.equal _.size(SpecialPost.Meta.generators), 2
  test.equal _.size(SpecialPost.Meta.generators.subdocument), 1
  test.instanceOf SpecialPost.Meta.generators.subdocument.slug, SpecialPost._GeneratedField
  test.isNull SpecialPost.Meta.generators.subdocument.slug.ancestorArray, SpecialPost.Meta.generators.subdocument.slug.ancestorArray
  test.isTrue _.isFunction SpecialPost.Meta.generators.subdocument.slug.generator
  test.equal SpecialPost.Meta.generators.subdocument.slug.sourcePath, 'subdocument.slug'
  test.equal SpecialPost.Meta.generators.subdocument.slug.sourceDocument, SpecialPost
  test.equal SpecialPost.Meta.generators.subdocument.slug.targetDocument, SpecialPost
  test.equal SpecialPost.Meta.generators.subdocument.slug.sourceCollection._name, 'SpecialPosts'
  test.equal SpecialPost.Meta.generators.subdocument.slug.targetCollection._name, 'SpecialPosts'
  test.equal SpecialPost.Meta.generators.subdocument.slug.sourceDocument.Meta.collection._name, 'SpecialPosts'
  test.equal SpecialPost.Meta.generators.subdocument.slug.targetDocument.Meta.collection._name, 'SpecialPosts'
  test.equal SpecialPost.Meta.generators.subdocument.slug.fields, ['body', 'subdocument.body']
  test.isUndefined SpecialPost.Meta.generators.subdocument.slug.reverseName
  test.isUndefined SpecialPost.Meta.generators.subdocument.slug.reverseFields
  test.instanceOf SpecialPost.Meta.generators.tags, SpecialPost._GeneratedField
  test.equal SpecialPost.Meta.generators.tags.ancestorArray, 'tags'
  test.isTrue _.isFunction SpecialPost.Meta.generators.tags.generator
  test.equal SpecialPost.Meta.generators.tags.sourcePath, 'tags'
  test.equal SpecialPost.Meta.generators.tags.sourceDocument, SpecialPost
  test.equal SpecialPost.Meta.generators.tags.targetDocument, SpecialPost
  test.equal SpecialPost.Meta.generators.tags.sourceCollection._name, 'SpecialPosts'
  test.equal SpecialPost.Meta.generators.tags.targetCollection._name, 'SpecialPosts'
  test.equal SpecialPost.Meta.generators.tags.sourceDocument.Meta.collection._name, 'SpecialPosts'
  test.equal SpecialPost.Meta.generators.tags.targetDocument.Meta.collection._name, 'SpecialPosts'
  test.equal SpecialPost.Meta.generators.tags.fields, ['body', 'subdocument.body', 'nested.body']
  test.isUndefined SpecialPost.Meta.generators.tags.reverseName
  test.isUndefined SpecialPost.Meta.generators.tags.reverseFields
  test.equal _.size(SpecialPost.Meta.fields), 7
  test.instanceOf SpecialPost.Meta.fields.author, SpecialPost._ReferenceField
  test.isNull SpecialPost.Meta.fields.author.ancestorArray, SpecialPost.Meta.fields.author.ancestorArray
  test.isTrue SpecialPost.Meta.fields.author.required
  test.equal SpecialPost.Meta.fields.author.sourcePath, 'author'
  test.equal SpecialPost.Meta.fields.author.sourceDocument, SpecialPost
  test.equal SpecialPost.Meta.fields.author.targetDocument, Person
  test.equal SpecialPost.Meta.fields.author.sourceCollection._name, 'SpecialPosts'
  test.equal SpecialPost.Meta.fields.author.targetCollection._name, 'Persons'
  test.equal SpecialPost.Meta.fields.author.sourceDocument.Meta.collection._name, 'SpecialPosts'
  test.equal SpecialPost.Meta.fields.author.targetDocument.Meta.collection._name, 'Persons'
  test.equal SpecialPost.Meta.fields.author.fields, ['username', 'displayName', 'field1', 'field2']
  test.equal SpecialPost.Meta.fields.author.reverseName, 'posts'
  test.equal SpecialPost.Meta.fields.author.reverseFields, ['body', 'subdocument.body', 'nested.body']
  test.instanceOf SpecialPost.Meta.fields.subscribers, SpecialPost._ReferenceField
  test.equal SpecialPost.Meta.fields.subscribers.ancestorArray, 'subscribers'
  test.isTrue SpecialPost.Meta.fields.subscribers.required
  test.equal SpecialPost.Meta.fields.subscribers.sourcePath, 'subscribers'
  test.equal SpecialPost.Meta.fields.subscribers.sourceDocument, SpecialPost
  test.equal SpecialPost.Meta.fields.subscribers.targetDocument, Person
  test.equal SpecialPost.Meta.fields.subscribers.sourceCollection._name, 'SpecialPosts'
  test.equal SpecialPost.Meta.fields.subscribers.targetCollection._name, 'Persons'
  test.equal SpecialPost.Meta.fields.subscribers.sourceDocument.Meta.collection._name, 'SpecialPosts'
  test.equal SpecialPost.Meta.fields.subscribers.targetDocument.Meta.collection._name, 'Persons'
  test.equal SpecialPost.Meta.fields.subscribers.fields, []
  test.isNull SpecialPost.Meta.fields.subscribers.reverseName
  test.equal SpecialPost.Meta.fields.subscribers.reverseFields, []
  test.instanceOf SpecialPost.Meta.fields.reviewers, SpecialPost._ReferenceField
  test.equal SpecialPost.Meta.fields.reviewers.ancestorArray, 'reviewers'
  test.isTrue SpecialPost.Meta.fields.reviewers.required
  test.equal SpecialPost.Meta.fields.reviewers.sourcePath, 'reviewers'
  test.equal SpecialPost.Meta.fields.reviewers.sourceDocument, SpecialPost
  test.equal SpecialPost.Meta.fields.reviewers.targetDocument, Person
  test.equal SpecialPost.Meta.fields.reviewers.sourceCollection._name, 'SpecialPosts'
  test.equal SpecialPost.Meta.fields.reviewers.targetCollection._name, 'Persons'
  test.equal SpecialPost.Meta.fields.reviewers.sourceDocument.Meta.collection._name, 'SpecialPosts'
  test.equal SpecialPost.Meta.fields.reviewers.targetDocument.Meta.collection._name, 'Persons'
  test.equal SpecialPost.Meta.fields.reviewers.fields, [username: 1]
  test.isNull SpecialPost.Meta.fields.reviewers.reverseName
  test.equal SpecialPost.Meta.fields.reviewers.reverseFields, []
  test.equal _.size(SpecialPost.Meta.fields.subdocument), 2
  test.instanceOf SpecialPost.Meta.fields.subdocument.person, SpecialPost._ReferenceField
  test.isNull SpecialPost.Meta.fields.subdocument.person.ancestorArray, SpecialPost.Meta.fields.subdocument.person.ancestorArray
  test.isFalse SpecialPost.Meta.fields.subdocument.person.required
  test.equal SpecialPost.Meta.fields.subdocument.person.sourcePath, 'subdocument.person'
  test.equal SpecialPost.Meta.fields.subdocument.person.sourceDocument, SpecialPost
  test.equal SpecialPost.Meta.fields.subdocument.person.targetDocument, Person
  test.equal SpecialPost.Meta.fields.subdocument.person.sourceCollection._name, 'SpecialPosts'
  test.equal SpecialPost.Meta.fields.subdocument.person.targetCollection._name, 'Persons'
  test.equal SpecialPost.Meta.fields.subdocument.person.sourceDocument.Meta.collection._name, 'SpecialPosts'
  test.equal SpecialPost.Meta.fields.subdocument.person.targetDocument.Meta.collection._name, 'Persons'
  test.equal SpecialPost.Meta.fields.subdocument.person.fields, {'username': 1, 'displayName': 1, 'field1': 1, 'field2': 1}
  test.equal SpecialPost.Meta.fields.subdocument.person.reverseName, 'subdocument.posts'
  test.equal SpecialPost.Meta.fields.subdocument.person.reverseFields, ['body', 'subdocument.body', 'nested.body']
  test.instanceOf SpecialPost.Meta.fields.subdocument.persons, SpecialPost._ReferenceField
  test.equal SpecialPost.Meta.fields.subdocument.persons.ancestorArray, 'subdocument.persons'
  test.isTrue SpecialPost.Meta.fields.subdocument.persons.required
  test.equal SpecialPost.Meta.fields.subdocument.persons.sourcePath, 'subdocument.persons'
  test.equal SpecialPost.Meta.fields.subdocument.persons.sourceDocument, SpecialPost
  test.equal SpecialPost.Meta.fields.subdocument.persons.targetDocument, Person
  test.equal SpecialPost.Meta.fields.subdocument.persons.sourceCollection._name, 'SpecialPosts'
  test.equal SpecialPost.Meta.fields.subdocument.persons.targetCollection._name, 'Persons'
  test.equal SpecialPost.Meta.fields.subdocument.persons.sourceDocument.Meta.collection._name, 'SpecialPosts'
  test.equal SpecialPost.Meta.fields.subdocument.persons.targetDocument.Meta.collection._name, 'Persons'
  test.equal SpecialPost.Meta.fields.subdocument.persons.fields, ['username', 'displayName', 'field1', 'field2']
  test.equal SpecialPost.Meta.fields.subdocument.persons.reverseName, 'subdocumentsPosts'
  test.equal SpecialPost.Meta.fields.subdocument.persons.reverseFields, ['body', 'subdocument.body', 'nested.body']
  test.equal _.size(SpecialPost.Meta.fields.nested), 3
  test.instanceOf SpecialPost.Meta.fields.nested.required, SpecialPost._ReferenceField
  test.equal SpecialPost.Meta.fields.nested.required.ancestorArray, 'nested'
  test.isTrue SpecialPost.Meta.fields.nested.required.required
  test.equal SpecialPost.Meta.fields.nested.required.sourcePath, 'nested.required'
  test.equal SpecialPost.Meta.fields.nested.required.sourceDocument, SpecialPost
  test.equal SpecialPost.Meta.fields.nested.required.targetDocument, Person
  test.equal SpecialPost.Meta.fields.nested.required.sourceCollection._name, 'SpecialPosts'
  test.equal SpecialPost.Meta.fields.nested.required.targetCollection._name, 'Persons'
  test.equal SpecialPost.Meta.fields.nested.required.sourceDocument.Meta.collection._name, 'SpecialPosts'
  test.equal SpecialPost.Meta.fields.nested.required.targetDocument.Meta.collection._name, 'Persons'
  test.equal SpecialPost.Meta.fields.nested.required.fields, ['username', 'displayName', 'field1', 'field2']
  test.equal SpecialPost.Meta.fields.nested.required.reverseName, 'nestedPosts'
  test.equal SpecialPost.Meta.fields.nested.required.reverseFields, ['body', 'subdocument.body', 'nested.body']
  test.instanceOf SpecialPost.Meta.fields.nested.optional, SpecialPost._ReferenceField
  test.equal SpecialPost.Meta.fields.nested.optional.ancestorArray, 'nested'
  test.isFalse SpecialPost.Meta.fields.nested.optional.required
  test.equal SpecialPost.Meta.fields.nested.optional.sourcePath, 'nested.optional'
  test.equal SpecialPost.Meta.fields.nested.optional.sourceDocument, SpecialPost
  test.equal SpecialPost.Meta.fields.nested.optional.targetDocument, Person
  test.equal SpecialPost.Meta.fields.nested.optional.sourceCollection._name, 'SpecialPosts'
  test.equal SpecialPost.Meta.fields.nested.optional.targetCollection._name, 'Persons'
  test.equal SpecialPost.Meta.fields.nested.optional.sourceDocument.Meta.collection._name, 'SpecialPosts'
  test.equal SpecialPost.Meta.fields.nested.optional.targetDocument.Meta.collection._name, 'Persons'
  test.equal SpecialPost.Meta.fields.nested.optional.fields, ['username']
  test.isNull SpecialPost.Meta.fields.nested.optional.reverseName
  test.equal SpecialPost.Meta.fields.nested.optional.reverseFields, []
  test.instanceOf SpecialPost.Meta.fields.nested.slug, SpecialPost._GeneratedField
  test.equal SpecialPost.Meta.fields.nested.slug.ancestorArray, 'nested'
  test.isTrue _.isFunction SpecialPost.Meta.fields.nested.slug.generator
  test.equal SpecialPost.Meta.fields.nested.slug.sourcePath, 'nested.slug'
  test.equal SpecialPost.Meta.fields.nested.slug.sourceDocument, SpecialPost
  test.equal SpecialPost.Meta.fields.nested.slug.targetDocument, SpecialPost
  test.equal SpecialPost.Meta.fields.nested.slug.sourceCollection._name, 'SpecialPosts'
  test.equal SpecialPost.Meta.fields.nested.slug.targetCollection._name, 'SpecialPosts'
  test.equal SpecialPost.Meta.fields.nested.slug.sourceDocument.Meta.collection._name, 'SpecialPosts'
  test.equal SpecialPost.Meta.fields.nested.slug.targetDocument.Meta.collection._name, 'SpecialPosts'
  test.equal SpecialPost.Meta.fields.nested.slug.fields, ['body', 'nested.body']
  test.isUndefined SpecialPost.Meta.fields.nested.slug.reverseName
  test.isUndefined SpecialPost.Meta.fields.nested.slug.reverseFields
  test.instanceOf SpecialPost.Meta.fields.slug, SpecialPost._GeneratedField
  test.isNull SpecialPost.Meta.fields.slug.ancestorArray, SpecialPost.Meta.fields.slug.ancestorArray
  test.isTrue _.isFunction SpecialPost.Meta.fields.slug.generator
  test.equal SpecialPost.Meta.fields.slug.sourcePath, 'slug'
  test.equal SpecialPost.Meta.fields.slug.sourceDocument, SpecialPost
  test.equal SpecialPost.Meta.fields.slug.targetDocument, SpecialPost
  test.equal SpecialPost.Meta.fields.slug.sourceCollection._name, 'SpecialPosts'
  test.equal SpecialPost.Meta.fields.slug.targetCollection._name, 'SpecialPosts'
  test.equal SpecialPost.Meta.fields.slug.sourceDocument.Meta.collection._name, 'SpecialPosts'
  test.equal SpecialPost.Meta.fields.slug.targetDocument.Meta.collection._name, 'SpecialPosts'
  test.equal SpecialPost.Meta.fields.slug.fields, ['body', 'subdocument.body']
  test.isUndefined SpecialPost.Meta.fields.slug.reverseName
  test.isUndefined SpecialPost.Meta.fields.slug.reverseFields
  test.instanceOf SpecialPost.Meta.fields.special, SpecialPost._ReferenceField
  test.isNull SpecialPost.Meta.fields.special.ancestorArray, SpecialPost.Meta.fields.special.ancestorArray
  test.isTrue SpecialPost.Meta.fields.special.required
  test.equal SpecialPost.Meta.fields.special.sourcePath, 'special'
  test.equal SpecialPost.Meta.fields.special.sourceDocument, SpecialPost
  test.equal SpecialPost.Meta.fields.special.targetDocument, Person
  test.equal SpecialPost.Meta.fields.special.sourceCollection._name, 'SpecialPosts'
  test.equal SpecialPost.Meta.fields.special.targetCollection._name, 'Persons'
  test.equal SpecialPost.Meta.fields.special.sourceDocument.Meta.collection._name, 'SpecialPosts'
  test.equal SpecialPost.Meta.fields.special.targetDocument.Meta.collection._name, 'Persons'
  test.equal SpecialPost.Meta.fields.special.fields, []
  test.isNull SpecialPost.Meta.fields.special.reverseName
  test.equal SpecialPost.Meta.fields.special.reverseFields, []
  test.isTrue SpecialPost.Meta._observersSetup

  test.equal LocalPost.Meta._name, 'LocalPost'
  test.equal LocalPost.Meta.document, LocalPost
  test.isNull LocalPost.Meta.collection._name
  test.equal _.size(LocalPost.Meta.triggers), 1
  test.instanceOf LocalPost.Meta.triggers.testTrigger, LocalPost._Trigger
  test.equal LocalPost.Meta.triggers.testTrigger.name, 'testTrigger'
  test.equal LocalPost.Meta.triggers.testTrigger.document, LocalPost
  test.isNull LocalPost.Meta.triggers.testTrigger.collection._name
  test.equal LocalPost.Meta.triggers.testTrigger.fields, ['body']
  test.equal _.size(LocalPost.Meta.fields), 7
  test.instanceOf LocalPost.Meta.fields.author, LocalPost._ReferenceField
  test.isNull LocalPost.Meta.fields.author.ancestorArray, LocalPost.Meta.fields.author.ancestorArray
  test.isTrue LocalPost.Meta.fields.author.required
  test.equal LocalPost.Meta.fields.author.sourcePath, 'author'
  test.equal LocalPost.Meta.fields.author.sourceDocument, LocalPost
  test.equal LocalPost.Meta.fields.author.targetDocument, LocalPerson
  test.isNull LocalPost.Meta.fields.author.sourceCollection._name
  test.isNull LocalPost.Meta.fields.author.targetCollection._name
  test.isNull LocalPost.Meta.fields.author.sourceDocument.Meta.collection._name
  test.isNull LocalPost.Meta.fields.author.targetDocument.Meta.collection._name
  test.equal LocalPost.Meta.fields.author.fields, ['username', 'displayName', 'field1', 'field2']
  test.equal LocalPost.Meta.fields.author.reverseName, 'posts'
  test.equal LocalPost.Meta.fields.author.reverseFields, ['body', 'subdocument.body', 'nested.body']
  test.instanceOf LocalPost.Meta.fields.subscribers, LocalPost._ReferenceField
  test.equal LocalPost.Meta.fields.subscribers.ancestorArray, 'subscribers'
  test.isTrue LocalPost.Meta.fields.subscribers.required
  test.equal LocalPost.Meta.fields.subscribers.sourcePath, 'subscribers'
  test.equal LocalPost.Meta.fields.subscribers.sourceDocument, LocalPost
  test.equal LocalPost.Meta.fields.subscribers.targetDocument, LocalPerson
  test.isNull LocalPost.Meta.fields.subscribers.sourceCollection._name
  test.isNull LocalPost.Meta.fields.subscribers.targetCollection._name
  test.isNull LocalPost.Meta.fields.subscribers.sourceDocument.Meta.collection._name
  test.isNull LocalPost.Meta.fields.subscribers.targetDocument.Meta.collection._name
  test.equal LocalPost.Meta.fields.subscribers.fields, []
  test.isNull LocalPost.Meta.fields.subscribers.reverseName
  test.equal LocalPost.Meta.fields.subscribers.reverseFields, []
  test.instanceOf LocalPost.Meta.fields.reviewers, LocalPost._ReferenceField
  test.equal LocalPost.Meta.fields.reviewers.ancestorArray, 'reviewers'
  test.isTrue LocalPost.Meta.fields.reviewers.required
  test.equal LocalPost.Meta.fields.reviewers.sourcePath, 'reviewers'
  test.equal LocalPost.Meta.fields.reviewers.sourceDocument, LocalPost
  test.equal LocalPost.Meta.fields.reviewers.targetDocument, LocalPerson
  test.isNull LocalPost.Meta.fields.reviewers.sourceCollection._name
  test.isNull LocalPost.Meta.fields.reviewers.targetCollection._name
  test.isNull LocalPost.Meta.fields.reviewers.sourceDocument.Meta.collection._name
  test.isNull LocalPost.Meta.fields.reviewers.targetDocument.Meta.collection._name
  test.equal LocalPost.Meta.fields.reviewers.fields, [username: 1]
  test.isNull LocalPost.Meta.fields.reviewers.reverseName
  test.equal LocalPost.Meta.fields.reviewers.reverseFields, []
  test.equal _.size(LocalPost.Meta.fields.subdocument), 3
  test.instanceOf LocalPost.Meta.fields.subdocument.person, LocalPost._ReferenceField
  test.isNull LocalPost.Meta.fields.subdocument.person.ancestorArray, LocalPost.Meta.fields.subdocument.person.ancestorArray
  test.isFalse LocalPost.Meta.fields.subdocument.person.required
  test.equal LocalPost.Meta.fields.subdocument.person.sourcePath, 'subdocument.person'
  test.equal LocalPost.Meta.fields.subdocument.person.sourceDocument, LocalPost
  test.equal LocalPost.Meta.fields.subdocument.person.targetDocument, LocalPerson
  test.isNull LocalPost.Meta.fields.subdocument.person.sourceCollection._name
  test.isNull LocalPost.Meta.fields.subdocument.person.targetCollection._name
  test.isNull LocalPost.Meta.fields.subdocument.person.sourceDocument.Meta.collection._name
  test.isNull LocalPost.Meta.fields.subdocument.person.targetDocument.Meta.collection._name
  test.equal LocalPost.Meta.fields.subdocument.person.fields, {'username': 1, 'displayName': 1, 'field1': 1, 'field2': 1}
  test.equal LocalPost.Meta.fields.subdocument.person.reverseName, 'subdocument.posts'
  test.equal LocalPost.Meta.fields.subdocument.person.reverseFields, ['body', 'subdocument.body', 'nested.body']
  test.instanceOf LocalPost.Meta.fields.subdocument.persons, LocalPost._ReferenceField
  test.equal LocalPost.Meta.fields.subdocument.persons.ancestorArray, 'subdocument.persons'
  test.isTrue LocalPost.Meta.fields.subdocument.persons.required
  test.equal LocalPost.Meta.fields.subdocument.persons.sourcePath, 'subdocument.persons'
  test.equal LocalPost.Meta.fields.subdocument.persons.sourceDocument, LocalPost
  test.equal LocalPost.Meta.fields.subdocument.persons.targetDocument, LocalPerson
  test.isNull LocalPost.Meta.fields.subdocument.persons.sourceCollection._name
  test.isNull LocalPost.Meta.fields.subdocument.persons.targetCollection._name
  test.isNull LocalPost.Meta.fields.subdocument.persons.sourceDocument.Meta.collection._name
  test.isNull LocalPost.Meta.fields.subdocument.persons.targetDocument.Meta.collection._name
  test.equal LocalPost.Meta.fields.subdocument.persons.fields, ['username', 'displayName', 'field1', 'field2']
  test.equal LocalPost.Meta.fields.subdocument.persons.reverseName, 'subdocumentsPosts'
  test.equal LocalPost.Meta.fields.subdocument.persons.reverseFields, ['body', 'subdocument.body', 'nested.body']
  test.instanceOf LocalPost.Meta.fields.subdocument.slug, LocalPost._GeneratedField
  test.isNull LocalPost.Meta.fields.subdocument.slug.ancestorArray, LocalPost.Meta.fields.subdocument.slug.ancestorArray
  test.isTrue _.isFunction LocalPost.Meta.fields.subdocument.slug.generator
  test.equal LocalPost.Meta.fields.subdocument.slug.sourcePath, 'subdocument.slug'
  test.equal LocalPost.Meta.fields.subdocument.slug.sourceDocument, LocalPost
  test.equal LocalPost.Meta.fields.subdocument.slug.targetDocument, LocalPost
  test.isNull LocalPost.Meta.fields.subdocument.slug.sourceCollection._name
  test.isNull LocalPost.Meta.fields.subdocument.slug.targetCollection._name
  test.isNull LocalPost.Meta.fields.subdocument.slug.sourceDocument.Meta.collection._name
  test.isNull LocalPost.Meta.fields.subdocument.slug.targetDocument.Meta.collection._name
  test.equal LocalPost.Meta.fields.subdocument.slug.fields, ['body', 'subdocument.body']
  test.isUndefined LocalPost.Meta.fields.subdocument.slug.reverseName
  test.isUndefined LocalPost.Meta.fields.subdocument.slug.reverseFields
  test.equal _.size(LocalPost.Meta.fields.nested), 3
  test.instanceOf LocalPost.Meta.fields.nested.required, LocalPost._ReferenceField
  test.equal LocalPost.Meta.fields.nested.required.ancestorArray, 'nested'
  test.isTrue LocalPost.Meta.fields.nested.required.required
  test.equal LocalPost.Meta.fields.nested.required.sourcePath, 'nested.required'
  test.equal LocalPost.Meta.fields.nested.required.sourceDocument, LocalPost
  test.equal LocalPost.Meta.fields.nested.required.targetDocument, LocalPerson
  test.isNull LocalPost.Meta.fields.nested.required.sourceCollection._name
  test.isNull LocalPost.Meta.fields.nested.required.targetCollection._name
  test.isNull LocalPost.Meta.fields.nested.required.sourceDocument.Meta.collection._name
  test.isNull LocalPost.Meta.fields.nested.required.targetDocument.Meta.collection._name
  test.equal LocalPost.Meta.fields.nested.required.fields, ['username', 'displayName', 'field1', 'field2']
  test.equal LocalPost.Meta.fields.nested.required.reverseName, 'nestedPosts'
  test.equal LocalPost.Meta.fields.nested.required.reverseFields, ['body', 'subdocument.body', 'nested.body']
  test.instanceOf LocalPost.Meta.fields.nested.optional, LocalPost._ReferenceField
  test.equal LocalPost.Meta.fields.nested.optional.ancestorArray, 'nested'
  test.isFalse LocalPost.Meta.fields.nested.optional.required
  test.equal LocalPost.Meta.fields.nested.optional.sourcePath, 'nested.optional'
  test.equal LocalPost.Meta.fields.nested.optional.sourceDocument, LocalPost
  test.equal LocalPost.Meta.fields.nested.optional.targetDocument, LocalPerson
  test.isNull LocalPost.Meta.fields.nested.optional.sourceCollection._name
  test.isNull LocalPost.Meta.fields.nested.optional.targetCollection._name
  test.isNull LocalPost.Meta.fields.nested.optional.sourceDocument.Meta.collection._name
  test.isNull LocalPost.Meta.fields.nested.optional.targetDocument.Meta.collection._name
  test.equal LocalPost.Meta.fields.nested.optional.fields, ['username']
  test.isNull LocalPost.Meta.fields.nested.optional.reverseName
  test.equal LocalPost.Meta.fields.nested.optional.reverseFields, []
  test.instanceOf LocalPost.Meta.fields.nested.slug, LocalPost._GeneratedField
  test.equal LocalPost.Meta.fields.nested.slug.ancestorArray, 'nested'
  test.isTrue _.isFunction LocalPost.Meta.fields.nested.slug.generator
  test.equal LocalPost.Meta.fields.nested.slug.sourcePath, 'nested.slug'
  test.equal LocalPost.Meta.fields.nested.slug.sourceDocument, LocalPost
  test.equal LocalPost.Meta.fields.nested.slug.targetDocument, LocalPost
  test.isNull LocalPost.Meta.fields.nested.slug.sourceCollection._name
  test.isNull LocalPost.Meta.fields.nested.slug.targetCollection._name
  test.isNull LocalPost.Meta.fields.nested.slug.sourceDocument.Meta.collection._name
  test.isNull LocalPost.Meta.fields.nested.slug.targetDocument.Meta.collection._name
  test.equal LocalPost.Meta.fields.nested.slug.fields, ['body', 'nested.body']
  test.isUndefined LocalPost.Meta.fields.nested.slug.reverseName
  test.isUndefined LocalPost.Meta.fields.nested.slug.reverseFields
  test.instanceOf LocalPost.Meta.fields.slug, LocalPost._GeneratedField
  test.isNull LocalPost.Meta.fields.slug.ancestorArray, LocalPost.Meta.fields.slug.ancestorArray
  test.isTrue _.isFunction LocalPost.Meta.fields.slug.generator
  test.equal LocalPost.Meta.fields.slug.sourcePath, 'slug'
  test.equal LocalPost.Meta.fields.slug.sourceDocument, LocalPost
  test.equal LocalPost.Meta.fields.slug.targetDocument, LocalPost
  test.isNull LocalPost.Meta.fields.slug.sourceCollection._name
  test.isNull LocalPost.Meta.fields.slug.targetCollection._name
  test.isNull LocalPost.Meta.fields.slug.sourceDocument.Meta.collection._name
  test.isNull LocalPost.Meta.fields.slug.targetDocument.Meta.collection._name
  test.equal LocalPost.Meta.fields.slug.fields, ['body', 'subdocument.body']
  test.isUndefined LocalPost.Meta.fields.slug.reverseName
  test.isUndefined LocalPost.Meta.fields.slug.reverseFields
  test.instanceOf LocalPost.Meta.fields.tags, LocalPost._GeneratedField
  test.equal LocalPost.Meta.fields.tags.ancestorArray, 'tags'
  test.isTrue _.isFunction LocalPost.Meta.fields.tags.generator
  test.equal LocalPost.Meta.fields.tags.sourcePath, 'tags'
  test.equal LocalPost.Meta.fields.tags.sourceDocument, LocalPost
  test.equal LocalPost.Meta.fields.tags.targetDocument, LocalPost
  test.isNull LocalPost.Meta.fields.tags.sourceCollection._name
  test.isNull LocalPost.Meta.fields.tags.targetCollection._name
  test.isNull LocalPost.Meta.fields.tags.sourceDocument.Meta.collection._name
  test.isNull LocalPost.Meta.fields.tags.targetDocument.Meta.collection._name
  test.equal LocalPost.Meta.fields.tags.fields, ['body', 'subdocument.body', 'nested.body']
  test.isUndefined LocalPost.Meta.fields.tags.reverseName
  test.isUndefined LocalPost.Meta.fields.tags.reverseFields
  test.isTrue LocalPost.Meta._observersSetup

  test.equal LocalPerson.Meta._name, 'LocalPerson'
  test.equal LocalPerson.Meta.document, LocalPerson
  test.isNull LocalPerson.Meta.collection._name
  test.equal _.size(LocalPerson.Meta.triggers), 0
  test.equal _.size(LocalPerson.Meta.fields), 5
  test.instanceOf LocalPerson.Meta.fields.posts, LocalPerson._ReferenceField
  test.equal LocalPerson.Meta.fields.posts.ancestorArray, 'posts'
  test.isTrue LocalPerson.Meta.fields.posts.required
  test.equal LocalPerson.Meta.fields.posts.sourcePath, 'posts'
  test.equal LocalPerson.Meta.fields.posts.sourceDocument, LocalPerson
  test.equal LocalPerson.Meta.fields.posts.targetDocument, LocalPost
  test.isNull LocalPerson.Meta.fields.posts.sourceCollection._name
  test.isNull LocalPerson.Meta.fields.posts.targetCollection._name
  test.isNull LocalPerson.Meta.fields.posts.sourceDocument.Meta.collection._name
  test.isNull LocalPerson.Meta.fields.posts.targetDocument.Meta.collection._name
  test.equal LocalPerson.Meta.fields.posts.fields, ['body', 'subdocument.body', 'nested.body']
  test.isNull LocalPerson.Meta.fields.posts.reverseName
  test.equal LocalPerson.Meta.fields.posts.reverseFields, []
  test.instanceOf LocalPerson.Meta.fields.nestedPosts, LocalPerson._ReferenceField
  test.equal LocalPerson.Meta.fields.nestedPosts.ancestorArray, 'nestedPosts'
  test.isTrue LocalPerson.Meta.fields.nestedPosts.required
  test.equal LocalPerson.Meta.fields.nestedPosts.sourcePath, 'nestedPosts'
  test.equal LocalPerson.Meta.fields.nestedPosts.sourceDocument, LocalPerson
  test.equal LocalPerson.Meta.fields.nestedPosts.targetDocument, LocalPost
  test.isNull LocalPerson.Meta.fields.nestedPosts.sourceCollection._name
  test.isNull LocalPerson.Meta.fields.nestedPosts.targetCollection._name
  test.isNull LocalPerson.Meta.fields.nestedPosts.sourceDocument.Meta.collection._name
  test.isNull LocalPerson.Meta.fields.nestedPosts.targetDocument.Meta.collection._name
  test.equal LocalPerson.Meta.fields.nestedPosts.fields, ['body', 'subdocument.body', 'nested.body']
  test.isNull LocalPerson.Meta.fields.nestedPosts.reverseName
  test.equal LocalPerson.Meta.fields.nestedPosts.reverseFields, []
  test.instanceOf LocalPerson.Meta.fields.count, LocalPerson._GeneratedField
  test.isNull LocalPerson.Meta.fields.count.ancestorArray, LocalPerson.Meta.fields.count.ancestorArray
  test.isTrue _.isFunction LocalPerson.Meta.fields.count.generator
  test.equal LocalPerson.Meta.fields.count.sourcePath, 'count'
  test.equal LocalPerson.Meta.fields.count.sourceDocument, LocalPerson
  test.equal LocalPerson.Meta.fields.count.targetDocument, LocalPerson
  test.isNull LocalPerson.Meta.fields.count.sourceCollection._name
  test.isNull LocalPerson.Meta.fields.count.targetCollection._name
  test.isNull LocalPerson.Meta.fields.count.sourceDocument.Meta.collection._name
  test.isNull LocalPerson.Meta.fields.count.targetDocument.Meta.collection._name
  test.equal LocalPerson.Meta.fields.count.fields, ['posts', 'subdocument.posts', 'subdocumentsPosts', 'nestedPosts']
  test.isUndefined LocalPerson.Meta.fields.count.reverseName
  test.isUndefined LocalPerson.Meta.fields.count.reverseFields
  test.instanceOf LocalPerson.Meta.fields.subdocument.posts, LocalPerson._ReferenceField
  test.equal LocalPerson.Meta.fields.subdocument.posts.ancestorArray, 'subdocument.posts'
  test.isTrue LocalPerson.Meta.fields.subdocument.posts.required
  test.equal LocalPerson.Meta.fields.subdocument.posts.sourcePath, 'subdocument.posts'
  test.equal LocalPerson.Meta.fields.subdocument.posts.sourceDocument, LocalPerson
  test.equal LocalPerson.Meta.fields.subdocument.posts.targetDocument, LocalPost
  test.isNull LocalPerson.Meta.fields.subdocument.posts.sourceCollection._name
  test.isNull LocalPerson.Meta.fields.subdocument.posts.targetCollection._name
  test.isNull LocalPerson.Meta.fields.subdocument.posts.sourceDocument.Meta.collection._name
  test.isNull LocalPerson.Meta.fields.subdocument.posts.targetDocument.Meta.collection._name
  test.equal LocalPerson.Meta.fields.subdocument.posts.fields, ['body', 'subdocument.body', 'nested.body']
  test.isNull LocalPerson.Meta.fields.subdocument.posts.reverseName
  test.equal LocalPerson.Meta.fields.subdocument.posts.reverseFields, []
  test.instanceOf LocalPerson.Meta.fields.subdocumentsPosts, LocalPerson._ReferenceField
  test.equal LocalPerson.Meta.fields.subdocumentsPosts.ancestorArray, 'subdocumentsPosts'
  test.isTrue LocalPerson.Meta.fields.subdocumentsPosts.required
  test.equal LocalPerson.Meta.fields.subdocumentsPosts.sourcePath, 'subdocumentsPosts'
  test.equal LocalPerson.Meta.fields.subdocumentsPosts.sourceDocument, LocalPerson
  test.equal LocalPerson.Meta.fields.subdocumentsPosts.targetDocument, LocalPost
  test.isNull LocalPerson.Meta.fields.subdocumentsPosts.sourceCollection._name
  test.isNull LocalPerson.Meta.fields.subdocumentsPosts.targetCollection._name
  test.isNull LocalPerson.Meta.fields.subdocumentsPosts.sourceDocument.Meta.collection._name
  test.isNull LocalPerson.Meta.fields.subdocumentsPosts.targetDocument.Meta.collection._name
  test.equal LocalPerson.Meta.fields.subdocumentsPosts.fields, ['body', 'subdocument.body', 'nested.body']
  test.isNull LocalPerson.Meta.fields.subdocumentsPosts.reverseName
  test.equal LocalPerson.Meta.fields.subdocumentsPosts.reverseFields, []
  test.isTrue LocalPerson.Meta._observersSetup

  testDocumentList test, ALL

plainObject = (obj) ->
  return obj unless _.isObject obj

  return (plainObject o for o in obj) if _.isArray obj

  keys = _.keys obj
  values = (plainObject o for o in _.values obj)

  _.object keys, values

for name, documents of {server: {Person: Person, Post: Post}, local: {Person: LocalPerson, Post: LocalPost}}
  do (documents) ->
    testAsyncMulti "peerdb - references #{name}", [
      (test, expect) ->
        testDefinition test

        # We should be able to call defineAll multiple times
        Document.defineAll()

        testDefinition test

        documents.Person.documents.insert
          username: 'person1'
          displayName: 'Person 1'
          field1: 'Field 1 - 1'
          field2: 'Field 1 - 2'
        ,
          expect (error, person1Id) =>
            test.isFalse error, error?.toString?() or error
            test.isTrue person1Id
            @person1Id = person1Id

        documents.Person.documents.insert
          username: 'person2'
          displayName: 'Person 2'
          field1: 'Field 2 - 1'
          field2: 'Field 2 - 2'
        ,
          expect (error, person2Id) =>
            test.isFalse error, error?.toString?() or error
            test.isTrue person2Id
            @person2Id = person2Id

        documents.Person.documents.insert
          username: 'person3'
          displayName: 'Person 3'
          field1: 'Field 3 - 1'
          field2: 'Field 3 - 2'
        ,
          expect (error, person3Id) =>
            test.isFalse error, error?.toString?() or error
            test.isTrue person3Id
            @person3Id = person3Id

        # Wait so that observers have time to run (but no post is yet made, so nothing really happens).
        # We want to wait here so that we catch possible errors in source observers, otherwise target
        # observers can patch things up. For example, if we create a post first and target observers
        # (triggered by person inserts, but pending) run afterwards, then they can patch things which
        # should in fact be done by source observers (on post), like setting usernames in post's
        # references to persons.
        waitForDatabase test, expect
    ,
      (test, expect) ->
        # Should work also with no argument (defaults to {}).
        test.isTrue documents.Person.documents.exists()
        test.isTrue documents.Person.documents.find().exists()

        test.isTrue documents.Person.documents.exists @person1Id
        test.isTrue documents.Person.documents.exists @person2Id
        test.isTrue documents.Person.documents.exists @person3Id

        test.isTrue documents.Person.documents.find(@person1Id).exists()
        test.isTrue documents.Person.documents.find(@person2Id).exists()
        test.isTrue documents.Person.documents.find(@person3Id).exists()

        test.equal documents.Person.documents.find({_id: $in: [@person1Id, @person2Id, @person3Id]}).count(), 3

        # Test without skip and limit.
        test.isTrue documents.Person.documents.exists({_id: $in: [@person1Id, @person2Id, @person3Id]})
        test.isTrue documents.Person.documents.find({_id: $in: [@person1Id, @person2Id, @person3Id]}).exists()

        # With sorting. We are testing all this combinations because there are various code paths.
        test.isTrue documents.Person.documents.exists({_id: $in: [@person1Id, @person2Id, @person3Id]}, {sort: [['username', 'asc']]})
        test.isTrue documents.Person.documents.find({_id: $in: [@person1Id, @person2Id, @person3Id]}, {sort: [['username', 'asc']]}).exists()

        # Test with skip and limit.
        # This behaves differently than .count() on the server because on the server
        # applySkipLimit is not set. But exists do respect skip and limit.
        test.isTrue documents.Person.documents.exists({_id: $in: [@person1Id, @person2Id, @person3Id]}, {skip: 2, limit: 1})
        test.isTrue documents.Person.documents.find({_id: $in: [@person1Id, @person2Id, @person3Id]}, {skip: 2, limit: 1}).exists()
        test.isFalse documents.Person.documents.exists({_id: $in: [@person1Id, @person2Id, @person3Id]}, {skip: 3, limit: 1})
        test.isFalse documents.Person.documents.find({_id: $in: [@person1Id, @person2Id, @person3Id]}, {skip: 3, limit: 1}).exists()

        test.isTrue documents.Person.documents.exists({_id: $in: [@person1Id, @person2Id, @person3Id]}, {skip: 2, limit: 1, sort: [['username', 'asc']]})
        test.isTrue documents.Person.documents.find({_id: $in: [@person1Id, @person2Id, @person3Id]}, {skip: 2, limit: 1, sort: [['username', 'asc']]}).exists()
        test.isFalse documents.Person.documents.exists({_id: $in: [@person1Id, @person2Id, @person3Id]}, {skip: 3, limit: 1, sort: [['username', 'asc']]})
        test.isFalse documents.Person.documents.find({_id: $in: [@person1Id, @person2Id, @person3Id]}, {skip: 3, limit: 1, sort: [['username', 'asc']]}).exists()

        @person1 = documents.Person.documents.findOne @person1Id,
          transform: null # So that we can use test.equal
        @person2 = documents.Person.documents.findOne @person2Id,
          transform: null # So that we can use test.equal
        @person3 = documents.Person.documents.findOne @person3Id,
          transform: null # So that we can use test.equal

        test.equal @person1,
          _id: @person1Id
          username: 'person1'
          displayName: 'Person 1'
          field1: 'Field 1 - 1'
          field2: 'Field 1 - 2'
          count: 0
        test.equal @person2,
          _id: @person2Id
          username: 'person2'
          displayName: 'Person 2'
          field1: 'Field 2 - 1'
          field2: 'Field 2 - 2'
          count: 0
        test.equal @person3,
          _id: @person3Id
          username: 'person3'
          displayName: 'Person 3'
          field1: 'Field 3 - 1'
          field2: 'Field 3 - 2'
          count: 0

        documents.Post.documents.insert
          author:
            _id: @person1._id
            # To test what happens if all fields are not up to date
            username: 'wrong'
            displayName: 'wrong'
            field1: 'wrong'
            field2: 'wrong'
          subscribers: [
            _id: @person2._id
          ,
            _id: @person3._id
          ]
          reviewers: [
            _id: @person2._id
            username: 'wrong'
          ,
            _id: @person3._id
            username: 'wrong'
          ]
          subdocument:
            person:
              _id: @person2._id
              username: 'wrong'
            persons: [
              _id: @person2._id
            ,
              _id: @person3._id
            ]
            body: 'SubdocumentFooBar'
          nested: [
            required:
              _id: @person2._id
              username: 'wrong'
              displayName: 'wrong'
            optional:
              _id: @person3._id
              username: 'wrong'
            body: 'NestedFooBar'
          ]
          body: 'FooBar'
        ,
          expect (error, postId) =>
            test.isFalse error, error?.toString?() or error
            test.isTrue postId
            @postId = postId

        # Wait so that observers have time to update documents
        waitForDatabase test, expect
    ,
      (test, expect) ->
        @post = documents.Post.documents.findOne @postId,
          transform: null # So that we can use test.equal

        # We inserted the document only with ids - subdocuments should be
        # automatically populated with additional fields as defined in @ReferenceField
        test.equal @post,
          _id: @postId
          author:
            _id: @person1._id
            username: @person1.username
            displayName: @person1.displayName
            field1: @person1.field1
            field2: @person1.field2
          # subscribers have only ids
          subscribers: [
            _id: @person2._id
          ,
            _id: @person3._id
          ]
          # But reviewers have usernames as well
          reviewers: [
            _id: @person2._id
            username: @person2.username
          ,
            _id: @person3._id
            username: @person3.username
          ]
          subdocument:
            person:
              _id: @person2._id
              username: @person2.username
              displayName: @person2.displayName
              field1: @person2.field1
              field2: @person2.field2
            persons: [
              _id: @person2._id
              username: @person2.username
              displayName: @person2.displayName
              field1: @person2.field1
              field2: @person2.field2
            ,
              _id: @person3._id
              username: @person3.username
              displayName: @person3.displayName
              field1: @person3.field1
              field2: @person3.field2
            ]
            slug: 'subdocument-prefix-foobar-subdocumentfoobar-suffix'
            body: 'SubdocumentFooBar'
          nested: [
            required:
              _id: @person2._id
              username: @person2.username
              displayName: @person2.displayName
              field1: @person2.field1
              field2: @person2.field2
            optional:
              _id: @person3._id
              username: @person3.username
            slug: 'nested-prefix-foobar-nestedfoobar-suffix'
            body: 'NestedFooBar'
          ]
          body: 'FooBar'
          slug: 'prefix-foobar-subdocumentfoobar-suffix'
          tags: [
            'tag-0-prefix-foobar-subdocumentfoobar-suffix'
            'tag-1-prefix-foobar-nestedfoobar-suffix'
          ]

        documents.Person.documents.update @person1Id,
          $set:
            username: 'person1a'
        ,
          expect (error, res) =>
            test.isFalse error, error?.toString?() or error
            test.isTrue res

        documents.Person.documents.update @person2Id,
          $set:
            username: 'person2a'
        ,
          expect (error, res) =>
            test.isFalse error, error?.toString?() or error
            test.isTrue res

        # Wait so that observers have time to update documents
        # so that persons updates are not merged together to better
        # test the code for multiple updates
        waitForDatabase test, expect
    ,
      (test, expect) ->
        documents.Person.documents.update @person3Id,
          $set:
            username: 'person3a'
        ,
          expect (error, res) =>
            test.isFalse error, error?.toString?() or error
            test.isTrue res
    ,
      (test, expect) ->
        @person1 = documents.Person.documents.findOne @person1Id,
          transform: null # So that we can use test.equal
        @person2 = documents.Person.documents.findOne @person2Id,
          transform: null # So that we can use test.equal
        @person3 = documents.Person.documents.findOne @person3Id,
          transform: null # So that we can use test.equal

        test.equal @person1,
          _id: @person1Id
          username: 'person1a'
          displayName: 'Person 1'
          field1: 'Field 1 - 1'
          field2: 'Field 1 - 2'
          posts: [
            _id: @postId
            body: 'FooBar'
            nested: [
              body: 'NestedFooBar'
            ]
            subdocument:
              body: 'SubdocumentFooBar'
          ]
          count: 1
        test.equal @person2,
          _id: @person2Id
          username: 'person2a'
          displayName: 'Person 2'
          field1: 'Field 2 - 1'
          field2: 'Field 2 - 2'
          subdocument:
            posts: [
              _id: @postId
              body: 'FooBar'
              nested: [
                body: 'NestedFooBar'
              ]
              subdocument:
                body: 'SubdocumentFooBar'
            ]
          subdocumentsPosts: [
            _id: @postId
            body: 'FooBar'
            nested: [
              body: 'NestedFooBar'
            ]
            subdocument:
              body: 'SubdocumentFooBar'
          ]
          nestedPosts: [
            _id: @postId
            body: 'FooBar'
            nested: [
              body: 'NestedFooBar'
            ]
            subdocument:
              body: 'SubdocumentFooBar'
          ]
          count: 3
        test.equal @person3,
          _id: @person3Id
          username: 'person3a'
          displayName: 'Person 3'
          field1: 'Field 3 - 1'
          field2: 'Field 3 - 2'
          subdocumentsPosts: [
            _id: @postId
            body: 'FooBar'
            nested: [
              body: 'NestedFooBar'
            ]
            subdocument:
              body: 'SubdocumentFooBar'
          ]
          count: 1

        # Wait so that observers have time to update documents
        waitForDatabase test, expect
    ,
      (test, expect) ->
        @post = documents.Post.documents.findOne @postId,
          transform: null # So that we can use test.equal

        # All persons had usernames changed, they should
        # be updated in the post as well, automatically
        test.equal @post,
          _id: @postId
          author:
            _id: @person1._id
            username: @person1.username
            displayName: @person1.displayName
            field1: @person1.field1
            field2: @person1.field2
          subscribers: [
            _id: @person2._id
          ,
            _id: @person3._id
          ]
          reviewers: [
            _id: @person2._id
            username: @person2.username
          ,
            _id: @person3._id
            username: @person3.username
          ]
          subdocument:
            person:
              _id: @person2._id
              username: @person2.username
              displayName: @person2.displayName
              field1: @person2.field1
              field2: @person2.field2
            persons: [
              _id: @person2._id
              username: @person2.username
              displayName: @person2.displayName
              field1: @person2.field1
              field2: @person2.field2
            ,
              _id: @person3._id
              username: @person3.username
              displayName: @person3.displayName
              field1: @person3.field1
              field2: @person3.field2
            ]
            slug: 'subdocument-prefix-foobar-subdocumentfoobar-suffix'
            body: 'SubdocumentFooBar'
          nested: [
            required:
              _id: @person2._id
              username: @person2.username
              displayName: @person2.displayName
              field1: @person2.field1
              field2: @person2.field2
            optional:
              _id: @person3._id
              username: @person3.username
            slug: 'nested-prefix-foobar-nestedfoobar-suffix'
            body: 'NestedFooBar'
          ]
          body: 'FooBar'
          slug: 'prefix-foobar-subdocumentfoobar-suffix'
          tags: [
            'tag-0-prefix-foobar-subdocumentfoobar-suffix'
            'tag-1-prefix-foobar-nestedfoobar-suffix'
          ]

        documents.Person.documents.remove @person3Id,
          expect (error) =>
            test.isFalse error, error?.toString?() or error

        # Wait so that observers have time to update documents
        waitForDatabase test, expect
    ,
      (test, expect) ->
        @post = documents.Post.documents.findOne @postId,
          transform: null # So that we can use test.equal

        # person3 was removed, references should be removed as well, automatically
        test.equal @post,
          _id: @postId
          author:
            _id: @person1._id
            username: @person1.username
            displayName: @person1.displayName
            field1: @person1.field1
            field2: @person1.field2
          subscribers: [
            _id: @person2._id
          ]
          reviewers: [
            _id: @person2._id
            username: @person2.username
          ]
          subdocument:
            person:
              _id: @person2._id
              username: @person2.username
              displayName: @person2.displayName
              field1: @person2.field1
              field2: @person2.field2
            persons: [
              _id: @person2._id
              username: @person2.username
              displayName: @person2.displayName
              field1: @person2.field1
              field2: @person2.field2
            ]
            slug: 'subdocument-prefix-foobar-subdocumentfoobar-suffix'
            body: 'SubdocumentFooBar'
          nested: [
            required:
              _id: @person2._id
              username: @person2.username
              displayName: @person2.displayName
              field1: @person2.field1
              field2: @person2.field2
            optional: null
            slug: 'nested-prefix-foobar-nestedfoobar-suffix'
            body: 'NestedFooBar'
          ]
          body: 'FooBar'
          slug: 'prefix-foobar-subdocumentfoobar-suffix'
          tags: [
            'tag-0-prefix-foobar-subdocumentfoobar-suffix'
            'tag-1-prefix-foobar-nestedfoobar-suffix'
          ]

        documents.Person.documents.remove @person2Id,
          expect (error) =>
            test.isFalse error, error?.toString?() or error

        # Wait so that observers have time to update documents
        waitForDatabase test, expect
    ,
      (test, expect) ->
        @post = documents.Post.documents.findOne @postId,
          transform: null # So that we can use test.equal

        # person2 was removed, references should be removed as well, automatically,
        # but lists should be kept as empty lists
        test.equal @post,
          _id: @postId
          author:
            _id: @person1._id
            username: @person1.username
            displayName: @person1.displayName
            field1: @person1.field1
            field2: @person1.field2
          subscribers: []
          reviewers: []
          subdocument:
            person: null
            persons: []
            slug: 'subdocument-prefix-foobar-subdocumentfoobar-suffix'
            body: 'SubdocumentFooBar'
          nested: []
          body: 'FooBar'
          slug: 'prefix-foobar-subdocumentfoobar-suffix'
          tags: [
            'tag-0-prefix-foobar-subdocumentfoobar-suffix'
          ]

        documents.Person.documents.remove @person1Id,
          expect (error) =>
            test.isFalse error, error?.toString?() or error

        # Wait so that observers have time to update documents
        waitForDatabase test, expect
    ,
      (test, expect) ->
        @post = documents.Post.documents.findOne @postId,
          transform: null # So that we can use test.equal

        # If directly referenced document is removed, dependency is removed as well
        test.isFalse @post, @post
    ]

Tinytest.add 'peerdb - invalid optional', (test) ->
  test.throws ->
    class BadPost1 extends Document
      @Meta
        name: 'BadPost1'
        fields: ->
          reviewers: [@ReferenceField Person, ['username'], false]
  , /Reference field directly in an array cannot be optional/

  # Invalid document should not be added to the list
  testDocumentList test, ALL

  # Should not try to define invalid document again
  Document.defineAll()

Tinytest.add 'peerdb - invalid nested arrays', (test) ->
  test.throws ->
    class BadPost2 extends Document
      @Meta
        name: 'BadPost2'
        fields: ->
          nested: [
            many: [@ReferenceField Person, ['username']]
          ]
  , /Field cannot be in a nested array/

  # Invalid document should not be added to the list
  testDocumentList test, ALL

  # Should not try to define invalid document again
  Document.defineAll()

Tinytest.add 'peerdb - abstract with parent', (test) ->
  test.throws ->
    class BadPost4 extends Post
      @Meta
        abstract: true
  , /Abstract document with a parent/

  # Invalid document should not be added to the list
  testDocumentList test, ALL

  # Should not try to define invalid document again
  Document.defineAll()

testAsyncMulti 'peerdb - circular changes', [
  (test, expect) ->
    Log._intercept 3 if Meteor.isServer and Document.instances is 1 # Three to see if we catch more than expected

    CircularFirst.documents.insert
      second: null
      content: 'FooBar 1'
    ,
      expect (error, circularFirstId) =>
        test.isFalse error, error?.toString?() or error
        test.isTrue circularFirstId
        @circularFirstId = circularFirstId

    CircularSecond.documents.insert
      first: null
      content: 'FooBar 2'
    ,
      expect (error, circularSecondId) =>
        test.isFalse error, error?.toString?() or error
        test.isTrue circularSecondId
        @circularSecondId = circularSecondId

    # Wait so that observers have time to update documents
    waitForDatabase test, expect
,
  (test, expect) ->
    if Meteor.isServer and Document.instances is 1
      intercepted = Log._intercepted()

      # One or two because it depends if the client tests are running at the same time
      test.isTrue 1 <= intercepted.length <= 2, intercepted

      # We are testing only the server one, so let's find it
      for i in intercepted
        break if i.indexOf(@circularFirstId) isnt -1
      test.isTrue _.isString(i), i
      intercepted = EJSON.parse i

      test.equal intercepted.message, "Document 'CircularFirst' '#{ @circularFirstId }' field 'second' was updated with an invalid value: null"
      test.equal intercepted.level, 'error'

    @circularFirst = CircularFirst.documents.findOne @circularFirstId,
      transform: null # So that we can use test.equal
    @circularSecond = CircularSecond.documents.findOne @circularSecondId,
      transform: null # So that we can use test.equal

    test.equal @circularFirst,
      _id: @circularFirstId
      second: null
      content: 'FooBar 1'
    test.equal @circularSecond,
      _id: @circularSecondId
      first: null
      content: 'FooBar 2'

    CircularFirst.documents.update @circularFirstId,
      $set:
        second:
          _id: @circularSecondId
    ,
      expect (error, res) =>
        test.isFalse error, error?.toString?() or error
        test.isTrue res

    # Wait so that observers have time to update documents
    waitForDatabase test, expect
,
  (test, expect) ->
    @circularFirst = CircularFirst.documents.findOne @circularFirstId,
      transform: null # So that we can use test.equal
    @circularSecond = CircularSecond.documents.findOne @circularSecondId,
      transform: null # So that we can use test.equal

    test.equal @circularFirst,
      _id: @circularFirstId
      second:
        _id: @circularSecondId
        content: 'FooBar 2'
      content: 'FooBar 1'
    test.equal @circularSecond,
      _id: @circularSecondId
      first: null
      content: 'FooBar 2'
      reverseFirsts: [
        _id: @circularFirstId
        content: 'FooBar 1'
      ]

    CircularSecond.documents.update @circularSecondId,
      $set:
        first:
          _id: @circularFirstId
    ,
      expect (error, res) =>
        test.isFalse error, error?.toString?() or error
        test.isTrue res

    # Wait so that observers have time to update documents
    waitForDatabase test, expect
,
  (test, expect) ->
    @circularFirst = CircularFirst.documents.findOne @circularFirstId,
      transform: null # So that we can use test.equal
    @circularSecond = CircularSecond.documents.findOne @circularSecondId,
      transform: null # So that we can use test.equal

    test.equal @circularFirst,
      _id: @circularFirstId
      second:
        _id: @circularSecondId
        content: 'FooBar 2'
      content: 'FooBar 1'
      reverseSeconds: [
        _id: @circularSecondId
        content: 'FooBar 2'
      ]
    test.equal @circularSecond,
      _id: @circularSecondId
      first:
        _id: @circularFirstId
        content: 'FooBar 1'
      content: 'FooBar 2'
      reverseFirsts: [
        _id: @circularFirstId
        content: 'FooBar 1'
      ]

    CircularFirst.documents.update @circularFirstId,
      $set:
        content: 'FooBar 1a'
    ,
      expect (error, res) =>
        test.isFalse error, error?.toString?() or error
        test.isTrue res

    # Wait so that observers have time to update documents
    waitForDatabase test, expect
,
  (test, expect) ->
    @circularFirst = CircularFirst.documents.findOne @circularFirstId,
      transform: null # So that we can use test.equal
    @circularSecond = CircularSecond.documents.findOne @circularSecondId,
      transform: null # So that we can use test.equal

    test.equal @circularFirst,
      _id: @circularFirstId
      second:
        _id: @circularSecondId
        content: 'FooBar 2'
      content: 'FooBar 1a'
      reverseSeconds: [
        _id: @circularSecondId
        content: 'FooBar 2'
      ]
    test.equal @circularSecond,
      _id: @circularSecondId
      first:
        _id: @circularFirstId
        content: 'FooBar 1a'
      content: 'FooBar 2'
      reverseFirsts: [
        _id: @circularFirstId
        content: 'FooBar 1a'
      ]

    CircularSecond.documents.update @circularSecondId,
      $set:
        content: 'FooBar 2a'
    ,
      expect (error, res) =>
        test.isFalse error, error?.toString?() or error
        test.isTrue res

    # Wait so that observers have time to update documents
    waitForDatabase test, expect
,
  (test, expect) ->
    @circularFirst = CircularFirst.documents.findOne @circularFirstId,
      transform: null # So that we can use test.equal
    @circularSecond = CircularSecond.documents.findOne @circularSecondId,
      transform: null # So that we can use test.equal

    test.equal @circularFirst,
      _id: @circularFirstId
      second:
        _id: @circularSecondId
        content: 'FooBar 2a'
      content: 'FooBar 1a'
      reverseSeconds: [
        _id: @circularSecondId
        content: 'FooBar 2a'
      ]
    test.equal @circularSecond,
      _id: @circularSecondId
      first:
        _id: @circularFirstId
        content: 'FooBar 1a'
      content: 'FooBar 2a'
      reverseFirsts: [
        _id: @circularFirstId
        content: 'FooBar 1a'
      ]

    CircularSecond.documents.remove @circularSecondId,
      expect (error) =>
        test.isFalse error, error?.toString?() or error

    # Wait so that observers have time to update documents
    waitForDatabase test, expect
,
  (test, expect) ->
    @circularFirst = CircularFirst.documents.findOne @circularFirstId,
      transform: null # So that we can use test.equal
    @circularSecond = CircularSecond.documents.findOne @circularSecondId,
      transform: null # So that we can use test.equal

    test.isFalse @circularSecond, @circularSecond

    # If directly referenced document is removed, dependency is removed as well
    test.isFalse @circularFirst, @circularFirst

    Log._intercept 1 if Meteor.isServer and Document.instances is 1

    CircularSecond.documents.insert
      first: null
      content: 'FooBar 2'
    ,
      expect (error, circularSecondId) =>
        test.isFalse error, error?.toString?() or error
        test.isTrue circularSecondId
        @circularSecondId = circularSecondId
,
  (test, expect) ->
    CircularFirst.documents.insert
      second:
        _id: @circularSecondId
      content: 'FooBar 1'
    ,
      expect (error, circularFirstId) =>
        test.isFalse error, error?.toString?() or error
        test.isTrue circularFirstId
        @circularFirstId = circularFirstId

    # Wait so that observers have time to update documents
    waitForDatabase test, expect
,
  (test, expect) ->
    if Meteor.isServer and Document.instances is 1
      intercepted = Log._intercepted()

      test.equal intercepted.length, 0, intercepted

    @circularFirst = CircularFirst.documents.findOne @circularFirstId,
      transform: null # So that we can use test.equal
    @circularSecond = CircularSecond.documents.findOne @circularSecondId,
      transform: null # So that we can use test.equal

    test.equal @circularFirst,
      _id: @circularFirstId
      second:
        _id: @circularSecondId
        content: 'FooBar 2'
      content: 'FooBar 1'
    test.equal @circularSecond,
      _id: @circularSecondId
      first: null
      content: 'FooBar 2'
      reverseFirsts: [
        _id: @circularFirstId
        content: 'FooBar 1'
      ]

    CircularSecond.documents.update @circularSecondId,
      $set:
        first:
          _id: @circularFirstId
    ,
      expect (error, res) =>
        test.isFalse error, error?.toString?() or error
        test.isTrue res

    # Wait so that observers have time to update documents
    waitForDatabase test, expect
,
  (test, expect) ->
    @circularFirst = CircularFirst.documents.findOne @circularFirstId,
      transform: null # So that we can use test.equal
    @circularSecond = CircularSecond.documents.findOne @circularSecondId,
      transform: null # So that we can use test.equal

    test.equal @circularFirst,
      _id: @circularFirstId
      second:
        _id: @circularSecondId
        content: 'FooBar 2'
      content: 'FooBar 1'
      reverseSeconds: [
        _id: @circularSecondId
        content: 'FooBar 2'
      ]
    test.equal @circularSecond,
      _id: @circularSecondId
      first:
        _id: @circularFirstId
        content: 'FooBar 1'
      content: 'FooBar 2'
      reverseFirsts: [
        _id: @circularFirstId
        content: 'FooBar 1'
      ]

    CircularFirst.documents.remove @circularFirstId,
      expect (error) =>
        test.isFalse error, error?.toString?() or error

    # Wait so that observers have time to update document
    waitForDatabase test, expect
,
  (test, expect) ->
    @circularFirst = CircularFirst.documents.findOne @circularFirstId,
      transform: null # So that we can use test.equal
    @circularSecond = CircularSecond.documents.findOne @circularSecondId,
      transform: null # So that we can use test.equal

    test.isFalse @circularFirst, @circularFirst

    # If directly referenced but optional document is removed, dependency is not removed as well, but set to null
    test.equal @circularSecond,
      _id: @circularSecondId
      first: null
      content: 'FooBar 2'
      reverseFirsts: []
]

testAsyncMulti 'peerdb - recursive two', [
  (test, expect) ->
    Recursive.documents.insert
      other: null
      content: 'FooBar 1'
    ,
      expect (error, recursive1Id) =>
        test.isFalse error, error?.toString?() or error
        test.isTrue recursive1Id
        @recursive1Id = recursive1Id

    Recursive.documents.insert
      other: null
      content: 'FooBar 2'
    ,
      expect (error, recursive2Id) =>
        test.isFalse error, error?.toString?() or error
        test.isTrue recursive2Id
        @recursive2Id = recursive2Id

    # Wait so that observers have time to update documents
    waitForDatabase test, expect
,
  (test, expect) ->
    @recursive1 = Recursive.documents.findOne @recursive1Id,
      transform: null # So that we can use test.equal
    @recursive2 = Recursive.documents.findOne @recursive2Id,
      transform: null # So that we can use test.equal

    test.equal @recursive1,
      _id: @recursive1Id
      other: null
      content: 'FooBar 1'
    test.equal @recursive2,
      _id: @recursive2Id
      other: null
      content: 'FooBar 2'

    Recursive.documents.update @recursive1Id,
      $set:
        other:
          _id: @recursive2Id
    ,
      expect (error, res) =>
        test.isFalse error, error?.toString?() or error
        test.isTrue res

    # Wait so that observers have time to update documents
    waitForDatabase test, expect
,
  (test, expect) ->
    @recursive1 = Recursive.documents.findOne @recursive1Id,
      transform: null # So that we can use test.equal
    @recursive2 = Recursive.documents.findOne @recursive2Id,
      transform: null # So that we can use test.equal

    test.equal @recursive1,
      _id: @recursive1Id
      other:
        _id: @recursive2Id
        content: 'FooBar 2'
      content: 'FooBar 1'
    test.equal @recursive2,
      _id: @recursive2Id
      other: null
      content: 'FooBar 2'
      reverse: [
        _id: @recursive1Id
        content: 'FooBar 1'
      ]

    Recursive.documents.update @recursive2Id,
      $set:
        other:
          _id: @recursive1Id
    ,
      expect (error, res) =>
        test.isFalse error, error?.toString?() or error
        test.isTrue res

    # Wait so that observers have time to update documents
    waitForDatabase test, expect
,
  (test, expect) ->
    @recursive1 = Recursive.documents.findOne @recursive1Id,
      transform: null # So that we can use test.equal
    @recursive2 = Recursive.documents.findOne @recursive2Id,
      transform: null # So that we can use test.equal

    test.equal @recursive1,
      _id: @recursive1Id
      other:
        _id: @recursive2Id
        content: 'FooBar 2'
      content: 'FooBar 1'
      reverse: [
        _id: @recursive2Id
        content: 'FooBar 2'
      ]
    test.equal @recursive2,
      _id: @recursive2Id
      other:
        _id: @recursive1Id
        content: 'FooBar 1'
      content: 'FooBar 2'
      reverse: [
        _id: @recursive1Id
        content: 'FooBar 1'
      ]

    Recursive.documents.update @recursive1Id,
      $set:
        content: 'FooBar 1a'
    ,
      expect (error, res) =>
        test.isFalse error, error?.toString?() or error
        test.isTrue res

    # Wait so that observers have time to update documents
    waitForDatabase test, expect
,
  (test, expect) ->
    @recursive1 = Recursive.documents.findOne @recursive1Id,
      transform: null # So that we can use test.equal
    @recursive2 = Recursive.documents.findOne @recursive2Id,
      transform: null # So that we can use test.equal

    test.equal @recursive1,
      _id: @recursive1Id
      other:
        _id: @recursive2Id
        content: 'FooBar 2'
      content: 'FooBar 1a'
      reverse: [
        _id: @recursive2Id
        content: 'FooBar 2'
      ]
    test.equal @recursive2,
      _id: @recursive2Id
      other:
        _id: @recursive1Id
        content: 'FooBar 1a'
      content: 'FooBar 2'
      reverse: [
        _id: @recursive1Id
        content: 'FooBar 1a'
      ]

    Recursive.documents.update @recursive2Id,
      $set:
        content: 'FooBar 2a'
    ,
      expect (error, res) =>
        test.isFalse error, error?.toString?() or error
        test.isTrue res

    # Wait so that observers have time to update documents
    waitForDatabase test, expect
,
  (test, expect) ->
    @recursive1 = Recursive.documents.findOne @recursive1Id,
      transform: null # So that we can use test.equal
    @recursive2 = Recursive.documents.findOne @recursive2Id,
      transform: null # So that we can use test.equal

    test.equal @recursive1,
      _id: @recursive1Id
      other:
        _id: @recursive2Id
        content: 'FooBar 2a'
      content: 'FooBar 1a'
      reverse: [
        _id: @recursive2Id
        content: 'FooBar 2a'
      ]
    test.equal @recursive2,
      _id: @recursive2Id
      other:
        _id: @recursive1Id
        content: 'FooBar 1a'
      content: 'FooBar 2a'
      reverse: [
        _id: @recursive1Id
        content: 'FooBar 1a'
      ]

    Recursive.documents.remove @recursive2Id,
      expect (error) =>
        test.isFalse error, error?.toString?() or error

    # Wait so that observers have time to update documents
    waitForDatabase test, expect
,
  (test, expect) ->
    @recursive1 = Recursive.documents.findOne @recursive1Id,
      transform: null # So that we can use test.equal
    @recursive2 = Recursive.documents.findOne @recursive2Id,
      transform: null # So that we can use test.equal

    test.isFalse @recursive2, @recursive2

    test.equal @recursive1,
      _id: @recursive1Id
      other: null
      content: 'FooBar 1a'
      reverse: []
]

testAsyncMulti 'peerdb - recursive one', [
  (test, expect) ->
    Recursive.documents.insert
      other: null
      content: 'FooBar'
    ,
      expect (error, recursiveId) =>
        test.isFalse error, error?.toString?() or error
        test.isTrue recursiveId
        @recursiveId = recursiveId

    # Wait so that observers have time to update documents
    waitForDatabase test, expect
,
  (test, expect) ->
    @recursive = Recursive.documents.findOne @recursiveId,
      transform: null # So that we can use test.equal

    test.equal @recursive,
      _id: @recursiveId
      other: null
      content: 'FooBar'

    Recursive.documents.update @recursiveId,
      $set:
        other:
          _id: @recursiveId
    ,
      expect (error, res) =>
        test.isFalse error, error?.toString?() or error
        test.isTrue res

    # Wait so that observers have time to update documents
    waitForDatabase test, expect
,
  (test, expect) ->
    @recursive = Recursive.documents.findOne @recursiveId,
      transform: null # So that we can use test.equal

    test.equal @recursive,
      _id: @recursiveId
      other:
        _id: @recursiveId
        content: 'FooBar'
      content: 'FooBar'
      reverse: [
        _id: @recursiveId
        content: 'FooBar'
      ]

    Recursive.documents.update @recursiveId,
      $set:
        content: 'FooBara'
    ,
      expect (error, res) =>
        test.isFalse error, error?.toString?() or error
        test.isTrue res

    # Wait so that observers have time to update documents
    waitForDatabase test, expect
,
  (test, expect) ->
    @recursive = Recursive.documents.findOne @recursiveId,
      transform: null # So that we can use test.equal

    test.equal @recursive,
      _id: @recursiveId
      other:
        _id: @recursiveId
        content: 'FooBara'
      content: 'FooBara'
      reverse: [
        _id: @recursiveId
        content: 'FooBara'
      ]

    Recursive.documents.remove @recursiveId,
      expect (error) =>
        test.isFalse error, error?.toString?() or error

    # Wait so that observers have time to update documents
    waitForDatabase test, expect
,
  (test, expect) ->
    @recursive = Recursive.documents.findOne @recursiveId,
      transform: null # So that we can use test.equal

    test.isFalse @recursive, @recursive
]

if Meteor.isServer and Document.instances is 1
  Tinytest.add 'peerdb - errors', (test) ->
    Log._intercept 2 # Two to see if we catch more than expected

    postId = Post.documents.insert
      author:
        _id: 'nonexistent'

    # Wait so that observers have time to update documents
    Meteor.call 'wait-for-database'

    intercepted = Log._intercepted()

    test.equal intercepted.length, 1, intercepted

    test.isTrue _.isString(intercepted[0]), intercepted[0]
    intercepted = EJSON.parse intercepted[0]

    test.equal intercepted.message, "Document 'Post' '#{ postId }' field 'author' is referencing a nonexistent document 'nonexistent'"
    test.equal intercepted.level, 'error'

    Log._intercept 2 # Two to see if we catch more than expected

    postId = Post.documents.insert
      subscribers: 'foobar'

    # Wait so that observers have time to update documents
    Meteor.call 'wait-for-database'

    intercepted = Log._intercepted()

    test.equal intercepted.length, 1, intercepted

    test.isTrue _.isString(intercepted[0]), intercepted[0]
    intercepted = EJSON.parse intercepted[0]

    test.equal intercepted.message, "Document 'Post' '#{ postId }' field 'subscribers' was updated with a non-array value: 'foobar'"
    test.equal intercepted.level, 'error'

    Log._intercept 2 # Two to see if we catch more than expected

    postId = Post.documents.insert
      subscribers: [
        _id: 'nonexistent'
      ]

    # Wait so that observers have time to update documents
    Meteor.call 'wait-for-database'

    intercepted = Log._intercepted()

    test.equal intercepted.length, 1, intercepted

    test.isTrue _.isString(intercepted[0]), intercepted[0]
    intercepted = EJSON.parse intercepted[0]

    test.equal intercepted.message, "Document 'Post' '#{ postId }' field 'subscribers' is referencing a nonexistent document 'nonexistent'"
    test.equal intercepted.level, 'error'

    Log._intercept 2 # Two to see if we catch more than expected

    postId = Post.documents.insert
      author: null

    # Wait so that observers have time to update documents
    Meteor.call 'wait-for-database'

    intercepted = Log._intercepted()

    test.equal intercepted.length, 1, intercepted

    test.isTrue _.isString(intercepted[0]), intercepted[0]
    intercepted = EJSON.parse intercepted[0]

    test.equal intercepted.message, "Document 'Post' '#{ postId }' field 'author' was updated with an invalid value: null"
    test.equal intercepted.level, 'error'

    Log._intercept 1

    userLinkId = UserLink.documents.insert
      user: null

    # Wait so that observers have time to update documents
    Meteor.call 'wait-for-database'

    intercepted = Log._intercepted()

    # There should be no warning because user is optional
    test.equal intercepted.length, 0, intercepted

testAsyncMulti 'peerdb - delayed defintion', [
  (test, expect) ->
    class BadPost5 extends Document
      @Meta
        name: 'BadPost5'
        fields: ->
          author: @ReferenceField undefined, ['username']

    Log._intercept 2 # Two to see if we catch more than expected

    # Sleep so that error is shown
    Meteor.setTimeout expect(), 1000 # We need 1000 here because we have a check which runs after 1000 ms to check for delayed definitions
,
  (test, expect) ->
    intercepted = Log._intercepted()

    # One or two because we could intercepted something else as well
    test.isTrue 1 <= intercepted.length <= 2, intercepted

    # Let's find it
    for i in intercepted
      break if i.indexOf('BadPost5') isnt -1
    test.isTrue _.isString(i), i
    intercepted = EJSON.parse i

    test.equal intercepted.message.lastIndexOf("Not all delayed document definitions were successfully retried:\nBadPost5 from"), 0, intercepted.message
    test.equal intercepted.level, 'error'

    testDocumentList test, ALL
    test.equal Document._delayed.length, 1

    # Clear delayed so that we can retry tests without errors
    Document._delayed = []
    Document._clearDelayedCheck()
]

testAsyncMulti 'peerdb - subdocument fields', [
  (test, expect) ->
    Person.documents.insert
      username: 'person1'
      displayName: 'Person 1'
      field1: 'Field 1 - 1'
      field2: 'Field 1 - 2'
    ,
      expect (error, person1Id) =>
        test.isFalse error, error?.toString?() or error
        test.isTrue person1Id
        @person1Id = person1Id

    Person.documents.insert
      username: 'person2'
      displayName: 'Person 2'
      field1: 'Field 2 - 1'
      field2: 'Field 2 - 2'
    ,
      expect (error, person2Id) =>
        test.isFalse error, error?.toString?() or error
        test.isTrue person2Id
        @person2Id = person2Id

    Person.documents.insert
      username: 'person3'
      displayName: 'Person 3'
      field1: 'Field 3 - 1'
      field2: 'Field 3 - 2'
    ,
      expect (error, person3Id) =>
        test.isFalse error, error?.toString?() or error
        test.isTrue person3Id
        @person3Id = person3Id

    # Wait so that observers have time to update documents
    waitForDatabase test, expect
,
  (test, expect) ->
    @person1 = Person.documents.findOne @person1Id,
      transform: null # So that we can use test.equal
    @person2 = Person.documents.findOne @person2Id,
      transform: null # So that we can use test.equal
    @person3 = Person.documents.findOne @person3Id,
      transform: null # So that we can use test.equal

    test.equal @person1,
      _id: @person1Id
      username: 'person1'
      displayName: 'Person 1'
      field1: 'Field 1 - 1'
      field2: 'Field 1 - 2'
      count: 0
    test.equal @person2,
      _id: @person2Id
      username: 'person2'
      displayName: 'Person 2'
      field1: 'Field 2 - 1'
      field2: 'Field 2 - 2'
      count: 0
    test.equal @person3,
      _id: @person3Id
      username: 'person3'
      displayName: 'Person 3'
      field1: 'Field 3 - 1'
      field2: 'Field 3 - 2'
      count: 0

    Post.documents.insert
      author:
        _id: @person1._id
      subscribers: [
        _id: @person2._id
      ,
        _id: @person3._id
      ]
      reviewers: [
        _id: @person2._id
      ,
        _id: @person3._id
      ]
      subdocument:
        person:
          _id: @person2._id
        persons: [
          _id: @person2._id
        ,
          _id: @person3._id
        ]
        body: 'SubdocumentFooBar'
      nested: [
        required:
          _id: @person2._id
        optional:
          _id: @person3._id
        body: 'NestedFooBar'
      ]
      body: 'FooBar'
    ,
      expect (error, postId) =>
        test.isFalse error, error?.toString?() or error
        test.isTrue postId
        @postId = postId

    # Wait so that observers have time to update documents
    waitForDatabase test, expect
,
  (test, expect) ->
    @post = Post.documents.findOne @postId,
      transform: null # So that we can use test.equal

    test.equal @post,
      _id: @postId
      author:
        _id: @person1._id
        username: @person1.username
        displayName: @person1.displayName
        field1: @person1.field1
        field2: @person1.field2
      subscribers: [
        _id: @person2._id
      ,
        _id: @person3._id
      ]
      reviewers: [
        _id: @person2._id
        username: @person2.username
      ,
        _id: @person3._id
        username: @person3.username
      ]
      subdocument:
        person:
          _id: @person2._id
          username: @person2.username
          displayName: @person2.displayName
          field1: @person2.field1
          field2: @person2.field2
        persons: [
          _id: @person2._id
          username: @person2.username
          displayName: @person2.displayName
          field1: @person2.field1
          field2: @person2.field2
        ,
          _id: @person3._id
          username: @person3.username
          displayName: @person3.displayName
          field1: @person3.field1
          field2: @person3.field2
        ]
        slug: 'subdocument-prefix-foobar-subdocumentfoobar-suffix'
        body: 'SubdocumentFooBar'
      nested: [
        required:
          _id: @person2._id
          username: @person2.username
          displayName: @person2.displayName
          field1: @person2.field1
          field2: @person2.field2
        optional:
          _id: @person3._id
          username: @person3.username
        slug: 'nested-prefix-foobar-nestedfoobar-suffix'
        body: 'NestedFooBar'
      ]
      body: 'FooBar'
      slug: 'prefix-foobar-subdocumentfoobar-suffix'
      tags: [
        'tag-0-prefix-foobar-subdocumentfoobar-suffix'
        'tag-1-prefix-foobar-nestedfoobar-suffix'
      ]

    PostLink.documents.insert
      post:
        _id: @post._id
    ,
      expect (error, postLinkId) =>
        test.isFalse error, error?.toString?() or error
        test.isTrue postLinkId
        @postLinkId = postLinkId

    # Wait so that observers have time to update documents
    waitForDatabase test, expect
,
  (test, expect) ->
    @postLink = PostLink.documents.findOne @postLinkId,
      transform: null # So that we can use test.equal

    test.equal @postLink,
      _id: @postLinkId
      post:
        _id: @post._id
        subdocument:
          person:
            _id: @person2._id
            username: @person2.username
            displayName: @person2.displayName
            field1: @person2.field1
            field2: @person2.field2
          persons: [
            _id: @person2._id
            username: @person2.username
            displayName: @person2.displayName
            field1: @person2.field1
            field2: @person2.field2
          ,
            _id: @person3._id
            username: @person3.username
            displayName: @person3.displayName
            field1: @person3.field1
            field2: @person3.field2
          ]

    Person.documents.update @person2Id,
      $set:
        username: 'person2a'
    ,
      expect (error, res) =>
        test.isFalse error, error?.toString?() or error
        test.isTrue res

    # Wait so that observers have time to update documents
    waitForDatabase test, expect
,
  (test, expect) ->
    @person2 = Person.documents.findOne @person2Id,
      transform: null # So that we can use test.equal

    test.equal @person2,
      _id: @person2Id
      username: 'person2a'
      displayName: 'Person 2'
      field1: 'Field 2 - 1'
      field2: 'Field 2 - 2'
      subdocument:
        posts: [
          _id: @postId
          body: 'FooBar'
          nested: [
            body: 'NestedFooBar'
          ]
          subdocument:
            body: 'SubdocumentFooBar'
        ]
      subdocumentsPosts: [
        _id: @postId
        body: 'FooBar'
        nested: [
          body: 'NestedFooBar'
        ]
        subdocument:
          body: 'SubdocumentFooBar'
      ]
      nestedPosts: [
        _id: @postId
        body: 'FooBar'
        nested: [
          body: 'NestedFooBar'
        ]
        subdocument:
          body: 'SubdocumentFooBar'
      ]
      count: 3

    @postLink = PostLink.documents.findOne @postLinkId,
      transform: null # So that we can use test.equal

    test.equal @postLink,
      _id: @postLinkId
      post:
        _id: @post._id
        subdocument:
          person:
            _id: @person2._id
            username: @person2.username
            displayName: @person2.displayName
            field1: @person2.field1
            field2: @person2.field2
          persons: [
            _id: @person2._id
            username: @person2.username
            displayName: @person2.displayName
            field1: @person2.field1
            field2: @person2.field2
          ,
            _id: @person3._id
            username: @person3.username
            displayName: @person3.displayName
            field1: @person3.field1
            field2: @person3.field2
          ]

    Person.documents.remove @person2Id,
      expect (error) =>
        test.isFalse error, error?.toString?() or error

    # Wait so that observers have time to update documents
    waitForDatabase test, expect
,
  (test, expect) ->
    @postLink = PostLink.documents.findOne @postLinkId,
      transform: null # So that we can use test.equal

    test.equal @postLink,
      _id: @postLinkId
      post:
        _id: @post._id
        subdocument:
          person: null
          persons: [
            _id: @person3._id
            username: @person3.username
            displayName: @person3.displayName
            field1: @person3.field1
            field2: @person3.field2
          ]

    Post.documents.remove @post._id,
      expect (error) =>
        test.isFalse error, error?.toString?() or error

    # Wait so that observers have time to update documents
    waitForDatabase test, expect
,
  (test, expect) ->
    @postLink = PostLink.documents.findOne @postLinkId,
      transform: null # So that we can use test.equal

    test.isFalse @postLink, @postLink
]

testAsyncMulti 'peerdb - generated fields', [
  (test, expect) ->
    Person.documents.insert
      username: 'person1'
      displayName: 'Person 1'
    ,
      expect (error, person1Id) =>
        test.isFalse error, error?.toString?() or error
        test.isTrue person1Id
        @person1Id = person1Id

    Person.documents.insert
      username: 'person2'
      displayName: 'Person 2'
    ,
      expect (error, person2Id) =>
        test.isFalse error, error?.toString?() or error
        test.isTrue person2Id
        @person2Id = person2Id

    Person.documents.insert
      username: 'person3'
      displayName: 'Person 3'
    ,
      expect (error, person3Id) =>
        test.isFalse error, error?.toString?() or error
        test.isTrue person3Id
        @person3Id = person3Id

    # Wait so that observers have time to update documents
    waitForDatabase test, expect
,
  (test, expect) ->
    @person1 = Person.documents.findOne @person1Id,
      transform: null # So that we can use test.equal
    @person2 = Person.documents.findOne @person2Id,
      transform: null # So that we can use test.equal
    @person3 = Person.documents.findOne @person3Id,
      transform: null # So that we can use test.equal

    test.equal @person1,
      _id: @person1Id
      username: 'person1'
      displayName: 'Person 1'
      count: 0
    test.equal @person2,
      _id: @person2Id
      username: 'person2'
      displayName: 'Person 2'
      count: 0
    test.equal @person3,
      _id: @person3Id
      username: 'person3'
      displayName: 'Person 3'
      count: 0

    Post.documents.insert
      author:
        _id: @person1._id
      subscribers: [
        _id: @person2._id
      ,
        _id: @person3._id
      ]
      reviewers: [
        _id: @person2._id
      ,
        _id: @person3._id
      ]
      subdocument:
        person:
          _id: @person2._id
        persons: [
          _id: @person2._id
        ,
          _id: @person3._id
        ]
        body: 'SubdocumentFooBar'
      nested: [
        required:
          _id: @person2._id
        optional:
          _id: @person3._id
        body: 'NestedFooBar'
      ]
      body: 'FooBar'
    ,
      expect (error, postId) =>
        test.isFalse error, error?.toString?() or error
        test.isTrue postId
        @postId = postId

    # Wait so that observers have time to update documents
    waitForDatabase test, expect
,
  (test, expect) ->
    @post = Post.documents.findOne @postId,
      transform: null # So that we can use test.equal

    test.equal @post,
      _id: @postId
      author:
        _id: @person1._id
        username: @person1.username
        displayName: @person1.displayName
      subscribers: [
        _id: @person2._id
      ,
        _id: @person3._id
      ]
      reviewers: [
        _id: @person2._id
        username: @person2.username
      ,
        _id: @person3._id
        username: @person3.username
      ]
      subdocument:
        person:
          _id: @person2._id
          username: @person2.username
          displayName: @person2.displayName
        persons: [
          _id: @person2._id
          username: @person2.username
          displayName: @person2.displayName
        ,
          _id: @person3._id
          username: @person3.username
          displayName: @person3.displayName
        ]
        slug: 'subdocument-prefix-foobar-subdocumentfoobar-suffix'
        body: 'SubdocumentFooBar'
      nested: [
        required:
          _id: @person2._id
          username: @person2.username
          displayName: @person2.displayName
        optional:
          _id: @person3._id
          username: @person3.username
        slug: 'nested-prefix-foobar-nestedfoobar-suffix'
        body: 'NestedFooBar'
      ]
      body: 'FooBar'
      slug: 'prefix-foobar-subdocumentfoobar-suffix'
      tags: [
        'tag-0-prefix-foobar-subdocumentfoobar-suffix'
        'tag-1-prefix-foobar-nestedfoobar-suffix'
      ]

    Post.documents.update @postId,
      $set:
        body: 'FooBarZ'
    ,
      expect (error, res) =>
        test.isFalse error, error?.toString?() or error
        test.isTrue res

    # Wait so that observers have time to update documents
    # so that persons updates are not merged together to better
    # test the code for multiple updates
    waitForDatabase test, expect
,
  (test, expect) ->
    @post = Post.documents.findOne @postId,
      transform: null # So that we can use test.equal

    # All persons had usernames changed, they should
    # be updated in the post as well, automatically
    test.equal @post,
      _id: @postId
      author:
        _id: @person1._id
        username: @person1.username
        displayName: @person1.displayName
      subscribers: [
        _id: @person2._id
      ,
        _id: @person3._id
      ]
      reviewers: [
        _id: @person2._id
        username: @person2.username
      ,
        _id: @person3._id
        username: @person3.username
      ]
      subdocument:
        person:
          _id: @person2._id
          username: @person2.username
          displayName: @person2.displayName
        persons: [
          _id: @person2._id
          username: @person2.username
          displayName: @person2.displayName
        ,
          _id: @person3._id
          username: @person3.username
          displayName: @person3.displayName
        ]
        slug: 'subdocument-prefix-foobarz-subdocumentfoobar-suffix'
        body: 'SubdocumentFooBar'
      nested: [
        required:
          _id: @person2._id
          username: @person2.username
          displayName: @person2.displayName
        optional:
          _id: @person3._id
          username: @person3.username
        slug: 'nested-prefix-foobarz-nestedfoobar-suffix'
        body: 'NestedFooBar'
      ]
      body: 'FooBarZ'
      slug: 'prefix-foobarz-subdocumentfoobar-suffix'
      tags: [
        'tag-0-prefix-foobarz-subdocumentfoobar-suffix'
        'tag-1-prefix-foobarz-nestedfoobar-suffix'
      ]

    Post.documents.update @postId,
      $set:
        'subdocument.body': 'SubdocumentFooBarZ'
    ,
      expect (error, res) =>
        test.isFalse error, error?.toString?() or error
        test.isTrue res

    # Wait so that observers have time to update documents
    # so that persons updates are not merged together to better
    # test the code for multiple updates
    waitForDatabase test, expect
,
   (test, expect) ->
    @post = Post.documents.findOne @postId,
      transform: null # So that we can use test.equal

    # All persons had usernames changed, they should
    # be updated in the post as well, automatically
    test.equal @post,
      _id: @postId
      author:
        _id: @person1._id
        username: @person1.username
        displayName: @person1.displayName
      subscribers: [
        _id: @person2._id
      ,
        _id: @person3._id
      ]
      reviewers: [
        _id: @person2._id
        username: @person2.username
      ,
        _id: @person3._id
        username: @person3.username
      ]
      subdocument:
        person:
          _id: @person2._id
          username: @person2.username
          displayName: @person2.displayName
        persons: [
          _id: @person2._id
          username: @person2.username
          displayName: @person2.displayName
        ,
          _id: @person3._id
          username: @person3.username
          displayName: @person3.displayName
        ]
        slug: 'subdocument-prefix-foobarz-subdocumentfoobarz-suffix'
        body: 'SubdocumentFooBarZ'
      nested: [
        required:
          _id: @person2._id
          username: @person2.username
          displayName: @person2.displayName
        optional:
          _id: @person3._id
          username: @person3.username
        slug: 'nested-prefix-foobarz-nestedfoobar-suffix'
        body: 'NestedFooBar'
      ]
      body: 'FooBarZ'
      slug: 'prefix-foobarz-subdocumentfoobarz-suffix'
      tags: [
        'tag-0-prefix-foobarz-subdocumentfoobarz-suffix'
        'tag-1-prefix-foobarz-nestedfoobar-suffix'
      ]

    Post.documents.update @postId,
      $set:
        'nested.0.body': 'NestedFooBarZ'
    ,
      expect (error, res) =>
        test.isFalse error, error?.toString?() or error
        test.isTrue res

    # Wait so that observers have time to update documents
    # so that persons updates are not merged together to better
    # test the code for multiple updates
    waitForDatabase test, expect
,
   (test, expect) ->
    @post = Post.documents.findOne @postId,
      transform: null # So that we can use test.equal

    # All persons had usernames changed, they should
    # be updated in the post as well, automatically
    test.equal @post,
      _id: @postId
      author:
        _id: @person1._id
        username: @person1.username
        displayName: @person1.displayName
      subscribers: [
        _id: @person2._id
      ,
        _id: @person3._id
      ]
      reviewers: [
        _id: @person2._id
        username: @person2.username
      ,
        _id: @person3._id
        username: @person3.username
      ]
      subdocument:
        person:
          _id: @person2._id
          username: @person2.username
          displayName: @person2.displayName
        persons: [
          _id: @person2._id
          username: @person2.username
          displayName: @person2.displayName
        ,
          _id: @person3._id
          username: @person3.username
          displayName: @person3.displayName
        ]
        slug: 'subdocument-prefix-foobarz-subdocumentfoobarz-suffix'
        body: 'SubdocumentFooBarZ'
      nested: [
        required:
          _id: @person2._id
          username: @person2.username
          displayName: @person2.displayName
        optional:
          _id: @person3._id
          username: @person3.username
        slug: 'nested-prefix-foobarz-nestedfoobarz-suffix'
        body: 'NestedFooBarZ'
      ]
      body: 'FooBarZ'
      slug: 'prefix-foobarz-subdocumentfoobarz-suffix'
      tags: [
        'tag-0-prefix-foobarz-subdocumentfoobarz-suffix'
        'tag-1-prefix-foobarz-nestedfoobarz-suffix'
      ]

    Post.documents.update @postId,
      $set:
        body: null
    ,
      expect (error, res) =>
        test.isFalse error, error?.toString?() or error
        test.isTrue res

    # Wait so that observers have time to update documents
    waitForDatabase test, expect
,
  (test, expect) ->
    @post = Post.documents.findOne @postId,
      transform: null # So that we can use test.equal

    test.equal @post,
      _id: @postId
      author:
        _id: @person1._id
        username: @person1.username
        displayName: @person1.displayName
      subscribers: [
        _id: @person2._id
      ,
        _id: @person3._id
      ]
      reviewers: [
        _id: @person2._id
        username: @person2.username
      ,
        _id: @person3._id
        username: @person3.username
      ]
      subdocument:
        person:
          _id: @person2._id
          username: @person2.username
          displayName: @person2.displayName
        persons: [
          _id: @person2._id
          username: @person2.username
          displayName: @person2.displayName
        ,
          _id: @person3._id
          username: @person3.username
          displayName: @person3.displayName
        ]
        slug: null
        body: 'SubdocumentFooBarZ'
      nested: [
        required:
          _id: @person2._id
          username: @person2.username
          displayName: @person2.displayName
        optional:
          _id: @person3._id
          username: @person3.username
        slug: null
        body: 'NestedFooBarZ'
      ]
      body: null
      slug: null
      tags: []

    Post.documents.update @postId,
      $unset:
        body: ''
    ,
      expect (error, res) =>
        test.isFalse error, error?.toString?() or error
        test.isTrue res

    # Wait so that observers have time to update documents
    waitForDatabase test, expect
,
  (test, expect) ->
    @post = Post.documents.findOne @postId,
      transform: null # So that we can use test.equal

    test.equal @post,
      _id: @postId
      author:
        _id: @person1._id
        username: @person1.username
        displayName: @person1.displayName
      subscribers: [
        _id: @person2._id
      ,
        _id: @person3._id
      ]
      reviewers: [
        _id: @person2._id
        username: @person2.username
      ,
        _id: @person3._id
        username: @person3.username
      ]
      subdocument:
        person:
          _id: @person2._id
          username: @person2.username
          displayName: @person2.displayName
        persons: [
          _id: @person2._id
          username: @person2.username
          displayName: @person2.displayName
        ,
          _id: @person3._id
          username: @person3.username
          displayName: @person3.displayName
        ]
        body: 'SubdocumentFooBarZ'
      nested: [
        required:
          _id: @person2._id
          username: @person2.username
          displayName: @person2.displayName
        optional:
          _id: @person3._id
          username: @person3.username
        body: 'NestedFooBarZ'
      ]
      tags: []
]

Tinytest.add 'peerdb - chain of extended classes', (test) ->
  list = _.clone Document.list

  firstReferenceA = undefined # To force delayed
  secondReferenceA = undefined # To force delayed
  firstReferenceB = undefined # To force delayed
  secondReferenceB = undefined # To force delayed

  class First extends Document
    @Meta
      name: 'First'
      fields: ->
        first: @ReferenceField firstReferenceA

  class Second extends First
    @Meta
      name: 'Second'
      fields: (fields) ->
        fields.second = @ReferenceField Post # Not undefined, but overall meta will still be delayed
        fields

  class Third extends Second
    @Meta
      name: 'Third'
      fields: (fields) ->
        fields.third = @ReferenceField secondReferenceA
        fields

  testDocumentList test, ALL
  test.equal Document._delayed.length, 3
  test.equal Document._delayed[0], First
  test.equal Document._delayed[1], Second
  test.equal Document._delayed[2], Third

  _TestFirst = First

  class First extends First
    @Meta
      name: 'First'
      replaceParent: true
      fields: (fields) ->
        fields.first = @ReferenceField firstReferenceB
        fields

  _TestSecond = Second

  class Second extends Second
    @Meta
      name: 'Second'
      replaceParent: true
      fields: (fields) ->
        fields.second = @ReferenceField Person # Not undefined, but overall meta will still be delayed
        fields

  _TestThird = Third

  class Third extends Third
    @Meta
      name: 'Third'
      replaceParent: true
      fields: (fields) ->
        fields.third = @ReferenceField secondReferenceB
        fields

  testDocumentList test, ALL
  test.equal Document._delayed.length, 6
  test.equal Document._delayed[0], _TestFirst
  test.equal Document._delayed[1], _TestSecond
  test.equal Document._delayed[2], _TestThird
  test.equal Document._delayed[3], First
  test.equal Document._delayed[4], Second
  test.equal Document._delayed[5], Third

  _TestThird2 = Third

  class Third extends Third
    @Meta
      name: 'Third'
      replaceParent: true
      fields: (fields) ->
        fields.third = @ReferenceField Person
        fields

  testDocumentList test, ALL
  test.equal Document._delayed.length, 7
  test.equal Document._delayed[0], _TestFirst
  test.equal Document._delayed[1], _TestSecond
  test.equal Document._delayed[2], _TestThird
  test.equal Document._delayed[3], First
  test.equal Document._delayed[4], Second
  test.equal Document._delayed[5], _TestThird2
  test.equal Document._delayed[6], Third

  _TestFirst2 = First

  class First extends First
    @Meta
      name: 'First'
      replaceParent: true
      fields: (fields) ->
        fields.first = @ReferenceField Person
        fields

  testDocumentList test, ALL
  test.equal Document._delayed.length, 8
  test.equal Document._delayed[0], _TestFirst
  test.equal Document._delayed[1], _TestSecond
  test.equal Document._delayed[2], _TestThird
  test.equal Document._delayed[3], _TestFirst2
  test.equal Document._delayed[4], Second
  test.equal Document._delayed[5], _TestThird2
  test.equal Document._delayed[6], Third
  test.equal Document._delayed[7], First

  firstReferenceA = First
  Document._retryDelayed()

  testDocumentList test, ALL.concat [_TestFirst, Second]
  test.equal Document._delayed.length, 5
  test.equal Document._delayed[0], _TestThird
  test.equal Document._delayed[1], _TestFirst2
  test.equal Document._delayed[2], _TestThird2
  test.equal Document._delayed[3], Third
  test.equal Document._delayed[4], First

  test.equal Second.Meta._name, 'Second'
  test.equal Second.Meta.parent, _TestSecond.Meta
  test.equal Second.Meta.document, Second
  test.equal Second.Meta.collection._name, 'Seconds'
  test.equal _.size(Second.Meta.fields), 2
  test.instanceOf Second.Meta.fields.first, Second._ReferenceField
  test.isFalse Second.Meta.fields.first.ancestorArray, Second.Meta.fields.first.ancestorArray
  test.isTrue Second.Meta.fields.first.required
  test.equal Second.Meta.fields.first.sourcePath, 'first'
  test.equal Second.Meta.fields.first.sourceDocument, Second
  test.equal Second.Meta.fields.first.targetDocument, firstReferenceA
  test.equal Second.Meta.fields.first.sourceCollection._name, 'Seconds'
  test.equal Second.Meta.fields.first.targetCollection._name, 'Firsts'
  test.equal Second.Meta.fields.first.sourceDocument.Meta.collection._name, 'Seconds'
  test.equal Second.Meta.fields.first.targetDocument.Meta.collection._name, 'Firsts'
  test.equal Second.Meta.fields.first.fields, []
  test.isNull Second.Meta.fields.first.reverseName
  test.equal Second.Meta.fields.first.reverseFields, []
  test.instanceOf Second.Meta.fields.second, Second._ReferenceField
  test.isFalse Second.Meta.fields.second.ancestorArray, Second.Meta.fields.second.ancestorArray
  test.isTrue Second.Meta.fields.second.required
  test.equal Second.Meta.fields.second.sourcePath, 'second'
  test.equal Second.Meta.fields.second.sourceDocument, Second
  test.equal Second.Meta.fields.second.targetDocument, Person
  test.equal Second.Meta.fields.second.sourceCollection._name, 'Seconds'
  test.equal Second.Meta.fields.second.targetCollection._name, 'Persons'
  test.equal Second.Meta.fields.second.sourceDocument.Meta.collection._name, 'Seconds'
  test.equal Second.Meta.fields.second.targetDocument.Meta.collection._name, 'Persons'
  test.equal Second.Meta.fields.second.fields, []
  test.isNull Second.Meta.fields.second.reverseName
  test.equal Second.Meta.fields.second.reverseFields, []

  firstReferenceB = Post
  Document._retryDelayed()

  testDocumentList test, ALL.concat [Second, First]
  test.equal Document._delayed.length, 3
  test.equal Document._delayed[0], _TestThird
  test.equal Document._delayed[1], _TestThird2
  test.equal Document._delayed[2], Third

  test.equal Second.Meta._name, 'Second'
  test.equal Second.Meta.parent, _TestSecond.Meta
  test.equal Second.Meta.document, Second
  test.equal Second.Meta.collection._name, 'Seconds'
  test.equal _.size(Second.Meta.fields), 2
  test.instanceOf Second.Meta.fields.first, Second._ReferenceField
  test.isFalse Second.Meta.fields.first.ancestorArray, Second.Meta.fields.first.ancestorArray
  test.isTrue Second.Meta.fields.first.required
  test.equal Second.Meta.fields.first.sourcePath, 'first'
  test.equal Second.Meta.fields.first.sourceDocument, Second
  test.equal Second.Meta.fields.first.targetDocument, firstReferenceA
  test.equal Second.Meta.fields.first.sourceCollection._name, 'Seconds'
  test.equal Second.Meta.fields.first.targetCollection._name, 'Firsts'
  test.equal Second.Meta.fields.first.sourceDocument.Meta.collection._name, 'Seconds'
  test.equal Second.Meta.fields.first.targetDocument.Meta.collection._name, 'Firsts'
  test.equal Second.Meta.fields.first.fields, []
  test.isNull Second.Meta.fields.first.reverseName
  test.equal Second.Meta.fields.first.reverseFields, []
  test.instanceOf Second.Meta.fields.second, Second._ReferenceField
  test.isFalse Second.Meta.fields.second.ancestorArray, Second.Meta.fields.second.ancestorArray
  test.isTrue Second.Meta.fields.second.required
  test.equal Second.Meta.fields.second.sourcePath, 'second'
  test.equal Second.Meta.fields.second.sourceDocument, Second
  test.equal Second.Meta.fields.second.targetDocument, Person
  test.equal Second.Meta.fields.second.sourceCollection._name, 'Seconds'
  test.equal Second.Meta.fields.second.targetCollection._name, 'Persons'
  test.equal Second.Meta.fields.second.sourceDocument.Meta.collection._name, 'Seconds'
  test.equal Second.Meta.fields.second.targetDocument.Meta.collection._name, 'Persons'
  test.equal Second.Meta.fields.second.fields, []
  test.isNull Second.Meta.fields.second.reverseName
  test.equal Second.Meta.fields.second.reverseFields, []

  test.equal First.Meta._name, 'First'
  test.equal First.Meta.parent, _TestFirst2.Meta
  test.equal First.Meta.document, First
  test.equal First.Meta.collection._name, 'Firsts'
  test.equal _.size(First.Meta.fields), 1
  test.instanceOf First.Meta.fields.first, First._ReferenceField
  test.isFalse First.Meta.fields.first.ancestorArray, First.Meta.fields.first.ancestorArray
  test.isTrue First.Meta.fields.first.required
  test.equal First.Meta.fields.first.sourcePath, 'first'
  test.equal First.Meta.fields.first.sourceDocument, First
  test.equal First.Meta.fields.first.targetDocument, Person
  test.equal First.Meta.fields.first.sourceCollection._name, 'Firsts'
  test.equal First.Meta.fields.first.targetCollection._name, 'Persons'
  test.equal First.Meta.fields.first.sourceDocument.Meta.collection._name, 'Firsts'
  test.equal First.Meta.fields.first.targetDocument.Meta.collection._name, 'Persons'
  test.equal First.Meta.fields.first.fields, []
  test.isNull First.Meta.fields.first.reverseName
  test.equal First.Meta.fields.first.reverseFields, []

  secondReferenceA = First
  Document._retryDelayed()

  testDocumentList test, ALL.concat [Second, First, _TestThird]
  test.equal Document._delayed.length, 2
  test.equal Document._delayed[0], _TestThird2
  test.equal Document._delayed[1], Third

  test.equal Second.Meta._name, 'Second'
  test.equal Second.Meta.parent, _TestSecond.Meta
  test.equal Second.Meta.document, Second
  test.equal Second.Meta.collection._name, 'Seconds'
  test.equal _.size(Second.Meta.fields), 2
  test.instanceOf Second.Meta.fields.first, Second._ReferenceField
  test.isFalse Second.Meta.fields.first.ancestorArray, Second.Meta.fields.first.ancestorArray
  test.isTrue Second.Meta.fields.first.required
  test.equal Second.Meta.fields.first.sourcePath, 'first'
  test.equal Second.Meta.fields.first.sourceDocument, Second
  test.equal Second.Meta.fields.first.targetDocument, firstReferenceA
  test.equal Second.Meta.fields.first.sourceCollection._name, 'Seconds'
  test.equal Second.Meta.fields.first.targetCollection._name, 'Firsts'
  test.equal Second.Meta.fields.first.sourceDocument.Meta.collection._name, 'Seconds'
  test.equal Second.Meta.fields.first.targetDocument.Meta.collection._name, 'Firsts'
  test.equal Second.Meta.fields.first.fields, []
  test.isNull Second.Meta.fields.first.reverseName
  test.equal Second.Meta.fields.first.reverseFields, []
  test.instanceOf Second.Meta.fields.second, Second._ReferenceField
  test.isFalse Second.Meta.fields.second.ancestorArray, Second.Meta.fields.second.ancestorArray
  test.isTrue Second.Meta.fields.second.required
  test.equal Second.Meta.fields.second.sourcePath, 'second'
  test.equal Second.Meta.fields.second.sourceDocument, Second
  test.equal Second.Meta.fields.second.targetDocument, Person
  test.equal Second.Meta.fields.second.sourceCollection._name, 'Seconds'
  test.equal Second.Meta.fields.second.targetCollection._name, 'Persons'
  test.equal Second.Meta.fields.second.sourceDocument.Meta.collection._name, 'Seconds'
  test.equal Second.Meta.fields.second.targetDocument.Meta.collection._name, 'Persons'
  test.equal Second.Meta.fields.second.fields, []
  test.isNull Second.Meta.fields.second.reverseName
  test.equal Second.Meta.fields.second.reverseFields, []

  test.equal First.Meta._name, 'First'
  test.equal First.Meta.parent, _TestFirst2.Meta
  test.equal First.Meta.document, First
  test.equal First.Meta.collection._name, 'Firsts'
  test.equal _.size(First.Meta.fields), 1
  test.instanceOf First.Meta.fields.first, First._ReferenceField
  test.isFalse First.Meta.fields.first.ancestorArray, First.Meta.fields.first.ancestorArray
  test.isTrue First.Meta.fields.first.required
  test.equal First.Meta.fields.first.sourcePath, 'first'
  test.equal First.Meta.fields.first.sourceDocument, First
  test.equal First.Meta.fields.first.targetDocument, Person
  test.equal First.Meta.fields.first.sourceCollection._name, 'Firsts'
  test.equal First.Meta.fields.first.targetCollection._name, 'Persons'
  test.equal First.Meta.fields.first.sourceDocument.Meta.collection._name, 'Firsts'
  test.equal First.Meta.fields.first.targetDocument.Meta.collection._name, 'Persons'
  test.equal First.Meta.fields.first.fields, []
  test.isNull First.Meta.fields.first.reverseName
  test.equal First.Meta.fields.first.reverseFields, []

  secondReferenceB = Post
  Document._retryDelayed()

  testDocumentList test, ALL.concat [Second, First, Third]
  test.equal Document._delayed.length, 0

  test.equal Second.Meta._name, 'Second'
  test.equal Second.Meta.parent, _TestSecond.Meta
  test.equal Second.Meta.document, Second
  test.equal Second.Meta.collection._name, 'Seconds'
  test.equal _.size(Second.Meta.fields), 2
  test.instanceOf Second.Meta.fields.first, Second._ReferenceField
  test.isFalse Second.Meta.fields.first.ancestorArray, Second.Meta.fields.first.ancestorArray
  test.isTrue Second.Meta.fields.first.required
  test.equal Second.Meta.fields.first.sourcePath, 'first'
  test.equal Second.Meta.fields.first.sourceDocument, Second
  test.equal Second.Meta.fields.first.targetDocument, firstReferenceA
  test.equal Second.Meta.fields.first.sourceCollection._name, 'Seconds'
  test.equal Second.Meta.fields.first.targetCollection._name, 'Firsts'
  test.equal Second.Meta.fields.first.sourceDocument.Meta.collection._name, 'Seconds'
  test.equal Second.Meta.fields.first.targetDocument.Meta.collection._name, 'Firsts'
  test.equal Second.Meta.fields.first.fields, []
  test.isNull Second.Meta.fields.first.reverseName
  test.equal Second.Meta.fields.first.reverseFields, []
  test.instanceOf Second.Meta.fields.second, Second._ReferenceField
  test.isFalse Second.Meta.fields.second.ancestorArray, Second.Meta.fields.second.ancestorArray
  test.isTrue Second.Meta.fields.second.required
  test.equal Second.Meta.fields.second.sourcePath, 'second'
  test.equal Second.Meta.fields.second.sourceDocument, Second
  test.equal Second.Meta.fields.second.targetDocument, Person
  test.equal Second.Meta.fields.second.sourceCollection._name, 'Seconds'
  test.equal Second.Meta.fields.second.targetCollection._name, 'Persons'
  test.equal Second.Meta.fields.second.sourceDocument.Meta.collection._name, 'Seconds'
  test.equal Second.Meta.fields.second.targetDocument.Meta.collection._name, 'Persons'
  test.equal Second.Meta.fields.second.fields, []
  test.isNull Second.Meta.fields.second.reverseName
  test.equal Second.Meta.fields.second.reverseFields, []

  test.equal First.Meta._name, 'First'
  test.equal First.Meta.parent, _TestFirst2.Meta
  test.equal First.Meta.document, First
  test.equal First.Meta.collection._name, 'Firsts'
  test.equal _.size(First.Meta.fields), 1
  test.instanceOf First.Meta.fields.first, First._ReferenceField
  test.isFalse First.Meta.fields.first.ancestorArray, First.Meta.fields.first.ancestorArray
  test.isTrue First.Meta.fields.first.required
  test.equal First.Meta.fields.first.sourcePath, 'first'
  test.equal First.Meta.fields.first.sourceDocument, First
  test.equal First.Meta.fields.first.targetDocument, Person
  test.equal First.Meta.fields.first.sourceCollection._name, 'Firsts'
  test.equal First.Meta.fields.first.targetCollection._name, 'Persons'
  test.equal First.Meta.fields.first.sourceDocument.Meta.collection._name, 'Firsts'
  test.equal First.Meta.fields.first.targetDocument.Meta.collection._name, 'Persons'
  test.equal First.Meta.fields.first.fields, []
  test.isNull First.Meta.fields.first.reverseName
  test.equal First.Meta.fields.first.reverseFields, []

  test.equal Third.Meta._name, 'Third'
  test.equal Third.Meta.parent, _TestThird2.Meta
  test.equal Third.Meta.document, Third
  test.equal Third.Meta.collection._name, 'Thirds'
  test.equal _.size(Third.Meta.fields), 3
  test.instanceOf Third.Meta.fields.first, Third._ReferenceField
  test.isFalse Third.Meta.fields.first.ancestorArray, Third.Meta.fields.first.ancestorArray
  test.isTrue Third.Meta.fields.first.required
  test.equal Third.Meta.fields.first.sourcePath, 'first'
  test.equal Third.Meta.fields.first.sourceDocument, Third
  test.equal Third.Meta.fields.first.targetDocument, firstReferenceA
  test.equal Third.Meta.fields.first.sourceCollection._name, 'Thirds'
  test.equal Third.Meta.fields.first.targetCollection._name, 'Firsts'
  test.equal Third.Meta.fields.first.sourceDocument.Meta.collection._name, 'Thirds'
  test.equal Third.Meta.fields.first.targetDocument.Meta.collection._name, 'Firsts'
  test.equal Third.Meta.fields.first.fields, []
  test.isNull Third.Meta.fields.first.reverseName
  test.equal Third.Meta.fields.first.reverseFields, []
  test.instanceOf Third.Meta.fields.second, Third._ReferenceField
  test.isFalse Third.Meta.fields.second.ancestorArray, Third.Meta.fields.second.ancestorArray
  test.isTrue Third.Meta.fields.second.required
  test.equal Third.Meta.fields.second.sourcePath, 'second'
  test.equal Third.Meta.fields.second.sourceDocument, Third
  test.equal Third.Meta.fields.second.targetDocument, Post
  test.equal Third.Meta.fields.second.sourceCollection._name, 'Thirds'
  test.equal Third.Meta.fields.second.targetCollection._name, 'Posts'
  test.equal Third.Meta.fields.second.sourceDocument.Meta.collection._name, 'Thirds'
  test.equal Third.Meta.fields.second.targetDocument.Meta.collection._name, 'Posts'
  test.equal Third.Meta.fields.second.fields, []
  test.isNull Third.Meta.fields.second.reverseName
  test.equal Third.Meta.fields.second.reverseFields, []
  test.instanceOf Third.Meta.fields.third, Third._ReferenceField
  test.isFalse Third.Meta.fields.third.ancestorArray, Third.Meta.fields.third.ancestorArray
  test.isTrue Third.Meta.fields.third.required
  test.equal Third.Meta.fields.third.sourcePath, 'third'
  test.equal Third.Meta.fields.third.sourceDocument, Third
  test.equal Third.Meta.fields.third.targetDocument, Person
  test.equal Third.Meta.fields.third.sourceCollection._name, 'Thirds'
  test.equal Third.Meta.fields.third.targetCollection._name, 'Persons'
  test.equal Third.Meta.fields.third.sourceDocument.Meta.collection._name, 'Thirds'
  test.equal Third.Meta.fields.third.targetDocument.Meta.collection._name, 'Persons'
  test.equal Third.Meta.fields.third.fields, []
  test.isNull Third.Meta.fields.third.reverseName
  test.equal Third.Meta.fields.third.reverseFields, []

  Document.defineAll()

  test.equal Second.Meta._name, 'Second'
  test.equal Second.Meta.parent, _TestSecond.Meta
  test.equal Second.Meta.document, Second
  test.equal Second.Meta.collection._name, 'Seconds'
  test.equal _.size(Second.Meta.fields), 2
  test.instanceOf Second.Meta.fields.first, Second._ReferenceField
  test.isFalse Second.Meta.fields.first.ancestorArray, Second.Meta.fields.first.ancestorArray
  test.isTrue Second.Meta.fields.first.required
  test.equal Second.Meta.fields.first.sourcePath, 'first'
  test.equal Second.Meta.fields.first.sourceDocument, Second
  test.equal Second.Meta.fields.first.targetDocument, firstReferenceA
  test.equal Second.Meta.fields.first.sourceCollection._name, 'Seconds'
  test.equal Second.Meta.fields.first.targetCollection._name, 'Firsts'
  test.equal Second.Meta.fields.first.sourceDocument.Meta.collection._name, 'Seconds'
  test.equal Second.Meta.fields.first.targetDocument.Meta.collection._name, 'Firsts'
  test.equal Second.Meta.fields.first.fields, []
  test.isNull Second.Meta.fields.first.reverseName
  test.equal Second.Meta.fields.first.reverseFields, []
  test.instanceOf Second.Meta.fields.second, Second._ReferenceField
  test.isFalse Second.Meta.fields.second.ancestorArray, Second.Meta.fields.second.ancestorArray
  test.isTrue Second.Meta.fields.second.required
  test.equal Second.Meta.fields.second.sourcePath, 'second'
  test.equal Second.Meta.fields.second.sourceDocument, Second
  test.equal Second.Meta.fields.second.targetDocument, Person
  test.equal Second.Meta.fields.second.sourceCollection._name, 'Seconds'
  test.equal Second.Meta.fields.second.targetCollection._name, 'Persons'
  test.equal Second.Meta.fields.second.sourceDocument.Meta.collection._name, 'Seconds'
  test.equal Second.Meta.fields.second.targetDocument.Meta.collection._name, 'Persons'
  test.equal Second.Meta.fields.second.fields, []
  test.isNull Second.Meta.fields.second.reverseName
  test.equal Second.Meta.fields.second.reverseFields, []

  test.equal First.Meta._name, 'First'
  test.equal First.Meta.parent, _TestFirst2.Meta
  test.equal First.Meta.document, First
  test.equal First.Meta.collection._name, 'Firsts'
  test.equal _.size(First.Meta.fields), 1
  test.instanceOf First.Meta.fields.first, First._ReferenceField
  test.isFalse First.Meta.fields.first.ancestorArray, First.Meta.fields.first.ancestorArray
  test.isTrue First.Meta.fields.first.required
  test.equal First.Meta.fields.first.sourcePath, 'first'
  test.equal First.Meta.fields.first.sourceDocument, First
  test.equal First.Meta.fields.first.targetDocument, Person
  test.equal First.Meta.fields.first.sourceCollection._name, 'Firsts'
  test.equal First.Meta.fields.first.targetCollection._name, 'Persons'
  test.equal First.Meta.fields.first.sourceDocument.Meta.collection._name, 'Firsts'
  test.equal First.Meta.fields.first.targetDocument.Meta.collection._name, 'Persons'
  test.equal First.Meta.fields.first.fields, []
  test.isNull First.Meta.fields.first.reverseName
  test.equal First.Meta.fields.first.reverseFields, []

  test.equal Third.Meta._name, 'Third'
  test.equal Third.Meta.parent, _TestThird2.Meta
  test.equal Third.Meta.document, Third
  test.equal Third.Meta.collection._name, 'Thirds'
  test.equal _.size(Third.Meta.fields), 3
  test.instanceOf Third.Meta.fields.first, Third._ReferenceField
  test.isFalse Third.Meta.fields.first.ancestorArray, Third.Meta.fields.first.ancestorArray
  test.isTrue Third.Meta.fields.first.required
  test.equal Third.Meta.fields.first.sourcePath, 'first'
  test.equal Third.Meta.fields.first.sourceDocument, Third
  test.equal Third.Meta.fields.first.targetDocument, firstReferenceA
  test.equal Third.Meta.fields.first.sourceCollection._name, 'Thirds'
  test.equal Third.Meta.fields.first.targetCollection._name, 'Firsts'
  test.equal Third.Meta.fields.first.sourceDocument.Meta.collection._name, 'Thirds'
  test.equal Third.Meta.fields.first.targetDocument.Meta.collection._name, 'Firsts'
  test.equal Third.Meta.fields.first.fields, []
  test.isNull Third.Meta.fields.first.reverseName
  test.equal Third.Meta.fields.first.reverseFields, []
  test.instanceOf Third.Meta.fields.second, Third._ReferenceField
  test.isFalse Third.Meta.fields.second.ancestorArray, Third.Meta.fields.second.ancestorArray
  test.isTrue Third.Meta.fields.second.required
  test.equal Third.Meta.fields.second.sourcePath, 'second'
  test.equal Third.Meta.fields.second.sourceDocument, Third
  test.equal Third.Meta.fields.second.targetDocument, Post
  test.equal Third.Meta.fields.second.sourceCollection._name, 'Thirds'
  test.equal Third.Meta.fields.second.targetCollection._name, 'Posts'
  test.equal Third.Meta.fields.second.sourceDocument.Meta.collection._name, 'Thirds'
  test.equal Third.Meta.fields.second.targetDocument.Meta.collection._name, 'Posts'
  test.equal Third.Meta.fields.second.fields, []
  test.isNull Third.Meta.fields.second.reverseName
  test.equal Third.Meta.fields.second.reverseFields, []
  test.instanceOf Third.Meta.fields.third, Third._ReferenceField
  test.isFalse Third.Meta.fields.third.ancestorArray, Third.Meta.fields.third.ancestorArray
  test.isTrue Third.Meta.fields.third.required
  test.equal Third.Meta.fields.third.sourcePath, 'third'
  test.equal Third.Meta.fields.third.sourceDocument, Third
  test.equal Third.Meta.fields.third.targetDocument, Person
  test.equal Third.Meta.fields.third.sourceCollection._name, 'Thirds'
  test.equal Third.Meta.fields.third.targetCollection._name, 'Persons'
  test.equal Third.Meta.fields.third.sourceDocument.Meta.collection._name, 'Thirds'
  test.equal Third.Meta.fields.third.targetDocument.Meta.collection._name, 'Persons'
  test.equal Third.Meta.fields.third.fields, []
  test.isNull Third.Meta.fields.third.reverseName
  test.equal Third.Meta.fields.third.reverseFields, []

  # Restore
  Document.list = list
  Document._delayed = []
  Document._clearDelayedCheck()

  # Verify we are back to normal
  testDefinition test

Tinytest.addAsync 'peerdb - local collections', (test, onComplete) ->
  list = _.clone Document.list

  try
    class Local extends Document
      @Meta
        name: 'Local'
        collection: null
        fields: ->
          person: @ReferenceField Person

    testDocumentList test, ALL.concat [Local]
    test.equal Document._delayed.length, 0

    test.equal Local.Meta._name, 'Local'
    test.isFalse Local.Meta.parent
    test.equal Local.Meta.document, Local
    test.equal Local.Meta.collection._name, null
    test.equal _.size(Local.Meta.fields), 1
    test.instanceOf Local.Meta.fields.person, Local._ReferenceField
    test.isNull Local.Meta.fields.person.ancestorArray, Local.Meta.fields.person.ancestorArray
    test.isTrue Local.Meta.fields.person.required
    test.equal Local.Meta.fields.person.sourcePath, 'person'
    test.equal Local.Meta.fields.person.sourceDocument, Local
    test.equal Local.Meta.fields.person.targetDocument, Person
    test.isFalse Local.Meta.fields.person.sourceCollection._name
    test.equal Local.Meta.fields.person.targetCollection._name, 'Persons'
    test.isFalse Local.Meta.fields.person.sourceDocument.Meta.collection._name
    test.equal Local.Meta.fields.person.targetDocument.Meta.collection._name, 'Persons'
    test.equal Local.Meta.fields.person.fields, []
    test.isNull Local.Meta.fields.person.reverseName
    test.equal Local.Meta.fields.person.reverseFields, []
    test.isTrue Local.Meta._observersSetup

  finally
    # Restore
    Document.list = list
    Document._delayed = []
    Document._clearDelayedCheck()

    # Verify we are back to normal
    testDefinition test

    if Meteor.isServer
      Post.Meta.collection.rawDatabase().collection 'Locals', {strict: true}, Meteor.bindEnvironment (error, collection) =>
        test.isTrue error
        onComplete()
    else
      onComplete()

Tinytest.addAsync 'peerdb - collections with connection', (test, onComplete) ->
  list = _.clone Document.list

  try
    class CollectionWithConnection extends Document
      @Meta
        name: 'CollectionWithConnection'
        collection: new Mongo.Collection 'CollectionWithConnections',
          connection: DDP.connect Meteor.absoluteUrl()
        fields: ->
          person: @ReferenceField Person

    testDocumentList test, ALL.concat [CollectionWithConnection]
    test.equal Document._delayed.length, 0

    test.equal CollectionWithConnection.Meta._name, 'CollectionWithConnection'
    test.isFalse CollectionWithConnection.Meta.parent
    test.equal CollectionWithConnection.Meta.document, CollectionWithConnection
    test.equal CollectionWithConnection.Meta.collection._name, 'CollectionWithConnections'
    test.equal _.size(CollectionWithConnection.Meta.fields), 1
    test.instanceOf CollectionWithConnection.Meta.fields.person, CollectionWithConnection._ReferenceField
    test.isNull CollectionWithConnection.Meta.fields.person.ancestorArray, CollectionWithConnection.Meta.fields.person.ancestorArray
    test.isTrue CollectionWithConnection.Meta.fields.person.required
    test.equal CollectionWithConnection.Meta.fields.person.sourcePath, 'person'
    test.equal CollectionWithConnection.Meta.fields.person.sourceDocument, CollectionWithConnection
    test.equal CollectionWithConnection.Meta.fields.person.targetDocument, Person
    test.equal CollectionWithConnection.Meta.fields.person.sourceCollection._name, 'CollectionWithConnections'
    test.equal CollectionWithConnection.Meta.fields.person.targetCollection._name, 'Persons'
    test.equal CollectionWithConnection.Meta.fields.person.sourceDocument.Meta.collection._name, 'CollectionWithConnections'
    test.equal CollectionWithConnection.Meta.fields.person.targetDocument.Meta.collection._name, 'Persons'
    test.equal CollectionWithConnection.Meta.fields.person.fields, []
    test.isNull CollectionWithConnection.Meta.fields.person.reverseName
    test.equal CollectionWithConnection.Meta.fields.person.reverseFields, []
    test.isTrue CollectionWithConnection.Meta._observersSetup

  finally
    # Restore
    Document.list = list
    Document._delayed = []
    Document._clearDelayedCheck()

    # Verify we are back to normal
    testDefinition test

    if Meteor.isServer
      Post.Meta.collection.rawDatabase().collection 'CollectionWithConnections', {strict: true}, Meteor.bindEnvironment (error, collection) =>
        test.isTrue error
        onComplete()
    else
      onComplete()

testAsyncMulti 'peerdb - errors for generated fields', [
  (test, expect) ->
    Log._intercept 3 if Meteor.isServer and Document.instances is 1 # Three to see if we catch more than expected

    IdentityGenerator.documents.insert
      source: 'foobar'
    ,
      expect (error, identityGeneratorId) =>
        test.isFalse error, error?.toString?() or error
        test.isTrue identityGeneratorId
        @identityGeneratorId = identityGeneratorId

    # Wait so that observers have time to update documents
    waitForDatabase test, expect
,
  (test, expect) ->
    if Meteor.isServer and Document.instances is 1
      intercepted = Log._intercepted()

      # One or two because it depends if the client tests are running at the same time
      test.isTrue 1 <= intercepted.length <= 2, intercepted

      # We are testing only the server one, so let's find it
      for i in intercepted
        break if i.indexOf(@identityGeneratorId) isnt -1
      test.isTrue _.isString(i), i
      intercepted = EJSON.parse i

      test.equal intercepted.message, "Generated field 'results' defined as an array with selector '#{ @identityGeneratorId }' was updated with a non-array value: 'foobar'"
      test.equal intercepted.level, 'error'

    @identityGenerator = IdentityGenerator.documents.findOne @identityGeneratorId,
      transform: null # So that we can use test.equal

    test.equal @identityGenerator,
      _id: @identityGeneratorId
      source: 'foobar'
      result: 'foobar'

    Log._intercept 3 if Meteor.isServer and Document.instances is 1 # Three to see if we catch more than expected

    IdentityGenerator.documents.update @identityGeneratorId,
      $set:
        source: ['foobar2']
    ,
      expect (error, res) =>
        test.isFalse error, error?.toString?() or error
        test.isTrue res

    # Wait so that observers have time to update documents
    waitForDatabase test, expect
,
  (test, expect) ->
    if Meteor.isServer and Document.instances is 1
      intercepted = Log._intercepted()

      # One or two because it depends if the client tests are running at the same time
      test.isTrue 1 <= intercepted.length <= 2, intercepted

      # We are testing only the server one, so let's find it
      for i in intercepted
        break if i.indexOf(@identityGeneratorId) isnt -1
      test.isTrue _.isString(i), i
      intercepted = EJSON.parse i

      test.equal intercepted.message, "Generated field 'result' not defined as an array with selector '#{ @identityGeneratorId }' was updated with an array value: [ 'foobar2' ]"
      test.equal intercepted.level, 'error'

    @identityGenerator = IdentityGenerator.documents.findOne @identityGeneratorId,
      transform: null # So that we can use test.equal

    test.equal @identityGenerator,
      _id: @identityGeneratorId
      source: ['foobar2']
      result: 'foobar'
      results: ['foobar2']
]

Tinytest.add 'peerdb - tricky references', (test) ->
  list = _.clone Document.list

  # You can in fact use class name instead of "self", but you have to
  # make sure things work out at the end and class is really defined
  class First1 extends Document
    @Meta
      name: 'First1'
      fields: ->
        first: @ReferenceField First1

  Document.defineAll()

  test.equal First1.Meta._name, 'First1'
  test.isFalse First1.Meta.parent
  test.equal First1.Meta.document, First1
  test.equal First1.Meta.collection._name, 'First1s'
  test.equal _.size(First1.Meta.fields), 1
  test.instanceOf First1.Meta.fields.first, First1._ReferenceField
  test.isFalse First1.Meta.fields.first.ancestorArray, First1.Meta.fields.first.ancestorArray
  test.isTrue First1.Meta.fields.first.required
  test.equal First1.Meta.fields.first.sourcePath, 'first'
  test.equal First1.Meta.fields.first.sourceDocument, First1
  test.equal First1.Meta.fields.first.targetDocument, First1
  test.equal First1.Meta.fields.first.sourceCollection._name, 'First1s'
  test.equal First1.Meta.fields.first.targetCollection._name, 'First1s'
  test.equal First1.Meta.fields.first.sourceDocument.Meta.collection._name, 'First1s'
  test.equal First1.Meta.fields.first.targetDocument.Meta.collection._name, 'First1s'
  test.equal First1.Meta.fields.first.fields, []

  # Restore
  Document.list = _.clone list
  Document._delayed = []
  Document._clearDelayedCheck()

  class First2 extends Document
    @Meta
      name: 'First2'
      fields: ->
        first: @ReferenceField undefined # To force delayed

  class Second2 extends Document
    @Meta
      name: 'Second2'
      fields: ->
        first: @ReferenceField First2

  test.throws ->
    Document.defineAll true
  , /Target document not defined/

  test.throws ->
    Document.defineAll()
  , /Invalid fields/

  # Restore
  Document.list = _.clone list
  Document._delayed = []
  Document._clearDelayedCheck()

  # Verify we are back to normal
  testDefinition test

testAsyncMulti 'peerdb - duplicate values in lists', [
  (test, expect) ->
    Person.documents.insert
      username: 'person1'
      displayName: 'Person 1'
      field1: 'Field 1 - 1'
      field2: 'Field 1 - 2'
    ,
      expect (error, person1Id) =>
        test.isFalse error, error?.toString?() or error
        test.isTrue person1Id
        @person1Id = person1Id

    Person.documents.insert
      username: 'person2'
      displayName: 'Person 2'
      field1: 'Field 2 - 1'
      field2: 'Field 2 - 2'
    ,
      expect (error, person2Id) =>
        test.isFalse error, error?.toString?() or error
        test.isTrue person2Id
        @person2Id = person2Id

    Person.documents.insert
      username: 'person3'
      displayName: 'Person 3'
      field1: 'Field 3 - 1'
      field2: 'Field 3 - 2'
    ,
      expect (error, person3Id) =>
        test.isFalse error, error?.toString?() or error
        test.isTrue person3Id
        @person3Id = person3Id

    # Wait so that observers have time to update documents
    waitForDatabase test, expect
,
  (test, expect) ->
    @person1 = Person.documents.findOne @person1Id,
      transform: null # So that we can use test.equal
    @person2 = Person.documents.findOne @person2Id,
      transform: null # So that we can use test.equal
    @person3 = Person.documents.findOne @person3Id,
      transform: null # So that we can use test.equal

    test.equal @person1,
      _id: @person1Id
      username: 'person1'
      displayName: 'Person 1'
      field1: 'Field 1 - 1'
      field2: 'Field 1 - 2'
      count: 0
    test.equal @person2,
      _id: @person2Id
      username: 'person2'
      displayName: 'Person 2'
      field1: 'Field 2 - 1'
      field2: 'Field 2 - 2'
      count: 0
    test.equal @person3,
      _id: @person3Id
      username: 'person3'
      displayName: 'Person 3'
      field1: 'Field 3 - 1'
      field2: 'Field 3 - 2'
      count: 0

    Post.documents.insert
      author:
        _id: @person1._id
        # To test what happens if fields are partially not up to date
        username: 'wrong'
        displayName: 'wrong'
      subscribers: [
        _id: @person2._id
      ,
        _id: @person2._id
      ,
        _id: @person3._id
      ]
      reviewers: [
        _id: @person2._id
      ,
        _id: @person3._id
      ,
        _id: @person3._id
      ]
      subdocument:
        person:
          _id: @person2._id
        persons: [
          _id: @person2._id
          username: 'wrong'
          displayName: 'wrong'
        ,
          _id: @person2._id
          username: @person2.username
          displayName: @person2.displayName
          field1: 'wrong'
        ,
          _id: @person3._id
          # To test if the second person3 value will be updated
          username: @person3.username
          displayName: @person3.displayName
          field1: @person3.field1
          field2: @person3.field2
        ,
          _id: @person3._id
        ]
        body: 'SubdocumentFooBar'
      nested: [
        required:
          _id: @person2._id
          username: 'wrong'
          displayName: 'wrong'
        optional:
          _id: @person3._id
        body: 'NestedFooBar'
      ,
        required:
          _id: @person2._id
          username: @person2.username
          displayName: @person2.displayName
        optional:
          _id: @person3._id
        body: 'NestedFooBar'
      ,
        required:
          _id: @person3._id
        optional:
          _id: @person2._id
        body: 'NestedFooBar'
      ,
        required:
          _id: @person3._id
        optional:
          _id: @person2._id
        body: 'NestedFooBar'
      ,
        required:
          _id: @person2._id
          username: @person2.username
          displayName: @person2.displayName
          field1: 'wrong'
        optional:
          _id: @person2._id
        body: 'NestedFooBar'
      ,
        required:
          _id: @person3._id
        optional:
          _id: @person3._id
        body: 'NestedFooBar'
      ]
      body: 'FooBar'
    ,
      expect (error, postId) =>
        test.isFalse error, error?.toString?() or error
        test.isTrue postId
        @postId = postId

    # Wait so that observers have time to update documents
    waitForDatabase test, expect
,
  (test, expect) ->
    @post = Post.documents.findOne @postId,
      transform: null # So that we can use test.equal

    test.equal @post,
      _id: @postId
      author:
        _id: @person1._id
        username: @person1.username
        displayName: @person1.displayName
        field1: @person1.field1
        field2: @person1.field2
      subscribers: [
        _id: @person2._id
      ,
        _id: @person2._id
      ,
        _id: @person3._id
      ]
      reviewers: [
        _id: @person2._id
        username: @person2.username
      ,
        _id: @person3._id
        username: @person3.username
      ,
        _id: @person3._id
        username: @person3.username
      ]
      subdocument:
        person:
          _id: @person2._id
          username: @person2.username
          displayName: @person2.displayName
          field1: @person2.field1
          field2: @person2.field2
        persons: [
          _id: @person2._id
          username: @person2.username
          displayName: @person2.displayName
          field1: @person2.field1
          field2: @person2.field2
        ,
          _id: @person2._id
          username: @person2.username
          displayName: @person2.displayName
          field1: @person2.field1
          field2: @person2.field2
        ,
          _id: @person3._id
          username: @person3.username
          displayName: @person3.displayName
          field1: @person3.field1
          field2: @person3.field2
        ,
          _id: @person3._id
          username: @person3.username
          displayName: @person3.displayName
          field1: @person3.field1
          field2: @person3.field2
        ]
        slug: 'subdocument-prefix-foobar-subdocumentfoobar-suffix'
        body: 'SubdocumentFooBar'
      nested: [
        required:
          _id: @person2._id
          username: @person2.username
          displayName: @person2.displayName
          field1: @person2.field1
          field2: @person2.field2
        optional:
          _id: @person3._id
          username: @person3.username
        slug: 'nested-prefix-foobar-nestedfoobar-suffix'
        body: 'NestedFooBar'
      ,
        required:
          _id: @person2._id
          username: @person2.username
          displayName: @person2.displayName
          field1: @person2.field1
          field2: @person2.field2
        optional:
          _id: @person3._id
          username: @person3.username
        slug: 'nested-prefix-foobar-nestedfoobar-suffix'
        body: 'NestedFooBar'
      ,
        required:
          _id: @person3._id
          username: @person3.username
          displayName: @person3.displayName
          field1: @person3.field1
          field2: @person3.field2
        optional:
          _id: @person2._id
          username: @person2.username
        slug: 'nested-prefix-foobar-nestedfoobar-suffix'
        body: 'NestedFooBar'
      ,
        required:
          _id: @person3._id
          username: @person3.username
          displayName: @person3.displayName
          field1: @person3.field1
          field2: @person3.field2
        optional:
          _id: @person2._id
          username: @person2.username
        slug: 'nested-prefix-foobar-nestedfoobar-suffix'
        body: 'NestedFooBar'
      ,
        required:
          _id: @person2._id
          username: @person2.username
          displayName: @person2.displayName
          field1: @person2.field1
          field2: @person2.field2
        optional:
          _id: @person2._id
          username: @person2.username
        slug: 'nested-prefix-foobar-nestedfoobar-suffix'
        body: 'NestedFooBar'
      ,
        required:
          _id: @person3._id
          username: @person3.username
          displayName: @person3.displayName
          field1: @person3.field1
          field2: @person3.field2
        optional:
          _id: @person3._id
          username: @person3.username
        slug: 'nested-prefix-foobar-nestedfoobar-suffix'
        body: 'NestedFooBar'
      ]
      body: 'FooBar'
      slug: 'prefix-foobar-subdocumentfoobar-suffix'
      tags: [
        'tag-0-prefix-foobar-subdocumentfoobar-suffix'
        'tag-1-prefix-foobar-nestedfoobar-suffix'
        'tag-2-prefix-foobar-nestedfoobar-suffix'
        'tag-3-prefix-foobar-nestedfoobar-suffix'
        'tag-4-prefix-foobar-nestedfoobar-suffix'
        'tag-5-prefix-foobar-nestedfoobar-suffix'
        'tag-6-prefix-foobar-nestedfoobar-suffix'
      ]

    Person.documents.update @person1Id,
      $set:
        username: 'person1a'
    ,
      expect (error, res) =>
        test.isFalse error, error?.toString?() or error
        test.isTrue res

    Person.documents.update @person2Id,
      $set:
        username: 'person2a'
    ,
      expect (error, res) =>
        test.isFalse error, error?.toString?() or error
        test.isTrue res

    # Wait so that observers have time to update documents
    # so that persons updates are not merged together to better
    # test the code for multiple updates
    waitForDatabase test, expect
,
  (test, expect) ->
    Person.documents.update @person3Id,
      $set:
        username: 'person3a'
    ,
      expect (error, res) =>
        test.isFalse error, error?.toString?() or error
        test.isTrue res

    # Wait so that observers have time to update documents
    waitForDatabase test, expect
,
  (test, expect) ->
    @person1 = Person.documents.findOne @person1Id,
      transform: null # So that we can use test.equal
    @person2 = Person.documents.findOne @person2Id,
      transform: null # So that we can use test.equal
    @person3 = Person.documents.findOne @person3Id,
      transform: null # So that we can use test.equal

    test.equal @person1,
      _id: @person1Id
      username: 'person1a'
      displayName: 'Person 1'
      field1: 'Field 1 - 1'
      field2: 'Field 1 - 2'
      posts: [
        _id: @postId
        subdocument:
          body: 'SubdocumentFooBar'
        nested: [
          body: 'NestedFooBar'
        ,
          body: 'NestedFooBar'
        ,
          body: 'NestedFooBar'
        ,
          body: 'NestedFooBar'
        ,
          body: 'NestedFooBar'
        ,
          body: 'NestedFooBar'
        ]
        body: 'FooBar'
      ]
      count: 1
    test.equal @person2,
      _id: @person2Id
      username: 'person2a'
      displayName: 'Person 2'
      field1: 'Field 2 - 1'
      field2: 'Field 2 - 2'
      subdocument:
        posts: [
          _id: @postId
          subdocument:
            body: 'SubdocumentFooBar'
          nested: [
            body: 'NestedFooBar'
          ,
            body: 'NestedFooBar'
          ,
            body: 'NestedFooBar'
          ,
            body: 'NestedFooBar'
          ,
            body: 'NestedFooBar'
          ,
            body: 'NestedFooBar'
          ]
          body: 'FooBar'
        ]
      subdocumentsPosts: [
        _id: @postId
        subdocument:
          body: 'SubdocumentFooBar'
        nested: [
          body: 'NestedFooBar'
        ,
          body: 'NestedFooBar'
        ,
          body: 'NestedFooBar'
        ,
          body: 'NestedFooBar'
        ,
          body: 'NestedFooBar'
        ,
          body: 'NestedFooBar'
        ]
        body: 'FooBar'
      ]
      nestedPosts: [
        _id: @postId
        subdocument:
          body: 'SubdocumentFooBar'
        nested: [
          body: 'NestedFooBar'
        ,
          body: 'NestedFooBar'
        ,
          body: 'NestedFooBar'
        ,
          body: 'NestedFooBar'
        ,
          body: 'NestedFooBar'
        ,
          body: 'NestedFooBar'
        ]
        body: 'FooBar'
      ]
      count: 3
    test.equal @person3,
      _id: @person3Id
      username: 'person3a'
      displayName: 'Person 3'
      field1: 'Field 3 - 1'
      field2: 'Field 3 - 2'
      subdocumentsPosts: [
        _id: @postId
        subdocument:
          body: 'SubdocumentFooBar'
        nested: [
          body: 'NestedFooBar'
        ,
          body: 'NestedFooBar'
        ,
          body: 'NestedFooBar'
        ,
          body: 'NestedFooBar'
        ,
          body: 'NestedFooBar'
        ,
          body: 'NestedFooBar'
        ]
        body: 'FooBar'
      ]
      nestedPosts: [
        _id: @postId
        subdocument:
          body: 'SubdocumentFooBar'
        nested: [
          body: 'NestedFooBar'
        ,
          body: 'NestedFooBar'
        ,
          body: 'NestedFooBar'
        ,
          body: 'NestedFooBar'
        ,
          body: 'NestedFooBar'
        ,
          body: 'NestedFooBar'
        ]
        body: 'FooBar'
      ]
      count: 2

    # Wait so that observers have time to update documents
    waitForDatabase test, expect
,
  (test, expect) ->
    @post = Post.documents.findOne @postId,
      transform: null # So that we can use test.equal

    test.equal @post,
      _id: @postId
      author:
        _id: @person1._id
        username: @person1.username
        displayName: @person1.displayName
        field1: @person1.field1
        field2: @person1.field2
      subscribers: [
        _id: @person2._id
      ,
        _id: @person2._id
      ,
        _id: @person3._id
      ]
      reviewers: [
        _id: @person2._id
        username: @person2.username
      ,
        _id: @person3._id
        username: @person3.username
      ,
        _id: @person3._id
        username: @person3.username
      ]
      subdocument:
        person:
          _id: @person2._id
          username: @person2.username
          displayName: @person2.displayName
          field1: @person2.field1
          field2: @person2.field2
        persons: [
          _id: @person2._id
          username: @person2.username
          displayName: @person2.displayName
          field1: @person2.field1
          field2: @person2.field2
        ,
          _id: @person2._id
          username: @person2.username
          displayName: @person2.displayName
          field1: @person2.field1
          field2: @person2.field2
        ,
          _id: @person3._id
          username: @person3.username
          displayName: @person3.displayName
          field1: @person3.field1
          field2: @person3.field2
        ,
          _id: @person3._id
          username: @person3.username
          displayName: @person3.displayName
          field1: @person3.field1
          field2: @person3.field2
        ]
        slug: 'subdocument-prefix-foobar-subdocumentfoobar-suffix'
        body: 'SubdocumentFooBar'
      nested: [
        required:
          _id: @person2._id
          username: @person2.username
          displayName: @person2.displayName
          field1: @person2.field1
          field2: @person2.field2
        optional:
          _id: @person3._id
          username: @person3.username
        slug: 'nested-prefix-foobar-nestedfoobar-suffix'
        body: 'NestedFooBar'
      ,
        required:
          _id: @person2._id
          username: @person2.username
          displayName: @person2.displayName
          field1: @person2.field1
          field2: @person2.field2
        optional:
          _id: @person3._id
          username: @person3.username
        slug: 'nested-prefix-foobar-nestedfoobar-suffix'
        body: 'NestedFooBar'
      ,
        required:
          _id: @person3._id
          username: @person3.username
          displayName: @person3.displayName
          field1: @person3.field1
          field2: @person3.field2
        optional:
          _id: @person2._id
          username: @person2.username
        slug: 'nested-prefix-foobar-nestedfoobar-suffix'
        body: 'NestedFooBar'
      ,
        required:
          _id: @person3._id
          username: @person3.username
          displayName: @person3.displayName
          field1: @person3.field1
          field2: @person3.field2
        optional:
          _id: @person2._id
          username: @person2.username
        slug: 'nested-prefix-foobar-nestedfoobar-suffix'
        body: 'NestedFooBar'
      ,
        required:
          _id: @person2._id
          username: @person2.username
          displayName: @person2.displayName
          field1: @person2.field1
          field2: @person2.field2
        optional:
          _id: @person2._id
          username: @person2.username
        slug: 'nested-prefix-foobar-nestedfoobar-suffix'
        body: 'NestedFooBar'
      ,
        required:
          _id: @person3._id
          username: @person3.username
          displayName: @person3.displayName
          field1: @person3.field1
          field2: @person3.field2
        optional:
          _id: @person3._id
          username: @person3.username
        slug: 'nested-prefix-foobar-nestedfoobar-suffix'
        body: 'NestedFooBar'
      ]
      body: 'FooBar'
      slug: 'prefix-foobar-subdocumentfoobar-suffix'
      tags: [
        'tag-0-prefix-foobar-subdocumentfoobar-suffix'
        'tag-1-prefix-foobar-nestedfoobar-suffix'
        'tag-2-prefix-foobar-nestedfoobar-suffix'
        'tag-3-prefix-foobar-nestedfoobar-suffix'
        'tag-4-prefix-foobar-nestedfoobar-suffix'
        'tag-5-prefix-foobar-nestedfoobar-suffix'
        'tag-6-prefix-foobar-nestedfoobar-suffix'
      ]

  (test, expect) ->
    Person.documents.update @person1Id,
      $set:
        # Updating two fields at the same time
        field1: 'Field 1 - 1a'
        field2: 'Field 1 - 2a'
    ,
      expect (error, res) =>
        test.isFalse error, error?.toString?() or error
        test.isTrue res

    # Wait so that observers have time to update documents
    waitForDatabase test, expect
,
  (test, expect) ->
    @person1 = Person.documents.findOne @person1Id,
      transform: null # So that we can use test.equal

    test.equal @person1,
      _id: @person1Id
      username: 'person1a'
      displayName: 'Person 1'
      field1: 'Field 1 - 1a'
      field2: 'Field 1 - 2a'
      posts: [
        _id: @postId
        subdocument:
          body: 'SubdocumentFooBar'
        nested: [
          body: 'NestedFooBar'
        ,
          body: 'NestedFooBar'
        ,
          body: 'NestedFooBar'
        ,
          body: 'NestedFooBar'
        ,
          body: 'NestedFooBar'
        ,
          body: 'NestedFooBar'
        ]
        body: 'FooBar'
      ]
      count: 1

    @post = Post.documents.findOne @postId,
      transform: null # So that we can use test.equal

    test.equal @post,
      _id: @postId
      author:
        _id: @person1._id
        username: @person1.username
        displayName: @person1.displayName
        field1: @person1.field1
        field2: @person1.field2
      subscribers: [
        _id: @person2._id
      ,
        _id: @person2._id
      ,
        _id: @person3._id
      ]
      reviewers: [
        _id: @person2._id
        username: @person2.username
      ,
        _id: @person3._id
        username: @person3.username
      ,
        _id: @person3._id
        username: @person3.username
      ]
      subdocument:
        person:
          _id: @person2._id
          username: @person2.username
          displayName: @person2.displayName
          field1: @person2.field1
          field2: @person2.field2
        persons: [
          _id: @person2._id
          username: @person2.username
          displayName: @person2.displayName
          field1: @person2.field1
          field2: @person2.field2
        ,
          _id: @person2._id
          username: @person2.username
          displayName: @person2.displayName
          field1: @person2.field1
          field2: @person2.field2
        ,
          _id: @person3._id
          username: @person3.username
          displayName: @person3.displayName
          field1: @person3.field1
          field2: @person3.field2
        ,
          _id: @person3._id
          username: @person3.username
          displayName: @person3.displayName
          field1: @person3.field1
          field2: @person3.field2
        ]
        slug: 'subdocument-prefix-foobar-subdocumentfoobar-suffix'
        body: 'SubdocumentFooBar'
      nested: [
        required:
          _id: @person2._id
          username: @person2.username
          displayName: @person2.displayName
          field1: @person2.field1
          field2: @person2.field2
        optional:
          _id: @person3._id
          username: @person3.username
        slug: 'nested-prefix-foobar-nestedfoobar-suffix'
        body: 'NestedFooBar'
      ,
        required:
          _id: @person2._id
          username: @person2.username
          displayName: @person2.displayName
          field1: @person2.field1
          field2: @person2.field2
        optional:
          _id: @person3._id
          username: @person3.username
        slug: 'nested-prefix-foobar-nestedfoobar-suffix'
        body: 'NestedFooBar'
      ,
        required:
          _id: @person3._id
          username: @person3.username
          displayName: @person3.displayName
          field1: @person3.field1
          field2: @person3.field2
        optional:
          _id: @person2._id
          username: @person2.username
        slug: 'nested-prefix-foobar-nestedfoobar-suffix'
        body: 'NestedFooBar'
      ,
        required:
          _id: @person3._id
          username: @person3.username
          displayName: @person3.displayName
          field1: @person3.field1
          field2: @person3.field2
        optional:
          _id: @person2._id
          username: @person2.username
        slug: 'nested-prefix-foobar-nestedfoobar-suffix'
        body: 'NestedFooBar'
      ,
        required:
          _id: @person2._id
          username: @person2.username
          displayName: @person2.displayName
          field1: @person2.field1
          field2: @person2.field2
        optional:
          _id: @person2._id
          username: @person2.username
        slug: 'nested-prefix-foobar-nestedfoobar-suffix'
        body: 'NestedFooBar'
      ,
        required:
          _id: @person3._id
          username: @person3.username
          displayName: @person3.displayName
          field1: @person3.field1
          field2: @person3.field2
        optional:
          _id: @person3._id
          username: @person3.username
        slug: 'nested-prefix-foobar-nestedfoobar-suffix'
        body: 'NestedFooBar'
      ]
      body: 'FooBar'
      slug: 'prefix-foobar-subdocumentfoobar-suffix'
      tags: [
        'tag-0-prefix-foobar-subdocumentfoobar-suffix'
        'tag-1-prefix-foobar-nestedfoobar-suffix'
        'tag-2-prefix-foobar-nestedfoobar-suffix'
        'tag-3-prefix-foobar-nestedfoobar-suffix'
        'tag-4-prefix-foobar-nestedfoobar-suffix'
        'tag-5-prefix-foobar-nestedfoobar-suffix'
        'tag-6-prefix-foobar-nestedfoobar-suffix'
      ]

    Person.documents.update @person1Id,
      $unset:
        username: ''
    ,
      expect (error, res) =>
        test.isFalse error, error?.toString?() or error
        test.isTrue res

    # Wait so that observers have time to update documents
    waitForDatabase test, expect
,
  (test, expect) ->
    @person1 = Person.documents.findOne @person1Id,
      transform: null # So that we can use test.equal

    test.equal @person1,
      _id: @person1Id
      displayName: 'Person 1'
      field1: 'Field 1 - 1a'
      field2: 'Field 1 - 2a'
      posts: [
        _id: @postId
        subdocument:
          body: 'SubdocumentFooBar'
        nested: [
          body: 'NestedFooBar'
        ,
          body: 'NestedFooBar'
        ,
          body: 'NestedFooBar'
        ,
          body: 'NestedFooBar'
        ,
          body: 'NestedFooBar'
        ,
          body: 'NestedFooBar'
        ]
        body: 'FooBar'
      ]
      count: 1

    @post = Post.documents.findOne @postId,
      transform: null # So that we can use test.equal

    test.equal @post,
      _id: @postId
      author:
        _id: @person1._id
        displayName: @person1.displayName
        field1: @person1.field1
        field2: @person1.field2
      subscribers: [
        _id: @person2._id
      ,
        _id: @person2._id
      ,
        _id: @person3._id
      ]
      reviewers: [
        _id: @person2._id
        username: @person2.username
      ,
        _id: @person3._id
        username: @person3.username
      ,
        _id: @person3._id
        username: @person3.username
      ]
      subdocument:
        person:
          _id: @person2._id
          username: @person2.username
          displayName: @person2.displayName
          field1: @person2.field1
          field2: @person2.field2
        persons: [
          _id: @person2._id
          username: @person2.username
          displayName: @person2.displayName
          field1: @person2.field1
          field2: @person2.field2
        ,
          _id: @person2._id
          username: @person2.username
          displayName: @person2.displayName
          field1: @person2.field1
          field2: @person2.field2
        ,
          _id: @person3._id
          username: @person3.username
          displayName: @person3.displayName
          field1: @person3.field1
          field2: @person3.field2
        ,
          _id: @person3._id
          username: @person3.username
          displayName: @person3.displayName
          field1: @person3.field1
          field2: @person3.field2
        ]
        slug: 'subdocument-prefix-foobar-subdocumentfoobar-suffix'
        body: 'SubdocumentFooBar'
      nested: [
        required:
          _id: @person2._id
          username: @person2.username
          displayName: @person2.displayName
          field1: @person2.field1
          field2: @person2.field2
        optional:
          _id: @person3._id
          username: @person3.username
        slug: 'nested-prefix-foobar-nestedfoobar-suffix'
        body: 'NestedFooBar'
      ,
        required:
          _id: @person2._id
          username: @person2.username
          displayName: @person2.displayName
          field1: @person2.field1
          field2: @person2.field2
        optional:
          _id: @person3._id
          username: @person3.username
        slug: 'nested-prefix-foobar-nestedfoobar-suffix'
        body: 'NestedFooBar'
      ,
        required:
          _id: @person3._id
          username: @person3.username
          displayName: @person3.displayName
          field1: @person3.field1
          field2: @person3.field2
        optional:
          _id: @person2._id
          username: @person2.username
        slug: 'nested-prefix-foobar-nestedfoobar-suffix'
        body: 'NestedFooBar'
      ,
        required:
          _id: @person3._id
          username: @person3.username
          displayName: @person3.displayName
          field1: @person3.field1
          field2: @person3.field2
        optional:
          _id: @person2._id
          username: @person2.username
        slug: 'nested-prefix-foobar-nestedfoobar-suffix'
        body: 'NestedFooBar'
      ,
        required:
          _id: @person2._id
          username: @person2.username
          displayName: @person2.displayName
          field1: @person2.field1
          field2: @person2.field2
        optional:
          _id: @person2._id
          username: @person2.username
        slug: 'nested-prefix-foobar-nestedfoobar-suffix'
        body: 'NestedFooBar'
      ,
        required:
          _id: @person3._id
          username: @person3.username
          displayName: @person3.displayName
          field1: @person3.field1
          field2: @person3.field2
        optional:
          _id: @person3._id
          username: @person3.username
        slug: 'nested-prefix-foobar-nestedfoobar-suffix'
        body: 'NestedFooBar'
      ]
      body: 'FooBar'
      slug: 'prefix-foobar-subdocumentfoobar-suffix'
      tags: [
        'tag-0-prefix-foobar-subdocumentfoobar-suffix'
        'tag-1-prefix-foobar-nestedfoobar-suffix'
        'tag-2-prefix-foobar-nestedfoobar-suffix'
        'tag-3-prefix-foobar-nestedfoobar-suffix'
        'tag-4-prefix-foobar-nestedfoobar-suffix'
        'tag-5-prefix-foobar-nestedfoobar-suffix'
        'tag-6-prefix-foobar-nestedfoobar-suffix'
      ]

    Person.documents.update @person2Id,
      $unset:
        username: ''
    ,
      expect (error, res) =>
        test.isFalse error, error?.toString?() or error
        test.isTrue res

    # Wait so that observers have time to update documents
    waitForDatabase test, expect
,
  (test, expect) ->
    @person2 = Person.documents.findOne @person2Id,
      transform: null # So that we can use test.equal

    test.equal @person2,
      _id: @person2Id
      displayName: 'Person 2'
      field1: 'Field 2 - 1'
      field2: 'Field 2 - 2'
      subdocument:
        posts: [
          _id: @postId
          subdocument:
            body: 'SubdocumentFooBar'
          nested: [
            body: 'NestedFooBar'
          ,
            body: 'NestedFooBar'
          ,
            body: 'NestedFooBar'
          ,
            body: 'NestedFooBar'
          ,
            body: 'NestedFooBar'
          ,
            body: 'NestedFooBar'
          ]
          body: 'FooBar'
        ]
      subdocumentsPosts: [
        _id: @postId
        subdocument:
          body: 'SubdocumentFooBar'
        nested: [
          body: 'NestedFooBar'
        ,
          body: 'NestedFooBar'
        ,
          body: 'NestedFooBar'
        ,
          body: 'NestedFooBar'
        ,
          body: 'NestedFooBar'
        ,
          body: 'NestedFooBar'
        ]
        body: 'FooBar'
      ]
      nestedPosts: [
        _id: @postId
        subdocument:
          body: 'SubdocumentFooBar'
        nested: [
          body: 'NestedFooBar'
        ,
          body: 'NestedFooBar'
        ,
          body: 'NestedFooBar'
        ,
          body: 'NestedFooBar'
        ,
          body: 'NestedFooBar'
        ,
          body: 'NestedFooBar'
        ]
        body: 'FooBar'
      ]
      count: 3

    @post = Post.documents.findOne @postId,
      transform: null # So that we can use test.equal

    test.equal @post,
      _id: @postId
      author:
        _id: @person1._id
        displayName: @person1.displayName
        field1: @person1.field1
        field2: @person1.field2
      subscribers: [
        _id: @person2._id
      ,
        _id: @person2._id
      ,
        _id: @person3._id
      ]
      reviewers: [
        _id: @person2._id
      ,
        _id: @person3._id
        username: @person3.username
      ,
        _id: @person3._id
        username: @person3.username
      ]
      subdocument:
        person:
          _id: @person2._id
          displayName: @person2.displayName
          field1: @person2.field1
          field2: @person2.field2
        persons: [
          _id: @person2._id
          displayName: @person2.displayName
          field1: @person2.field1
          field2: @person2.field2
        ,
          _id: @person2._id
          displayName: @person2.displayName
          field1: @person2.field1
          field2: @person2.field2
        ,
          _id: @person3._id
          username: @person3.username
          displayName: @person3.displayName
          field1: @person3.field1
          field2: @person3.field2
        ,
          _id: @person3._id
          username: @person3.username
          displayName: @person3.displayName
          field1: @person3.field1
          field2: @person3.field2
        ]
        slug: 'subdocument-prefix-foobar-subdocumentfoobar-suffix'
        body: 'SubdocumentFooBar'
      nested: [
        required:
          _id: @person2._id
          displayName: @person2.displayName
          field1: @person2.field1
          field2: @person2.field2
        optional:
          _id: @person3._id
          username: @person3.username
        slug: 'nested-prefix-foobar-nestedfoobar-suffix'
        body: 'NestedFooBar'
      ,
        required:
          _id: @person2._id
          displayName: @person2.displayName
          field1: @person2.field1
          field2: @person2.field2
        optional:
          _id: @person3._id
          username: @person3.username
        slug: 'nested-prefix-foobar-nestedfoobar-suffix'
        body: 'NestedFooBar'
      ,
        required:
          _id: @person3._id
          username: @person3.username
          displayName: @person3.displayName
          field1: @person3.field1
          field2: @person3.field2
        optional:
          _id: @person2._id
        slug: 'nested-prefix-foobar-nestedfoobar-suffix'
        body: 'NestedFooBar'
      ,
        required:
          _id: @person3._id
          username: @person3.username
          displayName: @person3.displayName
          field1: @person3.field1
          field2: @person3.field2
        optional:
          _id: @person2._id
        slug: 'nested-prefix-foobar-nestedfoobar-suffix'
        body: 'NestedFooBar'
      ,
        required:
          _id: @person2._id
          displayName: @person2.displayName
          field1: @person2.field1
          field2: @person2.field2
        optional:
          _id: @person2._id
        slug: 'nested-prefix-foobar-nestedfoobar-suffix'
        body: 'NestedFooBar'
      ,
        required:
          _id: @person3._id
          username: @person3.username
          displayName: @person3.displayName
          field1: @person3.field1
          field2: @person3.field2
        optional:
          _id: @person3._id
          username: @person3.username
        slug: 'nested-prefix-foobar-nestedfoobar-suffix'
        body: 'NestedFooBar'
      ]
      body: 'FooBar'
      slug: 'prefix-foobar-subdocumentfoobar-suffix'
      tags: [
        'tag-0-prefix-foobar-subdocumentfoobar-suffix'
        'tag-1-prefix-foobar-nestedfoobar-suffix'
        'tag-2-prefix-foobar-nestedfoobar-suffix'
        'tag-3-prefix-foobar-nestedfoobar-suffix'
        'tag-4-prefix-foobar-nestedfoobar-suffix'
        'tag-5-prefix-foobar-nestedfoobar-suffix'
        'tag-6-prefix-foobar-nestedfoobar-suffix'
      ]

    Person.documents.update @person3Id,
      $unset:
        username: ''
    ,
      expect (error, res) =>
        test.isFalse error, error?.toString?() or error
        test.isTrue res

    # Wait so that observers have time to update documents
    waitForDatabase test, expect
,
  (test, expect) ->
    @person3 = Person.documents.findOne @person3Id,
      transform: null # So that we can use test.equal

    test.equal @person3,
      _id: @person3Id
      displayName: 'Person 3'
      field1: 'Field 3 - 1'
      field2: 'Field 3 - 2'
      subdocumentsPosts: [
        _id: @postId
        subdocument:
          body: 'SubdocumentFooBar'
        nested: [
          body: 'NestedFooBar'
        ,
          body: 'NestedFooBar'
        ,
          body: 'NestedFooBar'
        ,
          body: 'NestedFooBar'
        ,
          body: 'NestedFooBar'
        ,
          body: 'NestedFooBar'
        ]
        body: 'FooBar'
      ]
      nestedPosts: [
        _id: @postId
        subdocument:
          body: 'SubdocumentFooBar'
        nested: [
          body: 'NestedFooBar'
        ,
          body: 'NestedFooBar'
        ,
          body: 'NestedFooBar'
        ,
          body: 'NestedFooBar'
        ,
          body: 'NestedFooBar'
        ,
          body: 'NestedFooBar'
        ]
        body: 'FooBar'
      ]
      count: 2

    @post = Post.documents.findOne @postId,
      transform: null # So that we can use test.equal

    test.equal @post,
      _id: @postId
      author:
        _id: @person1._id
        displayName: @person1.displayName
        field1: @person1.field1
        field2: @person1.field2
      subscribers: [
        _id: @person2._id
      ,
        _id: @person2._id
      ,
        _id: @person3._id
      ]
      reviewers: [
        _id: @person2._id
      ,
        _id: @person3._id
      ,
        _id: @person3._id
      ]
      subdocument:
        person:
          _id: @person2._id
          displayName: @person2.displayName
          field1: @person2.field1
          field2: @person2.field2
        persons: [
          _id: @person2._id
          displayName: @person2.displayName
          field1: @person2.field1
          field2: @person2.field2
        ,
          _id: @person2._id
          displayName: @person2.displayName
          field1: @person2.field1
          field2: @person2.field2
        ,
          _id: @person3._id
          displayName: @person3.displayName
          field1: @person3.field1
          field2: @person3.field2
        ,
          _id: @person3._id
          displayName: @person3.displayName
          field1: @person3.field1
          field2: @person3.field2
        ]
        slug: 'subdocument-prefix-foobar-subdocumentfoobar-suffix'
        body: 'SubdocumentFooBar'
      nested: [
        required:
          _id: @person2._id
          displayName: @person2.displayName
          field1: @person2.field1
          field2: @person2.field2
        optional:
          _id: @person3._id
        slug: 'nested-prefix-foobar-nestedfoobar-suffix'
        body: 'NestedFooBar'
      ,
        required:
          _id: @person2._id
          displayName: @person2.displayName
          field1: @person2.field1
          field2: @person2.field2
        optional:
          _id: @person3._id
        slug: 'nested-prefix-foobar-nestedfoobar-suffix'
        body: 'NestedFooBar'
      ,
        required:
          _id: @person3._id
          displayName: @person3.displayName
          field1: @person3.field1
          field2: @person3.field2
        optional:
          _id: @person2._id
        slug: 'nested-prefix-foobar-nestedfoobar-suffix'
        body: 'NestedFooBar'
      ,
        required:
          _id: @person3._id
          displayName: @person3.displayName
          field1: @person3.field1
          field2: @person3.field2
        optional:
          _id: @person2._id
        slug: 'nested-prefix-foobar-nestedfoobar-suffix'
        body: 'NestedFooBar'
      ,
        required:
          _id: @person2._id
          displayName: @person2.displayName
          field1: @person2.field1
          field2: @person2.field2
        optional:
          _id: @person2._id
        slug: 'nested-prefix-foobar-nestedfoobar-suffix'
        body: 'NestedFooBar'
      ,
        required:
          _id: @person3._id
          displayName: @person3.displayName
          field1: @person3.field1
          field2: @person3.field2
        optional:
          _id: @person3._id
        slug: 'nested-prefix-foobar-nestedfoobar-suffix'
        body: 'NestedFooBar'
      ]
      body: 'FooBar'
      slug: 'prefix-foobar-subdocumentfoobar-suffix'
      tags: [
        'tag-0-prefix-foobar-subdocumentfoobar-suffix'
        'tag-1-prefix-foobar-nestedfoobar-suffix'
        'tag-2-prefix-foobar-nestedfoobar-suffix'
        'tag-3-prefix-foobar-nestedfoobar-suffix'
        'tag-4-prefix-foobar-nestedfoobar-suffix'
        'tag-5-prefix-foobar-nestedfoobar-suffix'
        'tag-6-prefix-foobar-nestedfoobar-suffix'
      ]

    Person.documents.update @person1Id,
      $set:
        username: 'person1b'
    ,
      expect (error, res) =>
        test.isFalse error, error?.toString?() or error
        test.isTrue res

    # Wait so that observers have time to update documents
    waitForDatabase test, expect
,
  (test, expect) ->
    @person1 = Person.documents.findOne @person1Id,
      transform: null # So that we can use test.equal

    test.equal @person1,
      _id: @person1Id
      username: 'person1b'
      displayName: 'Person 1'
      field1: 'Field 1 - 1a'
      field2: 'Field 1 - 2a'
      posts: [
        _id: @postId
        subdocument:
          body: 'SubdocumentFooBar'
        nested: [
          body: 'NestedFooBar'
        ,
          body: 'NestedFooBar'
        ,
          body: 'NestedFooBar'
        ,
          body: 'NestedFooBar'
        ,
          body: 'NestedFooBar'
        ,
          body: 'NestedFooBar'
        ]
        body: 'FooBar'
      ]
      count: 1

    @post = Post.documents.findOne @postId,
      transform: null # So that we can use test.equal

    test.equal @post,
      _id: @postId
      author:
        _id: @person1._id
        username: @person1.username
        displayName: @person1.displayName
        field1: @person1.field1
        field2: @person1.field2
      subscribers: [
        _id: @person2._id
      ,
        _id: @person2._id
      ,
        _id: @person3._id
      ]
      reviewers: [
        _id: @person2._id
      ,
        _id: @person3._id
      ,
        _id: @person3._id
      ]
      subdocument:
        person:
          _id: @person2._id
          displayName: @person2.displayName
          field1: @person2.field1
          field2: @person2.field2
        persons: [
          _id: @person2._id
          displayName: @person2.displayName
          field1: @person2.field1
          field2: @person2.field2
        ,
          _id: @person2._id
          displayName: @person2.displayName
          field1: @person2.field1
          field2: @person2.field2
        ,
          _id: @person3._id
          displayName: @person3.displayName
          field1: @person3.field1
          field2: @person3.field2
        ,
          _id: @person3._id
          displayName: @person3.displayName
          field1: @person3.field1
          field2: @person3.field2
        ]
        slug: 'subdocument-prefix-foobar-subdocumentfoobar-suffix'
        body: 'SubdocumentFooBar'
      nested: [
        required:
          _id: @person2._id
          displayName: @person2.displayName
          field1: @person2.field1
          field2: @person2.field2
        optional:
          _id: @person3._id
        slug: 'nested-prefix-foobar-nestedfoobar-suffix'
        body: 'NestedFooBar'
      ,
        required:
          _id: @person2._id
          displayName: @person2.displayName
          field1: @person2.field1
          field2: @person2.field2
        optional:
          _id: @person3._id
        slug: 'nested-prefix-foobar-nestedfoobar-suffix'
        body: 'NestedFooBar'
      ,
        required:
          _id: @person3._id
          displayName: @person3.displayName
          field1: @person3.field1
          field2: @person3.field2
        optional:
          _id: @person2._id
        slug: 'nested-prefix-foobar-nestedfoobar-suffix'
        body: 'NestedFooBar'
      ,
        required:
          _id: @person3._id
          displayName: @person3.displayName
          field1: @person3.field1
          field2: @person3.field2
        optional:
          _id: @person2._id
        slug: 'nested-prefix-foobar-nestedfoobar-suffix'
        body: 'NestedFooBar'
      ,
        required:
          _id: @person2._id
          displayName: @person2.displayName
          field1: @person2.field1
          field2: @person2.field2
        optional:
          _id: @person2._id
        slug: 'nested-prefix-foobar-nestedfoobar-suffix'
        body: 'NestedFooBar'
      ,
        required:
          _id: @person3._id
          displayName: @person3.displayName
          field1: @person3.field1
          field2: @person3.field2
        optional:
          _id: @person3._id
        slug: 'nested-prefix-foobar-nestedfoobar-suffix'
        body: 'NestedFooBar'
      ]
      body: 'FooBar'
      slug: 'prefix-foobar-subdocumentfoobar-suffix'
      tags: [
        'tag-0-prefix-foobar-subdocumentfoobar-suffix'
        'tag-1-prefix-foobar-nestedfoobar-suffix'
        'tag-2-prefix-foobar-nestedfoobar-suffix'
        'tag-3-prefix-foobar-nestedfoobar-suffix'
        'tag-4-prefix-foobar-nestedfoobar-suffix'
        'tag-5-prefix-foobar-nestedfoobar-suffix'
        'tag-6-prefix-foobar-nestedfoobar-suffix'
      ]

    Person.documents.update @person2Id,
      $set:
        username: 'person2b'
    ,
      expect (error, res) =>
        test.isFalse error, error?.toString?() or error
        test.isTrue res

    # Wait so that observers have time to update documents
    waitForDatabase test, expect
,
  (test, expect) ->
    @person2 = Person.documents.findOne @person2Id,
      transform: null # So that we can use test.equal

    test.equal @person2,
      _id: @person2Id
      username: 'person2b'
      displayName: 'Person 2'
      field1: 'Field 2 - 1'
      field2: 'Field 2 - 2'
      subdocument:
        posts: [
          _id: @postId
          subdocument:
            body: 'SubdocumentFooBar'
          nested: [
            body: 'NestedFooBar'
          ,
            body: 'NestedFooBar'
          ,
            body: 'NestedFooBar'
          ,
            body: 'NestedFooBar'
          ,
            body: 'NestedFooBar'
          ,
            body: 'NestedFooBar'
          ]
          body: 'FooBar'
        ]
      subdocumentsPosts: [
        _id: @postId
        subdocument:
          body: 'SubdocumentFooBar'
        nested: [
          body: 'NestedFooBar'
        ,
          body: 'NestedFooBar'
        ,
          body: 'NestedFooBar'
        ,
          body: 'NestedFooBar'
        ,
          body: 'NestedFooBar'
        ,
          body: 'NestedFooBar'
        ]
        body: 'FooBar'
      ]
      nestedPosts: [
        _id: @postId
        subdocument:
          body: 'SubdocumentFooBar'
        nested: [
          body: 'NestedFooBar'
        ,
          body: 'NestedFooBar'
        ,
          body: 'NestedFooBar'
        ,
          body: 'NestedFooBar'
        ,
          body: 'NestedFooBar'
        ,
          body: 'NestedFooBar'
        ]
        body: 'FooBar'
      ]
      count: 3

    @post = Post.documents.findOne @postId,
      transform: null # So that we can use test.equal

    test.equal @post,
      _id: @postId
      author:
        _id: @person1._id
        username: @person1.username
        displayName: @person1.displayName
        field1: @person1.field1
        field2: @person1.field2
      subscribers: [
        _id: @person2._id
      ,
        _id: @person2._id
      ,
        _id: @person3._id
      ]
      reviewers: [
        _id: @person2._id
        username: @person2.username
      ,
        _id: @person3._id
      ,
        _id: @person3._id
      ]
      subdocument:
        person:
          _id: @person2._id
          username: @person2.username
          displayName: @person2.displayName
          field1: @person2.field1
          field2: @person2.field2
        persons: [
          _id: @person2._id
          username: @person2.username
          displayName: @person2.displayName
          field1: @person2.field1
          field2: @person2.field2
        ,
          _id: @person2._id
          username: @person2.username
          displayName: @person2.displayName
          field1: @person2.field1
          field2: @person2.field2
        ,
          _id: @person3._id
          displayName: @person3.displayName
          field1: @person3.field1
          field2: @person3.field2
        ,
          _id: @person3._id
          displayName: @person3.displayName
          field1: @person3.field1
          field2: @person3.field2
        ]
        slug: 'subdocument-prefix-foobar-subdocumentfoobar-suffix'
        body: 'SubdocumentFooBar'
      nested: [
        required:
          _id: @person2._id
          username: @person2.username
          displayName: @person2.displayName
          field1: @person2.field1
          field2: @person2.field2
        optional:
          _id: @person3._id
        slug: 'nested-prefix-foobar-nestedfoobar-suffix'
        body: 'NestedFooBar'
      ,
        required:
          _id: @person2._id
          username: @person2.username
          displayName: @person2.displayName
          field1: @person2.field1
          field2: @person2.field2
        optional:
          _id: @person3._id
        slug: 'nested-prefix-foobar-nestedfoobar-suffix'
        body: 'NestedFooBar'
      ,
        required:
          _id: @person3._id
          displayName: @person3.displayName
          field1: @person3.field1
          field2: @person3.field2
        optional:
          _id: @person2._id
          username: @person2.username
        slug: 'nested-prefix-foobar-nestedfoobar-suffix'
        body: 'NestedFooBar'
      ,
        required:
          _id: @person3._id
          displayName: @person3.displayName
          field1: @person3.field1
          field2: @person3.field2
        optional:
          _id: @person2._id
          username: @person2.username
        slug: 'nested-prefix-foobar-nestedfoobar-suffix'
        body: 'NestedFooBar'
      ,
        required:
          _id: @person2._id
          username: @person2.username
          displayName: @person2.displayName
          field1: @person2.field1
          field2: @person2.field2
        optional:
          _id: @person2._id
          username: @person2.username
        slug: 'nested-prefix-foobar-nestedfoobar-suffix'
        body: 'NestedFooBar'
      ,
        required:
          _id: @person3._id
          displayName: @person3.displayName
          field1: @person3.field1
          field2: @person3.field2
        optional:
          _id: @person3._id
        slug: 'nested-prefix-foobar-nestedfoobar-suffix'
        body: 'NestedFooBar'
      ]
      body: 'FooBar'
      slug: 'prefix-foobar-subdocumentfoobar-suffix'
      tags: [
        'tag-0-prefix-foobar-subdocumentfoobar-suffix'
        'tag-1-prefix-foobar-nestedfoobar-suffix'
        'tag-2-prefix-foobar-nestedfoobar-suffix'
        'tag-3-prefix-foobar-nestedfoobar-suffix'
        'tag-4-prefix-foobar-nestedfoobar-suffix'
        'tag-5-prefix-foobar-nestedfoobar-suffix'
        'tag-6-prefix-foobar-nestedfoobar-suffix'
      ]

    Person.documents.update @person3Id,
      $set:
        username: 'person3b'
    ,
      expect (error, res) =>
        test.isFalse error, error?.toString?() or error
        test.isTrue res

    # Wait so that observers have time to update documents
    waitForDatabase test, expect
,
  (test, expect) ->
    @person3 = Person.documents.findOne @person3Id,
      transform: null # So that we can use test.equal

    test.equal @person3,
      _id: @person3Id
      username: 'person3b'
      displayName: 'Person 3'
      field1: 'Field 3 - 1'
      field2: 'Field 3 - 2'
      subdocumentsPosts: [
        _id: @postId
        subdocument:
          body: 'SubdocumentFooBar'
        nested: [
          body: 'NestedFooBar'
        ,
          body: 'NestedFooBar'
        ,
          body: 'NestedFooBar'
        ,
          body: 'NestedFooBar'
        ,
          body: 'NestedFooBar'
        ,
          body: 'NestedFooBar'
        ]
        body: 'FooBar'
      ]
      nestedPosts: [
        _id: @postId
        subdocument:
          body: 'SubdocumentFooBar'
        nested: [
          body: 'NestedFooBar'
        ,
          body: 'NestedFooBar'
        ,
          body: 'NestedFooBar'
        ,
          body: 'NestedFooBar'
        ,
          body: 'NestedFooBar'
        ,
          body: 'NestedFooBar'
        ]
        body: 'FooBar'
      ]
      count: 2

    @post = Post.documents.findOne @postId,
      transform: null # So that we can use test.equal

    test.equal @post,
      _id: @postId
      author:
        _id: @person1._id
        username: @person1.username
        displayName: @person1.displayName
        field1: @person1.field1
        field2: @person1.field2
      subscribers: [
        _id: @person2._id
      ,
        _id: @person2._id
      ,
        _id: @person3._id
      ]
      reviewers: [
        _id: @person2._id
        username: @person2.username
      ,
        _id: @person3._id
        username: @person3.username
      ,
        _id: @person3._id
        username: @person3.username
      ]
      subdocument:
        person:
          _id: @person2._id
          username: @person2.username
          displayName: @person2.displayName
          field1: @person2.field1
          field2: @person2.field2
        persons: [
          _id: @person2._id
          username: @person2.username
          displayName: @person2.displayName
          field1: @person2.field1
          field2: @person2.field2
        ,
          _id: @person2._id
          username: @person2.username
          displayName: @person2.displayName
          field1: @person2.field1
          field2: @person2.field2
        ,
          _id: @person3._id
          username: @person3.username
          displayName: @person3.displayName
          field1: @person3.field1
          field2: @person3.field2
        ,
          _id: @person3._id
          username: @person3.username
          displayName: @person3.displayName
          field1: @person3.field1
          field2: @person3.field2
        ]
        slug: 'subdocument-prefix-foobar-subdocumentfoobar-suffix'
        body: 'SubdocumentFooBar'
      nested: [
        required:
          _id: @person2._id
          username: @person2.username
          displayName: @person2.displayName
          field1: @person2.field1
          field2: @person2.field2
        optional:
          _id: @person3._id
          username: @person3.username
        slug: 'nested-prefix-foobar-nestedfoobar-suffix'
        body: 'NestedFooBar'
      ,
        required:
          _id: @person2._id
          username: @person2.username
          displayName: @person2.displayName
          field1: @person2.field1
          field2: @person2.field2
        optional:
          _id: @person3._id
          username: @person3.username
        slug: 'nested-prefix-foobar-nestedfoobar-suffix'
        body: 'NestedFooBar'
      ,
        required:
          _id: @person3._id
          username: @person3.username
          displayName: @person3.displayName
          field1: @person3.field1
          field2: @person3.field2
        optional:
          _id: @person2._id
          username: @person2.username
        slug: 'nested-prefix-foobar-nestedfoobar-suffix'
        body: 'NestedFooBar'
      ,
        required:
          _id: @person3._id
          username: @person3.username
          displayName: @person3.displayName
          field1: @person3.field1
          field2: @person3.field2
        optional:
          _id: @person2._id
          username: @person2.username
        slug: 'nested-prefix-foobar-nestedfoobar-suffix'
        body: 'NestedFooBar'
      ,
        required:
          _id: @person2._id
          username: @person2.username
          displayName: @person2.displayName
          field1: @person2.field1
          field2: @person2.field2
        optional:
          _id: @person2._id
          username: @person2.username
        slug: 'nested-prefix-foobar-nestedfoobar-suffix'
        body: 'NestedFooBar'
      ,
        required:
          _id: @person3._id
          username: @person3.username
          displayName: @person3.displayName
          field1: @person3.field1
          field2: @person3.field2
        optional:
          _id: @person3._id
          username: @person3.username
        slug: 'nested-prefix-foobar-nestedfoobar-suffix'
        body: 'NestedFooBar'
      ]
      body: 'FooBar'
      slug: 'prefix-foobar-subdocumentfoobar-suffix'
      tags: [
        'tag-0-prefix-foobar-subdocumentfoobar-suffix'
        'tag-1-prefix-foobar-nestedfoobar-suffix'
        'tag-2-prefix-foobar-nestedfoobar-suffix'
        'tag-3-prefix-foobar-nestedfoobar-suffix'
        'tag-4-prefix-foobar-nestedfoobar-suffix'
        'tag-5-prefix-foobar-nestedfoobar-suffix'
        'tag-6-prefix-foobar-nestedfoobar-suffix'
      ]

  (test, expect) ->
    Person.documents.update @person2Id,
      $unset:
        # Removing two fields at the same time
        field1: ''
        field2: ''
    ,
      expect (error, res) =>
        test.isFalse error, error?.toString?() or error
        test.isTrue res

    # Wait so that observers have time to update documents
    waitForDatabase test, expect
,
  (test, expect) ->
    @person2 = Person.documents.findOne @person2Id,
      transform: null # So that we can use test.equal

    test.equal @person2,
      _id: @person2Id
      username: 'person2b'
      displayName: 'Person 2'
      subdocument:
        posts: [
          _id: @postId
          subdocument:
            body: 'SubdocumentFooBar'
          nested: [
            body: 'NestedFooBar'
          ,
            body: 'NestedFooBar'
          ,
            body: 'NestedFooBar'
          ,
            body: 'NestedFooBar'
          ,
            body: 'NestedFooBar'
          ,
            body: 'NestedFooBar'
          ]
          body: 'FooBar'
        ]
      subdocumentsPosts: [
        _id: @postId
        subdocument:
          body: 'SubdocumentFooBar'
        nested: [
          body: 'NestedFooBar'
        ,
          body: 'NestedFooBar'
        ,
          body: 'NestedFooBar'
        ,
          body: 'NestedFooBar'
        ,
          body: 'NestedFooBar'
        ,
          body: 'NestedFooBar'
        ]
        body: 'FooBar'
      ]
      nestedPosts: [
        _id: @postId
        subdocument:
          body: 'SubdocumentFooBar'
        nested: [
          body: 'NestedFooBar'
        ,
          body: 'NestedFooBar'
        ,
          body: 'NestedFooBar'
        ,
          body: 'NestedFooBar'
        ,
          body: 'NestedFooBar'
        ,
          body: 'NestedFooBar'
        ]
        body: 'FooBar'
      ]
      count: 3

    @post = Post.documents.findOne @postId,
      transform: null # So that we can use test.equal

    test.equal @post,
      _id: @postId
      author:
        _id: @person1._id
        username: @person1.username
        displayName: @person1.displayName
        field1: @person1.field1
        field2: @person1.field2
      subscribers: [
        _id: @person2._id
      ,
        _id: @person2._id
      ,
        _id: @person3._id
      ]
      reviewers: [
        _id: @person2._id
        username: @person2.username
      ,
        _id: @person3._id
        username: @person3.username
      ,
        _id: @person3._id
        username: @person3.username
      ]
      subdocument:
        person:
          _id: @person2._id
          username: @person2.username
          displayName: @person2.displayName
        persons: [
          _id: @person2._id
          username: @person2.username
          displayName: @person2.displayName
        ,
          _id: @person2._id
          username: @person2.username
          displayName: @person2.displayName
        ,
          _id: @person3._id
          username: @person3.username
          displayName: @person3.displayName
          field1: @person3.field1
          field2: @person3.field2
        ,
          _id: @person3._id
          username: @person3.username
          displayName: @person3.displayName
          field1: @person3.field1
          field2: @person3.field2
        ]
        slug: 'subdocument-prefix-foobar-subdocumentfoobar-suffix'
        body: 'SubdocumentFooBar'
      nested: [
        required:
          _id: @person2._id
          username: @person2.username
          displayName: @person2.displayName
        optional:
          _id: @person3._id
          username: @person3.username
        slug: 'nested-prefix-foobar-nestedfoobar-suffix'
        body: 'NestedFooBar'
      ,
        required:
          _id: @person2._id
          username: @person2.username
          displayName: @person2.displayName
        optional:
          _id: @person3._id
          username: @person3.username
        slug: 'nested-prefix-foobar-nestedfoobar-suffix'
        body: 'NestedFooBar'
      ,
        required:
          _id: @person3._id
          username: @person3.username
          displayName: @person3.displayName
          field1: @person3.field1
          field2: @person3.field2
        optional:
          _id: @person2._id
          username: @person2.username
        slug: 'nested-prefix-foobar-nestedfoobar-suffix'
        body: 'NestedFooBar'
      ,
        required:
          _id: @person3._id
          username: @person3.username
          displayName: @person3.displayName
          field1: @person3.field1
          field2: @person3.field2
        optional:
          _id: @person2._id
          username: @person2.username
        slug: 'nested-prefix-foobar-nestedfoobar-suffix'
        body: 'NestedFooBar'
      ,
        required:
          _id: @person2._id
          username: @person2.username
          displayName: @person2.displayName
        optional:
          _id: @person2._id
          username: @person2.username
        slug: 'nested-prefix-foobar-nestedfoobar-suffix'
        body: 'NestedFooBar'
      ,
        required:
          _id: @person3._id
          username: @person3.username
          displayName: @person3.displayName
          field1: @person3.field1
          field2: @person3.field2
        optional:
          _id: @person3._id
          username: @person3.username
        slug: 'nested-prefix-foobar-nestedfoobar-suffix'
        body: 'NestedFooBar'
      ]
      body: 'FooBar'
      slug: 'prefix-foobar-subdocumentfoobar-suffix'
      tags: [
        'tag-0-prefix-foobar-subdocumentfoobar-suffix'
        'tag-1-prefix-foobar-nestedfoobar-suffix'
        'tag-2-prefix-foobar-nestedfoobar-suffix'
        'tag-3-prefix-foobar-nestedfoobar-suffix'
        'tag-4-prefix-foobar-nestedfoobar-suffix'
        'tag-5-prefix-foobar-nestedfoobar-suffix'
        'tag-6-prefix-foobar-nestedfoobar-suffix'
      ]

  (test, expect) ->
    Person.documents.update @person2Id,
      $set:
        # Restoring two fields at the same time
        field1: 'Field 2 - 1b'
        field2: 'Field 2 - 2b'
    ,
      expect (error, res) =>
        test.isFalse error, error?.toString?() or error
        test.isTrue res

    # Wait so that observers have time to update documents
    waitForDatabase test, expect
,
  (test, expect) ->
    @person2 = Person.documents.findOne @person2Id,
      transform: null # So that we can use test.equal

    test.equal @person2,
      _id: @person2Id
      username: 'person2b'
      displayName: 'Person 2'
      field1: 'Field 2 - 1b'
      field2: 'Field 2 - 2b'
      subdocument:
        posts: [
          _id: @postId
          subdocument:
            body: 'SubdocumentFooBar'
          nested: [
            body: 'NestedFooBar'
          ,
            body: 'NestedFooBar'
          ,
            body: 'NestedFooBar'
          ,
            body: 'NestedFooBar'
          ,
            body: 'NestedFooBar'
          ,
            body: 'NestedFooBar'
          ]
          body: 'FooBar'
        ]
      subdocumentsPosts: [
        _id: @postId
        subdocument:
          body: 'SubdocumentFooBar'
        nested: [
          body: 'NestedFooBar'
        ,
          body: 'NestedFooBar'
        ,
          body: 'NestedFooBar'
        ,
          body: 'NestedFooBar'
        ,
          body: 'NestedFooBar'
        ,
          body: 'NestedFooBar'
        ]
        body: 'FooBar'
      ]
      nestedPosts: [
        _id: @postId
        subdocument:
          body: 'SubdocumentFooBar'
        nested: [
          body: 'NestedFooBar'
        ,
          body: 'NestedFooBar'
        ,
          body: 'NestedFooBar'
        ,
          body: 'NestedFooBar'
        ,
          body: 'NestedFooBar'
        ,
          body: 'NestedFooBar'
        ]
        body: 'FooBar'
      ]
      count: 3

    @post = Post.documents.findOne @postId,
      transform: null # So that we can use test.equal

    test.equal @post,
      _id: @postId
      author:
        _id: @person1._id
        username: @person1.username
        displayName: @person1.displayName
        field1: @person1.field1
        field2: @person1.field2
      subscribers: [
        _id: @person2._id
      ,
        _id: @person2._id
      ,
        _id: @person3._id
      ]
      reviewers: [
        _id: @person2._id
        username: @person2.username
      ,
        _id: @person3._id
        username: @person3.username
      ,
        _id: @person3._id
        username: @person3.username
      ]
      subdocument:
        person:
          _id: @person2._id
          username: @person2.username
          displayName: @person2.displayName
          field1: @person2.field1
          field2: @person2.field2
        persons: [
          _id: @person2._id
          username: @person2.username
          displayName: @person2.displayName
          field1: @person2.field1
          field2: @person2.field2
        ,
          _id: @person2._id
          username: @person2.username
          displayName: @person2.displayName
          field1: @person2.field1
          field2: @person2.field2
        ,
          _id: @person3._id
          username: @person3.username
          displayName: @person3.displayName
          field1: @person3.field1
          field2: @person3.field2
        ,
          _id: @person3._id
          username: @person3.username
          displayName: @person3.displayName
          field1: @person3.field1
          field2: @person3.field2
        ]
        slug: 'subdocument-prefix-foobar-subdocumentfoobar-suffix'
        body: 'SubdocumentFooBar'
      nested: [
        required:
          _id: @person2._id
          username: @person2.username
          displayName: @person2.displayName
          field1: @person2.field1
          field2: @person2.field2
        optional:
          _id: @person3._id
          username: @person3.username
        slug: 'nested-prefix-foobar-nestedfoobar-suffix'
        body: 'NestedFooBar'
      ,
        required:
          _id: @person2._id
          username: @person2.username
          displayName: @person2.displayName
          field1: @person2.field1
          field2: @person2.field2
        optional:
          _id: @person3._id
          username: @person3.username
        slug: 'nested-prefix-foobar-nestedfoobar-suffix'
        body: 'NestedFooBar'
      ,
        required:
          _id: @person3._id
          username: @person3.username
          displayName: @person3.displayName
          field1: @person3.field1
          field2: @person3.field2
        optional:
          _id: @person2._id
          username: @person2.username
        slug: 'nested-prefix-foobar-nestedfoobar-suffix'
        body: 'NestedFooBar'
      ,
        required:
          _id: @person3._id
          username: @person3.username
          displayName: @person3.displayName
          field1: @person3.field1
          field2: @person3.field2
        optional:
          _id: @person2._id
          username: @person2.username
        slug: 'nested-prefix-foobar-nestedfoobar-suffix'
        body: 'NestedFooBar'
      ,
        required:
          _id: @person2._id
          username: @person2.username
          displayName: @person2.displayName
          field1: @person2.field1
          field2: @person2.field2
        optional:
          _id: @person2._id
          username: @person2.username
        slug: 'nested-prefix-foobar-nestedfoobar-suffix'
        body: 'NestedFooBar'
      ,
        required:
          _id: @person3._id
          username: @person3.username
          displayName: @person3.displayName
          field1: @person3.field1
          field2: @person3.field2
        optional:
          _id: @person3._id
          username: @person3.username
        slug: 'nested-prefix-foobar-nestedfoobar-suffix'
        body: 'NestedFooBar'
      ]
      body: 'FooBar'
      slug: 'prefix-foobar-subdocumentfoobar-suffix'
      tags: [
        'tag-0-prefix-foobar-subdocumentfoobar-suffix'
        'tag-1-prefix-foobar-nestedfoobar-suffix'
        'tag-2-prefix-foobar-nestedfoobar-suffix'
        'tag-3-prefix-foobar-nestedfoobar-suffix'
        'tag-4-prefix-foobar-nestedfoobar-suffix'
        'tag-5-prefix-foobar-nestedfoobar-suffix'
        'tag-6-prefix-foobar-nestedfoobar-suffix'
      ]

    Post.documents.update @postId,
      $set:
        'subdocument.body': 'SubdocumentFooBarZ'
    ,
      expect (error, res) =>
        test.isFalse error, error?.toString?() or error
        test.isTrue res

    # Wait so that observers have time to update documents
    waitForDatabase test, expect
,
  (test, expect) ->
    @person1 = Person.documents.findOne @person1Id,
      transform: null # So that we can use test.equal
    @person2 = Person.documents.findOne @person2Id,
      transform: null # So that we can use test.equal
    @person3 = Person.documents.findOne @person3Id,
      transform: null # So that we can use test.equal

    test.equal @person1,
      _id: @person1Id
      username: 'person1b'
      displayName: 'Person 1'
      field1: 'Field 1 - 1a'
      field2: 'Field 1 - 2a'
      posts: [
        _id: @postId
        subdocument:
          body: 'SubdocumentFooBarZ'
        nested: [
          body: 'NestedFooBar'
        ,
          body: 'NestedFooBar'
        ,
          body: 'NestedFooBar'
        ,
          body: 'NestedFooBar'
        ,
          body: 'NestedFooBar'
        ,
          body: 'NestedFooBar'
        ]
        body: 'FooBar'
      ]
      count: 1
    test.equal @person2,
      _id: @person2Id
      username: 'person2b'
      displayName: 'Person 2'
      field1: 'Field 2 - 1b'
      field2: 'Field 2 - 2b'
      subdocument:
        posts: [
          _id: @postId
          subdocument:
            body: 'SubdocumentFooBarZ'
          nested: [
            body: 'NestedFooBar'
          ,
            body: 'NestedFooBar'
          ,
            body: 'NestedFooBar'
          ,
            body: 'NestedFooBar'
          ,
            body: 'NestedFooBar'
          ,
            body: 'NestedFooBar'
          ]
          body: 'FooBar'
        ]
      subdocumentsPosts: [
        _id: @postId
        subdocument:
          body: 'SubdocumentFooBarZ'
        nested: [
          body: 'NestedFooBar'
        ,
          body: 'NestedFooBar'
        ,
          body: 'NestedFooBar'
        ,
          body: 'NestedFooBar'
        ,
          body: 'NestedFooBar'
        ,
          body: 'NestedFooBar'
        ]
        body: 'FooBar'
      ]
      nestedPosts: [
        _id: @postId
        subdocument:
          body: 'SubdocumentFooBarZ'
        nested: [
          body: 'NestedFooBar'
        ,
          body: 'NestedFooBar'
        ,
          body: 'NestedFooBar'
        ,
          body: 'NestedFooBar'
        ,
          body: 'NestedFooBar'
        ,
          body: 'NestedFooBar'
        ]
        body: 'FooBar'
      ]
      count: 3
    test.equal @person3,
      _id: @person3Id
      username: 'person3b'
      displayName: 'Person 3'
      field1: 'Field 3 - 1'
      field2: 'Field 3 - 2'
      subdocumentsPosts: [
        _id: @postId
        subdocument:
          body: 'SubdocumentFooBarZ'
        nested: [
          body: 'NestedFooBar'
        ,
          body: 'NestedFooBar'
        ,
          body: 'NestedFooBar'
        ,
          body: 'NestedFooBar'
        ,
          body: 'NestedFooBar'
        ,
          body: 'NestedFooBar'
        ]
        body: 'FooBar'
      ]
      nestedPosts: [
        _id: @postId
        subdocument:
          body: 'SubdocumentFooBarZ'
        nested: [
          body: 'NestedFooBar'
        ,
          body: 'NestedFooBar'
        ,
          body: 'NestedFooBar'
        ,
          body: 'NestedFooBar'
        ,
          body: 'NestedFooBar'
        ,
          body: 'NestedFooBar'
        ]
        body: 'FooBar'
      ]
      count: 2

    @post = Post.documents.findOne @postId,
      transform: null # So that we can use test.equal

    test.equal @post,
      _id: @postId
      author:
        _id: @person1._id
        username: @person1.username
        displayName: @person1.displayName
        field1: @person1.field1
        field2: @person1.field2
      subscribers: [
        _id: @person2._id
      ,
        _id: @person2._id
      ,
        _id: @person3._id
      ]
      reviewers: [
        _id: @person2._id
        username: @person2.username
      ,
        _id: @person3._id
        username: @person3.username
      ,
        _id: @person3._id
        username: @person3.username
      ]
      subdocument:
        person:
          _id: @person2._id
          username: @person2.username
          displayName: @person2.displayName
          field1: @person2.field1
          field2: @person2.field2
        persons: [
          _id: @person2._id
          username: @person2.username
          displayName: @person2.displayName
          field1: @person2.field1
          field2: @person2.field2
        ,
          _id: @person2._id
          username: @person2.username
          displayName: @person2.displayName
          field1: @person2.field1
          field2: @person2.field2
        ,
          _id: @person3._id
          username: @person3.username
          displayName: @person3.displayName
          field1: @person3.field1
          field2: @person3.field2
        ,
          _id: @person3._id
          username: @person3.username
          displayName: @person3.displayName
          field1: @person3.field1
          field2: @person3.field2
        ]
        slug: 'subdocument-prefix-foobar-subdocumentfoobarz-suffix'
        body: 'SubdocumentFooBarZ'
      nested: [
        required:
          _id: @person2._id
          username: @person2.username
          displayName: @person2.displayName
          field1: @person2.field1
          field2: @person2.field2
        optional:
          _id: @person3._id
          username: @person3.username
        slug: 'nested-prefix-foobar-nestedfoobar-suffix'
        body: 'NestedFooBar'
      ,
        required:
          _id: @person2._id
          username: @person2.username
          displayName: @person2.displayName
          field1: @person2.field1
          field2: @person2.field2
        optional:
          _id: @person3._id
          username: @person3.username
        slug: 'nested-prefix-foobar-nestedfoobar-suffix'
        body: 'NestedFooBar'
      ,
        required:
          _id: @person3._id
          username: @person3.username
          displayName: @person3.displayName
          field1: @person3.field1
          field2: @person3.field2
        optional:
          _id: @person2._id
          username: @person2.username
        slug: 'nested-prefix-foobar-nestedfoobar-suffix'
        body: 'NestedFooBar'
      ,
        required:
          _id: @person3._id
          username: @person3.username
          displayName: @person3.displayName
          field1: @person3.field1
          field2: @person3.field2
        optional:
          _id: @person2._id
          username: @person2.username
        slug: 'nested-prefix-foobar-nestedfoobar-suffix'
        body: 'NestedFooBar'
      ,
        required:
          _id: @person2._id
          username: @person2.username
          displayName: @person2.displayName
          field1: @person2.field1
          field2: @person2.field2
        optional:
          _id: @person2._id
          username: @person2.username
        slug: 'nested-prefix-foobar-nestedfoobar-suffix'
        body: 'NestedFooBar'
      ,
        required:
          _id: @person3._id
          username: @person3.username
          displayName: @person3.displayName
          field1: @person3.field1
          field2: @person3.field2
        optional:
          _id: @person3._id
          username: @person3.username
        slug: 'nested-prefix-foobar-nestedfoobar-suffix'
        body: 'NestedFooBar'
      ]
      body: 'FooBar'
      slug: 'prefix-foobar-subdocumentfoobarz-suffix'
      tags: [
        'tag-0-prefix-foobar-subdocumentfoobarz-suffix'
        'tag-1-prefix-foobar-nestedfoobar-suffix'
        'tag-2-prefix-foobar-nestedfoobar-suffix'
        'tag-3-prefix-foobar-nestedfoobar-suffix'
        'tag-4-prefix-foobar-nestedfoobar-suffix'
        'tag-5-prefix-foobar-nestedfoobar-suffix'
        'tag-6-prefix-foobar-nestedfoobar-suffix'
      ]

    Post.documents.update @postId,
      $set:
        'nested.0.body': 'NestedFooBarZ'
    ,
      expect (error, res) =>
        test.isFalse error, error?.toString?() or error
        test.isTrue res

    # Wait so that observers have time to update documents
    waitForDatabase test, expect
,
  (test, expect) ->
    @person1 = Person.documents.findOne @person1Id,
      transform: null # So that we can use test.equal
    @person2 = Person.documents.findOne @person2Id,
      transform: null # So that we can use test.equal
    @person3 = Person.documents.findOne @person3Id,
      transform: null # So that we can use test.equal

    test.equal @person1,
      _id: @person1Id
      username: 'person1b'
      displayName: 'Person 1'
      field1: 'Field 1 - 1a'
      field2: 'Field 1 - 2a'
      posts: [
        _id: @postId
        subdocument:
          body: 'SubdocumentFooBarZ'
        nested: [
          body: 'NestedFooBarZ'
        ,
          body: 'NestedFooBar'
        ,
          body: 'NestedFooBar'
        ,
          body: 'NestedFooBar'
        ,
          body: 'NestedFooBar'
        ,
          body: 'NestedFooBar'
        ]
        body: 'FooBar'
      ]
      count: 1
    test.equal @person2,
      _id: @person2Id
      username: 'person2b'
      displayName: 'Person 2'
      field1: 'Field 2 - 1b'
      field2: 'Field 2 - 2b'
      subdocumentsPosts: [
        _id: @postId
        subdocument:
          body: 'SubdocumentFooBarZ'
        nested: [
          body: 'NestedFooBarZ'
        ,
          body: 'NestedFooBar'
        ,
          body: 'NestedFooBar'
        ,
          body: 'NestedFooBar'
        ,
          body: 'NestedFooBar'
        ,
          body: 'NestedFooBar'
        ]
        body: 'FooBar'
      ]
      subdocument:
        posts: [
          _id: @postId
          subdocument:
            body: 'SubdocumentFooBarZ'
          nested: [
            body: 'NestedFooBarZ'
          ,
            body: 'NestedFooBar'
          ,
            body: 'NestedFooBar'
          ,
            body: 'NestedFooBar'
          ,
            body: 'NestedFooBar'
          ,
            body: 'NestedFooBar'
          ]
          body: 'FooBar'
        ]
      nestedPosts: [
        _id: @postId
        subdocument:
          body: 'SubdocumentFooBarZ'
        nested: [
          body: 'NestedFooBarZ'
        ,
          body: 'NestedFooBar'
        ,
          body: 'NestedFooBar'
        ,
          body: 'NestedFooBar'
        ,
          body: 'NestedFooBar'
        ,
          body: 'NestedFooBar'
        ]
        body: 'FooBar'
      ]
      count: 3
    test.equal @person3,
      _id: @person3Id
      username: 'person3b'
      displayName: 'Person 3'
      field1: 'Field 3 - 1'
      field2: 'Field 3 - 2'
      subdocumentsPosts: [
        _id: @postId
        subdocument:
          body: 'SubdocumentFooBarZ'
        nested: [
          body: 'NestedFooBarZ'
        ,
          body: 'NestedFooBar'
        ,
          body: 'NestedFooBar'
        ,
          body: 'NestedFooBar'
        ,
          body: 'NestedFooBar'
        ,
          body: 'NestedFooBar'
        ]
        body: 'FooBar'
      ]
      nestedPosts: [
        _id: @postId
        subdocument:
          body: 'SubdocumentFooBarZ'
        nested: [
          body: 'NestedFooBarZ'
        ,
          body: 'NestedFooBar'
        ,
          body: 'NestedFooBar'
        ,
          body: 'NestedFooBar'
        ,
          body: 'NestedFooBar'
        ,
          body: 'NestedFooBar'
        ]
        body: 'FooBar'
      ]
      count: 2

    @post = Post.documents.findOne @postId,
      transform: null # So that we can use test.equal

    test.equal @post,
      _id: @postId
      author:
        _id: @person1._id
        username: @person1.username
        displayName: @person1.displayName
        field1: @person1.field1
        field2: @person1.field2
      subscribers: [
        _id: @person2._id
      ,
        _id: @person2._id
      ,
        _id: @person3._id
      ]
      reviewers: [
        _id: @person2._id
        username: @person2.username
      ,
        _id: @person3._id
        username: @person3.username
      ,
        _id: @person3._id
        username: @person3.username
      ]
      subdocument:
        person:
          _id: @person2._id
          username: @person2.username
          displayName: @person2.displayName
          field1: @person2.field1
          field2: @person2.field2
        persons: [
          _id: @person2._id
          username: @person2.username
          displayName: @person2.displayName
          field1: @person2.field1
          field2: @person2.field2
        ,
          _id: @person2._id
          username: @person2.username
          displayName: @person2.displayName
          field1: @person2.field1
          field2: @person2.field2
        ,
          _id: @person3._id
          username: @person3.username
          displayName: @person3.displayName
          field1: @person3.field1
          field2: @person3.field2
        ,
          _id: @person3._id
          username: @person3.username
          displayName: @person3.displayName
          field1: @person3.field1
          field2: @person3.field2
        ]
        slug: 'subdocument-prefix-foobar-subdocumentfoobarz-suffix'
        body: 'SubdocumentFooBarZ'
      nested: [
        required:
          _id: @person2._id
          username: @person2.username
          displayName: @person2.displayName
          field1: @person2.field1
          field2: @person2.field2
        optional:
          _id: @person3._id
          username: @person3.username
        slug: 'nested-prefix-foobar-nestedfoobarz-suffix'
        body: 'NestedFooBarZ'
      ,
        required:
          _id: @person2._id
          username: @person2.username
          displayName: @person2.displayName
          field1: @person2.field1
          field2: @person2.field2
        optional:
          _id: @person3._id
          username: @person3.username
        slug: 'nested-prefix-foobar-nestedfoobar-suffix'
        body: 'NestedFooBar'
      ,
        required:
          _id: @person3._id
          username: @person3.username
          displayName: @person3.displayName
          field1: @person3.field1
          field2: @person3.field2
        optional:
          _id: @person2._id
          username: @person2.username
        slug: 'nested-prefix-foobar-nestedfoobar-suffix'
        body: 'NestedFooBar'
      ,
        required:
          _id: @person3._id
          username: @person3.username
          displayName: @person3.displayName
          field1: @person3.field1
          field2: @person3.field2
        optional:
          _id: @person2._id
          username: @person2.username
        slug: 'nested-prefix-foobar-nestedfoobar-suffix'
        body: 'NestedFooBar'
      ,
        required:
          _id: @person2._id
          username: @person2.username
          displayName: @person2.displayName
          field1: @person2.field1
          field2: @person2.field2
        optional:
          _id: @person2._id
          username: @person2.username
        slug: 'nested-prefix-foobar-nestedfoobar-suffix'
        body: 'NestedFooBar'
      ,
        required:
          _id: @person3._id
          username: @person3.username
          displayName: @person3.displayName
          field1: @person3.field1
          field2: @person3.field2
        optional:
          _id: @person3._id
          username: @person3.username
        slug: 'nested-prefix-foobar-nestedfoobar-suffix'
        body: 'NestedFooBar'
      ]
      body: 'FooBar'
      slug: 'prefix-foobar-subdocumentfoobarz-suffix'
      tags: [
        'tag-0-prefix-foobar-subdocumentfoobarz-suffix'
        'tag-1-prefix-foobar-nestedfoobarz-suffix'
        'tag-2-prefix-foobar-nestedfoobar-suffix'
        'tag-3-prefix-foobar-nestedfoobar-suffix'
        'tag-4-prefix-foobar-nestedfoobar-suffix'
        'tag-5-prefix-foobar-nestedfoobar-suffix'
        'tag-6-prefix-foobar-nestedfoobar-suffix'
      ]

    Post.documents.update @postId,
      $set:
        'nested.4.body': 'NestedFooBarA'
    ,
      expect (error, res) =>
        test.isFalse error, error?.toString?() or error
        test.isTrue res

    # Wait so that observers have time to update documents
    waitForDatabase test, expect
,
  (test, expect) ->
    @person1 = Person.documents.findOne @person1Id,
      transform: null # So that we can use test.equal
    @person2 = Person.documents.findOne @person2Id,
      transform: null # So that we can use test.equal
    @person3 = Person.documents.findOne @person3Id,
      transform: null # So that we can use test.equal

    test.equal @person1,
      _id: @person1Id
      username: 'person1b'
      displayName: 'Person 1'
      field1: 'Field 1 - 1a'
      field2: 'Field 1 - 2a'
      posts: [
        _id: @postId
        subdocument:
          body: 'SubdocumentFooBarZ'
        nested: [
          body: 'NestedFooBarZ'
        ,
          body: 'NestedFooBar'
        ,
          body: 'NestedFooBar'
        ,
          body: 'NestedFooBar'
        ,
          body: 'NestedFooBarA'
        ,
          body: 'NestedFooBar'
        ]
        body: 'FooBar'
      ]
      count: 1
    test.equal @person2,
      _id: @person2Id
      username: 'person2b'
      displayName: 'Person 2'
      field1: 'Field 2 - 1b'
      field2: 'Field 2 - 2b'
      subdocument:
        posts: [
          _id: @postId
          subdocument:
            body: 'SubdocumentFooBarZ'
          nested: [
            body: 'NestedFooBarZ'
          ,
            body: 'NestedFooBar'
          ,
            body: 'NestedFooBar'
          ,
            body: 'NestedFooBar'
          ,
            body: 'NestedFooBarA'
          ,
            body: 'NestedFooBar'
          ]
          body: 'FooBar'
        ]
      subdocumentsPosts: [
        _id: @postId
        subdocument:
          body: 'SubdocumentFooBarZ'
        nested: [
          body: 'NestedFooBarZ'
        ,
          body: 'NestedFooBar'
        ,
          body: 'NestedFooBar'
        ,
          body: 'NestedFooBar'
        ,
          body: 'NestedFooBarA'
        ,
          body: 'NestedFooBar'
        ]
        body: 'FooBar'
      ]
      nestedPosts: [
        _id: @postId
        subdocument:
          body: 'SubdocumentFooBarZ'
        nested: [
          body: 'NestedFooBarZ'
        ,
          body: 'NestedFooBar'
        ,
          body: 'NestedFooBar'
        ,
          body: 'NestedFooBar'
        ,
          body: 'NestedFooBarA'
        ,
          body: 'NestedFooBar'
        ]
        body: 'FooBar'
      ]
      count: 3
    test.equal @person3,
      _id: @person3Id
      username: 'person3b'
      displayName: 'Person 3'
      field1: 'Field 3 - 1'
      field2: 'Field 3 - 2'
      subdocumentsPosts: [
        _id: @postId
        subdocument:
          body: 'SubdocumentFooBarZ'
        nested: [
          body: 'NestedFooBarZ'
        ,
          body: 'NestedFooBar'
        ,
          body: 'NestedFooBar'
        ,
          body: 'NestedFooBar'
        ,
          body: 'NestedFooBarA'
        ,
          body: 'NestedFooBar'
        ]
        body: 'FooBar'
      ]
      nestedPosts: [
        _id: @postId
        subdocument:
          body: 'SubdocumentFooBarZ'
        nested: [
          body: 'NestedFooBarZ'
        ,
          body: 'NestedFooBar'
        ,
          body: 'NestedFooBar'
        ,
          body: 'NestedFooBar'
        ,
          body: 'NestedFooBarA'
        ,
          body: 'NestedFooBar'
        ]
        body: 'FooBar'
      ]
      count: 2

    @post = Post.documents.findOne @postId,
      transform: null # So that we can use test.equal

    test.equal @post,
      _id: @postId
      author:
        _id: @person1._id
        username: @person1.username
        displayName: @person1.displayName
        field1: @person1.field1
        field2: @person1.field2
      subscribers: [
        _id: @person2._id
      ,
        _id: @person2._id
      ,
        _id: @person3._id
      ]
      reviewers: [
        _id: @person2._id
        username: @person2.username
      ,
        _id: @person3._id
        username: @person3.username
      ,
        _id: @person3._id
        username: @person3.username
      ]
      subdocument:
        person:
          _id: @person2._id
          username: @person2.username
          displayName: @person2.displayName
          field1: @person2.field1
          field2: @person2.field2
        persons: [
          _id: @person2._id
          username: @person2.username
          displayName: @person2.displayName
          field1: @person2.field1
          field2: @person2.field2
        ,
          _id: @person2._id
          username: @person2.username
          displayName: @person2.displayName
          field1: @person2.field1
          field2: @person2.field2
        ,
          _id: @person3._id
          username: @person3.username
          displayName: @person3.displayName
          field1: @person3.field1
          field2: @person3.field2
        ,
          _id: @person3._id
          username: @person3.username
          displayName: @person3.displayName
          field1: @person3.field1
          field2: @person3.field2
        ]
        slug: 'subdocument-prefix-foobar-subdocumentfoobarz-suffix'
        body: 'SubdocumentFooBarZ'
      nested: [
        required:
          _id: @person2._id
          username: @person2.username
          displayName: @person2.displayName
          field1: @person2.field1
          field2: @person2.field2
        optional:
          _id: @person3._id
          username: @person3.username
        slug: 'nested-prefix-foobar-nestedfoobarz-suffix'
        body: 'NestedFooBarZ'
      ,
        required:
          _id: @person2._id
          username: @person2.username
          displayName: @person2.displayName
          field1: @person2.field1
          field2: @person2.field2
        optional:
          _id: @person3._id
          username: @person3.username
        slug: 'nested-prefix-foobar-nestedfoobar-suffix'
        body: 'NestedFooBar'
      ,
        required:
          _id: @person3._id
          username: @person3.username
          displayName: @person3.displayName
          field1: @person3.field1
          field2: @person3.field2
        optional:
          _id: @person2._id
          username: @person2.username
        slug: 'nested-prefix-foobar-nestedfoobar-suffix'
        body: 'NestedFooBar'
      ,
        required:
          _id: @person3._id
          username: @person3.username
          displayName: @person3.displayName
          field1: @person3.field1
          field2: @person3.field2
        optional:
          _id: @person2._id
          username: @person2.username
        slug: 'nested-prefix-foobar-nestedfoobar-suffix'
        body: 'NestedFooBar'
      ,
        required:
          _id: @person2._id
          username: @person2.username
          displayName: @person2.displayName
          field1: @person2.field1
          field2: @person2.field2
        optional:
          _id: @person2._id
          username: @person2.username
        slug: 'nested-prefix-foobar-nestedfoobara-suffix'
        body: 'NestedFooBarA'
      ,
        required:
          _id: @person3._id
          username: @person3.username
          displayName: @person3.displayName
          field1: @person3.field1
          field2: @person3.field2
        optional:
          _id: @person3._id
          username: @person3.username
        slug: 'nested-prefix-foobar-nestedfoobar-suffix'
        body: 'NestedFooBar'
      ]
      body: 'FooBar'
      slug: 'prefix-foobar-subdocumentfoobarz-suffix'
      tags: [
        'tag-0-prefix-foobar-subdocumentfoobarz-suffix'
        'tag-1-prefix-foobar-nestedfoobarz-suffix'
        'tag-2-prefix-foobar-nestedfoobar-suffix'
        'tag-3-prefix-foobar-nestedfoobar-suffix'
        'tag-4-prefix-foobar-nestedfoobar-suffix'
        'tag-5-prefix-foobar-nestedfoobara-suffix'
        'tag-6-prefix-foobar-nestedfoobar-suffix'
      ]

    Post.documents.update @postId,
      $set:
        'nested.3.body': null
    ,
      expect (error, res) =>
        test.isFalse error, error?.toString?() or error
        test.isTrue res

    # Wait so that observers have time to update documents
    waitForDatabase test, expect
,
  (test, expect) ->
    @person1 = Person.documents.findOne @person1Id,
      transform: null # So that we can use test.equal
    @person2 = Person.documents.findOne @person2Id,
      transform: null # So that we can use test.equal
    @person3 = Person.documents.findOne @person3Id,
      transform: null # So that we can use test.equal

    test.equal @person1,
      _id: @person1Id
      username: 'person1b'
      displayName: 'Person 1'
      field1: 'Field 1 - 1a'
      field2: 'Field 1 - 2a'
      posts: [
        _id: @postId
        subdocument:
          body: 'SubdocumentFooBarZ'
        nested: [
          body: 'NestedFooBarZ'
        ,
          body: 'NestedFooBar'
        ,
          body: 'NestedFooBar'
        ,
          body: null
        ,
          body: 'NestedFooBarA'
        ,
          body: 'NestedFooBar'
        ]
        body: 'FooBar'
      ]
      count: 1
    test.equal @person2,
      _id: @person2Id
      username: 'person2b'
      displayName: 'Person 2'
      field1: 'Field 2 - 1b'
      field2: 'Field 2 - 2b'
      subdocument:
        posts: [
          _id: @postId
          subdocument:
            body: 'SubdocumentFooBarZ'
          nested: [
            body: 'NestedFooBarZ'
          ,
            body: 'NestedFooBar'
          ,
            body: 'NestedFooBar'
          ,
            body: null
          ,
            body: 'NestedFooBarA'
          ,
            body: 'NestedFooBar'
          ]
          body: 'FooBar'
        ]
      subdocumentsPosts: [
        _id: @postId
        subdocument:
          body: 'SubdocumentFooBarZ'
        nested: [
          body: 'NestedFooBarZ'
        ,
          body: 'NestedFooBar'
        ,
          body: 'NestedFooBar'
        ,
          body: null
        ,
          body: 'NestedFooBarA'
        ,
          body: 'NestedFooBar'
        ]
        body: 'FooBar'
      ]
      nestedPosts: [
        _id: @postId
        subdocument:
          body: 'SubdocumentFooBarZ'
        nested: [
          body: 'NestedFooBarZ'
        ,
          body: 'NestedFooBar'
        ,
          body: 'NestedFooBar'
        ,
          body: null
        ,
          body: 'NestedFooBarA'
        ,
          body: 'NestedFooBar'
        ]
        body: 'FooBar'
      ]
      count: 3
    test.equal @person3,
      _id: @person3Id
      username: 'person3b'
      displayName: 'Person 3'
      field1: 'Field 3 - 1'
      field2: 'Field 3 - 2'
      subdocumentsPosts: [
        _id: @postId
        subdocument:
          body: 'SubdocumentFooBarZ'
        nested: [
          body: 'NestedFooBarZ'
        ,
          body: 'NestedFooBar'
        ,
          body: 'NestedFooBar'
        ,
          body: null
        ,
          body: 'NestedFooBarA'
        ,
          body: 'NestedFooBar'
        ]
        body: 'FooBar'
      ]
      nestedPosts: [
        _id: @postId
        subdocument:
          body: 'SubdocumentFooBarZ'
        nested: [
          body: 'NestedFooBarZ'
        ,
          body: 'NestedFooBar'
        ,
          body: 'NestedFooBar'
        ,
          body: null
        ,
          body: 'NestedFooBarA'
        ,
          body: 'NestedFooBar'
        ]
        body: 'FooBar'
      ]
      count: 2

    @post = Post.documents.findOne @postId,
      transform: null # So that we can use test.equal

    test.equal @post,
      _id: @postId
      author:
        _id: @person1._id
        username: @person1.username
        displayName: @person1.displayName
        field1: @person1.field1
        field2: @person1.field2
      subscribers: [
        _id: @person2._id
      ,
        _id: @person2._id
      ,
        _id: @person3._id
      ]
      reviewers: [
        _id: @person2._id
        username: @person2.username
      ,
        _id: @person3._id
        username: @person3.username
      ,
        _id: @person3._id
        username: @person3.username
      ]
      subdocument:
        person:
          _id: @person2._id
          username: @person2.username
          displayName: @person2.displayName
          field1: @person2.field1
          field2: @person2.field2
        persons: [
          _id: @person2._id
          username: @person2.username
          displayName: @person2.displayName
          field1: @person2.field1
          field2: @person2.field2
        ,
          _id: @person2._id
          username: @person2.username
          displayName: @person2.displayName
          field1: @person2.field1
          field2: @person2.field2
        ,
          _id: @person3._id
          username: @person3.username
          displayName: @person3.displayName
          field1: @person3.field1
          field2: @person3.field2
        ,
          _id: @person3._id
          username: @person3.username
          displayName: @person3.displayName
          field1: @person3.field1
          field2: @person3.field2
        ]
        slug: 'subdocument-prefix-foobar-subdocumentfoobarz-suffix'
        body: 'SubdocumentFooBarZ'
      nested: [
        required:
          _id: @person2._id
          username: @person2.username
          displayName: @person2.displayName
          field1: @person2.field1
          field2: @person2.field2
        optional:
          _id: @person3._id
          username: @person3.username
        slug: 'nested-prefix-foobar-nestedfoobarz-suffix'
        body: 'NestedFooBarZ'
      ,
        required:
          _id: @person2._id
          username: @person2.username
          displayName: @person2.displayName
          field1: @person2.field1
          field2: @person2.field2
        optional:
          _id: @person3._id
          username: @person3.username
        slug: 'nested-prefix-foobar-nestedfoobar-suffix'
        body: 'NestedFooBar'
      ,
        required:
          _id: @person3._id
          username: @person3.username
          displayName: @person3.displayName
          field1: @person3.field1
          field2: @person3.field2
        optional:
          _id: @person2._id
          username: @person2.username
        slug: 'nested-prefix-foobar-nestedfoobar-suffix'
        body: 'NestedFooBar'
      ,
        required:
          _id: @person3._id
          username: @person3.username
          displayName: @person3.displayName
          field1: @person3.field1
          field2: @person3.field2
        optional:
          _id: @person2._id
          username: @person2.username
        slug: null
        body: null
      ,
        required:
          _id: @person2._id
          username: @person2.username
          displayName: @person2.displayName
          field1: @person2.field1
          field2: @person2.field2
        optional:
          _id: @person2._id
          username: @person2.username
        slug: 'nested-prefix-foobar-nestedfoobara-suffix'
        body: 'NestedFooBarA'
      ,
        required:
          _id: @person3._id
          username: @person3.username
          displayName: @person3.displayName
          field1: @person3.field1
          field2: @person3.field2
        optional:
          _id: @person3._id
          username: @person3.username
        slug: 'nested-prefix-foobar-nestedfoobar-suffix'
        body: 'NestedFooBar'
      ]
      body: 'FooBar'
      slug: 'prefix-foobar-subdocumentfoobarz-suffix'
      tags: [
        'tag-0-prefix-foobar-subdocumentfoobarz-suffix'
        'tag-1-prefix-foobar-nestedfoobarz-suffix'
        'tag-2-prefix-foobar-nestedfoobar-suffix'
        'tag-3-prefix-foobar-nestedfoobar-suffix'
        'tag-4-prefix-foobar-nestedfoobara-suffix'
        'tag-5-prefix-foobar-nestedfoobar-suffix'
      ]

    Post.documents.update @postId,
      $unset:
        'nested.2.body': ''
    ,
      expect (error, res) =>
        test.isFalse error, error?.toString?() or error
        test.isTrue res

    # Wait so that observers have time to update documents
    waitForDatabase test, expect
,
  (test, expect) ->
    @person1 = Person.documents.findOne @person1Id,
      transform: null # So that we can use test.equal
    @person2 = Person.documents.findOne @person2Id,
      transform: null # So that we can use test.equal
    @person3 = Person.documents.findOne @person3Id,
      transform: null # So that we can use test.equal

    test.equal @person1,
      _id: @person1Id
      username: 'person1b'
      displayName: 'Person 1'
      field1: 'Field 1 - 1a'
      field2: 'Field 1 - 2a'
      posts: [
        _id: @postId
        subdocument:
          body: 'SubdocumentFooBarZ'
        nested: [
          body: 'NestedFooBarZ'
        ,
          body: 'NestedFooBar'
        ,
          {}
        ,
          body: null
        ,
          body: 'NestedFooBarA'
        ,
          body: 'NestedFooBar'
        ]
        body: 'FooBar'
      ]
      count: 1
    test.equal @person2,
      _id: @person2Id
      username: 'person2b'
      displayName: 'Person 2'
      field1: 'Field 2 - 1b'
      field2: 'Field 2 - 2b'
      subdocumentsPosts: [
        _id: @postId
        subdocument:
          body: 'SubdocumentFooBarZ'
        nested: [
          body: 'NestedFooBarZ'
        ,
          body: 'NestedFooBar'
        ,
          {}
        ,
          body: null
        ,
          body: 'NestedFooBarA'
        ,
          body: 'NestedFooBar'
        ]
        body: 'FooBar'
      ]
      subdocument:
        posts: [
          _id: @postId
          subdocument:
            body: 'SubdocumentFooBarZ'
          nested: [
            body: 'NestedFooBarZ'
          ,
            body: 'NestedFooBar'
          ,
            {}
          ,
            body: null
          ,
            body: 'NestedFooBarA'
          ,
            body: 'NestedFooBar'
          ]
          body: 'FooBar'
        ]
      nestedPosts: [
        _id: @postId
        subdocument:
          body: 'SubdocumentFooBarZ'
        nested: [
          body: 'NestedFooBarZ'
        ,
          body: 'NestedFooBar'
        ,
          {}
        ,
          body: null
        ,
          body: 'NestedFooBarA'
        ,
          body: 'NestedFooBar'
        ]
        body: 'FooBar'
      ]
      count: 3
    test.equal @person3,
      _id: @person3Id
      username: 'person3b'
      displayName: 'Person 3'
      field1: 'Field 3 - 1'
      field2: 'Field 3 - 2'
      subdocumentsPosts: [
        _id: @postId
        subdocument:
          body: 'SubdocumentFooBarZ'
        nested: [
          body: 'NestedFooBarZ'
        ,
          body: 'NestedFooBar'
        ,
          {}
        ,
          body: null
        ,
          body: 'NestedFooBarA'
        ,
          body: 'NestedFooBar'
        ]
        body: 'FooBar'
      ]
      nestedPosts: [
        _id: @postId
        subdocument:
          body: 'SubdocumentFooBarZ'
        nested: [
          body: 'NestedFooBarZ'
        ,
          body: 'NestedFooBar'
        ,
          {}
        ,
          body: null
        ,
          body: 'NestedFooBarA'
        ,
          body: 'NestedFooBar'
        ]
        body: 'FooBar'
      ]
      count: 2

    @post = Post.documents.findOne @postId,
      transform: null # So that we can use test.equal

    test.equal @post,
      _id: @postId
      author:
        _id: @person1._id
        username: @person1.username
        displayName: @person1.displayName
        field1: @person1.field1
        field2: @person1.field2
      subscribers: [
        _id: @person2._id
      ,
        _id: @person2._id
      ,
        _id: @person3._id
      ]
      reviewers: [
        _id: @person2._id
        username: @person2.username
      ,
        _id: @person3._id
        username: @person3.username
      ,
        _id: @person3._id
        username: @person3.username
      ]
      subdocument:
        person:
          _id: @person2._id
          username: @person2.username
          displayName: @person2.displayName
          field1: @person2.field1
          field2: @person2.field2
        persons: [
          _id: @person2._id
          username: @person2.username
          displayName: @person2.displayName
          field1: @person2.field1
          field2: @person2.field2
        ,
          _id: @person2._id
          username: @person2.username
          displayName: @person2.displayName
          field1: @person2.field1
          field2: @person2.field2
        ,
          _id: @person3._id
          username: @person3.username
          displayName: @person3.displayName
          field1: @person3.field1
          field2: @person3.field2
        ,
          _id: @person3._id
          username: @person3.username
          displayName: @person3.displayName
          field1: @person3.field1
          field2: @person3.field2
        ]
        slug: 'subdocument-prefix-foobar-subdocumentfoobarz-suffix'
        body: 'SubdocumentFooBarZ'
      nested: [
        required:
          _id: @person2._id
          username: @person2.username
          displayName: @person2.displayName
          field1: @person2.field1
          field2: @person2.field2
        optional:
          _id: @person3._id
          username: @person3.username
        slug: 'nested-prefix-foobar-nestedfoobarz-suffix'
        body: 'NestedFooBarZ'
      ,
        required:
          _id: @person2._id
          username: @person2.username
          displayName: @person2.displayName
          field1: @person2.field1
          field2: @person2.field2
        optional:
          _id: @person3._id
          username: @person3.username
        slug: 'nested-prefix-foobar-nestedfoobar-suffix'
        body: 'NestedFooBar'
      ,
        required:
          _id: @person3._id
          username: @person3.username
          displayName: @person3.displayName
          field1: @person3.field1
          field2: @person3.field2
        optional:
          _id: @person2._id
          username: @person2.username
      ,
        required:
          _id: @person3._id
          username: @person3.username
          displayName: @person3.displayName
          field1: @person3.field1
          field2: @person3.field2
        optional:
          _id: @person2._id
          username: @person2.username
        slug: null
        body: null
      ,
        required:
          _id: @person2._id
          username: @person2.username
          displayName: @person2.displayName
          field1: @person2.field1
          field2: @person2.field2
        optional:
          _id: @person2._id
          username: @person2.username
        slug: 'nested-prefix-foobar-nestedfoobara-suffix'
        body: 'NestedFooBarA'
      ,
        required:
          _id: @person3._id
          username: @person3.username
          displayName: @person3.displayName
          field1: @person3.field1
          field2: @person3.field2
        optional:
          _id: @person3._id
          username: @person3.username
        slug: 'nested-prefix-foobar-nestedfoobar-suffix'
        body: 'NestedFooBar'
      ]
      body: 'FooBar'
      slug: 'prefix-foobar-subdocumentfoobarz-suffix'
      tags: [
        'tag-0-prefix-foobar-subdocumentfoobarz-suffix'
        'tag-1-prefix-foobar-nestedfoobarz-suffix'
        'tag-2-prefix-foobar-nestedfoobar-suffix'
        'tag-3-prefix-foobar-nestedfoobara-suffix'
        'tag-4-prefix-foobar-nestedfoobar-suffix'
      ]

    Post.documents.update @postId,
      $set:
        body: 'FooBarZ'
    ,
      expect (error, res) =>
        test.isFalse error, error?.toString?() or error
        test.isTrue res

    # Wait so that observers have time to update documents
    waitForDatabase test, expect
,
  (test, expect) ->
    @person1 = Person.documents.findOne @person1Id,
      transform: null # So that we can use test.equal
    @person2 = Person.documents.findOne @person2Id,
      transform: null # So that we can use test.equal
    @person3 = Person.documents.findOne @person3Id,
      transform: null # So that we can use test.equal

    test.equal @person1,
      _id: @person1Id
      username: 'person1b'
      displayName: 'Person 1'
      field1: 'Field 1 - 1a'
      field2: 'Field 1 - 2a'
      posts: [
        _id: @postId
        subdocument:
          body: 'SubdocumentFooBarZ'
        nested: [
          body: 'NestedFooBarZ'
        ,
          body: 'NestedFooBar'
        ,
          {}
        ,
          body: null
        ,
          body: 'NestedFooBarA'
        ,
          body: 'NestedFooBar'
        ]
        body: 'FooBarZ'
      ]
      count: 1
    test.equal @person2,
      _id: @person2Id
      username: 'person2b'
      displayName: 'Person 2'
      field1: 'Field 2 - 1b'
      field2: 'Field 2 - 2b'
      subdocument:
        posts: [
          _id: @postId
          subdocument:
            body: 'SubdocumentFooBarZ'
          nested: [
            body: 'NestedFooBarZ'
          ,
            body: 'NestedFooBar'
          ,
            {}
          ,
            body: null
          ,
            body: 'NestedFooBarA'
          ,
            body: 'NestedFooBar'
          ]
          body: 'FooBarZ'
        ]
      subdocumentsPosts: [
        _id: @postId
        subdocument:
          body: 'SubdocumentFooBarZ'
        nested: [
          body: 'NestedFooBarZ'
        ,
          body: 'NestedFooBar'
        ,
          {}
        ,
          body: null
        ,
          body: 'NestedFooBarA'
        ,
          body: 'NestedFooBar'
        ]
        body: 'FooBarZ'
      ]
      nestedPosts: [
        _id: @postId
        subdocument:
          body: 'SubdocumentFooBarZ'
        nested: [
          body: 'NestedFooBarZ'
        ,
          body: 'NestedFooBar'
        ,
          {}
        ,
          body: null
        ,
          body: 'NestedFooBarA'
        ,
          body: 'NestedFooBar'
        ]
        body: 'FooBarZ'
      ]
      count: 3
    test.equal @person3,
      _id: @person3Id
      username: 'person3b'
      displayName: 'Person 3'
      field1: 'Field 3 - 1'
      field2: 'Field 3 - 2'
      subdocumentsPosts: [
        _id: @postId
        subdocument:
          body: 'SubdocumentFooBarZ'
        nested: [
          body: 'NestedFooBarZ'
        ,
          body: 'NestedFooBar'
        ,
          {}
        ,
          body: null
        ,
          body: 'NestedFooBarA'
        ,
          body: 'NestedFooBar'
        ]
        body: 'FooBarZ'
      ]
      nestedPosts: [
        _id: @postId
        subdocument:
          body: 'SubdocumentFooBarZ'
        nested: [
          body: 'NestedFooBarZ'
        ,
          body: 'NestedFooBar'
        ,
          {}
        ,
          body: null
        ,
          body: 'NestedFooBarA'
        ,
          body: 'NestedFooBar'
        ]
        body: 'FooBarZ'
      ]
      count: 2

    @post = Post.documents.findOne @postId,
      transform: null # So that we can use test.equal

    test.equal @post,
      _id: @postId
      author:
        _id: @person1._id
        username: @person1.username
        displayName: @person1.displayName
        field1: @person1.field1
        field2: @person1.field2
      subscribers: [
        _id: @person2._id
      ,
        _id: @person2._id
      ,
        _id: @person3._id
      ]
      reviewers: [
        _id: @person2._id
        username: @person2.username
      ,
        _id: @person3._id
        username: @person3.username
      ,
        _id: @person3._id
        username: @person3.username
      ]
      subdocument:
        person:
          _id: @person2._id
          username: @person2.username
          displayName: @person2.displayName
          field1: @person2.field1
          field2: @person2.field2
        persons: [
          _id: @person2._id
          username: @person2.username
          displayName: @person2.displayName
          field1: @person2.field1
          field2: @person2.field2
        ,
          _id: @person2._id
          username: @person2.username
          displayName: @person2.displayName
          field1: @person2.field1
          field2: @person2.field2
        ,
          _id: @person3._id
          username: @person3.username
          displayName: @person3.displayName
          field1: @person3.field1
          field2: @person3.field2
        ,
          _id: @person3._id
          username: @person3.username
          displayName: @person3.displayName
          field1: @person3.field1
          field2: @person3.field2
        ]
        slug: 'subdocument-prefix-foobarz-subdocumentfoobarz-suffix'
        body: 'SubdocumentFooBarZ'
      nested: [
        required:
          _id: @person2._id
          username: @person2.username
          displayName: @person2.displayName
          field1: @person2.field1
          field2: @person2.field2
        optional:
          _id: @person3._id
          username: @person3.username
        slug: 'nested-prefix-foobarz-nestedfoobarz-suffix'
        body: 'NestedFooBarZ'
      ,
        required:
          _id: @person2._id
          username: @person2.username
          displayName: @person2.displayName
          field1: @person2.field1
          field2: @person2.field2
        optional:
          _id: @person3._id
          username: @person3.username
        slug: 'nested-prefix-foobarz-nestedfoobar-suffix'
        body: 'NestedFooBar'
      ,
        required:
          _id: @person3._id
          username: @person3.username
          displayName: @person3.displayName
          field1: @person3.field1
          field2: @person3.field2
        optional:
          _id: @person2._id
          username: @person2.username
      ,
        required:
          _id: @person3._id
          username: @person3.username
          displayName: @person3.displayName
          field1: @person3.field1
          field2: @person3.field2
        optional:
          _id: @person2._id
          username: @person2.username
        slug: null
        body: null
      ,
        required:
          _id: @person2._id
          username: @person2.username
          displayName: @person2.displayName
          field1: @person2.field1
          field2: @person2.field2
        optional:
          _id: @person2._id
          username: @person2.username
        slug: 'nested-prefix-foobarz-nestedfoobara-suffix'
        body: 'NestedFooBarA'
      ,
        required:
          _id: @person3._id
          username: @person3.username
          displayName: @person3.displayName
          field1: @person3.field1
          field2: @person3.field2
        optional:
          _id: @person3._id
          username: @person3.username
        slug: 'nested-prefix-foobarz-nestedfoobar-suffix'
        body: 'NestedFooBar'
      ]
      body: 'FooBarZ'
      slug: 'prefix-foobarz-subdocumentfoobarz-suffix'
      tags: [
        'tag-0-prefix-foobarz-subdocumentfoobarz-suffix'
        'tag-1-prefix-foobarz-nestedfoobarz-suffix'
        'tag-2-prefix-foobarz-nestedfoobar-suffix'
        'tag-3-prefix-foobarz-nestedfoobara-suffix'
        'tag-4-prefix-foobarz-nestedfoobar-suffix'
      ]

    Post.documents.update @postId,
      $push:
        nested:
          required:
            _id: @person2._id
          optional:
            _id: @person3._id
          body: 'NewFooBar'
    ,
      expect (error, res) =>
        test.isFalse error, error?.toString?() or error
        test.isTrue res

    # Wait so that observers have time to update documents
    waitForDatabase test, expect
,
  (test, expect) ->
    @person1 = Person.documents.findOne @person1Id,
      transform: null # So that we can use test.equal
    @person2 = Person.documents.findOne @person2Id,
      transform: null # So that we can use test.equal
    @person3 = Person.documents.findOne @person3Id,
      transform: null # So that we can use test.equal

    test.equal @person1,
      _id: @person1Id
      username: 'person1b'
      displayName: 'Person 1'
      field1: 'Field 1 - 1a'
      field2: 'Field 1 - 2a'
      posts: [
        _id: @postId
        subdocument:
          body: 'SubdocumentFooBarZ'
        nested: [
          body: 'NestedFooBarZ'
        ,
          body: 'NestedFooBar'
        ,
          {}
        ,
          body: null
        ,
          body: 'NestedFooBarA'
        ,
          body: 'NestedFooBar'
        ,
          body: 'NewFooBar'
        ]
        body: 'FooBarZ'
      ]
      count: 1
    test.equal @person2,
      _id: @person2Id
      username: 'person2b'
      displayName: 'Person 2'
      field1: 'Field 2 - 1b'
      field2: 'Field 2 - 2b'
      subdocument:
        posts: [
          _id: @postId
          subdocument:
            body: 'SubdocumentFooBarZ'
          nested: [
            body: 'NestedFooBarZ'
          ,
            body: 'NestedFooBar'
          ,
            {}
          ,
            body: null
          ,
            body: 'NestedFooBarA'
          ,
            body: 'NestedFooBar'
          ,
            body: 'NewFooBar'
          ]
          body: 'FooBarZ'
        ]
      subdocumentsPosts: [
        _id: @postId
        subdocument:
          body: 'SubdocumentFooBarZ'
        nested: [
          body: 'NestedFooBarZ'
        ,
          body: 'NestedFooBar'
        ,
          {}
        ,
          body: null
        ,
          body: 'NestedFooBarA'
        ,
          body: 'NestedFooBar'
        ,
          body: 'NewFooBar'
        ]
        body: 'FooBarZ'
      ]
      nestedPosts: [
        _id: @postId
        subdocument:
          body: 'SubdocumentFooBarZ'
        nested: [
          body: 'NestedFooBarZ'
        ,
          body: 'NestedFooBar'
        ,
          {}
        ,
          body: null
        ,
          body: 'NestedFooBarA'
        ,
          body: 'NestedFooBar'
        ,
          body: 'NewFooBar'
        ]
        body: 'FooBarZ'
      ]
      count: 3
    test.equal @person3,
      _id: @person3Id
      username: 'person3b'
      displayName: 'Person 3'
      field1: 'Field 3 - 1'
      field2: 'Field 3 - 2'
      subdocumentsPosts: [
        _id: @postId
        subdocument:
          body: 'SubdocumentFooBarZ'
        nested: [
          body: 'NestedFooBarZ'
        ,
          body: 'NestedFooBar'
        ,
          {}
        ,
          body: null
        ,
          body: 'NestedFooBarA'
        ,
          body: 'NestedFooBar'
        ,
          body: 'NewFooBar'
        ]
        body: 'FooBarZ'
      ]
      nestedPosts: [
        _id: @postId
        subdocument:
          body: 'SubdocumentFooBarZ'
        nested: [
          body: 'NestedFooBarZ'
        ,
          body: 'NestedFooBar'
        ,
          {}
        ,
          body: null
        ,
          body: 'NestedFooBarA'
        ,
          body: 'NestedFooBar'
        ,
          body: 'NewFooBar'
        ]
        body: 'FooBarZ'
      ]
      count: 2

    @post = Post.documents.findOne @postId,
      transform: null # So that we can use test.equal

    test.equal @post,
      _id: @postId
      author:
        _id: @person1._id
        username: @person1.username
        displayName: @person1.displayName
        field1: @person1.field1
        field2: @person1.field2
      subscribers: [
        _id: @person2._id
      ,
        _id: @person2._id
      ,
        _id: @person3._id
      ]
      reviewers: [
        _id: @person2._id
        username: @person2.username
      ,
        _id: @person3._id
        username: @person3.username
      ,
        _id: @person3._id
        username: @person3.username
      ]
      subdocument:
        person:
          _id: @person2._id
          username: @person2.username
          displayName: @person2.displayName
          field1: @person2.field1
          field2: @person2.field2
        persons: [
          _id: @person2._id
          username: @person2.username
          displayName: @person2.displayName
          field1: @person2.field1
          field2: @person2.field2
        ,
          _id: @person2._id
          username: @person2.username
          displayName: @person2.displayName
          field1: @person2.field1
          field2: @person2.field2
        ,
          _id: @person3._id
          username: @person3.username
          displayName: @person3.displayName
          field1: @person3.field1
          field2: @person3.field2
        ,
          _id: @person3._id
          username: @person3.username
          displayName: @person3.displayName
          field1: @person3.field1
          field2: @person3.field2
        ]
        slug: 'subdocument-prefix-foobarz-subdocumentfoobarz-suffix'
        body: 'SubdocumentFooBarZ'
      nested: [
        required:
          _id: @person2._id
          username: @person2.username
          displayName: @person2.displayName
          field1: @person2.field1
          field2: @person2.field2
        optional:
          _id: @person3._id
          username: @person3.username
        slug: 'nested-prefix-foobarz-nestedfoobarz-suffix'
        body: 'NestedFooBarZ'
      ,
        required:
          _id: @person2._id
          username: @person2.username
          displayName: @person2.displayName
          field1: @person2.field1
          field2: @person2.field2
        optional:
          _id: @person3._id
          username: @person3.username
        slug: 'nested-prefix-foobarz-nestedfoobar-suffix'
        body: 'NestedFooBar'
      ,
        required:
          _id: @person3._id
          username: @person3.username
          displayName: @person3.displayName
          field1: @person3.field1
          field2: @person3.field2
        optional:
          _id: @person2._id
          username: @person2.username
      ,
        required:
          _id: @person3._id
          username: @person3.username
          displayName: @person3.displayName
          field1: @person3.field1
          field2: @person3.field2
        optional:
          _id: @person2._id
          username: @person2.username
        slug: null
        body: null
      ,
        required:
          _id: @person2._id
          username: @person2.username
          displayName: @person2.displayName
          field1: @person2.field1
          field2: @person2.field2
        optional:
          _id: @person2._id
          username: @person2.username
        slug: 'nested-prefix-foobarz-nestedfoobara-suffix'
        body: 'NestedFooBarA'
      ,
        required:
          _id: @person3._id
          username: @person3.username
          displayName: @person3.displayName
          field1: @person3.field1
          field2: @person3.field2
        optional:
          _id: @person3._id
          username: @person3.username
        slug: 'nested-prefix-foobarz-nestedfoobar-suffix'
        body: 'NestedFooBar'
      ,
        required:
          _id: @person2._id
          username: @person2.username
          displayName: @person2.displayName
          field1: @person2.field1
          field2: @person2.field2
        optional:
          _id: @person3._id
          username: @person3.username
        slug: 'nested-prefix-foobarz-newfoobar-suffix'
        body: 'NewFooBar'
      ]
      body: 'FooBarZ'
      slug: 'prefix-foobarz-subdocumentfoobarz-suffix'
      tags: [
        'tag-0-prefix-foobarz-subdocumentfoobarz-suffix'
        'tag-1-prefix-foobarz-nestedfoobarz-suffix'
        'tag-2-prefix-foobarz-nestedfoobar-suffix'
        'tag-3-prefix-foobarz-nestedfoobara-suffix'
        'tag-4-prefix-foobarz-nestedfoobar-suffix'
        'tag-5-prefix-foobarz-newfoobar-suffix'
      ]

    Person.documents.remove @person2Id,
      expect (error) =>
        test.isFalse error, error?.toString?() or error

    # Wait so that observers have time to update documents
    waitForDatabase test, expect
,
  (test, expect) ->
    @person1 = Person.documents.findOne @person1Id,
      transform: null # So that we can use test.equal
    @person3 = Person.documents.findOne @person3Id,
      transform: null # So that we can use test.equal

    test.equal @person1,
      _id: @person1Id
      username: 'person1b'
      displayName: 'Person 1'
      field1: 'Field 1 - 1a'
      field2: 'Field 1 - 2a'
      posts: [
        _id: @postId
        subdocument:
          body: 'SubdocumentFooBarZ'
        nested: [
          {}
        ,
          body: null
        ,
          body: 'NestedFooBar'
        ]
        body: 'FooBarZ'
      ]
      count: 1
    test.equal @person3,
      _id: @person3Id
      username: 'person3b'
      displayName: 'Person 3'
      field1: 'Field 3 - 1'
      field2: 'Field 3 - 2'
      subdocumentsPosts: [
        _id: @postId
        subdocument:
          body: 'SubdocumentFooBarZ'
        nested: [
          {}
        ,
          body: null
        ,
          body: 'NestedFooBar'
        ]
        body: 'FooBarZ'
      ]
      nestedPosts: [
        _id: @postId
        subdocument:
          body: 'SubdocumentFooBarZ'
        nested: [
          {}
        ,
          body: null
        ,
          body: 'NestedFooBar'
        ]
        body: 'FooBarZ'
      ]
      count: 2

    @post = Post.documents.findOne @postId,
      transform: null # So that we can use test.equal

    test.equal @post,
      _id: @postId
      author:
        _id: @person1._id
        username: @person1.username
        displayName: @person1.displayName
        field1: @person1.field1
        field2: @person1.field2
      subscribers: [
        _id: @person3._id
      ]
      reviewers: [
        _id: @person3._id
        username: @person3.username
      ,
        _id: @person3._id
        username: @person3.username
      ]
      subdocument:
        person: null
        persons: [
          _id: @person3._id
          username: @person3.username
          displayName: @person3.displayName
          field1: @person3.field1
          field2: @person3.field2
        ,
          _id: @person3._id
          username: @person3.username
          displayName: @person3.displayName
          field1: @person3.field1
          field2: @person3.field2
        ]
        slug: 'subdocument-prefix-foobarz-subdocumentfoobarz-suffix'
        body: 'SubdocumentFooBarZ'
      nested: [
        required:
          _id: @person3._id
          username: @person3.username
          displayName: @person3.displayName
          field1: @person3.field1
          field2: @person3.field2
        optional: null
      ,
        required:
          _id: @person3._id
          username: @person3.username
          displayName: @person3.displayName
          field1: @person3.field1
          field2: @person3.field2
        optional: null
        slug: null
        body: null
      ,
        required:
          _id: @person3._id
          username: @person3.username
          displayName: @person3.displayName
          field1: @person3.field1
          field2: @person3.field2
        optional:
          _id: @person3._id
          username: @person3.username
        slug: 'nested-prefix-foobarz-nestedfoobar-suffix'
        body: 'NestedFooBar'
      ]
      body: 'FooBarZ'
      slug: 'prefix-foobarz-subdocumentfoobarz-suffix'
      tags: [
        'tag-0-prefix-foobarz-subdocumentfoobarz-suffix'
        'tag-1-prefix-foobarz-nestedfoobar-suffix'
      ]

    Person.documents.remove @person3Id,
      expect (error) =>
        test.isFalse error, error?.toString?() or error

    # Wait so that observers have time to update documents
    waitForDatabase test, expect
,
  (test, expect) ->
    @person1 = Person.documents.findOne @person1Id,
      transform: null # So that we can use test.equal

    test.equal @person1,
      _id: @person1Id
      username: 'person1b'
      displayName: 'Person 1'
      field1: 'Field 1 - 1a'
      field2: 'Field 1 - 2a'
      posts: [
        _id: @postId
        subdocument:
          body: 'SubdocumentFooBarZ'
        nested: []
        body: 'FooBarZ'
      ]
      count: 1

    @post = Post.documents.findOne @postId,
      transform: null # So that we can use test.equal

    test.equal @post,
      _id: @postId
      author:
        _id: @person1._id
        username: @person1.username
        displayName: @person1.displayName
        field1: @person1.field1
        field2: @person1.field2
      subscribers: []
      reviewers: []
      subdocument:
        person: null
        persons: []
        slug: 'subdocument-prefix-foobarz-subdocumentfoobarz-suffix'
        body: 'SubdocumentFooBarZ'
      nested: []
      body: 'FooBarZ'
      slug: 'prefix-foobarz-subdocumentfoobarz-suffix'
      tags: [
        'tag-0-prefix-foobarz-subdocumentfoobarz-suffix'
      ]

    Person.documents.remove @person1Id,
      expect (error) =>
        test.isFalse error, error?.toString?() or error

    # Wait so that observers have time to update documents
    waitForDatabase test, expect
,
  (test, expect) ->
    @post = Post.documents.findOne @postId,
      transform: null # So that we can use test.equal

    test.isFalse @post, @post
]

if Meteor.isServer and Document.instances is 1
  testAsyncMulti 'peerdb - exception while processing', [
    (test, expect) ->
      Log._intercept 3

      IdentityGenerator.documents.insert
        source: 'exception'
      ,
        expect (error, identityGeneratorId) =>
          test.isFalse error, error?.toString?() or error
          test.isTrue identityGeneratorId
          @identityGeneratorId = identityGeneratorId

      # Wait so that observers have time to update documents
      waitForDatabase test, expect
  ,
    (test, expect) ->
      intercepted = Log._intercepted()

      test.isTrue intercepted.length is 3, intercepted

      # We are testing only the server one, so let's find it
      for i in intercepted
        # First error message
        if i.indexOf('PeerDB exception: Error: Test exception') isnt -1
          i = EJSON.parse i
          test.equal i.message, "PeerDB exception: Error: Test exception: [ { source: 'exception', _id: '#{ @identityGeneratorId }' } ]"
          test.equal i.level, 'error'
        # Stack trace error message
        else if i.indexOf('Error: Test exception') isnt -1
          i = EJSON.parse i
          test.isTrue i.message.indexOf('_GeneratedField.generator') isnt -1, i.message
          test.equal i.level, 'error'
        # Invalid update error message
        else if i.indexOf('defined as an array with selector') isnt -1
          i = EJSON.parse i
          test.equal i.message, "Generated field 'results' defined as an array with selector '#{ @identityGeneratorId }' was updated with a non-array value: 'exception'"
          test.equal i.level, 'error'
        else
          test.fail
            type: 'assert_never'
            message: i
  ]

testAsyncMulti 'peerdb - instances', [
  (test, expect) ->
    testDefinition test

    Person.documents.insert
      username: 'person1'
      displayName: 'Person 1'
    ,
      expect (error, person1Id) =>
        test.isFalse error, error?.toString?() or error
        test.isTrue person1Id
        @person1Id = person1Id

    Person.documents.insert
      username: 'person2'
      displayName: 'Person 2'
    ,
      expect (error, person2Id) =>
        test.isFalse error, error?.toString?() or error
        test.isTrue person2Id
        @person2Id = person2Id

    Person.documents.insert
      username: 'person3'
      displayName: 'Person 3'
    ,
      expect (error, person3Id) =>
        test.isFalse error, error?.toString?() or error
        test.isTrue person3Id
        @person3Id = person3Id

    # Wait so that observers have time to update documents
    waitForDatabase test, expect
,
  (test, expect) ->
    @person1 = Person.documents.findOne @person1Id
    @person2 = Person.documents.findOne @person2Id
    @person3 = Person.documents.findOne @person3Id

    test.instanceOf @person1, Person
    test.instanceOf @person2, Person
    test.instanceOf @person3, Person

    test.equal plainObject(@person1),
      _id: @person1Id
      username: 'person1'
      displayName: 'Person 1'
      count: 0
    test.equal plainObject(@person2),
      _id: @person2Id
      username: 'person2'
      displayName: 'Person 2'
      count: 0
    test.equal plainObject(@person3),
      _id: @person3Id
      username: 'person3'
      displayName: 'Person 3'
      count: 0

    test.equal @person1.formatName(), 'person1-Person 1'
    test.equal @person2.formatName(), 'person2-Person 2'
    test.equal @person3.formatName(), 'person3-Person 3'

    Post.documents.insert
      author:
        _id: @person1._id
      subscribers: [
        _id: @person2._id
      ,
        _id: @person3._id
      ]
      reviewers: [
        _id: @person2._id
      ,
        _id: @person3._id
      ]
      subdocument:
        person:
          _id: @person2._id
        persons: [
          _id: @person2._id
        ,
          _id: @person3._id
        ]
        body: 'SubdocumentFooBar'
      nested: [
        required:
          _id: @person2._id
        optional:
          _id: @person3._id
        body: 'NestedFooBar'
      ]
      body: 'FooBar'
    ,
      expect (error, postId) =>
        test.isFalse error, error?.toString?() or error
        test.isTrue postId
        @postId = postId

    # Wait so that observers have time to update documents
    waitForDatabase test, expect
,
  (test, expect) ->
    @post = Post.documents.findOne @postId

    test.instanceOf @post, Post
    test.instanceOf @post.author, Person
    test.instanceOf @post.subscribers[0], Person
    test.instanceOf @post.subscribers[1], Person
    test.instanceOf @post.reviewers[0], Person
    test.instanceOf @post.reviewers[1], Person
    test.instanceOf @post.subdocument.person, Person
    test.instanceOf @post.subdocument.persons[0], Person
    test.instanceOf @post.subdocument.persons[1], Person
    test.instanceOf @post.nested[0].required, Person
    test.instanceOf @post.nested[0].optional, Person

    test.equal @post.author.formatName(), "#{ @person1.username }-#{ @person1.displayName }"

    test.equal plainObject(@post),
      _id: @postId
      author:
        _id: @person1._id
        username: @person1.username
        displayName: @person1.displayName
      # subscribers have only ids
      subscribers: [
        _id: @person2._id
      ,
        _id: @person3._id
      ]
      # But reviewers have usernames as well
      reviewers: [
        _id: @person2._id
        username: @person2.username
      ,
        _id: @person3._id
        username: @person3.username
      ]
      subdocument:
        person:
          _id: @person2._id
          username: @person2.username
          displayName: @person2.displayName
        persons: [
          _id: @person2._id
          username: @person2.username
          displayName: @person2.displayName
        ,
          _id: @person3._id
          username: @person3.username
          displayName: @person3.displayName
        ]
        slug: 'subdocument-prefix-foobar-subdocumentfoobar-suffix'
        body: 'SubdocumentFooBar'
      nested: [
        required:
          _id: @person2._id
          username: @person2.username
          displayName: @person2.displayName
        optional:
          _id: @person3._id
          username: @person3.username
        slug: 'nested-prefix-foobar-nestedfoobar-suffix'
        body: 'NestedFooBar'
      ]
      body: 'FooBar'
      slug: 'prefix-foobar-subdocumentfoobar-suffix'
      tags: [
        'tag-0-prefix-foobar-subdocumentfoobar-suffix'
        'tag-1-prefix-foobar-nestedfoobar-suffix'
      ]

    SpecialPost.documents.insert
      author:
        _id: @person1._id
      subscribers: [
        _id: @person2._id
      ,
        _id: @person3._id
      ]
      reviewers: [
        _id: @person2._id
      ,
        _id: @person3._id
      ]
      subdocument:
        person:
          _id: @person2._id
        persons: [
          _id: @person2._id
        ,
          _id: @person3._id
        ]
        body: 'SubdocumentFooBar'
      nested: [
        required:
          _id: @person2._id
        optional:
          _id: @person3._id
        body: 'NestedFooBar'
      ]
      body: 'FooBar'
      special:
        _id: @person1._id
    ,
      expect (error, postId) =>
        test.isFalse error, error?.toString?() or error
        test.isTrue postId
        @postId = postId

    # Wait so that observers have time to update documents
    waitForDatabase test, expect
,
  (test, expect) ->
    @post = SpecialPost.documents.findOne @postId

    test.instanceOf @post, SpecialPost
    test.instanceOf @post.author, Person
    test.instanceOf @post.subscribers[0], Person
    test.instanceOf @post.subscribers[1], Person
    test.instanceOf @post.reviewers[0], Person
    test.instanceOf @post.reviewers[1], Person
    test.instanceOf @post.subdocument.person, Person
    test.instanceOf @post.subdocument.persons[0], Person
    test.instanceOf @post.subdocument.persons[1], Person
    test.instanceOf @post.nested[0].required, Person
    test.instanceOf @post.nested[0].optional, Person
    test.instanceOf @post.special, Person

    test.equal @post.author.formatName(), "#{ @person1.username }-#{ @person1.displayName }"

    test.equal plainObject(@post),
      _id: @postId
      author:
        _id: @person1._id
        username: @person1.username
        displayName: @person1.displayName
      # subscribers have only ids
      subscribers: [
        _id: @person2._id
      ,
        _id: @person3._id
      ]
      # But reviewers have usernames as well
      reviewers: [
        _id: @person2._id
        username: @person2.username
      ,
        _id: @person3._id
        username: @person3.username
      ]
      subdocument:
        person:
          _id: @person2._id
          username: @person2.username
          displayName: @person2.displayName
        persons: [
          _id: @person2._id
          username: @person2.username
          displayName: @person2.displayName
        ,
          _id: @person3._id
          username: @person3.username
          displayName: @person3.displayName
        ]
        slug: 'subdocument-prefix-foobar-subdocumentfoobar-suffix'
        body: 'SubdocumentFooBar'
      nested: [
        required:
          _id: @person2._id
          username: @person2.username
          displayName: @person2.displayName
        optional:
          _id: @person3._id
          username: @person3.username
        slug: 'nested-prefix-foobar-nestedfoobar-suffix'
        body: 'NestedFooBar'
      ]
      body: 'FooBar'
      slug: 'prefix-foobar-subdocumentfoobar-suffix'
      tags: [
        'tag-0-prefix-foobar-subdocumentfoobar-suffix'
        'tag-1-prefix-foobar-nestedfoobar-suffix'
      ]
      special:
        _id: @person1._id

    @username = Random.id()

    if Meteor.isServer
      @userId = Accounts.createUser
        username: @username
        password: 'test'
    else
      Accounts.createUser
        username: @username
        password: 'test'
      ,
        expect (error) =>
          test.isFalse error, error?.toString?() or error
          @userId = Meteor.userId() unless error
,
  (test, expect) ->
    @user = User.documents.findOne @userId

    test.instanceOf @user, User
    test.equal @user.username, @username
]

Tinytest.add 'peerdb - bad instances', (test) ->
  # Empty document should be always possible to create
  for document in Document.list
    test.isTrue new document

  # Something simple
  test.isTrue new Post
    author:
      _id: Random.id()
      username: 'Foobar'

  test.throws ->
    new Post
      author: [
        _id: Random.id()
        username: 'Foobar'
      ]
  , /Document does not match schema, not a plain object/

  test.throws ->
    new Post
      subscribers: [
        Random.id()
      ]
  , /Document does not match schema, not a plain object/

  test.throws ->
    new Post
      subdocument: []
  , /Document does not match schema, an unexpected array/

  test.throws ->
    new Post
      subdocument: [
        persons: []
      ]
  , /Document does not match schema, an unexpected array/

  test.throws ->
    new Post
      subdocument: [[
        persons: []
      ]]
  , /Document does not match schema, an unexpected array/

  test.throws ->
    new Post
      subdocument:
        persons: [
          Random.id()
        ]
  , /Document does not match schema, not a plain object/

  test.throws ->
    new Post
      nested:
        _id: Random.id()
  , /Document does not match schema, expected an array/

  test.throws ->
    new Post
      nested: [
        required: Random.id()
      ]
  , /Document does not match schema, not a plain object/

  test.throws ->
    new Post
      nested:
        required: [
          _id: Random.id()
        ]
  , /Document does not match schema, expected an array/

  test.throws ->
    new Post
      nested:
        required:
          _id: Random.id()
  , /Document does not match schema, expected an array/

  test.throws ->
    new Post
      nested: [
        required: [
          _id: Random.id()
        ]
      ]
  , /Document does not match schema, not a plain object/

if Meteor.isServer and not Document.instanceDisabled
  testAsyncMulti 'peerdb - update all', [
    (test, expect) ->
      testDefinition test

      Person.documents.insert
        username: 'person1'
        displayName: 'Person 1'
      ,
        expect (error, person1Id) =>
          test.isFalse error, error?.toString?() or error
          test.isTrue person1Id
          @person1Id = person1Id

      Person.documents.insert
        username: 'person2'
        displayName: 'Person 2'
      ,
        expect (error, person2Id) =>
          test.isFalse error, error?.toString?() or error
          test.isTrue person2Id
          @person2Id = person2Id

      Person.documents.insert
        username: 'person3'
        displayName: 'Person 3'
      ,
        expect (error, person3Id) =>
          test.isFalse error, error?.toString?() or error
          test.isTrue person3Id
          @person3Id = person3Id

      # Wait so that observers have time to update documents
      waitForDatabase test, expect
  ,
    (test, expect) ->
      @person1 = Person.documents.findOne @person1Id
      @person2 = Person.documents.findOne @person2Id
      @person3 = Person.documents.findOne @person3Id

      Post.documents.insert
        author:
          _id: @person1._id
          # To test what happens if one field is already up to date, but the other is not
          username: @person1.username
          displayName: 'wrong'
        subscribers: [
          _id: @person2._id
        ,
          _id: @person3._id
        ]
        reviewers: [
          _id: @person2._id
        ,
          _id: @person3._id
        ]
        subdocument:
          person:
            _id: @person2._id
          persons: [
            _id: @person2._id
          ,
            _id: @person3._id
          ]
          body: 'SubdocumentFooBar'
        nested: [
          required:
            _id: @person2._id
          optional:
            _id: @person3._id
          body: 'NestedFooBar'
        ]
        body: 'FooBar'
      ,
        expect (error, postId) =>
          test.isFalse error, error?.toString?() or error
          test.isTrue postId
          @postId = postId

      # Wait so that observers have time to update documents
      waitForDatabase test, expect
  ,
    (test, expect) ->
      @post = Post.documents.findOne @postId,
        transform: null # So that we can use test.equal

      test.equal @post,
        _id: @postId
        author:
          _id: @person1._id
          username: @person1.username
          displayName: @person1.displayName
        # subscribers have only ids
        subscribers: [
          _id: @person2._id
        ,
          _id: @person3._id
        ]
        # But reviewers have usernames as well
        reviewers: [
          _id: @person2._id
          username: @person2.username
        ,
          _id: @person3._id
          username: @person3.username
        ]
        subdocument:
          person:
            _id: @person2._id
            username: @person2.username
            displayName: @person2.displayName
          persons: [
            _id: @person2._id
            username: @person2.username
            displayName: @person2.displayName
          ,
            _id: @person3._id
            username: @person3.username
            displayName: @person3.displayName
          ]
          slug: 'subdocument-prefix-foobar-subdocumentfoobar-suffix'
          body: 'SubdocumentFooBar'
        nested: [
          required:
            _id: @person2._id
            username: @person2.username
            displayName: @person2.displayName
          optional:
            _id: @person3._id
            username: @person3.username
          slug: 'nested-prefix-foobar-nestedfoobar-suffix'
          body: 'NestedFooBar'
        ]
        body: 'FooBar'
        slug: 'prefix-foobar-subdocumentfoobar-suffix'
        tags: [
          'tag-0-prefix-foobar-subdocumentfoobar-suffix'
          'tag-1-prefix-foobar-nestedfoobar-suffix'
        ]

      Post.documents.update @postId,
        $set:
          'author.username': 'wrong'
          'reviewers.0.username': 'wrong'
          'reviewers.1.username': 'wrong'
          'subdocument.person.username': 'wrong'
          'subdocument.persons.0.username': 'wrong'
          'subdocument.persons.1.username': 'wrong'
          'nested.0.required.username': 'wrong'
          'nested.0.optional.username': 'wrong'
          slug: 'wrong'
          tags: 'wrong'
      ,
        expect (error, res) =>
          test.isFalse error, error?.toString?() or error
          test.isTrue res

      # Wait so that observers have time to update documents
      waitForDatabase test, expect
  ,
    (test, expect) ->
      @post = Post.documents.findOne @postId,
        transform: null # So that we can use test.equal

      # Reference fields are automatically updated back, but generated fields are not
      test.equal @post,
        _id: @postId
        author:
          _id: @person1._id
          username: @person1.username
          displayName: @person1.displayName
        # subscribers have only ids
        subscribers: [
          _id: @person2._id
        ,
          _id: @person3._id
        ]
        # But reviewers have usernames as well
        reviewers: [
          _id: @person2._id
          username: @person2.username
        ,
          _id: @person3._id
          username: @person3.username
        ]
        subdocument:
          person:
            _id: @person2._id
            username: @person2.username
            displayName: @person2.displayName
          persons: [
            _id: @person2._id
            username: @person2.username
            displayName: @person2.displayName
          ,
            _id: @person3._id
            username: @person3.username
            displayName: @person3.displayName
          ]
          slug: 'subdocument-prefix-foobar-subdocumentfoobar-suffix'
          body: 'SubdocumentFooBar'
        nested: [
          required:
            _id: @person2._id
            username: @person2.username
            displayName: @person2.displayName
          optional:
            _id: @person3._id
            username: @person3.username
          slug: 'nested-prefix-foobar-nestedfoobar-suffix'
          body: 'NestedFooBar'
        ]
        body: 'FooBar'
        slug: 'wrong'
        tags: 'wrong'

      # Update all fields back (a blocking operation)
      Document.updateAll()

      # Wait so that triggered observers have time to update documents
      waitForDatabase test, expect
  ,
    (test, expect) ->
      @post = Post.documents.findOne @postId,
        transform: null # So that we can use test.equal

      test.equal @post,
        _id: @postId
        author:
          _id: @person1._id
          username: @person1.username
          displayName: @person1.displayName
        # subscribers have only ids
        subscribers: [
          _id: @person2._id
        ,
          _id: @person3._id
        ]
        # But reviewers have usernames as well
        reviewers: [
          _id: @person2._id
          username: @person2.username
        ,
          _id: @person3._id
          username: @person3.username
        ]
        subdocument:
          person:
            _id: @person2._id
            username: @person2.username
            displayName: @person2.displayName
          persons: [
            _id: @person2._id
            username: @person2.username
            displayName: @person2.displayName
          ,
            _id: @person3._id
            username: @person3.username
            displayName: @person3.displayName
          ]
          slug: 'subdocument-prefix-foobar-subdocumentfoobar-suffix'
          body: 'SubdocumentFooBar'
        nested: [
          required:
            _id: @person2._id
            username: @person2.username
            displayName: @person2.displayName
          optional:
            _id: @person3._id
            username: @person3.username
          slug: 'nested-prefix-foobar-nestedfoobar-suffix'
          body: 'NestedFooBar'
        ]
        body: 'FooBar'
        slug: 'prefix-foobar-subdocumentfoobar-suffix'
        tags: [
          'tag-0-prefix-foobar-subdocumentfoobar-suffix'
          'tag-1-prefix-foobar-nestedfoobar-suffix'
        ]
  ]

testAsyncMulti 'peerdb - reverse posts', [
  (test, expect) ->
    Person.documents.insert
      username: 'person1'
      displayName: 'Person 1'
    ,
      expect (error, person1Id) =>
        test.isFalse error, error?.toString?() or error
        test.isTrue person1Id
        @person1Id = person1Id

    Person.documents.insert
      username: 'person2'
      displayName: 'Person 2'
    ,
      expect (error, person2Id) =>
        test.isFalse error, error?.toString?() or error
        test.isTrue person2Id
        @person2Id = person2Id

    Person.documents.insert
      username: 'person3'
      displayName: 'Person 3'
    ,
      expect (error, person3Id) =>
        test.isFalse error, error?.toString?() or error
        test.isTrue person3Id
        @person3Id = person3Id

    # Wait so that observers have time to update documents
    waitForDatabase test, expect
,
  (test, expect) ->
    Post.documents.insert
      author:
        _id: @person1Id
      nested: [
        required:
          _id: @person2Id
        body: 'NestedFooBar1'
      ]
      subdocument:
        person:
          _id: @person1Id
        persons: [
          _id: @person1Id
        ,
          _id: @person2Id
        ,
          _id: @person3Id
        ,
          _id: @person1Id
        ,
          _id: @person2Id
        ,
          _id: @person3Id
        ]
        body: 'SubdocumentFooBar1'
      body: 'FooBar1'
    ,
      expect (error, postId) =>
        test.isFalse error, error?.toString?() or error
        test.isTrue postId
        @postId1 = postId

    Post.documents.insert
      author:
        _id: @person1Id
      nested: [
        required:
          _id: @person3Id
        body: 'NestedFooBar2'
      ]
      subdocument:
        person:
          _id: @person2Id
        persons: [
          _id: @person2Id
        ,
          _id: @person2Id
        ,
          _id: @person2Id
        ,
          _id: @person1Id
        ,
          _id: @person2Id
        ,
          _id: @person3Id
        ]
        body: 'SubdocumentFooBar2'
      body: 'FooBar2'
    ,
      expect (error, postId) =>
        test.isFalse error, error?.toString?() or error
        test.isTrue postId
        @postId2 = postId

    Post.documents.insert
      author:
        _id: @person1Id
      nested: [
        required:
          _id: @person3Id
        body: 'NestedFooBar3'
      ]
      subdocument:
        person:
          _id: @person1Id
        persons: [
          _id: @person1Id
        ,
          _id: @person1Id
        ,
          _id: @person1Id
        ,
          _id: @person1Id
        ,
          _id: @person2Id
        ,
          _id: @person3Id
        ]
        body: 'SubdocumentFooBar3'
      body: 'FooBar3'
    ,
      expect (error, postId) =>
        test.isFalse error, error?.toString?() or error
        test.isTrue postId
        @postId3 = postId

    # Wait so that observers have time to update documents
    waitForDatabase test, expect
,
  (test, expect) ->
    @post1 = Post.documents.findOne @postId1,
      transform: null # So that we can use test.equal
    @post2 = Post.documents.findOne @postId2,
      transform: null # So that we can use test.equal
    @post3 = Post.documents.findOne @postId3,
      transform: null # So that we can use test.equal

    test.equal @post1,
      _id: @postId1
      author:
        _id: @person1Id
        username: 'person1'
        displayName: 'Person 1'
      subdocument:
        person:
          _id: @person1Id
          displayName: 'Person 1'
          username: 'person1'
        persons: [
          _id: @person1Id
          displayName: 'Person 1'
          username: 'person1'
        ,
          _id: @person2Id
          displayName: 'Person 2'
          username: 'person2'
        ,
          _id: @person3Id
          displayName: 'Person 3'
          username: 'person3'
        ,
          _id: @person1Id
          displayName: 'Person 1'
          username: 'person1'
        ,
          _id: @person2Id
          displayName: 'Person 2'
          username: 'person2'
        ,
          _id: @person3Id
          displayName: 'Person 3'
          username: 'person3'
        ]
        slug: 'subdocument-prefix-foobar1-subdocumentfoobar1-suffix'
        body: 'SubdocumentFooBar1'
      nested: [
        required:
          _id: @person2Id
          username: 'person2'
          displayName: 'Person 2'
        slug: 'nested-prefix-foobar1-nestedfoobar1-suffix'
        body: 'NestedFooBar1'
      ]
      body: 'FooBar1'
      slug: 'prefix-foobar1-subdocumentfoobar1-suffix'
      tags: [
        'tag-0-prefix-foobar1-subdocumentfoobar1-suffix'
        'tag-1-prefix-foobar1-nestedfoobar1-suffix'
      ]

    test.equal @post2,
      _id: @postId2
      author:
        _id: @person1Id
        username: 'person1'
        displayName: 'Person 1'
      subdocument:
        person:
          _id: @person2Id
          displayName: 'Person 2'
          username: 'person2'
        persons: [
          _id: @person2Id
          displayName: 'Person 2'
          username: 'person2'
        ,
          _id: @person2Id
          displayName: 'Person 2'
          username: 'person2'
        ,
          _id: @person2Id
          displayName: 'Person 2'
          username: 'person2'
        ,
          _id: @person1Id
          displayName: 'Person 1'
          username: 'person1'
        ,
          _id: @person2Id
          displayName: 'Person 2'
          username: 'person2'
        ,
          _id: @person3Id
          displayName: 'Person 3'
          username: 'person3'
        ]
        slug: 'subdocument-prefix-foobar2-subdocumentfoobar2-suffix'
        body: 'SubdocumentFooBar2'
      nested: [
        required:
          _id: @person3Id
          username: 'person3'
          displayName: 'Person 3'
        slug: 'nested-prefix-foobar2-nestedfoobar2-suffix'
        body: 'NestedFooBar2'
      ]
      body: 'FooBar2'
      slug: 'prefix-foobar2-subdocumentfoobar2-suffix'
      tags: [
        'tag-0-prefix-foobar2-subdocumentfoobar2-suffix'
        'tag-1-prefix-foobar2-nestedfoobar2-suffix'
      ]

    test.equal @post3,
      _id: @postId3
      author:
        _id: @person1Id
        username: 'person1'
        displayName: 'Person 1'
      subdocument:
        person:
          _id: @person1Id
          displayName: 'Person 1'
          username: 'person1'
        persons: [
          _id: @person1Id
          displayName: 'Person 1'
          username: 'person1'
        ,
          _id: @person1Id
          displayName: 'Person 1'
          username: 'person1'
        ,
          _id: @person1Id
          displayName: 'Person 1'
          username: 'person1'
        ,
          _id: @person1Id
          displayName: 'Person 1'
          username: 'person1'
        ,
          _id: @person2Id
          displayName: 'Person 2'
          username: 'person2'
        ,
          _id: @person3Id
          displayName: 'Person 3'
          username: 'person3'
        ]
        slug: 'subdocument-prefix-foobar3-subdocumentfoobar3-suffix'
        body: 'SubdocumentFooBar3'
      nested: [
        required:
          _id: @person3Id
          username: 'person3'
          displayName: 'Person 3'
        slug: 'nested-prefix-foobar3-nestedfoobar3-suffix'
        body: 'NestedFooBar3'
      ]
      body: 'FooBar3'
      slug: 'prefix-foobar3-subdocumentfoobar3-suffix'
      tags: [
        'tag-0-prefix-foobar3-subdocumentfoobar3-suffix'
        'tag-1-prefix-foobar3-nestedfoobar3-suffix'
      ]

    @person1 = Person.documents.findOne @person1Id,
      transform: null # So that we can use test.equal
    @person2 = Person.documents.findOne @person2Id,
      transform: null # So that we can use test.equal
    @person3 = Person.documents.findOne @person3Id,
      transform: null # So that we can use test.equal

    test.equal _.omit(@person1, 'posts', 'subdocument', 'subdocumentsPosts', 'nestedPosts'),
      _id: @person1Id
      username: 'person1'
      displayName: 'Person 1'
      count: 8

    testSetEqual test, @person1.posts,
      [
        _id: @postId1
        subdocument:
          body: 'SubdocumentFooBar1'
        nested: [
          body: 'NestedFooBar1'
        ]
        body: 'FooBar1'
      ,
        _id: @postId2
        subdocument:
          body: 'SubdocumentFooBar2'
        nested: [
          body: 'NestedFooBar2'
        ]
        body: 'FooBar2'
      ,
        _id: @postId3
        subdocument:
          body: 'SubdocumentFooBar3'
        nested: [
          body: 'NestedFooBar3'
        ]
        body: 'FooBar3'
      ]
    testSetEqual test, @person1.subdocument?.posts,
      [
        _id: @postId1
        subdocument:
          body: 'SubdocumentFooBar1'
        nested: [
          body: 'NestedFooBar1'
        ]
        body: 'FooBar1'
      ,
        _id: @postId3
        subdocument:
          body: 'SubdocumentFooBar3'
        nested: [
          body: 'NestedFooBar3'
        ]
        body: 'FooBar3'
      ]
    testSetEqual test, @person1.subdocumentsPosts,
      [
        _id: @postId1
        subdocument:
          body: 'SubdocumentFooBar1'
        nested: [
          body: 'NestedFooBar1'
        ]
        body: 'FooBar1'
      ,
        _id: @postId2
        subdocument:
          body: 'SubdocumentFooBar2'
        nested: [
          body: 'NestedFooBar2'
        ]
        body: 'FooBar2'
      ,
        _id: @postId3
        subdocument:
          body: 'SubdocumentFooBar3'
        nested: [
          body: 'NestedFooBar3'
        ]
        body: 'FooBar3'
      ]
    testSetEqual test, @person1.nestedPosts, []

    test.equal _.omit(@person2, 'posts', 'subdocument', 'subdocumentsPosts', 'nestedPosts'),
      _id: @person2Id
      username: 'person2'
      displayName: 'Person 2'
      count: 5

    testSetEqual test, @person2.posts, []
    testSetEqual test, @person2.subdocument?.posts,
      [
        _id: @postId2
        subdocument:
          body: 'SubdocumentFooBar2'
        nested: [
          body: 'NestedFooBar2'
        ]
        body: 'FooBar2'
      ]
    testSetEqual test, @person2.subdocumentsPosts,
      [
        _id: @postId1
        subdocument:
          body: 'SubdocumentFooBar1'
        nested: [
          body: 'NestedFooBar1'
        ]
        body: 'FooBar1'
      ,
        _id: @postId2
        subdocument:
          body: 'SubdocumentFooBar2'
        nested: [
          body: 'NestedFooBar2'
        ]
        body: 'FooBar2'
      ,
        _id: @postId3
        subdocument:
          body: 'SubdocumentFooBar3'
        nested: [
          body: 'NestedFooBar3'
        ]
        body: 'FooBar3'
      ]
    testSetEqual test, @person2.nestedPosts,
      [
        _id: @postId1
        subdocument:
          body: 'SubdocumentFooBar1'
        nested: [
          body: 'NestedFooBar1'
        ]
        body: 'FooBar1'
      ]

    test.equal _.omit(@person3, 'posts', 'subdocument', 'subdocumentsPosts', 'nestedPosts'),
      _id: @person3Id
      username: 'person3'
      displayName: 'Person 3'
      count: 5

    testSetEqual test, @person3.posts, []
    testSetEqual test, @person3.subdocument?.posts, []
    testSetEqual test, @person3.subdocumentsPosts,
      [
        _id: @postId1
        subdocument:
          body: 'SubdocumentFooBar1'
        nested: [
          body: 'NestedFooBar1'
        ]
        body: 'FooBar1'
      ,
        _id: @postId2
        subdocument:
          body: 'SubdocumentFooBar2'
        nested: [
          body: 'NestedFooBar2'
        ]
        body: 'FooBar2'
      ,
        _id: @postId3
        subdocument:
          body: 'SubdocumentFooBar3'
        nested: [
          body: 'NestedFooBar3'
        ]
        body: 'FooBar3'
      ]
    testSetEqual test, @person3.nestedPosts,
      [
        _id: @postId2
        subdocument:
          body: 'SubdocumentFooBar2'
        nested: [
          body: 'NestedFooBar2'
        ]
        body: 'FooBar2'
      ,
        _id: @postId3
        subdocument:
          body: 'SubdocumentFooBar3'
        nested: [
          body: 'NestedFooBar3'
        ]
        body: 'FooBar3'
      ]

    Post.documents.insert
      author:
        _id: @person1Id
      nested: [
        required:
          _id: @person3Id
        body: 'NestedFooBar4'
      ,
        required:
          _id: @person3Id
        body: 'NestedFooBar4'
      ,
        required:
          _id: @person1Id
        body: 'NestedFooBar4'
      ,
        required:
          _id: @person2Id
        body: 'NestedFooBar4'
      ,
        required:
          _id: @person3Id
        body: 'NestedFooBar4'
      ,
        required:
          _id: @person1Id
        body: 'NestedFooBar4'
      ,
        required:
          _id: @person2Id
        body: 'NestedFooBar4'
      ,
        required:
          _id: @person3Id
        body: 'NestedFooBar4'
      ]
      subdocument:
        person:
          _id: @person1Id
        persons: [
          _id: @person1Id
        ,
          _id: @person1Id
        ,
          _id: @person1Id
        ,
          _id: @person1Id
        ,
          _id: @person2Id
        ,
          _id: @person2Id
        ]
        body: 'SubdocumentFooBar4'
      body: 'FooBar4'
    ,
      expect (error, postId) =>
        test.isFalse error, error?.toString?() or error
        test.isTrue postId
        @postId4 = postId

    Post.documents.insert
      author:
        _id: @person1Id
      nested: [
        required:
          _id: @person3Id
        body: 'NestedFooBar5'
      ,
        required:
          _id: @person3Id
        body: 'NestedFooBar5'
      ,
        required:
          _id: @person3Id
        body: 'NestedFooBar5'
      ]
      subdocument:
        person:
          _id: @person3Id
        persons: [
          _id: @person3Id
        ,
          _id: @person3Id
        ,
          _id: @person3Id
        ,
          _id: @person3Id
        ,
          _id: @person2Id
        ,
          _id: @person3Id
        ]
        body: 'SubdocumentFooBar5'
      body: 'FooBar5'
    ,
      expect (error, postId) =>
        test.isFalse error, error?.toString?() or error
        test.isTrue postId
        @postId5 = postId

    # Wait so that observers have time to update documents
    waitForDatabase test, expect
,
  (test, expect) ->
    @person1 = Person.documents.findOne @person1Id,
      transform: null # So that we can use test.equal
    @person2 = Person.documents.findOne @person2Id,
      transform: null # So that we can use test.equal
    @person3 = Person.documents.findOne @person3Id,
      transform: null # So that we can use test.equal

    test.equal _.omit(@person1, 'posts', 'subdocument', 'subdocumentsPosts', 'nestedPosts'),
      _id: @person1Id
      username: 'person1'
      displayName: 'Person 1'
      count: 13

    testSetEqual test, @person1.posts,
      [
        _id: @postId1
        subdocument:
          body: 'SubdocumentFooBar1'
        nested: [
          body: 'NestedFooBar1'
        ]
        body: 'FooBar1'
      ,
        _id: @postId2
        subdocument:
          body: 'SubdocumentFooBar2'
        nested: [
          body: 'NestedFooBar2'
        ]
        body: 'FooBar2'
      ,
        _id: @postId3
        subdocument:
          body: 'SubdocumentFooBar3'
        nested: [
          body: 'NestedFooBar3'
        ]
        body: 'FooBar3'
      ,
        _id: @postId4
        subdocument:
          body: 'SubdocumentFooBar4'
        nested: [
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ]
        body: 'FooBar4'
      ,
        _id: @postId5
        subdocument:
          body: 'SubdocumentFooBar5'
        nested: [
          body: 'NestedFooBar5'
        ,
          body: 'NestedFooBar5'
        ,
          body: 'NestedFooBar5'
        ]
        body: 'FooBar5'
      ]
    testSetEqual test, @person1.subdocument?.posts,
      [
        _id: @postId1
        subdocument:
          body: 'SubdocumentFooBar1'
        nested: [
          body: 'NestedFooBar1'
        ]
        body: 'FooBar1'
      ,
        _id: @postId3
        subdocument:
          body: 'SubdocumentFooBar3'
        nested: [
          body: 'NestedFooBar3'
        ]
        body: 'FooBar3'
      ,
        _id: @postId4
        subdocument:
          body: 'SubdocumentFooBar4'
        nested: [
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ]
        body: 'FooBar4'
      ]
    testSetEqual test, @person1.subdocumentsPosts,
      [
        _id: @postId1
        subdocument:
          body: 'SubdocumentFooBar1'
        nested: [
          body: 'NestedFooBar1'
        ]
        body: 'FooBar1'
      ,
        _id: @postId2
        subdocument:
          body: 'SubdocumentFooBar2'
        nested: [
          body: 'NestedFooBar2'
        ]
        body: 'FooBar2'
      ,
        _id: @postId3
        subdocument:
          body: 'SubdocumentFooBar3'
        nested: [
          body: 'NestedFooBar3'
        ]
        body: 'FooBar3'
      ,
        _id: @postId4
        subdocument:
          body: 'SubdocumentFooBar4'
        nested: [
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ]
        body: 'FooBar4'
      ]
    testSetEqual test, @person1.nestedPosts,
      [
        _id: @postId4
        subdocument:
          body: 'SubdocumentFooBar4'
        nested: [
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ]
        body: 'FooBar4'
      ]

    test.equal _.omit(@person2, 'posts', 'subdocument', 'subdocumentsPosts', 'nestedPosts'),
      _id: @person2Id
      username: 'person2'
      displayName: 'Person 2'
      count: 8

    testSetEqual test, @person2.posts, []
    testSetEqual test, @person2.subdocument?.posts,
      [
        _id: @postId2
        subdocument:
          body: 'SubdocumentFooBar2'
        nested: [
          body: 'NestedFooBar2'
        ]
        body: 'FooBar2'
      ]
    testSetEqual test, @person2.subdocumentsPosts,
      [
        _id: @postId1
        subdocument:
          body: 'SubdocumentFooBar1'
        nested: [
          body: 'NestedFooBar1'
        ]
        body: 'FooBar1'
      ,
        _id: @postId2
        subdocument:
          body: 'SubdocumentFooBar2'
        nested: [
          body: 'NestedFooBar2'
        ]
        body: 'FooBar2'
      ,
        _id: @postId3
        subdocument:
          body: 'SubdocumentFooBar3'
        nested: [
          body: 'NestedFooBar3'
        ]
        body: 'FooBar3'
      ,
        _id: @postId4
        subdocument:
          body: 'SubdocumentFooBar4'
        nested: [
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ]
        body: 'FooBar4'
      ,
        _id: @postId5
        subdocument:
          body: 'SubdocumentFooBar5'
        nested: [
          body: 'NestedFooBar5'
        ,
          body: 'NestedFooBar5'
        ,
          body: 'NestedFooBar5'
        ]
        body: 'FooBar5'
      ]
    testSetEqual test, @person2.nestedPosts,
      [
        _id: @postId1
        subdocument:
          body: 'SubdocumentFooBar1'
        nested: [
          body: 'NestedFooBar1'
        ]
        body: 'FooBar1'
      ,
        _id: @postId4
        subdocument:
          body: 'SubdocumentFooBar4'
        nested: [
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ]
        body: 'FooBar4'
      ]

    test.equal _.omit(@person3, 'posts', 'subdocument', 'subdocumentsPosts', 'nestedPosts'),
      _id: @person3Id
      username: 'person3'
      displayName: 'Person 3'
      count: 9

    testSetEqual test, @person3.posts, []
    testSetEqual test, @person3.subdocument?.posts,
      [
        _id: @postId5
        subdocument:
          body: 'SubdocumentFooBar5'
        nested: [
          body: 'NestedFooBar5'
        ,
          body: 'NestedFooBar5'
        ,
          body: 'NestedFooBar5'
        ]
        body: 'FooBar5'
      ]
    testSetEqual test, @person3.subdocumentsPosts,
      [
        _id: @postId1
        subdocument:
          body: 'SubdocumentFooBar1'
        nested: [
          body: 'NestedFooBar1'
        ]
        body: 'FooBar1'
      ,
        _id: @postId2
        subdocument:
          body: 'SubdocumentFooBar2'
        nested: [
          body: 'NestedFooBar2'
        ]
        body: 'FooBar2'
      ,
        _id: @postId3
        subdocument:
          body: 'SubdocumentFooBar3'
        nested: [
          body: 'NestedFooBar3'
        ]
        body: 'FooBar3'
      ,
        _id: @postId5
        subdocument:
          body: 'SubdocumentFooBar5'
        nested: [
          body: 'NestedFooBar5'
        ,
          body: 'NestedFooBar5'
        ,
          body: 'NestedFooBar5'
        ]
        body: 'FooBar5'
      ]
    testSetEqual test, @person3.nestedPosts,
      [
        _id: @postId2
        subdocument:
          body: 'SubdocumentFooBar2'
        nested: [
          body: 'NestedFooBar2'
        ]
        body: 'FooBar2'
      ,
        _id: @postId3
        subdocument:
          body: 'SubdocumentFooBar3'
        nested: [
          body: 'NestedFooBar3'
        ]
        body: 'FooBar3'
      ,
        _id: @postId4
        subdocument:
          body: 'SubdocumentFooBar4'
        nested: [
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ]
        body: 'FooBar4'
      ,
        _id: @postId5
        subdocument:
          body: 'SubdocumentFooBar5'
        nested: [
          body: 'NestedFooBar5'
        ,
          body: 'NestedFooBar5'
        ,
          body: 'NestedFooBar5'
        ]
        body: 'FooBar5'
      ]

    Post.documents.update @postId1,
      $set:
        'body': 'FooBar1a'
        'subdocument.body': 'SubdocumentFooBar1a'
        'nested.0.body': 'NestedFooBar1a'
    ,
      expect (error, res) =>
        test.isFalse error, error?.toString?() or error
        test.isTrue res

    Post.documents.update @postId2,
      $set:
        'body': 'FooBar2a'
        'subdocument.body': 'SubdocumentFooBar2a'
        'nested.0.body': 'NestedFooBar2a'
    ,
      expect (error, res) =>
        test.isFalse error, error?.toString?() or error
        test.isTrue res

    Post.documents.update @postId3,
      $set:
        'body': 'FooBar3a'
        'subdocument.body': 'SubdocumentFooBar3a'
        'nested.0.body': 'NestedFooBar3a'
    ,
      expect (error, res) =>
        test.isFalse error, error?.toString?() or error
        test.isTrue res

    Post.documents.update @postId4,
      $set:
        'body': 'FooBar4a'
        'subdocument.body': 'SubdocumentFooBar4a'
        'nested.1.body': 'NestedFooBar4a'
        'nested.3.body': 'NestedFooBar4a'
    ,
      expect (error, res) =>
        test.isFalse error, error?.toString?() or error
        test.isTrue res

    Post.documents.update @postId5,
      $set:
        'body': 'FooBar5a'
        'subdocument.body': 'SubdocumentFooBar5a'
        'nested.1.body': 'NestedFooBar5a'
    ,
      expect (error, res) =>
        test.isFalse error, error?.toString?() or error
        test.isTrue res

    # Wait so that observers have time to update documents
    waitForDatabase test, expect
,
  (test, expect) ->
    @person1 = Person.documents.findOne @person1Id,
      transform: null # So that we can use test.equal
    @person2 = Person.documents.findOne @person2Id,
      transform: null # So that we can use test.equal
    @person3 = Person.documents.findOne @person3Id,
      transform: null # So that we can use test.equal

    test.equal _.omit(@person1, 'posts', 'subdocument', 'subdocumentsPosts', 'nestedPosts'),
      _id: @person1Id
      username: 'person1'
      displayName: 'Person 1'
      count: 13

    testSetEqual test, @person1.posts,
      [
        _id: @postId1
        subdocument:
          body: 'SubdocumentFooBar1a'
        nested: [
          body: 'NestedFooBar1a'
        ]
        body: 'FooBar1a'
      ,
        _id: @postId2
        subdocument:
          body: 'SubdocumentFooBar2a'
        nested: [
          body: 'NestedFooBar2a'
        ]
        body: 'FooBar2a'
      ,
        _id: @postId3
        subdocument:
          body: 'SubdocumentFooBar3a'
        nested: [
          body: 'NestedFooBar3a'
        ]
        body: 'FooBar3a'
      ,
        _id: @postId4
        subdocument:
          body: 'SubdocumentFooBar4a'
        nested: [
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ]
        body: 'FooBar4a'
      ,
        _id: @postId5
        subdocument:
          body: 'SubdocumentFooBar5a'
        nested: [
          body: 'NestedFooBar5'
        ,
          body: 'NestedFooBar5a'
        ,
          body: 'NestedFooBar5'
        ]
        body: 'FooBar5a'
      ]
    testSetEqual test, @person1.subdocument?.posts,
      [
        _id: @postId1
        subdocument:
          body: 'SubdocumentFooBar1a'
        nested: [
          body: 'NestedFooBar1a'
        ]
        body: 'FooBar1a'
      ,
        _id: @postId3
        subdocument:
          body: 'SubdocumentFooBar3a'
        nested: [
          body: 'NestedFooBar3a'
        ]
        body: 'FooBar3a'
      ,
        _id: @postId4
        subdocument:
          body: 'SubdocumentFooBar4a'
        nested: [
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ]
        body: 'FooBar4a'
      ]
    testSetEqual test, @person1.subdocumentsPosts,
      [
        _id: @postId1
        subdocument:
          body: 'SubdocumentFooBar1a'
        nested: [
          body: 'NestedFooBar1a'
        ]
        body: 'FooBar1a'
      ,
        _id: @postId2
        subdocument:
          body: 'SubdocumentFooBar2a'
        nested: [
          body: 'NestedFooBar2a'
        ]
        body: 'FooBar2a'
      ,
        _id: @postId3
        subdocument:
          body: 'SubdocumentFooBar3a'
        nested: [
          body: 'NestedFooBar3a'
        ]
        body: 'FooBar3a'
      ,
        _id: @postId4
        subdocument:
          body: 'SubdocumentFooBar4a'
        nested: [
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ]
        body: 'FooBar4a'
      ]
    testSetEqual test, @person1.nestedPosts,
      [
        _id: @postId4
        subdocument:
          body: 'SubdocumentFooBar4a'
        nested: [
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ]
        body: 'FooBar4a'
      ]

    test.equal _.omit(@person2, 'posts', 'subdocument', 'subdocumentsPosts', 'nestedPosts'),
      _id: @person2Id
      username: 'person2'
      displayName: 'Person 2'
      count: 8

    testSetEqual test, @person2.posts, []
    testSetEqual test, @person2.subdocument?.posts,
      [
        _id: @postId2
        subdocument:
          body: 'SubdocumentFooBar2a'
        nested: [
          body: 'NestedFooBar2a'
        ]
        body: 'FooBar2a'
      ]
    testSetEqual test, @person2.subdocumentsPosts,
      [
        _id: @postId1
        subdocument:
          body: 'SubdocumentFooBar1a'
        nested: [
          body: 'NestedFooBar1a'
        ]
        body: 'FooBar1a'
      ,
        _id: @postId2
        subdocument:
          body: 'SubdocumentFooBar2a'
        nested: [
          body: 'NestedFooBar2a'
        ]
        body: 'FooBar2a'
      ,
        _id: @postId3
        subdocument:
          body: 'SubdocumentFooBar3a'
        nested: [
          body: 'NestedFooBar3a'
        ]
        body: 'FooBar3a'
      ,
        _id: @postId4
        subdocument:
          body: 'SubdocumentFooBar4a'
        nested: [
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ]
        body: 'FooBar4a'
      ,
        _id: @postId5
        subdocument:
          body: 'SubdocumentFooBar5a'
        nested: [
          body: 'NestedFooBar5'
        ,
          body: 'NestedFooBar5a'
        ,
          body: 'NestedFooBar5'
        ]
        body: 'FooBar5a'
      ]
    testSetEqual test, @person2.nestedPosts,
      [
        _id: @postId1
        subdocument:
          body: 'SubdocumentFooBar1a'
        nested: [
          body: 'NestedFooBar1a'
        ]
        body: 'FooBar1a'
      ,
        _id: @postId4
        subdocument:
          body: 'SubdocumentFooBar4a'
        nested: [
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ]
        body: 'FooBar4a'
      ]

    test.equal _.omit(@person3, 'posts', 'subdocument', 'subdocumentsPosts', 'nestedPosts'),
      _id: @person3Id
      username: 'person3'
      displayName: 'Person 3'
      count: 9

    testSetEqual test, @person3.posts, []
    testSetEqual test, @person3.subdocument?.posts,
      [
        _id: @postId5
        subdocument:
          body: 'SubdocumentFooBar5a'
        nested: [
          body: 'NestedFooBar5'
        ,
          body: 'NestedFooBar5a'
        ,
          body: 'NestedFooBar5'
        ]
        body: 'FooBar5a'
      ]
    testSetEqual test, @person3.subdocumentsPosts,
      [
        _id: @postId1
        subdocument:
          body: 'SubdocumentFooBar1a'
        nested: [
          body: 'NestedFooBar1a'
        ]
        body: 'FooBar1a'
      ,
        _id: @postId2
        subdocument:
          body: 'SubdocumentFooBar2a'
        nested: [
          body: 'NestedFooBar2a'
        ]
        body: 'FooBar2a'
      ,
        _id: @postId3
        subdocument:
          body: 'SubdocumentFooBar3a'
        nested: [
          body: 'NestedFooBar3a'
        ]
        body: 'FooBar3a'
      ,
        _id: @postId5
        subdocument:
          body: 'SubdocumentFooBar5a'
        nested: [
          body: 'NestedFooBar5'
        ,
          body: 'NestedFooBar5a'
        ,
          body: 'NestedFooBar5'
        ]
        body: 'FooBar5a'
      ]
    testSetEqual test, @person3.nestedPosts,
      [
        _id: @postId2
        subdocument:
          body: 'SubdocumentFooBar2a'
        nested: [
          body: 'NestedFooBar2a'
        ]
        body: 'FooBar2a'
      ,
        _id: @postId3
        subdocument:
          body: 'SubdocumentFooBar3a'
        nested: [
          body: 'NestedFooBar3a'
        ]
        body: 'FooBar3a'
      ,
        _id: @postId4
        subdocument:
          body: 'SubdocumentFooBar4a'
        nested: [
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ]
        body: 'FooBar4a'
      ,
        _id: @postId5
        subdocument:
          body: 'SubdocumentFooBar5a'
        nested: [
          body: 'NestedFooBar5'
        ,
          body: 'NestedFooBar5a'
        ,
          body: 'NestedFooBar5'
        ]
        body: 'FooBar5a'
      ]

    Post.documents.update @postId2,
      $push:
        nested:
          required:
            _id: @person2Id
          body: 'NestedFooBarNew'
    ,
      expect (error, res) =>
        test.isFalse error, error?.toString?() or error
        test.isTrue res

    # Wait so that observers have time to update documents
    waitForDatabase test, expect
,
  (test, expect) ->
    @post2 = Post.documents.findOne @postId2,
      transform: null # So that we can use test.equal

    test.equal @post2,
      _id: @postId2
      author:
        _id: @person1Id
        username: 'person1'
        displayName: 'Person 1'
      subdocument:
        person:
          _id: @person2Id
          displayName: 'Person 2'
          username: 'person2'
        persons: [
          _id: @person2Id
          displayName: 'Person 2'
          username: 'person2'
        ,
          _id: @person2Id
          displayName: 'Person 2'
          username: 'person2'
        ,
          _id: @person2Id
          displayName: 'Person 2'
          username: 'person2'
        ,
          _id: @person1Id
          displayName: 'Person 1'
          username: 'person1'
        ,
          _id: @person2Id
          displayName: 'Person 2'
          username: 'person2'
        ,
          _id: @person3Id
          displayName: 'Person 3'
          username: 'person3'
        ]
        slug: 'subdocument-prefix-foobar2a-subdocumentfoobar2a-suffix'
        body: 'SubdocumentFooBar2a'
      nested: [
        required:
          _id: @person3Id
          username: 'person3'
          displayName: 'Person 3'
        slug: 'nested-prefix-foobar2a-nestedfoobar2a-suffix'
        body: 'NestedFooBar2a'
      ,
        required:
          _id: @person2Id
          username: 'person2'
          displayName: 'Person 2'
        slug: 'nested-prefix-foobar2a-nestedfoobarnew-suffix'
        body: 'NestedFooBarNew'
      ]
      body: 'FooBar2a'
      slug: 'prefix-foobar2a-subdocumentfoobar2a-suffix'
      tags: [
        'tag-0-prefix-foobar2a-subdocumentfoobar2a-suffix'
        'tag-1-prefix-foobar2a-nestedfoobar2a-suffix'
        'tag-2-prefix-foobar2a-nestedfoobarnew-suffix'
      ]

    @person1 = Person.documents.findOne @person1Id,
      transform: null # So that we can use test.equal
    @person2 = Person.documents.findOne @person2Id,
      transform: null # So that we can use test.equal
    @person3 = Person.documents.findOne @person3Id,
      transform: null # So that we can use test.equal

    test.equal _.omit(@person1, 'posts', 'subdocument', 'subdocumentsPosts', 'nestedPosts'),
      _id: @person1Id
      username: 'person1'
      displayName: 'Person 1'
      count: 13

    testSetEqual test, @person1.posts,
      [
        _id: @postId1
        subdocument:
          body: 'SubdocumentFooBar1a'
        nested: [
          body: 'NestedFooBar1a'
        ]
        body: 'FooBar1a'
      ,
        _id: @postId2
        subdocument:
          body: 'SubdocumentFooBar2a'
        nested: [
          body: 'NestedFooBar2a'
        ,
          body: 'NestedFooBarNew'
        ]
        body: 'FooBar2a'
      ,
        _id: @postId3
        subdocument:
          body: 'SubdocumentFooBar3a'
        nested: [
          body: 'NestedFooBar3a'
        ]
        body: 'FooBar3a'
      ,
        _id: @postId4
        subdocument:
          body: 'SubdocumentFooBar4a'
        nested: [
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ]
        body: 'FooBar4a'
      ,
        _id: @postId5
        subdocument:
          body: 'SubdocumentFooBar5a'
        nested: [
          body: 'NestedFooBar5'
        ,
          body: 'NestedFooBar5a'
        ,
          body: 'NestedFooBar5'
        ]
        body: 'FooBar5a'
      ]
    testSetEqual test, @person1.subdocument?.posts,
      [
        _id: @postId1
        subdocument:
          body: 'SubdocumentFooBar1a'
        nested: [
          body: 'NestedFooBar1a'
        ]
        body: 'FooBar1a'
      ,
        _id: @postId3
        subdocument:
          body: 'SubdocumentFooBar3a'
        nested: [
          body: 'NestedFooBar3a'
        ]
        body: 'FooBar3a'
      ,
        _id: @postId4
        subdocument:
          body: 'SubdocumentFooBar4a'
        nested: [
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ]
        body: 'FooBar4a'
      ]
    testSetEqual test, @person1.subdocumentsPosts,
      [
        _id: @postId1
        subdocument:
          body: 'SubdocumentFooBar1a'
        nested: [
          body: 'NestedFooBar1a'
        ]
        body: 'FooBar1a'
      ,
        _id: @postId2
        subdocument:
          body: 'SubdocumentFooBar2a'
        nested: [
          body: 'NestedFooBar2a'
        ,
          body: 'NestedFooBarNew'
        ]
        body: 'FooBar2a'
      ,
        _id: @postId3
        subdocument:
          body: 'SubdocumentFooBar3a'
        nested: [
          body: 'NestedFooBar3a'
        ]
        body: 'FooBar3a'
      ,
        _id: @postId4
        subdocument:
          body: 'SubdocumentFooBar4a'
        nested: [
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ]
        body: 'FooBar4a'
      ]
    testSetEqual test, @person1.nestedPosts,
      [
        _id: @postId4
        subdocument:
          body: 'SubdocumentFooBar4a'
        nested: [
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ]
        body: 'FooBar4a'
      ]

    test.equal _.omit(@person2, 'posts', 'subdocument', 'subdocumentsPosts', 'nestedPosts'),
      _id: @person2Id
      username: 'person2'
      displayName: 'Person 2'
      count: 9

    testSetEqual test, @person2.posts, []
    testSetEqual test, @person2.subdocument?.posts,
      [
        _id: @postId2
        subdocument:
          body: 'SubdocumentFooBar2a'
        nested: [
          body: 'NestedFooBar2a'
        ,
          body: 'NestedFooBarNew'
        ]
        body: 'FooBar2a'
      ]
    testSetEqual test, @person2.subdocumentsPosts,
      [
        _id: @postId1
        subdocument:
          body: 'SubdocumentFooBar1a'
        nested: [
          body: 'NestedFooBar1a'
        ]
        body: 'FooBar1a'
      ,
        _id: @postId2
        subdocument:
          body: 'SubdocumentFooBar2a'
        nested: [
          body: 'NestedFooBar2a'
        ,
          body: 'NestedFooBarNew'
        ]
        body: 'FooBar2a'
      ,
        _id: @postId3
        subdocument:
          body: 'SubdocumentFooBar3a'
        nested: [
          body: 'NestedFooBar3a'
        ]
        body: 'FooBar3a'
      ,
        _id: @postId4
        subdocument:
          body: 'SubdocumentFooBar4a'
        nested: [
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ]
        body: 'FooBar4a'
      ,
        _id: @postId5
        subdocument:
          body: 'SubdocumentFooBar5a'
        nested: [
          body: 'NestedFooBar5'
        ,
          body: 'NestedFooBar5a'
        ,
          body: 'NestedFooBar5'
        ]
        body: 'FooBar5a'
      ]
    testSetEqual test, @person2.nestedPosts,
      [
        _id: @postId1
        subdocument:
          body: 'SubdocumentFooBar1a'
        nested: [
          body: 'NestedFooBar1a'
        ]
        body: 'FooBar1a'
      ,
        _id: @postId4
        subdocument:
          body: 'SubdocumentFooBar4a'
        nested: [
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ]
        body: 'FooBar4a'
      ,
        _id: @postId2
        subdocument:
          body: 'SubdocumentFooBar2a'
        nested: [
          body: 'NestedFooBar2a'
        ,
          body: 'NestedFooBarNew'
        ]
        body: 'FooBar2a'
      ]

    test.equal _.omit(@person3, 'posts', 'subdocument', 'subdocumentsPosts', 'nestedPosts'),
      _id: @person3Id
      username: 'person3'
      displayName: 'Person 3'
      count: 9

    testSetEqual test, @person3.posts, []
    testSetEqual test, @person3.subdocument?.posts,
      [
        _id: @postId5
        subdocument:
          body: 'SubdocumentFooBar5a'
        nested: [
          body: 'NestedFooBar5'
        ,
          body: 'NestedFooBar5a'
        ,
          body: 'NestedFooBar5'
        ]
        body: 'FooBar5a'
      ]
    testSetEqual test, @person3.subdocumentsPosts,
      [
        _id: @postId1
        subdocument:
          body: 'SubdocumentFooBar1a'
        nested: [
          body: 'NestedFooBar1a'
        ]
        body: 'FooBar1a'
      ,
        _id: @postId2
        subdocument:
          body: 'SubdocumentFooBar2a'
        nested: [
          body: 'NestedFooBar2a'
        ,
          body: 'NestedFooBarNew'
        ]
        body: 'FooBar2a'
      ,
        _id: @postId3
        subdocument:
          body: 'SubdocumentFooBar3a'
        nested: [
          body: 'NestedFooBar3a'
        ]
        body: 'FooBar3a'
      ,
        _id: @postId5
        subdocument:
          body: 'SubdocumentFooBar5a'
        nested: [
          body: 'NestedFooBar5'
        ,
          body: 'NestedFooBar5a'
        ,
          body: 'NestedFooBar5'
        ]
        body: 'FooBar5a'
      ]
    testSetEqual test, @person3.nestedPosts,
      [
        _id: @postId2
        subdocument:
          body: 'SubdocumentFooBar2a'
        nested: [
          body: 'NestedFooBar2a'
        ,
          body: 'NestedFooBarNew'
        ]
        body: 'FooBar2a'
      ,
        _id: @postId3
        subdocument:
          body: 'SubdocumentFooBar3a'
        nested: [
          body: 'NestedFooBar3a'
        ]
        body: 'FooBar3a'
      ,
        _id: @postId4
        subdocument:
          body: 'SubdocumentFooBar4a'
        nested: [
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ]
        body: 'FooBar4a'
      ,
        _id: @postId5
        subdocument:
          body: 'SubdocumentFooBar5a'
        nested: [
          body: 'NestedFooBar5'
        ,
          body: 'NestedFooBar5a'
        ,
          body: 'NestedFooBar5'
        ]
        body: 'FooBar5a'
      ]

    Post.documents.update @postId2,
      $pop:
        nested: 1
    ,
      expect (error, res) =>
        test.isFalse error, error?.toString?() or error
        test.isTrue res

    # Wait so that observers have time to update documents
    waitForDatabase test, expect
,
  (test, expect) ->
    @post2 = Post.documents.findOne @postId2,
      transform: null # So that we can use test.equal

    test.equal @post2,
      _id: @postId2
      author:
        _id: @person1Id
        username: 'person1'
        displayName: 'Person 1'
      subdocument:
        person:
          _id: @person2Id
          displayName: 'Person 2'
          username: 'person2'
        persons: [
          _id: @person2Id
          displayName: 'Person 2'
          username: 'person2'
        ,
          _id: @person2Id
          displayName: 'Person 2'
          username: 'person2'
        ,
          _id: @person2Id
          displayName: 'Person 2'
          username: 'person2'
        ,
          _id: @person1Id
          displayName: 'Person 1'
          username: 'person1'
        ,
          _id: @person2Id
          displayName: 'Person 2'
          username: 'person2'
        ,
          _id: @person3Id
          displayName: 'Person 3'
          username: 'person3'
        ]
        slug: 'subdocument-prefix-foobar2a-subdocumentfoobar2a-suffix'
        body: 'SubdocumentFooBar2a'
      nested: [
        required:
          _id: @person3Id
          username: 'person3'
          displayName: 'Person 3'
        slug: 'nested-prefix-foobar2a-nestedfoobar2a-suffix'
        body: 'NestedFooBar2a'
      ]
      body: 'FooBar2a'
      slug: 'prefix-foobar2a-subdocumentfoobar2a-suffix'
      tags: [
        'tag-0-prefix-foobar2a-subdocumentfoobar2a-suffix'
        'tag-1-prefix-foobar2a-nestedfoobar2a-suffix'
      ]

    @person1 = Person.documents.findOne @person1Id,
      transform: null # So that we can use test.equal
    @person2 = Person.documents.findOne @person2Id,
      transform: null # So that we can use test.equal
    @person3 = Person.documents.findOne @person3Id,
      transform: null # So that we can use test.equal

    test.equal _.omit(@person1, 'posts', 'subdocument', 'subdocumentsPosts', 'nestedPosts'),
      _id: @person1Id
      username: 'person1'
      displayName: 'Person 1'
      count: 13

    testSetEqual test, @person1.posts,
      [
        _id: @postId1
        subdocument:
          body: 'SubdocumentFooBar1a'
        nested: [
          body: 'NestedFooBar1a'
        ]
        body: 'FooBar1a'
      ,
        _id: @postId2
        subdocument:
          body: 'SubdocumentFooBar2a'
        nested: [
          body: 'NestedFooBar2a'
        ]
        body: 'FooBar2a'
      ,
        _id: @postId3
        subdocument:
          body: 'SubdocumentFooBar3a'
        nested: [
          body: 'NestedFooBar3a'
        ]
        body: 'FooBar3a'
      ,
        _id: @postId4
        subdocument:
          body: 'SubdocumentFooBar4a'
        nested: [
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ]
        body: 'FooBar4a'
      ,
        _id: @postId5
        subdocument:
          body: 'SubdocumentFooBar5a'
        nested: [
          body: 'NestedFooBar5'
        ,
          body: 'NestedFooBar5a'
        ,
          body: 'NestedFooBar5'
        ]
        body: 'FooBar5a'
      ]
    testSetEqual test, @person1.subdocument?.posts,
      [
        _id: @postId1
        subdocument:
          body: 'SubdocumentFooBar1a'
        nested: [
          body: 'NestedFooBar1a'
        ]
        body: 'FooBar1a'
      ,
        _id: @postId3
        subdocument:
          body: 'SubdocumentFooBar3a'
        nested: [
          body: 'NestedFooBar3a'
        ]
        body: 'FooBar3a'
      ,
        _id: @postId4
        subdocument:
          body: 'SubdocumentFooBar4a'
        nested: [
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ]
        body: 'FooBar4a'
      ]
    testSetEqual test, @person1.subdocumentsPosts,
      [
        _id: @postId1
        subdocument:
          body: 'SubdocumentFooBar1a'
        nested: [
          body: 'NestedFooBar1a'
        ]
        body: 'FooBar1a'
      ,
        _id: @postId2
        subdocument:
          body: 'SubdocumentFooBar2a'
        nested: [
          body: 'NestedFooBar2a'
        ]
        body: 'FooBar2a'
      ,
        _id: @postId3
        subdocument:
          body: 'SubdocumentFooBar3a'
        nested: [
          body: 'NestedFooBar3a'
        ]
        body: 'FooBar3a'
      ,
        _id: @postId4
        subdocument:
          body: 'SubdocumentFooBar4a'
        nested: [
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ]
        body: 'FooBar4a'
      ]
    testSetEqual test, @person1.nestedPosts,
      [
        _id: @postId4
        subdocument:
          body: 'SubdocumentFooBar4a'
        nested: [
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ]
        body: 'FooBar4a'
      ]

    test.equal _.omit(@person2, 'posts', 'subdocument', 'subdocumentsPosts', 'nestedPosts'),
      _id: @person2Id
      username: 'person2'
      displayName: 'Person 2'
      count: 8

    testSetEqual test, @person2.posts, []
    testSetEqual test, @person2.subdocument?.posts,
      [
        _id: @postId2
        subdocument:
          body: 'SubdocumentFooBar2a'
        nested: [
          body: 'NestedFooBar2a'
        ]
        body: 'FooBar2a'
      ]
    testSetEqual test, @person2.subdocumentsPosts,
      [
        _id: @postId1
        subdocument:
          body: 'SubdocumentFooBar1a'
        nested: [
          body: 'NestedFooBar1a'
        ]
        body: 'FooBar1a'
      ,
        _id: @postId2
        subdocument:
          body: 'SubdocumentFooBar2a'
        nested: [
          body: 'NestedFooBar2a'
        ]
        body: 'FooBar2a'
      ,
        _id: @postId3
        subdocument:
          body: 'SubdocumentFooBar3a'
        nested: [
          body: 'NestedFooBar3a'
        ]
        body: 'FooBar3a'
      ,
        _id: @postId4
        subdocument:
          body: 'SubdocumentFooBar4a'
        nested: [
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ]
        body: 'FooBar4a'
      ,
        _id: @postId5
        subdocument:
          body: 'SubdocumentFooBar5a'
        nested: [
          body: 'NestedFooBar5'
        ,
          body: 'NestedFooBar5a'
        ,
          body: 'NestedFooBar5'
        ]
        body: 'FooBar5a'
      ]
    testSetEqual test, @person2.nestedPosts,
      [
        _id: @postId1
        subdocument:
          body: 'SubdocumentFooBar1a'
        nested: [
          body: 'NestedFooBar1a'
        ]
        body: 'FooBar1a'
      ,
        _id: @postId4
        subdocument:
          body: 'SubdocumentFooBar4a'
        nested: [
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ]
        body: 'FooBar4a'
      ]

    test.equal _.omit(@person3, 'posts', 'subdocument', 'subdocumentsPosts', 'nestedPosts'),
      _id: @person3Id
      username: 'person3'
      displayName: 'Person 3'
      count: 9

    testSetEqual test, @person3.posts, []
    testSetEqual test, @person3.subdocument?.posts,
      [
        _id: @postId5
        subdocument:
          body: 'SubdocumentFooBar5a'
        nested: [
          body: 'NestedFooBar5'
        ,
          body: 'NestedFooBar5a'
        ,
          body: 'NestedFooBar5'
        ]
        body: 'FooBar5a'
      ]
    testSetEqual test, @person3.subdocumentsPosts,
      [
        _id: @postId1
        subdocument:
          body: 'SubdocumentFooBar1a'
        nested: [
          body: 'NestedFooBar1a'
        ]
        body: 'FooBar1a'
      ,
        _id: @postId2
        subdocument:
          body: 'SubdocumentFooBar2a'
        nested: [
          body: 'NestedFooBar2a'
        ]
        body: 'FooBar2a'
      ,
        _id: @postId3
        subdocument:
          body: 'SubdocumentFooBar3a'
        nested: [
          body: 'NestedFooBar3a'
        ]
        body: 'FooBar3a'
      ,
        _id: @postId5
        subdocument:
          body: 'SubdocumentFooBar5a'
        nested: [
          body: 'NestedFooBar5'
        ,
          body: 'NestedFooBar5a'
        ,
          body: 'NestedFooBar5'
        ]
        body: 'FooBar5a'
      ]
    testSetEqual test, @person3.nestedPosts,
      [
        _id: @postId2
        subdocument:
          body: 'SubdocumentFooBar2a'
        nested: [
          body: 'NestedFooBar2a'
        ]
        body: 'FooBar2a'
      ,
        _id: @postId3
        subdocument:
          body: 'SubdocumentFooBar3a'
        nested: [
          body: 'NestedFooBar3a'
        ]
        body: 'FooBar3a'
      ,
        _id: @postId4
        subdocument:
          body: 'SubdocumentFooBar4a'
        nested: [
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ]
        body: 'FooBar4a'
      ,
        _id: @postId5
        subdocument:
          body: 'SubdocumentFooBar5a'
        nested: [
          body: 'NestedFooBar5'
        ,
          body: 'NestedFooBar5a'
        ,
          body: 'NestedFooBar5'
        ]
        body: 'FooBar5a'
      ]

    # Add one which already exist
    Post.documents.update @postId2,
      $push:
        nested:
          required:
            _id: @person3Id
          body: 'NestedFooBarNew'
    ,
      expect (error, res) =>
        test.isFalse error, error?.toString?() or error
        test.isTrue res

    # Wait so that observers have time to update documents
    waitForDatabase test, expect
,
  (test, expect) ->
    @post2 = Post.documents.findOne @postId2,
      transform: null # So that we can use test.equal

    test.equal @post2,
      _id: @postId2
      author:
        _id: @person1Id
        username: 'person1'
        displayName: 'Person 1'
      subdocument:
        person:
          _id: @person2Id
          displayName: 'Person 2'
          username: 'person2'
        persons: [
          _id: @person2Id
          displayName: 'Person 2'
          username: 'person2'
        ,
          _id: @person2Id
          displayName: 'Person 2'
          username: 'person2'
        ,
          _id: @person2Id
          displayName: 'Person 2'
          username: 'person2'
        ,
          _id: @person1Id
          displayName: 'Person 1'
          username: 'person1'
        ,
          _id: @person2Id
          displayName: 'Person 2'
          username: 'person2'
        ,
          _id: @person3Id
          displayName: 'Person 3'
          username: 'person3'
        ]
        slug: 'subdocument-prefix-foobar2a-subdocumentfoobar2a-suffix'
        body: 'SubdocumentFooBar2a'
      nested: [
        required:
          _id: @person3Id
          username: 'person3'
          displayName: 'Person 3'
        slug: 'nested-prefix-foobar2a-nestedfoobar2a-suffix'
        body: 'NestedFooBar2a'
      ,
        required:
          _id: @person3Id
          username: 'person3'
          displayName: 'Person 3'
        slug: 'nested-prefix-foobar2a-nestedfoobarnew-suffix'
        body: 'NestedFooBarNew'
      ]
      body: 'FooBar2a'
      slug: 'prefix-foobar2a-subdocumentfoobar2a-suffix'
      tags: [
        'tag-0-prefix-foobar2a-subdocumentfoobar2a-suffix'
        'tag-1-prefix-foobar2a-nestedfoobar2a-suffix'
        'tag-2-prefix-foobar2a-nestedfoobarnew-suffix'
      ]

    @person1 = Person.documents.findOne @person1Id,
      transform: null # So that we can use test.equal
    @person2 = Person.documents.findOne @person2Id,
      transform: null # So that we can use test.equal
    @person3 = Person.documents.findOne @person3Id,
      transform: null # So that we can use test.equal

    test.equal _.omit(@person1, 'posts', 'subdocument', 'subdocumentsPosts', 'nestedPosts'),
      _id: @person1Id
      username: 'person1'
      displayName: 'Person 1'
      count: 13

    testSetEqual test, @person1.posts,
      [
        _id: @postId1
        subdocument:
          body: 'SubdocumentFooBar1a'
        nested: [
          body: 'NestedFooBar1a'
        ]
        body: 'FooBar1a'
      ,
        _id: @postId2
        subdocument:
          body: 'SubdocumentFooBar2a'
        nested: [
          body: 'NestedFooBar2a'
        ,
          body: 'NestedFooBarNew'
        ]
        body: 'FooBar2a'
      ,
        _id: @postId3
        subdocument:
          body: 'SubdocumentFooBar3a'
        nested: [
          body: 'NestedFooBar3a'
        ]
        body: 'FooBar3a'
      ,
        _id: @postId4
        subdocument:
          body: 'SubdocumentFooBar4a'
        nested: [
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ]
        body: 'FooBar4a'
      ,
        _id: @postId5
        subdocument:
          body: 'SubdocumentFooBar5a'
        nested: [
          body: 'NestedFooBar5'
        ,
          body: 'NestedFooBar5a'
        ,
          body: 'NestedFooBar5'
        ]
        body: 'FooBar5a'
      ]
    testSetEqual test, @person1.subdocument?.posts,
      [
        _id: @postId1
        subdocument:
          body: 'SubdocumentFooBar1a'
        nested: [
          body: 'NestedFooBar1a'
        ]
        body: 'FooBar1a'
      ,
        _id: @postId3
        subdocument:
          body: 'SubdocumentFooBar3a'
        nested: [
          body: 'NestedFooBar3a'
        ]
        body: 'FooBar3a'
      ,
        _id: @postId4
        subdocument:
          body: 'SubdocumentFooBar4a'
        nested: [
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ]
        body: 'FooBar4a'
      ]
    testSetEqual test, @person1.subdocumentsPosts,
      [
        _id: @postId1
        subdocument:
          body: 'SubdocumentFooBar1a'
        nested: [
          body: 'NestedFooBar1a'
        ]
        body: 'FooBar1a'
      ,
        _id: @postId2
        subdocument:
          body: 'SubdocumentFooBar2a'
        nested: [
          body: 'NestedFooBar2a'
        ,
          body: 'NestedFooBarNew'
        ]
        body: 'FooBar2a'
      ,
        _id: @postId3
        subdocument:
          body: 'SubdocumentFooBar3a'
        nested: [
          body: 'NestedFooBar3a'
        ]
        body: 'FooBar3a'
      ,
        _id: @postId4
        subdocument:
          body: 'SubdocumentFooBar4a'
        nested: [
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ]
        body: 'FooBar4a'
      ]
    testSetEqual test, @person1.nestedPosts,
      [
        _id: @postId4
        subdocument:
          body: 'SubdocumentFooBar4a'
        nested: [
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ]
        body: 'FooBar4a'
      ]

    test.equal _.omit(@person2, 'posts', 'subdocument', 'subdocumentsPosts', 'nestedPosts'),
      _id: @person2Id
      username: 'person2'
      displayName: 'Person 2'
      count: 8

    testSetEqual test, @person2.posts, []
    testSetEqual test, @person2.subdocument?.posts,
      [
        _id: @postId2
        subdocument:
          body: 'SubdocumentFooBar2a'
        nested: [
          body: 'NestedFooBar2a'
        ,
          body: 'NestedFooBarNew'
        ]
        body: 'FooBar2a'
      ]
    testSetEqual test, @person2.subdocumentsPosts,
      [
        _id: @postId1
        subdocument:
          body: 'SubdocumentFooBar1a'
        nested: [
          body: 'NestedFooBar1a'
        ]
        body: 'FooBar1a'
      ,
        _id: @postId2
        subdocument:
          body: 'SubdocumentFooBar2a'
        nested: [
          body: 'NestedFooBar2a'
        ,
          body: 'NestedFooBarNew'
        ]
        body: 'FooBar2a'
      ,
        _id: @postId3
        subdocument:
          body: 'SubdocumentFooBar3a'
        nested: [
          body: 'NestedFooBar3a'
        ]
        body: 'FooBar3a'
      ,
        _id: @postId4
        subdocument:
          body: 'SubdocumentFooBar4a'
        nested: [
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ]
        body: 'FooBar4a'
      ,
        _id: @postId5
        subdocument:
          body: 'SubdocumentFooBar5a'
        nested: [
          body: 'NestedFooBar5'
        ,
          body: 'NestedFooBar5a'
        ,
          body: 'NestedFooBar5'
        ]
        body: 'FooBar5a'
      ]
    testSetEqual test, @person2.nestedPosts,
      [
        _id: @postId1
        subdocument:
          body: 'SubdocumentFooBar1a'
        nested: [
          body: 'NestedFooBar1a'
        ]
        body: 'FooBar1a'
      ,
        _id: @postId4
        subdocument:
          body: 'SubdocumentFooBar4a'
        nested: [
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ]
        body: 'FooBar4a'
      ]

    test.equal _.omit(@person3, 'posts', 'subdocument', 'subdocumentsPosts', 'nestedPosts'),
      _id: @person3Id
      username: 'person3'
      displayName: 'Person 3'
      count: 9

    testSetEqual test, @person3.posts, []
    testSetEqual test, @person3.subdocument?.posts,
      [
        _id: @postId5
        subdocument:
          body: 'SubdocumentFooBar5a'
        nested: [
          body: 'NestedFooBar5'
        ,
          body: 'NestedFooBar5a'
        ,
          body: 'NestedFooBar5'
        ]
        body: 'FooBar5a'
      ]
    testSetEqual test, @person3.subdocumentsPosts,
      [
        _id: @postId1
        subdocument:
          body: 'SubdocumentFooBar1a'
        nested: [
          body: 'NestedFooBar1a'
        ]
        body: 'FooBar1a'
      ,
        _id: @postId2
        subdocument:
          body: 'SubdocumentFooBar2a'
        nested: [
          body: 'NestedFooBar2a'
        ,
          body: 'NestedFooBarNew'
        ]
        body: 'FooBar2a'
      ,
        _id: @postId3
        subdocument:
          body: 'SubdocumentFooBar3a'
        nested: [
          body: 'NestedFooBar3a'
        ]
        body: 'FooBar3a'
      ,
        _id: @postId5
        subdocument:
          body: 'SubdocumentFooBar5a'
        nested: [
          body: 'NestedFooBar5'
        ,
          body: 'NestedFooBar5a'
        ,
          body: 'NestedFooBar5'
        ]
        body: 'FooBar5a'
      ]
    testSetEqual test, @person3.nestedPosts,
      [
        _id: @postId2
        subdocument:
          body: 'SubdocumentFooBar2a'
        nested: [
          body: 'NestedFooBar2a'
        ,
          body: 'NestedFooBarNew'
        ]
        body: 'FooBar2a'
      ,
        _id: @postId3
        subdocument:
          body: 'SubdocumentFooBar3a'
        nested: [
          body: 'NestedFooBar3a'
        ]
        body: 'FooBar3a'
      ,
        _id: @postId4
        subdocument:
          body: 'SubdocumentFooBar4a'
        nested: [
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ]
        body: 'FooBar4a'
      ,
        _id: @postId5
        subdocument:
          body: 'SubdocumentFooBar5a'
        nested: [
          body: 'NestedFooBar5'
        ,
          body: 'NestedFooBar5a'
        ,
          body: 'NestedFooBar5'
        ]
        body: 'FooBar5a'
      ]

    Post.documents.update @postId2,
      $pop:
        nested: 1
    ,
      expect (error, res) =>
        test.isFalse error, error?.toString?() or error
        test.isTrue res

    # Wait so that observers have time to update documents
    waitForDatabase test, expect
,
  (test, expect) ->
    @post2 = Post.documents.findOne @postId2,
      transform: null # So that we can use test.equal

    test.equal @post2,
      _id: @postId2
      author:
        _id: @person1Id
        username: 'person1'
        displayName: 'Person 1'
      subdocument:
        person:
          _id: @person2Id
          displayName: 'Person 2'
          username: 'person2'
        persons: [
          _id: @person2Id
          displayName: 'Person 2'
          username: 'person2'
        ,
          _id: @person2Id
          displayName: 'Person 2'
          username: 'person2'
        ,
          _id: @person2Id
          displayName: 'Person 2'
          username: 'person2'
        ,
          _id: @person1Id
          displayName: 'Person 1'
          username: 'person1'
        ,
          _id: @person2Id
          displayName: 'Person 2'
          username: 'person2'
        ,
          _id: @person3Id
          displayName: 'Person 3'
          username: 'person3'
        ]
        slug: 'subdocument-prefix-foobar2a-subdocumentfoobar2a-suffix'
        body: 'SubdocumentFooBar2a'
      nested: [
        required:
          _id: @person3Id
          username: 'person3'
          displayName: 'Person 3'
        slug: 'nested-prefix-foobar2a-nestedfoobar2a-suffix'
        body: 'NestedFooBar2a'
      ]
      body: 'FooBar2a'
      slug: 'prefix-foobar2a-subdocumentfoobar2a-suffix'
      tags: [
        'tag-0-prefix-foobar2a-subdocumentfoobar2a-suffix'
        'tag-1-prefix-foobar2a-nestedfoobar2a-suffix'
      ]

    @person1 = Person.documents.findOne @person1Id,
      transform: null # So that we can use test.equal
    @person2 = Person.documents.findOne @person2Id,
      transform: null # So that we can use test.equal
    @person3 = Person.documents.findOne @person3Id,
      transform: null # So that we can use test.equal

    test.equal _.omit(@person1, 'posts', 'subdocument', 'subdocumentsPosts', 'nestedPosts'),
      _id: @person1Id
      username: 'person1'
      displayName: 'Person 1'
      count: 13

    testSetEqual test, @person1.posts,
      [
        _id: @postId1
        subdocument:
          body: 'SubdocumentFooBar1a'
        nested: [
          body: 'NestedFooBar1a'
        ]
        body: 'FooBar1a'
      ,
        _id: @postId2
        subdocument:
          body: 'SubdocumentFooBar2a'
        nested: [
          body: 'NestedFooBar2a'
        ]
        body: 'FooBar2a'
      ,
        _id: @postId3
        subdocument:
          body: 'SubdocumentFooBar3a'
        nested: [
          body: 'NestedFooBar3a'
        ]
        body: 'FooBar3a'
      ,
        _id: @postId4
        subdocument:
          body: 'SubdocumentFooBar4a'
        nested: [
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ]
        body: 'FooBar4a'
      ,
        _id: @postId5
        subdocument:
          body: 'SubdocumentFooBar5a'
        nested: [
          body: 'NestedFooBar5'
        ,
          body: 'NestedFooBar5a'
        ,
          body: 'NestedFooBar5'
        ]
        body: 'FooBar5a'
      ]
    testSetEqual test, @person1.subdocument?.posts,
      [
        _id: @postId1
        subdocument:
          body: 'SubdocumentFooBar1a'
        nested: [
          body: 'NestedFooBar1a'
        ]
        body: 'FooBar1a'
      ,
        _id: @postId3
        subdocument:
          body: 'SubdocumentFooBar3a'
        nested: [
          body: 'NestedFooBar3a'
        ]
        body: 'FooBar3a'
      ,
        _id: @postId4
        subdocument:
          body: 'SubdocumentFooBar4a'
        nested: [
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ]
        body: 'FooBar4a'
      ]
    testSetEqual test, @person1.subdocumentsPosts,
      [
        _id: @postId1
        subdocument:
          body: 'SubdocumentFooBar1a'
        nested: [
          body: 'NestedFooBar1a'
        ]
        body: 'FooBar1a'
      ,
        _id: @postId2
        subdocument:
          body: 'SubdocumentFooBar2a'
        nested: [
          body: 'NestedFooBar2a'
        ]
        body: 'FooBar2a'
      ,
        _id: @postId3
        subdocument:
          body: 'SubdocumentFooBar3a'
        nested: [
          body: 'NestedFooBar3a'
        ]
        body: 'FooBar3a'
      ,
        _id: @postId4
        subdocument:
          body: 'SubdocumentFooBar4a'
        nested: [
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ]
        body: 'FooBar4a'
      ]
    testSetEqual test, @person1.nestedPosts,
      [
        _id: @postId4
        subdocument:
          body: 'SubdocumentFooBar4a'
        nested: [
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ]
        body: 'FooBar4a'
      ]

    test.equal _.omit(@person2, 'posts', 'subdocument', 'subdocumentsPosts', 'nestedPosts'),
      _id: @person2Id
      username: 'person2'
      displayName: 'Person 2'
      count: 8

    testSetEqual test, @person2.posts, []
    testSetEqual test, @person2.subdocument?.posts,
      [
        _id: @postId2
        subdocument:
          body: 'SubdocumentFooBar2a'
        nested: [
          body: 'NestedFooBar2a'
        ]
        body: 'FooBar2a'
      ]
    testSetEqual test, @person2.subdocumentsPosts,
      [
        _id: @postId1
        subdocument:
          body: 'SubdocumentFooBar1a'
        nested: [
          body: 'NestedFooBar1a'
        ]
        body: 'FooBar1a'
      ,
        _id: @postId2
        subdocument:
          body: 'SubdocumentFooBar2a'
        nested: [
          body: 'NestedFooBar2a'
        ]
        body: 'FooBar2a'
      ,
        _id: @postId3
        subdocument:
          body: 'SubdocumentFooBar3a'
        nested: [
          body: 'NestedFooBar3a'
        ]
        body: 'FooBar3a'
      ,
        _id: @postId4
        subdocument:
          body: 'SubdocumentFooBar4a'
        nested: [
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ]
        body: 'FooBar4a'
      ,
        _id: @postId5
        subdocument:
          body: 'SubdocumentFooBar5a'
        nested: [
          body: 'NestedFooBar5'
        ,
          body: 'NestedFooBar5a'
        ,
          body: 'NestedFooBar5'
        ]
        body: 'FooBar5a'
      ]
    testSetEqual test, @person2.nestedPosts,
      [
        _id: @postId1
        subdocument:
          body: 'SubdocumentFooBar1a'
        nested: [
          body: 'NestedFooBar1a'
        ]
        body: 'FooBar1a'
      ,
        _id: @postId4
        subdocument:
          body: 'SubdocumentFooBar4a'
        nested: [
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ]
        body: 'FooBar4a'
      ]

    test.equal _.omit(@person3, 'posts', 'subdocument', 'subdocumentsPosts', 'nestedPosts'),
      _id: @person3Id
      username: 'person3'
      displayName: 'Person 3'
      count: 9

    testSetEqual test, @person3.posts, []
    testSetEqual test, @person3.subdocument?.posts,
      [
        _id: @postId5
        subdocument:
          body: 'SubdocumentFooBar5a'
        nested: [
          body: 'NestedFooBar5'
        ,
          body: 'NestedFooBar5a'
        ,
          body: 'NestedFooBar5'
        ]
        body: 'FooBar5a'
      ]
    testSetEqual test, @person3.subdocumentsPosts,
      [
        _id: @postId1
        subdocument:
          body: 'SubdocumentFooBar1a'
        nested: [
          body: 'NestedFooBar1a'
        ]
        body: 'FooBar1a'
      ,
        _id: @postId2
        subdocument:
          body: 'SubdocumentFooBar2a'
        nested: [
          body: 'NestedFooBar2a'
        ]
        body: 'FooBar2a'
      ,
        _id: @postId3
        subdocument:
          body: 'SubdocumentFooBar3a'
        nested: [
          body: 'NestedFooBar3a'
        ]
        body: 'FooBar3a'
      ,
        _id: @postId5
        subdocument:
          body: 'SubdocumentFooBar5a'
        nested: [
          body: 'NestedFooBar5'
        ,
          body: 'NestedFooBar5a'
        ,
          body: 'NestedFooBar5'
        ]
        body: 'FooBar5a'
      ]
    testSetEqual test, @person3.nestedPosts,
      [
        _id: @postId2
        subdocument:
          body: 'SubdocumentFooBar2a'
        nested: [
          body: 'NestedFooBar2a'
        ]
        body: 'FooBar2a'
      ,
        _id: @postId3
        subdocument:
          body: 'SubdocumentFooBar3a'
        nested: [
          body: 'NestedFooBar3a'
        ]
        body: 'FooBar3a'
      ,
        _id: @postId4
        subdocument:
          body: 'SubdocumentFooBar4a'
        nested: [
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ]
        body: 'FooBar4a'
      ,
        _id: @postId5
        subdocument:
          body: 'SubdocumentFooBar5a'
        nested: [
          body: 'NestedFooBar5'
        ,
          body: 'NestedFooBar5a'
        ,
          body: 'NestedFooBar5'
        ]
        body: 'FooBar5a'
      ]

    Post.documents.update @postId5,
      $set:
        'nested.0.required._id': @person2Id
    ,
      expect (error, res) =>
        test.isFalse error, error?.toString?() or error
        test.isTrue res

    # Wait so that observers have time to update documents
    waitForDatabase test, expect
,
  (test, expect) ->
    @post5 = Post.documents.findOne @postId5,
      transform: null # So that we can use test.equal

    test.equal @post5,
      _id: @postId5
      author:
        _id: @person1Id
        username: 'person1'
        displayName: 'Person 1'
      subdocument:
        person:
          _id: @person3Id
          displayName: 'Person 3'
          username: 'person3'
        persons: [
          _id: @person3Id
          displayName: 'Person 3'
          username: 'person3'
        ,
          _id: @person3Id
          displayName: 'Person 3'
          username: 'person3'
        ,
          _id: @person3Id
          displayName: 'Person 3'
          username: 'person3'
        ,
          _id: @person3Id
          displayName: 'Person 3'
          username: 'person3'
        ,
          _id: @person2Id
          displayName: 'Person 2'
          username: 'person2'
        ,
          _id: @person3Id
          displayName: 'Person 3'
          username: 'person3'
        ]
        slug: 'subdocument-prefix-foobar5a-subdocumentfoobar5a-suffix'
        body: 'SubdocumentFooBar5a'
      nested: [
        required:
          _id: @person2Id
          username: 'person2'
          displayName: 'Person 2'
        slug: 'nested-prefix-foobar5a-nestedfoobar5-suffix'
        body: 'NestedFooBar5'
      ,
        required:
          _id: @person3Id
          username: 'person3'
          displayName: 'Person 3'
        slug: 'nested-prefix-foobar5a-nestedfoobar5a-suffix'
        body: 'NestedFooBar5a'
      ,
        required:
          _id: @person3Id
          username: 'person3'
          displayName: 'Person 3'
        slug: 'nested-prefix-foobar5a-nestedfoobar5-suffix'
        body: 'NestedFooBar5'
      ]
      body: 'FooBar5a'
      slug: 'prefix-foobar5a-subdocumentfoobar5a-suffix'
      tags: [
        'tag-0-prefix-foobar5a-subdocumentfoobar5a-suffix'
        'tag-1-prefix-foobar5a-nestedfoobar5-suffix'
        'tag-2-prefix-foobar5a-nestedfoobar5a-suffix'
        'tag-3-prefix-foobar5a-nestedfoobar5-suffix'
      ]

    @person1 = Person.documents.findOne @person1Id,
      transform: null # So that we can use test.equal
    @person2 = Person.documents.findOne @person2Id,
      transform: null # So that we can use test.equal
    @person3 = Person.documents.findOne @person3Id,
      transform: null # So that we can use test.equal

    test.equal _.omit(@person1, 'posts', 'subdocument', 'subdocumentsPosts', 'nestedPosts'),
      _id: @person1Id
      username: 'person1'
      displayName: 'Person 1'
      count: 13

    testSetEqual test, @person1.posts,
      [
        _id: @postId1
        subdocument:
          body: 'SubdocumentFooBar1a'
        nested: [
          body: 'NestedFooBar1a'
        ]
        body: 'FooBar1a'
      ,
        _id: @postId2
        subdocument:
          body: 'SubdocumentFooBar2a'
        nested: [
          body: 'NestedFooBar2a'
        ]
        body: 'FooBar2a'
      ,
        _id: @postId3
        subdocument:
          body: 'SubdocumentFooBar3a'
        nested: [
          body: 'NestedFooBar3a'
        ]
        body: 'FooBar3a'
      ,
        _id: @postId4
        subdocument:
          body: 'SubdocumentFooBar4a'
        nested: [
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ]
        body: 'FooBar4a'
      ,
        _id: @postId5
        subdocument:
          body: 'SubdocumentFooBar5a'
        nested: [
          body: 'NestedFooBar5'
        ,
          body: 'NestedFooBar5a'
        ,
          body: 'NestedFooBar5'
        ]
        body: 'FooBar5a'
      ]
    testSetEqual test, @person1.subdocument?.posts,
      [
        _id: @postId1
        subdocument:
          body: 'SubdocumentFooBar1a'
        nested: [
          body: 'NestedFooBar1a'
        ]
        body: 'FooBar1a'
      ,
        _id: @postId3
        subdocument:
          body: 'SubdocumentFooBar3a'
        nested: [
          body: 'NestedFooBar3a'
        ]
        body: 'FooBar3a'
      ,
        _id: @postId4
        subdocument:
          body: 'SubdocumentFooBar4a'
        nested: [
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ]
        body: 'FooBar4a'
      ]
    testSetEqual test, @person1.subdocumentsPosts,
      [
        _id: @postId1
        subdocument:
          body: 'SubdocumentFooBar1a'
        nested: [
          body: 'NestedFooBar1a'
        ]
        body: 'FooBar1a'
      ,
        _id: @postId2
        subdocument:
          body: 'SubdocumentFooBar2a'
        nested: [
          body: 'NestedFooBar2a'
        ]
        body: 'FooBar2a'
      ,
        _id: @postId3
        subdocument:
          body: 'SubdocumentFooBar3a'
        nested: [
          body: 'NestedFooBar3a'
        ]
        body: 'FooBar3a'
      ,
        _id: @postId4
        subdocument:
          body: 'SubdocumentFooBar4a'
        nested: [
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ]
        body: 'FooBar4a'
      ]
    testSetEqual test, @person1.nestedPosts,
      [
        _id: @postId4
        subdocument:
          body: 'SubdocumentFooBar4a'
        nested: [
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ]
        body: 'FooBar4a'
      ]

    test.equal _.omit(@person2, 'posts', 'subdocument', 'subdocumentsPosts', 'nestedPosts'),
      _id: @person2Id
      username: 'person2'
      displayName: 'Person 2'
      count: 9

    testSetEqual test, @person2.posts, []
    testSetEqual test, @person2.subdocument?.posts,
      [
        _id: @postId2
        subdocument:
          body: 'SubdocumentFooBar2a'
        nested: [
          body: 'NestedFooBar2a'
        ]
        body: 'FooBar2a'
      ]
    testSetEqual test, @person2.subdocumentsPosts,
      [
        _id: @postId1
        subdocument:
          body: 'SubdocumentFooBar1a'
        nested: [
          body: 'NestedFooBar1a'
        ]
        body: 'FooBar1a'
      ,
        _id: @postId2
        subdocument:
          body: 'SubdocumentFooBar2a'
        nested: [
          body: 'NestedFooBar2a'
        ]
        body: 'FooBar2a'
      ,
        _id: @postId3
        subdocument:
          body: 'SubdocumentFooBar3a'
        nested: [
          body: 'NestedFooBar3a'
        ]
        body: 'FooBar3a'
      ,
        _id: @postId4
        subdocument:
          body: 'SubdocumentFooBar4a'
        nested: [
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ]
        body: 'FooBar4a'
      ,
        _id: @postId5
        subdocument:
          body: 'SubdocumentFooBar5a'
        nested: [
          body: 'NestedFooBar5'
        ,
          body: 'NestedFooBar5a'
        ,
          body: 'NestedFooBar5'
        ]
        body: 'FooBar5a'
      ]
    testSetEqual test, @person2.nestedPosts,
      [
        _id: @postId1
        subdocument:
          body: 'SubdocumentFooBar1a'
        nested: [
          body: 'NestedFooBar1a'
        ]
        body: 'FooBar1a'
      ,
        _id: @postId4
        subdocument:
          body: 'SubdocumentFooBar4a'
        nested: [
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ]
        body: 'FooBar4a'
      ,
        _id: @postId5
        subdocument:
          body: 'SubdocumentFooBar5a'
        nested: [
          body: 'NestedFooBar5'
        ,
          body: 'NestedFooBar5a'
        ,
          body: 'NestedFooBar5'
        ]
        body: 'FooBar5a'
      ]

    test.equal _.omit(@person3, 'posts', 'subdocument', 'subdocumentsPosts', 'nestedPosts'),
      _id: @person3Id
      username: 'person3'
      displayName: 'Person 3'
      count: 9

    testSetEqual test, @person3.posts, []
    testSetEqual test, @person3.subdocument?.posts,
      [
        _id: @postId5
        subdocument:
          body: 'SubdocumentFooBar5a'
        nested: [
          body: 'NestedFooBar5'
        ,
          body: 'NestedFooBar5a'
        ,
          body: 'NestedFooBar5'
        ]
        body: 'FooBar5a'
      ]
    testSetEqual test, @person3.subdocumentsPosts,
      [
        _id: @postId1
        subdocument:
          body: 'SubdocumentFooBar1a'
        nested: [
          body: 'NestedFooBar1a'
        ]
        body: 'FooBar1a'
      ,
        _id: @postId2
        subdocument:
          body: 'SubdocumentFooBar2a'
        nested: [
          body: 'NestedFooBar2a'
        ]
        body: 'FooBar2a'
      ,
        _id: @postId3
        subdocument:
          body: 'SubdocumentFooBar3a'
        nested: [
          body: 'NestedFooBar3a'
        ]
        body: 'FooBar3a'
      ,
        _id: @postId5
        subdocument:
          body: 'SubdocumentFooBar5a'
        nested: [
          body: 'NestedFooBar5'
        ,
          body: 'NestedFooBar5a'
        ,
          body: 'NestedFooBar5'
        ]
        body: 'FooBar5a'
      ]
    testSetEqual test, @person3.nestedPosts,
      [
        _id: @postId2
        subdocument:
          body: 'SubdocumentFooBar2a'
        nested: [
          body: 'NestedFooBar2a'
        ]
        body: 'FooBar2a'
      ,
        _id: @postId3
        subdocument:
          body: 'SubdocumentFooBar3a'
        nested: [
          body: 'NestedFooBar3a'
        ]
        body: 'FooBar3a'
      ,
        _id: @postId4
        subdocument:
          body: 'SubdocumentFooBar4a'
        nested: [
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ]
        body: 'FooBar4a'
      ,
        _id: @postId5
        subdocument:
          body: 'SubdocumentFooBar5a'
        nested: [
          body: 'NestedFooBar5'
        ,
          body: 'NestedFooBar5a'
        ,
          body: 'NestedFooBar5'
        ]
        body: 'FooBar5a'
      ]

    Post.documents.update @postId5,
      $set:
        'nested.0.required._id': @person3Id
    ,
      expect (error, res) =>
        test.isFalse error, error?.toString?() or error
        test.isTrue res

    # Wait so that observers have time to update documents
    waitForDatabase test, expect
,
  (test, expect) ->
    @post5 = Post.documents.findOne @postId5,
      transform: null # So that we can use test.equal

    test.equal @post5,
      _id: @postId5
      author:
        _id: @person1Id
        username: 'person1'
        displayName: 'Person 1'
      subdocument:
        person:
          _id: @person3Id
          displayName: 'Person 3'
          username: 'person3'
        persons: [
          _id: @person3Id
          displayName: 'Person 3'
          username: 'person3'
        ,
          _id: @person3Id
          displayName: 'Person 3'
          username: 'person3'
        ,
          _id: @person3Id
          displayName: 'Person 3'
          username: 'person3'
        ,
          _id: @person3Id
          displayName: 'Person 3'
          username: 'person3'
        ,
          _id: @person2Id
          displayName: 'Person 2'
          username: 'person2'
        ,
          _id: @person3Id
          displayName: 'Person 3'
          username: 'person3'
        ]
        slug: 'subdocument-prefix-foobar5a-subdocumentfoobar5a-suffix'
        body: 'SubdocumentFooBar5a'
      nested: [
        required:
          _id: @person3Id
          username: 'person3'
          displayName: 'Person 3'
        slug: 'nested-prefix-foobar5a-nestedfoobar5-suffix'
        body: 'NestedFooBar5'
      ,
        required:
          _id: @person3Id
          username: 'person3'
          displayName: 'Person 3'
        slug: 'nested-prefix-foobar5a-nestedfoobar5a-suffix'
        body: 'NestedFooBar5a'
      ,
        required:
          _id: @person3Id
          username: 'person3'
          displayName: 'Person 3'
        slug: 'nested-prefix-foobar5a-nestedfoobar5-suffix'
        body: 'NestedFooBar5'
      ]
      body: 'FooBar5a'
      slug: 'prefix-foobar5a-subdocumentfoobar5a-suffix'
      tags: [
        'tag-0-prefix-foobar5a-subdocumentfoobar5a-suffix'
        'tag-1-prefix-foobar5a-nestedfoobar5-suffix'
        'tag-2-prefix-foobar5a-nestedfoobar5a-suffix'
        'tag-3-prefix-foobar5a-nestedfoobar5-suffix'
      ]

    @person1 = Person.documents.findOne @person1Id,
      transform: null # So that we can use test.equal
    @person2 = Person.documents.findOne @person2Id,
      transform: null # So that we can use test.equal
    @person3 = Person.documents.findOne @person3Id,
      transform: null # So that we can use test.equal

    test.equal _.omit(@person1, 'posts', 'subdocument', 'subdocumentsPosts', 'nestedPosts'),
      _id: @person1Id
      username: 'person1'
      displayName: 'Person 1'
      count: 13

    testSetEqual test, @person1.posts,
      [
        _id: @postId1
        subdocument:
          body: 'SubdocumentFooBar1a'
        nested: [
          body: 'NestedFooBar1a'
        ]
        body: 'FooBar1a'
      ,
        _id: @postId2
        subdocument:
          body: 'SubdocumentFooBar2a'
        nested: [
          body: 'NestedFooBar2a'
        ]
        body: 'FooBar2a'
      ,
        _id: @postId3
        subdocument:
          body: 'SubdocumentFooBar3a'
        nested: [
          body: 'NestedFooBar3a'
        ]
        body: 'FooBar3a'
      ,
        _id: @postId4
        subdocument:
          body: 'SubdocumentFooBar4a'
        nested: [
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ]
        body: 'FooBar4a'
      ,
        _id: @postId5
        subdocument:
          body: 'SubdocumentFooBar5a'
        nested: [
          body: 'NestedFooBar5'
        ,
          body: 'NestedFooBar5a'
        ,
          body: 'NestedFooBar5'
        ]
        body: 'FooBar5a'
      ]
    testSetEqual test, @person1.subdocument?.posts,
      [
        _id: @postId1
        subdocument:
          body: 'SubdocumentFooBar1a'
        nested: [
          body: 'NestedFooBar1a'
        ]
        body: 'FooBar1a'
      ,
        _id: @postId3
        subdocument:
          body: 'SubdocumentFooBar3a'
        nested: [
          body: 'NestedFooBar3a'
        ]
        body: 'FooBar3a'
      ,
        _id: @postId4
        subdocument:
          body: 'SubdocumentFooBar4a'
        nested: [
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ]
        body: 'FooBar4a'
      ]
    testSetEqual test, @person1.subdocumentsPosts,
      [
        _id: @postId1
        subdocument:
          body: 'SubdocumentFooBar1a'
        nested: [
          body: 'NestedFooBar1a'
        ]
        body: 'FooBar1a'
      ,
        _id: @postId2
        subdocument:
          body: 'SubdocumentFooBar2a'
        nested: [
          body: 'NestedFooBar2a'
        ]
        body: 'FooBar2a'
      ,
        _id: @postId3
        subdocument:
          body: 'SubdocumentFooBar3a'
        nested: [
          body: 'NestedFooBar3a'
        ]
        body: 'FooBar3a'
      ,
        _id: @postId4
        subdocument:
          body: 'SubdocumentFooBar4a'
        nested: [
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ]
        body: 'FooBar4a'
      ]
    testSetEqual test, @person1.nestedPosts,
      [
        _id: @postId4
        subdocument:
          body: 'SubdocumentFooBar4a'
        nested: [
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ]
        body: 'FooBar4a'
      ]

    test.equal _.omit(@person2, 'posts', 'subdocument', 'subdocumentsPosts', 'nestedPosts'),
      _id: @person2Id
      username: 'person2'
      displayName: 'Person 2'
      count: 8

    testSetEqual test, @person2.posts, []
    testSetEqual test, @person2.subdocument?.posts,
      [
        _id: @postId2
        subdocument:
          body: 'SubdocumentFooBar2a'
        nested: [
          body: 'NestedFooBar2a'
        ]
        body: 'FooBar2a'
      ]
    testSetEqual test, @person2.subdocumentsPosts,
      [
        _id: @postId1
        subdocument:
          body: 'SubdocumentFooBar1a'
        nested: [
          body: 'NestedFooBar1a'
        ]
        body: 'FooBar1a'
      ,
        _id: @postId2
        subdocument:
          body: 'SubdocumentFooBar2a'
        nested: [
          body: 'NestedFooBar2a'
        ]
        body: 'FooBar2a'
      ,
        _id: @postId3
        subdocument:
          body: 'SubdocumentFooBar3a'
        nested: [
          body: 'NestedFooBar3a'
        ]
        body: 'FooBar3a'
      ,
        _id: @postId4
        subdocument:
          body: 'SubdocumentFooBar4a'
        nested: [
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ]
        body: 'FooBar4a'
      ,
        _id: @postId5
        subdocument:
          body: 'SubdocumentFooBar5a'
        nested: [
          body: 'NestedFooBar5'
        ,
          body: 'NestedFooBar5a'
        ,
          body: 'NestedFooBar5'
        ]
        body: 'FooBar5a'
      ]
    testSetEqual test, @person2.nestedPosts,
      [
        _id: @postId1
        subdocument:
          body: 'SubdocumentFooBar1a'
        nested: [
          body: 'NestedFooBar1a'
        ]
        body: 'FooBar1a'
      ,
        _id: @postId4
        subdocument:
          body: 'SubdocumentFooBar4a'
        nested: [
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ]
        body: 'FooBar4a'
      ]

    test.equal _.omit(@person3, 'posts', 'subdocument', 'subdocumentsPosts', 'nestedPosts'),
      _id: @person3Id
      username: 'person3'
      displayName: 'Person 3'
      count: 9

    testSetEqual test, @person3.posts, []
    testSetEqual test, @person3.subdocument?.posts,
      [
        _id: @postId5
        subdocument:
          body: 'SubdocumentFooBar5a'
        nested: [
          body: 'NestedFooBar5'
        ,
          body: 'NestedFooBar5a'
        ,
          body: 'NestedFooBar5'
        ]
        body: 'FooBar5a'
      ]
    testSetEqual test, @person3.subdocumentsPosts,
      [
        _id: @postId1
        subdocument:
          body: 'SubdocumentFooBar1a'
        nested: [
          body: 'NestedFooBar1a'
        ]
        body: 'FooBar1a'
      ,
        _id: @postId2
        subdocument:
          body: 'SubdocumentFooBar2a'
        nested: [
          body: 'NestedFooBar2a'
        ]
        body: 'FooBar2a'
      ,
        _id: @postId3
        subdocument:
          body: 'SubdocumentFooBar3a'
        nested: [
          body: 'NestedFooBar3a'
        ]
        body: 'FooBar3a'
      ,
        _id: @postId5
        subdocument:
          body: 'SubdocumentFooBar5a'
        nested: [
          body: 'NestedFooBar5'
        ,
          body: 'NestedFooBar5a'
        ,
          body: 'NestedFooBar5'
        ]
        body: 'FooBar5a'
      ]
    testSetEqual test, @person3.nestedPosts,
      [
        _id: @postId2
        subdocument:
          body: 'SubdocumentFooBar2a'
        nested: [
          body: 'NestedFooBar2a'
        ]
        body: 'FooBar2a'
      ,
        _id: @postId3
        subdocument:
          body: 'SubdocumentFooBar3a'
        nested: [
          body: 'NestedFooBar3a'
        ]
        body: 'FooBar3a'
      ,
        _id: @postId4
        subdocument:
          body: 'SubdocumentFooBar4a'
        nested: [
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ]
        body: 'FooBar4a'
      ,
        _id: @postId5
        subdocument:
          body: 'SubdocumentFooBar5a'
        nested: [
          body: 'NestedFooBar5'
        ,
          body: 'NestedFooBar5a'
        ,
          body: 'NestedFooBar5'
        ]
        body: 'FooBar5a'
      ]

    Post.documents.update @postId5,
      $push:
        'subdocument.persons':
          _id: @person1Id
    ,
      expect (error, res) =>
        test.isFalse error, error?.toString?() or error
        test.isTrue res

    # Wait so that observers have time to update documents
    waitForDatabase test, expect
,
  (test, expect) ->
    @post5 = Post.documents.findOne @postId5,
      transform: null # So that we can use test.equal

    test.equal @post5,
      _id: @postId5
      author:
        _id: @person1Id
        username: 'person1'
        displayName: 'Person 1'
      subdocument:
        person:
          _id: @person3Id
          displayName: 'Person 3'
          username: 'person3'
        persons: [
          _id: @person3Id
          displayName: 'Person 3'
          username: 'person3'
        ,
          _id: @person3Id
          displayName: 'Person 3'
          username: 'person3'
        ,
          _id: @person3Id
          displayName: 'Person 3'
          username: 'person3'
        ,
          _id: @person3Id
          displayName: 'Person 3'
          username: 'person3'
        ,
          _id: @person2Id
          displayName: 'Person 2'
          username: 'person2'
        ,
          _id: @person3Id
          displayName: 'Person 3'
          username: 'person3'
        ,
          _id: @person1Id
          displayName: 'Person 1'
          username: 'person1'
        ]
        slug: 'subdocument-prefix-foobar5a-subdocumentfoobar5a-suffix'
        body: 'SubdocumentFooBar5a'
      nested: [
        required:
          _id: @person3Id
          username: 'person3'
          displayName: 'Person 3'
        slug: 'nested-prefix-foobar5a-nestedfoobar5-suffix'
        body: 'NestedFooBar5'
      ,
        required:
          _id: @person3Id
          username: 'person3'
          displayName: 'Person 3'
        slug: 'nested-prefix-foobar5a-nestedfoobar5a-suffix'
        body: 'NestedFooBar5a'
      ,
        required:
          _id: @person3Id
          username: 'person3'
          displayName: 'Person 3'
        slug: 'nested-prefix-foobar5a-nestedfoobar5-suffix'
        body: 'NestedFooBar5'
      ]
      body: 'FooBar5a'
      slug: 'prefix-foobar5a-subdocumentfoobar5a-suffix'
      tags: [
        'tag-0-prefix-foobar5a-subdocumentfoobar5a-suffix'
        'tag-1-prefix-foobar5a-nestedfoobar5-suffix'
        'tag-2-prefix-foobar5a-nestedfoobar5a-suffix'
        'tag-3-prefix-foobar5a-nestedfoobar5-suffix'
      ]

    @person1 = Person.documents.findOne @person1Id,
      transform: null # So that we can use test.equal
    @person2 = Person.documents.findOne @person2Id,
      transform: null # So that we can use test.equal
    @person3 = Person.documents.findOne @person3Id,
      transform: null # So that we can use test.equal

    test.equal _.omit(@person1, 'posts', 'subdocument', 'subdocumentsPosts', 'nestedPosts'),
      _id: @person1Id
      username: 'person1'
      displayName: 'Person 1'
      count: 14

    testSetEqual test, @person1.posts,
      [
        _id: @postId1
        subdocument:
          body: 'SubdocumentFooBar1a'
        nested: [
          body: 'NestedFooBar1a'
        ]
        body: 'FooBar1a'
      ,
        _id: @postId2
        subdocument:
          body: 'SubdocumentFooBar2a'
        nested: [
          body: 'NestedFooBar2a'
        ]
        body: 'FooBar2a'
      ,
        _id: @postId3
        subdocument:
          body: 'SubdocumentFooBar3a'
        nested: [
          body: 'NestedFooBar3a'
        ]
        body: 'FooBar3a'
      ,
        _id: @postId4
        subdocument:
          body: 'SubdocumentFooBar4a'
        nested: [
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ]
        body: 'FooBar4a'
      ,
        _id: @postId5
        subdocument:
          body: 'SubdocumentFooBar5a'
        nested: [
          body: 'NestedFooBar5'
        ,
          body: 'NestedFooBar5a'
        ,
          body: 'NestedFooBar5'
        ]
        body: 'FooBar5a'
      ]
    testSetEqual test, @person1.subdocument?.posts,
      [
        _id: @postId1
        subdocument:
          body: 'SubdocumentFooBar1a'
        nested: [
          body: 'NestedFooBar1a'
        ]
        body: 'FooBar1a'
      ,
        _id: @postId3
        subdocument:
          body: 'SubdocumentFooBar3a'
        nested: [
          body: 'NestedFooBar3a'
        ]
        body: 'FooBar3a'
      ,
        _id: @postId4
        subdocument:
          body: 'SubdocumentFooBar4a'
        nested: [
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ]
        body: 'FooBar4a'
      ]
    testSetEqual test, @person1.subdocumentsPosts,
      [
        _id: @postId1
        subdocument:
          body: 'SubdocumentFooBar1a'
        nested: [
          body: 'NestedFooBar1a'
        ]
        body: 'FooBar1a'
      ,
        _id: @postId2
        subdocument:
          body: 'SubdocumentFooBar2a'
        nested: [
          body: 'NestedFooBar2a'
        ]
        body: 'FooBar2a'
      ,
        _id: @postId3
        subdocument:
          body: 'SubdocumentFooBar3a'
        nested: [
          body: 'NestedFooBar3a'
        ]
        body: 'FooBar3a'
      ,
        _id: @postId4
        subdocument:
          body: 'SubdocumentFooBar4a'
        nested: [
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ]
        body: 'FooBar4a'
      ,
        _id: @postId5
        subdocument:
          body: 'SubdocumentFooBar5a'
        nested: [
          body: 'NestedFooBar5'
        ,
          body: 'NestedFooBar5a'
        ,
          body: 'NestedFooBar5'
        ]
        body: 'FooBar5a'
      ]
    testSetEqual test, @person1.nestedPosts,
      [
        _id: @postId4
        subdocument:
          body: 'SubdocumentFooBar4a'
        nested: [
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ]
        body: 'FooBar4a'
      ]

    test.equal _.omit(@person2, 'posts', 'subdocument', 'subdocumentsPosts', 'nestedPosts'),
      _id: @person2Id
      username: 'person2'
      displayName: 'Person 2'
      count: 8

    testSetEqual test, @person2.posts, []
    testSetEqual test, @person2.subdocument?.posts,
      [
        _id: @postId2
        subdocument:
          body: 'SubdocumentFooBar2a'
        nested: [
          body: 'NestedFooBar2a'
        ]
        body: 'FooBar2a'
      ]
    testSetEqual test, @person2.subdocumentsPosts,
      [
        _id: @postId1
        subdocument:
          body: 'SubdocumentFooBar1a'
        nested: [
          body: 'NestedFooBar1a'
        ]
        body: 'FooBar1a'
      ,
        _id: @postId2
        subdocument:
          body: 'SubdocumentFooBar2a'
        nested: [
          body: 'NestedFooBar2a'
        ]
        body: 'FooBar2a'
      ,
        _id: @postId3
        subdocument:
          body: 'SubdocumentFooBar3a'
        nested: [
          body: 'NestedFooBar3a'
        ]
        body: 'FooBar3a'
      ,
        _id: @postId4
        subdocument:
          body: 'SubdocumentFooBar4a'
        nested: [
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ]
        body: 'FooBar4a'
      ,
        _id: @postId5
        subdocument:
          body: 'SubdocumentFooBar5a'
        nested: [
          body: 'NestedFooBar5'
        ,
          body: 'NestedFooBar5a'
        ,
          body: 'NestedFooBar5'
        ]
        body: 'FooBar5a'
      ]
    testSetEqual test, @person2.nestedPosts,
      [
        _id: @postId1
        subdocument:
          body: 'SubdocumentFooBar1a'
        nested: [
          body: 'NestedFooBar1a'
        ]
        body: 'FooBar1a'
      ,
        _id: @postId4
        subdocument:
          body: 'SubdocumentFooBar4a'
        nested: [
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ]
        body: 'FooBar4a'
      ]

    test.equal _.omit(@person3, 'posts', 'subdocument', 'subdocumentsPosts', 'nestedPosts'),
      _id: @person3Id
      username: 'person3'
      displayName: 'Person 3'
      count: 9

    testSetEqual test, @person3.posts, []
    testSetEqual test, @person3.subdocument?.posts,
      [
        _id: @postId5
        subdocument:
          body: 'SubdocumentFooBar5a'
        nested: [
          body: 'NestedFooBar5'
        ,
          body: 'NestedFooBar5a'
        ,
          body: 'NestedFooBar5'
        ]
        body: 'FooBar5a'
      ]
    testSetEqual test, @person3.subdocumentsPosts,
      [
        _id: @postId1
        subdocument:
          body: 'SubdocumentFooBar1a'
        nested: [
          body: 'NestedFooBar1a'
        ]
        body: 'FooBar1a'
      ,
        _id: @postId2
        subdocument:
          body: 'SubdocumentFooBar2a'
        nested: [
          body: 'NestedFooBar2a'
        ]
        body: 'FooBar2a'
      ,
        _id: @postId3
        subdocument:
          body: 'SubdocumentFooBar3a'
        nested: [
          body: 'NestedFooBar3a'
        ]
        body: 'FooBar3a'
      ,
        _id: @postId5
        subdocument:
          body: 'SubdocumentFooBar5a'
        nested: [
          body: 'NestedFooBar5'
        ,
          body: 'NestedFooBar5a'
        ,
          body: 'NestedFooBar5'
        ]
        body: 'FooBar5a'
      ]
    testSetEqual test, @person3.nestedPosts,
      [
        _id: @postId2
        subdocument:
          body: 'SubdocumentFooBar2a'
        nested: [
          body: 'NestedFooBar2a'
        ]
        body: 'FooBar2a'
      ,
        _id: @postId3
        subdocument:
          body: 'SubdocumentFooBar3a'
        nested: [
          body: 'NestedFooBar3a'
        ]
        body: 'FooBar3a'
      ,
        _id: @postId4
        subdocument:
          body: 'SubdocumentFooBar4a'
        nested: [
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ]
        body: 'FooBar4a'
      ,
        _id: @postId5
        subdocument:
          body: 'SubdocumentFooBar5a'
        nested: [
          body: 'NestedFooBar5'
        ,
          body: 'NestedFooBar5a'
        ,
          body: 'NestedFooBar5'
        ]
        body: 'FooBar5a'
      ]

    Post.documents.update @postId5,
      $pop:
        'subdocument.persons': 1
    ,
      expect (error, res) =>
        test.isFalse error, error?.toString?() or error
        test.isTrue res

    # Wait so that observers have time to update documents
    waitForDatabase test, expect
,
  (test, expect) ->
    @post5 = Post.documents.findOne @postId5,
      transform: null # So that we can use test.equal

    test.equal @post5,
      _id: @postId5
      author:
        _id: @person1Id
        username: 'person1'
        displayName: 'Person 1'
      subdocument:
        person:
          _id: @person3Id
          displayName: 'Person 3'
          username: 'person3'
        persons: [
          _id: @person3Id
          displayName: 'Person 3'
          username: 'person3'
        ,
          _id: @person3Id
          displayName: 'Person 3'
          username: 'person3'
        ,
          _id: @person3Id
          displayName: 'Person 3'
          username: 'person3'
        ,
          _id: @person3Id
          displayName: 'Person 3'
          username: 'person3'
        ,
          _id: @person2Id
          displayName: 'Person 2'
          username: 'person2'
        ,
          _id: @person3Id
          displayName: 'Person 3'
          username: 'person3'
        ]
        slug: 'subdocument-prefix-foobar5a-subdocumentfoobar5a-suffix'
        body: 'SubdocumentFooBar5a'
      nested: [
        required:
          _id: @person3Id
          username: 'person3'
          displayName: 'Person 3'
        slug: 'nested-prefix-foobar5a-nestedfoobar5-suffix'
        body: 'NestedFooBar5'
      ,
        required:
          _id: @person3Id
          username: 'person3'
          displayName: 'Person 3'
        slug: 'nested-prefix-foobar5a-nestedfoobar5a-suffix'
        body: 'NestedFooBar5a'
      ,
        required:
          _id: @person3Id
          username: 'person3'
          displayName: 'Person 3'
        slug: 'nested-prefix-foobar5a-nestedfoobar5-suffix'
        body: 'NestedFooBar5'
      ]
      body: 'FooBar5a'
      slug: 'prefix-foobar5a-subdocumentfoobar5a-suffix'
      tags: [
        'tag-0-prefix-foobar5a-subdocumentfoobar5a-suffix'
        'tag-1-prefix-foobar5a-nestedfoobar5-suffix'
        'tag-2-prefix-foobar5a-nestedfoobar5a-suffix'
        'tag-3-prefix-foobar5a-nestedfoobar5-suffix'
      ]

    @person1 = Person.documents.findOne @person1Id,
      transform: null # So that we can use test.equal
    @person2 = Person.documents.findOne @person2Id,
      transform: null # So that we can use test.equal
    @person3 = Person.documents.findOne @person3Id,
      transform: null # So that we can use test.equal

    test.equal _.omit(@person1, 'posts', 'subdocument', 'subdocumentsPosts', 'nestedPosts'),
      _id: @person1Id
      username: 'person1'
      displayName: 'Person 1'
      count: 13

    testSetEqual test, @person1.posts,
      [
        _id: @postId1
        subdocument:
          body: 'SubdocumentFooBar1a'
        nested: [
          body: 'NestedFooBar1a'
        ]
        body: 'FooBar1a'
      ,
        _id: @postId2
        subdocument:
          body: 'SubdocumentFooBar2a'
        nested: [
          body: 'NestedFooBar2a'
        ]
        body: 'FooBar2a'
      ,
        _id: @postId3
        subdocument:
          body: 'SubdocumentFooBar3a'
        nested: [
          body: 'NestedFooBar3a'
        ]
        body: 'FooBar3a'
      ,
        _id: @postId4
        subdocument:
          body: 'SubdocumentFooBar4a'
        nested: [
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ]
        body: 'FooBar4a'
      ,
        _id: @postId5
        subdocument:
          body: 'SubdocumentFooBar5a'
        nested: [
          body: 'NestedFooBar5'
        ,
          body: 'NestedFooBar5a'
        ,
          body: 'NestedFooBar5'
        ]
        body: 'FooBar5a'
      ]
    testSetEqual test, @person1.subdocument?.posts,
      [
        _id: @postId1
        subdocument:
          body: 'SubdocumentFooBar1a'
        nested: [
          body: 'NestedFooBar1a'
        ]
        body: 'FooBar1a'
      ,
        _id: @postId3
        subdocument:
          body: 'SubdocumentFooBar3a'
        nested: [
          body: 'NestedFooBar3a'
        ]
        body: 'FooBar3a'
      ,
        _id: @postId4
        subdocument:
          body: 'SubdocumentFooBar4a'
        nested: [
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ]
        body: 'FooBar4a'
      ]
    testSetEqual test, @person1.subdocumentsPosts,
      [
        _id: @postId1
        subdocument:
          body: 'SubdocumentFooBar1a'
        nested: [
          body: 'NestedFooBar1a'
        ]
        body: 'FooBar1a'
      ,
        _id: @postId2
        subdocument:
          body: 'SubdocumentFooBar2a'
        nested: [
          body: 'NestedFooBar2a'
        ]
        body: 'FooBar2a'
      ,
        _id: @postId3
        subdocument:
          body: 'SubdocumentFooBar3a'
        nested: [
          body: 'NestedFooBar3a'
        ]
        body: 'FooBar3a'
      ,
        _id: @postId4
        subdocument:
          body: 'SubdocumentFooBar4a'
        nested: [
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ]
        body: 'FooBar4a'
      ]
    testSetEqual test, @person1.nestedPosts,
      [
        _id: @postId4
        subdocument:
          body: 'SubdocumentFooBar4a'
        nested: [
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ]
        body: 'FooBar4a'
      ]

    test.equal _.omit(@person2, 'posts', 'subdocument', 'subdocumentsPosts', 'nestedPosts'),
      _id: @person2Id
      username: 'person2'
      displayName: 'Person 2'
      count: 8

    testSetEqual test, @person2.posts, []
    testSetEqual test, @person2.subdocument?.posts,
      [
        _id: @postId2
        subdocument:
          body: 'SubdocumentFooBar2a'
        nested: [
          body: 'NestedFooBar2a'
        ]
        body: 'FooBar2a'
      ]
    testSetEqual test, @person2.subdocumentsPosts,
      [
        _id: @postId1
        subdocument:
          body: 'SubdocumentFooBar1a'
        nested: [
          body: 'NestedFooBar1a'
        ]
        body: 'FooBar1a'
      ,
        _id: @postId2
        subdocument:
          body: 'SubdocumentFooBar2a'
        nested: [
          body: 'NestedFooBar2a'
        ]
        body: 'FooBar2a'
      ,
        _id: @postId3
        subdocument:
          body: 'SubdocumentFooBar3a'
        nested: [
          body: 'NestedFooBar3a'
        ]
        body: 'FooBar3a'
      ,
        _id: @postId4
        subdocument:
          body: 'SubdocumentFooBar4a'
        nested: [
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ]
        body: 'FooBar4a'
      ,
        _id: @postId5
        subdocument:
          body: 'SubdocumentFooBar5a'
        nested: [
          body: 'NestedFooBar5'
        ,
          body: 'NestedFooBar5a'
        ,
          body: 'NestedFooBar5'
        ]
        body: 'FooBar5a'
      ]
    testSetEqual test, @person2.nestedPosts,
      [
        _id: @postId1
        subdocument:
          body: 'SubdocumentFooBar1a'
        nested: [
          body: 'NestedFooBar1a'
        ]
        body: 'FooBar1a'
      ,
        _id: @postId4
        subdocument:
          body: 'SubdocumentFooBar4a'
        nested: [
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ]
        body: 'FooBar4a'
      ]

    test.equal _.omit(@person3, 'posts', 'subdocument', 'subdocumentsPosts', 'nestedPosts'),
      _id: @person3Id
      username: 'person3'
      displayName: 'Person 3'
      count: 9

    testSetEqual test, @person3.posts, []
    testSetEqual test, @person3.subdocument?.posts,
      [
        _id: @postId5
        subdocument:
          body: 'SubdocumentFooBar5a'
        nested: [
          body: 'NestedFooBar5'
        ,
          body: 'NestedFooBar5a'
        ,
          body: 'NestedFooBar5'
        ]
        body: 'FooBar5a'
      ]
    testSetEqual test, @person3.subdocumentsPosts,
      [
        _id: @postId1
        subdocument:
          body: 'SubdocumentFooBar1a'
        nested: [
          body: 'NestedFooBar1a'
        ]
        body: 'FooBar1a'
      ,
        _id: @postId2
        subdocument:
          body: 'SubdocumentFooBar2a'
        nested: [
          body: 'NestedFooBar2a'
        ]
        body: 'FooBar2a'
      ,
        _id: @postId3
        subdocument:
          body: 'SubdocumentFooBar3a'
        nested: [
          body: 'NestedFooBar3a'
        ]
        body: 'FooBar3a'
      ,
        _id: @postId5
        subdocument:
          body: 'SubdocumentFooBar5a'
        nested: [
          body: 'NestedFooBar5'
        ,
          body: 'NestedFooBar5a'
        ,
          body: 'NestedFooBar5'
        ]
        body: 'FooBar5a'
      ]
    testSetEqual test, @person3.nestedPosts,
      [
        _id: @postId2
        subdocument:
          body: 'SubdocumentFooBar2a'
        nested: [
          body: 'NestedFooBar2a'
        ]
        body: 'FooBar2a'
      ,
        _id: @postId3
        subdocument:
          body: 'SubdocumentFooBar3a'
        nested: [
          body: 'NestedFooBar3a'
        ]
        body: 'FooBar3a'
      ,
        _id: @postId4
        subdocument:
          body: 'SubdocumentFooBar4a'
        nested: [
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ]
        body: 'FooBar4a'
      ,
        _id: @postId5
        subdocument:
          body: 'SubdocumentFooBar5a'
        nested: [
          body: 'NestedFooBar5'
        ,
          body: 'NestedFooBar5a'
        ,
          body: 'NestedFooBar5'
        ]
        body: 'FooBar5a'
      ]

    # Add one which already exist
    Post.documents.update @postId5,
      $push:
        'subdocument.persons':
          _id: @person3Id
    ,
      expect (error, res) =>
        test.isFalse error, error?.toString?() or error
        test.isTrue res

    # Wait so that observers have time to update documents
    waitForDatabase test, expect
,
  (test, expect) ->
    @post5 = Post.documents.findOne @postId5,
      transform: null # So that we can use test.equal

    test.equal @post5,
      _id: @postId5
      author:
        _id: @person1Id
        username: 'person1'
        displayName: 'Person 1'
      subdocument:
        person:
          _id: @person3Id
          displayName: 'Person 3'
          username: 'person3'
        persons: [
          _id: @person3Id
          displayName: 'Person 3'
          username: 'person3'
        ,
          _id: @person3Id
          displayName: 'Person 3'
          username: 'person3'
        ,
          _id: @person3Id
          displayName: 'Person 3'
          username: 'person3'
        ,
          _id: @person3Id
          displayName: 'Person 3'
          username: 'person3'
        ,
          _id: @person2Id
          displayName: 'Person 2'
          username: 'person2'
        ,
          _id: @person3Id
          displayName: 'Person 3'
          username: 'person3'
        ,
          _id: @person3Id
          displayName: 'Person 3'
          username: 'person3'
        ]
        slug: 'subdocument-prefix-foobar5a-subdocumentfoobar5a-suffix'
        body: 'SubdocumentFooBar5a'
      nested: [
        required:
          _id: @person3Id
          username: 'person3'
          displayName: 'Person 3'
        slug: 'nested-prefix-foobar5a-nestedfoobar5-suffix'
        body: 'NestedFooBar5'
      ,
        required:
          _id: @person3Id
          username: 'person3'
          displayName: 'Person 3'
        slug: 'nested-prefix-foobar5a-nestedfoobar5a-suffix'
        body: 'NestedFooBar5a'
      ,
        required:
          _id: @person3Id
          username: 'person3'
          displayName: 'Person 3'
        slug: 'nested-prefix-foobar5a-nestedfoobar5-suffix'
        body: 'NestedFooBar5'
      ]
      body: 'FooBar5a'
      slug: 'prefix-foobar5a-subdocumentfoobar5a-suffix'
      tags: [
        'tag-0-prefix-foobar5a-subdocumentfoobar5a-suffix'
        'tag-1-prefix-foobar5a-nestedfoobar5-suffix'
        'tag-2-prefix-foobar5a-nestedfoobar5a-suffix'
        'tag-3-prefix-foobar5a-nestedfoobar5-suffix'
      ]

    @person1 = Person.documents.findOne @person1Id,
      transform: null # So that we can use test.equal
    @person2 = Person.documents.findOne @person2Id,
      transform: null # So that we can use test.equal
    @person3 = Person.documents.findOne @person3Id,
      transform: null # So that we can use test.equal

    test.equal _.omit(@person1, 'posts', 'subdocument', 'subdocumentsPosts', 'nestedPosts'),
      _id: @person1Id
      username: 'person1'
      displayName: 'Person 1'
      count: 13

    testSetEqual test, @person1.posts,
      [
        _id: @postId1
        subdocument:
          body: 'SubdocumentFooBar1a'
        nested: [
          body: 'NestedFooBar1a'
        ]
        body: 'FooBar1a'
      ,
        _id: @postId2
        subdocument:
          body: 'SubdocumentFooBar2a'
        nested: [
          body: 'NestedFooBar2a'
        ]
        body: 'FooBar2a'
      ,
        _id: @postId3
        subdocument:
          body: 'SubdocumentFooBar3a'
        nested: [
          body: 'NestedFooBar3a'
        ]
        body: 'FooBar3a'
      ,
        _id: @postId4
        subdocument:
          body: 'SubdocumentFooBar4a'
        nested: [
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ]
        body: 'FooBar4a'
      ,
        _id: @postId5
        subdocument:
          body: 'SubdocumentFooBar5a'
        nested: [
          body: 'NestedFooBar5'
        ,
          body: 'NestedFooBar5a'
        ,
          body: 'NestedFooBar5'
        ]
        body: 'FooBar5a'
      ]
    testSetEqual test, @person1.subdocument?.posts,
      [
        _id: @postId1
        subdocument:
          body: 'SubdocumentFooBar1a'
        nested: [
          body: 'NestedFooBar1a'
        ]
        body: 'FooBar1a'
      ,
        _id: @postId3
        subdocument:
          body: 'SubdocumentFooBar3a'
        nested: [
          body: 'NestedFooBar3a'
        ]
        body: 'FooBar3a'
      ,
        _id: @postId4
        subdocument:
          body: 'SubdocumentFooBar4a'
        nested: [
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ]
        body: 'FooBar4a'
      ]
    testSetEqual test, @person1.subdocumentsPosts,
      [
        _id: @postId1
        subdocument:
          body: 'SubdocumentFooBar1a'
        nested: [
          body: 'NestedFooBar1a'
        ]
        body: 'FooBar1a'
      ,
        _id: @postId2
        subdocument:
          body: 'SubdocumentFooBar2a'
        nested: [
          body: 'NestedFooBar2a'
        ]
        body: 'FooBar2a'
      ,
        _id: @postId3
        subdocument:
          body: 'SubdocumentFooBar3a'
        nested: [
          body: 'NestedFooBar3a'
        ]
        body: 'FooBar3a'
      ,
        _id: @postId4
        subdocument:
          body: 'SubdocumentFooBar4a'
        nested: [
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ]
        body: 'FooBar4a'
      ]
    testSetEqual test, @person1.nestedPosts,
      [
        _id: @postId4
        subdocument:
          body: 'SubdocumentFooBar4a'
        nested: [
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ]
        body: 'FooBar4a'
      ]

    test.equal _.omit(@person2, 'posts', 'subdocument', 'subdocumentsPosts', 'nestedPosts'),
      _id: @person2Id
      username: 'person2'
      displayName: 'Person 2'
      count: 8

    testSetEqual test, @person2.posts, []
    testSetEqual test, @person2.subdocument?.posts,
      [
        _id: @postId2
        subdocument:
          body: 'SubdocumentFooBar2a'
        nested: [
          body: 'NestedFooBar2a'
        ]
        body: 'FooBar2a'
      ]
    testSetEqual test, @person2.subdocumentsPosts,
      [
        _id: @postId1
        subdocument:
          body: 'SubdocumentFooBar1a'
        nested: [
          body: 'NestedFooBar1a'
        ]
        body: 'FooBar1a'
      ,
        _id: @postId2
        subdocument:
          body: 'SubdocumentFooBar2a'
        nested: [
          body: 'NestedFooBar2a'
        ]
        body: 'FooBar2a'
      ,
        _id: @postId3
        subdocument:
          body: 'SubdocumentFooBar3a'
        nested: [
          body: 'NestedFooBar3a'
        ]
        body: 'FooBar3a'
      ,
        _id: @postId4
        subdocument:
          body: 'SubdocumentFooBar4a'
        nested: [
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ]
        body: 'FooBar4a'
      ,
        _id: @postId5
        subdocument:
          body: 'SubdocumentFooBar5a'
        nested: [
          body: 'NestedFooBar5'
        ,
          body: 'NestedFooBar5a'
        ,
          body: 'NestedFooBar5'
        ]
        body: 'FooBar5a'
      ]
    testSetEqual test, @person2.nestedPosts,
      [
        _id: @postId1
        subdocument:
          body: 'SubdocumentFooBar1a'
        nested: [
          body: 'NestedFooBar1a'
        ]
        body: 'FooBar1a'
      ,
        _id: @postId4
        subdocument:
          body: 'SubdocumentFooBar4a'
        nested: [
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ]
        body: 'FooBar4a'
      ]

    test.equal _.omit(@person3, 'posts', 'subdocument', 'subdocumentsPosts', 'nestedPosts'),
      _id: @person3Id
      username: 'person3'
      displayName: 'Person 3'
      count: 9

    testSetEqual test, @person3.posts, []
    testSetEqual test, @person3.subdocument?.posts,
      [
        _id: @postId5
        subdocument:
          body: 'SubdocumentFooBar5a'
        nested: [
          body: 'NestedFooBar5'
        ,
          body: 'NestedFooBar5a'
        ,
          body: 'NestedFooBar5'
        ]
        body: 'FooBar5a'
      ]
    testSetEqual test, @person3.subdocumentsPosts,
      [
        _id: @postId1
        subdocument:
          body: 'SubdocumentFooBar1a'
        nested: [
          body: 'NestedFooBar1a'
        ]
        body: 'FooBar1a'
      ,
        _id: @postId2
        subdocument:
          body: 'SubdocumentFooBar2a'
        nested: [
          body: 'NestedFooBar2a'
        ]
        body: 'FooBar2a'
      ,
        _id: @postId3
        subdocument:
          body: 'SubdocumentFooBar3a'
        nested: [
          body: 'NestedFooBar3a'
        ]
        body: 'FooBar3a'
      ,
        _id: @postId5
        subdocument:
          body: 'SubdocumentFooBar5a'
        nested: [
          body: 'NestedFooBar5'
        ,
          body: 'NestedFooBar5a'
        ,
          body: 'NestedFooBar5'
        ]
        body: 'FooBar5a'
      ]
    testSetEqual test, @person3.nestedPosts,
      [
        _id: @postId2
        subdocument:
          body: 'SubdocumentFooBar2a'
        nested: [
          body: 'NestedFooBar2a'
        ]
        body: 'FooBar2a'
      ,
        _id: @postId3
        subdocument:
          body: 'SubdocumentFooBar3a'
        nested: [
          body: 'NestedFooBar3a'
        ]
        body: 'FooBar3a'
      ,
        _id: @postId4
        subdocument:
          body: 'SubdocumentFooBar4a'
        nested: [
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ]
        body: 'FooBar4a'
      ,
        _id: @postId5
        subdocument:
          body: 'SubdocumentFooBar5a'
        nested: [
          body: 'NestedFooBar5'
        ,
          body: 'NestedFooBar5a'
        ,
          body: 'NestedFooBar5'
        ]
        body: 'FooBar5a'
      ]

    Post.documents.update @postId5,
      $pop:
        'subdocument.persons': 1
    ,
      expect (error, res) =>
        test.isFalse error, error?.toString?() or error
        test.isTrue res

    # Wait so that observers have time to update documents
    waitForDatabase test, expect
,
  (test, expect) ->
    @post5 = Post.documents.findOne @postId5,
      transform: null # So that we can use test.equal

    test.equal @post5,
      _id: @postId5
      author:
        _id: @person1Id
        username: 'person1'
        displayName: 'Person 1'
      subdocument:
        person:
          _id: @person3Id
          displayName: 'Person 3'
          username: 'person3'
        persons: [
          _id: @person3Id
          displayName: 'Person 3'
          username: 'person3'
        ,
          _id: @person3Id
          displayName: 'Person 3'
          username: 'person3'
        ,
          _id: @person3Id
          displayName: 'Person 3'
          username: 'person3'
        ,
          _id: @person3Id
          displayName: 'Person 3'
          username: 'person3'
        ,
          _id: @person2Id
          displayName: 'Person 2'
          username: 'person2'
        ,
          _id: @person3Id
          displayName: 'Person 3'
          username: 'person3'
        ]
        slug: 'subdocument-prefix-foobar5a-subdocumentfoobar5a-suffix'
        body: 'SubdocumentFooBar5a'
      nested: [
        required:
          _id: @person3Id
          username: 'person3'
          displayName: 'Person 3'
        slug: 'nested-prefix-foobar5a-nestedfoobar5-suffix'
        body: 'NestedFooBar5'
      ,
        required:
          _id: @person3Id
          username: 'person3'
          displayName: 'Person 3'
        slug: 'nested-prefix-foobar5a-nestedfoobar5a-suffix'
        body: 'NestedFooBar5a'
      ,
        required:
          _id: @person3Id
          username: 'person3'
          displayName: 'Person 3'
        slug: 'nested-prefix-foobar5a-nestedfoobar5-suffix'
        body: 'NestedFooBar5'
      ]
      body: 'FooBar5a'
      slug: 'prefix-foobar5a-subdocumentfoobar5a-suffix'
      tags: [
        'tag-0-prefix-foobar5a-subdocumentfoobar5a-suffix'
        'tag-1-prefix-foobar5a-nestedfoobar5-suffix'
        'tag-2-prefix-foobar5a-nestedfoobar5a-suffix'
        'tag-3-prefix-foobar5a-nestedfoobar5-suffix'
      ]

    @person1 = Person.documents.findOne @person1Id,
      transform: null # So that we can use test.equal
    @person2 = Person.documents.findOne @person2Id,
      transform: null # So that we can use test.equal
    @person3 = Person.documents.findOne @person3Id,
      transform: null # So that we can use test.equal

    test.equal _.omit(@person1, 'posts', 'subdocument', 'subdocumentsPosts', 'nestedPosts'),
      _id: @person1Id
      username: 'person1'
      displayName: 'Person 1'
      count: 13

    testSetEqual test, @person1.posts,
      [
        _id: @postId1
        subdocument:
          body: 'SubdocumentFooBar1a'
        nested: [
          body: 'NestedFooBar1a'
        ]
        body: 'FooBar1a'
      ,
        _id: @postId2
        subdocument:
          body: 'SubdocumentFooBar2a'
        nested: [
          body: 'NestedFooBar2a'
        ]
        body: 'FooBar2a'
      ,
        _id: @postId3
        subdocument:
          body: 'SubdocumentFooBar3a'
        nested: [
          body: 'NestedFooBar3a'
        ]
        body: 'FooBar3a'
      ,
        _id: @postId4
        subdocument:
          body: 'SubdocumentFooBar4a'
        nested: [
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ]
        body: 'FooBar4a'
      ,
        _id: @postId5
        subdocument:
          body: 'SubdocumentFooBar5a'
        nested: [
          body: 'NestedFooBar5'
        ,
          body: 'NestedFooBar5a'
        ,
          body: 'NestedFooBar5'
        ]
        body: 'FooBar5a'
      ]
    testSetEqual test, @person1.subdocument?.posts,
      [
        _id: @postId1
        subdocument:
          body: 'SubdocumentFooBar1a'
        nested: [
          body: 'NestedFooBar1a'
        ]
        body: 'FooBar1a'
      ,
        _id: @postId3
        subdocument:
          body: 'SubdocumentFooBar3a'
        nested: [
          body: 'NestedFooBar3a'
        ]
        body: 'FooBar3a'
      ,
        _id: @postId4
        subdocument:
          body: 'SubdocumentFooBar4a'
        nested: [
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ]
        body: 'FooBar4a'
      ]
    testSetEqual test, @person1.subdocumentsPosts,
      [
        _id: @postId1
        subdocument:
          body: 'SubdocumentFooBar1a'
        nested: [
          body: 'NestedFooBar1a'
        ]
        body: 'FooBar1a'
      ,
        _id: @postId2
        subdocument:
          body: 'SubdocumentFooBar2a'
        nested: [
          body: 'NestedFooBar2a'
        ]
        body: 'FooBar2a'
      ,
        _id: @postId3
        subdocument:
          body: 'SubdocumentFooBar3a'
        nested: [
          body: 'NestedFooBar3a'
        ]
        body: 'FooBar3a'
      ,
        _id: @postId4
        subdocument:
          body: 'SubdocumentFooBar4a'
        nested: [
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ]
        body: 'FooBar4a'
      ]
    testSetEqual test, @person1.nestedPosts,
      [
        _id: @postId4
        subdocument:
          body: 'SubdocumentFooBar4a'
        nested: [
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ]
        body: 'FooBar4a'
      ]

    test.equal _.omit(@person2, 'posts', 'subdocument', 'subdocumentsPosts', 'nestedPosts'),
      _id: @person2Id
      username: 'person2'
      displayName: 'Person 2'
      count: 8

    testSetEqual test, @person2.posts, []
    testSetEqual test, @person2.subdocument?.posts,
      [
        _id: @postId2
        subdocument:
          body: 'SubdocumentFooBar2a'
        nested: [
          body: 'NestedFooBar2a'
        ]
        body: 'FooBar2a'
      ]
    testSetEqual test, @person2.subdocumentsPosts,
      [
        _id: @postId1
        subdocument:
          body: 'SubdocumentFooBar1a'
        nested: [
          body: 'NestedFooBar1a'
        ]
        body: 'FooBar1a'
      ,
        _id: @postId2
        subdocument:
          body: 'SubdocumentFooBar2a'
        nested: [
          body: 'NestedFooBar2a'
        ]
        body: 'FooBar2a'
      ,
        _id: @postId3
        subdocument:
          body: 'SubdocumentFooBar3a'
        nested: [
          body: 'NestedFooBar3a'
        ]
        body: 'FooBar3a'
      ,
        _id: @postId4
        subdocument:
          body: 'SubdocumentFooBar4a'
        nested: [
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ]
        body: 'FooBar4a'
      ,
        _id: @postId5
        subdocument:
          body: 'SubdocumentFooBar5a'
        nested: [
          body: 'NestedFooBar5'
        ,
          body: 'NestedFooBar5a'
        ,
          body: 'NestedFooBar5'
        ]
        body: 'FooBar5a'
      ]
    testSetEqual test, @person2.nestedPosts,
      [
        _id: @postId1
        subdocument:
          body: 'SubdocumentFooBar1a'
        nested: [
          body: 'NestedFooBar1a'
        ]
        body: 'FooBar1a'
      ,
        _id: @postId4
        subdocument:
          body: 'SubdocumentFooBar4a'
        nested: [
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ]
        body: 'FooBar4a'
      ]

    test.equal _.omit(@person3, 'posts', 'subdocument', 'subdocumentsPosts', 'nestedPosts'),
      _id: @person3Id
      username: 'person3'
      displayName: 'Person 3'
      count: 9

    testSetEqual test, @person3.posts, []
    testSetEqual test, @person3.subdocument?.posts,
      [
        _id: @postId5
        subdocument:
          body: 'SubdocumentFooBar5a'
        nested: [
          body: 'NestedFooBar5'
        ,
          body: 'NestedFooBar5a'
        ,
          body: 'NestedFooBar5'
        ]
        body: 'FooBar5a'
      ]
    testSetEqual test, @person3.subdocumentsPosts,
      [
        _id: @postId1
        subdocument:
          body: 'SubdocumentFooBar1a'
        nested: [
          body: 'NestedFooBar1a'
        ]
        body: 'FooBar1a'
      ,
        _id: @postId2
        subdocument:
          body: 'SubdocumentFooBar2a'
        nested: [
          body: 'NestedFooBar2a'
        ]
        body: 'FooBar2a'
      ,
        _id: @postId3
        subdocument:
          body: 'SubdocumentFooBar3a'
        nested: [
          body: 'NestedFooBar3a'
        ]
        body: 'FooBar3a'
      ,
        _id: @postId5
        subdocument:
          body: 'SubdocumentFooBar5a'
        nested: [
          body: 'NestedFooBar5'
        ,
          body: 'NestedFooBar5a'
        ,
          body: 'NestedFooBar5'
        ]
        body: 'FooBar5a'
      ]
    testSetEqual test, @person3.nestedPosts,
      [
        _id: @postId2
        subdocument:
          body: 'SubdocumentFooBar2a'
        nested: [
          body: 'NestedFooBar2a'
        ]
        body: 'FooBar2a'
      ,
        _id: @postId3
        subdocument:
          body: 'SubdocumentFooBar3a'
        nested: [
          body: 'NestedFooBar3a'
        ]
        body: 'FooBar3a'
      ,
        _id: @postId4
        subdocument:
          body: 'SubdocumentFooBar4a'
        nested: [
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ]
        body: 'FooBar4a'
      ,
        _id: @postId5
        subdocument:
          body: 'SubdocumentFooBar5a'
        nested: [
          body: 'NestedFooBar5'
        ,
          body: 'NestedFooBar5a'
        ,
          body: 'NestedFooBar5'
        ]
        body: 'FooBar5a'
      ]

    Post.documents.update @postId5,
      $set:
        'subdocument.persons.2._id': @person1Id
    ,
      expect (error, res) =>
        test.isFalse error, error?.toString?() or error
        test.isTrue res

    # Wait so that observers have time to update documents
    waitForDatabase test, expect
,
  (test, expect) ->
    @post5 = Post.documents.findOne @postId5,
      transform: null # So that we can use test.equal

    test.equal @post5,
      _id: @postId5
      author:
        _id: @person1Id
        username: 'person1'
        displayName: 'Person 1'
      subdocument:
        person:
          _id: @person3Id
          displayName: 'Person 3'
          username: 'person3'
        persons: [
          _id: @person3Id
          displayName: 'Person 3'
          username: 'person3'
        ,
          _id: @person3Id
          displayName: 'Person 3'
          username: 'person3'
        ,
          _id: @person1Id
          displayName: 'Person 1'
          username: 'person1'
        ,
          _id: @person3Id
          displayName: 'Person 3'
          username: 'person3'
        ,
          _id: @person2Id
          displayName: 'Person 2'
          username: 'person2'
        ,
          _id: @person3Id
          displayName: 'Person 3'
          username: 'person3'
        ]
        slug: 'subdocument-prefix-foobar5a-subdocumentfoobar5a-suffix'
        body: 'SubdocumentFooBar5a'
      nested: [
        required:
          _id: @person3Id
          username: 'person3'
          displayName: 'Person 3'
        slug: 'nested-prefix-foobar5a-nestedfoobar5-suffix'
        body: 'NestedFooBar5'
      ,
        required:
          _id: @person3Id
          username: 'person3'
          displayName: 'Person 3'
        slug: 'nested-prefix-foobar5a-nestedfoobar5a-suffix'
        body: 'NestedFooBar5a'
      ,
        required:
          _id: @person3Id
          username: 'person3'
          displayName: 'Person 3'
        slug: 'nested-prefix-foobar5a-nestedfoobar5-suffix'
        body: 'NestedFooBar5'
      ]
      body: 'FooBar5a'
      slug: 'prefix-foobar5a-subdocumentfoobar5a-suffix'
      tags: [
        'tag-0-prefix-foobar5a-subdocumentfoobar5a-suffix'
        'tag-1-prefix-foobar5a-nestedfoobar5-suffix'
        'tag-2-prefix-foobar5a-nestedfoobar5a-suffix'
        'tag-3-prefix-foobar5a-nestedfoobar5-suffix'
      ]

    @person1 = Person.documents.findOne @person1Id,
      transform: null # So that we can use test.equal
    @person2 = Person.documents.findOne @person2Id,
      transform: null # So that we can use test.equal
    @person3 = Person.documents.findOne @person3Id,
      transform: null # So that we can use test.equal

    test.equal _.omit(@person1, 'posts', 'subdocument', 'subdocumentsPosts', 'nestedPosts'),
      _id: @person1Id
      username: 'person1'
      displayName: 'Person 1'
      count: 14

    testSetEqual test, @person1.posts,
      [
        _id: @postId1
        subdocument:
          body: 'SubdocumentFooBar1a'
        nested: [
          body: 'NestedFooBar1a'
        ]
        body: 'FooBar1a'
      ,
        _id: @postId2
        subdocument:
          body: 'SubdocumentFooBar2a'
        nested: [
          body: 'NestedFooBar2a'
        ]
        body: 'FooBar2a'
      ,
        _id: @postId3
        subdocument:
          body: 'SubdocumentFooBar3a'
        nested: [
          body: 'NestedFooBar3a'
        ]
        body: 'FooBar3a'
      ,
        _id: @postId4
        subdocument:
          body: 'SubdocumentFooBar4a'
        nested: [
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ]
        body: 'FooBar4a'
      ,
        _id: @postId5
        subdocument:
          body: 'SubdocumentFooBar5a'
        nested: [
          body: 'NestedFooBar5'
        ,
          body: 'NestedFooBar5a'
        ,
          body: 'NestedFooBar5'
        ]
        body: 'FooBar5a'
      ]
    testSetEqual test, @person1.subdocument?.posts,
      [
        _id: @postId1
        subdocument:
          body: 'SubdocumentFooBar1a'
        nested: [
          body: 'NestedFooBar1a'
        ]
        body: 'FooBar1a'
      ,
        _id: @postId3
        subdocument:
          body: 'SubdocumentFooBar3a'
        nested: [
          body: 'NestedFooBar3a'
        ]
        body: 'FooBar3a'
      ,
        _id: @postId4
        subdocument:
          body: 'SubdocumentFooBar4a'
        nested: [
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ]
        body: 'FooBar4a'
      ]
    testSetEqual test, @person1.subdocumentsPosts,
      [
        _id: @postId1
        subdocument:
          body: 'SubdocumentFooBar1a'
        nested: [
          body: 'NestedFooBar1a'
        ]
        body: 'FooBar1a'
      ,
        _id: @postId2
        subdocument:
          body: 'SubdocumentFooBar2a'
        nested: [
          body: 'NestedFooBar2a'
        ]
        body: 'FooBar2a'
      ,
        _id: @postId3
        subdocument:
          body: 'SubdocumentFooBar3a'
        nested: [
          body: 'NestedFooBar3a'
        ]
        body: 'FooBar3a'
      ,
        _id: @postId4
        subdocument:
          body: 'SubdocumentFooBar4a'
        nested: [
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ]
        body: 'FooBar4a'
      ,
        _id: @postId5
        subdocument:
          body: 'SubdocumentFooBar5a'
        nested: [
          body: 'NestedFooBar5'
        ,
          body: 'NestedFooBar5a'
        ,
          body: 'NestedFooBar5'
        ]
        body: 'FooBar5a'
      ]
    testSetEqual test, @person1.nestedPosts,
      [
        _id: @postId4
        subdocument:
          body: 'SubdocumentFooBar4a'
        nested: [
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ]
        body: 'FooBar4a'
      ]

    test.equal _.omit(@person2, 'posts', 'subdocument', 'subdocumentsPosts', 'nestedPosts'),
      _id: @person2Id
      username: 'person2'
      displayName: 'Person 2'
      count: 8

    testSetEqual test, @person2.posts, []
    testSetEqual test, @person2.subdocument?.posts,
      [
        _id: @postId2
        subdocument:
          body: 'SubdocumentFooBar2a'
        nested: [
          body: 'NestedFooBar2a'
        ]
        body: 'FooBar2a'
      ]
    testSetEqual test, @person2.subdocumentsPosts,
      [
        _id: @postId1
        subdocument:
          body: 'SubdocumentFooBar1a'
        nested: [
          body: 'NestedFooBar1a'
        ]
        body: 'FooBar1a'
      ,
        _id: @postId2
        subdocument:
          body: 'SubdocumentFooBar2a'
        nested: [
          body: 'NestedFooBar2a'
        ]
        body: 'FooBar2a'
      ,
        _id: @postId3
        subdocument:
          body: 'SubdocumentFooBar3a'
        nested: [
          body: 'NestedFooBar3a'
        ]
        body: 'FooBar3a'
      ,
        _id: @postId4
        subdocument:
          body: 'SubdocumentFooBar4a'
        nested: [
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ]
        body: 'FooBar4a'
      ,
        _id: @postId5
        subdocument:
          body: 'SubdocumentFooBar5a'
        nested: [
          body: 'NestedFooBar5'
        ,
          body: 'NestedFooBar5a'
        ,
          body: 'NestedFooBar5'
        ]
        body: 'FooBar5a'
      ]
    testSetEqual test, @person2.nestedPosts,
      [
        _id: @postId1
        subdocument:
          body: 'SubdocumentFooBar1a'
        nested: [
          body: 'NestedFooBar1a'
        ]
        body: 'FooBar1a'
      ,
        _id: @postId4
        subdocument:
          body: 'SubdocumentFooBar4a'
        nested: [
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ]
        body: 'FooBar4a'
      ]

    test.equal _.omit(@person3, 'posts', 'subdocument', 'subdocumentsPosts', 'nestedPosts'),
      _id: @person3Id
      username: 'person3'
      displayName: 'Person 3'
      count: 9

    testSetEqual test, @person3.posts, []
    testSetEqual test, @person3.subdocument?.posts,
      [
        _id: @postId5
        subdocument:
          body: 'SubdocumentFooBar5a'
        nested: [
          body: 'NestedFooBar5'
        ,
          body: 'NestedFooBar5a'
        ,
          body: 'NestedFooBar5'
        ]
        body: 'FooBar5a'
      ]
    testSetEqual test, @person3.subdocumentsPosts,
      [
        _id: @postId1
        subdocument:
          body: 'SubdocumentFooBar1a'
        nested: [
          body: 'NestedFooBar1a'
        ]
        body: 'FooBar1a'
      ,
        _id: @postId2
        subdocument:
          body: 'SubdocumentFooBar2a'
        nested: [
          body: 'NestedFooBar2a'
        ]
        body: 'FooBar2a'
      ,
        _id: @postId3
        subdocument:
          body: 'SubdocumentFooBar3a'
        nested: [
          body: 'NestedFooBar3a'
        ]
        body: 'FooBar3a'
      ,
        _id: @postId5
        subdocument:
          body: 'SubdocumentFooBar5a'
        nested: [
          body: 'NestedFooBar5'
        ,
          body: 'NestedFooBar5a'
        ,
          body: 'NestedFooBar5'
        ]
        body: 'FooBar5a'
      ]
    testSetEqual test, @person3.nestedPosts,
      [
        _id: @postId2
        subdocument:
          body: 'SubdocumentFooBar2a'
        nested: [
          body: 'NestedFooBar2a'
        ]
        body: 'FooBar2a'
      ,
        _id: @postId3
        subdocument:
          body: 'SubdocumentFooBar3a'
        nested: [
          body: 'NestedFooBar3a'
        ]
        body: 'FooBar3a'
      ,
        _id: @postId4
        subdocument:
          body: 'SubdocumentFooBar4a'
        nested: [
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ]
        body: 'FooBar4a'
      ,
        _id: @postId5
        subdocument:
          body: 'SubdocumentFooBar5a'
        nested: [
          body: 'NestedFooBar5'
        ,
          body: 'NestedFooBar5a'
        ,
          body: 'NestedFooBar5'
        ]
        body: 'FooBar5a'
      ]

    # Add one which already exist
    Post.documents.update @postId5,
      $set:
        'subdocument.persons.2._id': @person3Id
    ,
      expect (error, res) =>
        test.isFalse error, error?.toString?() or error
        test.isTrue res

    # Wait so that observers have time to update documents
    waitForDatabase test, expect
,
  (test, expect) ->
    @post5 = Post.documents.findOne @postId5,
      transform: null # So that we can use test.equal

    test.equal @post5,
      _id: @postId5
      author:
        _id: @person1Id
        username: 'person1'
        displayName: 'Person 1'
      subdocument:
        person:
          _id: @person3Id
          displayName: 'Person 3'
          username: 'person3'
        persons: [
          _id: @person3Id
          displayName: 'Person 3'
          username: 'person3'
        ,
          _id: @person3Id
          displayName: 'Person 3'
          username: 'person3'
        ,
          _id: @person3Id
          displayName: 'Person 3'
          username: 'person3'
        ,
          _id: @person3Id
          displayName: 'Person 3'
          username: 'person3'
        ,
          _id: @person2Id
          displayName: 'Person 2'
          username: 'person2'
        ,
          _id: @person3Id
          displayName: 'Person 3'
          username: 'person3'
        ]
        slug: 'subdocument-prefix-foobar5a-subdocumentfoobar5a-suffix'
        body: 'SubdocumentFooBar5a'
      nested: [
        required:
          _id: @person3Id
          username: 'person3'
          displayName: 'Person 3'
        slug: 'nested-prefix-foobar5a-nestedfoobar5-suffix'
        body: 'NestedFooBar5'
      ,
        required:
          _id: @person3Id
          username: 'person3'
          displayName: 'Person 3'
        slug: 'nested-prefix-foobar5a-nestedfoobar5a-suffix'
        body: 'NestedFooBar5a'
      ,
        required:
          _id: @person3Id
          username: 'person3'
          displayName: 'Person 3'
        slug: 'nested-prefix-foobar5a-nestedfoobar5-suffix'
        body: 'NestedFooBar5'
      ]
      body: 'FooBar5a'
      slug: 'prefix-foobar5a-subdocumentfoobar5a-suffix'
      tags: [
        'tag-0-prefix-foobar5a-subdocumentfoobar5a-suffix'
        'tag-1-prefix-foobar5a-nestedfoobar5-suffix'
        'tag-2-prefix-foobar5a-nestedfoobar5a-suffix'
        'tag-3-prefix-foobar5a-nestedfoobar5-suffix'
      ]

    @person1 = Person.documents.findOne @person1Id,
      transform: null # So that we can use test.equal
    @person2 = Person.documents.findOne @person2Id,
      transform: null # So that we can use test.equal
    @person3 = Person.documents.findOne @person3Id,
      transform: null # So that we can use test.equal

    test.equal _.omit(@person1, 'posts', 'subdocument', 'subdocumentsPosts', 'nestedPosts'),
      _id: @person1Id
      username: 'person1'
      displayName: 'Person 1'
      count: 13

    testSetEqual test, @person1.posts,
      [
        _id: @postId1
        subdocument:
          body: 'SubdocumentFooBar1a'
        nested: [
          body: 'NestedFooBar1a'
        ]
        body: 'FooBar1a'
      ,
        _id: @postId2
        subdocument:
          body: 'SubdocumentFooBar2a'
        nested: [
          body: 'NestedFooBar2a'
        ]
        body: 'FooBar2a'
      ,
        _id: @postId3
        subdocument:
          body: 'SubdocumentFooBar3a'
        nested: [
          body: 'NestedFooBar3a'
        ]
        body: 'FooBar3a'
      ,
        _id: @postId4
        subdocument:
          body: 'SubdocumentFooBar4a'
        nested: [
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ]
        body: 'FooBar4a'
      ,
        _id: @postId5
        subdocument:
          body: 'SubdocumentFooBar5a'
        nested: [
          body: 'NestedFooBar5'
        ,
          body: 'NestedFooBar5a'
        ,
          body: 'NestedFooBar5'
        ]
        body: 'FooBar5a'
      ]
    testSetEqual test, @person1.subdocument?.posts,
      [
        _id: @postId1
        subdocument:
          body: 'SubdocumentFooBar1a'
        nested: [
          body: 'NestedFooBar1a'
        ]
        body: 'FooBar1a'
      ,
        _id: @postId3
        subdocument:
          body: 'SubdocumentFooBar3a'
        nested: [
          body: 'NestedFooBar3a'
        ]
        body: 'FooBar3a'
      ,
        _id: @postId4
        subdocument:
          body: 'SubdocumentFooBar4a'
        nested: [
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ]
        body: 'FooBar4a'
      ]
    testSetEqual test, @person1.subdocumentsPosts,
      [
        _id: @postId1
        subdocument:
          body: 'SubdocumentFooBar1a'
        nested: [
          body: 'NestedFooBar1a'
        ]
        body: 'FooBar1a'
      ,
        _id: @postId2
        subdocument:
          body: 'SubdocumentFooBar2a'
        nested: [
          body: 'NestedFooBar2a'
        ]
        body: 'FooBar2a'
      ,
        _id: @postId3
        subdocument:
          body: 'SubdocumentFooBar3a'
        nested: [
          body: 'NestedFooBar3a'
        ]
        body: 'FooBar3a'
      ,
        _id: @postId4
        subdocument:
          body: 'SubdocumentFooBar4a'
        nested: [
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ]
        body: 'FooBar4a'
      ]
    testSetEqual test, @person1.nestedPosts,
      [
        _id: @postId4
        subdocument:
          body: 'SubdocumentFooBar4a'
        nested: [
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ]
        body: 'FooBar4a'
      ]

    test.equal _.omit(@person2, 'posts', 'subdocument', 'subdocumentsPosts', 'nestedPosts'),
      _id: @person2Id
      username: 'person2'
      displayName: 'Person 2'
      count: 8

    testSetEqual test, @person2.posts, []
    testSetEqual test, @person2.subdocument?.posts,
      [
        _id: @postId2
        subdocument:
          body: 'SubdocumentFooBar2a'
        nested: [
          body: 'NestedFooBar2a'
        ]
        body: 'FooBar2a'
      ]
    testSetEqual test, @person2.subdocumentsPosts,
      [
        _id: @postId1
        subdocument:
          body: 'SubdocumentFooBar1a'
        nested: [
          body: 'NestedFooBar1a'
        ]
        body: 'FooBar1a'
      ,
        _id: @postId2
        subdocument:
          body: 'SubdocumentFooBar2a'
        nested: [
          body: 'NestedFooBar2a'
        ]
        body: 'FooBar2a'
      ,
        _id: @postId3
        subdocument:
          body: 'SubdocumentFooBar3a'
        nested: [
          body: 'NestedFooBar3a'
        ]
        body: 'FooBar3a'
      ,
        _id: @postId4
        subdocument:
          body: 'SubdocumentFooBar4a'
        nested: [
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ]
        body: 'FooBar4a'
      ,
        _id: @postId5
        subdocument:
          body: 'SubdocumentFooBar5a'
        nested: [
          body: 'NestedFooBar5'
        ,
          body: 'NestedFooBar5a'
        ,
          body: 'NestedFooBar5'
        ]
        body: 'FooBar5a'
      ]
    testSetEqual test, @person2.nestedPosts,
      [
        _id: @postId1
        subdocument:
          body: 'SubdocumentFooBar1a'
        nested: [
          body: 'NestedFooBar1a'
        ]
        body: 'FooBar1a'
      ,
        _id: @postId4
        subdocument:
          body: 'SubdocumentFooBar4a'
        nested: [
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ]
        body: 'FooBar4a'
      ]

    test.equal _.omit(@person3, 'posts', 'subdocument', 'subdocumentsPosts', 'nestedPosts'),
      _id: @person3Id
      username: 'person3'
      displayName: 'Person 3'
      count: 9

    testSetEqual test, @person3.posts, []
    testSetEqual test, @person3.subdocument?.posts,
      [
        _id: @postId5
        subdocument:
          body: 'SubdocumentFooBar5a'
        nested: [
          body: 'NestedFooBar5'
        ,
          body: 'NestedFooBar5a'
        ,
          body: 'NestedFooBar5'
        ]
        body: 'FooBar5a'
      ]
    testSetEqual test, @person3.subdocumentsPosts,
      [
        _id: @postId1
        subdocument:
          body: 'SubdocumentFooBar1a'
        nested: [
          body: 'NestedFooBar1a'
        ]
        body: 'FooBar1a'
      ,
        _id: @postId2
        subdocument:
          body: 'SubdocumentFooBar2a'
        nested: [
          body: 'NestedFooBar2a'
        ]
        body: 'FooBar2a'
      ,
        _id: @postId3
        subdocument:
          body: 'SubdocumentFooBar3a'
        nested: [
          body: 'NestedFooBar3a'
        ]
        body: 'FooBar3a'
      ,
        _id: @postId5
        subdocument:
          body: 'SubdocumentFooBar5a'
        nested: [
          body: 'NestedFooBar5'
        ,
          body: 'NestedFooBar5a'
        ,
          body: 'NestedFooBar5'
        ]
        body: 'FooBar5a'
      ]
    testSetEqual test, @person3.nestedPosts,
      [
        _id: @postId2
        subdocument:
          body: 'SubdocumentFooBar2a'
        nested: [
          body: 'NestedFooBar2a'
        ]
        body: 'FooBar2a'
      ,
        _id: @postId3
        subdocument:
          body: 'SubdocumentFooBar3a'
        nested: [
          body: 'NestedFooBar3a'
        ]
        body: 'FooBar3a'
      ,
        _id: @postId4
        subdocument:
          body: 'SubdocumentFooBar4a'
        nested: [
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ]
        body: 'FooBar4a'
      ,
        _id: @postId5
        subdocument:
          body: 'SubdocumentFooBar5a'
        nested: [
          body: 'NestedFooBar5'
        ,
          body: 'NestedFooBar5a'
        ,
          body: 'NestedFooBar5'
        ]
        body: 'FooBar5a'
      ]

    Post.documents.update @postId5,
      $set:
        'subdocument.person': null
    ,
      expect (error, res) =>
        test.isFalse error, error?.toString?() or error
        test.isTrue res

    # Wait so that observers have time to update documents
    waitForDatabase test, expect
,
  (test, expect) ->
    @post5 = Post.documents.findOne @postId5,
      transform: null # So that we can use test.equal

    test.equal @post5,
      _id: @postId5
      author:
        _id: @person1Id
        username: 'person1'
        displayName: 'Person 1'
      subdocument:
        person: null
        persons: [
          _id: @person3Id
          displayName: 'Person 3'
          username: 'person3'
        ,
          _id: @person3Id
          displayName: 'Person 3'
          username: 'person3'
        ,
          _id: @person3Id
          displayName: 'Person 3'
          username: 'person3'
        ,
          _id: @person3Id
          displayName: 'Person 3'
          username: 'person3'
        ,
          _id: @person2Id
          displayName: 'Person 2'
          username: 'person2'
        ,
          _id: @person3Id
          displayName: 'Person 3'
          username: 'person3'
        ]
        slug: 'subdocument-prefix-foobar5a-subdocumentfoobar5a-suffix'
        body: 'SubdocumentFooBar5a'
      nested: [
        required:
          _id: @person3Id
          username: 'person3'
          displayName: 'Person 3'
        slug: 'nested-prefix-foobar5a-nestedfoobar5-suffix'
        body: 'NestedFooBar5'
      ,
        required:
          _id: @person3Id
          username: 'person3'
          displayName: 'Person 3'
        slug: 'nested-prefix-foobar5a-nestedfoobar5a-suffix'
        body: 'NestedFooBar5a'
      ,
        required:
          _id: @person3Id
          username: 'person3'
          displayName: 'Person 3'
        slug: 'nested-prefix-foobar5a-nestedfoobar5-suffix'
        body: 'NestedFooBar5'
      ]
      body: 'FooBar5a'
      slug: 'prefix-foobar5a-subdocumentfoobar5a-suffix'
      tags: [
        'tag-0-prefix-foobar5a-subdocumentfoobar5a-suffix'
        'tag-1-prefix-foobar5a-nestedfoobar5-suffix'
        'tag-2-prefix-foobar5a-nestedfoobar5a-suffix'
        'tag-3-prefix-foobar5a-nestedfoobar5-suffix'
      ]

    @person1 = Person.documents.findOne @person1Id,
      transform: null # So that we can use test.equal
    @person2 = Person.documents.findOne @person2Id,
      transform: null # So that we can use test.equal
    @person3 = Person.documents.findOne @person3Id,
      transform: null # So that we can use test.equal

    test.equal _.omit(@person1, 'posts', 'subdocument', 'subdocumentsPosts', 'nestedPosts'),
      _id: @person1Id
      username: 'person1'
      displayName: 'Person 1'
      count: 13

    testSetEqual test, @person1.posts,
      [
        _id: @postId1
        subdocument:
          body: 'SubdocumentFooBar1a'
        nested: [
          body: 'NestedFooBar1a'
        ]
        body: 'FooBar1a'
      ,
        _id: @postId2
        subdocument:
          body: 'SubdocumentFooBar2a'
        nested: [
          body: 'NestedFooBar2a'
        ]
        body: 'FooBar2a'
      ,
        _id: @postId3
        subdocument:
          body: 'SubdocumentFooBar3a'
        nested: [
          body: 'NestedFooBar3a'
        ]
        body: 'FooBar3a'
      ,
        _id: @postId4
        subdocument:
          body: 'SubdocumentFooBar4a'
        nested: [
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ]
        body: 'FooBar4a'
      ,
        _id: @postId5
        subdocument:
          body: 'SubdocumentFooBar5a'
        nested: [
          body: 'NestedFooBar5'
        ,
          body: 'NestedFooBar5a'
        ,
          body: 'NestedFooBar5'
        ]
        body: 'FooBar5a'
      ]
    testSetEqual test, @person1.subdocument?.posts,
      [
        _id: @postId1
        subdocument:
          body: 'SubdocumentFooBar1a'
        nested: [
          body: 'NestedFooBar1a'
        ]
        body: 'FooBar1a'
      ,
        _id: @postId3
        subdocument:
          body: 'SubdocumentFooBar3a'
        nested: [
          body: 'NestedFooBar3a'
        ]
        body: 'FooBar3a'
      ,
        _id: @postId4
        subdocument:
          body: 'SubdocumentFooBar4a'
        nested: [
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ]
        body: 'FooBar4a'
      ]
    testSetEqual test, @person1.subdocumentsPosts,
      [
        _id: @postId1
        subdocument:
          body: 'SubdocumentFooBar1a'
        nested: [
          body: 'NestedFooBar1a'
        ]
        body: 'FooBar1a'
      ,
        _id: @postId2
        subdocument:
          body: 'SubdocumentFooBar2a'
        nested: [
          body: 'NestedFooBar2a'
        ]
        body: 'FooBar2a'
      ,
        _id: @postId3
        subdocument:
          body: 'SubdocumentFooBar3a'
        nested: [
          body: 'NestedFooBar3a'
        ]
        body: 'FooBar3a'
      ,
        _id: @postId4
        subdocument:
          body: 'SubdocumentFooBar4a'
        nested: [
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ]
        body: 'FooBar4a'
      ]
    testSetEqual test, @person1.nestedPosts,
      [
        _id: @postId4
        subdocument:
          body: 'SubdocumentFooBar4a'
        nested: [
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ]
        body: 'FooBar4a'
      ]

    test.equal _.omit(@person2, 'posts', 'subdocument', 'subdocumentsPosts', 'nestedPosts'),
      _id: @person2Id
      username: 'person2'
      displayName: 'Person 2'
      count: 8

    testSetEqual test, @person2.posts, []
    testSetEqual test, @person2.subdocument?.posts,
      [
        _id: @postId2
        subdocument:
          body: 'SubdocumentFooBar2a'
        nested: [
          body: 'NestedFooBar2a'
        ]
        body: 'FooBar2a'
      ]
    testSetEqual test, @person2.subdocumentsPosts,
      [
        _id: @postId1
        subdocument:
          body: 'SubdocumentFooBar1a'
        nested: [
          body: 'NestedFooBar1a'
        ]
        body: 'FooBar1a'
      ,
        _id: @postId2
        subdocument:
          body: 'SubdocumentFooBar2a'
        nested: [
          body: 'NestedFooBar2a'
        ]
        body: 'FooBar2a'
      ,
        _id: @postId3
        subdocument:
          body: 'SubdocumentFooBar3a'
        nested: [
          body: 'NestedFooBar3a'
        ]
        body: 'FooBar3a'
      ,
        _id: @postId4
        subdocument:
          body: 'SubdocumentFooBar4a'
        nested: [
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ]
        body: 'FooBar4a'
      ,
        _id: @postId5
        subdocument:
          body: 'SubdocumentFooBar5a'
        nested: [
          body: 'NestedFooBar5'
        ,
          body: 'NestedFooBar5a'
        ,
          body: 'NestedFooBar5'
        ]
        body: 'FooBar5a'
      ]
    testSetEqual test, @person2.nestedPosts,
      [
        _id: @postId1
        subdocument:
          body: 'SubdocumentFooBar1a'
        nested: [
          body: 'NestedFooBar1a'
        ]
        body: 'FooBar1a'
      ,
        _id: @postId4
        subdocument:
          body: 'SubdocumentFooBar4a'
        nested: [
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ]
        body: 'FooBar4a'
      ]

    test.equal _.omit(@person3, 'posts', 'subdocument', 'subdocumentsPosts', 'nestedPosts'),
      _id: @person3Id
      username: 'person3'
      displayName: 'Person 3'
      count: 8

    testSetEqual test, @person3.posts, []
    testSetEqual test, @person3.subdocument?.posts, []
    testSetEqual test, @person3.subdocumentsPosts,
      [
        _id: @postId1
        subdocument:
          body: 'SubdocumentFooBar1a'
        nested: [
          body: 'NestedFooBar1a'
        ]
        body: 'FooBar1a'
      ,
        _id: @postId2
        subdocument:
          body: 'SubdocumentFooBar2a'
        nested: [
          body: 'NestedFooBar2a'
        ]
        body: 'FooBar2a'
      ,
        _id: @postId3
        subdocument:
          body: 'SubdocumentFooBar3a'
        nested: [
          body: 'NestedFooBar3a'
        ]
        body: 'FooBar3a'
      ,
        _id: @postId5
        subdocument:
          body: 'SubdocumentFooBar5a'
        nested: [
          body: 'NestedFooBar5'
        ,
          body: 'NestedFooBar5a'
        ,
          body: 'NestedFooBar5'
        ]
        body: 'FooBar5a'
      ]
    testSetEqual test, @person3.nestedPosts,
      [
        _id: @postId2
        subdocument:
          body: 'SubdocumentFooBar2a'
        nested: [
          body: 'NestedFooBar2a'
        ]
        body: 'FooBar2a'
      ,
        _id: @postId3
        subdocument:
          body: 'SubdocumentFooBar3a'
        nested: [
          body: 'NestedFooBar3a'
        ]
        body: 'FooBar3a'
      ,
        _id: @postId4
        subdocument:
          body: 'SubdocumentFooBar4a'
        nested: [
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ]
        body: 'FooBar4a'
      ,
        _id: @postId5
        subdocument:
          body: 'SubdocumentFooBar5a'
        nested: [
          body: 'NestedFooBar5'
        ,
          body: 'NestedFooBar5a'
        ,
          body: 'NestedFooBar5'
        ]
        body: 'FooBar5a'
      ]

    Post.documents.update @postId5,
      $set:
        'subdocument.person':
          _id: @person3Id
    ,
      expect (error, res) =>
        test.isFalse error, error?.toString?() or error
        test.isTrue res

    # Wait so that observers have time to update documents
    waitForDatabase test, expect
,
  (test, expect) ->
    @post5 = Post.documents.findOne @postId5,
      transform: null # So that we can use test.equal

    test.equal @post5,
      _id: @postId5
      author:
        _id: @person1Id
        username: 'person1'
        displayName: 'Person 1'
      subdocument:
        person:
          _id: @person3Id
          displayName: 'Person 3'
          username: 'person3'
        persons: [
          _id: @person3Id
          displayName: 'Person 3'
          username: 'person3'
        ,
          _id: @person3Id
          displayName: 'Person 3'
          username: 'person3'
        ,
          _id: @person3Id
          displayName: 'Person 3'
          username: 'person3'
        ,
          _id: @person3Id
          displayName: 'Person 3'
          username: 'person3'
        ,
          _id: @person2Id
          displayName: 'Person 2'
          username: 'person2'
        ,
          _id: @person3Id
          displayName: 'Person 3'
          username: 'person3'
        ]
        slug: 'subdocument-prefix-foobar5a-subdocumentfoobar5a-suffix'
        body: 'SubdocumentFooBar5a'
      nested: [
        required:
          _id: @person3Id
          username: 'person3'
          displayName: 'Person 3'
        slug: 'nested-prefix-foobar5a-nestedfoobar5-suffix'
        body: 'NestedFooBar5'
      ,
        required:
          _id: @person3Id
          username: 'person3'
          displayName: 'Person 3'
        slug: 'nested-prefix-foobar5a-nestedfoobar5a-suffix'
        body: 'NestedFooBar5a'
      ,
        required:
          _id: @person3Id
          username: 'person3'
          displayName: 'Person 3'
        slug: 'nested-prefix-foobar5a-nestedfoobar5-suffix'
        body: 'NestedFooBar5'
      ]
      body: 'FooBar5a'
      slug: 'prefix-foobar5a-subdocumentfoobar5a-suffix'
      tags: [
        'tag-0-prefix-foobar5a-subdocumentfoobar5a-suffix'
        'tag-1-prefix-foobar5a-nestedfoobar5-suffix'
        'tag-2-prefix-foobar5a-nestedfoobar5a-suffix'
        'tag-3-prefix-foobar5a-nestedfoobar5-suffix'
      ]

    @person1 = Person.documents.findOne @person1Id,
      transform: null # So that we can use test.equal
    @person2 = Person.documents.findOne @person2Id,
      transform: null # So that we can use test.equal
    @person3 = Person.documents.findOne @person3Id,
      transform: null # So that we can use test.equal

    test.equal _.omit(@person1, 'posts', 'subdocument', 'subdocumentsPosts', 'nestedPosts'),
      _id: @person1Id
      username: 'person1'
      displayName: 'Person 1'
      count: 13

    testSetEqual test, @person1.posts,
      [
        _id: @postId1
        subdocument:
          body: 'SubdocumentFooBar1a'
        nested: [
          body: 'NestedFooBar1a'
        ]
        body: 'FooBar1a'
      ,
        _id: @postId2
        subdocument:
          body: 'SubdocumentFooBar2a'
        nested: [
          body: 'NestedFooBar2a'
        ]
        body: 'FooBar2a'
      ,
        _id: @postId3
        subdocument:
          body: 'SubdocumentFooBar3a'
        nested: [
          body: 'NestedFooBar3a'
        ]
        body: 'FooBar3a'
      ,
        _id: @postId4
        subdocument:
          body: 'SubdocumentFooBar4a'
        nested: [
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ]
        body: 'FooBar4a'
      ,
        _id: @postId5
        subdocument:
          body: 'SubdocumentFooBar5a'
        nested: [
          body: 'NestedFooBar5'
        ,
          body: 'NestedFooBar5a'
        ,
          body: 'NestedFooBar5'
        ]
        body: 'FooBar5a'
      ]
    testSetEqual test, @person1.subdocument?.posts,
      [
        _id: @postId1
        subdocument:
          body: 'SubdocumentFooBar1a'
        nested: [
          body: 'NestedFooBar1a'
        ]
        body: 'FooBar1a'
      ,
        _id: @postId3
        subdocument:
          body: 'SubdocumentFooBar3a'
        nested: [
          body: 'NestedFooBar3a'
        ]
        body: 'FooBar3a'
      ,
        _id: @postId4
        subdocument:
          body: 'SubdocumentFooBar4a'
        nested: [
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ]
        body: 'FooBar4a'
      ]
    testSetEqual test, @person1.subdocumentsPosts,
      [
        _id: @postId1
        subdocument:
          body: 'SubdocumentFooBar1a'
        nested: [
          body: 'NestedFooBar1a'
        ]
        body: 'FooBar1a'
      ,
        _id: @postId2
        subdocument:
          body: 'SubdocumentFooBar2a'
        nested: [
          body: 'NestedFooBar2a'
        ]
        body: 'FooBar2a'
      ,
        _id: @postId3
        subdocument:
          body: 'SubdocumentFooBar3a'
        nested: [
          body: 'NestedFooBar3a'
        ]
        body: 'FooBar3a'
      ,
        _id: @postId4
        subdocument:
          body: 'SubdocumentFooBar4a'
        nested: [
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ]
        body: 'FooBar4a'
      ]
    testSetEqual test, @person1.nestedPosts,
      [
        _id: @postId4
        subdocument:
          body: 'SubdocumentFooBar4a'
        nested: [
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ]
        body: 'FooBar4a'
      ]

    test.equal _.omit(@person2, 'posts', 'subdocument', 'subdocumentsPosts', 'nestedPosts'),
      _id: @person2Id
      username: 'person2'
      displayName: 'Person 2'
      count: 8

    testSetEqual test, @person2.posts, []
    testSetEqual test, @person2.subdocument?.posts,
      [
        _id: @postId2
        subdocument:
          body: 'SubdocumentFooBar2a'
        nested: [
          body: 'NestedFooBar2a'
        ]
        body: 'FooBar2a'
      ]
    testSetEqual test, @person2.subdocumentsPosts,
      [
        _id: @postId1
        subdocument:
          body: 'SubdocumentFooBar1a'
        nested: [
          body: 'NestedFooBar1a'
        ]
        body: 'FooBar1a'
      ,
        _id: @postId2
        subdocument:
          body: 'SubdocumentFooBar2a'
        nested: [
          body: 'NestedFooBar2a'
        ]
        body: 'FooBar2a'
      ,
        _id: @postId3
        subdocument:
          body: 'SubdocumentFooBar3a'
        nested: [
          body: 'NestedFooBar3a'
        ]
        body: 'FooBar3a'
      ,
        _id: @postId4
        subdocument:
          body: 'SubdocumentFooBar4a'
        nested: [
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ]
        body: 'FooBar4a'
      ,
        _id: @postId5
        subdocument:
          body: 'SubdocumentFooBar5a'
        nested: [
          body: 'NestedFooBar5'
        ,
          body: 'NestedFooBar5a'
        ,
          body: 'NestedFooBar5'
        ]
        body: 'FooBar5a'
      ]
    testSetEqual test, @person2.nestedPosts,
      [
        _id: @postId1
        subdocument:
          body: 'SubdocumentFooBar1a'
        nested: [
          body: 'NestedFooBar1a'
        ]
        body: 'FooBar1a'
      ,
        _id: @postId4
        subdocument:
          body: 'SubdocumentFooBar4a'
        nested: [
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ]
        body: 'FooBar4a'
      ]

    test.equal _.omit(@person3, 'posts', 'subdocument', 'subdocumentsPosts', 'nestedPosts'),
      _id: @person3Id
      username: 'person3'
      displayName: 'Person 3'
      count: 9

    testSetEqual test, @person3.posts, []
    testSetEqual test, @person3.subdocument?.posts,
      [
        _id: @postId5
        subdocument:
          body: 'SubdocumentFooBar5a'
        nested: [
          body: 'NestedFooBar5'
        ,
          body: 'NestedFooBar5a'
        ,
          body: 'NestedFooBar5'
        ]
        body: 'FooBar5a'
      ]
    testSetEqual test, @person3.subdocumentsPosts,
      [
        _id: @postId1
        subdocument:
          body: 'SubdocumentFooBar1a'
        nested: [
          body: 'NestedFooBar1a'
        ]
        body: 'FooBar1a'
      ,
        _id: @postId2
        subdocument:
          body: 'SubdocumentFooBar2a'
        nested: [
          body: 'NestedFooBar2a'
        ]
        body: 'FooBar2a'
      ,
        _id: @postId3
        subdocument:
          body: 'SubdocumentFooBar3a'
        nested: [
          body: 'NestedFooBar3a'
        ]
        body: 'FooBar3a'
      ,
        _id: @postId5
        subdocument:
          body: 'SubdocumentFooBar5a'
        nested: [
          body: 'NestedFooBar5'
        ,
          body: 'NestedFooBar5a'
        ,
          body: 'NestedFooBar5'
        ]
        body: 'FooBar5a'
      ]
    testSetEqual test, @person3.nestedPosts,
      [
        _id: @postId2
        subdocument:
          body: 'SubdocumentFooBar2a'
        nested: [
          body: 'NestedFooBar2a'
        ]
        body: 'FooBar2a'
      ,
        _id: @postId3
        subdocument:
          body: 'SubdocumentFooBar3a'
        nested: [
          body: 'NestedFooBar3a'
        ]
        body: 'FooBar3a'
      ,
        _id: @postId4
        subdocument:
          body: 'SubdocumentFooBar4a'
        nested: [
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ]
        body: 'FooBar4a'
      ,
        _id: @postId5
        subdocument:
          body: 'SubdocumentFooBar5a'
        nested: [
          body: 'NestedFooBar5'
        ,
          body: 'NestedFooBar5a'
        ,
          body: 'NestedFooBar5'
        ]
        body: 'FooBar5a'
      ]

    Post.documents.update @postId5,
      $set:
        'subdocument.person':
          _id: @person1Id
    ,
      expect (error, res) =>
        test.isFalse error, error?.toString?() or error
        test.isTrue res

    # Wait so that observers have time to update documents
    waitForDatabase test, expect
,
  (test, expect) ->
    @post5 = Post.documents.findOne @postId5,
      transform: null # So that we can use test.equal

    test.equal @post5,
      _id: @postId5
      author:
        _id: @person1Id
        username: 'person1'
        displayName: 'Person 1'
      subdocument:
        person:
          _id: @person1Id
          displayName: 'Person 1'
          username: 'person1'
        persons: [
          _id: @person3Id
          displayName: 'Person 3'
          username: 'person3'
        ,
          _id: @person3Id
          displayName: 'Person 3'
          username: 'person3'
        ,
          _id: @person3Id
          displayName: 'Person 3'
          username: 'person3'
        ,
          _id: @person3Id
          displayName: 'Person 3'
          username: 'person3'
        ,
          _id: @person2Id
          displayName: 'Person 2'
          username: 'person2'
        ,
          _id: @person3Id
          displayName: 'Person 3'
          username: 'person3'
        ]
        slug: 'subdocument-prefix-foobar5a-subdocumentfoobar5a-suffix'
        body: 'SubdocumentFooBar5a'
      nested: [
        required:
          _id: @person3Id
          username: 'person3'
          displayName: 'Person 3'
        slug: 'nested-prefix-foobar5a-nestedfoobar5-suffix'
        body: 'NestedFooBar5'
      ,
        required:
          _id: @person3Id
          username: 'person3'
          displayName: 'Person 3'
        slug: 'nested-prefix-foobar5a-nestedfoobar5a-suffix'
        body: 'NestedFooBar5a'
      ,
        required:
          _id: @person3Id
          username: 'person3'
          displayName: 'Person 3'
        slug: 'nested-prefix-foobar5a-nestedfoobar5-suffix'
        body: 'NestedFooBar5'
      ]
      body: 'FooBar5a'
      slug: 'prefix-foobar5a-subdocumentfoobar5a-suffix'
      tags: [
        'tag-0-prefix-foobar5a-subdocumentfoobar5a-suffix'
        'tag-1-prefix-foobar5a-nestedfoobar5-suffix'
        'tag-2-prefix-foobar5a-nestedfoobar5a-suffix'
        'tag-3-prefix-foobar5a-nestedfoobar5-suffix'
      ]

    @person1 = Person.documents.findOne @person1Id,
      transform: null # So that we can use test.equal
    @person2 = Person.documents.findOne @person2Id,
      transform: null # So that we can use test.equal
    @person3 = Person.documents.findOne @person3Id,
      transform: null # So that we can use test.equal

    test.equal _.omit(@person1, 'posts', 'subdocument', 'subdocumentsPosts', 'nestedPosts'),
      _id: @person1Id
      username: 'person1'
      displayName: 'Person 1'
      count: 14

    testSetEqual test, @person1.posts,
      [
        _id: @postId1
        subdocument:
          body: 'SubdocumentFooBar1a'
        nested: [
          body: 'NestedFooBar1a'
        ]
        body: 'FooBar1a'
      ,
        _id: @postId2
        subdocument:
          body: 'SubdocumentFooBar2a'
        nested: [
          body: 'NestedFooBar2a'
        ]
        body: 'FooBar2a'
      ,
        _id: @postId3
        subdocument:
          body: 'SubdocumentFooBar3a'
        nested: [
          body: 'NestedFooBar3a'
        ]
        body: 'FooBar3a'
      ,
        _id: @postId4
        subdocument:
          body: 'SubdocumentFooBar4a'
        nested: [
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ]
        body: 'FooBar4a'
      ,
        _id: @postId5
        subdocument:
          body: 'SubdocumentFooBar5a'
        nested: [
          body: 'NestedFooBar5'
        ,
          body: 'NestedFooBar5a'
        ,
          body: 'NestedFooBar5'
        ]
        body: 'FooBar5a'
      ]
    testSetEqual test, @person1.subdocument?.posts,
      [
        _id: @postId1
        subdocument:
          body: 'SubdocumentFooBar1a'
        nested: [
          body: 'NestedFooBar1a'
        ]
        body: 'FooBar1a'
      ,
        _id: @postId3
        subdocument:
          body: 'SubdocumentFooBar3a'
        nested: [
          body: 'NestedFooBar3a'
        ]
        body: 'FooBar3a'
      ,
        _id: @postId4
        subdocument:
          body: 'SubdocumentFooBar4a'
        nested: [
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ]
        body: 'FooBar4a'
      ,
        _id: @postId5
        subdocument:
          body: 'SubdocumentFooBar5a'
        nested: [
          body: 'NestedFooBar5'
        ,
          body: 'NestedFooBar5a'
        ,
          body: 'NestedFooBar5'
        ]
        body: 'FooBar5a'
      ]
    testSetEqual test, @person1.subdocumentsPosts,
      [
        _id: @postId1
        subdocument:
          body: 'SubdocumentFooBar1a'
        nested: [
          body: 'NestedFooBar1a'
        ]
        body: 'FooBar1a'
      ,
        _id: @postId2
        subdocument:
          body: 'SubdocumentFooBar2a'
        nested: [
          body: 'NestedFooBar2a'
        ]
        body: 'FooBar2a'
      ,
        _id: @postId3
        subdocument:
          body: 'SubdocumentFooBar3a'
        nested: [
          body: 'NestedFooBar3a'
        ]
        body: 'FooBar3a'
      ,
        _id: @postId4
        subdocument:
          body: 'SubdocumentFooBar4a'
        nested: [
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ]
        body: 'FooBar4a'
      ]
    testSetEqual test, @person1.nestedPosts,
      [
        _id: @postId4
        subdocument:
          body: 'SubdocumentFooBar4a'
        nested: [
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ]
        body: 'FooBar4a'
      ]

    test.equal _.omit(@person2, 'posts', 'subdocument', 'subdocumentsPosts', 'nestedPosts'),
      _id: @person2Id
      username: 'person2'
      displayName: 'Person 2'
      count: 8

    testSetEqual test, @person2.posts, []
    testSetEqual test, @person2.subdocument?.posts,
      [
        _id: @postId2
        subdocument:
          body: 'SubdocumentFooBar2a'
        nested: [
          body: 'NestedFooBar2a'
        ]
        body: 'FooBar2a'
      ]
    testSetEqual test, @person2.subdocumentsPosts,
      [
        _id: @postId1
        subdocument:
          body: 'SubdocumentFooBar1a'
        nested: [
          body: 'NestedFooBar1a'
        ]
        body: 'FooBar1a'
      ,
        _id: @postId2
        subdocument:
          body: 'SubdocumentFooBar2a'
        nested: [
          body: 'NestedFooBar2a'
        ]
        body: 'FooBar2a'
      ,
        _id: @postId3
        subdocument:
          body: 'SubdocumentFooBar3a'
        nested: [
          body: 'NestedFooBar3a'
        ]
        body: 'FooBar3a'
      ,
        _id: @postId4
        subdocument:
          body: 'SubdocumentFooBar4a'
        nested: [
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ]
        body: 'FooBar4a'
      ,
        _id: @postId5
        subdocument:
          body: 'SubdocumentFooBar5a'
        nested: [
          body: 'NestedFooBar5'
        ,
          body: 'NestedFooBar5a'
        ,
          body: 'NestedFooBar5'
        ]
        body: 'FooBar5a'
      ]
    testSetEqual test, @person2.nestedPosts,
      [
        _id: @postId1
        subdocument:
          body: 'SubdocumentFooBar1a'
        nested: [
          body: 'NestedFooBar1a'
        ]
        body: 'FooBar1a'
      ,
        _id: @postId4
        subdocument:
          body: 'SubdocumentFooBar4a'
        nested: [
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ]
        body: 'FooBar4a'
      ]

    test.equal _.omit(@person3, 'posts', 'subdocument', 'subdocumentsPosts', 'nestedPosts'),
      _id: @person3Id
      username: 'person3'
      displayName: 'Person 3'
      count: 8

    testSetEqual test, @person3.posts, []
    testSetEqual test, @person3.subdocument?.posts, []
    testSetEqual test, @person3.subdocumentsPosts,
      [
        _id: @postId1
        subdocument:
          body: 'SubdocumentFooBar1a'
        nested: [
          body: 'NestedFooBar1a'
        ]
        body: 'FooBar1a'
      ,
        _id: @postId2
        subdocument:
          body: 'SubdocumentFooBar2a'
        nested: [
          body: 'NestedFooBar2a'
        ]
        body: 'FooBar2a'
      ,
        _id: @postId3
        subdocument:
          body: 'SubdocumentFooBar3a'
        nested: [
          body: 'NestedFooBar3a'
        ]
        body: 'FooBar3a'
      ,
        _id: @postId5
        subdocument:
          body: 'SubdocumentFooBar5a'
        nested: [
          body: 'NestedFooBar5'
        ,
          body: 'NestedFooBar5a'
        ,
          body: 'NestedFooBar5'
        ]
        body: 'FooBar5a'
      ]
    testSetEqual test, @person3.nestedPosts,
      [
        _id: @postId2
        subdocument:
          body: 'SubdocumentFooBar2a'
        nested: [
          body: 'NestedFooBar2a'
        ]
        body: 'FooBar2a'
      ,
        _id: @postId3
        subdocument:
          body: 'SubdocumentFooBar3a'
        nested: [
          body: 'NestedFooBar3a'
        ]
        body: 'FooBar3a'
      ,
        _id: @postId4
        subdocument:
          body: 'SubdocumentFooBar4a'
        nested: [
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ]
        body: 'FooBar4a'
      ,
        _id: @postId5
        subdocument:
          body: 'SubdocumentFooBar5a'
        nested: [
          body: 'NestedFooBar5'
        ,
          body: 'NestedFooBar5a'
        ,
          body: 'NestedFooBar5'
        ]
        body: 'FooBar5a'
      ]

    Post.documents.update @postId5,
      $unset:
        'subdocument.person': ''
    ,
      expect (error, res) =>
        test.isFalse error, error?.toString?() or error
        test.isTrue res

    # Wait so that observers have time to update documents
    waitForDatabase test, expect
,
  (test, expect) ->
    @post5 = Post.documents.findOne @postId5,
      transform: null # So that we can use test.equal

    test.equal @post5,
      _id: @postId5
      author:
        _id: @person1Id
        username: 'person1'
        displayName: 'Person 1'
      subdocument:
        persons: [
          _id: @person3Id
          displayName: 'Person 3'
          username: 'person3'
        ,
          _id: @person3Id
          displayName: 'Person 3'
          username: 'person3'
        ,
          _id: @person3Id
          displayName: 'Person 3'
          username: 'person3'
        ,
          _id: @person3Id
          displayName: 'Person 3'
          username: 'person3'
        ,
          _id: @person2Id
          displayName: 'Person 2'
          username: 'person2'
        ,
          _id: @person3Id
          displayName: 'Person 3'
          username: 'person3'
        ]
        slug: 'subdocument-prefix-foobar5a-subdocumentfoobar5a-suffix'
        body: 'SubdocumentFooBar5a'
      nested: [
        required:
          _id: @person3Id
          username: 'person3'
          displayName: 'Person 3'
        slug: 'nested-prefix-foobar5a-nestedfoobar5-suffix'
        body: 'NestedFooBar5'
      ,
        required:
          _id: @person3Id
          username: 'person3'
          displayName: 'Person 3'
        slug: 'nested-prefix-foobar5a-nestedfoobar5a-suffix'
        body: 'NestedFooBar5a'
      ,
        required:
          _id: @person3Id
          username: 'person3'
          displayName: 'Person 3'
        slug: 'nested-prefix-foobar5a-nestedfoobar5-suffix'
        body: 'NestedFooBar5'
      ]
      body: 'FooBar5a'
      slug: 'prefix-foobar5a-subdocumentfoobar5a-suffix'
      tags: [
        'tag-0-prefix-foobar5a-subdocumentfoobar5a-suffix'
        'tag-1-prefix-foobar5a-nestedfoobar5-suffix'
        'tag-2-prefix-foobar5a-nestedfoobar5a-suffix'
        'tag-3-prefix-foobar5a-nestedfoobar5-suffix'
      ]

    @person1 = Person.documents.findOne @person1Id,
      transform: null # So that we can use test.equal
    @person2 = Person.documents.findOne @person2Id,
      transform: null # So that we can use test.equal
    @person3 = Person.documents.findOne @person3Id,
      transform: null # So that we can use test.equal

    test.equal _.omit(@person1, 'posts', 'subdocument', 'subdocumentsPosts', 'nestedPosts'),
      _id: @person1Id
      username: 'person1'
      displayName: 'Person 1'
      count: 13

    testSetEqual test, @person1.posts,
      [
        _id: @postId1
        subdocument:
          body: 'SubdocumentFooBar1a'
        nested: [
          body: 'NestedFooBar1a'
        ]
        body: 'FooBar1a'
      ,
        _id: @postId2
        subdocument:
          body: 'SubdocumentFooBar2a'
        nested: [
          body: 'NestedFooBar2a'
        ]
        body: 'FooBar2a'
      ,
        _id: @postId3
        subdocument:
          body: 'SubdocumentFooBar3a'
        nested: [
          body: 'NestedFooBar3a'
        ]
        body: 'FooBar3a'
      ,
        _id: @postId4
        subdocument:
          body: 'SubdocumentFooBar4a'
        nested: [
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ]
        body: 'FooBar4a'
      ,
        _id: @postId5
        subdocument:
          body: 'SubdocumentFooBar5a'
        nested: [
          body: 'NestedFooBar5'
        ,
          body: 'NestedFooBar5a'
        ,
          body: 'NestedFooBar5'
        ]
        body: 'FooBar5a'
      ]
    testSetEqual test, @person1.subdocument?.posts,
      [
        _id: @postId1
        subdocument:
          body: 'SubdocumentFooBar1a'
        nested: [
          body: 'NestedFooBar1a'
        ]
        body: 'FooBar1a'
      ,
        _id: @postId3
        subdocument:
          body: 'SubdocumentFooBar3a'
        nested: [
          body: 'NestedFooBar3a'
        ]
        body: 'FooBar3a'
      ,
        _id: @postId4
        subdocument:
          body: 'SubdocumentFooBar4a'
        nested: [
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ]
        body: 'FooBar4a'
      ]
    testSetEqual test, @person1.subdocumentsPosts,
      [
        _id: @postId1
        subdocument:
          body: 'SubdocumentFooBar1a'
        nested: [
          body: 'NestedFooBar1a'
        ]
        body: 'FooBar1a'
      ,
        _id: @postId2
        subdocument:
          body: 'SubdocumentFooBar2a'
        nested: [
          body: 'NestedFooBar2a'
        ]
        body: 'FooBar2a'
      ,
        _id: @postId3
        subdocument:
          body: 'SubdocumentFooBar3a'
        nested: [
          body: 'NestedFooBar3a'
        ]
        body: 'FooBar3a'
      ,
        _id: @postId4
        subdocument:
          body: 'SubdocumentFooBar4a'
        nested: [
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ]
        body: 'FooBar4a'
      ]
    testSetEqual test, @person1.nestedPosts,
      [
        _id: @postId4
        subdocument:
          body: 'SubdocumentFooBar4a'
        nested: [
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ]
        body: 'FooBar4a'
      ]

    test.equal _.omit(@person2, 'posts', 'subdocument', 'subdocumentsPosts', 'nestedPosts'),
      _id: @person2Id
      username: 'person2'
      displayName: 'Person 2'
      count: 8

    testSetEqual test, @person2.posts, []
    testSetEqual test, @person2.subdocument?.posts,
      [
        _id: @postId2
        subdocument:
          body: 'SubdocumentFooBar2a'
        nested: [
          body: 'NestedFooBar2a'
        ]
        body: 'FooBar2a'
      ]
    testSetEqual test, @person2.subdocumentsPosts,
      [
        _id: @postId1
        subdocument:
          body: 'SubdocumentFooBar1a'
        nested: [
          body: 'NestedFooBar1a'
        ]
        body: 'FooBar1a'
      ,
        _id: @postId2
        subdocument:
          body: 'SubdocumentFooBar2a'
        nested: [
          body: 'NestedFooBar2a'
        ]
        body: 'FooBar2a'
      ,
        _id: @postId3
        subdocument:
          body: 'SubdocumentFooBar3a'
        nested: [
          body: 'NestedFooBar3a'
        ]
        body: 'FooBar3a'
      ,
        _id: @postId4
        subdocument:
          body: 'SubdocumentFooBar4a'
        nested: [
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ]
        body: 'FooBar4a'
      ,
        _id: @postId5
        subdocument:
          body: 'SubdocumentFooBar5a'
        nested: [
          body: 'NestedFooBar5'
        ,
          body: 'NestedFooBar5a'
        ,
          body: 'NestedFooBar5'
        ]
        body: 'FooBar5a'
      ]
    testSetEqual test, @person2.nestedPosts,
      [
        _id: @postId1
        subdocument:
          body: 'SubdocumentFooBar1a'
        nested: [
          body: 'NestedFooBar1a'
        ]
        body: 'FooBar1a'
      ,
        _id: @postId4
        subdocument:
          body: 'SubdocumentFooBar4a'
        nested: [
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ]
        body: 'FooBar4a'
      ]

    test.equal _.omit(@person3, 'posts', 'subdocument', 'subdocumentsPosts', 'nestedPosts'),
      _id: @person3Id
      username: 'person3'
      displayName: 'Person 3'
      count: 8

    testSetEqual test, @person3.posts, []
    testSetEqual test, @person3.subdocument?.posts, []
    testSetEqual test, @person3.subdocumentsPosts,
      [
        _id: @postId1
        subdocument:
          body: 'SubdocumentFooBar1a'
        nested: [
          body: 'NestedFooBar1a'
        ]
        body: 'FooBar1a'
      ,
        _id: @postId2
        subdocument:
          body: 'SubdocumentFooBar2a'
        nested: [
          body: 'NestedFooBar2a'
        ]
        body: 'FooBar2a'
      ,
        _id: @postId3
        subdocument:
          body: 'SubdocumentFooBar3a'
        nested: [
          body: 'NestedFooBar3a'
        ]
        body: 'FooBar3a'
      ,
        _id: @postId5
        subdocument:
          body: 'SubdocumentFooBar5a'
        nested: [
          body: 'NestedFooBar5'
        ,
          body: 'NestedFooBar5a'
        ,
          body: 'NestedFooBar5'
        ]
        body: 'FooBar5a'
      ]
    testSetEqual test, @person3.nestedPosts,
      [
        _id: @postId2
        subdocument:
          body: 'SubdocumentFooBar2a'
        nested: [
          body: 'NestedFooBar2a'
        ]
        body: 'FooBar2a'
      ,
        _id: @postId3
        subdocument:
          body: 'SubdocumentFooBar3a'
        nested: [
          body: 'NestedFooBar3a'
        ]
        body: 'FooBar3a'
      ,
        _id: @postId4
        subdocument:
          body: 'SubdocumentFooBar4a'
        nested: [
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ]
        body: 'FooBar4a'
      ,
        _id: @postId5
        subdocument:
          body: 'SubdocumentFooBar5a'
        nested: [
          body: 'NestedFooBar5'
        ,
          body: 'NestedFooBar5a'
        ,
          body: 'NestedFooBar5'
        ]
        body: 'FooBar5a'
      ]

    Post.documents.update @postId5,
      $set:
        author:
          _id: @person2Id
    ,
      expect (error, res) =>
        test.isFalse error, error?.toString?() or error
        test.isTrue res

    # Wait so that observers have time to update documents
    waitForDatabase test, expect
,
  (test, expect) ->
    @post5 = Post.documents.findOne @postId5,
      transform: null # So that we can use test.equal

    test.equal @post5,
      _id: @postId5
      author:
        _id: @person2Id
        username: 'person2'
        displayName: 'Person 2'
      subdocument:
        persons: [
          _id: @person3Id
          displayName: 'Person 3'
          username: 'person3'
        ,
          _id: @person3Id
          displayName: 'Person 3'
          username: 'person3'
        ,
          _id: @person3Id
          displayName: 'Person 3'
          username: 'person3'
        ,
          _id: @person3Id
          displayName: 'Person 3'
          username: 'person3'
        ,
          _id: @person2Id
          displayName: 'Person 2'
          username: 'person2'
        ,
          _id: @person3Id
          displayName: 'Person 3'
          username: 'person3'
        ]
        slug: 'subdocument-prefix-foobar5a-subdocumentfoobar5a-suffix'
        body: 'SubdocumentFooBar5a'
      nested: [
        required:
          _id: @person3Id
          username: 'person3'
          displayName: 'Person 3'
        slug: 'nested-prefix-foobar5a-nestedfoobar5-suffix'
        body: 'NestedFooBar5'
      ,
        required:
          _id: @person3Id
          username: 'person3'
          displayName: 'Person 3'
        slug: 'nested-prefix-foobar5a-nestedfoobar5a-suffix'
        body: 'NestedFooBar5a'
      ,
        required:
          _id: @person3Id
          username: 'person3'
          displayName: 'Person 3'
        slug: 'nested-prefix-foobar5a-nestedfoobar5-suffix'
        body: 'NestedFooBar5'
      ]
      body: 'FooBar5a'
      slug: 'prefix-foobar5a-subdocumentfoobar5a-suffix'
      tags: [
        'tag-0-prefix-foobar5a-subdocumentfoobar5a-suffix'
        'tag-1-prefix-foobar5a-nestedfoobar5-suffix'
        'tag-2-prefix-foobar5a-nestedfoobar5a-suffix'
        'tag-3-prefix-foobar5a-nestedfoobar5-suffix'
      ]

    @person1 = Person.documents.findOne @person1Id,
      transform: null # So that we can use test.equal
    @person2 = Person.documents.findOne @person2Id,
      transform: null # So that we can use test.equal
    @person3 = Person.documents.findOne @person3Id,
      transform: null # So that we can use test.equal

    test.equal _.omit(@person1, 'posts', 'subdocument', 'subdocumentsPosts', 'nestedPosts'),
      _id: @person1Id
      username: 'person1'
      displayName: 'Person 1'
      count: 12

    testSetEqual test, @person1.posts,
      [
        _id: @postId1
        subdocument:
          body: 'SubdocumentFooBar1a'
        nested: [
          body: 'NestedFooBar1a'
        ]
        body: 'FooBar1a'
      ,
        _id: @postId2
        subdocument:
          body: 'SubdocumentFooBar2a'
        nested: [
          body: 'NestedFooBar2a'
        ]
        body: 'FooBar2a'
      ,
        _id: @postId3
        subdocument:
          body: 'SubdocumentFooBar3a'
        nested: [
          body: 'NestedFooBar3a'
        ]
        body: 'FooBar3a'
      ,
        _id: @postId4
        subdocument:
          body: 'SubdocumentFooBar4a'
        nested: [
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ]
        body: 'FooBar4a'
      ]
    testSetEqual test, @person1.subdocument?.posts,
      [
        _id: @postId1
        subdocument:
          body: 'SubdocumentFooBar1a'
        nested: [
          body: 'NestedFooBar1a'
        ]
        body: 'FooBar1a'
      ,
        _id: @postId3
        subdocument:
          body: 'SubdocumentFooBar3a'
        nested: [
          body: 'NestedFooBar3a'
        ]
        body: 'FooBar3a'
      ,
        _id: @postId4
        subdocument:
          body: 'SubdocumentFooBar4a'
        nested: [
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ]
        body: 'FooBar4a'
      ]
    testSetEqual test, @person1.subdocumentsPosts,
      [
        _id: @postId1
        subdocument:
          body: 'SubdocumentFooBar1a'
        nested: [
          body: 'NestedFooBar1a'
        ]
        body: 'FooBar1a'
      ,
        _id: @postId2
        subdocument:
          body: 'SubdocumentFooBar2a'
        nested: [
          body: 'NestedFooBar2a'
        ]
        body: 'FooBar2a'
      ,
        _id: @postId3
        subdocument:
          body: 'SubdocumentFooBar3a'
        nested: [
          body: 'NestedFooBar3a'
        ]
        body: 'FooBar3a'
      ,
        _id: @postId4
        subdocument:
          body: 'SubdocumentFooBar4a'
        nested: [
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ]
        body: 'FooBar4a'
      ]
    testSetEqual test, @person1.nestedPosts,
      [
        _id: @postId4
        subdocument:
          body: 'SubdocumentFooBar4a'
        nested: [
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ]
        body: 'FooBar4a'
      ]

    test.equal _.omit(@person2, 'posts', 'subdocument', 'subdocumentsPosts', 'nestedPosts'),
      _id: @person2Id
      username: 'person2'
      displayName: 'Person 2'
      count: 9

    testSetEqual test, @person2.posts,
      [
        _id: @postId5
        subdocument:
          body: 'SubdocumentFooBar5a'
        nested: [
          body: 'NestedFooBar5'
        ,
          body: 'NestedFooBar5a'
        ,
          body: 'NestedFooBar5'
        ]
        body: 'FooBar5a'
      ]
    testSetEqual test, @person2.subdocument?.posts,
      [
        _id: @postId2
        subdocument:
          body: 'SubdocumentFooBar2a'
        nested: [
          body: 'NestedFooBar2a'
        ]
        body: 'FooBar2a'
      ]
    testSetEqual test, @person2.subdocumentsPosts,
      [
        _id: @postId1
        subdocument:
          body: 'SubdocumentFooBar1a'
        nested: [
          body: 'NestedFooBar1a'
        ]
        body: 'FooBar1a'
      ,
        _id: @postId2
        subdocument:
          body: 'SubdocumentFooBar2a'
        nested: [
          body: 'NestedFooBar2a'
        ]
        body: 'FooBar2a'
      ,
        _id: @postId3
        subdocument:
          body: 'SubdocumentFooBar3a'
        nested: [
          body: 'NestedFooBar3a'
        ]
        body: 'FooBar3a'
      ,
        _id: @postId4
        subdocument:
          body: 'SubdocumentFooBar4a'
        nested: [
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ]
        body: 'FooBar4a'
      ,
        _id: @postId5
        subdocument:
          body: 'SubdocumentFooBar5a'
        nested: [
          body: 'NestedFooBar5'
        ,
          body: 'NestedFooBar5a'
        ,
          body: 'NestedFooBar5'
        ]
        body: 'FooBar5a'
      ]
    testSetEqual test, @person2.nestedPosts,
      [
        _id: @postId1
        subdocument:
          body: 'SubdocumentFooBar1a'
        nested: [
          body: 'NestedFooBar1a'
        ]
        body: 'FooBar1a'
      ,
        _id: @postId4
        subdocument:
          body: 'SubdocumentFooBar4a'
        nested: [
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ]
        body: 'FooBar4a'
      ]

    test.equal _.omit(@person3, 'posts', 'subdocument', 'subdocumentsPosts', 'nestedPosts'),
      _id: @person3Id
      username: 'person3'
      displayName: 'Person 3'
      count: 8

    testSetEqual test, @person3.posts, []
    testSetEqual test, @person3.subdocument?.posts, []
    testSetEqual test, @person3.subdocumentsPosts,
      [
        _id: @postId1
        subdocument:
          body: 'SubdocumentFooBar1a'
        nested: [
          body: 'NestedFooBar1a'
        ]
        body: 'FooBar1a'
      ,
        _id: @postId2
        subdocument:
          body: 'SubdocumentFooBar2a'
        nested: [
          body: 'NestedFooBar2a'
        ]
        body: 'FooBar2a'
      ,
        _id: @postId3
        subdocument:
          body: 'SubdocumentFooBar3a'
        nested: [
          body: 'NestedFooBar3a'
        ]
        body: 'FooBar3a'
      ,
        _id: @postId5
        subdocument:
          body: 'SubdocumentFooBar5a'
        nested: [
          body: 'NestedFooBar5'
        ,
          body: 'NestedFooBar5a'
        ,
          body: 'NestedFooBar5'
        ]
        body: 'FooBar5a'
      ]
    testSetEqual test, @person3.nestedPosts,
      [
        _id: @postId2
        subdocument:
          body: 'SubdocumentFooBar2a'
        nested: [
          body: 'NestedFooBar2a'
        ]
        body: 'FooBar2a'
      ,
        _id: @postId3
        subdocument:
          body: 'SubdocumentFooBar3a'
        nested: [
          body: 'NestedFooBar3a'
        ]
        body: 'FooBar3a'
      ,
        _id: @postId4
        subdocument:
          body: 'SubdocumentFooBar4a'
        nested: [
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ]
        body: 'FooBar4a'
      ,
        _id: @postId5
        subdocument:
          body: 'SubdocumentFooBar5a'
        nested: [
          body: 'NestedFooBar5'
        ,
          body: 'NestedFooBar5a'
        ,
          body: 'NestedFooBar5'
        ]
        body: 'FooBar5a'
      ]

    Post.documents.remove @postId5,
      expect (error) =>
        test.isFalse error, error?.toString?() or error

    # Wait so that observers have time to update documents
    waitForDatabase test, expect
,
  (test, expect) ->
    @person1 = Person.documents.findOne @person1Id,
      transform: null # So that we can use test.equal
    @person2 = Person.documents.findOne @person2Id,
      transform: null # So that we can use test.equal
    @person3 = Person.documents.findOne @person3Id,
      transform: null # So that we can use test.equal

    test.equal _.omit(@person1, 'posts', 'subdocument', 'subdocumentsPosts', 'nestedPosts'),
      _id: @person1Id
      username: 'person1'
      displayName: 'Person 1'
      count: 12

    testSetEqual test, @person1.posts,
      [
        _id: @postId1
        subdocument:
          body: 'SubdocumentFooBar1a'
        nested: [
          body: 'NestedFooBar1a'
        ]
        body: 'FooBar1a'
      ,
        _id: @postId2
        subdocument:
          body: 'SubdocumentFooBar2a'
        nested: [
          body: 'NestedFooBar2a'
        ]
        body: 'FooBar2a'
      ,
        _id: @postId3
        subdocument:
          body: 'SubdocumentFooBar3a'
        nested: [
          body: 'NestedFooBar3a'
        ]
        body: 'FooBar3a'
      ,
        _id: @postId4
        subdocument:
          body: 'SubdocumentFooBar4a'
        nested: [
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ]
        body: 'FooBar4a'
      ]
    testSetEqual test, @person1.subdocument?.posts,
      [
        _id: @postId1
        subdocument:
          body: 'SubdocumentFooBar1a'
        nested: [
          body: 'NestedFooBar1a'
        ]
        body: 'FooBar1a'
      ,
        _id: @postId3
        subdocument:
          body: 'SubdocumentFooBar3a'
        nested: [
          body: 'NestedFooBar3a'
        ]
        body: 'FooBar3a'
      ,
        _id: @postId4
        subdocument:
          body: 'SubdocumentFooBar4a'
        nested: [
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ]
        body: 'FooBar4a'
      ]
    testSetEqual test, @person1.subdocumentsPosts,
      [
        _id: @postId1
        subdocument:
          body: 'SubdocumentFooBar1a'
        nested: [
          body: 'NestedFooBar1a'
        ]
        body: 'FooBar1a'
      ,
        _id: @postId2
        subdocument:
          body: 'SubdocumentFooBar2a'
        nested: [
          body: 'NestedFooBar2a'
        ]
        body: 'FooBar2a'
      ,
        _id: @postId3
        subdocument:
          body: 'SubdocumentFooBar3a'
        nested: [
          body: 'NestedFooBar3a'
        ]
        body: 'FooBar3a'
      ,
        _id: @postId4
        subdocument:
          body: 'SubdocumentFooBar4a'
        nested: [
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ]
        body: 'FooBar4a'
      ]
    testSetEqual test, @person1.nestedPosts,
      [
        _id: @postId4
        subdocument:
          body: 'SubdocumentFooBar4a'
        nested: [
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ]
        body: 'FooBar4a'
      ]

    test.equal _.omit(@person2, 'posts', 'subdocument', 'subdocumentsPosts', 'nestedPosts'),
      _id: @person2Id
      username: 'person2'
      displayName: 'Person 2'
      count: 7

    testSetEqual test, @person2.posts, []
    testSetEqual test, @person2.subdocument?.posts,
      [
        _id: @postId2
        subdocument:
          body: 'SubdocumentFooBar2a'
        nested: [
          body: 'NestedFooBar2a'
        ]
        body: 'FooBar2a'
      ]
    testSetEqual test, @person2.subdocumentsPosts,
      [
        _id: @postId1
        subdocument:
          body: 'SubdocumentFooBar1a'
        nested: [
          body: 'NestedFooBar1a'
        ]
        body: 'FooBar1a'
      ,
        _id: @postId2
        subdocument:
          body: 'SubdocumentFooBar2a'
        nested: [
          body: 'NestedFooBar2a'
        ]
        body: 'FooBar2a'
      ,
        _id: @postId3
        subdocument:
          body: 'SubdocumentFooBar3a'
        nested: [
          body: 'NestedFooBar3a'
        ]
        body: 'FooBar3a'
      ,
        _id: @postId4
        subdocument:
          body: 'SubdocumentFooBar4a'
        nested: [
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ]
        body: 'FooBar4a'
      ]
    testSetEqual test, @person2.nestedPosts,
      [
        _id: @postId1
        subdocument:
          body: 'SubdocumentFooBar1a'
        nested: [
          body: 'NestedFooBar1a'
        ]
        body: 'FooBar1a'
      ,
        _id: @postId4
        subdocument:
          body: 'SubdocumentFooBar4a'
        nested: [
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ]
        body: 'FooBar4a'
      ]

    test.equal _.omit(@person3, 'posts', 'subdocument', 'subdocumentsPosts', 'nestedPosts'),
      _id: @person3Id
      username: 'person3'
      displayName: 'Person 3'
      count: 6

    testSetEqual test, @person3.posts, []
    testSetEqual test, @person3.subdocument?.posts, []
    testSetEqual test, @person3.subdocumentsPosts,
      [
        _id: @postId1
        subdocument:
          body: 'SubdocumentFooBar1a'
        nested: [
          body: 'NestedFooBar1a'
        ]
        body: 'FooBar1a'
      ,
        _id: @postId2
        subdocument:
          body: 'SubdocumentFooBar2a'
        nested: [
          body: 'NestedFooBar2a'
        ]
        body: 'FooBar2a'
      ,
        _id: @postId3
        subdocument:
          body: 'SubdocumentFooBar3a'
        nested: [
          body: 'NestedFooBar3a'
        ]
        body: 'FooBar3a'
      ]
    testSetEqual test, @person3.nestedPosts,
      [
        _id: @postId2
        subdocument:
          body: 'SubdocumentFooBar2a'
        nested: [
          body: 'NestedFooBar2a'
        ]
        body: 'FooBar2a'
      ,
        _id: @postId3
        subdocument:
          body: 'SubdocumentFooBar3a'
        nested: [
          body: 'NestedFooBar3a'
        ]
        body: 'FooBar3a'
      ,
        _id: @postId4
        subdocument:
          body: 'SubdocumentFooBar4a'
        nested: [
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ]
        body: 'FooBar4a'
      ]

    Post.documents.remove @postId2,
      expect (error) =>
        test.isFalse error, error?.toString?() or error

    # Wait so that observers have time to update documents
    waitForDatabase test, expect
,
  (test, expect) ->
    @person1 = Person.documents.findOne @person1Id,
      transform: null # So that we can use test.equal
    @person2 = Person.documents.findOne @person2Id,
      transform: null # So that we can use test.equal
    @person3 = Person.documents.findOne @person3Id,
      transform: null # So that we can use test.equal

    test.equal _.omit(@person1, 'posts', 'subdocument', 'subdocumentsPosts', 'nestedPosts'),
      _id: @person1Id
      username: 'person1'
      displayName: 'Person 1'
      count: 10

    testSetEqual test, @person1.posts,
      [
        _id: @postId1
        subdocument:
          body: 'SubdocumentFooBar1a'
        nested: [
          body: 'NestedFooBar1a'
        ]
        body: 'FooBar1a'
      ,
        _id: @postId3
        subdocument:
          body: 'SubdocumentFooBar3a'
        nested: [
          body: 'NestedFooBar3a'
        ]
        body: 'FooBar3a'
      ,
        _id: @postId4
        subdocument:
          body: 'SubdocumentFooBar4a'
        nested: [
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ]
        body: 'FooBar4a'
      ]
    testSetEqual test, @person1.subdocument?.posts,
      [
        _id: @postId1
        subdocument:
          body: 'SubdocumentFooBar1a'
        nested: [
          body: 'NestedFooBar1a'
        ]
        body: 'FooBar1a'
      ,
        _id: @postId3
        subdocument:
          body: 'SubdocumentFooBar3a'
        nested: [
          body: 'NestedFooBar3a'
        ]
        body: 'FooBar3a'
      ,
        _id: @postId4
        subdocument:
          body: 'SubdocumentFooBar4a'
        nested: [
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ]
        body: 'FooBar4a'
      ]
    testSetEqual test, @person1.subdocumentsPosts,
      [
        _id: @postId1
        subdocument:
          body: 'SubdocumentFooBar1a'
        nested: [
          body: 'NestedFooBar1a'
        ]
        body: 'FooBar1a'
      ,
        _id: @postId3
        subdocument:
          body: 'SubdocumentFooBar3a'
        nested: [
          body: 'NestedFooBar3a'
        ]
        body: 'FooBar3a'
      ,
        _id: @postId4
        subdocument:
          body: 'SubdocumentFooBar4a'
        nested: [
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ]
        body: 'FooBar4a'
      ]
    testSetEqual test, @person1.nestedPosts,
      [
        _id: @postId4
        subdocument:
          body: 'SubdocumentFooBar4a'
        nested: [
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ]
        body: 'FooBar4a'
      ]

    test.equal _.omit(@person2, 'posts', 'subdocument', 'subdocumentsPosts', 'nestedPosts'),
      _id: @person2Id
      username: 'person2'
      displayName: 'Person 2'
      count: 5

    testSetEqual test, @person2.posts, []
    testSetEqual test, @person2.subdocument?.posts, []
    testSetEqual test, @person2.subdocumentsPosts,
      [
        _id: @postId1
        subdocument:
          body: 'SubdocumentFooBar1a'
        nested: [
          body: 'NestedFooBar1a'
        ]
        body: 'FooBar1a'
      ,
        _id: @postId3
        subdocument:
          body: 'SubdocumentFooBar3a'
        nested: [
          body: 'NestedFooBar3a'
        ]
        body: 'FooBar3a'
      ,
        _id: @postId4
        subdocument:
          body: 'SubdocumentFooBar4a'
        nested: [
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ]
        body: 'FooBar4a'
      ]
    testSetEqual test, @person2.nestedPosts,
      [
        _id: @postId1
        subdocument:
          body: 'SubdocumentFooBar1a'
        nested: [
          body: 'NestedFooBar1a'
        ]
        body: 'FooBar1a'
      ,
        _id: @postId4
        subdocument:
          body: 'SubdocumentFooBar4a'
        nested: [
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ]
        body: 'FooBar4a'
      ]

    test.equal _.omit(@person3, 'posts', 'subdocument', 'subdocumentsPosts', 'nestedPosts'),
      _id: @person3Id
      username: 'person3'
      displayName: 'Person 3'
      count: 4

    testSetEqual test, @person3.posts, []
    testSetEqual test, @person3.subdocument?.posts, []
    testSetEqual test, @person3.subdocumentsPosts,
      [
        _id: @postId1
        subdocument:
          body: 'SubdocumentFooBar1a'
        nested: [
          body: 'NestedFooBar1a'
        ]
        body: 'FooBar1a'
      ,
        _id: @postId3
        subdocument:
          body: 'SubdocumentFooBar3a'
        nested: [
          body: 'NestedFooBar3a'
        ]
        body: 'FooBar3a'
      ]
    testSetEqual test, @person3.nestedPosts,
      [
        _id: @postId3
        subdocument:
          body: 'SubdocumentFooBar3a'
        nested: [
          body: 'NestedFooBar3a'
        ]
        body: 'FooBar3a'
      ,
        _id: @postId4
        subdocument:
          body: 'SubdocumentFooBar4a'
        nested: [
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ]
        body: 'FooBar4a'
      ]

    Post.documents.remove @postId3,
      expect (error) =>
        test.isFalse error, error?.toString?() or error

    # Wait so that observers have time to update documents
    waitForDatabase test, expect
,
  (test, expect) ->
    @person1 = Person.documents.findOne @person1Id,
      transform: null # So that we can use test.equal
    @person2 = Person.documents.findOne @person2Id,
      transform: null # So that we can use test.equal
    @person3 = Person.documents.findOne @person3Id,
      transform: null # So that we can use test.equal

    test.equal _.omit(@person1, 'posts', 'subdocument', 'subdocumentsPosts', 'nestedPosts'),
      _id: @person1Id
      username: 'person1'
      displayName: 'Person 1'
      count: 7

    testSetEqual test, @person1.posts,
      [
        _id: @postId1
        subdocument:
          body: 'SubdocumentFooBar1a'
        nested: [
          body: 'NestedFooBar1a'
        ]
        body: 'FooBar1a'
      ,
        _id: @postId4
        subdocument:
          body: 'SubdocumentFooBar4a'
        nested: [
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ]
        body: 'FooBar4a'
      ]
    testSetEqual test, @person1.subdocument?.posts,
      [
        _id: @postId1
        subdocument:
          body: 'SubdocumentFooBar1a'
        nested: [
          body: 'NestedFooBar1a'
        ]
        body: 'FooBar1a'
      ,
        _id: @postId4
        subdocument:
          body: 'SubdocumentFooBar4a'
        nested: [
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ]
        body: 'FooBar4a'
      ]
    testSetEqual test, @person1.subdocumentsPosts,
      [
        _id: @postId1
        subdocument:
          body: 'SubdocumentFooBar1a'
        nested: [
          body: 'NestedFooBar1a'
        ]
        body: 'FooBar1a'
      ,
        _id: @postId4
        subdocument:
          body: 'SubdocumentFooBar4a'
        nested: [
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ]
        body: 'FooBar4a'
      ]
    testSetEqual test, @person1.nestedPosts,
      [
        _id: @postId4
        subdocument:
          body: 'SubdocumentFooBar4a'
        nested: [
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ]
        body: 'FooBar4a'
      ]

    test.equal _.omit(@person2, 'posts', 'subdocument', 'subdocumentsPosts', 'nestedPosts'),
      _id: @person2Id
      username: 'person2'
      displayName: 'Person 2'
      count: 4

    testSetEqual test, @person2.posts, []
    testSetEqual test, @person2.subdocument?.posts, []
    testSetEqual test, @person2.subdocumentsPosts,
      [
        _id: @postId1
        subdocument:
          body: 'SubdocumentFooBar1a'
        nested: [
          body: 'NestedFooBar1a'
        ]
        body: 'FooBar1a'
      ,
        _id: @postId4
        subdocument:
          body: 'SubdocumentFooBar4a'
        nested: [
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ]
        body: 'FooBar4a'
      ]
    testSetEqual test, @person2.nestedPosts,
      [
        _id: @postId1
        subdocument:
          body: 'SubdocumentFooBar1a'
        nested: [
          body: 'NestedFooBar1a'
        ]
        body: 'FooBar1a'
      ,
        _id: @postId4
        subdocument:
          body: 'SubdocumentFooBar4a'
        nested: [
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ]
        body: 'FooBar4a'
      ]

    test.equal _.omit(@person3, 'posts', 'subdocument', 'subdocumentsPosts', 'nestedPosts'),
      _id: @person3Id
      username: 'person3'
      displayName: 'Person 3'
      count: 2

    testSetEqual test, @person3.posts, []
    testSetEqual test, @person3.subdocument?.posts, []
    testSetEqual test, @person3.subdocumentsPosts,
      [
        _id: @postId1
        subdocument:
          body: 'SubdocumentFooBar1a'
        nested: [
          body: 'NestedFooBar1a'
        ]
        body: 'FooBar1a'
      ]
    testSetEqual test, @person3.nestedPosts,
      [
        _id: @postId4
        subdocument:
          body: 'SubdocumentFooBar4a'
        nested: [
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4a'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ,
          body: 'NestedFooBar4'
        ]
        body: 'FooBar4a'
      ]

    for id in [@postId1, @postId2, @postId3, @postId4, @postId5]
      Post.documents.update
        _id: id
      ,
        $set:
          nested: []
      ,
        expect (error) =>
          test.isFalse error, error?.toString?() or error

    # Wait so that observers have time to update documents
    waitForDatabase test, expect
,
  (test, expect) ->
    @person1 = Person.documents.findOne @person1Id,
      transform: null # So that we can use test.equal
    @person2 = Person.documents.findOne @person2Id,
      transform: null # So that we can use test.equal
    @person3 = Person.documents.findOne @person3Id,
      transform: null # So that we can use test.equal

    test.equal _.omit(@person1, 'posts', 'subdocument', 'subdocumentsPosts', 'nestedPosts'),
      _id: @person1Id
      username: 'person1'
      displayName: 'Person 1'
      count: 6

    testSetEqual test, @person1.posts,
      [
        _id: @postId1
        subdocument:
          body: 'SubdocumentFooBar1a'
        nested: []
        body: 'FooBar1a'
      ,
        _id: @postId4
        subdocument:
          body: 'SubdocumentFooBar4a'
        nested: []
        body: 'FooBar4a'
      ]
    testSetEqual test, @person1.subdocument?.posts,
      [
        _id: @postId1
        subdocument:
          body: 'SubdocumentFooBar1a'
        nested: []
        body: 'FooBar1a'
      ,
        _id: @postId4
        subdocument:
          body: 'SubdocumentFooBar4a'
        nested: []
        body: 'FooBar4a'
      ]
    testSetEqual test, @person1.subdocumentsPosts,
      [
        _id: @postId1
        subdocument:
          body: 'SubdocumentFooBar1a'
        nested: []
        body: 'FooBar1a'
      ,
        _id: @postId4
        subdocument:
          body: 'SubdocumentFooBar4a'
        nested: []
        body: 'FooBar4a'
      ]
    testSetEqual test, @person1.nestedPosts, []

    test.equal _.omit(@person2, 'posts', 'subdocument', 'subdocumentsPosts', 'nestedPosts'),
      _id: @person2Id
      username: 'person2'
      displayName: 'Person 2'
      count: 2

    testSetEqual test, @person2.posts, []
    testSetEqual test, @person2.subdocument?.posts, []
    testSetEqual test, @person2.subdocumentsPosts,
      [
        _id: @postId1
        subdocument:
          body: 'SubdocumentFooBar1a'
        nested: []
        body: 'FooBar1a'
      ,
        _id: @postId4
        subdocument:
          body: 'SubdocumentFooBar4a'
        nested: []
        body: 'FooBar4a'
      ]
    testSetEqual test, @person2.nestedPosts, []

    test.equal _.omit(@person3, 'posts', 'subdocument', 'subdocumentsPosts', 'nestedPosts'),
      _id: @person3Id
      username: 'person3'
      displayName: 'Person 3'
      count: 1

    testSetEqual test, @person3.posts, []
    testSetEqual test, @person3.subdocument?.posts, []
    testSetEqual test, @person3.subdocumentsPosts,
      [
        _id: @postId1
        subdocument:
          body: 'SubdocumentFooBar1a'
        nested: []
        body: 'FooBar1a'
      ]
    testSetEqual test, @person3.nestedPosts, []
]

if Meteor.isServer
  testAsyncMulti 'peerdb - triggers', [
    (test, expect) ->
      testDefinition test

      Person.documents.insert
        username: 'person1'
        displayName: 'Person 1'
      ,
        expect (error, person1Id) =>
          test.isFalse error, error?.toString?() or error
          test.isTrue person1Id
          @person1Id = person1Id

      # Wait so that observers have time to update documents
      waitForDatabase test, expect
  ,
    (test, expect) ->
      @person1 = Person.documents.findOne @person1Id

      test.instanceOf @person1, Person

      test.equal plainObject(@person1),
        _id: @person1Id
        username: 'person1'
        displayName: 'Person 1'
        count: 0

      test.equal @person1.formatName(), 'person1-Person 1'

      Post.documents.insert
        author:
          _id: @person1._id
        subdocument: {}
        body: 'FooBar'
      ,
        expect (error, postId) =>
          test.isFalse error, error?.toString?() or error
          test.isTrue postId
          @postId = postId

      # Wait so that observers have time to update documents
      waitForDatabase test, expect
  ,
    (test, expect) ->
      @post = Post.documents.findOne @postId

      test.instanceOf @post, Post
      test.instanceOf @post.author, Person

      test.equal @post.author.formatName(), "#{ @person1.username }-#{ @person1.displayName }"

      test.equal plainObject(@post),
        _id: @postId
        author:
          _id: @person1._id
          username: @person1.username
          displayName: @person1.displayName
        subdocument: {}
        body: 'FooBar'
        tags: []

      SpecialPost.documents.insert
        author:
          _id: @person1._id
        subdocument: {}
        body: 'FooBar'
        special:
          _id: @person1._id
      ,
        expect (error, postId) =>
          test.isFalse error, error?.toString?() or error
          test.isTrue postId
          @specialPostId = postId

      # Wait so that observers have time to update documents
      waitForDatabase test, expect
  ,
    (test, expect) ->
      @specialPost = SpecialPost.documents.findOne @specialPostId

      test.instanceOf @specialPost, SpecialPost
      test.instanceOf @specialPost.author, Person
      test.instanceOf @specialPost.special, Person

      test.equal @specialPost.author.formatName(), "#{ @person1.username }-#{ @person1.displayName }"

      test.equal plainObject(@specialPost),
        _id: @specialPostId
        author:
          _id: @person1._id
          username: @person1.username
          displayName: @person1.displayName
        subdocument: {}
        body: 'FooBar'
        tags: []
        special:
          _id: @person1._id

      test.equal globalTestTriggerCounters[@postId], 1
      test.equal globalTestTriggerCounters[@specialPostId], 1

      Post.documents.update @postId,
        $set:
          body: 'FooBar 1'
      ,
        expect (error, res) =>
          test.isFalse error, error?.toString?() or error
          test.isTrue res

      SpecialPost.documents.update @specialPostId,
        $set:
          body: 'FooBar 1'
      ,
        expect (error, res) =>
          test.isFalse error, error?.toString?() or error
          test.isTrue res

      # Wait so that observers have time to update documents
      waitForDatabase test, expect
  ,
    (test, expect) ->
      @post = Post.documents.findOne @postId

      test.instanceOf @post, Post
      test.instanceOf @post.author, Person

      test.equal @post.author.formatName(), "#{ @person1.username }-#{ @person1.displayName }"

      test.equal plainObject(@post),
        _id: @postId
        author:
          _id: @person1._id
          username: @person1.username
          displayName: @person1.displayName
        subdocument: {}
        body: 'FooBar 1'
        tags: []

      @specialPost = SpecialPost.documents.findOne @specialPostId

      test.instanceOf @specialPost, SpecialPost
      test.instanceOf @specialPost.author, Person
      test.instanceOf @specialPost.special, Person

      test.equal @specialPost.author.formatName(), "#{ @person1.username }-#{ @person1.displayName }"

      test.equal plainObject(@specialPost),
        _id: @specialPostId
        author:
          _id: @person1._id
          username: @person1.username
          displayName: @person1.displayName
        subdocument: {}
        body: 'FooBar 1'
        tags: []
        special:
          _id: @person1._id

      test.equal globalTestTriggerCounters[@postId], 2
      test.equal globalTestTriggerCounters[@specialPostId], 2

      Post.documents.update @postId,
        $set:
          'subdocument.body': 'FooBar zzz'
      ,
        expect (error, res) =>
          test.isFalse error, error?.toString?() or error
          test.isTrue res

      SpecialPost.documents.update @specialPostId,
        $set:
          'subdocument.body': 'FooBar zzz'
      ,
        expect (error, res) =>
          test.isFalse error, error?.toString?() or error
          test.isTrue res

      # Wait so that observers have time to update documents
      waitForDatabase test, expect
  ,
    (test, expect) ->
      @post = Post.documents.findOne @postId

      test.instanceOf @post, Post
      test.instanceOf @post.author, Person

      test.equal @post.author.formatName(), "#{ @person1.username }-#{ @person1.displayName }"

      test.equal plainObject(@post),
        _id: @postId
        author:
          _id: @person1._id
          username: @person1.username
          displayName: @person1.displayName
        subdocument:
          body: 'FooBar zzz'
          slug: 'subdocument-prefix-foobar 1-foobar zzz-suffix'
        body: 'FooBar 1'
        slug: 'prefix-foobar 1-foobar zzz-suffix'
        tags: [
          'tag-0-prefix-foobar 1-foobar zzz-suffix'
        ]

      @specialPost = SpecialPost.documents.findOne @specialPostId

      test.instanceOf @specialPost, SpecialPost
      test.instanceOf @specialPost.author, Person
      test.instanceOf @specialPost.special, Person

      test.equal @specialPost.author.formatName(), "#{ @person1.username }-#{ @person1.displayName }"

      test.equal plainObject(@specialPost),
        _id: @specialPostId
        author:
          _id: @person1._id
          username: @person1.username
          displayName: @person1.displayName
        subdocument:
          body: 'FooBar zzz'
          slug: 'subdocument-prefix-foobar 1-foobar zzz-suffix'
        body: 'FooBar 1'
        slug: 'prefix-foobar 1-foobar zzz-suffix'
        tags: [
          'tag-0-prefix-foobar 1-foobar zzz-suffix'
        ]
        special:
          _id: @person1._id

      test.equal globalTestTriggerCounters[@postId], 2
      test.equal globalTestTriggerCounters[@specialPostId], 2
  ]

testAsyncMulti 'peerdb - reverse fields', [
  (test, expect) ->
    Person.documents.insert
      username: 'person1'
      displayName: 'Person 1'
      field1: 'Field 1 - 1'
      field2: 'Field 1 - 2'
    ,
      expect (error, person1Id) =>
        test.isFalse error, error?.toString?() or error
        test.isTrue person1Id
        @person1Id = person1Id

    # Wait so that observers have time to update documents
    waitForDatabase test, expect
,
  (test, expect) ->
    @person1 = Person.documents.findOne @person1Id,
      transform: null # So that we can use test.equal

    test.equal @person1,
      _id: @person1Id
      username: 'person1'
      displayName: 'Person 1'
      field1: 'Field 1 - 1'
      field2: 'Field 1 - 2'
      count: 0

    @changes = []

    @handle = Person.documents.find(@person1Id).observe
      changed: (newDocument, oldDocument) =>
        @changes.push newDocument

    Post.documents.insert
      author:
        _id: @person1._id
      subdocument:
        persons: []
        body: 'SubdocumentFooBar'
      nested: []
      body: 'FooBar'
    ,
      expect (error, postId) =>
        test.isFalse error, error?.toString?() or error
        test.isTrue postId
        @postId = postId

    # Wait so that observers have time to update documents
    waitForDatabase test, expect
,
  (test, expect) ->
    @person1 = Person.documents.findOne @person1Id,
      transform: null # So that we can use test.equal

    test.equal @person1,
      _id: @person1Id
      username: 'person1'
      displayName: 'Person 1'
      field1: 'Field 1 - 1'
      field2: 'Field 1 - 2'
      count: 1
      posts: [
        _id: @postId
        body: 'FooBar'
        nested: []
        subdocument:
          body: 'SubdocumentFooBar'
      ]

    # This test is checking that all fields in reverse field subdocuments are populated
    # from the beginning. Otherwise there might be a short but existing time when
    # document does not match the schema, and is published as such to the client.
    for person in @changes
      for post in person.posts
        test.equal post.body, 'FooBar'
        test.equal post.nested, []
        test.equal post.subdocument?.body, 'SubdocumentFooBar'

    @handle.stop()
]

testAsyncMulti 'peerdb - bulk insert', [
  (test, expect) ->
    @testContent = for i in [0..100]
      content: Random.id()

    ids = Recursive.documents.bulkInsert @testContent, expect (error, ids) =>
        test.isFalse error, error?.toString?() or error
        test.isTrue ids
        test.equal ids?.length, @testContent.length
        @testIds = ids

    test.isTrue ids
    test.equal ids?.length, @testContent.length

    # Wait so that observers have time to update documents
    waitForDatabase test, expect
,
  (test, expect) ->
    docs = Recursive.documents.find(
      _id:
        $in: @testIds
    ,
      fields:
        _id: 0
        content: 1
      transform: null # So that we can use test.equal
    ).fetch()

    testSetEqual test, @testContent, docs
,
  (test, expect) ->
    randomIds = for i in [0...100]
      Random.id()

    insertContent = for i in [0...100]
      other = randomIds[(i + 50) % 100]
      reverse = randomIds[(100 + i - 50) % 100]

      _id: randomIds[i]
      content: randomIds[i]
      other:
        _id: other
      reverse: [
        _id: reverse
      ]
    @testContent = for i in [0...100]
      other = randomIds[(i + 50) % 100]
      reverse = randomIds[(100 + i - 50) % 100]

      _id: randomIds[i]
      content: randomIds[i]
      other:
        _id: other
        content: other
      reverse: [
        _id: reverse
        content: reverse
      ]

    ids = Recursive.documents.bulkInsert insertContent, expect (error, ids) =>
      test.isFalse error, error?.toString?() or error
      test.isTrue ids
      test.equal ids, _.pluck @testContent, '_id'

    test.equal ids, _.pluck @testContent, '_id'

    # Wait so that observers have time to update documents
    waitForDatabase test, expect
,
  (test, expect) ->
    # We sleep a bit so that all changes get to the client, when rnning on the client.
    Meteor.setTimeout expect(), 200
,
  (test, expect) ->
    docs = Recursive.documents.find(
      _id:
        $in: _.pluck(@testContent, '_id')
    ,
      transform: null # So that we can use test.equal
    ).fetch()

    testSetEqual test, @testContent, docs
,
  (test, expect) ->
    # Test bulkInsert without any arguments.
    Recursive.documents.bulkInsert []
]

testAsyncMulti 'peerdb - bulk insert with subfield references', [
  (test, expect) ->
    itemId = Random.id()
    @item =
      _id: itemId
      hello: "world"
      toplevel:
        subitem:
          _id: itemId
        anotherA: "hello"
        anotherB: "world"
      # Do not set the array fields on purpose.

    SubfieldItem.documents.bulkInsert [@item], expect (error, ids) =>
      test.exception error if error
      test.equal ids, [itemId]
,
  (test, expect) ->
    insertedItem = SubfieldItem.documents.findOne @item._id
    test.equal insertedItem, _.extend {objectInArray: [], anArray: []}, @item
,
  (test, expect) ->
    itemId = Random.id()
    @item =
      _id: itemId
      hello: "world"
      toplevel:
        anotherA: "hello"
        anotherB: "world"
      # Do not set the array fields on purpose.

    SubfieldItem.documents.bulkInsert [@item], expect (error, ids) =>
      test.exception error if error
      test.equal ids, [itemId]
,
  (test, expect) ->
    insertedItem = SubfieldItem.documents.findOne @item._id
    item = _.extend {objectInArray: [], anArray: []}, @item
    # Missing references should be set to null.
    item.toplevel.subitem = null
    test.equal insertedItem, item
,
  (test, expect) ->
    itemId = Random.id()
    @item =
      _id: itemId
      hello: "world"
      toplevel:
        subitem:
          _id: itemId
        anotherA: "hello"
        anotherB: "world"
      objectInArray: [
        subitem:
          _id: itemId
        subitem2:
          _id: itemId
        otheritem: 42
      ]
      anArray: [
        _id: itemId
      ]

    SubfieldItem.documents.bulkInsert [@item], expect (error, ids) =>
      test.exception error if error
      test.equal ids, [itemId]
,
  (test, expect) ->
    insertedItem = SubfieldItem.documents.findOne @item._id
    test.equal insertedItem, @item

    # To make sure there are no residual observes going into @changes.
    waitForDatabase test, expect
,
  (test, expect) ->
    itemId = Random.id()
    @item =
      _id: itemId
      hello: "world"
      toplevel:
        subitem:
          _id: itemId
        anotherA: "hello"
        anotherB: "world"
      objectInArray: [
        subitem2:
          _id: itemId
        otheritem: 42
      ]
      anArray: [
        _id: itemId
      ]

    @changes = []

    initializing = true

    @handle = SubfieldItem.documents.find().observeChanges
      added: (id, fields) =>
        @changes.push {type: 'added', id, fields} unless initializing
      changed: (id, fields) =>
        @changes.push {type: 'changed', id, fields}

    initializing = false

    SubfieldItem.documents.bulkInsert [@item], expect (error, ids) =>
      test.exception error if error
      test.equal ids, [itemId]

    # Wait so that observers have time to update documents. It is not really necessary for PeerDB observes, but for
    # our observe above. It seems findOne return already correct document, while changed callback above is not
    # necessary already called and @changes does not contain all values.
    waitForDatabase test, expect
,
  (test, expect) ->
    insertedItem = SubfieldItem.documents.findOne @item._id
    test.equal insertedItem, @item

    test.equal @changes, [
      type: 'added'
      id: @item._id
      fields:
        hello: "world"
        toplevel:
          anotherA: "hello"
          anotherB: "world"
    ,
      type: 'changed'
      id: @item._id
      fields: _.pick @item, 'objectInArray', 'anArray', 'toplevel'
    ]

    @changes = []

    itemId = Random.id()
    @item._id = itemId

    SubfieldItem.documents.bulkInsert [@item], {dontDelay: ['toplevel.subitem']}, expect (error, ids) =>
      test.exception error if error
      test.equal ids, [itemId]

    # Wait so that observers have time to update documents. It is not really necessary for PeerDB observes, but for
    # our observe above. It seems findOne return already correct document, while changed callback above is not
    # necessary already called and @changes does not contain all values.
    waitForDatabase test, expect
,
  (test, expect) ->
    insertedItem = SubfieldItem.documents.findOne @item._id
    test.equal insertedItem, @item

    test.equal @changes, [
      type: 'added'
      id: @item._id
      fields: _.pick @item, 'hello', 'toplevel'
    ,
      type: 'changed'
      id: @item._id
      fields: _.pick @item, 'objectInArray', 'anArray'
    ]

    @handle.stop()
]

Tinytest.add 'peerdb - local documents', (test) ->
  testDefinition test

  class ReallyLocalPost extends Post
    @Meta
      name: 'ReallyLocalPost'
      collection: null
      local: true

  testDefinition test
