+++
title = "Hello World"
description = "Introducing NeuronBench, a web-first neuron simulator."
date = 2021-05-01T09:19:42+00:00
updated = 2021-05-01T09:19:42+00:00
draft = false
template = "blog/page.html"

[taxonomies]
authors = ["Greg"]

+++

If you're a neuroscientist, you probably remember the first time you saw a neuron
in culture, heard your first amplified extracellural action potential, or
built and ran your first leakey integrate-and-fire model. These are transformative
personal experiences!

But you may not remember the first picture of a neuron you saw in a textbook, or
the first time you read about synapses and LTP. Why not?

The difference is in the tangible, real-time connection you have to the real thing
in front of you. You can have a conversation with it - illuminate it with a different
wavelength of light, add extracellular potassium to drive a barage of spikes, or tweak
your model parameters, and the real object in front of you responds. The brain isn't
just an interesting abstraction from a textbook anymore.

**NeuronBench aims to give everyone this interactive experience with neural systems.**

In other words, NeuronBench exists to give people that sense of having a dialogue
with a real, working neural system. More people should have easier access to
a toy neuron in a dish. A neuron in NeuronBench can be rotated and zoomed. It
can be stimulated with current pulses (and in the future, stimuli like sounds
and images). And it responds in real time, indicating changes in membrane voltage
by changing color, all in real time.

Extending this idea just a little: many of our research findings could have
a deeper impact if they provided a toy version that the audience could play
with. Maybe you just discovered a new form of dendritic computation. While Our
usual figures and slides convey the technical details well enough, it would be
far more memorable if your audience members could reach your model through a
link, play with it, feel that they are rediscovering your phenomenon for
themselves.

In your best talks, the audience is broiling with ideas to extend or break
your model. And the final thing to say about the thesis for NeuronBench in this
blog post, relates to this creative energy, and the fact that specialized tools
could refine that energy into concrete scientific discoveries.

How could someone interact with your newly discovered dendritic computation?
Max, the student who just learned about refractory periods, wants to validate
your findings with stronger or weaker
<math display="inline"><msup><mi>Na</mi><mi>+</mi></msup></math>
inactivation. Stephanie, who
specializes in alpha rhythms, adds an oscillatory current to the soma and finds
that your phenomenon works best at certain phases. Garrett, who studies species
differences, has already lenthened your apical dendrites and enriched their
<math display="inline"><msub><mi>I</mi><mi>h</mi></msub></math>
currents; he has a hunch that your effect is stonger more human-like neurons.

NeuronBench aims at this goal of instantaneous interaction through a "web-first"
approach. This means focusing on remixing, interaction, distribution and
visualization, over other desirable features for a neuron simulator. NeuronBench
doesn't aim to be the best platform for neuroscience research, or to be the
fastest cluster workhorse. The simulator and the language are optimized for
demonstrating neural networks, letting users access your networks without
installing software, and allowing people to build on top of each other's work.

Exactly _how_ we focus on those aspects will be the topic of future blog posts.

So there you have it - a brief introduction to what we are trying to build here.
We hope you share our love of neurons and spread the joy by building biologically
realistic neuron simulations with us! Check out a [sample neuron pair](https://nbnch.io/s/xnzs-qhdf), [sign up](https://neuronbench.com/signup)
for an account, or read some [docs](https://docs.neuronbench.com) to get started!
