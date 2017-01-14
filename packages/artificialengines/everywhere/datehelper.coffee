AE = Artificial.Everywhere

# Date extensions and helper methods to deal with the date object.
class AE.DateHelper
  # How many days are in the specified month.
  @daysInMonth: (month, year) ->
    new Date(year, month + 1, 0).getDate()
