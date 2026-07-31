Tinytest.add 'artificialengines - lodash - arraysHaveSameValues', (test) ->
  firstInstance = {}
  secondInstance = {}

  test.isTrue _.arraysHaveSameValues [], []
  test.isTrue _.arraysHaveSameValues [1, 'two', true], [1, 'two', true]
  test.isTrue _.arraysHaveSameValues [firstInstance, secondInstance], [firstInstance, secondInstance]

  test.isFalse _.arraysHaveSameValues [1, 2], [1, 3]
  test.isFalse _.arraysHaveSameValues [firstInstance], [firstInstance, secondInstance]
  test.isFalse _.arraysHaveSameValues [firstInstance, secondInstance], [secondInstance, firstInstance]
  test.isFalse _.arraysHaveSameValues [firstInstance], [{}]
