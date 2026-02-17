# Cross App Website

This is the official website for the Cross fitness tracking app, built with GitHub Pages.

## Website Structure

- `index.html` - Main landing page
- `style.css` - Stylesheet
- `script.js` - JavaScript for interactivity
- `assets/` - Images, icons, and other assets
  - `icon.svg` - App icon
  - `workout-screen.svg` - App screenshot mockup

## Development

The website is built with:
- HTML5
- CSS3 (with CSS Variables for theming)
- Vanilla JavaScript
- Inter font from Google Fonts
- Font Awesome icons

### Local Development

1. Clone the repository:
   ```bash
   git clone https://github.com/cubecnelson/cross_app.git
   cd cross_app/docs
   ```

2. Open `index.html` in your browser or use a local server:
   ```bash
   python3 -m http.server 8000
   ```

3. Navigate to `http://localhost:8000`

### Design System

Colors:
- Primary: `#FF6B35` (Orange)
- Primary Dark: `#E65100`
- Secondary: `#263238` (Dark Blue)
- Accent: `#00B0FF` (Light Blue)

Typography:
- Font Family: Inter
- Base font size: 16px
- Line height: 1.6

## Deployment

The website is automatically deployed to GitHub Pages via GitHub Actions workflow (`.github/workflows/github-pages.yml`).

Deployment triggers:
- Push to `main` branch with changes in `docs/` folder
- Manual trigger via GitHub Actions UI

The site is deployed to: `https://cubecnelson.github.io/cross_app/`

## Features

1. **Responsive Design** - Works on mobile, tablet, and desktop
2. **Mobile Navigation** - Collapsible menu for small screens
3. **Smooth Scrolling** - For anchor links
4. **Animated Elements** - Feature cards and ACWR chart
5. **Waitlist Forms** - Interactive buttons for iOS/Android waitlists

## License

The website code is part of the Cross App project. See the main repository for licensing information.