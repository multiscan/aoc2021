# Advent of Code 2021 in Ruby

The little scripts for solving the Advent of Code 2021 puzzles.

### Setup
Create a `.env` file that contains something like the following:

```
SESSION="1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef"
```

where the string is the one found in your session cookie for the AOC website.

### Run
There is one ruby script per day.

To execute all the scripts, just run `./go.sh`. For a single script, pass the
day number: `./go.sh DAYNUMBER`

Quitz data will be automaticaly downloaded from the AOC website.

#### Rust version

I started this project with the idea of learning rust language. Due to lack of
time, I ended up doing everything in ruby as last year. Still, some of the
solutions will be translated into this language. In that case, add `--rust` to
the wrapper script: `./go.sh --rust DAYNUMBER`
