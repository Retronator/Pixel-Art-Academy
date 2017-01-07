AE = Artificial.Everywhere

# Creates a date from a date, string or object with any of the year, month, day, hours, minutes, seconds, milliseconds.
# Unlike the normal Date constructor, if you specify just some of the year/month/... properties, the higher order ones
# will be taken from the current date, not from Jan 1 1970. The lower ones (the smaller values) will be set to 0.
Date.fromObject = (object) ->
  throw new Meteor.Error 'argument-null', "Object must be provided." unless object?

  date = null

  if _.isDate object
    date = object

  else if _.isString object
    date = new Date object
    throw new Meteor.Error 'invalid-argument', "object is not a valid date string." if _.isNaN(date.getDate())

  else if _.isNumber object
    date = new Date object
    throw new Meteor.Error 'invalid-argument', "object is not a valid date number value." if _.isNaN(date.getDate())

  else if object.year? or object.month? or object.day? or object.hours? or object.minutes? or object.seconds? or object.milliseconds?
    params = [object.year, object.month, object.day, object.hours, object.minutes, object.seconds, object.milliseconds]
    paramMethods = ['getFullYear', 'getMonth', 'getDate', 'getHours', 'getMinutes', 'getSeconds', 'getMilliseconds']

    currentDate = new Date()
    insertCurrentDate = false

    for i in [params.length - 1..0]
      if params[i]?
        insertCurrentDate = true

      else if insertCurrentDate
        params[i] = currentDate[paramMethods[i]]()

    params = _.without params, undefined
    date = new Date params...

    # One and two digit years need to be explicitly set via setFullYear since otherwise they get added to 1900.
    if 0 <= object.year < 100
      date.setFullYear object.year

  else
    throw new Meteor.Error 'invalid-argument', "object is not in any of the valid formats."

  date

# How many days are in the month of this date.
Date::daysInMonth = ->
  AE.DateHelper.daysInMonth @getMonth(), @getFullYear()
