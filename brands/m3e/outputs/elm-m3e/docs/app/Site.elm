module Site exposing (config)

import BackendTask exposing (BackendTask)
import FatalError exposing (FatalError)
import Head
import MimeType
import Pages.Url
import SiteConfig exposing (SiteConfig)


config : SiteConfig
config =
    { -- The site's own canonical origin (feeds canonical <link> tags + sitemap).
      -- Was the elm-pages template placeholder ("https://elm-pages.com"), which
      -- emitted canonical URLs pointing at a different site. Set to the Netlify
      -- default derived from the repo slug; update to the real deployed origin
      -- if a custom domain is configured.
      canonicalUrl = "https://elm-m3e.netlify.app"
    , head = head
    }


head : BackendTask FatalError (List Head.Tag)
head =
    [ Head.metaName "viewport" (Head.raw "width=device-width,initial-scale=1")
    , Head.sitemapLink "/sitemap.xml"
    , -- Custom brand favicon (the tangram mark in public/favicon.svg). Uses a
      -- root-relative href (`Pages.Url.external "/favicon.svg"`) rather than
      -- `Pages.Url.fromPath`, which would absolutize against `canonicalUrl`
      -- (the prod origin) and make every environment — local dev, Netlify
      -- deploy previews, forks — fetch prod's favicon instead of its own. A
      -- `<link rel="icon">` must be same-origin; only OG/social images (which
      -- these routes emit separately) need the absolute canonical form.
      Head.icon [] (MimeType.OtherImage "svg+xml") (Pages.Url.external "/favicon.svg")
    ]
        |> BackendTask.succeed
