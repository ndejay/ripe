# Ripe
[![Gem Version](https://badge.fury.io/rb/ripe.svg)](http://badge.fury.io/rb/ripe)
[![Build Status](https://travis-ci.org/ndejay/ripe.svg)](https://travis-ci.org/ndejay/ripe)
[![Code Climate](https://codeclimate.com/github/ndejay/ripe/badges/gpa.svg)](https://codeclimate.com/github/ndejay/ripe)
[![Test Coverage](https://codeclimate.com/github/ndejay/ripe/badges/coverage.svg)](https://codeclimate.com/github/ndejay/ripe)
[![Inline docs](http://inch-ci.org/github/ndejay/ripe.svg?branch=master)](http://inch-ci.org/github/ndejay/ripe)

ripe is an abstraction layer between the MOAB/Torque stack and your pipeline.

With ripe, you can easily collate tasks into workflows which can then be
applied to samples without the headache of manually dealing with the queuing
system.

Notes:

- MOAB is a scheduler -- it takes care of priorities and allocations.
- Torque is a resource manager -- it launches the jobs on the nodes.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'ripe', :git => 'git://github.com/ndejay/ripe.git'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install ripe

## Usage

TODO: Write usage instructions here

## Contributing

1. Fork it ( https://github.com/ndejay/ripe/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
