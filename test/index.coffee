import { test, success } from "@dashkite/amen"
import print from "@dashkite/amen-console"

import { sleep } from "@dashkite/joy"
import * as k from "@dashkite/katana"
import * as m from "@dashkite/mimic"
import browse from "@dashkite/genie-presets/browser"

do browse ({browser, port}) ->

  # TODO the browser sometimes starts up before we've
  # apparently finished writing the build products
  await sleep 1000

  print await test "Tests", [

    await do m.launch browser, [
      m.page
      m.goto "http://localhost:#{port}/"
      m.waitFor -> window.__test?
      m.evaluate -> window.__test
      k.get
    ]

  ]

  process.exit if success then 0 else 1
