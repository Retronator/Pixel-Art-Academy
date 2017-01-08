# Pixel Art Academy Code Style

(Based on [PeerLibrary Code Style](https://github.com/peerlibrary/peerlibrary/wiki/Code-Style) with some modifications and extensions.)

## Main guidelines

### 1. Consistency

If in doubt, try to find similar existing code and style your code the same.

> Motivation: We never assume one person will be responsible for one part of the code — everyone should be comfortable to understand and adjust any piece of code. Having the same code style everywhere helps to normalize this.

This is why we also stick to only one language/tool for the task:

- [CoffeeScript](http://coffeescript.org/) for code (and no JS),
- [Stylus](http://learnboost.github.io/stylus/) for style (and no pure CSS, SCSS, Sass, Less …),
- Spacebars with [Meteor Blaze Components](https://github.com/peerlibrary/meteor-blaze-components) for HTML (and no native Blaze templates or React or Angular …). 

### 2. Comment everything!

Your comments should describe, in plain English, what each code segment is doing. The actual code is the realization of the goal you set out with the comment.

Example:

        # Calculate minimum viewport ratio.
        minViewportSize =
          width: scaledSafeAreaWidth
          height: scaledSafeAreaHeight

        # Make sure the aspect ratio is within range.
        minViewportAspectRatio = minViewportSize.width / minViewportSize.height
        minViewportAspectRatio = Math.max minViewportAspectRatio, minAspectRatio if minAspectRatio
        minViewportAspectRatio = Math.min minViewportAspectRatio, maxAspectRatio if maxAspectRatio

        # If image is too tall, expand left/right.
        minViewportSize.width = minViewportSize.height * minViewportAspectRatio if safeAreaAspectRatio < minViewportAspectRatio

        # If image is too wide, expand up/down.
        minViewportSize.height = usableClientSize.width / minViewportAspectRatio if safeAreaAspectRatio > minViewportAspectRatio

I should not need to reverse engineer the code to understand what this algorithm does. I should be able to read the comments to know what it does. Only if something is not behaving properly, should I need to inspect the code itself. 

You should also explain anything that is not obvious from reading the code.

> Motivation: As a coder you leave comments, not only for yourself, but for everyone, explaining how something is implemented, especially when it is not obvious. Maybe you came across some problems, while doing it the usual way, so you used a different approach. If you don't mention that, somebody coming after you might want to change it to the conventional way and run into the same problems. If you leave a comment, that information is not lost.

Example:

    userId = Meteor.userId()

    throw new AE.UnauthorizedException "You must be logged in to add an email." unless userId

    Accounts.addEmail userId, emailAddress

    # Also update registered_emails. We need to fetch user here so it has the updated email fields.
    AccountsEmailsField.updateEmails user: Retronator.user()

Looking at this code without the comment, I would be tempted to refactor and just fetch the user at the start and use `user._id` instead of `userId`. However, Accounts.addEmail modifies the user document, meaning we would be passing a stale object to `updateEmails`, leading to wrong behavior (true story).

#### Fixing code style

> If you find in existing code anything you think should be improved for code style, please fix it and make a **separate** pull request for it, separate from any other code changes. It is much easier to review a pull request if it is only code style changes. And it is much harder to review a pull request if it is both code style and code itself changes. But do please do make pull requests for code style. Such contributions are a great way to get involved with the project and are an easy way to get accustomed to the code anyway. Make sure your pull request improves code style consistency though.

### 3. Be verbose

Always spell out all names. 

> Motivation: Readability. Again, making things easiest to decode. We are using modern IDEs so it's easy enough to auto-complete long names. Don't try to be smart. Try to be super obvious.

Example:

      exitName: ->
        exitLocationId = @currentData()
        location = @location()
    
        # Find exit's location name.
        subscriptionHandle = location.exitsTranslationSubscriptions()[exitLocationId]
        return unless subscriptionHandle?.ready()
    
        key = LOI.Avatar.translationKeys.shortName
        translated = AB.translate subscriptionHandle, key
    
        console.log "Displaying exit name for", key, "translated", translated if LOI.debug
    
        translated.text

I could be tempted to name `exitLocationId` just `id`, `subscriptionHandle` just `handle` or `subHandle`, etc.

There are very few exceptions where we shorten name parts, such as `min`, `max` and `id` that have no chance to be ambiguous. Using `id` as part of the name instead of `identifier` is OK, but just `id` rarely is. Id of what? Make all names mean exactly what they mean. 

Also, use `itemCount` instead of `numItems`.

## General Guidelines

- All code should be in English. 
- For indentation we are using 2 spaces. 
- No trailing whitespace.
- Separate mathematical operators with spaces: `x = 10 + Math.log(3 * a)` and not `x = 10+Math.log(3*a)`.

The file `coffeelint.json` will enforce these last three, so install [CoffeeLint](http://www.coffeelint.org) to your IDE of choice.

### Blank lines

Use blank lines to organize long code blocks into units of what they do. 

> Motivation: This will help someone new understand the code quicker when they read it. You are leaving little hints behind, what parts of code to understand as one unit, one step of your algorithm. Imagine you were writing the code to be published in an article and you try to make everything as easy to learn as possible. It's the same here, because we assume our teammates are going to use the code after us.

Comments always have one blank line before them, except when they are the first line of an indented block of code.

    for item in items
      # No new line above this comment.
      ...
  
    # New line above this comment.
    ...
 
### Line wrapping

We wrap comments at the 120 characters right margin. If the comment wraps to two lines, balance the lines so they are both approximately the same length.

So-so:

    # This is a very long comment that exceeds  |
    # one line.                                 |

Better:

    # This is a very long comment               |
    # that exceeds one line.                    |

When the comment gets over two lines, you don't worry about this anymore:

    # This is an even longer comment that will  |
    # surely go over the two lines limit, since |
    # I'm using so many words.                  |

Code lines (not comments) can go over 120 characters, but if possible it's better to break it into shorter subsets. When a line is over 120 characters it often means too much logic is going on in one line. By exctracting some operations into their own variables it helps readability and gives semantic meaning to code blocks.

Example:

    # Make sure that UI fills at least half the screen, if it needs to.
    neededUIHeight = Math.min $textInterface.find('.text-display-content').height(), viewport.viewportBounds.height() / 2

Better:

    # Make sure that UI fills at least half the screen, if it needs to.
    totalContentHeight = $textInterface.find('.text-display-content').height()
    neededUIHeight = Math.min totalContentHeight, viewport.viewportBounds.height() / 2

You could even go one step further:

    # Make sure that UI fills at least half the screen, if it needs to.
    totalContentHeight = $textInterface.find('.text-display-content').height()
    halfViewportHeight = viewport.viewportBounds.height() / 2
    
    neededUIHeight = Math.min totalContentHeight, halfViewportHeight
    
The blank line there separates the preparation of variables step (assignments) from the operation step (minimum of the two).

### Project structure and namespaces

All classes are placed in (deeply) nested namespaces.

Examples:

    Artificial.Mirage.Component
    LandsOfIllusions.Adventure.Script.Parser
    Retronator.Store.Transactions.Item
   
Common abbreviations are used to help speed up typing and they will appear at the top of the file (similar to imports from other systems):
    
    AE = Artificial.Everywhere
    AB = Artificial.Base
    AM = Artificial.Mirage
    LOI = LandsOfIllusions
    SP = Retropolis.Spaceport
    
    Vocabulary = LOI.Parser.Vocabulary
    
    Action = LOI.Adventure.Ability.Action
    Talking = LOI.Adventure.Ability.Talking
    
    class SP.Locations.Terrace extends LOI.Adventure.Location
    ...
    
Template names and style classes are also just as verbose.

Example:

The class `class SP.Locations.Terrace` will have a corrseponding Spacebars template and first div with a CSS class:
    
    <template name="Retropolis.Spaceport.Locations.Terrace">
    <div class="retropolis-spaceport-locations-terrace">
      <div class="landing-page {{initializingClass}}">
      ...

The same is then in the stylus file:
    
    @import "{retronator:landsofillusions}/style/style.import"
    
    .retropolis-spaceport-locations-terrace
      .landing-page
        position relative
        color black

## CoffeeScript

### Naming conventions

- Variables, functions, methods, fields are all in `lowerCamelCase`.
- Classes are in `UpperCamelCase`. 
- Constants are also `UpperCamelCase` and NOT the most often used `UPPERCASE_WITH_UNDERSCORES`. 
  
  Example: 
  
  ```
  class RS.Transactions.Payment extends AM.Document
    @Types:
      KickstarterPledge: 'KickstarterPledge'
      StripePayment: 'StripePayment'
      ReferralCode: 'ReferralCode'
      StoreCredit: 'StoreCredit'
  ```
  
- We always use `@` instead of `this`.
- All jQuery variables start with a dollar sign (while DOM elements do not).

  Example: 
  
  ```
  $listItem = $('li')
  listItem = $listItem[0]

  button = event.target
  $button = $(event.target)
  ```
  
- Private methods and fields should be prefixed with an underscore (`_`). 

### Parentheses

CoffeeScript allows to omit many parentheses and we try to do so, until thing start becoming ambiguous. If something is unclear to you, how it would be parsed, you should probably use parentheses.

This especially happens in nested function calls. `display getWidget(x, top), 100` is not the same as `display getWidget x, top, 100`.

Other uses of parentheses:
- Always for jQuery functions, because of chaining: ```$someElement.addClass('active').css(opacity:x)```. Do it even if it's just one call (we might need to add another later): ```$otherElement.removeClass('disabled')```.

  This does not apply to multiline code, which is better not to be chained.
  ```
  $someElement.css
    left: 0
    top: 0
    
  $someElement.show()
  ```
  
  Avoid this:
  ```
  $someElement.css(
    left: 0
    top: 0
  ).show()
  ```

- An exception is find-fetch (or find-count) calls to Mongo, since we usually don't need the intermediate cursor:
  ```
  numX = Collection.documents.find(
    name: 'x'
  ).fetch()
  ```

- Parentheses are common in math expressions because of precedence and non-associativity. Always use them when you're calling mathematical functions since they would usually appear in an equation too, e.g. *x = 1 + abs(a-b)* becomes `x = 1 + Math.abs(a - b)` and not `x = 1 + Math.abs a - b`.

- Also do not forget that you do need parentheses when calling a function without arguments: `someCursor.count()`. 

  This is only for CoffeScript. In Spacebars (html files), if you would reference the same `count` function on the template data context, you wouldn't need parentheses:
  ```
  <div>Total: {{count}}</div>
  ```
  
- Always use parenthesis in single-line comprehensions, to make it a bit more explicit that collection into an array is happening:

  ```
  atari2600HueNames = (name for name of LOI.Assets.Palette.Atari2600.hues)
  ```
  
  Alternatively just break it into a new line.
  
  ```
      # Cast the items to enable any extra functionality.
      items = for item in items
        item.cast()
  ```
  
- We do not use parenthesis for creating new objects, not even if there are no parameters (note that when calling functions, you have to use empty parentesis to invoke the function call.

  ```
  @_state = new AC.KeyboardState
  ```
  
  But you have to do:
  
  ```
  scrollPositionTop = @_$scrollTarget.scrollTop()
  ```
  
  Otherwise you will be just assigning the function to the variable, not the result of its call.

### Creating objects

CoffeeScript allows you to create objects just by indentation, which we try to use as much as possible.

    kids =
      brother:
        name: "Max"
        age:  11
      sister:
        name: "Ida"
        age:  9

### Strings

For strings only seen in code we are using single quotes (`'`) and for all user interface strings we are using double quotes (`"`). This makes it easier to see that a string will be read by the user and needs to support translations. (With `console.log` we also uses double quotes, even though no-one will go translate that.)

Examples:
    
      # selector
      @$backButton = @$('.lands-of-illusions-components-back-button')
    
      # ID
      @register 'Retronator.HQ.Items.Tablet.Apps.Prospectus.Purchase'
      
      # class
      closingClass: ->
        'closing' if @closing()
        
      # comment
      console.log "Command input detected a key down and is checking if interface is active:", interfaceActive if LOI.debug
    
      # user communication
      email.addParagraph "Sorry for having trouble with signing in to Lands of Illusions."

Bigger class example:
    
      @id: -> 'Retronator.HQ.Items.Tablet'
      @url: -> 'spectrum/*'
    
      @version: -> '0.0.1'
    
      @fullName: -> "Spectrum tablet"
    
      @shortName: -> "tablet"
    
      @description: ->
        "
          It's the latest model of the signature Retronator Spectrum Tablet, used to interact around Retronator HQ.
        "

Another very often used case for double quotes is string interpolation (which we prefer over string concatenation).

Example:

    name = "#{firstName} #{lastName}"

instead of:

    name = firstName + ' ' + lastName

### Comments

Both standalone one-sentence one-line comments and multi-sentence comments should have grammatically correct punctuation.

- When you are explaining what the code will do, end the sentence with a dot. 

  ```
  # Calculate total value.
  value = quantity * price
  ```
- Short after-the-line comments (which should not be sentences) do not have an ending dot:

  ```
  Meteor.setTimeout ->
    ...
  , 10 # ms
  ```

- Titles that are separating sections of code are also not a sentence (no dot).

  ```
  ## Vector operations
  
  dotProduct = (vector1, vector2) -> ...
  crossProduct = (vector1, vector2) -> ...

  ## Matrix operations
  
  transform = (vector, matrix) -> ...  
  ```
  
  Separate them with a blank line.

TODO comments should be one-line only, with grammatically correct punctuation:

    # TODO: Description of a TODO.

And not:

    # TODO: Something
    # TODO Something.
    #TODO: Something.

### Undefined

Never set variables to `undefined`, instead, use `null`. If you need a field to not exist, use `delete` if really needed (it's slow, so be careful).

### Errors

We avoid throwing errors except instances of `Meteor.Error` which get returned to the client over DDP. Artificial Everything has a set of subclasses of `Meteor.Error` called `Exceptions`. These semantically match Exceptions from the .NET/C# ecosystem.

- **ArgumentException**: The exception that is thrown when one of the arguments provided to a method is not valid.
- **ArgumentNullException**: The exception that is thrown when a null reference is passed to a method that does not accept it as a valid argument.
- **ArgumentOutOfRangeException**: The exception that is thrown when the value of an argument is outside the allowable range of values as defined by the invoked method.
- **ArithmeticException**: The exception that is thrown for errors in an arithmetic, casting, or conversion operation.
- **InvalidOperationException**: The exception that is thrown when a method call is invalid for the object’s current state.
- **NotImplementedException**: The exception that is thrown when a requested method or operation is not implemented.
- **UnauthorizedException**: The exception that is thrown when the caller does not have permission to perform the action.

A method can have a defined set of exceptions it can throw and the client can then react to them and provide any feedback to the user.

Examples:

    throw new AE.ArgumentException "Namespace-key pair must be unique. (namespace: #{namespace}, key: #{key}, default text: #{defaultText})"

    throw new AE.ArgumentNullException 'Storage key must be provided.' unless options.storageKey?

    throw new AE.ArgumentOutOfRangeException "A payment that exceeds the value of the shopping cart was attempted." if payAmount > totalPrice

    throw new AE.InvalidOperationException "The purchase requires more store credit than the user has available." if needsCreditAmount > availableCreditAmount

    throw new AE.UnauthorizedException "You must be logged in to perform actions with a character." unless user

## Stylus

### Naming

Style class names are all in lower case with hyphens between words. We use pure Stylus style without braces (`{}`) and colons (`:`) otherwise used in CSS. We nest and reuse as possible. If needed, we use double quotes (`"`).

Class names are always namespaced and the top level div always has a style that matches the template name, except lowercase and with hyphens instead of dots.

### Structure

Selector structure must exactly match the HTML structure, even when no style rules are defined at intermediate levels.

Example html:
    
      <div class="artificial-mirage-display {{debugClass}}">
        <div class="viewport-bounds">
          <div class="scale">display at x{{scale}}</div>
          <div class="safe-area">
          </div>
        </div>
      </div>
  
Matching stylus:
    
    .artificial-mirage-display
      .viewport-bounds
        display none
    
      &.debug
        .viewport-bounds
          display block
          position fixed
          border 2px solid firebrick
          color firebrick
          pointer-events none
          z-index 9999
    
          .scale
            position absolute
            bottom 0
            right 0
            padding 2px
    
          .safe-area
            position absolute
            border 2px solid goldenrod

> Motivation: When we try to add some style to an imtermediate level later on, we avoid excessive indentation of the codebase which makes commits harder to diff for changes. It's also more consistent and easier to understand to just always spell out the structure explicitly. 

### Order of properties

As a guideline, the order of properties for a style is as follows:

- display
- position
- dimensions (left, right, width …)
- margin
- padding
- visuals (color, background, shadows …)

> Motivation: We first specify how the element appears (display), then where it appears (position + dimensions + margin), then how its content (or visual styling) looks like (padding + visuals).

Templates
---------

Templates are written in HTML5 and [Spacebars](https://github.com/meteor/meteor/tree/devel/packages/spacebars). We write self-closing tags (`<br />`) and use correct nesting. We always indent, either for HTML elements or Spacebars tags. We do not put spaces after `{{` or before `}}`. 

Example:

    {{error}}
    {{#each publications}}
      {{> publicationsItem}}
    {{/each}}

We document templates with inline comments and TODOs where we do use spaces to make them more readable:

    {{! TODO: Description of a TODO. }}
    {{! General comment }}
    {{!
      Long comment with multiple lines.
      Second line. Try to align them.
    }}

## Commit messages

Commit messages should be descriptive and full sentences, with grammatically correct punctuation. If possible, they should reference relevant tickets (by appending something like `See #123`) or even close them (`Fixes #123`). GitHub recognizes that. If longer commit message is suitable (which is always a good thing), first one line summary should be made (50 characters is a soft limit), followed by a multi-line description:

    Added artificially lowering of the height in IE. Fixes #123
    
    In IE there is a problem when rendering when user is located
    higher than 2000m. By artificially lowering the height rendering
    now works again.

## File and folder structure

Some conventions:

- Always match namespaces to folders. This means you create an (empty) namespace class in each folder and then in subfolders put classes that live in that namespace.
- The holy trinity of html + styl + coffee for a component almost always goes into its own folder.
- If a file is placed exclusively on the server or the client, if that is not the convention for the file, it should include a `-server` or `-client` suffix.

  For example, `subscriptions.coffee` doesn't need the suffix because it's always on the server only. But `methods-server.coffee` class does need it since methods are usually both on server and client.
