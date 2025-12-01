# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Zenn book repository for "RSpecgfv∆π»nHπ" (Learning Testing Concepts with RSpec). The book teaches RSpec and automated testing fundamentals to beginners.

## Commands

```bash
# Preview the book locally
npx zenn preview

# Create a new article
npx zenn new:article

# Create a new book
npx zenn new:book

# Create a new chapter
npx zenn new:chapter
```

## Repository Structure

- `books/252daa01819885/` - Main book content
  - `config.yaml` - Book configuration (title, chapters, topics)
  - `chapter*.md` - Individual chapter files
  - `cover.png` - Book cover image
- `articles/` - Zenn articles (currently empty)
- `example/` - Example RSpec code used in book chapters

## Content Guidelines

- Write in Japanese
- Book targets RSpec/automated testing beginners
- Example code in `example/` directory should be referenced in chapters
- Chapter order is defined in `books/252daa01819885/config.yaml`
