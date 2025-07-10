# rtdog Distribution Guide

## 🚀 **Complete Distribution Strategy**

This guide explains how to distribute rtdog to your coworkers with minimal friction, maximum security, and proper download tracking.

## 📋 **Distribution Overview**

### **Primary Method: GitHub Releases + One-Click Installer**
- ✅ **No Apple Store required**
- ✅ **One-click installation** via terminal command
- ✅ **Security handling** via automatic quarantine removal
- ✅ **Download tracking** via GitHub analytics
- ✅ **Company workspace** within GitHub organization

### **Backup Methods**
- **Manual Download**: Direct ZIP download from GitHub releases
- **Source Installation**: For developers who want to customize
- **Direct File Sharing**: For offline scenarios

## 🔧 **Setup Process**

### **1. Automated Release Creation**

The release process is already automated via the `scripts/release.sh` script. When you create a new release:

```bash
# Create a new release
./scripts/release.sh patch

# This automatically:
# - Bumps version number
# - Builds release archive
# - Creates ZIP file
# - Commits changes
# - Creates git tag
# - Pushes to GitHub
```

### **2. GitHub Release Upload**

After running the release script, upload the assets to GitHub:

```bash
# Upload release assets using GitHub CLI
gh release create v1.1.3 \
  ./releases/v1.1.3/rtdog-1.1.3.zip \
  --title "rtdog v1.1.3 - PDF Reporting & Bug Fixes" \
  --notes-file CHANGELOG.md \
  --latest
```

### **3. Enable GitHub Pages**

To host the installation landing page:

1. Go to your GitHub repository settings
2. Navigate to "Pages"
3. Set source to "Deploy from a branch"
4. Select "main" branch and "/docs" folder
5. The landing page will be available at: `https://ccdaniele.github.io/rtdog/install.html`

## 📊 **Download Tracking**

### **GitHub Analytics**
- **Release Downloads**: View download counts for each release asset
- **Traffic Insights**: See repository visits and clones
- **Referral Sources**: Track how people find the project

### **Access Analytics**
1. Go to GitHub repository
2. Click "Insights" tab
3. View "Traffic" for visitor statistics
4. View "Releases" for download statistics

### **Custom Analytics (Optional)**
If you need more detailed tracking, you can add Google Analytics to the landing page:

```html
<!-- Add to docs/install.html <head> section -->
<script async src="https://www.googletagmanager.com/gtag/js?id=GA_MEASUREMENT_ID"></script>
<script>
  window.dataLayer = window.dataLayer || [];
  function gtag(){dataLayer.push(arguments);}
  gtag('js', new Date());
  gtag('config', 'GA_MEASUREMENT_ID');
</script>
```

## 🔒 **Security Considerations**

### **Code Signing (Optional)**
For maximum security, consider getting an Apple Developer account ($99/year) and signing the app:

```bash
# Sign the application
codesign --deep --force --verify --verbose --sign "Developer ID Application: Your Name" rtdog.app

# Notarize for distribution
xcrun notarytool submit rtdog.app --keychain-profile "notarization" --wait
```

### **Checksums**
The installer script automatically verifies file integrity. For additional security, publish checksums:

```bash
# Generate checksums
shasum -a 256 rtdog-1.1.3.zip > rtdog-1.1.3.zip.sha256
```

### **Repository Security**
- **Private Repository**: Keep the repository private if needed
- **Access Control**: Use GitHub teams to control access
- **Branch Protection**: Protect main branch from direct pushes

## 📢 **Distribution Methods**

### **Method 1: One-Click Install (Recommended)**

**For coworkers:**
```bash
curl -fsSL https://raw.githubusercontent.com/ccdaniele/rtdog/main/install.sh | bash
```

**What it does:**
- Checks system requirements
- Downloads latest release from GitHub
- Installs to Applications folder
- Handles macOS security (removes quarantine)
- Provides user feedback and error handling

### **Method 2: Landing Page**

Share the professional landing page:
- **URL**: `https://ccdaniele.github.io/rtdog/install.html`
- **Features**: Multiple installation methods, troubleshooting, feature overview
- **Benefits**: Non-technical users get guided experience

### **Method 3: Direct GitHub Release**

For tech-savvy users:
- **URL**: `https://github.com/ccdaniele/rtdog/releases/latest`
- **Process**: Download ZIP, extract, move to Applications

### **Method 4: Internal Distribution**

For company-specific distribution:

```bash
# Create internal download script
#!/bin/bash
# company-install.sh

# Download from internal location
curl -L -o rtdog.zip "https://internal-server.company.com/rtdog/latest"
# ... rest of installation process
```

## 🎯 **Communication Strategy**

### **Email Template**
```
Subject: 🐕 rtdog - Office Day Tracker Now Available

Hi team,

I've created a macOS app to help track our office days and stay compliant with RTO requirements.

🚀 Quick Install (30 seconds):
1. Open Terminal
2. Paste: curl -fsSL https://raw.githubusercontent.com/ccdaniele/rtdog/main/install.sh | bash
3. Press Enter and follow prompts

📄 More Info: https://ccdaniele.github.io/rtdog/install.html

Features:
• 📅 Visual calendar tracking
• 📊 Monthly quota monitoring  
• 🔔 Smart notifications
• 📄 PDF reports
• 🔒 All data stays on your Mac

Questions? Reply to this email or check the GitHub repo.

Cheers!
```

### **Slack Message**
```
🐕 **rtdog - Office Day Tracker** is now available!

Track your office days easily with this native macOS app.

🚀 **Install in 30 seconds:**
```
curl -fsSL https://raw.githubusercontent.com/ccdaniele/rtdog/main/install.sh | bash
```

📄 **Full details:** https://ccdaniele.github.io/rtdog/install.html

Features: Calendar tracking, quota monitoring, smart notifications, PDF reports, and complete privacy (data stays local).

Built by Datadog employees, for Datadog employees. Not an official company product.
```

### **Teams Message**
```
🎉 **New Tool Available: rtdog - Office Day Tracker**

I've built a macOS app to help us track office days and stay compliant with RTO policies.

**Quick Install:**
- Open Terminal
- Run: `curl -fsSL https://raw.githubusercontent.com/ccdaniele/rtdog/main/install.sh | bash`
- Follow the prompts

**Features:**
- 📅 Visual calendar with work location tracking
- 📊 Monthly office day quota monitoring
- 🔔 Interactive notification reminders
- 📄 Generate PDF reports with statistics
- 🔒 Complete privacy - all data stored locally

**More Info:** https://ccdaniele.github.io/rtdog/install.html

Questions? Feel free to reach out!
```

## 🛠️ **Maintenance**

### **Regular Updates**
1. **Monthly Releases**: Regular feature updates and bug fixes
2. **Security Updates**: Address any security concerns promptly
3. **User Feedback**: Monitor GitHub issues and user feedback

### **Version Management**
- **Semantic Versioning**: Follow semver for clear version communication
- **Changelog**: Maintain comprehensive changelog
- **Deprecation Notices**: Provide advance notice for breaking changes

### **Support**
- **GitHub Issues**: Primary support channel
- **Documentation**: Keep README and guides up to date
- **FAQ**: Common questions and solutions

## 📈 **Analytics Dashboard**

### **Key Metrics to Track**
- **Downloads per release**
- **GitHub repository traffic**
- **User engagement (stars, forks, issues)**
- **Installation success rate**
- **User feedback and satisfaction**

### **Monitoring**
- **Weekly**: Check download statistics
- **Monthly**: Review user feedback and issues
- **Quarterly**: Analyze usage patterns and plan features

## 🔄 **Continuous Improvement**

### **User Feedback Loop**
1. **Collect**: GitHub issues, direct feedback
2. **Analyze**: Common requests and pain points
3. **Prioritize**: Impact vs. effort matrix
4. **Implement**: Regular release cycle
5. **Communicate**: Update users on progress

### **Distribution Optimization**
- **A/B Testing**: Different installation methods
- **User Experience**: Simplify installation process
- **Performance**: Optimize download speeds
- **Accessibility**: Ensure broad compatibility

## 🎉 **Success Metrics**

### **Short-term Goals (1-2 months)**
- [ ] 50+ downloads
- [ ] 90%+ installation success rate
- [ ] <5 support issues per month
- [ ] Positive user feedback

### **Long-term Goals (6+ months)**
- [ ] 200+ active users
- [ ] Feature requests from users
- [ ] Community contributions
- [ ] Internal adoption as standard tool

## 📞 **Support Channels**

### **Primary Support**
- **GitHub Issues**: https://github.com/ccdaniele/rtdog/issues
- **Email**: Direct contact for sensitive issues
- **Slack/Teams**: Company-specific support channels

### **Documentation**
- **README**: Basic setup and usage
- **Wiki**: Detailed documentation
- **FAQ**: Common questions and solutions
- **Video Tutorials**: For complex features

---

## 🚀 **Quick Start Checklist**

- [ ] Run release script to create latest version
- [ ] Upload release assets to GitHub
- [ ] Enable GitHub Pages for landing page
- [ ] Test installation script
- [ ] Share installation instructions with team
- [ ] Monitor download statistics
- [ ] Collect user feedback
- [ ] Plan next release

**Ready to distribute? Follow the steps above and your coworkers will be tracking their office days in no time! 🎯** 
