# Welcome to TimePulse
## OSS Time Tracker for Consultants and Contractors

This project is originally by Logical Reality Design, Inc., and was built primarily
by Evan Dorn, Judson Lester, and Hannah Howard with contributions from many other
current and past contractors of LRD.

## Features Overview

TimePulse features a few key features we find useful in a team time-tracking application.

* Both punchclock and manual entry clocking
* Integration with GitHub and Pivotal Tracker - clocked time is associated automatically with PT tickets and with
* Heirarchical tree of projects, with attribute inheritance
* Unified interface for both invoicing clients and paying subcontractors
* Invoice generation
* Multiple customizable rates for each project
* Workers can be individually assigned to a rate on a per-project basis

## Technology

TimePulse is a Rails 3.2 + MySQL application, with a modest amount of JavaScript written with jQuery and NinjaScript.  It should run fine on any platform capable of running a Ruby 1.9.3 + Rails 3.2 application, with few other dependencies.

## API Integrations

TimePulse provides callback endpoints for both GitHub and PivotalTracker. If the URL at which you run TimePulse is configured in either or both services, activity (commits, ticket state changes, etc.) will be saved with your time logs. Invoice reports can then be generated which show (for example) all the git traffic and pivotal tickets that were completed during the period being billed for, and associated to the developer and/or work hours entry.

## Documentation

Documentation and examples can be found at [timepulse.io](http://timepulse.io, "TimePulse Home Page").

## Getting Started

Assuming you have a place to deploy already set up, you'll need to:
  * Clone this repository
  * Set up deploy scripts (for Capistrano, or whatever system you prefer)
  * Copy and configure the credentials files, particularly config/database.yml, config/initializers/smtp.rb, config/initializers/session_secret.rb and config/initializers/api_keys.rb
  * Create a database
  * Deploy and seed the database
  * Log in as the initial admin user

For now, you'll probably need solid knowledge of Rails to customize and deploy this app.  We're working on making it a simpler process for future users.

## History

TimePulse was first built as an internal time-tracking application for LRD in early 2011.  Since then it's grown and expanded, and in October 2013 we decided to open-source the project.

## Contributors

Austin Fonacier
Charles Hudson
Evan Dorn
Hannah Howard
Judson Lester
Michael McCormick
Nate Berggren
Scott Van Essen
Tom Jakubowski

## LICENSE

TimePulse is released under a restricted license. See the accompanying LICENSE file for details.



