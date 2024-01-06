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

We can use interactive neuron models to bridge this gap by allowing students
to selectively remove ion channels or to tweak their properties, and instantly
measure the effect this has on the on an actively spiking neuron.

### Learning goals

 - Turn on and off specific conductances in the NeuronBench action-potential
   tutorial.
 - Map the standard Hodgkin-Huxley conductances to their visual impact on a
   spiking model neuron.
 - Map the standard Hodgkin-Huxley conductances to their impact on the action
   potential waveform.
 - Measure absolute and relative refractory periods.
 - Gain an intuitive understanding of the relationship between the Na+ channel
   kinetics and K+ gating and the action potential waveform.


### Requirements

 - Understanding of the Nearnst and GHK Equations
 - Knowledge of the role of Sodium, Potassium and Leak channels in determining
   the dynamics of an action potential in an idealized neuron segment.
 - Understanding of absolute and relative refractory periods.
 - Access to a Gmail account (for logging in to the NeuronBench app).
 

## For students
 
You have just learned how the neuron generates action potentials through ion
concentration gradients, ion-selective channels, voltage gating, and
inactivation. Now we will use a real neuron simulation to experiment with
these components.

### Part 1. 
