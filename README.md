# emp_curate_data
Code for preparing the EEG data for #EEGManyPipelines.


In the EEGManyPipelines project, we will provide a set of (almost) unprocessed raw EEG data, and ask participants/analysts to process these data with an analysis pipeline of their choice. The dataset for this project is from an experiment on visual recognition memory. For the purpose of EEGManyPipelines, these data need to be prepared and curated.

## script01_import_bdf
This Matlab script loads the original raw data in Biosemi .bdf format, converts them to EEGLAB format, and then goes through the following steps:
1. remove empty channels;
2. rereference to Cz (because Biosemi is recorded reference-free, which might otherwise confuse analysts);
3. compute HEOG and VEOG
4. downsample to 512 Hz;
5. remove all triggers from events that are irrelevant for the EEGManyPipelines analysis, leaving only triggers indicating image onset;
6. replace subject name with arbitrary, anonymous id.

## script02_recode_triggers
This script loads each subjects' EEG data and the corresponding behavioral log file. From the log file, I construct a table coding for each trial:
- LOG.trial: number of this trial
- LOG.scene_name: beach(1), forest(2), highway(3), building(4)
- LOG.scene_cat: the same information, numerically coded
- LOG.scene_man: is this scene category natural (1) or man-made (2)
- LOG.is_old: is the image on this trial old (1) or new (0)
- LOG.recognition: was the subject's response on this trial a ...
  - hit: old item correctly judged as old (1)
  - miss: old item incorrectly judged as new (2)
  - false alarm: new item incorrectly judged as new (3)
  - correct rejection: new item correctly judged as new (4)
  - rare cases when the response was not recorded (0)
- LOG.subscorrect = is the subject going to remember the image from this trial next time it is repeated?
  - subsequently remembered (1)
  - subsequently forgotten (2)
  - some images are shown a second time (9)
