# PsychDetect

## Introduction

PsychDetect is a software framework for conducting **acoustic psychophysical experiments**.

It is less a single ready-to-use program to immediately run experiments, but rather it provides components to build and set up a program to your own needs. (But see also the motivation section for the idea behind PsychDetect.)

The main components are:

* an experiment controller for controlling a go/no go detection experiment
* auditory stimuli
* an audio player that plays those stimuli
* a stimulus generator that provides stimuli to play
* an I/O interface through which the subject can react upon stimuli and get feedback about his performance
* a logbook that keeps track of experimental events like stimulus presentation and subject responses


## Motivation

The main goal of making our experimental software publicity available as an open source project is to allow other researchers to understand, how we conduct our experiments.

Researchers often fail in replicating experimental results from other labs. Partially, this might be related to major or minor differences in the experimental set-up or procedure. Space in method sections of scientific journals is limited. Since research in neuroscience is becoming increasingly complex, the information provided by journals (including supplementary information that is sometimes available via websites), does not suffice to replicate an experiment in every detail. 

Neuroscience make use of computer programs for many year now, e. g. for stimulation or data acquisition. Those programs are becoming more and more sophisticated and can have dramatic impact on results. Despite of their importance, they are barely accessible.

We want to encourage other scientist to share their software, too. Therefore, our software is licensed under the [GNU General Public License](https://en.wikipedia.org/wiki/GNU_General_Public_License) (GPL). GPL is a copyleft license that allows you to use, change, and redistribute the software while the GPL license must be retained. That means that the software must be kept open source.
