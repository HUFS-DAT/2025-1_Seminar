from schemas import MCQPromptConfig

def generate_mcq_prompt(topic: str, config: MCQPromptConfig) -> str:
    """
    Generates a structured MCQ prompt.
    """
    return f"""
    Generate a {config.difficulty}-level multiple-choice question about '{topic}'
    requiring {config.bloom_level}-level thinking. Include {config.distractor_count}
    plausible distractors and format the response as JSON with the following structure:

    {{
        "question": "Your generated question",
        "A": "Option 1",
        "B": "Option 2",
        "C": "Option 3",
        "D": "Option 4",
        "correct_answer": "A"
    }}
    """