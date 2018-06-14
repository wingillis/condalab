# condalab

Handy MATLAB utility to switch between conda environments **from within MATLAB**

**NEW**: now works with Windows and Miniconda!

## Installation

Grab this repo
```
git clone https://github.com/wingillis/condalab.git
```
Chuck it somewhere on your matlab path:
```matlab
% add the full path for condalab: for me it's:
addpath(genpath('/Users/wgillis/dev/condalab'));
```

## Usage

To view all your conda environments (i.e., the equivalent of `conda env list`)

```matlab
conda.getenv

% You'll see something like this:
asimov     /Users/sg-s/anaconda3/envs/asimov
mctsne     /Users/sg-s/anaconda3/envs/mctsne
*tensorflow     /Users/sg-s/anaconda3/envs/tensorflow
root     /Users/sg-s/anaconda3
```
the `*` indicates the currently active environment

To switch between environments (i.e., `source activate env`)

```matlab
conda.setenv('env_name')

```

It's that simple. Enjoy.
