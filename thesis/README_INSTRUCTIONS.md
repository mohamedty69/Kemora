# Kemora Graduation Project Book - Instructions

Everything related to your graduation project book is now completely contained within this `E:\Kemora\thesis` folder.

## 1. Required Figures & Images Checklist
To make the document compile perfectly and hit your target page count, you need to provide the following image files and place them exactly in the `E:\Kemora\thesis\figures\` folder with these exact names:

### System Diagrams (Required)
*(Note: I provided `.mmd` Mermaid files for these. If you have the Mermaid-CLI `mmdc` installed, you can generate them, or just use an online Mermaid live editor to export them as PNGs).*
- [ ] `architecture.png` (Exported from `architecture.mmd`)
- [ ] `erd.png` (Exported from `erd.mmd`)

### Cover Page (Optional but recommended)
- [ ] `placeholder_logo.png` (Your university or faculty logo. Overwrite the dummy file if you create one, or remove the line in `main.tex`).

### Frontend UI Screenshots (Required for Chapter 3)
Take vertical screenshots from your Flutter emulator/phone and name them exactly as follows:
- [ ] `splash.png` (The Kemora splash screen)
- [ ] `login.png` (The login/register screen)
- [ ] `home.png` (The main dashboard feed)
- [ ] `map.png` (The interactive governorates map)
- [ ] `gov_details.png` (The details page of a specific governorate)
- [ ] `place_details.png` (The details page of a specific place/hotel/restaurant)
- [ ] `ai_questions.png` (The AI trip planner multi-step questionnaire)
- [ ] `ai_itinerary.png` (The beautifully rendered AI generated trip roadmap)
- [ ] `social_feed.png` (The community social feed showing posts)
- [ ] `chat.png` (The real-time messaging interface)
- [ ] `profile.png` (The user profile screen)
- [ ] `badges.png` (The gamification/badges screen)

## 2. LaTeX Compilation Instructions
1. Open the `E:\Kemora\thesis\main.tex` file in your favorite editor (e.g., VS Code with LaTeX Workshop, TeXstudio, or upload the whole folder to Overleaf).
2. At the top of `main.tex`, look for the section `--- USER PLACEHOLDERS ---`.
3. Replace the bracketed text with your actual details:
   - `\newcommand{\universityName}{[UNIVERSITY NAME]}` -> `\newcommand{\universityName}{Cairo University}`
   - Fill in your Faculty, Academic Year, Supervisor, and Team Members.
4. Run your LaTeX compiler (typically `pdflatex main.tex`). Run it twice to ensure the Table of Contents generates properly.

## 3. Review the Appendices
I have included two robust appendices at the end of the document to ensure the page count is substantial and technically impressive:
- **Appendix A:** An API reference detailing key backend endpoints (the full API surface spans 100 endpoints across 18 controllers).
- **Appendix B:** The critical source code implementation of the `OpenRouterAiService` showing the dynamic LLM integration.
