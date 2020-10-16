#=
scraping:
- Julia version: 
- Author: zmt11
- Date: 2020-10-16
=#
using HTTP, Gumbo, Cascadia


NZTA_URL = "https://www.nzta.govt.nz"
SIGNS_SEARCH_URL = "$(NZTA_URL)/resources/traffic-control-devices-manual/sign-specifications"
SIGN_SEARCH_ALL_QUERY = "?category=&sortby=Default&term="
ALL_SIGNS_URL = "$(SIGNS_SEARCH_URL)/$(SIGN_SEARCH_ALL_QUERY)"


get_page(url) = HTTP.get(url).body |> String |> parsehtml

function signs(url=ALL_SIGNS_URL)
    page = get_page(url)
    rows = eachmatch(sel"div.\[.col.\].typography > table > tbody", page.root)
    table_data = [eachmatch(sel"td", r) for r in rows]
    for r in table_data
        code = r[1].children[1].text
        rule = r[2].children[1].text
        url = "$(NZTA_URL)$(attrs(r[4].children[1])["href"])"
        gif_url = url |> sign_image_nzta_spec
        HTTP.download(gif_url, "$(code)_$(rule)_image.gif")
    end
    return
end


function sign_image_nzta_spec(url)
    page = get_page(url)
    gif = eachmatch(sel"div > table:nth-child(5) > tbody > tr:nth-child(5) > td > a", page.root)[1]
    return "$(NZTA_URL)$(attrs(gif)["href"])"
end


signs()