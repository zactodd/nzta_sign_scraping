# nzta_sign_scraping

## Dependencies
The packages are HTTP, Gumbo, Cascadia, Dates, and KissThreading.
They can be installed with the following.

```julia
using Pkg
Pkg.add("HTTP")
Pkg.add("Gumbo")
Pkg.add("Cascadia")
Pkg.add("KissThreading")
```

## Running
The scraping utilises threading and can be run using the following.

```bash
julia --threads 40 scraping.ji
```

### Issues

