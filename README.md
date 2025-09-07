# Cheater Statistics GitHub repo
This is the repo for my `cheatstats.jl` script and all supplementary files, which was inspired by [this blog](https://codeforces.com/blog/entry/145853) on Codeforces.

## How to run
If you do not have Julia installed, go to [the official install instructions](https://julialang.org/install/).

If you do not have Gnuplot installed and wish to create charts, you can install it from [here](https://sourceforge.net/projects/gnuplot/files/gnuplot/6.0.3/).

Once you have both programs installed

- Run `julia cheatstats.jl`.
- After a few seconds, you will get prompted with `Get fresh list of cheaters? (last retrieval: <date-of-last-retrieval>) (y/n)`.
  - If you input `y`, the list of cheaters from [cheaters.json](https://github.com/macaquedev/cf-cheater-highlighter/blob/main/cheaters.json) will be queried for country and rating via Codeforces API.
  - If you input `n`, the list of countries and ratings will not be refreshed and used for statistical calculation directly. The reason this exists is to test modifications to the code without waiting two lifespans.


> [!WARNING]
> Inputting `y` will overwrite both `ctry.txt`, `rate.dat` and `rate.txt`; and will take its time to query Codeforces a billion times. Proceed with caution.

### Gnuplot
In the repo, there is a file named `rate.gp`. This is the script that can optionally be run if you want to generate the rating graph.

`rate.gp` is set up to output images to a 1920x1080 PNG file using the `pngcairo` terminal. In order to use it appropriately, run `gnuplot rate.gp > out.png`. This will, in turn, output a graph to `out.png`.
