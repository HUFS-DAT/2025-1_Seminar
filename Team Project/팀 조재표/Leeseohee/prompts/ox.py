from schemas import OXPromptConfig

def generate_ox_prompt(topic: str, config: OXPromptConfig) -> str:
    """
    Generates a structured OX prompt.
    """
    return f"""
    Generate a {config.difficulty}-level True/False (OX) question about '{topic}'.
    Format the response as JSON with the following structure:

    {{
        "question": "Your generated question",
        "options": [
            {{"option_text": "O", "is_correct": true}},
            {{"option_text": "X", "is_correct": false}}
        ],
        "correct_answer": "O"
    }}
    """