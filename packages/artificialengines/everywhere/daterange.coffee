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
  constructor: (startOrOptions, end) ->
    if _.isObject(startOrOptions) and not _.isDate(startOrOptions)
      options = startOrOptions

      if options instanceof AE.DateRange
        start = options.start()
        end = options.end()

      else if options.start or options.end
        start = options.start
        end = options.end

      else if options.year? or options.month? or options.day? or options.hours? or options.minutes? or options.seconds? or options.milliseconds?
        start = Date.fromObject options

        # Create the end date object by taking the start date object and increasing by one the first defined property
        # from the end backwards. For example, if year and month are specified, end would be at month+1
        endObject = _.clone options

        parameters = [options.year, options.month, options.day, options.hours, options.minutes, options.seconds, options.milliseconds]
        parameterProperties = ['year', 'month', 'day', 'hours', 'minutes', 'seconds', 'milliseconds']

        for i in [parameters.length - 1..0]
          if parameters[i]?
            # Increase property by 1.
            endObject[parameterProperties[i]]++
            break

        # Create an actual date for the end of the range.
        end = Date.fromObject endObject

    else
      start = startOrOptions

    # Make sure we have dates for the values.
    start = Date.fromObject start if start and not _.isDate start
    end = Date.fromObject end if end and not _.isDate end

    # The inclusive start of the date range.
    @start = new ReactiveField start

    # The exclusive end of the date range.
    @end = new ReactiveField end

  # Modifies a mongo query where $gte/$lt conditions have been set for the given property.
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
    a.start?().getTime() is b.start?().getTime() and a.end?().getTime() is b.end?().getTime()

  equals: (other) ->
    @constructor.equals @, other

  toString: ->
    "#{@typeName()}{#{@start()}, #{@end()}}"

EJSON.addType AE.DateRange.typeName(), (json) ->
  new AE.DateRange EJSON.parse json
