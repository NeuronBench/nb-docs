+++
title = "Core Modeling"
description = "Introduction to the core entities in network models."
date = 2021-05-01T08:20:00+00:00
updated = 2021-05-01T08:20:00+00:00
draft = false
weight = 30
sort_by = "weight"
template = "docs/page.html"

[extra]
lead = "Introduction to the core entities in network models."
toc = true
top = false
+++

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
in
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
  } in

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

### Interpreting this code

Since a URL is equivalent to the configuration stored at that URL, we can
replace 
