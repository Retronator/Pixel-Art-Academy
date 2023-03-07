Tinytest.add 'directcollection - basic', (test) ->
  testCollection = new DirectCollection 'direct'

  # First cleanup
  testCollection.remove {}

  test.equal testCollection.count({}), 0

  document1 =
    foo: 'bar1'
    faa: 'zar'
  document1Id = testCollection.insert document1

  # insert should not modify document1 directly
  test.isFalse document1._id
  document1._id = document1Id

  test.isTrue _.isString document1._id
  test.equal testCollection.findOne(_id: document1._id), document1
  test.equal testCollection.findOne(document1), document1

  document2 =
    _id: 'test'
    foo: 'bar2'
    faa: 'zar'
  document2Id = testCollection.insert document2

  test.equal document2._id, 'test'
  test.equal document2Id, 'test'

  test.equal testCollection.findOne(_id: document2._id), document2
  test.equal testCollection.findOne(document2), document2

  test.equal testCollection.count({}), 2

  test.equal testCollection.count(foo: 'bar2'), 1
  test.equal testCollection.count(faa: 'zar'), 2

  test.equal testCollection.findToArray({}), [document1, document2]

  correctOrder = 0

  testCollection.findEach {}, (document) ->
    Meteor._nodeCodeMustBeInFiber()

    Meteor._sleepForMs 50

    correctOrder++
    if correctOrder is 1
      test.equal document1, document
    else if correctOrder is 2
      test.equal document2, document
    else
      test.fail
        type: 'fail'
        message: "Invalid correctOrder: " + correctOrder

  test.equal correctOrder, 2

  test.throws ->
    testCollection.findEach {}, (document) ->
      throw new Error 'test'
  , /test/

  updates = testCollection.update {},
    $set:
      foo: 'bar1a'

  document1.foo = 'bar1a'

  test.equal updates, 1
  test.equal testCollection.findToArray({}), [document1, document2]

  updates = testCollection.update {},
    $set:
      faa: 'zar2'
  ,
    multi: true

  document1.faa = 'zar2'
  document2.faa = 'zar2'

  test.equal updates, 2
  test.equal testCollection.findToArray({}), [document1, document2]

  removed = testCollection.remove foo: 'bar2'

  test.equal removed, 1
  test.equal testCollection.count({}), 1

  removed = testCollection.remove {}

  test.equal removed, 1
  test.equal testCollection.count({}), 0

Tinytest.add 'directcollection - external db', (test) ->
  # Obtain current URL
  mongoUrl = null
  AppConfig.configurePackage 'mongo-livedata', (config) ->
    mongoUrl = "#{ config.url }_external"

  testCollection = new DirectCollection 'foo', null, mongoUrl

  # First cleanup
  testCollection.remove {}

  test.equal testCollection.count({}), 0

  document1 =
    foo: 'bar1'
    faa: 'zar'
  document1._id = testCollection.insert document1

  test.equal testCollection.findOne(_id: document1._id), document1
  test.equal testCollection.findOne(document1), document1

  test.equal DirectCollection.command({getLastError: 1}, null, mongoUrl)?.ok, 1

  # Ensure that insert went to the right database
  testCollection = new DirectCollection 'foo'

  test.isFalse testCollection.findOne _id: document1._id
