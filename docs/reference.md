# Neon API Reference

This document provides precise signatures and enriched descriptions for the functions exported by Neon. The library relies heavily on functional composition, providing utilities that generate combinators designed to operate on a shared context.

## The Rendering Context

The core abstraction driving Neon is the Rendering Context. The context is a mutable object threaded sequentially through every combinator in a rendering pipeline. Rather than relying on hidden state or global variables, all necessary information for rendering and lifecycle management is stored on this context.

When a pipeline executes, the context typically accumulates the following properties:
- `root`: The overarching root DOM element containing the application.
- `page`: The currently active page element.
- `view`: The currently active view element instantiated within the page.
- `data`: Static metadata associated with the page configuration.
- `path`: The routing path associated with the active view.
- `initializing`: A boolean flag indicating whether the view was just created (`true`) or if it already existed (`false`).

Creators interact with the context implicitly when composing combinators, though they may also access properties like `initializing` or `view` when providing custom handlers to events or lifecycle hooks.

## Combinators

### view

$view: selector, template \to combinator$

Returns a combinator that creates or updates a view within a page. It targets the element matching the provided CSS `selector`. The `template` function receives the current `context` and MUST return an HTML string representing the desired structure. The resulting DOM patching is highly efficient.

```coffeescript
import { view } from "@dashkite/neon"
import assert from "@dashkite/assert"

pipeline = view "main", ({title}) -> "<h1>#{title}</h1>"
assert typeof pipeline == "function"
```

### activate

$activate: handler \to combinator$

Returns a combinator that executes the provided `handler` function when the view enters the visible viewport. The `handler` receives the rendering `context`. It leverages an internal `IntersectionObserver` configured to fire precisely upon visibility changes, ensuring smooth lifecycle hooks without manual scroll tracking.

```coffeescript
import { activate } from "@dashkite/neon"
import assert from "@dashkite/assert"

pipeline = activate (context) -> context.view.classList.add "visible"
assert typeof pipeline == "function"
```

### deactivate

$deactivate: handler \to combinator$

Returns a combinator that executes the `handler` function when the view leaves the visible viewport. The `handler` receives the rendering `context`. This provides developers with an ergonomic mechanism to pause processing or animations for off-screen elements.

```coffeescript
import { deactivate } from "@dashkite/neon"
import assert from "@dashkite/assert"

pipeline = deactivate (context) -> context.view.classList.remove "visible"
assert typeof pipeline == "function"
```

### dispose

$dispose: context \to context$

A standalone combinator that automatically removes the active view from the DOM when it leaves the viewport. It leverages `deactivate` internally to trigger the `remove()` operation on the view element, freeing up memory safely.

```coffeescript
import { dispose } from "@dashkite/neon"
import assert from "@dashkite/assert"

assert typeof dispose == "function"
```

### show

$show: context \to context$

A standalone combinator that displays the view for the active render context. It iterates over any existing active elements within the root to hide them, and subsequently applies the "active" class to the current `page` and `view` elements in the context.

```coffeescript
import { show } from "@dashkite/neon"
import assert from "@dashkite/assert"

assert typeof show == "function"
```

### event

$event: name, handler \to combinator$

Returns a combinator that adds an event listener for the specified DOM event `name` to the current view element. The `handler` is called with the dispatched DOM event object and the rendering `context`. 

```coffeescript
import { event } from "@dashkite/neon"
import assert from "@dashkite/assert"

pipeline = event "click", (e, context) -> console.log "Clicked element in view"
assert typeof pipeline == "function"
```

### success

$success: handler \to combinator$

Returns a combinator that attaches a explicit "success" event listener to the current view element. The `handler` is invoked with the DOM event and the rendering `context`. This pairs well with network operations triggering custom events on completion.

```coffeescript
import { success } from "@dashkite/neon"
import assert from "@dashkite/assert"

pipeline = success (e, context) -> console.log "Success"
assert typeof pipeline == "function"
```

### failure

$failure: handler \to combinator$

Returns a combinator that attaches a explicit "failure" event listener to the current view element. The `handler` is invoked with the DOM event and the rendering `context`. 

```coffeescript
import { failure } from "@dashkite/neon"
import assert from "@dashkite/assert"

pipeline = failure (e, context) -> console.error "Failure"
assert typeof pipeline == "function"
```

### render

$render: selector, template \to combinator$

Returns a combinator that updates the DOM element matching the CSS `selector` with the output of the `template` function. The `template` receives the `context` and MUST return an HTML string. It patches the DOM structurally utilizing `diffHTML` rather than replacing the content entirely, preserving the focus state of unaffected child nodes.

```coffeescript
import { render } from "@dashkite/neon"
import assert from "@dashkite/assert"

pipeline = render "head", ({title}) -> "<title>#{title}</title>"
assert typeof pipeline == "function"
```

### append

$append: selector, template \to combinator$

Returns a combinator that appends the HTML output of the `template` function to the DOM element matching the CSS `selector`. The `template` receives the `context` and MUST return an HTML string. This is particularly useful for infinite scrolling lists or logging interfaces.

```coffeescript
import { append } from "@dashkite/neon"
import assert from "@dashkite/assert"

pipeline = append "#log", ({message}) -> "<li>#{message}</li>"
assert typeof pipeline == "function"
```
