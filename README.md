# Agency Attribution Tools and Scripts

https://osf.io/e8e8c/ for more

**Note:** Change mainClass in `build.sbt` or comment it to select at runtime.


## HypnosisApp Results Parser (`Main`)

`sbt "run <json_file_path>"`


## Epoch Fixer (`eeg.EpochFixer`)

Run `sbt "run <subject>"` for a single subject, or `sbt "run <subject_1> <subject_2> ..."` for multiple subjects.

## PsychoPy Group Cleaner (`eeg.PsychoPyGroupCleaner`)

Simply run `sbt run`.

## PsychoPy Subject Cleaner (`eeg.PsychoPySubjectCleaner`)

Run `sbt "run <subject>"`.
