AM = Artificial.Mummification

class AM.MongoHelper
  # returns a new query where the additional conditions have been
  # merged to the query, potentially adding the $and operation.
  @addConditionsToQuery = (query, conditions) ->
    query = EJSON.clone query

    for condition in conditions
      # Condition should be an object with one key, operating on one property.
      property = _.first _.keys condition

      if query[property]
        # We already have this property so we'll need an $and query. Take all the queries and put them into an array.
        $and = [condition]
        for key, value of query
          newCondition = {}
          newCondition[key] = value
          $and.push newCondition

          delete query[key]

        # Create the $and operation with the collected conditions.
        query.$and = $and

      else if query.$and
        # We have the $and property so simply push our condition.
        query.$and.push condition

      else
        # this is not an $and query and property is not yet set. We can simply set it.
        query[property] = condition[property]

    query
