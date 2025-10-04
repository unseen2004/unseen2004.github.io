# 🚀 Modern Portfolio Website

A stunning, modern portfolio website built with pure HTML, CSS, and JavaScript. Features smooth animations, particle effects, and a fully responsive design.

![Portfolio Preview](https://via.placeholder.com/1200x600/0a192f/64ffda?text=Portfolio+Website)

## ✨ Features

- **🎨 Modern Design**: Clean, professional aesthetic with a dark theme
- **✨ Smooth Animations**: Scroll-based animations using AOS library
- **🌟 Particle Background**: Interactive particle effect in hero section
- **⚡ Fast Loading**: Optimized for performance despite rich animations
- **📱 Fully Responsive**: Works perfectly on all devices
- **🎯 Interactive Elements**: Custom cursor, hover effects, and transitions
- **♿ Accessible**: Semantic HTML and proper ARIA labels
- **🔍 SEO Optimized**: Proper meta tags and structure

## 🛠️ Technologies Used

- **HTML5**: Semantic markup
- **CSS3**: Modern styling with CSS Grid, Flexbox, and custom properties
- **JavaScript**: Vanilla JS for interactivity
- **Particles.js**: For particle background effect
- **AOS**: Animate On Scroll library
- **Typed.js**: For typing animation effect
- **Font Awesome**: For icons

## 📁 File Structure

```
portfolio/
├── index.html          # Main HTML file
├── css/
│   └── style.css       # Main stylesheet with all animations
├── js/
│   └── script.js       # JavaScript for interactivity
├── assets/
│   └── img/            # Project images and screenshots
├── projects/           # Individual project detail pages
│   ├── endlessRunner.html
│   ├── simplePaint.html
│   └── glucoApp.html
└── README.md           # This file
```

## 🚀 Getting Started

### Prerequisites

- A web browser (Chrome, Firefox, Safari, Edge)
- A text editor (VS Code, Sublime Text, etc.)
- Basic knowledge of HTML, CSS, and JavaScript

### Installation

1. **Clone or download this repository**
   ```bash
   git clone https://github.com/unseen2004/unseen2004.github.io.git
   cd unseen2004.github.io
   ```

2. **Open `index.html` in your browser**
   - Simply double-click the file, or
   - Use a local server (recommended): `python -m http.server 8000`

3. **Start customizing!**

## 📝 Customization Guide

### Changing Personal Information

1. **Edit Header/Hero Section** (index.html, lines 44-63):
   ```html
   <p class="hero-greeting">Hi, my name is</p>
   <h1 class="hero-name">Your Name</h1>
   ```

2. **Update About Section** (index.html, lines 72-135):
   - Modify the bio text
   - Update personal information (location, education, etc.)

3. **Update Contact Information** (index.html, lines 350-400):
   - Change email address
   - Update GitHub username
   - Add/modify social links

### Adding a New Project

#### Method 1: Add to Projects Grid

Add a new project card in the projects section (index.html, lines 269-330):

```html
<!-- New Project Card -->
<div class="project-card" data-aos="fade-up" data-aos-delay="400">
    <div class="project-image">
        <img src="assets/img/your-project.png" alt="Your Project">
        <div class="project-overlay">
            <div class="project-links">
                <a href="projects/your-project.html" class="project-link" title="View Details">
                    <i class="fas fa-external-link-alt"></i>
                </a>
                <a href="https://github.com/yourusername/your-repo" class="project-link" title="View Code">
                    <i class="fab fa-github"></i>
                </a>
            </div>
        </div>
    </div>
    <div class="project-content">
        <h3 class="project-title">Your Project Title</h3>
        <p class="project-description">
            A brief description of your project and what it does.
        </p>
        <div class="project-tech">
            <span class="tech-tag">Technology 1</span>
            <span class="tech-tag">Technology 2</span>
            <span class="tech-tag">Technology 3</span>
        </div>
    </div>
</div>
```

#### Method 2: Create a Project Detail Page

1. Create a new HTML file in the `projects/` directory:
   ```bash
   cp projects/endlessRunner.html projects/your-project.html
   ```

2. Customize the content:
   - Update the title
   - Add project description
   - List technologies used
   - Add screenshots/images
   - Include GitHub links

### Modifying Colors and Theme

All colors are defined as CSS variables in `css/style.css` (lines 9-19):

```css
:root {
    --primary-color: #64ffda;      /* Accent color */
    --bg-dark: #0a192f;            /* Background */
    --bg-light: #112240;           /* Lighter sections */
    --text-primary: #ccd6f6;       /* Main text */
    --text-secondary: #8892b0;     /* Secondary text */
}
```

Change these values to customize the entire color scheme!

### Adding New Skills

In the Skills section (index.html, lines 150-250):

```html
<div class="skill-item">
    <i class="fab fa-your-icon"></i>
    <span>Your Skill</span>
</div>
```

Find icons at [Font Awesome](https://fontawesome.com/icons).

### Customizing Animations

#### AOS (Animate On Scroll) Options

Available in `js/script.js` (lines 8-13):

```javascript
AOS.init({
    duration: 1000,     // Animation duration
    easing: 'ease-out', // Easing function
    once: true,         // Animate only once
    offset: 100         // Offset from viewport
});
```

#### Typing Animation

Modify in `js/script.js` (lines 92-103):

```javascript
const typed = new Typed('.typing-text', {
    strings: [
        'Add Your',
        'Custom Titles',
        'Here'
    ],
    typeSpeed: 80,
    backSpeed: 60,
    backDelay: 1500,
    loop: true
});
```

#### Particle Configuration

Customize particles in `js/script.js` (lines 17-88):

```javascript
particlesJS('particles-js', {
    particles: {
        number: { value: 80 },  // Number of particles
        color: { value: '#64ffda' }, // Particle color
        // ... more options
    }
});
```

## 🎨 Design Philosophy

This portfolio follows modern web design principles:

1. **Minimalism**: Clean, uncluttered interface
2. **Consistency**: Uniform spacing, colors, and typography
3. **Hierarchy**: Clear visual hierarchy guiding user attention
4. **Responsiveness**: Seamless experience across all devices
5. **Performance**: Fast loading despite rich animations
6. **Accessibility**: Usable by everyone, including screen readers

## 📱 Responsive Breakpoints

- **Desktop**: 1200px and above
- **Tablet**: 768px to 1199px
- **Mobile**: Below 768px
- **Small Mobile**: Below 480px

## ⚡ Performance Tips

1. **Optimize Images**:
   - Use WebP format when possible
   - Compress images (use tools like TinyPNG)
   - Lazy load images below the fold

2. **Minimize HTTP Requests**:
   - Combine CSS/JS files in production
   - Use CDN for libraries

3. **Enable Caching**:
   - Set proper cache headers
   - Use service workers for offline functionality

## 🐛 Troubleshooting

### Particles not showing?
- Check browser console for errors
- Ensure particles.js CDN is loaded
- Verify `#particles-js` element exists

### Animations not working?
- Make sure AOS library is loaded
- Check that elements have `data-aos` attributes
- Verify JavaScript is enabled

### Images not loading?
- Check file paths are correct
- Ensure images exist in `assets/img/`
- Verify image file names match HTML references

## 🌐 Deployment to GitHub Pages

1. **Enable GitHub Pages**:
   - Go to repository Settings
   - Navigate to Pages section
   - Select main branch as source
   - Save

2. **Your site will be live at**:
   `https://yourusername.github.io/repository-name/`

3. **Custom Domain** (optional):
   - Add CNAME file with your domain
   - Configure DNS settings with your provider

## 📚 Resources

- [HTML5 Documentation](https://developer.mozilla.org/en-US/docs/Web/HTML)
- [CSS3 Documentation](https://developer.mozilla.org/en-US/docs/Web/CSS)
- [JavaScript Documentation](https://developer.mozilla.org/en-US/docs/Web/JavaScript)
- [AOS Library](https://michalsnik.github.io/aos/)
- [Particles.js](https://vincentgarreau.com/particles.js/)
- [Typed.js](https://mattboldt.com/demos/typed-js/)
- [Font Awesome Icons](https://fontawesome.com/)

## 🤝 Contributing

Contributions are welcome! If you have suggestions or find bugs:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is open source and available under the [MIT License](LICENSE).

## 👤 Author

**Unseen**

- GitHub: [@unseen2004](https://github.com/unseen2004)
- Email: 279783@student.pwr.edu.pl
- LinkedIn: [Maksymilian Kułakowski](https://www.linkedin.com/in/maksymilian-kułakowski)

## 🙏 Acknowledgments

- Inspired by modern portfolio designs
- Font Awesome for icons
- Google Fonts for typography
- AOS, Particles.js, and Typed.js for animations
- The open-source community

## 📸 Screenshots

### Desktop View
![Desktop View](https://via.placeholder.com/1200x800/0a192f/64ffda?text=Desktop+View)

### Mobile View
![Mobile View](https://via.placeholder.com/400x800/0a192f/64ffda?text=Mobile+View)

### Animations
![Animations](https://via.placeholder.com/1200x600/0a192f/64ffda?text=Smooth+Animations)

---

**⭐ If you found this helpful, please consider giving it a star!**

Made with 💚 by [Unseen](https://github.com/unseen2004)
