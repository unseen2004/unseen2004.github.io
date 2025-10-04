# 🚀 Quick Start Guide

## Instant Setup (30 seconds)

1. **Clone the repository:**
   ```bash
   git clone https://github.com/unseen2004/unseen2004.github.io.git
   cd unseen2004.github.io
   ```

2. **Open in browser:**
   ```bash
   # Option 1: Direct
   open index.html
   
   # Option 2: Local server (recommended)
   python3 -m http.server 8080
   # Then visit: http://localhost:8080
   ```

3. **Deploy to GitHub Pages:**
   - Already configured! Just push to `main` branch
   - Enable Pages in repository Settings
   - Your site will be live at: `https://yourusername.github.io/`

## 📝 Quick Customization

### Change Your Name & Info
**File:** `index.html`

```html
<!-- Line 47 -->
<h1 class="hero-name">Your Name Here</h1>

<!-- Line 53-55 -->
<p class="hero-description">
    Your custom description here...
</p>
```

### Add a New Project
**File:** `index.html` (around line 280)

```html
<div class="project-card" data-aos="fade-up" data-aos-delay="400">
    <div class="project-image">
        <img src="assets/img/your-project.png" alt="Your Project">
        <div class="project-overlay">
            <div class="project-links">
                <a href="projects/your-project.html" class="project-link">
                    <i class="fas fa-external-link-alt"></i>
                </a>
                <a href="https://github.com/you/repo" class="project-link">
                    <i class="fab fa-github"></i>
                </a>
            </div>
        </div>
    </div>
    <div class="project-content">
        <h3 class="project-title">Your Project Name</h3>
        <p class="project-description">Brief description...</p>
        <div class="project-tech">
            <span class="tech-tag">Tech 1</span>
            <span class="tech-tag">Tech 2</span>
        </div>
    </div>
</div>
```

### Change Colors
**File:** `css/style.css` (lines 9-19)

```css
:root {
    --primary-color: #64ffda;      /* Your accent color */
    --bg-dark: #0a192f;            /* Main background */
    --bg-light: #112240;           /* Section backgrounds */
    --text-primary: #ccd6f6;       /* Main text color */
    --text-secondary: #8892b0;     /* Secondary text */
}
```

### Update Contact Info
**File:** `index.html` (around line 365)

```html
<a href="mailto:your@email.com" class="contact-method">
    <!-- Email contact card -->
</a>

<a href="https://github.com/yourusername" class="contact-method">
    <!-- GitHub contact card -->
</a>
```

### Modify Typing Animation
**File:** `js/script.js` (around line 100)

```javascript
strings: [
    'Your Title 1',
    'Your Title 2',
    'Your Title 3'
]
```

## 🎨 File Structure

```
portfolio/
├── index.html          # Main page (EDIT THIS)
├── css/
│   └── style.css       # All styles (colors, animations)
├── js/
│   └── script.js       # Interactivity
├── assets/
│   └── img/            # Project images
├── projects/           # Project detail pages
├── README.md           # Full documentation
└── FEATURES.md         # Feature list
```

## 🔧 Common Tasks

### Add a Skill
**File:** `index.html` (around line 175)

```html
<div class="skill-item">
    <i class="fab fa-your-icon"></i>
    <span>Your Skill</span>
</div>
```

### Change About Section
**File:** `index.html` (lines 75-138)

Edit the paragraphs and info cards.

### Adjust Animation Speed
**File:** `css/style.css`

```css
--transition-speed: 0.3s;  /* Change this value */
```

Or in `js/script.js`:
```javascript
AOS.init({
    duration: 1000,  // Change animation duration
});
```

## 📱 Testing Responsive Design

```bash
# Desktop view (default)
Open in browser normally

# Mobile view
1. Open browser DevTools (F12)
2. Click "Toggle Device Toolbar" (Ctrl+Shift+M)
3. Select device or custom size
```

## 🐛 Troubleshooting

### Animations not showing?
- Check browser console (F12)
- Ensure JavaScript is enabled
- Fallback CSS animations will still work

### Images not loading?
- Check file paths in `assets/img/`
- Verify image names match HTML references
- Use lowercase file names

### Fonts look different?
- Google Fonts might be blocked
- Fallback to system fonts automatically

## 🚀 Deployment Checklist

- [ ] Update all personal information
- [ ] Replace project images
- [ ] Test all links
- [ ] Check mobile responsiveness
- [ ] Optimize images (compress)
- [ ] Push to GitHub
- [ ] Enable GitHub Pages
- [ ] Test live site

## 💡 Pro Tips

1. **Images:** Use WebP format for better compression
2. **Performance:** Keep images under 500KB
3. **SEO:** Update meta tags in `<head>`
4. **Analytics:** Add Google Analytics code if needed
5. **Domain:** Add custom domain in repository settings

## 📚 Resources

- **Full Documentation:** See `README.md`
- **Features List:** See `FEATURES.md`
- **Icon Library:** [Font Awesome](https://fontawesome.com/icons)
- **Color Picker:** [Coolors.co](https://coolors.co/)
- **Image Optimization:** [TinyPNG](https://tinypng.com/)

## 🆘 Need Help?

1. Check `README.md` for detailed guides
2. Review `FEATURES.md` for what's included
3. Open an issue on GitHub
4. Contact: 279783@student.pwr.edu.pl

---

**Happy coding! 🎉**

Made with 💚 by [Unseen](https://github.com/unseen2004)
