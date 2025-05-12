from schemas import ShortPromptConfig

def generate_short_prompt(topic: str, config: ShortPromptConfig) -> str:
    """
    Generates a structured Short Answer prompt.
    """
    return f"""
    Generate a {config.difficulty}-level short-answer question about '{topic}'.
    Limit the answer to {config.word_limit} words.
    Format the response as JSON with the following structure:

    {{
        "question": "Your generated question",
        "correct_answer": "Brief and concise answer"
    }}
    """