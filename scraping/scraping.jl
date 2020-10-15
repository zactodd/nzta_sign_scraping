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


function signs(url=ALL_SIGNS_URL)
    page = HTTP.get(url)
    page = page.body |> String |> parsehtml
    rows = eachmatch(sel"div.\[.col.\].typography > table > tbody", page.root)
    table_data = [eachmatch(sel"td", r) for r in rows]
    for r in table_data
#         code = r[1].children[1].text
#         rule = r[2].children[1].text
#         motsam = r[3].children[1].text
        url = "$(NZTA_URL)$(attrs(r[4].children[1])["href"])"
        println(url)
    end
    return table_data
end


print(signs())
