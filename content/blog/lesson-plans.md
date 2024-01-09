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

