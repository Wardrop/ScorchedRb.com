Simple, Powerful, Scorched
==========================

Scorched is a generic, unopinionated, light-weight web framework for Ruby. Scorched provides a generic yet powerful set of constructs for processing HTTP requests, with which websites and applications of almost any scale can be built.

Getting Started
---------------

Install the canister...

    gem install scorched

Open the valve...

    # ruby
    # hello_world.ru
    require 'scorched'
    class App < Scorched::Controller
      get '/' do
        'hello world'
      end
    end
    run App
    
And light the flame...

    rackup hello_world.ru
    

Tell Me More
------------

To learn more about Scorched, refer to the site navigation on the left. Other 