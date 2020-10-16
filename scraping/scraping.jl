#=
scraping:
- Julia version: 
- Author: zmt11
- Date: 2020-10-16
=#
using HTTP, Gumbo, Cascadia, Dates


NZTA_URL = "https://www.nzta.govt.nz"
SIGNS_SEARCH_URL = "$(NZTA_URL)/resources/traffic-control-devices-manual/sign-specifications"
SIGN_SEARCH_ALL_QUERY = "?category=&sortby=Default&term="
ALL_SIGNS_URL = "$(SIGNS_SEARCH_URL)/$(SIGN_SEARCH_ALL_QUERY)"


get_page(url) = HTTP.get(url).body |> String |> parsehtml
all_pages(url=SIGNS_SEARCH_URL) = ["$(url)/$(SIGN_SEARCH_ALL_QUERY)&start=$(i)" for i in 0:30:1155]
download_all_signs(outdir) = map(x -> download_signs(x, outdir), all_pages())


function download_signs(url, outdir)
    page = get_page(url)
    rows = eachmatch(sel"div.\[.col.\].typography > table > tbody", page.root)
    table_data = [eachmatch(sel"td", r) for r in rows]
    for r in table_data
        try
            url = "$(NZTA_URL)$(attrs(r[4].children[1])["href"])"
            gif_url = url |> sign_image_nzta_spec
            name = split(gif_url, "/")[end]
            HTTP.download(gif_url, "$(outdir)/$(name)")
        catch e
            println(e)
        end
    end
end


function sign_image_nzta_spec(url)
    page = get_page(url)
    gif = eachmatch(sel"div > table:nth-child(5) > tbody > tr:nth-child(5) > td > a", page.root)[1]
    return "$(NZTA_URL)$(attrs(gif)["href"])"
end


