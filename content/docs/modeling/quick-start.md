+++
title = "Quick Start"
description = "One page summary of how to start a new AdiDoks project."
date = 2021-05-01T08:20:00+00:00
updated = 2021-05-01T08:20:00+00:00
draft = false
weight = 20
sort_by = "weight"
template = "docs/page.html"

[extra]
lead = "One page summary of how to start a new AdiDoks project."
toc = true
top = false
+++


## Create an account

<a href="https://neuronbench.com/signup">Click Here</a> or visit <a href="https://neuronbench.com">neuronbench.com</a> to create an account.

You will be prompted to choose an account name. This name will be used in the address for your profile and your models. Choose a name between 3 and 32 characters long containing letters, numbers and `_` (underscores). Then click "Continue with google" to sign up with your Google credentials.

## Create a project

NeuronBench groups related files together into Projects. Click the `New Project` button in the upper right corner to create one. The Project name will also be part of its address, so it has similar restrictions to your account name - letters, numbers and underscores only, no spaces.

Click "Create Project" to generate the project, and you will be taken to the Project page.

## Create a Scene Model

A Project is a collection of Models, and Models have different types, like `Scene`, `Neuron` or `Channel`.

A `Scene` is a Model that contains all the information needed for the simulator to run. Click the "New Scene" button, choose a name (same restrictions as the Account name and Project name).

Do not click "Prepopulate with example", since we are about to create the Model ourselves.

Click "Create", you will be taken to the code editor.

Paste the following code into the editor, and click `Save`:

```
let my_scene = https://neuronbench.com/imalsogreg/docs-demo/scene.ffg
in my_scene
```

### Interpreting this code

This "scene" is an expression in NeuronBench's configuration language. The name `my_scene` is not important,  you could choose any name you like.

This code binds the configuration at the address
`https://neuronbench.com/imalsogreg/docs-demo/scene.ffg` to the variable
`my_scene`, and returns `my_scene`.

In [Core Modeling](../core-modeling/), we will look at the contents of
`https://neuronbench.com/imalsogreg/docs-demo/scene.ffg` to see what makes up a `Scene`. For now, we will just use the `Scene` directly, without looking into its details.


## Preview the Scene

Click the `Preview` button. The simulator will load next to the code editor,
and after several seconds, the scene will load and the simulation will start.

## Congratulations

You have created your first simulation on NeuronBench! In
[Core Modeling](../core-modeling/) you will learn to defive the individual
components of a neural network. Then you can customize the demo scene, or
compose your own complete scenes from scratch.
