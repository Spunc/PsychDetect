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

## Getting started

### Prerequisites

#### Software

PsychDetect needs at least Matlab Version 2015b. (It has not been tested for newer versions yet.)  
In addition, you need [Psychtoolbox-3](http://psychtoolbox.org/) to be installed.

#### Hardware

You need a sound device that fulfils your specific needs. We run the software on a Windows machine with a high-end ASIO sound device with 192 kHz sampling rate for ultrasonic stimulation. We also tested the software with a common “sound on board” device at different sampling rates. Both set-ups run without latency issues.

### Install

1. Clone the repository or download the zip-archive and extract it at your preferred location.
2. Add the root directory to your Matlab path.
3. Change to *test/* and type `runtests` and verify that all tests pass.

### Run a demonstration session 

Type `runExampleGapSession` to run a demonstration of a psychoacoustic gap detection experiment.

The demonstration program will open two windows. The left window lets you control the experiment. It contains buttons for starting, stopping, and saving the experimental session. The right window is a demo implementation of the subject's input device. The subject uses it to initiate trials and to respond upon detected stimuli.

1. Focus on the left window and click on “Start”. This will make the audio player playing white noise.
2. Focus on the right window and hold downs the space key to initiate a trial.
3. After a random delay, the audio player will insert a small gap of silence into the noise.
4. Release the space key as soon as you identify a gap.
5. Again, hold down the space key to initiate the next trial. Steps 3 to 5 will repeat until all trials have been played.
6. After all trials have been played, the audio player will stop playing noise. You can save the session's data by clicking on “Save”.

Throughout the hole session, you can survey all experimental events at Matlab's console.

## Motivation

The main goal of making our experimental software publicity available as an open source project is to allow other researchers to understand, how we conduct our experiments.

Researchers often fail in replicating experimental results from other labs. Partially, this might be related to major or minor differences in the experimental set-up or procedure. Space in method sections of scientific journals is limited. Since research in neuroscience is becoming increasingly complex, the information provided by journals (including supplementary information that is sometimes available via websites), does not suffice to replicate an experiment in every detail. 

Neuroscience makes use of computer programs for many year now, e. g. for stimulation or data acquisition. Those programs are becoming more and more sophisticated and can have dramatic impact on results. Despite of their importance, they are barely accessible.

We want to encourage other scientist to share their software, too. Therefore, our software is licensed under the [GNU General Public License](https://en.wikipedia.org/wiki/GNU_General_Public_License) (GPL). GPL is a copyleft license that allows you to use, change, and redistribute the software while the GPL license must be retained. That means that the software must be kept open source.
