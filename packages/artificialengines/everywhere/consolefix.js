/*
HACK: The Showdown package includes a polyfill for console, which gets activated even though console is available. This
is due to having the console assignment statement in the source file, which Meteor then picks up as a global variable
and tries to scope it to the package. This in turn makes console be undefined in this scope, triggering the polyfill,
which uses alerts instead of the window console. So we simply assign the console variable ourselves as the first thing
in the package, restoring the normal order in the universe.
 */
console = window.console;
