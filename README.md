TheUnbelievableSequencer
=========================

This project demonstrates what I consider to be the simplest form of a sequencer or a beat machine in TheAmazingAudioEngine. 

It uses the AUSampler audio unit and MIDI files to define patterns.

Creating patterns
------------------
The pattern in the example is just a midi file with notes in the C3 to E3 range. All notes are on track 1 and channel 1. The sampler has a different percussive sound associated to each of these notes.

Creating Sampler Presets
------------------------
The sequencer loads .aupreset files created with AULab. The preset in the example contains a single layer with 5 sounds, each associated to notes in the C3 to E3 range. AULab is very easy to use but is not the only way to create aupresets for AUSampler. Basically any DAW that can load and run the AUSampler audio unit can be used to create the presets.

UI
---
The UI is just a collection view with a custom layout. It illustrates how a user interface could associate to the sequencer via NSIndexPath.

NOTES
-------
If you have trouble running the code, you may need to use TAAE latest repository code instead of the Pod. The latest Pod is 1.4.8 and is a bit behind the code needed to run this code.






