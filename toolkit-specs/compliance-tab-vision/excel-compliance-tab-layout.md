# Excel Compliance Tab - Visual Layout Guide

## Overview
This document shows exactly how the Compliance tab should look in Excel, using only native Excel features (no macros).

## Excel Layout Mockup

```
   A          B          C          D          E          F          G          H          I          J
1  ═══════════════════════════════════════════════════════════════════════════════════════════════════
2  ║                              QRAMM COMPLIANCE MAPPING                                             ║
3  ═══════════════════════════════════════════════════════════════════════════════════════════════════
4
5  Select Framework:  [▼ NIST CSF 2.0                    ]    ← Data validation dropdown
6
7  ┌─────────────────────────────────────────────────────────────────────────────────────────────────┐
8  │  COMPLIANCE OVERVIEW - NIST CSF 2.0                                                             │
9  ├─────────────────┬─────────────────┬─────────────────┬─────────────────┬───────────────────────┤
10 │ Overall Score   │ Mapped Controls │ Full Coverage   │ Partial Coverage│ No Coverage          │
11 │                 │                 │                 │                 │                      │
12 │     73%         │    42/58        │      28         │      14         │     16               │
13 │   [███████░░]   │                 │    (48%)        │    (24%)        │   (28%)              │
14 └─────────────────┴─────────────────┴─────────────────┴─────────────────┴───────────────────────┘
15
16 Framework Category Coverage:
17 ┌─────────────────────────────────────────────────────────────────────────────────────────────────┐
18 │ Identify (ID)    [████████████████████░░░░░]  85%                                               │
19 │ Protect (PR)     [██████████████░░░░░░░░░░░]  70%                                               │
20 │ Detect (DE)      [████████████░░░░░░░░░░░░░]  60%                                               │
21 │ Respond (RS)     [███████████████░░░░░░░░░░]  75%                                               │
22 │ Recover (RC)     [█████████████░░░░░░░░░░░░]  65%                                               │
23 └─────────────────────────────────────────────────────────────────────────────────────────────────┘
24
25 DETAILED MAPPING
26 ┌─────────────────────────────────────────────────────────────────────────────────────────────────┐
27 │ Relevance Score Guide: 1.0 = Direct Match | 0.8 = Strong Match | 0.6 = Moderate | 0.4 = Related │
28 └─────────────────────────────────────────────────────────────────────────────────────────────────┘
29 ┌────────────────────────┬─────────────────┬──────────┬────────────┬──────────┬─────────────────┐
30 │ QRAMM Practice         │ Framework Ctrl  │ Relevance│ Your Score │ Coverage │ Gap Priority    │
31 ├────────────────────────┼─────────────────┼──────────┼────────────┼──────────┼─────────────────┤
32 │ CVI.1.1 - Crypto       │ ID.AM-1        │   1.0    │    75%     │   75%    │ Low             │
33 │ Discovery              │ ID.AM-2        │   1.0    │    75%     │   75%    │ Low             │
34 ├────────────────────────┼─────────────────┼──────────┼────────────┼──────────┼─────────────────┤
35 │ CVI.1.2 - Vuln        │ ID.RA-1        │   1.0    │    60%     │   60%    │ Medium           │
36 │ Assessment             │ ID.RA-3        │   1.0    │    60%     │   60%    │ Medium           │
37 ├────────────────────────┼─────────────────┼──────────┼────────────┼──────────┼─────────────────┤
38 │ SGRM.2.1 - Executive  │ GV.OC-1        │   1.0    │    40%     │   40%    │ HIGH ⚠          │
39 │ Leadership            │ GV.OC-2        │   1.0    │    40%     │   40%    │ HIGH ⚠          │
40 └────────────────────────┴─────────────────┴──────────┴────────────┴──────────┴─────────────────┘
38
39
```

## Key Excel Features Used

### 1. Framework Selection (Row 5)
- **Data Validation** dropdown listing all 8 frameworks:
  - NIST CSF 2.0
  - NIST PQC
  - CMMC 2.0
  - FISMA
  - FedRAMP
  - ISO 27001
  - SOC2
  - CIS v8

### 2. Summary Cards (Rows 8-14)
- **Merged cells** with borders for card appearance
- **Conditional formatting** for score colors:
  - Green: ≥80%
  - Yellow: 60-79%
  - Red: <60%
- **REPT formula** for progress bar: `=REPT("█",ROUND(B12*10,0))&REPT("░",10-ROUND(B12*10,0))`

### 3. Category Progress Bars (Rows 16-23)
- Uses same REPT formula technique
- Pulls from calculation sheet using SUMIFS on the mapping table

### 4. Detailed Mapping Table (Rows 25-37)
- **Structured Table** (Insert > Table) for sorting/filtering
- **Conditional formatting** on Gap Priority column
- **Icons** using Wingdings or Unicode characters
- Formula for Coverage: `=Relevance * Your_Score`

### 5. Key Formulas

**Overall Compliance Score (Cell B12):**
```excel
=SUMPRODUCT(
    (Data!$B$2:$B$500=Compliance!$D$5)*
    Data!$H$2:$H$500*
    VLOOKUP(Data!$A$2:$A$500,Assessment!$A:$C,3,FALSE)
)/SUMIF(Data!$B$2:$B$500,Compliance!$D$5,Data!$H$2:$H$500)
```
*Note: Column H contains Relevance scores (1.0, 0.8, etc.)*

**Mapped Controls Count (Cell E12):**
```excel
=COUNTIFS(Data!$B:$B,Compliance!$D$5,Data!$H:$H,">0")&"/"&
COUNTIF(FrameworkControls!$A:$A,Compliance!$D$5)
```

**Gap Priority Calculation:**
```excel
=IF(E32<0.3,"HIGH ⚠",IF(E32<0.7,"Medium","Low"))
```
*Where E32 is the Coverage cell*

**Coverage Calculation (Column E):**
```excel
=C32*D32
```
*Where C32 is Relevance and D32 is Your Score*

### 6. Visual Design Elements
- **Borders**: Box borders for sections
- **Cell shading**: Light blue headers, white data areas
- **Font hierarchy**: 
  - Title: 16pt bold
  - Section headers: 12pt bold
  - Data: 10pt regular
- **Number formats**: Percentages with no decimals
- **Alignment**: Center-aligned scores, left-aligned text

### 7. REMOVED


### 8. Hidden Calculations Sheet
Contains:
- Full mapping table from Document 4 - 4_QRAMM_Compliance_Mapping_Details
- SUMIFS formulas for category rollups
- RANK formulas for improvement opportunities
- Lookup tables for framework controls

## User Experience Flow

1. User selects framework from dropdown
2. All displays update automatically via formulas

## Implementation Notes

- All data comes from the existing mapping in Document 4 - 4_QRAMM_Compliance_Mapping_Details
- Progress bars use Unicode block characters (█ and ░)
- Colors use Excel's standard theme colors for consistency
- Table formatting allows easy sorting and filtering
- Formulas reference structured tables for clarity