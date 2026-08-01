# Agents

## Scope

These instructions apply to the entire repository unless a deeper `agents.md` overrides them.

## Project overview

- `Pixel-Art-Academy` is a Meteor-based game project.
- The repo primarily uses CoffeeScript, Stylus, and Spacebars/Blaze components.
- Desktop packaging exists, but several runtime and packaging entries at the repo root are symlinks outside this workspace.

## Working rules

- Match the existing architecture and naming patterns before introducing new abstractions.
- Prefer CoffeeScript for app logic changes; avoid introducing plain JavaScript into CoffeeScript areas.
- Prefer Stylus for styling changes; avoid adding CSS/SCSS unless an existing file already uses it.
- Keep names verbose and explicit; this codebase favors readability over brevity.
- Add comments for non-obvious code paths and multi-step logic, consistent with `codestyle.md`.
- Use 2-space indentation and avoid trailing whitespace.
- Keep changes focused; do not mix style cleanups with behavior changes unless asked.

## Style and architecture observations

- Prefer precise domain vocabulary over generic technical names. For example, in chess code, use terms such as ply, live position, previewed history position, square, move, piece, and game state when those are the concepts being modeled.
- Prefer rich package-level domain objects over primitive strings or coordinate pairs when the concept exists. For example, a variable named `square` should be a `Chess.Square`, while square names should be explicitly named as such.
- Keep game rules and persistent game state in manager/model classes, and keep interface-only behavior in interface components. Animation, dragging, display formatting, and other presentation concerns belong close to the relevant UI component.
- When a concept is reused or hides collection shape, expose it through a helper method on the owning class instead of reaching through fields from another component.
- In Blaze/Artificial.Mirage components, get parent context through `ancestorComponentOfType` in lifecycle methods, use `currentData()` for item helpers, and pass rich data objects rather than relying on DOM data attributes when possible.
- This codebase often splits a class across multiple CoffeeScript files by extending the same class again for a specific concern. Follow that pattern for large component concerns instead of creating detached utility modules.

## Repository guidance

- Read `codestyle.md` before making substantial code changes in existing modules.
- Use `rg` and `rg --files` for search.
- Do not modify symlinked runtime or deployment entries at the repo root unless the task explicitly requires it:
  - `build`
  - `run`
  - `test`
  - `package`
  - `sign`
  - `notarize`
  - `deploy-steam`
  - `deploy-steam-demo`
  - `.steam`
- Treat `.desktop`, `.desktop-package`, and generated local Meteor artifacts as build output unless the task is specifically about packaging.

## Validation

- Prefer targeted validation first.
- For CoffeeScript style-sensitive changes, use the repo’s existing lint/configuration when relevant.
- For app/runtime changes, prefer the smallest check that exercises the edited area before suggesting broader app runs.
- The main Meteor app is normally running during development. Never run `meteor test-packages` directly from the
  repository because it can interfere with the live build and root npm dependencies.
- Use `./test setup` to prepare the isolated test environment, `./test` for the full test suite, and
  `./test package <package-folder-or-name>` for targeted package tests. When adding or changing tests, run the relevant
  `./test` command and report its result.
- Request network access before running `./test` commands so dependency setup or Meteor downloads do not stall in the
  sandbox before failing.
