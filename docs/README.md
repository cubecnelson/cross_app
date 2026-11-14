# OnTheRack marketing site

This is the GitHub Pages landing page for OnTheRack, built from the `docs/` folder of the `cubecnelson/cross_app` repository.

Live site: https://cubecnelson.github.io/cross_app/

## Website structure

- `index.html` — Landing page (OnTheRack product copy)
- `style.css` — Existing stylesheet
- `script.js` — Mobile navigation and smooth scrolling
- `assets/` — Existing artwork (app icons in this folder were not changed in the conversion)

## Local development

```bash
git clone https://github.com/cubecnelson/cross_app.git
cd cross_app/docs
python3 -m http.server 8000
```

Open http://localhost:8000

## Deployment

The site is deployed by `.github/workflows/github-pages.yml` when `docs/` or the workflow file changes on `main`, or when the workflow is run manually.

The GitHub repository name remains `cross_app`, so the Pages URL is unchanged.
