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
specification all at once.

<!--
If you are familiar with ion channels and prefer to
learn in the bottom-up direction, starting with channels, then building
membranes and neurons, you might like to start with [Building a Neuron From
Scratch](../../tutorials/build-a-neuron-from-scratch/). -->

## Import links

The Model we created in [Quick Start](../quick-start/) contained the following
code:

```
let my_scene = import "/imalsogreg/docs-demo/scene.ncl" in
my_scene
```

`import` followed by a path is a link to another model hosted on NeuronBench.
We don't actually need to assign the import to a name and then use the name -
it would be sufficient to use this code for our Model:

```
import "/imalsogreg/docs-demo/scene.ncl"
```

Our example uses the first version to emphasize that models are not
_just_ links, they are expressions in a configuration language. That language
is [Nickel](https://nickel-lang.org), with a few NeuronBench additions that we
will meet below.

The meaning of an import is the content of the file it names. If you open
`https://neuronbench.com/imalsogreg/docs-demo/scene.ncl`, you will find more
complicated configuration code:

```
let neuron_ = import "neuron.ncl" in
let synapse = import "synapse.ncl" in
let stimulator_ =
  {
    envelope = {
      period_sec = 0.010,
      onset_sec = 0.000,
      offset_sec = 0.001
    },
    current_shape = {
      type = 'SquareWave,
      on_current_uamps_per_square_cm = 500.0,
      off_current_uamps_per_square_cm = -20.0
    }
  } | nb.Stimulator
in
{
  neurons = [

    { neuron = neuron_
    , location = { x_mm = 0.5, y_mm = 0.1, z_mm = 0.0 }
    , stimulator_segments = [
        { segment = 30
        , stimulator = stimulator_
        }
      ]
    },

    { neuron = neuron_
    , location = { x_mm = -0.0, y_mm = 0.55, z_mm = 0.0 }
    , stimulator_segments = []
    }

  ],
  synapses = [synapse]
} | nb.Scene
```

The first two lines import two more files. A path that starts with `/`, like
the one in our own Model, is the address of a file on NeuronBench. A path
without the leading `/` is relative to the file doing the importing, so
`neuron.ncl` here is the file next to `scene.ncl`, in the same project.

## Simplified Scene

Let's strip this down to see how a `Scene` works.

```
{
  neurons = [],
  synapses = []
} | nb.Scene
```

A `Scene` is a record with two fields, `neurons` and `synapses`, followed by
`| nb.Scene`. The `neurons` field specifies a list of located neurons, and the
`synapses` field specifies a list of synapses. In our first example, both lists
are empty.

To make our scene more interesting, let's add a located neuron.

```
{
  neurons = [
    { neuron = import "/imalsogreg/docs-demo/neuron.ncl",
      location = { x_mm = 0.0, y_mm = 0.0, z_mm = 0.0 },
      stimulator_segments = []
    }
  ],
  synapses = []
} | nb.Scene
```

A located neuron is defined as a record with these three fields:

  - `neuron`: A `Neuron`, which we will explore soon.
  - `location`: A record with fields specifying the x, y and z location of the soma.
  - `stimulator_segments`: A list of pairs of `segment` and `stimulator`.

#### Aside: Contracts vs. plain records

You may wonder - why is the scene's record followed by `| nb.Scene`, when
things like the located neuron and its location are plain records?

`nb.Scene` is a _contract_, and writing `| nb.Scene` after a record applies the
contract to it. The contract's job is to make sure that all the required fields
of a scene are present in the record, that there are no fields a scene does not
have, and that every field has the correct type. When a record breaks its
contract, saving the Model reports an error that points at the field at fault.

We will see later that the configuration is very flexible. You can create
records with any fields that you like, and recombine them, giving you a lot of
power when building up large networks. Contracts check that, when all is said
and done, the meaningful entities have the right shape.

NeuronBench provides contracts for these entities: scenes (`nb.Scene`), neurons
(`nb.Neuron`), synapses (`nb.Synapse`), membranes (`nb.Membrane`), channels
(`nb.Channel`) and stimulators (`nb.Stimulator`). A contract also checks the
records nested inside it. `nb.Scene` checks each located neuron and its
location, which is why those did not need a contract of their own.

## The Neuron Contract {#the-neuron-constructor}

Next we will next examine the file imported within our located neuron:
`/imalsogreg/docs-demo/neuron.ncl`

```
let membranes_ = import "membranes.ncl" in
{
 membranes = [
    membranes_.pyramidal_cell.soma,
    membranes_.pyramidal_cell.axon,
    membranes_.pyramidal_cell.basal_dendrite,
    membranes_.pyramidal_cell.apical_dendrite,
    membranes_.pyramidal_cell.apical_dendrite,
 ],
 segments = [
  {id = 1, x = 1273.4436, y = 1106.0421, z = 72.3856, r = 6.9784, type = 1, parent = -1},
  {id = 30, x = 1262.873, y = 1141.7006, z = 69.9832, r = 0.1144, type = 2, parent = 1},
  {id = 60, x = 1250.3691, y = 1171.8221, z = 71.7704, r = 0.1144, type = 2, parent = 30},
  {id = 90, x = 1238.3686, y = 1203.0647, z = 76.5666, r = 0.1144, type = 2, parent = 60},
  {id = 100, x = 1234.0442, y = 1213.0633, z = 80.3158, r = 0.1144, type = 2, parent = 90},
  ...
  ]
} | nb.Neuron
```

The `nb.Neuron` contract applies to a record with two fields:

 - `membranes`: A list of `Membrane`.
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
list will be applied to every segment with `type = 1` (Soma). The second
entry in `membranes` will be applied to every segment with `type = 2` (Axon), etc.

#### Aside: let _ in _

Let's take a moment to understand a pattern that has appeared a few times: "let
expressions". A "let expression" (which looks like `let x = y in z`) is used to
assign `y` to the variable `x` within the expression `z`. To assign several
variables, write one let expression inside the next, each with its own `in`, as
the scene did: `let a = 1 in let b = 2 in a + b`.

Let expressions are useful for removing duplication. In our `Neuron`, we used
a let expression to create a shorthand reference to
`import "membranes.ncl"`. We did not have to
do this. Here is what the code would have looked like without the let expression:

```
{
 membranes = [
    (import "membranes.ncl").pyramidal_cell.soma,
    (import "membranes.ncl").pyramidal_cell.axon,
    (import "membranes.ncl").pyramidal_cell.basal_dendrite,
    (import "membranes.ncl").pyramidal_cell.apical_dendrite,
    (import "membranes.ncl").pyramidal_cell.apical_dendrite,
 ],
 segments = [
  {id = 1, x = 1273.4436, y = 1106.0421, z = 72.3856, r = 6.9784, type = 1, parent = -1},
  {id = 30, x = 1262.873, y = 1141.7006, z = 69.9832, r = 0.1144, type = 2, parent = 1},
  {id = 60, x = 1250.3691, y = 1171.8221, z = 71.7704, r = 0.1144, type = 2, parent = 30},
  {id = 90, x = 1238.3686, y = 1203.0647, z = 76.5666, r = 0.1144, type = 2, parent = 60},
  {id = 100, x = 1234.0442, y = 1213.0633, z = 80.3158, r = 0.1144, type = 2, parent = 90},
  ...
  ]
} | nb.Neuron
```

This is valid, but repetitive.

A let expression can be used anywhere that a normal expression could appear. For example,
we could rewrite our original `Neuron` this way:

```
{
 membranes =
   let m = import "membranes.ncl" in
     [
       m.pyramidal_cell.soma,
       m.pyramidal_cell.axon,
       m.pyramidal_cell.basal_dendrite,
       m.pyramidal_cell.apical_dendrite,
       m.pyramidal_cell.apical_dendrite,
     ],
 segments = [
  {id = 1, x = 1273.4436, y = 1106.0421, z = 72.3856, r = 6.9784, type = 1, parent = -1},
  {id = 30, x = 1262.873, y = 1141.7006, z = 69.9832, r = 0.1144, type = 2, parent = 1},
  {id = 60, x = 1250.3691, y = 1171.8221, z = 71.7704, r = 0.1144, type = 2, parent = 30},
  {id = 90, x = 1238.3686, y = 1203.0647, z = 76.5666, r = 0.1144, type = 2, parent = 60},
  {id = 100, x = 1234.0442, y = 1213.0633, z = 80.3158, r = 0.1144, type = 2, parent = 90},
  ...
  ]
} | nb.Neuron
```

Where you put let expressions is up to you as the author of your configuration
files.

One helpful convention to follow: **When importing other configuration files,
it is good practice to use let expressions to bind them to a name at the beginning
of your configuration file,** as was done in the original `Neuron` configuration
example. This makes it easy to see your external dependencies at a glance. Conversely
if you scatter imports through a large configuration file, it can become hard to remember
which files depend on which other files.

#### Aside: Why `membranes_`?

Our `Neuron` binds its import to the name `membranes_`, with an underscore at
the end, and the scene did the same with `neuron_` and `stimulator_`. The
underscore is there to avoid a clash with a field name.

Inside a record, the name of a field refers to that field. So within
`{ membranes = ... }`, the name `membranes` means the field being defined, and
not a variable of the same name bound outside the record. Writing
`let neuron = import "neuron.ncl" in { neuron = neuron }` defines the field
`neuron` in terms of itself, which fails with an "infinite recursion" error.

When a variable would share its name with a field of the record where you use
it, give the variable a different name. Ours add an underscore.

## The Membrane Contract {#the-membrane-constructor}

Let's examine the contents of
`https://neuronbench.com/imalsogreg/docs-demo/membranes.ncl`.

```
let channels = import "channels.ncl" in
let leak = channels.giant_squid.leak in
let k_slow = channels.rat_thalamocortical.k_slow in
let na_transient = channels.rat_thalamocortical.na_transient in
let hcn_soma = channels.rat_ca1_pyramidal.hcn_soma in
let hcn_dendrite = channels.rat_ca1_pyramidal.hcn_dendrite in

{

  pyramidal_cell = {

    apical_dendrite = {
      capacitance_farads_per_square_cm = 2.0e-6,
      membrane_channels = [
        { channel = na_transient , siemens_per_square_cm = 0.023 },
        { channel = leak , siemens_per_square_cm = 0.03e-3 },
        { channel = hcn_dendrite , siemens_per_square_cm = 0.08e-3 },
        { channel = k_slow , siemens_per_square_cm = 0.040 }
      ]
    } | nb.Membrane,

    basal_dendrite = {
      capacitance_farads_per_square_cm = 2.0e-6,
      membrane_channels = [
        { channel = leak , siemens_per_square_cm = 0.03e-3 },
        { channel = hcn_dendrite , siemens_per_square_cm = 0.08e-3 }
      ]
    } | nb.Membrane,

    axon_initial_segment = {
      capacitance_farads_per_square_cm = 1.0e-6,
      membrane_channels = [
        { channel = na_transient , siemens_per_square_cm = 120.0e-3 },
        { channel = leak , siemens_per_square_cm = 0.3e-3 },
        { channel = k_slow , siemens_per_square_cm = 36.0e-3 }
      ]
    } | nb.Membrane,

    axon = {
      capacitance_farads_per_square_cm = 1.0e-6,
      membrane_channels = [
        { channel = na_transient , siemens_per_square_cm = 120.0e-3 },
        { channel = leak , siemens_per_square_cm = 0.3e-3 },
        { channel = k_slow , siemens_per_square_cm = 36.0e-3 }
      ]
    } | nb.Membrane,

    soma = {
      capacitance_farads_per_square_cm = 1.0e-6,
      membrane_channels = [
        { channel = k_slow, siemens_per_square_cm = 36.0e-3 },
        { channel = na_transient, siemens_per_square_cm = 120.0e-3 },
        { channel = leak, siemens_per_square_cm = 3.0e-5 }
      ]
    } | nb.Membrane

  }
}
```

#### Aside - Plain records

There are two things to understand before we focus on the details of
a `Membrane` - The use of `let _ in _` and the fact that the top level
record in this file does not have a contract.

We use `let _ in _` to import the configuration in the file `channels.ncl` and
give it the name `channels`. Then we use more `let` bindings to bind subfields of
`channels` to short names. For example, we bind `channels.giant_squid.leak`
to the name `leak`. Later, when we examine the `channels.ncl` configuration file,
we will see how these subfields `giant_squid` and `leak` are defined.

After our name bindings, we have a top-level record with no contract.
It has one top-level field, `pyramidal_cell`, which in turn has the fields
`apical_dendrite`, `basal_dendrite`, `axon_initial_segment`, etc. Only
under these fields do we see our contract, `nb.Membrane`. How do we interpret
these top-level records with no contract?

A top-level record without a contract can have any fields that you like. It
is a free-form way for you to organize your data. This is the main distinction
between plain records and records with a contract. Plain records are
flexible and can take whatever shape is useful for you in organizing your data.
Records with a contract represent concrete entities in the simulation and must
contain exactly the set of fields and sub-fields needed by that entity.

#### Membranes

A `Membrane` represents a unit area of cell membrane, which has an intrinsic
capacitance (per unit area) and any number of active ion conductances (also
per unit area).

The `nb.Membrane` contract has two fields:
 - `capacitance_farads_per_square_cm`: The membrane capacitance.
 - `membrane_channels`: A list of channels and their expression levels in this membrane. Each element is a record with the fields:
   - `channel`: The `Channel` type.
   - `siemens_per_square_cm`: The peak conductance for that channel in a unit area of this type membrane.

## The Channel Contract {#the-channel-constructor}

Channels are the lowest level entity in NeuronBench. They are also fairly
complicated, since they are responsible for all of the Hodgkin-Huxley dynamics
of the simulation. Let's look at the
configuration file `https://neuronbench.com/imalsogreg/docs-demo/channels.ncl`,
which was imported by `https://neuronbench.com/imalsogreg/docs-demo/membranes.ncl`,
to see some `Channel`s.

```
{

  giant_squid = {
    k = {
      ion_selectivity = { k = 1.0, na = 0.0, cl = 0.0, ca = 0.0 },
      activation = {
        gates = 4,
        magnitude = { v_at_half_max_mv = -53.0, slope = 15.0 },
        time_constant = {
          type = 'Gaussian,
          v_at_max_tau_mv = -79.0,
          c_base = 1.1e-3,
          c_amp = 4.7e-3,
          sigma = 50.0
        }
      },
      inactivation = null,
    } | nb.Channel,

    na = {
      ion_selectivity = { k = 0.0, na = 1.0, cl = 0.0, ca = 0.0 },
      activation = {
        gates = 3,
        magnitude = { v_at_half_max_mv = -40.0, slope = 15.0 },
        time_constant = {
          type = 'Gaussian,
          v_at_max_tau_mv = -38.0,
          c_base = 0.04e-3,
          c_amp = 0.46e-3,
          sigma = 30.0
        }
      },
      inactivation = {
        gates = 1,
        magnitude = { v_at_half_max_mv = -62.0, slope = -7.0 },
        time_constant = {
          type = 'Gaussian,
          v_at_max_tau_mv = -67.0,
          c_base = 1.2e-3,
          c_amp = 7.4e-3,
          sigma = 20.0
        }
      }
    } | nb.Channel,

    leak = {
      ion_selectivity = { k = 0.0, na = 0.0, cl = 1.0, ca = 0.0 },
      activation = null,
      inactivation = null,
    } | nb.Channel
  },

  rat_thalamocortical = {

    na_transient = {
      ion_selectivity = { k = 0.0, na = 1.0, cl = 0.0, ca = 0.0 },
      activation = {
        gates = 1,
        magnitude = { v_at_half_max_mv = -30.0, slope = 5.5 },
        time_constant = { type = 'Instantaneous }
      },
      inactivation = {
        gates = 1,
        magnitude = { v_at_half_max_mv = -70.0, slope = -5.8 },
        time_constant = {
          type = 'LinearExp,
          coef = 3.0,
          v_offset_mv = -40.0,
          inner_coef = 0.03
        }
      }
    } | nb.Channel,

    k_slow = {
      ion_selectivity = { k = 1.0, na = 0.0, cl = 0.0, ca = 0.0 },
      activation = {
        gates = 1,
        magnitude = { v_at_half_max_mv = -3.0, slope = 10.0 },
        time_constant = {
          type = 'Gaussian,
          v_at_max_tau_mv = -50.0,
          c_base = 0.005,
          c_amp = 0.047,
          sigma = 0.030,
        }
      },
      inactivation = {
        gates = 1,
        magnitude = { v_at_half_max_mv = -51.0, slope = -12.0 },
        time_constant = {
          type = 'Gaussian,
          v_at_max_tau_mv = -50.0,
          c_base = 0.36,
          c_amp = 0.1,
          sigma = 50.0
        }
      }
    } | nb.Channel
  },

  rat_ca1_pyramidal = {
    hcn_soma = {
      ion_selectivity = { na = 0.35, k = 0.65, cl = 0.0, ca = 0.0 },
      activation = null,
      inactivation = {
        gates = 1,
        magnitude = { v_at_half_max_mv = -82.0, slope = -9.0 },
        time_constant = {
          type = 'Gaussian,
          v_at_max_tau_mv = -75.0,
          c_base = 10.0e-3,
          c_amp = 50.0e-3,
          sigma = 20.0
        }
      }
    } | nb.Channel,

    hcn_dendrite = {
      ion_selectivity = { na = 0.55, k = 0.45, cl = 0.0, ca = 0.0 },
      activation = null,
      inactivation = {
        gates = 1,
        magnitude = { v_at_half_max_mv = -90.0, slope = -8.5 },
        time_constant = {
          type = 'Gaussian,
          v_at_max_tau_mv = -75.0,
          c_base = 10.0e-3,
          c_amp = 40.0e-3,
          sigma = 20.0
        }
      }
    } | nb.Channel
  }
}
```

Like our `membranes.ncl` model, `channels.ncl` is a plain top-level record that
uses custom fields to group various channels together. This grouping is arbitrary,
and it would have been valid to put each channel into its own file, letting each
file be a single record with the `nb.Channel` contract, instead of grouping them
all into one record.

A record with the `nb.Channel` contract contains three fields:
 - `ion_selectivity`: A record specifying the relative permiability of the channel to Na+, K+, Ca++, and Cl-.
 - `activation`, which we will describe below.
 - `inactivation`, identical to activation.

The simplest example to look at is the field `giant_squid.leak`:

```
...
    leak = {
      ion_selectivity = { k = 0.0, na = 0.0, cl = 1.0, ca = 0.0 },
      activation = null,
      inactivation = null,
    } | nb.Channel
...
```

`ion_selectivity` specifies that this channel is only permeable to Cl-.
`activation` and `inactivation` are both `null`, which is a valid value since
not all channels activate or inactivate.

For an example of a channel with an activation mechanism we will look at the
giant squid axon's potassium channel:

```
    k = {
      ion_selectivity = { k = 1.0, na = 0.0, cl = 0.0, ca = 0.0 },
      activation = {
        gates = 4,
        magnitude = { v_at_half_max_mv = -53.0, slope = 15.0 },
        time_constant = {
          type = 'Gaussian,
          v_at_max_tau_mv = -79.0,
          c_base = 1.1e-3,
          c_amp = 4.7e-3,
          sigma = 50.0
        }
      },
      inactivation = null,
    } | nb.Channel,
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
Gaussian parameters under the `time_constant` field. Its `type` field says which
function the time constant follows: `'Gaussian` here. There are other functions
we can use for the time constant beyond Gaussians (the channels above also use
`'Instantaneous` and `'LinearExp`), but we will not cover the details of those
here. The leading `'` marks `'Gaussian` as a tag, one of a fixed set of names,
and not a variable or a piece of text.

<!--
(See [Time Constants](../../language-reference/time-constants/) if you are
interested). -->

The parameters of a Gaussian function are specified with the fields `c_base`, `c_amp`, `v_at_max_tau_mv`, and `sigma`.

#### Inactivating Na+ Channels

The `inactivation` field is specified in exactly the same way as the `activation` field,
and is used for channels like the giant squid axon's Na+ channel.

```
    na = {
      ion_selectivity = { k = 0.0, na = 1.0, cl = 0.0, ca = 0.0 },
      activation = {
        gates = 3,
        magnitude = { v_at_half_max_mv = -40.0, slope = 15.0 },
        time_constant = {
          type = 'Gaussian,
          v_at_max_tau_mv = -38.0,
          c_base = 0.04e-3,
          c_amp = 0.46e-3,
          sigma = 30.0
        }
      },
      inactivation = {
        gates = 1,
        magnitude = { v_at_half_max_mv = -62.0, slope = -7.0 },
        time_constant = {
          type = 'Gaussian,
          v_at_max_tau_mv = -67.0,
          c_base = 1.2e-3,
          c_amp = 7.4e-3,
          sigma = 20.0
        }
      }
    } | nb.Channel,
```

We model a Na+ channel the same way as the K channel: specifying its permeativity
to various ions, its activation staeady state magnitude and timecourse, and its
inactivation steady state and timecourse.

## The Synapse Contract {#the-synapse-constructor}

Returning to our top-level scene, there is one more entity we have to describe,
the Synapse.

Synapses in NeuronBench are modeled conteptually as a pair of mechanisms: a
presynaptic voltage-dependent neurotransmitter pump, and a set of post-synaptic 
ion channels gated by neurotransmitter concentration.

We have a concrete example to study in the synapse file imported by our
top level scene: `https://neuronbench.com/imalsogreg/docs-demo/synapse.ncl`

```
let glutamate_release = {
    transmitter = "Glutamate",
    transmitter_pump_params = {
      target_concentration = {
        min_molar = 1.0e-4,
        max_molar = 1.1e-2,
        slope = 1.0,
        v_at_half_max_mv = 0.0
      },
      time_constant = {
        type = 'Gaussian,
        v_at_max_tau_mv = 0.0,
        c_base = 1.0e-3,
        c_amp = 1.0e-6,
        sigma = 1.0
      }
    }
  } in
let ampa_receptor = {
    membrane_channel = {
      channel = {
        ion_selectivity = { k = 0.5, na = 0.5, cl = 0.0, ca = 0.0 },
        activation = null,
        inactivation = null
      } | nb.Channel,
      siemens_per_square_cm = 1.0e7
    },
    neurotransmitter_sensitivity = {
      transmitter = "Glutamate",
      concentration_at_half_max_molar = 3e-3,
      slope = 10000.0
    }
  } in

{
  pre_neuron = 0,
  pre_segment = 37,
  post_neuron = 1,
  post_segment = 330,
  synapse_membranes = {
    cleft_solution = { k = 5.0e-3, na = 145.0e-3, cl = 110.0e-3, ca = 2.5e-3 },
    presynaptic_pumps = [ glutamate_release ],
    postsynaptic_receptors = [ ampa_receptor ],
    surface_area_square_mm = 1.0e-6,
    transmitter_concentrations = { glutamate_molar = 0.1e-3, gaba_molar = 0.1e-3 }
  }
} | nb.Synapse
```

This configuation file does a lot of setup before it reaches the record with
the `nb.Synapse` contract. In the spirit of our top-down approach in this
tutorial, we will look at that record first, and then drill down to
the details.

The fields `pre_neuron`, `pre_segment`, `post_neuron` and `post_segment`
attach the synapse to a pair of neurons. Biological synapses originate
from an axon and usually terminate on a dendrite or soma, but NeuronBench
does not impose this restriction. `synapse_membranes` specifies the
intrinsic properties of the synapse:

 - `cleft_solution`: The ionic composition of the synaptic cleft.
 - `presynaptic_pumps`: A mechanism that releases neurotransmitter
    into the cleft as a function of presaptic membrane voltage and time.
 - `postsynaptic_receptors`: A list of receptors, which consist of an ion
    channel paired with neurotransmitter gating.
 - `surface_area_square_mm`: A rudimentary way of scaling the synaptic
    strength.
 - `transmitter_concentrations`: The initial concentrations of neurotransmitter
    in the synaptic cleft.


Each element in `presynaptic_pumps` is a record with the following fields:

 - `transmitter`: The neurotransmitter controlled by thihs pump. 
   Either `"Glutamate"` or `"GABA"`.
 - `transmitter_pump_params.target_concentration`: The parameters of a
   sigmoid function, mapping presynaptic membrane voltage to the steady-state
   neurotransmitter concentration.
 - `transmitter_pump_params.time_constant`: The parameters of the time constant
   determining how quickly the neurotransmitter approaches its steady-state value,
   as a function of presynaptic membrane voltage.
 
Each element in `postsynaptic_receptors` is a record with a field `membrane_channel`
specifying the peak current and the `Channel` properties of a postsynaptic channel current,
and a new field, `neurotransmitter_sensitivity`, which specifies a Bolzman function
relating the scaling of the `Channel` by the concentration of the specified
neurotransmitter.
 
## Conclusion

We began with a simple scene configuration, a single import; and we iteratively
loaded that scene, examined its fields, and recursively explored each sub-component.

We learned the basic structure of the following named Entities:

 - `Channel`
 - `Membrane`
 - `Neuron`
 - `Synapse`
 - `Scene`

And along the way, we learned about the flexibility of the syntax and the techniques
for organizing your data in the way that makes the most sense for your project, such
as `let _ in _` constructs and plain top-level records.

This was a lot of information, congratulations of finishing! You now know enough to
construct your own basic networks, and to produce configurations in a way that
allows other users to build on top of your work.

#### What to do next

**Build your own models.** Using the techniques you learned here, build up your own
neural network. You can directly use the existing `Channels` and `Membranes`, try to
tweak them to have different properties, or generate complete new ones from parameters
you find in papers or referencee textbooks.

**Model a phenomenon.** What interests you in neuroscience? Take an interesting
phenomenon from computational neuroscience and implement it as an interactive
model. Can you build a coincidence detector? A winner-takes-all network? A
ring attractor?

**Extend the simulator.** NeuronBench is a very new project, and the simulator
and specification language may lack the specific features you need for building
your models. If you find this to be the case, please share your findings with
the development team, or consider contributing your expertise to the project
by implementing or consulting on the features you need.

**Publicize your work.** Users with paid subscriptions can create permanent
public links to their models. You can use these links to make your model
publically accessible to everyone, even people without a NeuronBench account. If
you are giving a talk about a neuron with special membrane properties, or an
interesting new dynamical network, your audience can interact with your
simulation in real time (without learning the intricacies of the configuration
language or installing any software).
