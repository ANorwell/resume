# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a personal resume repository containing LaTeX source files for generating professional resumes. The primary working file is `ArronNorwellResume.tex`, which uses the ModernCV LaTeX class.

## Key Commands

### Building the Resume
```bash
# Build PDF from LaTeX source
pdflatex ArronNorwellResume.tex
```

### Cleaning Build Files
```bash
# Remove auxiliary files
rm -f ArronNorwellResume.aux ArronNorwellResume.log ArronNorwellResume.out
```

## File Structure

- `ArronNorwellResume.tex` - Main LaTeX resume source file (actively maintained)
- `ArronNorwellResume.pdf` - Generated PDF output
- `ArronNorwellResume*.pdf` - Historical resume versions

## Editing the Resume

The resume uses the ModernCV LaTeX document class with the classic blue theme. Key sections include:

- **Header/Contact Info**: Name, phone, email, location, website, GitHub
- **Summary**: Brief professional overview
- **Skills**: Technical proficiencies and programming languages
- **Experience**: Work history with bullet points
- **Education**: Degrees and institutions
- **Selected Projects**: Notable projects and open source contributions

### Common Modifications

1. **Adding Experience**: Use `\cventry{dates}{title}{company}{}{location}{bullet_points}`
2. **Updating Skills**: Modify `\cvlistdoubleitem{}{}` entries
3. **Adjusting Layout**: 
   - Margins: Modify `\usepackage[...]{geometry}` parameters
   - Spacing: Adjust `\itemsep` values in itemize environments
   - Font size: Change document class options

### One-Page Formatting Tips

- Use tighter margins: `scale=0.9, top=1cm, bottom=1cm`
- Reduce item spacing: `\itemsep -2pt` 
- Condense bullet points while preserving key achievements
- Combine similar sections (e.g., education degrees on one line)
- Remove older/less relevant positions if necessary

## Dependencies

Requires a full LaTeX installation with:
- ModernCV document class
- FontAwesome packages
- Standard LaTeX packages (geometry, hyperref, etc.)

On Debian/Ubuntu:
```bash
sudo apt install texlive-latex-base texlive-latex-extra texlive-fonts-recommended
```