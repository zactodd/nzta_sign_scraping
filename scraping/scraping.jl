using HTTP, Gumbo, Cascadia, Dates, KissThreading


NZTA_URL = "https://www.nzta.govt.nz"
SIGNS_SEARCH_URL = "$NZTA_URL/resources/traffic-control-devices-manual/sign-specifications"
SIGN_SEARCH_ALL_QUERY = "?category=&sortby=Default&term="
ALL_SIGNS_URL = "$SIGNS_SEARCH_URL/$SIGN_SEARCH_ALL_QUERY"


COOKIE = "visid_incap_508956=i5z5wEhsRWSSJqIT+eKo2/qmg18AAAAAQUIPAAAAAAADMlOx+pty1Z0vLeNwwUWL; _ga=GA1.3.54630425.1602463484; _gcl_au=1.1.2029631771.1602463484; incap_ses_998_508956=F2pQS+AdkwqDCVCP95vZDURAs18AAAAARGytWs3/ZTpVxX4qlBbeZw==; _gid=GA1.3.1213075170.1605582935"
USER_AGENT = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/86.0.4240.75 Safari/537.36"
HEADERS = ["cookie" => COOKIE, "user-agent" => USER_AGENT]


get_page(url, h=HEADERS) = HTTP.request("GET", url, headers=h).body |> String |> parsehtml
all_pages(url=SIGNS_SEARCH_URL) = ["$url$SIGN_SEARCH_ALL_QUERY&start=$(i)" for i in 0:30:1155]
download_all_signs(outdir) = tmap(x -> download_signs(x, outdir), all_pages())
spec_url(row) = "$NZTA_URL$(attrs(row[4].children[1])["href"])"


function download_signs(url, outdir)
    page = get_page(url)
    rows = eachmatch(sel"div.\[.col.\].typography > table > tbody", page.root)
    image_urls = [eachmatch(sel"td", r) |> spec_url |> image_from_spec for r in rows]
    for url in skipmissing(image_urls)
        name = split(url, "/")[end]
        try
            HTTP.download(url, "$outdir/$name")
        catch e
            println("Failure on $url")
            println(e)
        end
    end
end


function image_from_spec(url)
    page = get_page(url)
    matches = eachmatch(sel"div > table:nth-child(5) > tbody > tr:nth-child(5) > td > a", page.root)
    return length(matches) > 0 ? "$NZTA_URL$(attrs(matches[1])["href"])" : missing
end


println("Running with $(Threads.nthreads()) threads.")
download_all_signs("images")
