# Dimples
A very, very, *very* simple static site generator gem.

[![Build Status](https://travis-ci.org/waferbaby/dimples.svg?branch=master)](https://travis-ci.org/waferbaby/dimples) [![Test Coverage](https://codeclimate.com/github/waferbaby/dimples/badges/coverage.svg)](https://codeclimate.com/github/waferbaby/dimples) [![Gem Version](https://badge.fury.io/rb/dimples.svg)](http://badge.fury.io/rb/dimples)

## Requirements

- [Tilt](https://github.com/rtomayko/tilt "The Tilt gem.") - for the templates.
- One of the gems Tilt uses for templating, depending on your needs.

## Installation

Assuming you're using Bundler, add this to your Gemfile:

```ruby
gem "dimples"
```

And then run `bundle`.

## Usage

Dimples includes a very simple command-line tool, imaginatively named `dimples`, which lets you generate a site in the current directory by running `dimples build`.

It assumes your folder layout will possibly look something like this:

```
config/
  site.yml
lib/
  (optional code to extend Dimples)
pages/
  (a bunch of awesome pages)
posts/
  (a bunch of clever, articulate posts)
templates/
  (a bunch of horribly attractive templates)
```

All pages, posts and templates support front matter.

### Pages

Any files in `pages/` will be turned into static pages, maintaining any folder hierarchy you're using. I know, amazing.

### Posts

Dimples, being very opinionated, assumes your posts will be named in the following format:

`{year}-{month}-{day}-{slug}.{extension}`

### Templates

Templates are the skeletons propping up the meat of all your pages and posts. Hm, that's kind of gross, but you get the idea. As they're rendered, templates are passed in three Ruby objects:

- `@site`, which refers to the entire `Dimples::Site` instance.
- `@this`, which refers to the current _thing_ being rendered (a page, a post, or even a template itself).
- `@type`, which is the name of the thing being rendered (like `post` or `page`).

For example, a very basic template for a post might look something like:

```html
---
<article class="post">
    <header>
        <h1><%= @this.title %> (I'm a <%= @type %>!)</h1>
    </header>
    <%= yield %>
</article>
```

### Lib

Any code in here will be loaded by the `dimples` command-line tool, and is primarily used to override the default classes in Dimples, in case you need to change things up for your own needs.

## Front matter

Dimples, like every other site generator out there, supports front matter at the beginning of a post, page or template file. It looks a little something like this (it's YAML):

```yaml
---
title: My first post!
layout: post
categories:
- awesome
- the_best
---

I did it, mum.
```

Anything you throw into the front matter becomes available to the `@this` item when the site is rendered (so for the above example you'd have access to `@this.title`, `@this.layout` and `@this.categories`.)

Posts are also given `@this.date` and `@this.slug`, which matches what you used for their filenames.

You can override the file extension your page or post will use by supplying an `extension` element:

```yaml
---
extension: txt
---
```

You tell Dimples what template to use by setting the `layout` element, which will map to the filename of any file in `templates/`, sans-extension (so `templates/post.erb` is available as `post`, and so on). This works for posts, pages _and_ templates. Dimples makes no assumptions here, so unless you specify a layout, you ain't getting one.

```yaml
---
layout: feed
---
```

And no, I really don't know why I'm using both 'layouts' and 'templates' either. Madness, I tell you.