+++
title = "How to Contribute"
description = "Contribute to NeuronBench."
date = 2021-05-01T18:10:00+00:00
updated = 2021-05-01T18:10:00+00:00
draft = false
weight = 410
sort_by = "weight"
template = "docs/page.html"

[extra]
lead = "You can contribute to NeuronBench development!"
toc = true
top = false
+++

👉 Make sure to read the [Code of Conduct](../code-of-conduct/).

## Contribute to the simulator

👉 The NeuronBench simulator code lives in the
[`nb-sim`](https://github.com/neuronbench/nb-sim) repository.

The simulator is written in [Rust](https://rust-lang.org) and builds on top of the
[Bevy Game Engine](https://bevyengine.org).

## Contribute to the configuration language

👉 NeuronBench models are written in [Nickel](https://nickel-lang.org). The code that evaluates them, and the `nb` contracts such as `nb.Scene`, live in the [`nb-nickel`](https://github.com/neuronbench/nb-nickel) repository.

It is written in [Rust](https://rust-lang.org) and builds on top of the
[Nickel](https://github.com/tweag/nickel) configuration language.

## Improve documentation

👉 The documentation lives in [`./content/docs/`](https://github.com/neuronbench/nb-docs/tree/main/content/docs)
of the [`nb-docs`](https://github.com/neuronbench/nb-docs) repository.
