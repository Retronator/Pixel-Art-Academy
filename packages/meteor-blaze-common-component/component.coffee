# @nodoc
expirationMsFromDuration = (duration) ->
  # Default values from  moment/src/lib/duration/humanize.js.
  thresholds =
    s: 45 # seconds to minute
    m: 45 # minutes to hour
    h: 22 # hours to day

  seconds = Math.round(duration.as 's')
  minutes = Math.round(duration.as 'm')
  hours = Math.round(duration.as 'h')

  if seconds < thresholds.s
    (thresholds.s - seconds) * 1000 + 500
  else if minutes < thresholds.m
    (60 - seconds % 60) * 1000 + 500
  else if hours < thresholds.h
    ((60 * 60) - seconds % (60 * 60)) * 1000 + 500
  else
    ((24 * 60 * 60) - seconds % (24 * 60 * 60)) * 1000 + 500

# @nodoc
invalidateAfter = (expirationMs) ->
  computation = Tracker.currentComputation
  handle = Meteor.setTimeout =>
    computation.invalidate()
  ,
    expirationMs
  computation.onInvalidate =>
    Meteor.clearTimeout handle if handle
    handle = null

# A base class for components with additional methods for various useful features.
#
# In addition to methods/template helpers available when using this class as a base
# class, [`insertDOMElement`](https://github.com/peerlibrary/meteor-blaze-components#user-content-reference_instance_insertDOMElement),
# [`moveDOMElement`](https://github.com/peerlibrary/meteor-blaze-components#user-content-reference_instance_moveDOMElement),
# and [`removeDOMElement`](https://github.com/peerlibrary/meteor-blaze-components#user-content-reference_instance_removeDOMElement) have been
# configured to call corresponding methods in mixins, if they exist, as it is
# described [in Blaze Components documentation](https://github.com/peerlibrary/meteor-blaze-components#animations).
# This allows you to use mixins which add animations to your components.
class CommonComponent extends share.CommonComponentBase
  # @nodoc
  insertDOMElement: (parent, node, before, next) ->
    next ?= =>
      super parent, node, before
      true

    return next() unless @callFirstWith @, 'insertDOMElement', parent, node, before, next

    # It has been handled.
    true

  # @nodoc
  moveDOMElement: (parent, node, before, next) ->
    next ?= =>
      super parent, node, before
      true

    return next() unless @callFirstWith @, 'moveDOMElement', parent, node, before, next

    # It has been handled.
    true

  # @nodoc
  removeDOMElement: (parent, node, next) ->
    next ?= =>
      super parent, node
      true

    return next() unless @callFirstWith @, 'removeDOMElement', parent, node, next

    # It has been handled.
    true

  # Template helper which resolves [Flow Router](https://github.com/kadirahq/flow-router) path definition and arguments to
  # URL paths using [`FlowRouter.path`](https://github.com/kadirahq/flow-router#flowrouterpathpathdef-params-queryparams).
  # It works when Flow Router package is available.
  #
  # @example
  #   {{pathFor 'Post.edit' params=data}}
  #
  # @param [String] pathName Path name or path definition.
  # @param [Object] kwargs
  # @option kwargs [Object] params Parameters to resolve variables in the path.
  # @option kwargs [Object] query Query string values to be added to the URL path.
  # @return [String]
  pathFor: (pathName, kwargs) ->
    kwargs = kwargs.hash if kwargs instanceof Spacebars.kw

    params = kwargs?.params or {}
    queryParams = kwargs?.query or {}

    FlowRouter = Package['peerlibrary:flow-router']?.FlowRouter or Package['kadira:flow-router']?.FlowRouter

    throw new Error "FlowRouter package missing." unless FlowRouter

    FlowRouter.path pathName, params, queryParams

  # Returns the [`Meteor.userId()`](http://docs.meteor.com/#/full/meteor_users) value.
  # Use it instead of [`currentUser`](http://docs.meteor.com/#/full/template_currentuser) template helper when you want
  # to check only if user is logged in or not.
  #
  # @example
  #   {{#if currentUserId}}
  #     ...
  #   {{/if}}
  #
  # @return [String]
  currentUserId: ->
    Meteor.userId()

  # Extended version of [`currentUser`](http://docs.meteor.com/#/full/template_currentuser) template helper which
  # can optionally limit fields returned in the user object. This limits template helper's reactivity as well.
  # It works when [peerlibrary:user-extra](https://github.com/peerlibrary/meteor-user-extra) package is available
  # and falls back to old behavior if it is not.
  #
  # @param [String] userId
  # @param [Object] fields [MongoDB fields specifier](http://docs.meteor.com/#/full/fieldspecifiers).
  # @return [Object]
  currentUser: (userId, fields) ->
    if not fields and _.isObject userId
      fields = userId
      userId = null

    fields = fields.hash if fields instanceof Spacebars.kw

    Meteor.user userId, fields

  # Returns `true` if any of the arguments is true.
  #
  # @example
  #   {{#if $or isAdmin isModerator}}
  #     ...
  #   {{/if}}
  #
  # @return [Boolean]
  $or: (args...) ->
    # Removing kwargs.
    args.pop() if args[args.length - 1] instanceof Spacebars.kw

    _.some args

  # Returns `true` if all of the arguments are true.
  #
  # @example
  #   {{#if $and currentUserId subscriptionReady}}
  #     ...
  #   {{/if}}
  #
  # @return [Boolean]
  $and: (args...) ->
    # Removing kwargs.
    args.pop() if args[args.length - 1] instanceof Spacebars.kw

    _.every args

  # Returns `true` if the first argument is false, `false` otherwise.
  #
  # @example
  #   {{#if $not isRobot}}
  #     ...
  #   {{/if}}
  #
  # @return [Boolean]
  $not: (args...) ->
    # Removing kwargs.
    args.pop() if args[args.length - 1] instanceof Spacebars.kw

    not args[0]

  # Joins arguments using the `delimiter`.
  #
  # @example
  #   {{> EditorComponent args id=($join '-' 'edit-body' _id)}}
  #
  # @param [String] delimiter
  # @return [String]
  $join: (delimiter, args...) ->
    # Removing kwargs.
    args.pop() if args[args.length - 1] instanceof Spacebars.kw

    args.join delimiter

  # @property [String] Default localized date-time format. Example: `Thu, Sep 4 1986 8:30 PM`.
  DEFAULT_DATETIME_FORMAT:
    'llll'

  # @property [String] Default localized date format. Example: `Sep 4 1986`.
  DEFAULT_DATE_FORMAT:
    'll'

  # @property [String] Default localized time format. Example: `8:30 PM`.
  DEFAULT_TIME_FORMAT:
    'LT'

  # [Format](http://momentjs.com/docs/#/displaying/format/) a datetime using provided `format` string.
  #
  # @example
  #   {{formatDate createdAt DEFAULT_DATETIME_FORMAT}}
  #
  # @param [Date] date
  # @param [String] format
  # @return [String]
  formatDate: (date, format) ->
    format = null if format instanceof Spacebars.kw

    moment(date).format format

  # Reactively format a datetime into a relative from now and localized string. As times progresses, string is
  # automatically updated. Strings are made using [moment.js `fromNow` function](http://momentjs.com/docs/#/displaying/fromnow/).
  #
  # Example output: `3 months ago`.
  #
  # @example
  #   <span class="timestamp" title="{{formatDate createdAt DEFAULT_DATETIME_FORMAT}}">{{fromNow createdAt}}</span>
  #
  # @param [Date] date
  # @param [Boolean] withoutSuffix Should `ago` suffix be omitted, default is `false`.
  # @return [String]
  fromNow: (date, withoutSuffix) ->
    withoutSuffix = false if withoutSuffix instanceof Spacebars.kw

    momentDate = moment(date)

    if Tracker.active
      absoluteDuration = moment.duration(to: momentDate, from: moment()).abs()
      expirationMs = expirationMsFromDuration absoluteDuration
      invalidateAfter expirationMs

    momentDate.fromNow withoutSuffix

  # Format a datetime into a relative from now and localized string using friendly day names.
  # Strings are made using [moment.js `calendar` function](http://momentjs.com/docs/#/displaying/calendar-time/).
  #
  # Example output: `last Sunday at 2:30 AM`.
  #
  # @example
  #   <span title="{{formatDate playStart DEFAULT_DATETIME_FORMAT}}">{{calendarDate playStart}}</span>
  #
  # @param [Date] date
  # @return [String]
  calendarDate: (date) ->
    moment(date).calendar null,
      lastDay: '[yesterday at] LT',
      sameDay: '[today at] LT',
      nextDay: '[tomorrow at] LT',
      lastWeek: '[last] dddd [at] LT',
      nextWeek: 'dddd [at] LT',
      sameElse: @DEFAULT_DATETIME_FORMAT

  # Similar to [moment.js `humanize` function](http://momentjs.com/docs/#/durations/humanize/) it returns
  # a friendly string representing the duration.
  #
  # It is build from `size` number of units. For example, for `size` equals 2, the string could be `2 days 1 hour`.
  # For `size` equals 3, `2 days 1 hour 44 minutes`. If you omit `size`, full precision is used.
  #
  # If `from` or `to` are `null`, the output is reactive.
  #
  # @example
  #   <span title="{{formatDuration startedAt endedAt}}">{{formatDuration startedAt endedAt 2}}</span>
  #
  # @example
  #   <span title="{{formatDuration startedAt null}}">{{formatDuration startedAt null 3}}</span>
  #
  # @param [Date] from If `null`, current time is used.
  # @param [Date] to If `null`, current time is used.
  # @param [Number] size Duration description precision: from how many units it should be build.
  # @return [String]
  # @todo Support localization.
  formatDuration: (from, to, size) ->
    size = null if size instanceof Spacebars.kw

    reactive = not (from and to)

    from ?= new Date()
    to ?= new Date()

    duration = moment.duration({from, to}).abs()

    minutes = Math.round(duration.as 'm') % 60
    hours = Math.round(duration.as 'h') % 24
    days = Math.round(duration.as 'd') % 7
    weeks = Math.floor(Math.round(duration.as 'd') / 7)

    partials = [
      key: 'week'
      value: weeks
    ,
      key: 'day'
      value: days
    ,
      key: 'hour'
      value: hours
    ,
      key: 'minute'
      value: minutes
    ]

    # Trim zero values from the left.
    while partials.length and partials[0].value is 0
      partials.shift()

    # Cut the length to provided size.
    partials = partials[0...size] if size

    if reactive and Tracker.active
      seconds = Math.round(duration.as 's')

      if partials.length
        lastPartial = partials[partials.length - 1].key
        if lastPartial is 'minute'
          expirationMs = (60 - seconds % 60) * 1000 + 500
        else if lastPartial is 'hour'
          expirationMs = ((60 * 60) - seconds % (60 * 60)) * 1000 + 500
        else
          expirationMs = ((24 * 60 * 60) - seconds % (24 * 60 * 60)) * 1000 + 500
      else
        assert seconds < 60, seconds
        expirationMs = (60 - seconds) * 1000 + 500

      invalidateAfter expirationMs

    partials = for {key, value} in partials
      # Maybe there are some zero values in-between, skip them.
      continue if value is 0

      key = "#{key}s" if value isnt 1

      "#{value} #{key}"

    if partials.length
      partials.join ' '
    else
      "less than a minute"

  # Returns the CSS prefix used by the current browser.
  #
  # @return [String]
  cssPrefix: ->
    unless '_cssPrefix' of @
      styles = window.getComputedStyle document.documentElement, ''
      @_cssPrefix = (_.toArray(styles).join('').match(/-(moz|webkit|ms)-/) or (styles.OLink is '' and ['', 'o']))[1]
    @_cssPrefix

  # Construct a `Date` object from inputs of HTML5 form fields of type `date` and `time`.
  #
  # @example
  #   this.constructDatetime(this.$('[name="start-date"]').val(), this.$('[name="start-time"]').val())
  #
  # @param [String] date
  # @param [String] time
  # @return [Date]
  constructDatetime: (date, time) ->
    # TODO: Make a warning or something?
    throw new Error "Both date and time fields are required together." if (date and not time) or (time and not date)

    return null unless date and time

    moment("#{date} #{time}", 'YYYY-MM-DD HH:mm').toDate()
