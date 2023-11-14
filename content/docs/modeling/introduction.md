+++
title = "Introduction"
description = "AdiDoks is a Zola theme helping you build modern documentation websites, which is a port of the Hugo theme Doks for Zola."
date = 2021-05-01T08:00:00+00:00
updated = 2021-05-01T08:00:00+00:00
draft = false
weight = 10
sort_by = "weight"
template = "docs/page.html"

[extra]
lead = 'Welcome! The <a href="https://neuronbench.com">NeuronBench</a> dashboard is your hub for creating models, managing who can access and edit your files, and controlling your settings and billing information.'
toc = true
top = false
+++


## Quick Start

In just a few minutes, you will create an account, start your first project and
populate it with a copy of the demo model (a network with two neurons and a
synapse). <br/> [Quick Start →](../quick-start/)

## Core Modeling Concepts

Building in our [Quick Start](../quick-start/) project, we will unpack the sample network. We will write the top-level `Scene` component by remixing the pre-written `Neuron`, `Stimulator` and `Synapse` components.

We will then unpack `Neuron`, defining it in terms of its morphology and `Membrane`s.

And finally we will unpack `Membrane` to learn how `Channel`s are specified.

At the end of the tutorial, we will have fully defined the demo scene, without any external links, and we can freely experiment with channel properties to see what impact they have on the network.
<br/> [Core Modeling →](../core-modeling/)



## Contributing

Find out how to contribute to NeuronBench. [Contributing →](../../contributing/how-to-contribute/)

## Help

Get help on Doks. [Help →](../../help/faq/)
