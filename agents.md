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

## Repository guidance

- Read `codestyle.md` before making substantial code changes in existing modules.
- Use `rg` and `rg --files` for search.
- Do not modify symlinked runtime or deployment entries at the repo root unless the task explicitly requires it:
  - `build`
  - `run`
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
