## Overview

1. Run the Bash Script `text2speech.sh` which will allow you to choose a **.txt** file to convert and output a **.wav**


## Setup

1. This only works on linux or on WSL2 for windows (Linux for Windows)
2. Create a Conda environment using the Mamba package (much faster) and the yaml file I made.  Depending on your GPU and machine there can be compatiblity issues with the pytorch version and the cudatoolkit, and NVIDIA drivers.  This should work for most newer gaming laptops. 

`mamba env create -n tts` <br>
`mamba env update -n tts -f txt2wav_env.yaml`


## Pronounciation Updates

There are 3 files which should be constantly updated as you come across words with strange pronounciations, new abbreviations which the model will not be aware of, or rare combinations of vowels which need tweaking.  This files use the 'sed' cli format which is a form of REGEX commands.

`fonetix.sed` <br>
`abbreviations.sed` <br>
`letters.sed` <br>

Be aware of the difference between 

`s/ear/eeerr/g` - For example this would change the word *linear* to *lineerrr* <br>
`s/\<ear\>/eeerr/g` - This format would only change the word *ear* itself


