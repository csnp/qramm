#!/usr/bin/env python3
"""
Quick script to extract missing questions for specific practices
"""
import re

def extract_all_questions_for_practice(file_path, practice_num):
    """Extract all questions for a specific practice"""
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Find practice section
    practice_pattern = f'# Practice {practice_num}:.*?(?=# Practice|$)'
    practice_match = re.search(practice_pattern, content, re.DOTALL)
    
    if not practice_match:
        return []
    
    practice_content = practice_match.group(0)
    
    questions = []
    
    # Find all questions in both streams
    question_pattern = r'\*\*Question\*\*?:?\s*([^\n]+)\n\n\*\*Explanation\*\*:?\s*([^\n]+)\n\n\*\*Options\*\*:?\s*\n(.*?)\n\n\*\*Evidence to Look For\*\*:?\s*\n(.*?)(?=\n\n### Level|\n\n\*\*|$)'
    
    question_matches = re.finditer(question_pattern, practice_content, re.DOTALL)
    
    for match in question_matches:
        question_text = match.group(1).strip()
        explanation = match.group(2).strip()
        options_text = match.group(3).strip()
        evidence_text = match.group(4).strip()
        
        # Parse options
        options = []
        for line in options_text.split('\n'):
            line = line.strip()
            if line and not line.startswith('**'):
                options.append(line)
        
        # Parse evidence
        evidence = []
        for line in evidence_text.split('\n'):
            line = line.strip()
            if line and not line.startswith('**'):
                evidence.append(line)
        
        questions.append({
            'text': question_text,
            'explanation': explanation,
            'options': options,
            'evidence': evidence
        })
    
    return questions

# Extract Practice 1.3 questions
questions_1_3 = extract_all_questions_for_practice('/Users/decimai/workspace/qramm-repo/archive/Dimension 1 - v5.md', '1.3')
print(f"Found {len(questions_1_3)} questions for Practice 1.3:")
for i, q in enumerate(questions_1_3, 1):
    print(f"{i}. {q['text']}")
    print(f"   Options: {len(q['options'])}")
    print()
