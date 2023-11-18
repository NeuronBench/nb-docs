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
let m = https://neuronbench.com/imalsogreg/docs-demo/membranes.ffg
in
Neuron {
 membranes: [
    m.pyramidal_cell.soma,
    m.pyramidal_cell.axon,
    m.pyramidal_cell.basal_dendrite,
    m.pyramidal_cell.apical_dendrite,
    m.pyramidal_cell.apical_dendrite,
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

Let's take a moment to understand a pattern that has appeared a few times: "let
expressions". A "let expression" (which looks like `let x = y in z`) is used to
assign `y` to the variable `x` within the expressio `z`.

Let expressions are useful for removing duplication. In our `Neuron`, we used
a let expression to create a shorthand reference to
`https://neuronbench.com/imalsogreg/docs-demo/membranes.ffg`. We did not have to
do this. Here is what the code would have looked like without the let expression:

```
Neuron {
 membranes: [
    (https://neuronbench.com/imalsogreg/docs-demo/membranes.ffg).pyramidal_cell.soma,
    (https://neuronbench.com/imalsogreg/docs-demo/membranes.ffg).pyramidal_cell.axon,
    (https://neuronbench.com/imalsogreg/docs-demo/membranes.ffg).pyramidal_cell.basal_dendrite,
    (https://neuronbench.com/imalsogreg/docs-demo/membranes.ffg).pyramidal_cell.apical_dendrite,
    (https://neuronbench.com/imalsogreg/docs-demo/membranes.ffg).pyramidal_cell.apical_dendrite,
 ],
 segments: [
  {id: 1, x: 1273.4436, y: 1106.0421, z: 72.3856, r: 6.9784, type: 1, parent: -1},
  {id: 30, x: 1262.873, y: 1141.7006, z: 69.9832, r: 0.1144, type: 2, parent: 1},
  {id: 60, x: 1250.3691, y: 1171.8221, z: 71.7704, r: 0.1144, type: 2, parent: 30},
  {id: 90, x: 1238.3686, y: 1203.0647, z: 76.5666, r: 0.1144, type: 2, parent: 60},
  {id: 100, x: 1234.0442, y: 1213.0633, z: 80.3158, r: 0.1144, type: 2, parent: 90},
  ...
  ]
```

This is valid, but repetitive.

A let expression can be used anywhere that a normal expression could appear. For example,
we could rewrite our original `Neuron` this way:

```
Neuron {
 membranes: 
   let m = https://neuronbench.com/imalsogreg/docs-demo/membranes.ffg in
     [
       m.pyramidal_cell.soma,
       m.pyramidal_cell.axon,
       m.pyramidal_cell.basal_dendrite,
       m.pyramidal_cell.apical_dendrite,
       m.pyramidal_cell.apical_dendrite,
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

Where you put let expressions is up to you as the author of your configuration
files.

One helpful convention to follow: **When using URL to other configuration files,
it is good practice to use let expressions to bind them to a name at the beginning
of your configuration file,** as was done in the original `Neuron` configuration
example. This makes it easy to see your external dependencies at a glance. Conversely
if you scatter URLs through a large configuration file, it can become hard to remember
which files depend on which other files.

## The Membrane Constructor

Let's examine the contents of
`https://neuronbench.com/imalsogreg/docs-demo/membranes.ffg`.

```
let channels = https://neuronbench.com/imalsogreg/docs-demo/channels.ffg
let leak = channels.giant_squid.leak
let k_slow = channels.rat_thalamocortical.k_slow
let na_transient = channels.rat_thalamocortical.na_transient
let hcn_soma = channels.rat_ca1_pyramidal.hcn_soma
let hcn_dendrite = channels.rat_ca1_pyramidal.hcn_dendrite

in {

  pyramidal_cell: {

    apical_dendrite: Membrane {
      capacitance_farads_per_square_cm: 2.0e-6,
      membrane_channels: [
        { channel: na_transient , siemens_per_square_cm: 0.023 },
        { channel: leak , siemens_per_square_cm: 0.03e-3 },
        { channel: hcn_dendrite , siemens_per_square_cm: 0.08e-3 },
        { channel: k_slow , siemens_per_square_cm: 0.040 }
      ]
    },

    basal_dendrite: Membrane {
      capacitance_farads_per_square_cm: 2.0e-6,
      membrane_channels: [
        { channel: leak , siemens_per_square_cm: 0.03e-3 },
        { channel: hcn_dendrite , siemens_per_square_cm: 0.08e-3 }
      ]
    },

    axon_initial_segment: Membrane {
      capacitance_farads_per_square_cm: 1.0e-6,
      membrane_channels: [
        { channel: na_transient , siemens_per_square_cm: 120.0e-3 },
        { channel: leak , siemens_per_square_cm: 0.3e-3 },
        { channel: k_slow , siemens_per_square_cm: 36.0e-3 }
      ]
    },

    axon: Membrane {
      capacitance_farads_per_square_cm: 1.0e-6,
      membrane_channels: [
        { channel: na_transient , siemens_per_square_cm: 120.0e-3 },
        { channel: leak , siemens_per_square_cm: 0.3e-3 },
        { channel: k_slow , siemens_per_square_cm: 36.0e-3 }
      ]
    },

    soma: Membrane {
      capacitance_farads_per_square_cm: 1.0e-6,
      membrane_channels: [
        { channel: k_slow, siemens_per_square_cm: 36.0e-3 },
        { channel: na_transient, siemens_per_square_cm: 120.0e-3 },
        { channel: leak, siemens_per_square_cm: 3.0e-5 }
      ]
    }

  }
}
```

#### Aside - Bare records

There are two things to understand before we focus on the details of
a `Membrane` - The use of `let _ in _` and the fact that the top level
record in this file does not have a constructor.

We use `let _ in _` to import the configuration at
`https://neuronbench.com/imalsogreg/docs-demo/channels.ffg` and give it the
name `channels`. Then we use more `let` bindings to bind subfields of
`channels` to short names. For example, we bind `channels.giant_squid.leak`
to the name `leak`. Later, when we examine the `channels.ffg` configuration file,
we will see how these subfields `giant_squid` and `leak` are defined.

After our name bindings, we have a top-level record with no constructor.
It has one top-level field, `pyramidal_cell`, which in turn has the fields
`apical_dendrite`, `basal_dendrite`, `axon_initial_segment`, etc. Only
under these fields do we see our constructor, `Membrane`. How do we interpret
these top-level records with no constructor?

A top-level record without a constructor can have any fields that you like. It
is a free-from way for you to organize your data. This is the main distinction
between bare records and records that start with constructors. Bare records are
flexible and can take whatever shape is useful for you in organizing your data.
Constructor records represent concrete entities in the simulation and must
contain exactly the set of fields and sub-fields needed by that entity.

#### Membranes

A `Membrane` represents a unit area of cell membrane, which has an intrinsic
capacitance (per unit area) and any number of active ion conductances (also
per unit area).

The `Membrane` constructor has two fields:
 - `capacitance_farads_per_square_cm`: The membrane capacitance.
 - `membrane_channels`: A list of channels and their expression levels in this membrane. Each element is a record with the fields:
   - `channel`: The `Channel` type.
   - `siemens_per_square_cm`: The peak conductance for that channel in a unit area of this type membrane.

## The Channel Constructor

Channels are the lowest level entity in NeuronBench. They are also fairly
complicated, since they are responsible for all of the Hodgkin-Huxley dynamics
of the simulation. Let's look at the
configuration file `https://neuronbench.com/imalsogreg/docs-demo/channels.ffg`,
which was imported by `https://neuronbench.com/imalsogreg/docs-demo/membranes.ffg`,
to see some `Channel`s.

```
{

  giant_squid: {
     k: Channel {
       ion_selectivity: { k: 1.0, na: 0.0, cl: 0.0, ca: 0.0 },
       activation: {
         gates: 4,
         magnitude: {v_at_half_max_mv: -53.0, slope: 15.0},
         time_constant: Gaussian
           { v_at_max_tau_mv: -79.0,
             c_base: 1.1e-3,
             c_amp: 4.7e-3,
             sigma: 50.0
           }
       },
       inactivation: null,
     },

     na: Channel {
       ion_selectivity: { k: 0.0, na: 1.0, cl: 0.0, ca: 0.0 },
       activation: {
         gates: 3,
         magnitude: {v_at_half_max_mv: -40.0, slope: 15.0},
         time_constant: Gaussian
           { v_at_max_tau_mv: -38.0,
             c_base: 0.04e-3,
             c_amp: 0.46e-3,
             sigma: 30.0
           }
       },
       inactivation: {
         gates: 1,
         magnitude: {v_at_half_max_mv: -62.0, slope: -7.0},
         time_constant: Gaussian
           { v_at_max_tau_mv: -67.0,
             c_base: 1.2e-3,
             c_amp: 7.4e-3,
             sigma: 20.0
           }
       }
     },

     leak: Channel {
       ion_selectivity: { k: 0.0, na: 0.0, cl: 1.0, ca: 0.0 },
       activation: null,
       inactivation: null,
     }
  },

  rat_thalamocortical: {

    na_transient: Channel {
      ion_selectivity: { k: 0.0, na: 1.0, cl: 0.0, ca: 0.0 },
      activation: {
        gates: 1,
        magnitude: {v_at_half_max_mv: -30.0, slope: 5.5},
        time_constant: Instantaneous {}
      },
      inactivation: {
        gates: 1,
        magnitude: {v_at_half_max_mv: -70.0, slope: -5.8},
        time_constant: LinearExp {
          coef: 3.0,
          v_offset_mv: -40.0,
          inner_coef: 0.03
        }
      }
    },
    k_slow: Channel {
      ion_selectivity: { k: 1.0, na: 0.0, cl: 0.0, ca: 0.0 },
      activation: {
        gates: 1,
        magnitude: {v_at_half_max_mv: -3.0, slope: 10.0},
        time_constant: Gaussian {
          v_at_max_tau_mv: -50.0,
          c_base: 0.005,
          c_amp: 0.047,
          sigma: 0.030,
        }
      },
      inactivation: {
        gates: 1,
        magnitude: {v_at_half_max_mv: -51.0, slope: -12.0},
        time_constant: Gaussian {
          v_at_max_tau_mv: -50.0,
          c_base: 0.36,
          c_amp: 0.1,
          sigma: 50.0
        }
      }
    }
  },

  rat_ca1_pyramidal: {
    hcn_soma: Channel {
      ion_selectivity: { na: 0.35, k: 0.65, cl: 0.0, ca: 0.0 },
      activation: null,
      inactivation: {
        gates: 1,
        magnitude: {v_at_half_max_mv: -82.0, slope: -9.0},
        time_constant: Gaussian {
          v_at_max_tau_mv: -75.0,
          c_base:  10.0e-3,
          c_amp:  50.0e-3,
          sigma: 20.0
        } 
      }
    },
    hcn_dendrite: Channel {
      ion_selectivity: { na: 0.55, k: 0.45, cl: 0.0, ca: 0.0 },
      activation: null,
      inactivation: {
        gates: 1,
        magnitude: {v_at_half_max_mv: -90.0, slope: -8.5},
        time_constant: Gaussian {
          v_at_max_tau_mv: -75.0,
          c_base: 10.0e-3,
          c_amp: 40.0e-3,
          sigma:  20.0
        }
      }
    }
  }
}
```

Like our `membranes.ffg` model, `channels.ffg` is a bare top-level record that
uses custom fields to group various channels together. This grouping is arbitrary,
and it would have been valid to put each channel into its own file, letting each
file begin with a `Channel` constructor, instead of grouping them all into one
struct.

A `Channel` constructor record contains three fields:
 - `ion_selectivity`: A record specifying the relative permiability of the channel to Na+, K+, Ca++, and Cl-.
 - `activation`, which we will describe below.
 - `inactivation`, identical to activation.

The simplest example to look at is the field `giant_squid.leak`:

```
...
     leak: Channel {
       ion_selectivity: { k: 0.0, na: 0.0, cl: 1.0, ca: 0.0 },
       activation: null,
       inactivation: null,
     }
...
```

`ion_selectivity` specifies that this channel is only permeable to Cl-. The constructor
enforces that `activation` and `inactivation` are specified, but `null` is a valid
value since not all channels activate or inactivate.

For an example of a channel with an activation mechanism we will look at the
giant squid axon's potassium channel:

```
     k: Channel {
       ion_selectivity: { k: 1.0, na: 0.0, cl: 0.0, ca: 0.0 },
       activation: {
         gates: 4,
         magnitude: {v_at_half_max_mv: -53.0, slope: 15.0},
         time_constant: Gaussian
           { v_at_max_tau_mv: -79.0,
             c_base: 1.1e-3,
             c_amp: 4.7e-3,
             sigma: 50.0
           }
       },
       inactivation: null,
     },
```



The `activation` field, when not `null`, has the fields:

 - `gates`
 - `magnitude`
 - `time_constant`

These fields are easiest to understand if we refer back to the formulas
describing the Hodgkin-Huxley dynamics. The following formula gives the
instantaneous current through the K channels in terms the maximal K
conductance <math display="inline"> <msub><mi>g</mi><mi>K</mi></msub></math>,
the activation <math display="inline"> <mi>n</mi> </math>, the number of gates
in a given channel ( <math display="inline"> <mi>4</mi></math> for this channel ),
and the difference between the membrane potential and the K reversal potential.
The `gates` parameter for our K channel is therefore `4`.

<math display="block">
  <mi>I</mi>
  <mo>=</mo>
  <msub>
    <mi>g</mi>
    <mi>K</mi>
  </msub>
  <mo>&#8290;</mo>
  <msup>
    <mi>n</mi>
    <mn>4</mn> <!-- Corresponds to activation.gates -->
  </msup>
  <mo>&#8290;</mo>
  <mo>(</mo>
  <mi>V</mi>
  <mo>-</mo>
  <msub>
    <mi>E</mi>
    <mi>K</mi>
  </msub>
  <mo>)</mo>
</math>


<math display="inline"> <mi>n</mi></math> the activation is a dynamic value. It has
a steady-state value
<math display="inline">
  <msub><mi>n</mi><mi>&#x221E;</mi></msub><mi>(</mi><mi>V</mi><mi>)</mi>
  </math>, which is a function of the Voltage, and it approaches that steady-state
value at the rate <math display="inline">
  <mi>&tau;</mi><mi>(</mi><mi>V</mi><mi>)</mi>  </math>
, which is also a function of membrane
  voltage `test`.
  
The relationship between the steady state activation level and membrane voltage,
<math display="inline">
  <msub>
    <mi>n</mi>
    <mi>&#x221E;</mi>
  </msub>
  <mi>(</mi>
  <mi>V</mi>
  <mi>)</mi>
</math>
is approximated by the Bolzman function.

<math display="block">
  <msub>
    <mi>n</mi>
    <mo>&#x221E;</mo> <!-- Infinity symbol -->
  </msub>
  <mo>(</mo>
  <mi>V</mi>
  <mo>)</mo>
  <mo>=</mo>
  <mfrac>
    <mn>1</mn>
    <mrow>
      <mn>1</mn>
      <mo>+</mo>
      <mi>exp</mi>
      <mo>{</mo>
      <mo>(</mo>
      <msub>
        <mi>V</mi>
        <mrow>
          <mn>1/2</mn>
        </mrow>
      </msub>
      <mo>-</mo>
      <mi>V</mi>
      <mo>)</mo>
      <mo>/</mo>
      <mi>k</mi>
      <mo>}</mo>
    </mrow>
  </mfrac>
</math>

We specify this function in the `magnitude` field. It has
two parameters:
<math display="inline">
      <msub>
        <mi>V</mi>
        <mrow>
          <mn>1/2</mn>
        </mrow>
      </msub>
</math>, which we specify as `v_at_half_max_mv`, and
<math display="inline"><mi>k</mi></math>, which we specify as `slope`.


The speed at which <math display="inline"><mi>n</mi></math> approaches
<math display="inline"><msub><mi>n</mi><mi>&#x221E;</mi></msub></math> also
depends on membrane voltage, but by a Gaussian function.

<math display="block">
  <mi>&tau;</mi>
  <mo>(</mo>
  <mi>V</mi>
  <mo>)</mo>
  <mo>=</mo>
  <msub>
    <mi>C</mi>
    <mo>base</mo>
  </msub>
  <mo>+</mo>
  <msub>
    <mi>C</mi>
    <mi>amp</mi>
  </msub>
  <mo>&#8290;</mo>
  <mi>exp</mi>
  <mfrac>
    <mrow>
      <mo>-</mo>
      <mo>(</mo>
      <msub>
        <mi>V</mi>
        <mi>max</mi>
      </msub>
      <mo>-</mo>
      <mi>V</mi>
      <mo>)</mo>
      <msup>
        <mo></mo>
        <mn>2</mn>
      </msup>
    </mrow>
    <mrow>
      <mi>&sigma;</mi>
      <msup>
        <mo></mo>
        <mn>2</mn>
      </msup>
    </mrow>
  </mfrac>
</math>

We specify the
Gaussian parameters under the `time_constant` field. We also use a `Gaussian`
constructor, because there are other functions we can use for the time constant
beyond Gaussians, but we will not cover the details of that here.
(See [Time Constants](../../language-reference/time-constants/) if you are
interested).

The parameters of a Gaussian function are specified with the fields `c_base`, `c_amp`, `v_at_max_tau_mv`, and `sigma`.

#### Inactivating Na+ Channels

The `inactivation` field is specified in exactly the same way as the `activation` field,
and is used for channels like the giant squid axon's Na+ channel.

```
     na: Channel {
       ion_selectivity: { k: 0.0, na: 1.0, cl: 0.0, ca: 0.0 },
       activation: {
         gates: 3,
         magnitude: {v_at_half_max_mv: -40.0, slope: 15.0},
         time_constant: Gaussian
           { v_at_max_tau_mv: -38.0,
             c_base: 0.04e-3,
             c_amp: 0.46e-3,
             sigma: 30.0
           }
       },
       inactivation: {
         gates: 1,
         magnitude: {v_at_half_max_mv: -62.0, slope: -7.0},
         time_constant: Gaussian
           { v_at_max_tau_mv: -67.0,
             c_base: 1.2e-3,
             c_amp: 7.4e-3,
             sigma: 20.0
           }
       }
     },
```

We model a Na+ channel the same way as the K channel: specifying its permeativity
to various ions, its activation staeady state magnitude and timecourse, and its
inactivation steady state and timecourse.

## The Synapse Constructor

Returning to our top-level scene, there is one more entity we have to describe,
the Synapse.

Synapses in NeuronBench are modeled conteptually as a pair of mechanisms: a
presynaptic voltage-dependent neurotransmitter pump, and a set of post-synaptic 
ion channels gated by neurotransmitter concentration.

A concrete 
