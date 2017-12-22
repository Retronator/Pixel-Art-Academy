AE = Artificial.Everywhere

# Date extensions.

# Creates a date from a date, string or object with any of the year, month, day, hours, minutes, seconds, milliseconds.
# Unlike the normal Date constructor, if you specify just some of the year/month/... properties, the higher order ones
# will be taken from the current date, not from Jan 1 1970. The lower ones (the smaller values) will be set to 0.
Date.fromObject = (options) ->
  throw new Meteor.Error 'argument-null', "Object must be provided." unless options?

  date = null

  if _.isDate options
    date = options

  else if _.isString options
    date = new Date options
    throw new Meteor.Error 'invalid-argument', "options is not a valid date string." if _.isNaN(date.getDate())

  else if _.isNumber options
    date = new Date options
    throw new Meteor.Error 'invalid-argument', "options is not a valid date number value." if _.isNaN(date.getDate())

  else if options.year? or options.month? or options.day? or options.hours? or options.minutes? or options.seconds? or options.milliseconds?
    parameters = [options.year, options.month, options.day, options.hours, options.minutes, options.seconds, options.milliseconds]
    parameterMethods = ['getFullYear', 'getMonth', 'getDate', 'getHours', 'getMinutes', 'getSeconds', 'getMilliseconds']
    parameterDefaults = [null, 0, 1, 0, 0, 0, 0]

    currentDate = new Date()
    insertCurrentDate = false

    for i in [parameters.length - 1..0]
      if parameters[i]?
        # Parameter in this place is already specified, but from now on,
        # any higher parameter missing should be replaced from current data.
        insertCurrentDate = true

      else if insertCurrentDate
        # Parameter in this place is missing and we should copy it from the current date.
        parameters[i] = currentDate[parameterMethods[i]]()

      else
        # Parameter in this place is missing and we should just use the default.
        parameters[i] = parameterDefaults[i]

    # Create the date in UTC time.
    dateTime = Date.UTC parameters...
    date = new Date dateTime

    # One and two digit years need to be explicitly set via setFullYear since otherwise they get added to 1900.
    if 0 <= options.year < 100
      date.setFullYear options.year

  else
    throw new Meteor.Error 'invalid-argument', "options is not in any of the valid formats."

  date

# How many days are in the month of this date.
Date::daysInMonth = ->
  AE.DateHelper.daysInMonth @getMonth(), @getFullYear()
