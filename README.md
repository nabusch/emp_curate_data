# emp_curate_data
Code for preparing the EEG data for #EEGManyPipelines.


In the EEGManyPipelines project, we will provide a set of (almost) unprocessed raw EEG data, and ask participants/analysts to process these data with an analysis pipeline of their choice. The dataset for this project is from an experiment on visual recognition memory. For the purpose of EEGManyPipelines, these data need to be prepared and curated.

## script01_import_bdf
This Matlab script loads the original raw data in Biosemi .bdf format, converts them to EEGLAB format, and then goes through the following steps:
- remove empty channels;
- rereference to Cz (because Biosemi is recorded reference-free, which might otherwise confuse analysts);
- compute HEOG and VEOG
- downsample to 512 Hz;
- remove all triggers from events that are irrelevant for the EEGManyPipelines analysis, leaving only triggers indicating image onset;
- replace subject name with arbitrary, anonymous id.
