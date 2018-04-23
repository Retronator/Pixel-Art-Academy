# Retronator 

## App

The root package for the Retronator web app that runs Pixel Art Academy and related projects.

It controls the head and the body and imports and wires all other packages.

## Cron schedule

### Daily

These get executed on the hour.

* **12 AM**: Retronator Blog all posts update.
* **1 AM**: Patreon pledges update.
* **2 AM**: Featured website previews updates (rendering).
* **3 AM**: Euro exchange rates.

### Hourly

* **0 min**: This slot is reserved for processing tasks that happen daily.
* **10 min**: Pixel Dailies.
* **20 min**: Retronator Blog latest 20 posts update.

### Frequent

* **x5 min**: Game simulation.
