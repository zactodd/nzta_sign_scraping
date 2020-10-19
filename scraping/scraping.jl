using HTTP, Gumbo, Cascadia, Dates

NZTA_URL = "https://www.nzta.govt.nz"
SIGNS_SEARCH_URL = "$NZTA_URL/resources/traffic-control-devices-manual/sign-specifications"
SIGN_SEARCH_ALL_QUERY = "?category=&sortby=Default&term="
ALL_SIGNS_URL = "$SIGNS_SEARCH_URL/$SIGN_SEARCH_ALL_QUERY"


get_page(url) = HTTP.get(url).body |> String |> parsehtml
all_pages(url=SIGNS_SEARCH_URL) = ["$url/$SIGN_SEARCH_ALL_QUERY&start=$(i)" for i in 0:30:1155]
download_all_signs(outdir) = map(x -> download_signs(x, outdir), all_pages())
spec_url(row) = "$NZTA_URL$(attrs(row[4].children[1])["href"])"


function download_signs(url, outdir)
    page = get_page(url)
    rows = eachmatch(sel"div.\[.col.\].typography > table > tbody", page.root)
    image_urls = [eachmatch(sel"td", r) |> spec_url |> image_from_spec for r in rows]
    for url in skipmissing(image_urls)
        name = replace(split(url, "/")[end], ".gif" => ".png")
        HTTP.download(url, "$outdir/$name")
    end
end


function image_from_spec(url)
    page = get_page(url)
    matches = eachmatch(sel"div > table:nth-child(5) > tbody > tr:nth-child(5) > td > a", page.root)
    if length(matches) == 0
        return missing
    else
        return "$NZTA_URL$(attrs(matches[1])["href"])"
    end
end
