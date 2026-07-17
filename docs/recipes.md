# Neon Usage Guides

This document explains how to orchestrate web page updates using the Neon combinators. The recipes progress logically from basic DOM manipulation to orchestrating complex, lifecycle-driven architectures.

## Rendering and Appending Static Content

Creators frequently need to patch static content into specific elements or append items to a list without reloading the document. Neon natively enables this through the `render` and `append` combinators.

Neon evaluates a provided template function against a shared context to generate an HTML string. For `render`, it structurally patches the target element via `diffHTML` to minimize mutations. For `append`, it injects the new HTML directly at the end of the target element. 

```coffeescript
import { render, append } from "@dashkite/neon"
import { flow } from "@dashkite/joy/function"

renderContent = flow [
  render "header", ({title}) -> "<h1>#{title}</h1>"
  append "#log", ({message}) -> "<li>#{message}</li>"
]

# Provide context to execute the pipeline
renderContent { title: "Welcome", message: "Rendered successfully." }
```

**Step-by-step Algorithm:**
1. The developer defines a pipeline using `flow`, combining the `render` and `append` combinators.
2. The pipeline receives a context object containing data properties.
3. The `render` combinator selects the `header` element and structurally patches it with the evaluated `title`.
4. The `append` combinator selects the `#log` element and adds a new list item containing the `message`.

## Orchestrating Dynamic Page Views

Developers building single-page applications often need to manage complex view hierarchies and transitions logically, rather than merely updating loose elements. Neon manages this via the `view` and `show` combinators.

The `view` combinator isolates dynamic content inside specific wrapper elements assigned to a route, while the `show` combinator handles the mechanics of hiding old active views and revealing the new one. 

```coffeescript
import { view, show } from "@dashkite/neon"
import { flow } from "@dashkite/joy/function"

transitionView = flow [
  view "main", ({content}) -> "<article>#{content}</article>"
  show
]

transitionView { 
  root: document.body,
  data: { name: "post" },
  path: "/posts/1",
  content: "This is the first post." 
}
```

**Step-by-step Algorithm:**
1. The developer passes a context containing a `root` node, `data.name`, and `path` to the pipeline.
2. The `view` combinator queries the DOM for an existing view matching the path. If none exists, it creates one.
3. The `view` combinator evaluates the template and patches the view element.
4. The `show` combinator locates previously active views within the root, removes their active states, and assigns the active state to the current view.

## Attaching Functional Event Listeners

Once views are instantiated, they must react to interactions and asynchronous events. Creators wire these reactions using the `event`, `success`, and `failure` combinators.

These combinators attach listeners directly to the active view managed by the context. By threading events this way, developers maintain functional purity without reaching outside the pipeline to bind manual listeners.

```coffeescript
import { view, event, success, failure } from "@dashkite/neon"
import { flow } from "@dashkite/joy/function"

interactiveView = flow [
  view "main", ({content}) -> "<button>#{content}</button>"
  event "click", (e, context) -> 
    # fetch external data on click
    console.log "Button clicked."
  success (e, context) -> 
    # update state after successful network fetch
    console.log "Data loaded successfully."
  failure (e, context) -> 
    # handle network errors gracefully
    console.error "Failed to fetch data."
]
```

**Step-by-step Algorithm:**
1. The `view` combinator renders the interactive HTML structure.
2. The `event` combinator attaches a generic click listener to the view element.
3. The `success` and `failure` combinators attach listeners for distinct semantic events, likely dispatched by separate network controllers.
4. When an event fires, the respective handler executes, receiving both the DOM event and the rendering context.

## Managing Complex Visibility Lifecycles

The most intricate aspect of a modern human experience is managing memory and triggering logic as elements move off-screen. Developers orchestrate these subtle lifecycles using the `activate`, `deactivate`, and `dispose` combinators.

Neon backs these combinators with internal `IntersectionObserver` instances. This allows creators to seamlessly fire logic when views enter or leave the viewport, and automatically remove them from the DOM when they are no longer needed.

```coffeescript
import { view, activate, deactivate, dispose } from "@dashkite/neon"
import { flow } from "@dashkite/joy/function"

lazyLoadView = flow [
  view "main", ({content}) -> "<article>#{content}</article>"
  activate (context) -> 
    # trigger complex animations when element enters viewport
    console.log "View is visible on screen."
  deactivate (context) ->
    # pause animations or halt network polling
    console.log "View left the viewport."
  dispose
]
```

**Step-by-step Algorithm:**
1. The `view` combinator initializes or updates the structural element.
2. The `activate` combinator attaches an `IntersectionObserver` that fires its handler the moment the element's intersection ratio exceeds zero.
3. The `deactivate` combinator attaches an observer that fires when the intersection ratio hits zero, pausing heavy processing.
4. The `dispose` combinator hooks into the deactivation lifecycle, invoking `.remove()` on the view element to ensure robust memory cleanup.

## Integrating with Monterey and Cordoba

The most advanced applications utilize Neon not just for view transitions, but as the foundational rendering pipeline orchestrating an entire page lifecycle. Creators achieve this macroscopic page-level orchestration by integrating a cohesive Neon flow with the `monterey` and `cordoba` libraries.

In this pattern, developers distill an entire page lifecycle into a single high-level Neon pipeline. Because `flow` evaluates directly to a function, creators typically inline this pipeline directly as the `render` attribute when defining the page in Monterey. Cordoba then utilizes this registry to listen for navigation events. When a navigation event matches the Monterey route, Cordoba's reactor pipelines the navigation context directly into the Neon flow, which subsequently cascades downward to activate decoupled components.

```coffeescript
import { view, show } from "@dashkite/neon"
import { flow } from "@dashkite/joy/function"
import Registry from "@dashkite/registry"
import Monterey from "@dashkite/monterey"
import Router from "@dashkite/cordoba"

# 1. Initialize a Monterey registry to manage application routes
pages = Monterey.make()

# 2. Register a page and assign the Neon flow directly to the render key
pages.add "/profiles/{id}", 
  name: "view profile"
  render: flow [
    view "main", ({profile}) -> """
      <user-profile 
        name="#{profile.name}" 
        role="#{profile.role}">
      </user-profile>
    """
    show
  ]

# 3. Register the Monterey instance in the global Registry
Registry.set "application", pages

# 4. Initialize Cordoba to start listening for navigation events
Router.run()
```

**Step-by-step Algorithm:**
1. The developer initializes a Monterey registry to structure the application routes.
2. The developer uses `Monterey.make().add` to register a specific route and directly inlines the Neon flow as the value of the `render` key.
3. The developer registers the active Monterey instance into the global Registry under the name `"application"`.
4. The developer executes `Router.run()`, which triggers Cordoba to establish its internal reactive pipeline. Cordoba handles matching navigation events against the registry and executing the associated Neon flow automatically.
