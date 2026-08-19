module Api exposing (routes)

import ApiRoute exposing (ApiRoute)
import BackendTask exposing (BackendTask)
import FatalError exposing (FatalError)
import Html exposing (Html)
import Route exposing (Route)
import Site


{-| API routes for the docs site.

Currently just the sitemap. The site head links `/sitemap.xml`
(see `Site.head`), so this route must exist to back that link — otherwise
crawlers (and the `<link rel="sitemap">` reference) hit a 404.

-}
routes :
    BackendTask FatalError (List Route)
    -> (Maybe { indent : Int, newLines : Bool } -> Html Never -> String)
    -> List (ApiRoute ApiRoute.Response)
routes getStaticRoutes _ =
    [ sitemap getStaticRoutes ]


{-| Pre-render `/sitemap.xml` from the full set of build-time routes.

Each route is turned into an absolute `<loc>` under the site's canonical
origin. This is a plain URL-set sitemap (no lastmod/changefreq/priority) —
those fields are optional and we have no reliable per-page timestamps to
report, so we omit them rather than emit misleading values.

-}
sitemap : BackendTask FatalError (List Route) -> ApiRoute ApiRoute.Response
sitemap getStaticRoutes =
    ApiRoute.succeed
        (getStaticRoutes
            |> BackendTask.map
                (\allRoutes ->
                    allRoutes
                        |> List.map (Route.toString >> locEntry)
                        |> String.join "\n"
                        |> sitemapDocument
                )
        )
        |> ApiRoute.literal "sitemap.xml"
        |> ApiRoute.single


{-| Wrap the `<url>` entries in the sitemap envelope.
-}
sitemapDocument : String -> String
sitemapDocument urls =
    String.join "\n"
        [ "<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
        , "<urlset xmlns=\"http://www.sitemaps.org/schemas/sitemap/0.9\">"
        , urls
        , "</urlset>"
        ]


{-| One `<url><loc>…</loc></url>` entry, resolving the route path against the
site's canonical origin.
-}
locEntry : String -> String
locEntry path =
    "  <url><loc>" ++ absoluteUrl path ++ "</loc></url>"


{-| Join the canonical origin and a route path into one absolute URL,
avoiding a doubled slash where the origin ends in `/` and the path begins
with one.
-}
absoluteUrl : String -> String
absoluteUrl path =
    let
        origin : String
        origin =
            if String.endsWith "/" Site.config.canonicalUrl then
                String.dropRight 1 Site.config.canonicalUrl

            else
                Site.config.canonicalUrl
    in
    if String.startsWith "/" path then
        origin ++ path

    else
        origin ++ "/" ++ path
