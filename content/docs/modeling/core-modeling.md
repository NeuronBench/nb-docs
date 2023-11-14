+++
title = "Core Modeling"
description = "Deep dive into the entities used in network models."
date = 2021-05-01T08:20:00+00:00
updated = 2021-05-01T08:20:00+00:00
draft = false
weight = 30
sort_by = "weight"
template = "docs/page.html"

[extra]
lead = "Deep dive into the entities used in network models."
toc = true
top = false
+++

## A Top-down Tour

Our plan in this tutorial is to start with a fully functioning network (a
`Scene`), unwrap it layer by layer, until we work our way down to the definition
of ion channels.

It can be overwhelming to encounter abstract things like `Scene`, the unfamiliar
syntaxn of NeuronBench's language, and the many layers of a network
specification all at once. If you are familiar with ion channels and prefer to
learn in the bottom-up direction, starting with channels, then building
membranes and neurons, you might like to start with [Building a Neuron From
Scratch](../../tutorials/build-a-neuron-from-scratch/).

## Import links

The Model we created in [Quick Start](../quick-start/) contained the following
code:

```
let my_scene = https://neuronbench.com/imalsogreg/docs-demo/scene.ffg
in my_scene
```

The URL is a link to another model hosted on NeuronBench. We don't
actually need to assign that URL to a name and then use the name - it
would be sufficient to use this code for our Model:

```
https://neuronbench.com/imalsogreg/docs-demo/scene.ffg
```

Our example uses the first version to emphasize that models are not
_just_ URLs, they are expressions in a configuration language.

The meaning of a URL in our language is equivalent to the content that exists
at that URL. If you actually navigate to the URL, you will find more
complicated configuration code:

```
let neuron = https://neuronbench.com/imalsogreg/docs-demo/neuron.ffg
let synapses = https://neuronbench.com/imalsogreg/docs-demo/synapse.ffg
let stimulator =
  Stimulator {
    envelope: {
      period_sec: 0.1,
      onset_sec: 0.0,
      offset_sec: 0.05
    },
    current_shape: SquareWave {
      on_current_uamps_per_square_cm: 100.0,
      off_current_uamps_per_square_cm: 200.0
    }
  }
in
Scene {
  neurons: [

    { neuron: neuron
    , location: { x_mm: 0.5, y_mm: 0.1, z_mm: 0.0 }
    , stimulator_segments: [
        { segment: 30
        , stimulator: stimulator
        }
      ]
    },

    { neuron: neuron
    , location: { x_mm: -0.4, y_mm: 0.5, z_mm: 0.0 }
    , stimulator_segments: []
    }

  ],
  synapses: synapses
}
```

## Simplified Scene

Let's strip this down to see how a `Scene` works.

```
Scene {
  neurons: [],
  synapses: []
}
```

A `Scene` is defined by using the `Scene` constructor followed by its record
fields: `neurons` and `synapses`. The `neurons` field specifies a list of
located neurons, and the `synapses` field specifies a list of synapses. In
our first example, both lists are empty.

To make our scene more interesting, let's add a located neuron.

```
Scene {
  neurons: [
    { neuron: https://neuronbench.com/imalsogreg/docs-demo/neuron.ffg,
      location: { x_mm: 0.0, y_mm: 0.0, z: 0.0 },
      stimulator_segments: []
    }
  ],
  synapses: []
}
```

A located neuron is defined as a record with these three fields:

  - `neuron`: A [Neuron](../language-ref/neuron/), which we will explore soon.
  - `location`: A record with fields specifying the x, y and z location of the soma.
  - `stimulator_segments`: A list of pairs of `segment` and [Stimulator](../language-ref/stimulator/)

#### Aside: Constructors vs. records

You may wonder - why does `Scene`need a constructor before the record, when
things like located neuron and location don't need a constructor?

This follows from the role constructors play in the configuration language:
ensuring that a configuration has all the required components. We will see later
that the configuration is very flexible. You can create records with any fields
that you like, and recombine them, giving you a low of power when building up
large networks. The `Scene` constructor's job is to make sure that all the
required fields of a scene are present in the record, when all is said and done,
and that all of the specified fields have the correct type.

The language chooses certain meaningful entities as ones that need constructors:
scenes, neurons, synapses, membranes, and channels.

## The Neuron Constructor

Next we will next examine the file linked within our located neuron:
`https://neuronbench.com/imalsogreg/docs-demo/neuron.ffg`

```
let membranes = https://neuronbench.com/imalsogreg/docs-demo/membranes.ffg
in
Neuron {
 membranes: [
    membranes.pyramidal_cell.soma,
    membranes.pyramidal_cell.axon,
    membranes.pyramidal_cell.basal_dendrite,
    membranes.pyramidal_cell.apical_dendrite,
    membranes.pyramidal_cell.apical_dendrite,
 ],
 segments: [
  {id: 1, x: 1273.4436, y: 1106.0421, z: 72.3856, r: 6.9784, type: 1, parent: -1},
  {id: 30, x: 1262.873, y: 1141.7006, z: 69.9832, r: 0.1144, type: 2, parent: 1},
  {id: 60, x: 1250.3691, y: 1171.8221, z: 71.7704, r: 0.1144, type: 2, parent: 30},
  {id: 90, x: 1238.3686, y: 1203.0647, z: 76.5666, r: 0.1144, type: 2, parent: 60},
  {id: 100, x: 1234.0442, y: 1213.0633, z: 80.3158, r: 0.1144, type: 2, parent: 90},
  ...
  ]
}
```

The `Neuron` constructor applies to a record with two fields:

 - `membranes`: A list of [`Membrane`s](../language-ref/membrane/).
 - `segments`: A list of segment records. Segments specify the morphology of the neuron
    and its linkage to the membrane. A segment record has these fields:
      - `id`: An identifier label for the segment.
      - `x`: X position in &micro;m.
      - `y`: Y position in &micro;m.
      - `z`: Z position in &micro;m.
      - `r`: Radius in &micro;m.
      - `type`: Numerical code for the membrane type.
      - `parent`: The `id` of the segment upstream of this segment.
 
 This representation is adapted from the standard SWC format. `type` has the
 following code:
 
  1. Soma
  2. Axon
  3. Dendrite
  4. Apical Dendrite
  5. Other

The simulator uses these codes as an index into the list of `membranes` to give
each segment its biophysical properties. The first `Membrane` in your `membranes`
list will be applied to every segment with `type: 1` (Soma). The second
entry in `membranes` will be applied to every segment with `type: 2` (Axon), etc.

#### Aside: let _ in _

