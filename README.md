# Naqdi — Public Site

Static site served by GitHub Pages for the Naqdi iOS app:
**https://naqdi.app**-style URLs for the marketing home, support / FAQ,
Privacy Policy, and Terms of Use — the URLs referenced from App Store
Connect and from inside the app.

This repo is **public by design** so GitHub Pages serves it on the free
tier and Apple's review team (and anyone opening a link from the App
Store listing) can load the pages without authentication.

The main app source code lives in a separate **private** repo.

## Pages live at

Once Pages is enabled:

| Purpose | URL |
|---|---|
| Marketing (EN) | `https://<user>.github.io/naqdi-site/` |
| Marketing (AR) | `https://<user>.github.io/naqdi-site/index-ar.html` |
| Support (EN)   | `https://<user>.github.io/naqdi-site/support.html` |
| Support (AR)   | `https://<user>.github.io/naqdi-site/support-ar.html` |
| Privacy (EN)   | `https://<user>.github.io/naqdi-site/privacy-policy.html` |
| Privacy (AR)   | `https://<user>.github.io/naqdi-site/privacy-policy-ar.html` |
| Terms (EN)     | `https://<user>.github.io/naqdi-site/terms-of-use.html` |
| Terms (AR)     | `https://<user>.github.io/naqdi-site/terms-of-use-ar.html` |

Paste those URLs into App Store Connect → App Information.

## Enabling Pages (one-time)

1. Push this repo to GitHub (public).
2. Repo → **Settings** → **Pages**.
3. Source: **Deploy from a branch** → Branch: `main` → Folder: `/ (root)`.
4. Save. Wait ~1 minute for the first deploy.
5. Green "Your site is live at ..." banner appears. Click to verify.

## File layout

```
naqdi-site/
├── index.html            EN marketing home
├── index-ar.html         AR marketing home
├── support.html          EN support/FAQ
├── support-ar.html       AR support/FAQ
├── privacy-policy.html   EN privacy policy
├── privacy-policy-ar.html
├── terms-of-use.html     EN terms of use
├── terms-of-use-ar.html
├── style.css             shared stylesheet (RTL-aware)
├── .nojekyll             tells Pages to skip Jekyll processing
└── README.md
```

## Updating the content

Edit the `.html` files directly, commit, push. GitHub Pages picks up the
change within a minute.

The **in-app** legal text (shown when users tap Privacy Policy / Terms of
Use in Settings) is duplicated in the private app repo at
`Naqdi/Models/LegalDocuments.swift`. When you make a legal change, update
both — they must match so the in-app reader and the App Store listing
agree on what the user has agreed to.

## Custom domain (optional, later)

To move to a real domain (e.g. `naqdi.app`):

1. Buy the domain.
2. Settings → Pages → Custom domain → enter the domain, save.
3. Add a `CNAME` DNS record pointing `naqdi.app` →
   `<user>.github.io`.
4. Delete the `<user>.github.io/naqdi-site/` URLs from App Store Connect
   and swap in the custom-domain URLs.

## License

Content here is bundled as part of the Naqdi product. Not licensed for
reuse outside of the Naqdi app.
