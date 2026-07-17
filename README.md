# Neon

*Combinators for dynamically rendering and updating browser pages.*

[![Hippocratic License](https://img.shields.io/badge/License-Hippocratic_3.0-lightgrey.svg)](https://firstdonoharm.dev)

Neon provides a functional approach to describing updates for Web pages. It leverages a composable, combinatorial pattern that makes it easy for creators to orchestrate view swaps and element patching without reloading the page.

## Features

- Supports asynchronous composition natively across all combinators.
- Integrates structurally with `diffHTML` to intelligently patch the DOM.
- Allows rendering via string-returning functions, empowering developers to choose their templating strategy.
- Selects specific views logically to handle complex single-page application transitions.
- Extends seamlessly by crafting custom combinators that accept a unified rendering context.

## Installation

```bash
pnpm install @dashkite/neon
```

## Usage

With Neon, developers construct sequences of operations, passing a rendering context through combinators. It integrates well with Joy for functional composition.

```coffeescript
import { flow } from "@dashkite/joy/function"
import { render, view, show } from "@dashkite/neon"

# Assemble the rendering pipeline
renderPipeline = flow [
  render "head", ({title}) -> "<title>#{title}</title>"
  view "main", ({title, html, image}) ->
    """
    <h1>#{title}</h1>
    <img src='#{image}'/>
    #{html}
    """
  show
]

# Execute the pipeline with a context
renderPipeline { 
  data: { name: "view post" }, 
  title: "Hello", 
  html: "<p>World</p>", 
  image: "image.png" 
}
```

## Other Resources

- [Usage Guides](docs/recipes.md)
- [API Reference](docs/reference.md)
- [Technical Notes](docs/technical-notes.md)
- [Testing Guidelines](docs/testing.md)