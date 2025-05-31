#!/usr/bin/env python3
"""
QRAMM Full Assessment Builder - CORRECTED VERSION
Extracts questions from archive dimension files and builds complete 120-question assessment
This version handles the actual format found in the archive files
"""

import re
import os

def extract_practice_questions(content, practice_name):
    """Extract all questions for a specific practice from archive format"""
    questions = []
    
    # Find the practice section
    practice_pattern = f'### {re.escape(practice_name)}.*?(?=### Practice|# Dimension|$)'
    practice_match = re.search(practice_pattern, content, re.DOTALL)
    
    if not practice_match:
        print(f"Warning: Practice '{practice_name}' not found")
        return questions
        
    practice_content = practice_match.group(0)
    
    # Extract Stream A questions
    stream_a_pattern = r'#### Stream A:.*?(?=#### Stream B:|### Practice|$)'
    stream_a_match = re.search(stream_a_pattern, practice_content, re.DOTALL)
    
    if stream_a_match:
        stream_a_content = stream_a_match.group(0)
        
        # Extract questions from each level (1-5)
        level_questions = extract_stream_questions(stream_a_content, 'A')
        questions.extend(level_questions)
    
    # Extract Stream B questions  
    stream_b_pattern = r'#### Stream B:.*?(?=### Practice|# Dimension|$)'
    stream_b_match = re.search(stream_b_pattern, practice_content, re.DOTALL)
    
    if stream_b_match:
        stream_b_content = stream_b_match.group(0)
        
        # Extract questions from each level (1-5)
        level_questions = extract_stream_questions(stream_b_content, 'B')
        questions.extend(level_questions)
    
    return questions

def extract_stream_questions(stream_content, stream_name):
    """Extract questions from a stream"""
    questions = []
    
    # Find all level sections
    level_pattern = r'##### Level (\d+) - ([^\n]+)\n\n(.*?)(?=##### Level \d+|#### Stream|### Practice|$)'
    level_matches = re.finditer(level_pattern, stream_content, re.DOTALL)
    
    for match in level_matches:
        level_num = int(match.group(1))
        level_name = match.group(2)
        level_content = match.group(3)
        
        # Extract question from this level
        question = extract_single_question(level_content)
        if question:
            question['stream'] = stream_name
            question['level'] = level_num
            question['level_name'] = level_name
            questions.append(question)
    
    return questions

def extract_single_question(content):
    """Extract a single question from level content"""
    # Match the question pattern from archive files
    question_pattern = r'\*\*Question\*\*: ([^\n]+)\n\n\*\*Explanation\*\*: ([^\n]+)\n\n\*\*Options\*\*:\n\n(.*?)\n\n\*\*Evidence to Look For\*\*:\n\n(.*?)(?=\n\n##### Level|\n\n\*\*|$)'
    
    match = re.search(question_pattern, content, re.DOTALL)
    
    if not match:
        # Try alternative pattern
        question_pattern = r'\*\*Question\*\*: ([^\n]+)\n\n\*\*Explanation\*\*: ([^\n]+)\n\n\*\*Options\*\*:\n\n(.*?)\*\*Evidence to Look For\*\*:\n\n(.*?)(?=\n\n##### Level|\n\n\*\*|$)'
        match = re.search(question_pattern, content, re.DOTALL)
    
    if not match:
        return None
        
    question_text = match.group(1).strip()
    explanation = match.group(2).strip()
    options_text = match.group(3).strip()
    evidence_text = match.group(4).strip()
    
    # Parse options (should be 4 options)
    options = []
    option_lines = options_text.split('\n')
    for line in option_lines:
        line = line.strip()
        if line and not line.startswith('**'):
            options.append(line)
    
    # Parse evidence points
    evidence_points = []
    evidence_lines = evidence_text.split('\n')
    for line in evidence_lines:
        line = line.strip()
        if line and not line.startswith('**') and line:
            evidence_points.append(line)
    
    return {
        'text': question_text,
        'explanation': explanation,
        'options': options,
        'evidence': evidence_points
    }

def extract_practices_from_archive(file_path):
    """Extract all practices and their questions from archive dimension files"""
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
        
        # Find all practice sections
        practices = []
        practice_pattern = r'### Practice (\d+\.\d+): ([^\n]+)\n\n\*\*Outcome\*\*: ([^\n]+)'
        practice_matches = re.finditer(practice_pattern, content)
        
        for match in practice_matches:
            practice_num = match.group(1)
            practice_name = match.group(2)
            outcome = match.group(3)
            
            # Extract questions for this practice
            full_practice_name = f"Practice {practice_num}: {practice_name}"
            questions = extract_practice_questions(content, full_practice_name)
            
            practices.append({
                'number': practice_num,
                'name': practice_name,
                'outcome': outcome,
                'questions': questions
            })
        
        return practices
    except Exception as e:
        print(f"Error reading {file_path}: {e}")
        return []

def build_assessment_content():
    """Build the complete assessment content"""
    
    # File paths for dimension archives
    archive_files = [
        ('/Users/decimai/workspace/qramm-repo/archive/Dimension 1 - v5.md', 1, 'Cryptographic Visibility & Inventory (CVI)'),
        ('/Users/decimai/workspace/qramm-repo/archive/Dimension 2 - v5.md', 2, 'Strategic Governance & Risk Management (SGRM)'),
        ('/Users/decimai/workspace/qramm-repo/archive/Dimension 3 - v5.md', 3, 'Data Protection Engineering (DPE)'),
        ('/Users/decimai/workspace/qramm-repo/archive/Dimension 4 - v5.md', 4, 'Implementation & Technical Readiness (ITR)')
    ]
    
    # Start with existing header content
    assessment_content = """# QRAMM Full Assessment Framework
**Quantum Risk Assessment and Management Methodology - Complete 120-Question Evaluation**

## Overview

The QRAMM Full Assessment is a comprehensive evaluation framework designed to measure organizational readiness for quantum computing threats across four critical dimensions. This assessment provides detailed insights into your organization's current capabilities and guides strategic planning for quantum-safe transformation.

**Assessment Structure:**
- **4 Dimensions:** CVI, SGRM, DPE, ITR
- **12 Practices:** 3 practices per dimension
- **120 Questions:** 10 questions per practice
- **5 Maturity Levels:** From Basic (1) to Optimizing (5)
- **2 Assessment Streams:** Foundation (60%) and Advanced (40%) per practice

## Instructions

For each question, select the option that best describes your organization's current state. Consider the explanation and evidence indicators when making your selection. Be honest and realistic in your assessments to ensure accurate results.

---

"""
    
    total_questions = 0
    
    # Process each dimension
    for file_path, dim_num, dim_name in archive_files:
        if not os.path.exists(file_path):
            print(f"Warning: {file_path} not found")
            continue
            
        practices = extract_practices_from_archive(file_path)
        
        # Add dimension header
        assessment_content += f"# Dimension {dim_num}: {dim_name}\n\n"
        
        # Add each practice
        for practice in practices:
            assessment_content += f"## Practice {practice['number']}: {practice['name']}\n\n"
            assessment_content += f"**Outcome**: {practice['outcome']}\n\n"
            
            # Add each question with proper numbering
            for q_num, question in enumerate(practice['questions'], 1):
                total_questions += 1
                assessment_content += f"### Question {practice['number']}.{q_num}: {question['text']}\n\n"
                assessment_content += f"**Explanation**: {question['explanation']}\n\n"
                assessment_content += "**Options**:\n"
                
                # Add options (should be exactly 4)
                for option in question['options']:
                    assessment_content += f"- {option}\n"
                
                assessment_content += "\n**Evidence to Look For**:\n"
                
                # Add evidence points
                for evidence in question['evidence']:
                    assessment_content += f"- {evidence}\n"
                
                assessment_content += "\n"
            
            print(f"Practice {practice['number']}: {len(practice['questions'])} questions extracted")
        
        assessment_content += "---\n\n"
    
    print(f"Total questions extracted: {total_questions}")
    
    return assessment_content

def main():
    """Main function to build and save the assessment"""
    print("Building QRAMM Full Assessment (CORRECTED VERSION)...")
    
    try:
        content = build_assessment_content()
        
        # Save to file
        output_path = '/Users/decimai/workspace/qramm-repo/assessment/full-assessment.md'
        with open(output_path, 'w', encoding='utf-8') as f:
            f.write(content)
        
        print(f"✅ Assessment saved to {output_path}")
        print(f"📊 Content length: {len(content):,} characters")
        
    except Exception as e:
        print(f"❌ Error building assessment: {e}")

if __name__ == "__main__":
    main()
