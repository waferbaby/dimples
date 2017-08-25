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

It assumes your directory structure will possibly look something like this:

- `config/`
  - `site.yml`
- `lib/` (optional code to extend Dimples)
- `pages/` (a bunch of awesome pages)
- `posts/` (a bunch of clever, articulate posts)
- `templates/` (a bunch of horribly attractive templates)
  - `feeds/` (optional templates for feeds)

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

Any templates stored in a `feeds` subdirectory will be used as a feed format, mapping its filename to the generated feed's extension - `templates/feeds/atom.erb` becomes `feed.atom`, and so on.

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

You tell Dimples what template to use by setting the `layout` element, which will map to the filename of any file in `templates/`, sans-extension (so `templates/post.erb` is available as `post`, and so on). This works for posts, pages _and_ templates. Dimples makes no assumptions here, so unless you specify a layout, **it won't use one**.

```yaml
---
layout: feed
---
```

### Hey! Why both 'layouts' and 'templates'?

A template represents the actual file on disk, whereas a layout signals which one to use. Make sense? Yeah, I didn't think so.

## Configuration

As a fussy and opinionated gem, Dimples has a lot of feelings about how it should generate a site, but that doesn't mean you don't get to have a say in it. Here's what the default config looks like, in YAML:

```yaml
source_path: (current directory)
destination_path: (current directory plus "site")
verbose_logging: false
class_overrides:
  :site:
  :post:
rendering: {}
category_names: {}
paths:
  archives: archives
  posts: archives/%Y/%m/%d
  categories: archives/categories
layouts:
  posts: posts
  post: post
  category: category
  year_archives: year_archives
  month_archives: month_archives
  day_archives: day_archives
pagination:
  per_page: 10
generation:
  categories: true
  year_archives: true
  month_archives: true
  day_archives: true
  feeds: true
  category_feeds: true
date_formats:
  year: "%Y"
  month: "%Y-%m"
  day: "%Y-%m-%d"
```

And here's what it all means:

## The basics

I think you're great.

Key | Default | Description
----|---------|-------------
`source_path` | The current directory. | Where Dimples should look for all the goodies.
`destination_path` | The current directory, plus 'site'. | Where Dimples will build a site. This directory is generated for you, if it doesn't exist (and it's destroyed if it does!).
`verbose_logging` | `false` | In case you _really_ need to know what Dimples is doing while generating.

## Class overrides

In case Dimples doesn't do exactly what you want, you can substitute subclasses of the default site or post classes and override whatever makes sense to you, you go-getter.

Key | Default | Description
----|---------|-------------
`site` | nil | A class to use in place of `Dimples::Site`.
`post` | nil | A class to use in place of `Dimples::Post`.

## Rendering

These options will be passed directly to the renderer Tilt picks for your posts, pages and templates, based on the file extension.

## Category names

By default, Dimples will capitalise your categories as their titles so you can display 'em nicely, but you can override that with your own formatting:

```yaml
category_names:
  bsd: 'BSD'
  mac: 'Macintosh'
```

## Paths

Defines where your generated posts will land.

Key | Default | Description
----|---------|-------------
`archives` | `archives` | Where all your posts will end up.
`posts` | `archives/%Y/%m/%d` | Where individual posts end up, suffixed with the post slug. This string is passed to Ruby's `strftime` [Time method](http://ruby-doc.org/core-2.4.0/Time.html#method-i-strftime "The strftime method of the Time class."), so you can use any of its options to flesh this out.
`categories` | `archives/categories` | Where individual category pages end up, suffixed with the category slug.

## Layouts

The default layouts for various posts and pages.

Key | Default | Description
----|---------|-------------
`posts` | `posts` | The default layout used for a collection of posts.
`post` | `post` | The default layout used for a single post.
`category` | `category` | The default layout used for category pages.
`year_archives` | `year_archives` | The default layout used for year archive pages.
`month_archives` | `month_archives` | The default layout used for month archive pages.
`day_archives` | `day_archives` | The default layout used for day archive pages.

## Pagination

There's only one option here, but it's pretty great.

Key | Default | Description
----|---------|-------------
`per_page` | 10 | The number of posts to show per page. This applies to your feeds, too.

## Generation

A bunch of flags to toggle what's generated when running `dimples build`.

Key | Default | Description
----|---------|-------------
`categories` | true | If we should build category pages.
`year_archives` | true | If we should build year archive pages.
`month_archives` | true | If we should build month archive pages.
`day_archives` | true | If we should build day archive pages.
`feeds` | true | If we should build the main feeds based on your posts.
`category_feeds` | true | If we should build a feed of posts for each category on your site.

## Date formats

These are currently used to define the auto-generated title for each type of archive page, and are also passed to Ruby's `strftime` [Time method](http://ruby-doc.org/core-2.4.0/Time.html#method-i-strftime "The strftime method of the Time class.").

Key | Default | Description
----|---------|-------------
`year` | `%Y` | The year format.
`month` | `%Y-%m` | The month format.
`day` | `%Y-%m-%d` | The day format.
