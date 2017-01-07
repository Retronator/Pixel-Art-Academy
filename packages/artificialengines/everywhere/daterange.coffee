AE = Artificial.Everywhere
AM = null

Meteor.startup ->
  AM = Artificial.Mummification

# A reactive range of time between two dates (all dates where: start <= date < end).
class AE.DateRange
  # You can either set one or both of the start/end pair or an object with any of the
  # year/month/day/hour/minutes/seconds/milliseconds settings as in the Date.fromObject method. In that case the start
  # and end are placed at the edge of that range — if you specify just the year you will get a range of that whole year,
  # if you specify the year and month, you will get all the days in that month. If you specify just the month, the year
  # will be taken from the current date (and similar for the rest).
  constructor: (startOrObject, end) ->
    if _.isObject(startOrObject) and not _.isDate(startOrObject)
      object = startOrObject

      if object instanceof AE.DateRange
        start = object.start()
        end = object.end()

      else if object.start or object.end
        start = object.start
        end = object.end

      else if object.year? or object.month? or object.day? or object.hours? or object.minutes? or object.seconds? or object.milliseconds?
        start = Date.fromObject object

        # Create the end date object by taking the start date object and increasing by one the first defined property
        # from the end backwards. For example, if year and month are specified, end would be at month+1
        endObject = $.extend {}, object

        params = [object.year, object.month, object.day, object.hours, object.minutes, object.seconds, object.milliseconds]
        paramProperties = ['year', 'month', 'day', 'hours', 'minues', 'seconds', 'milliseconds']

        for i in [params.length - 1..0]
          if params[i]?
            # Increase property by 1.
            endObject[paramProperties[i]]++
            break

        # Create an actual date for the end of the range.
        end = Date.fromObject endObject

    else
      start = startOrObject

    # Make sure we have dates for the values.
    start = Date.fromObject start if start and not _.isDate start
    end = Date.fromObject end if end and not _.isDate end

    # The inclusive start of the date range.
    @start = new ReactiveField start

    # The exclusive end of the date range.
    @end = new ReactiveField end

  # Returns a modified mongo query where $gte/$lt conditions have been set for the given property.
  addToMongoQuery: (query, property) ->
    start = @start()
    end = @end()

    conditions = []

    if start
      condition = {}
      condition[property] = $gte: start
      conditions.push condition

    if end
      condition = {}
      condition[property] = $lt: end
      conditions.push condition

    AM.MongoHelper.addConditionsToQuery query, conditions

  ### Utility ###

  @typeName: -> 'AE.DateRange'
  typeName: -> @constructor.typeName()

  toJSONValue: ->
    EJSON.stringify
      start: @start()
      end: @end()

  clone: ->
    new AE.DateRange @start(), @end()

  @equals: (a, b) ->
    return false unless a and b
    a.start?() is b.start?() and a.end?() is b.end?()

  equals: (other) ->
    @constructor.equals @, other

  toString: ->
    "#{@typeName()}{#{@start()}, #{@end()}}"

EJSON.addType AE.DateRange.typeName(), (json) ->
  new AE.DateRange EJSON.parse json
