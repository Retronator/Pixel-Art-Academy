# Artificial Engines
A Meteor game development library written in CoffeeScript.

### Artificial Babel

_Translation framework_

Database-based translation framework for easy, reactive translating.

- **Translatable**: Component for translating the text in-place.
- **Translation**: Document that stores the translated texts for a given key in a namespace.
- **Server**: Remote server that hosts translation documents.

### Artificial Base

_The app framework_

Tying all the pieces of your app together can be a hassle. Running an update and draw loop should be unified. 
Artificial Base (AB) gives you the basic framework.

- **App**: The root class from which to inherit your custom app.

### Artificial Control

_Input hardware abstraction_

Helpers for keyboard, mouse and other input devices.

- **Keys**: Enumeration of all the keyboard keys.
- **KeyboardState**: A snapshot of pressed keys.
- **Keyboard**: Static class with a reactive source of the current keyboard state.

### Artificial Everywhere

_Useful bits and pieces_

Some static classes and routines are just useful right about everywhere in your code and don’t fall into any specific
category. The place for them is Artificial Everywhere (AE).

- **Date**: Date extensions.
- **DateHelper**: Date extensions and helper methods to deal with the date object.
- **DateRange**: A reactive range of time between two dates.
- **Exceptions**: Exception classes with predefined error codes.
- **Jquery**:
  - **PositionCSS**: A cross-browser way to read position css properties (left/right/top/bottom).
- **Match**: Extensions to Meteor's match patterns.
- **ReactiveWrapper**: A reactive field with extra reactivity for manual updates.
- **Rectangle**: A reactive rectangle data structure.
- **Three.js**:
  - **Color**: Extra functionality for the color class.
- **LoDash**:
  - **LetterCase**: String operations that change letter case.
  - **Math**: Math operations not available natively.
  - **NestedProperty**: Access to properties on nested objects.
  - **Urls**: Operations that deal with URL strings.

### Artificial Mirage

_Graphical user interface elements_

A great GUI is a ticket to user friendliness. Artificial Mirage provides common interface elements that you connect
into a system, specially designed to adapt to different display resolutions and aspect ratios.

- **Component**: Extension of BlazeComponent with custom functionality.
- **CSSHelper**: Helper functions for dealing with CSS.
- **DataInput**: Base class for an input component with easy setup for different mixins.
- **Display**: Represents the display area and provides automatic pixel art scaling calculation.
- **Mixins**:
  - **AutoSelectInputMixin**: Selects the input text on focus.
  - **PersistentInputMixin**: Prevents the input value to be overridden while editing.
- **Window**: The bounds of your browser window.

### Artificial Mummification

_Data storage_

Classes, extensions and helpers for database storage.

- **Document**: Extended PeerDB document with common operations.
- **MongoHelper**: Useful methods to help with mongo queries.

### Artificial Spectrum

_Rendering routines_

Artificial Spectrum provides powerful supportive objects with rich functionality for many different rendering tasks
one might require.

### Artificial Telepathy

_Network communication_

- **EmailComposer**: Helper for constructing text and html emails.
- **FlowRouter**:
  - **AddRoute**: Add route to Flow Router using Blaze Layout.
  - **Spacebars**: Spacebars helpers for Flow Router.
  - **RouteLink**: Component that displays a span or a link, depending if we're on this route or not. Useful for navigation menus.
