# Testing Guidelines

This document outlines the approach used to ensure the reliability and correctness of Neon.

## General Approach

Neon employs an in-browser testing strategy to validate its DOM manipulation capabilities accurately. The testing suite leverages Mimic alongside DashKite browser testing presets to launch and control a headless browser environment. This guarantees that elements are rendered, patched, and managed exactly as they would be in a real human experience.

The tests define templates, invoke the combinators, and then assert the presence and structural integrity of the resulting DOM nodes.

## Running Tests

Developers execute the test suite via the `genie` task manager. The suite compiles the CoffeeScript source code, starts a local server, launches the headless browser, and executes the assertions in sequence.

```bash
npx genie test
```
