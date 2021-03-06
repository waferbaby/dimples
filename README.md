![Gem Version](https://img.shields.io/gem/v/dimples)
![Status](https://img.shields.io/github/checks-status/waferbaby/dimples/master)
![License](https://img.shields.io/github/license/waferbaby/usesthis)

# Dimples
A simple, opinionated static site generator.

## Requirements

- [Tilt](https://github.com/rtomayko/tilt "The Tilt gem.") - for the templates.
- One of the gems Tilt uses for templating, depending on your needs.

## Installation

```ruby
gem install dimples
```

## Usage

Dimples is a very simple command-line tool, imaginatively named `dimples`, which lets you generate a site in the current directory by running `dimples build`.

It assumes your directory structure will look like this:

- `config.json`
- `pages/`
- `posts/`
- `static/`
- `templates/`
  - `feeds/`

### The 'pages' directory

All files here will be turned into static pages, maintaining whatever directory structure you're using.

### The 'posts' directory

Dimples assumes your posts here will be named `{year}-{month}-{day}-{slug}.{extension}`.

### The 'static' directory

All files here are copied as is into the destination directory.

### The 'templates' directory

Templates wrap the contents of your pages and posts. Any template stored in the `feeds` subdirectory will map its filename to the feed's extension - `templates/feeds/atom.(extension)` becomes `feed.atom`, and so on.

## Front Matter

Dimples supports YAML front matter at the beginning of a post, page or template file.

```yaml
---
title: My first post
layout: post
categories:
- first
- static
---

Today I read documentation about a static site generator.
```

As your pages, posts and templates are rendered, Dimples will look for a `layout` element in the front matter and use that to render the file's contents within the template (otherwise, it's rendered as is.) The `layout` value will map to a template file in `templates/` without the file extension, so `layout: post` would match `templates/post.erb`.

## Generation

As each file is generated, Dimples makes special variables available:

- `site`, the entire `Dimples::Site` instance.
- `page`, the current page being rendered.
- `template`, the current template being rendered.

Anything in your front matter is available to either the `page` (for a page or post) or `template` (for a template) objects.

```yaml
title: My title
custom_field: true
```

If this was a page or post, you'd have access to `page.title` and `page.custom_field`, and if this was a template, `template.title` and `template.custom_field`.

### Site

Key | Description
----|------------
`site.posts` | All the posts in your site, ordered by the most recent first.
`site.latest_post` | The most recent post on the site.
`site.categories` | All categories across the site.
`site.data` | An optional key/value dictionary you can define in your config.

### Page

All pages receive the following:

Key | Description
----|------------
`page.title` | Defined by you, or auto-generated by the archive and category pages (otherwise it's empty).

When a post is being generated:

Key | Description
----|------------
`page.date` | The date of your post based on the filename.
`page.slug` | The last part of your post's filename.
`page.categories` | An array of categories your post belongs to, if any. Each category has a `name`, `slug` and a list of `posts` available.

When a feed is being generated:

Key | Description
----|------------
`page.feed_posts` | A list of posts for the feed to render.

When an archive page is being generated:

Key | Description
----|------------
`page.archive_date` | The date of the current archive date.
`page.archive_type` | Either `year`, `month` or `day`.

### Template

The `template` object pulls in anything from that template file's front matter, similar to how `page` works.

### Pagination

If the page being generated is part of a paginated collection, there's also a `pagination` object:

Key | Description
----|------------
`pagination.posts` | A list of posts for the current page.
`pagination.current_page` | The current page number.
`pagination.page_count` | The total number of pages.
`pagination.post_count` | The total number of posts.
`pagination.previous_page` | The previous page number, if any.
`pagination.next_page` | The next page number, if any.
`pagination.urls.current_page` | The URL for the current page.
`pagination.urls.first_page` | The URL for the first page.
`pagination.urls.last_page` | The URL for the last page.
`pagination.urls.previous_page` | The URL for the previous page, if any.
`pagination.urls.next_page` | The URL for the next page, if any.

## Configuration

Dimples has a number of options for customising how it works - here are the defaults:

```json
{
  "source": "./",
  "destination": "./public",
  "paths": {
    "archives": "archives",
    "paginated_posts": "posts",
    "posts": "archives/%Y/%m/%d",
    "categories": "archives/categories"
  },
  "generation": {
    "paginated_posts": true,
    "year_archives": true,
    "month_archives": true,
    "day_archives": true,
    "categories": true,
    "main_feed": true,
    "category_feeds": true
  },
  "layouts": {
    "post": "post",
    "category": "category",
    "paginated_post": "paginated_post",
    "archive": "archive",
    "date_archive": "archive"
  },
  "pagination": {
    "page_prefix": "page_",
    "per_page": 10
  },
  "date_formats": {
    "year": "%Y",
    "month": "%Y-%m",
    "day": "%Y-%m-%d"
  },
  "feed_formats": [
    "atom"
  ],
  "category_names": {},
  "rendering": {},
  "data": {}
}
```

### Source and Destination

Both of these are full directory paths.

Key | Default | Description
----|---------|-------------
`source` | `./` | The directory where your site's files and config live.
`destination` | `./public` | The directory where your site will be built. This string is passed to Ruby's `strftime` [Time method](http://ruby-doc.org/core-2.7.2/Time.html#method-i-strftime "The strftime method of the Time class."), so you can use any of its options here.

### Paths

The relative paths used to build generated files - each is appended to the `destination` directory.

Key | Default | Description
----|---------|-------------
`archives` | `archives` | The path for the main paginated archives.
`paginated_posts` | `posts` | The path for index-style pages for all posts.
`posts` | `archives/%Y/%m/%d` | The path for posts (suffixed with the individual post slug). This string is passed to Ruby's `strftime` [Time method](http://ruby-doc.org/core-2.7.2/Time.html#method-i-strftime "The strftime method of the Time class."), so you can use any of its options here.
`categories` | `archives/categories` | The path for category index pages (suffixed with the individual category slug).

### Generation

Choose what gets built when Dimples runs.

Key | Default | Description
----|---------|-------------
`paginated_posts` | true | If we should build out paginated pages for all posts.
`year_archives` | true | If we should build paginated year archives.
`month_archives` | true | If we should build paginated month archives.
`day_archives` | true | If we should build paginated day archives.
`categories` | true | If we should build paginated pages for each category.
`main_feed` | true | If we should build the main feeds based on your posts.
`category_feeds` | true | If we should build feeds of the posts in each site category.

### Layouts

The default templates for various page types.

Key | Default | Description
----|---------|-------------
`post` | `post` | A single post.
`category` | `category` | Category pages.
`paginated_post` | `paginated_post` | The paginated posts pages.
`archive` | `archive` | The main archive pages.
`date_archive` | `date_archive` | The year, month and day archive pages.

### Pagination

Settings for all paginated pages.

Key | Default | Description
----|---------|-------------
`page_prefix` | `page` | The prefix used when generating page URL slugs ("page_2").
`per_page` | 10 | The number of posts to show per page. This applies to your feeds, too.

### Date formats

These are used to define the auto-generated title for each type of archive page, and they're passed to Ruby's [method for formatting dates](https://ruby-doc.org/stdlib-2.3.1/libdoc/date/rdoc/Date.html#method-i-strftime "The strftime method of the Date class.").

Key | Default | Description
----|---------|-------------
`year` | `%Y` | The year format.
`month` | `%Y-%m` | The month format.
`day` | `%Y-%m-%d` | The day format.

### Feed formats

An array of feed formats your site supports - these will be matched by name to the templates within the `templates/feeds/` directory, so `atom` will use
`templates/feeds/atom.(extension)`.

### Category names

By default, Dimples will capitalise your category's slug as its title, but you can override that here:

```json
"category_names": {
  "bsd": "BSD",
  "mac": "Macintosh"
}
```

### Rendering

These options will be passed directly to the renderer Tilt picks for your posts, pages and templates based on the file extension.

### Data

A collection of your own custom key/value pairs that will be made available to all pages, posts and templates via `site.data`. For example:

```json
"data": {
  "tagline": "This is my static website"
}
```

This would give you `site.data.tagline`.
