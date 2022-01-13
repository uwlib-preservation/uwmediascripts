# CD Ripping Workflow
## Workflow for supportings scripts in dBPoweramp/Nimbie based ripping

### Pre-rip
* Create TARGETS.txt file with desired filenames. Names must be in the same order as the CDs in the ripper.
* Run `get_cd_meta.rb` to start background process that will log lengths of CDs for post-rip comparison to verify completeness.
  - Command structure: `get_cd_meta.rb [TARGET-DIRECTORY] [TARGET-DRIVE]`

### Post-rip
* Kill process running `get_cd_meta.rb`
* Verify completeness of rips via `compare_times.rb`
  - Command structure: `compare_times.rb [TARGET-DIRECTORY]`
* Rename WAV/CUE pairs with `rename-waves.rb`
  - Command structure: `rename-waves -t [TARGET-DIRECTORY] -n [TARGETS.txt]`
* Make sure everything is hunky-dory!!