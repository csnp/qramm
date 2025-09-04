# QRAMM Visual Design & Implementation Specifications
*Complete design standards and technical implementation details*

## Color Scheme

### Primary Colors
- **Primary Blue**: #4A90E2 (Headers, primary buttons)
- **Secondary Blue**: #E3F2FD (Light backgrounds)
- **Success Green**: #28A745 (Positive indicators)
- **Warning Yellow**: #FFC107 (Caution indicators)
- **Danger Red**: #DC3545 (Critical indicators)
- **Info Purple**: #6F42C1 (Level 5 / Optimizing)
- **Neutral Gray**: #6C757D (Inactive elements)

### Score-Based Colors
| Score Range | Background | Text | Use Case |
|-------------|------------|------|----------|
| 0-1.5 | #FFCDD2 | #C62828 | Critical/Level 1 |
| 1.6-2.5 | #FFF3CD | #856404 | Warning/Level 2 |
| 2.6-3.5 | #D4EDDA | #155724 | Good/Level 3 |
| 3.6-3.9 | #CCE5FF | #004085 | Excellent/Level 4 |
| 4.0 | #E1BEE7 | #6F42C1 | Optimizing/Level 5 |

## Conditional Formatting Rules

### For Score Cells (E10:E43 on each dimension tab)
```
Rule 1: Cell Value = "" → No Format
Rule 2: Cell Value between 0 and 1.5 → Fill #FFCDD2
Rule 3: Cell Value between 1.6 and 2.5 → Fill #FFF3CD
Rule 4: Cell Value between 2.6 and 3.5 → Fill #D4EDDA
Rule 5: Cell Value between 3.6 and 3.9 → Fill #CCE5FF
Rule 6: Cell Value = 4 → Fill #E1BEE7
```

### For Maturity Level Text
Apply icon sets:
- Level 1: ⭕ Red circle
- Level 2: 🟡 Yellow circle  
- Level 3: 🟢 Green circle
- Level 4: 🔵 Blue circle
- Level 5: 🟣 Purple star

## Cell Formatting Standards

### Input Cells (Unlocked)
- Background: White (#FFFFFF)
- Border: 2pt Blue (#4A90E2)
- Font: Calibri 11pt Regular

### Formula Cells (Locked)
- Background: Light Gray (#F8F9FA)
- Border: 1pt Gray (#DEE2E6)
- Font: Calibri 11pt Regular
- Protection: Locked, Hidden formulas

### Header Cells
- Background: Primary Blue (#4A90E2)
- Text: White (#FFFFFF)
- Font: Calibri 14pt Bold
- Alignment: Center

## Chart Specifications

### Radar Chart (Dimensions)
```
Type: Radar with Markers
Size: 400x400 pixels
Position: Scorecard tab, D30:J50

Series Configuration:
1. Your Score (Blue, 40% transparent fill)
2. Target (Red line, no fill, dashed)
3. Industry Average (Green line, no fill)

Axis: 0-4, Major unit 1
Gridlines: Major only, light gray
Legend: Bottom center
```

### Progress Indicators
```
Type: Data Bars
Length: Proportional to value
Color: Gradient Blue (#E3F2FD to #4A90E2)
Show value: Yes
```

## Protection Settings

### Workbook Level
- Structure: Protected
- Windows: Protected
- Password: QRAMM2025

### Worksheet Level
All sheets protected with password, allowing users to:
- Select locked cells: Yes
- Select unlocked cells: Yes
- Format cells: No
- Insert/delete rows: No
- Sort: No
- Use AutoFilter: Yes

### Unlocked Cells
- Profile: C11:C20 (organization inputs)
- Dimensions: D10:D43, F10:F43 (answers & notes)
- Welcome: None
- Scorecard: None
- Compliance: B20:B27 (framework checkboxes)

## Font Hierarchy

1. **Main Title**: Calibri Light 24pt, Blue
2. **Section Headers**: Calibri 18pt Bold, Blue  
3. **Subsection Headers**: Calibri 14pt Bold, Black
4. **Body Text**: Calibri 11pt Regular, Black
5. **Explanatory Text**: Calibri 9pt Italic, Gray
6. **Data/Scores**: Calibri 12pt Bold, Conditional

## Layout Standards

### Column Widths
- A (Numbers): 8
- B (Questions): 45  
- C (Explanations): 35
- D (Answers): 25
- E (Scores): 12
- F (Evidence): 30

### Row Heights
- Headers: 30px
- Questions: 60px (to accommodate wrapped text)
- Totals: 25px

### Margins
- Top: 0.5"
- Bottom: 0.5"
- Left: 0.5"
- Right: 0.5"

## Navigation Elements

### Tab Colors
- Welcome: Green
- Profile: Blue
- Dimension 1-4: Orange
- Scorecard: Purple
- Compliance: Red
- Data: Gray (Hidden)

### Hyperlink Buttons
```
Style: Rounded rectangle
Fill: Primary Blue
Text: White, Bold
Size: 120x30 pixels
Hover: 10% darker blue
```

## Print Configuration

### Page Setup
- Orientation: Landscape (except Profile - Portrait)
- Paper Size: Letter (8.5" x 11")
- Scaling: Fit to 1 page wide

### Headers/Footers
- Header: "&[Tab] - QRAMM Assessment"
- Footer: "Page &[Page] of &[Pages] | &[Date] | Confidential"

## Implementation Notes

1. Remove gridlines from all visible sheets
2. Freeze panes at row 9 on dimension tabs
3. Group/outline practice sections for collapsing
4. Set zoom to 90% for better visibility
5. Enable worksheet protection last
6. Test all conditional formatting works
7. Verify charts update dynamically
8. Check print preview before delivery

## Quality Checks

- [ ] Consistent colors throughout
- [ ] All formulas hidden when protected
- [ ] Input cells clearly marked
- [ ] Professional appearance
- [ ] No spelling errors
- [ ] Smooth navigation
- [ ] Charts readable
- [ ] Prints correctly