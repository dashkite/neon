# Technical Notes

This document provides architectural context and implementation details for Neon.

### DOM Patching Mechanics

Neon delegates structural DOM updates to `diffHTML`. This library implements a specific algorithm to compare the existing Document Object Model against the newly generated HTML string and applies minimal mutations. Neon leverages this capability to preserve the state of unaffected elements while swiftly updating changing text and attributes.

### Context Preservation

The design of Neon relies heavily on a mutable context object threaded through combinators using utilities like `joy/function.tee`. This pipeline-oriented architecture guarantees that each combinator has access to the accumulated state of the page generation process without relying on external side effects. It maintains functional purity for the developers consuming the API.

### Intersection Observer Lifecycle

Neon utilizes `IntersectionObserver` internally to power the `activate`, `deactivate`, and `dispose` combinators. The observers are configured with a threshold of 0, meaning they fire exactly when the element enters or leaves the visible viewport. This enables fine-grained lifecycle management without requiring creators to wire up manual scroll event listeners.

### Page-Level Orchestration

While Neon manages granular components, its functional composition directly supports rendering architectures at the macroscopic page level. The design operates on the assumption that the broader application has already logically identified the active page. Given that identity, Neon allows creators to readily construct the encompassing page markup and orchestrate the functions necessary to verify and update that structure.

This pipeline-oriented approach ensures that developers can distill an entire page lifecycle into a single, high-level function. This cohesive function integrates seamlessly with the `monterey` and `cordoba` routing pair. Once a DashKite application resolves a route and determines a page is active, it triggers this primary function. The resulting Neon flow cascades downward, instantiating and updating individual components. These components subsequently activate, operating as decoupled reactive objects that communicate independently with their distinct network resources.
