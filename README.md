# NZTA Road Sign Scraping

## Dependencies
The packages are HTTP, Gumbo, Cascadia, Dates, KissThreading and JSON.
They can be installed with the following.

```julia
using Pkg
Pkg.add("HTTP")
Pkg.add("Gumbo")
Pkg.add("Cascadia")
Pkg.add("KissThreading")
Pkg.add("JSON")
```

## Running
The scraping utilises threading and can be run using the following.

```bash
julia --threads 40 scraping.ji
```

### Issues
If there is an 403 the cookie in resources/headers.json may need to be updated.
