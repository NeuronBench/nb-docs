+++
title = "Quick Start"
description = "Speed-running a new project on NeuronBench."
date = 2021-05-01T08:20:00+00:00
updated = 2021-05-01T08:20:00+00:00
draft = false
weight = 20
sort_by = "weight"
template = "docs/page.html"

[extra]
lead = "How to interact with live neuron models."
toc = true
top = false
+++

## Overview

NeuronBench simulates small neural network models in the web browser. These models
run withouth needing to install any 

## Finding a model

NeuronBench models are built by modelers and shared through custom links. You
can find an example neuron at
[https://nbnch.io/s/xnzs-qhdf](https://nbnch.io/s/xnzs-qhdf). Open this in a new
window so you can play with it while reading these instructions.

## Navigating the default view

![A screetshot of the default simulator UI](../fig10.jpg "The default view").

*Image credit: DALL-E2*

The simulation will start with a view of the neural network and the
`NeuronBench` menu.

## Runtime Stats

Click the triangle next to "Runtime Stats" to see basic information about the
simulation, like the current simulation time and the simulation's frame rate
on your machine.

Use the `Simulation step` slider to choose how far the simulation should progress
in every update. Smaller simulation steps result in a more accurate simulation and allow you
to see activity on a much finer timescale. Longer steps result in more simulated time
passing per unit of wall clock time, allowing you to see more activity unfold with
less waiting. The simulation step has an upper limit because large timesteps are less
accurate, and steps of several dozen microseconds can cause the simulation to become
unstable.

## Stimulation

The `Stimulation` submenu allows you to choose the properties of a stimulation probe.

![A screenshot of the stimulation prob configuration](../fig20.jpg "Stimulation probe config").

The settings in the above screenshot produce a 10 Hz square wave that turns on
1 ms after the beginning of a cycle and turns off 50ms into the cycle. The on-current
is 50 &micro;A and the off-current is -10&micro;A.

Clicking on any segment of a neuron will place a stimulation probe with those properties.
Stimulation probes are drawn as spheres that are white when selected, and either blue
or red when unselected, depending on whether they are producing negative or positive current.

![A screenshot of a segment with an attached probe](../fig30.jpg "A stimulation probe on a segment").

Existing stimulators can be modified by clicking them and editing their properties
in the `Stimulation` submenu.

Note that the default network in our example contains one highly active
stimulation probe. It drives the network hard enough that the effects of
subsequent probes will be hard to see. When experimenting with stimulations
probes on the default network, the first thing you should do is select the
preexisting stimulator and reduce its on-current to 0, so that your new
stimulators aren't crowded out.

## Oscilloscope traces

The `Oscilloscope` submenu allows you to attach up to 4 oscilloscope probes to
segments in the network. To attach a probe to a segment, click one of the 4
numbers in the `Oscilloscope` submenu, then click on a segment.

![A screenshot of the oscilloscope](../fig40.jpg "Three oscilloscope traces").
