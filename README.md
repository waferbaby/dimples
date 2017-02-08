# Dimples
A very, very, *very* simple static site generator gem.

[![Build Status](https://travis-ci.org/waferbaby/dimples.svg?branch=master)](https://travis-ci.org/waferbaby/dimples) [![Test Coverage](https://codeclimate.com/github/waferbaby/dimples/badges/coverage.svg)](https://codeclimate.com/github/waferbaby/dimples) [![Gem Version](https://badge.fury.io/rb/dimples.svg)](http://badge.fury.io/rb/dimples)

## Requirements

- [Tilt](https://github.com/rtomayko/tilt "The Tilt gem.") - for the templates.
- One of the gems Tilt uses for templating, depending on your needs.

## Installation

> gem install dimples

## Usage

Dimples is designed to be called via Ruby directly, so there's no included binary for generating a scaffold site. It's fairly straightforward:

    require 'dimples'
    require 'yaml'
    
    config = YAML.load_file('my_config.yml')
    site = Dimples::Site.new(config)
    
    site.generate

That's it!