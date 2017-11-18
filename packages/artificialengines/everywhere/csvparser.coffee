AE = Artificial.Everywhere

class AE.CSVParser
  # Parses a CSV text and returns an array of rows, each row being an array of values.
  @parse: (text) ->
    # Adapted from Stack Overflow answer shared by user niry at https://stackoverflow.com/questions/8493195/how-can-i-parse-a-csv-string-with-javascript-which-contains-comma-in-data
    previous = ''
    currentRow = ['']
    rows = [currentRow]
    valueIndex = 0
    rowIndex = 0
    outsideQuotes = true

    for character in text
      if character is '"'
        currentRow[valueIndex] += character if outsideQuotes and character is previous
        outsideQuotes = not outsideQuotes

      else if character is ',' and outsideQuotes
        # Move to next value.
        valueIndex++
        currentRow[valueIndex] = ''
        character = ''

      else if character is '\n' and outsideQuotes
        # Move to next row. Remove \r if needed before moving on.
        currentRow[valueIndex] = currentRow[valueIndex].slice(0, -1) if previous is '\r'

        rowIndex++
        currentRow = ['']
        rows[rowIndex] = currentRow

        valueIndex = 0
        character = ''

      else
        currentRow[valueIndex] += character

      previous = character

    rows
