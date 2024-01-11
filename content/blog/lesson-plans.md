+++
title = "Teaching the Action Potential with NeuronBench"
description = "How to add interactive neuron models to the intro neuroscience curriculum."
date = 2023-12-30T19:10:00+00:00
updated = 2023-12-31T19:10:00+00:00
draft = false
template = "blog/page.html"

[taxonomies]
authors = ["Greg"]

+++

## For instructors

This lesson plan uses interactive neuron modeling to enrich and enliven the
standard presentation of the Hodgkin-Hukley action potential.

Instruction on the generation of the action potential oftnen represents the
first time that nebulous, abstract neuroscience concepts begin to feel tangible
and grounded, as spikes become understanbable in terms of salt concentrations,
voltage gradients, and gated ion channels. But the usual presentation has room
for improvement; it can feel like a lot of received wisdom, a student may want
to know what the practical implications would be if a given ion channel had
different conductance, kinitecs or voltage deependence, and the entire treatment
can more quantitative than intuitive even after gaining confidence in the
equasions.

We will use interactive neuron models to bridge this gap by allowing students
to selectively remove ion channels or to tweak their properties, and instantly
measure the effect this has on an actively spiking neuron.

### Learning goals

 - Gain familiarity with the NeuronBench web app and configuration format.
 - Observe the impact of leak, K+, and Na+ currents on a spiking neuron by
   selectively removing them.
 - Achieve greater intuition about the voltage gating and kinetics of ion
   channels, by experimentally modifying these properties and measuring their
   effects on the shape of the action potential.

### Requirements

 - Understanding of the Nearnst and GHK Equations.
 - Classroom knowledge of the role of Na+, K+ and Leak channels in determining
   the dynamics of an action potential in an idealized neuron segment.
 - Access to a Gmail account (for logging in to the NeuronBench app).


## For students
 
You have just learned how the neuron generates action potentials through ion
concentration gradients, ion-selective channels, voltage gating, and
inactivation. Now we will use a real neuron simulation on
[NeuronBench](https://neuronbench.com/signup) to experiment with these
concepts and get deeper intuition about each channel and how its
properties impact the ability of a neuron to generate action potentials.

### Section 1. A Simulated Neuron

Follow these steps to create your first neuron:

 1. Create an account on [NeuronBench](https://neuronbench.com/signup) using
    your gmail login.
 2. Click "New project", and choose any name you like. You will be taken to
    your project's page.
 3. Click "New Scene", and again choose any name you like. `scene` is a
    covnentional name for the main file of your project, you you might name
    it that. The "Prepopulate with example" checkbox can remain blank.
 4. You will be taken to the neuron configuration editor. Paste the following
    code in and click "Save":

```
# Import ion channels and helper function.
let channels = https://neuronbench.com/imalsogreg/docs-demo/channels.ffg
let buildScene = https://neuronbench.com/imalsogreg/lesson-0000-understanding-the-action-potential/buildScene

# Define a cell membrane with the three Hodgkin-Huxley conductances:
#  - Inactivating sodium conductance
#  - Voltage-gated potassium conductance
#  - Leak conductance
let membrane = Membrane {
  capacitance_farads_per_square_cm: 2.0e-6,
  membrane_channels: [
    { channel: channels.giant_squid.na , siemens_per_square_cm: 120.0e-3 },
    { channel: channels.giant_squid.leak , siemens_per_square_cm: 0.3e-3 },
    { channel: channels.giant_squid.k , siemens_per_square_cm: 36.0e-3 }
  ]
}

in

# Call the helper function to apply our custom membrane to an example neuron.
buildScene membrane
```

  5. Click preview.
  6. Congratulations, you should see your first neuron!
  
The small sphere is a stimulator injecting current into the neuron once
every few seconds. The segments of the neuron flash green to indicate
their increased membrane voltage and return to grey at resting membrane
potential.

#### Exercise 1: Channel knockouts

The code snippet exposes the three channels used to define the one type
of cell membrane used throughout this neuron. Remove one channel at
a time by deleting or commenting out the configuration line for that
channel. For example, to remove the leak channel, your `membrane_channels`
would look like this:

```
  membrane_channels: [
    { channel: channels.giant_squid.na , siemens_per_square_cm: 120.0e-3 },
    # { channel: channels.giant_squid.leak , siemens_per_square_cm: 0.3e-3 },
    { channel: channels.giant_squid.k , siemens_per_square_cm: 36.0e-3 }
  ]
```

The `#` character is used to comment out a line in NeuronBench.

Hitting `Save` will reload the simulation and restart it.

**For each channel, describe the impact of removing that channel from the
membrane.**

#### Exercise 2: The effect of leak currents

The peak conductance of each channel is specified in the `siemens_per_square_cm`
field. `siemens` is the inverse of `Ohms` (the physisical unit of electrical
resistance), so a higher `siemens` value means higher peak current.

**Leaving other channels the same, what is the highest leak current that
continues to allow the whole neuron to spike?**

**Describe the spatial extent of the action potential, at leak currents just
below the threshold where spikes are no longer occurring.**

#### Exercise 3: Drawing the action potential waveform

We previously focused on the neuron's color to assess the spatial extent
of an action potential. Now we will use a virtual oscilloscope to focus
on the voltage dynamics of a single segment.

First, reset the neuron's membrane channels to their original values and
hit "Save".

Now in the `NeuronBench` menu within the Preview, click "Oscilloscope",
then click the `1` button, and then immediately click somewhere on
the neuron. You should see a yellow trace begin to form on the oscilloscope
viewport. If not, try zooming in on the neuron, click `1`, and click the
neuron again.

**Draw the graph of a single action potential. Label the minimum and maximum
membrane potential reached by that segment. Indicate the width at half max (the
time difference between when the neuron has gotten half way to its peak voltage
and when it has returned half way to its baseline voltage).**

### Section 2: Channel properties

Now we will recap what you learned about the specific properties of these ion
channels by experimenting with their low-level properties.

Specifically, we will take a close look at the voltage gating of the activation
and inactivation components of the Na+ channel, as well as the time constant of
the delayed rectifier K+ channel.

Start by copying this configuration file in to your open configuration file:

```
# Define ion channels.
let channels = {
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

}
let buildScene = https://neuronbench.com/imalsogreg/lesson-0000-understanding-the-action-potential/buildScene

# Define a cell membrane with the three Hodgkin-Huxley conductances:
#  - Inactivating sodium conductance
#  - Voltage-gated potassium conductance
#  - Leak conductance
let membrane = Membrane {
  capacitance_farads_per_square_cm: 2.0e-6,
  membrane_channels: [
    { channel: channels.na , siemens_per_square_cm: 120.0e-3 },
    { channel: channels.leak , siemens_per_square_cm: 0.3e-3 },
    { channel: channels.k , siemens_per_square_cm: 36.0e-3 }
  ]
}

in

# Call the helper function to apply our custom membrane to an example neuron.
buildScene membrane
```

This configuration differs from the one we used earlier. It defines its
own ion channels, rather than importing standard ones. This way we can
play with the ion channel properties and observe the results.

The last channel, `leak`, is the easiest to understand: is is defined as
as channel that is selectively permeable to chloride ions and has no activation
or inactivation dynamics.

Depending on the level of detail of your course, the specification of the
channels `k` and `na` might be more complicated, or at least different, from
what you expected. Let's zoom in on `k`:

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

For a detailed description of every field, refer to the
[Channel](https://docs.neuronbench.com/docs/modeling/core-modeling/#the-channel-constructor)
documentation. But we can make some simplifying assumptions without sacrificing
much accuracy:

 - `magnitude.v_at_half_max_mv`: this is roughly the voltage gating level of this component
    of the channel.
 - `time_constant.c_base` alone is the time-constant if you set `time_constant.c_amp` to 0.
    Otherwise the time constant is always somewhere between `c_base` and `c_base + c_amp`.
 
 Using this simplification, we can see our K+ channel activates at `-53 mV` and the time constant
 is between 1e-3 and 5e-3.



#### Exercise 1: Na+ Activation

Na+ channels in our configuration activate at `-40 mv`. Let us experiment with this voltage
gating to determine how it impacts the sensitivity of the neuron to current pulses.

First we will raise the activation from `-40 mV` to some higher value.

**Will raising the activation voltage of the Na+ channel make the neuron more likely or
less likely to spikee?**

**Find the highest voltage at which the neuron fires an action potential in
response to the first current pulse (to an accuracy order of 1 or 2 mV). Draw
the action potential waveform you observe with this activation voltage. Draw the
voltage waveform again after raising the activation voltage another 3 mV.**

Now test the opposite direction - change the activation voltage to `-60 mV`.

**Draw the resulting membrane potential trace. What range of membrane voltages
are observed? Should this activity be considered an action potential? Why or why
not?**

#### Exercise 2: Spike squeezing and stretching

The width of the action potential is determined by how quickly the membrane potential
returns to baseline after reaching its peak, which it turn is determined by:
 - Activation of the K+ rectifier channels
 - Inactivatioon of the Na+ channels

Set the Na+ channel inactivation timeconstant `c_base` and `c_amp` to `0.6e-3`
and `4.0e-3` respectively, about half their normal value. Smaller time constants
translate to faster changes in the channel gating.

**How does the action potential shape with reduced inactivation time_constant
parameters compare to the original action potential shape, in terms of width and
peak amplitude?**

**What happens to the action potential shape if we divide `c_base` and `c_amp` by 2 once again,
to `0.3e-3 and 2e-3`?**

**Bonus question: Changing the inactivation time constant `c_base` and `c_amp` to `0.3e-3`
and `2.0e-3` had a deleterious effect on the action potential shape. In the previous question
you hypothesized a mechanism for this. Based on that hypothesis, find some _other_ parameter
of either the Na+ channel or another channel you can change, to restore action potential
propagation through the neuron.**
