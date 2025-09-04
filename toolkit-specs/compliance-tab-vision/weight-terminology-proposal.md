# Compliance Mapping Terminology Improvement

## Problem
"Weight" doesn't communicate what the number actually means - users won't understand that 0.8 means "strong alignment" vs 1.0 meaning "direct requirement"

## Proposed Alternative Terms

### Option 1: "Relevance Score"
- More intuitive - immediately suggests "how relevant is this QRAMM practice to this control?"
- Allows for the 0.0-1.0 scale to make sense

### Option 2: "Coverage Level"
- Indicates how much the QRAMM practice "covers" the framework requirement
- Natural to understand that 1.0 = full coverage

### Option 3: "Alignment Rating"
- Shows how well aligned the QRAMM practice is with the control
- Professional terminology that compliance officers understand

## Recommended Implementation

### 1. Change Column Header
Instead of just "Weight", use:
```
Relevance Score
(What's this?)
```
With a tooltip/help icon

### 2. Add Legend/Key
Include a visible legend on the Compliance tab:

```
RELEVANCE SCORING KEY:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
1.0 = Direct Match     QRAMM practice directly satisfies this control
0.8 = Strong Match     QRAMM practice substantially covers this control  
0.6 = Moderate Match   QRAMM practice partially addresses this control
0.4 = Related          QRAMM practice has indirect relevance
0.2 = Minimal          QRAMM practice has slight connection
0.0 = Not Applicable   No relationship between practice and control
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### 3. Visual Indicators
Add visual cues alongside the numbers:
- 1.0 = ● (filled circle)
- 0.8 = ◕ (mostly filled)
- 0.6 = ◑ (half filled)
- 0.4 = ◔ (partially filled)
- 0.2 = ○ (empty circle)

### 4. Contextual Help Text
When hovering over a relevance score, show examples:

**1.0 Direct Match Example:**
"Cryptographic Discovery (QRAMM) → Asset Inventory (NIST CSF)
Both require identifying and cataloging cryptographic assets"

**0.8 Strong Match Example:**
"Cryptographic Discovery (QRAMM) → Access Control (CMMC)
Access control needs asset information, though it's not the primary focus"

**0.6 Moderate Match Example:**
"Quantum Threat Assessment (QRAMM) → Vulnerability Management (ISO)
ISO addresses vulnerabilities but doesn't specifically mention quantum threats"

## Benefits of This Approach

1. **Immediate Understanding**: Users instantly grasp what the numbers mean
2. **Reduces Confusion**: No need to guess or look up documentation
3. **Builds Confidence**: Users trust the mappings when they understand them
4. **Actionable**: Helps prioritize which improvements matter most

## Implementation in Excel

### Option A: Dedicated Legend Section
Add a small box below the framework selector with the scoring key

### Option B: Tooltip on Column Header
Add a comment/note to the "Relevance Score" header cell with the full explanation

### Option C: Conditional Formatting
Use cell background shading:
- 1.0 = Dark blue
- 0.8 = Medium blue
- 0.6 = Light blue
- 0.4 = Very light blue
- 0.2 = Gray

This makes the relevance visually obvious without reading numbers.