Rating study to collect normative dataset
================
Jörn Alexander Quent
November 12, 2018

Description of this repository
==============================

Project name: schemaVR

Pre-registration: not pre-registered

Publication status (November 12, 2018): not submitted

This repository contains data collected on the expectancy of twenty objects in twenty locations in a virtual kitchen. The participants answered the question "How expected is/are this/these object(s) in that location?". After rating all 400 combinations, participants were asked to rate "How expected is/are this/these object(s) in a kitchen?" to collect whether a particular object is expected to be found in a kitchen in general. Twelve of the objects were selected because they were thought to be kitchen objects (e.g. microwave). The scale ranged from -100 (unexpected) to 100 (expected). Participants moved a slider across this scale by moving a mouse laterally.

This normative data was used to select object/location combinations that span across the whole range from very unexpected to very expected locations, which in turn is important to show that spatial memory is a U-shape function of object/location memory, which is one of the main aims of the project [schemaVR](https://jaquent.github.io/tags/schemavr/).

Guide through this repository
=============================

-   The folder *normativeData* contains RT and Ratings for object/location expectancy and general expectancy. The data is organised in matrices (one row for each object and one column for each location).
-   The folder *stimuli* contains the images and questions used to collect the data.
-   The experiment itself is a MATLAB/Psychtoolbox 3 script (*ratingStudy.m*), which uses my slide scale function (*slideScale.m*).
-   The folder post contains a short analysis of the data. 

List of notebook entries
========================

-   [Analysing normative data set](https://jaquent.github.io/post/analysing-normative-data/)

Disclaimer
==========

Note that this repository unfortunately has not been version controlled from the beginning and that some files for altered to fit into the newly developed open notebook/repository scheme.
