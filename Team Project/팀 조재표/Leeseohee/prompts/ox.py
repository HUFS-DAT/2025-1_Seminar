from schemas import OXPromptConfig
import random


def generate_ox_prompt(topic: str, config: OXPromptConfig) -> str:
    """
    Generates a structured OX prompt.
    """
    is_true = random.choice([True, False])
    correct_answer = "O" if is_true else "X"

    # Few-shot 예시 추가
    example_prompt = """
    Example:
    {
        "question": "Is the Earth round?",
        "options": [
            {"option_text": "O", "is_correct": true},
            {"option_text": "X", "is_correct": false}
        ],
        "correct_answer": "O"
    }
    """

    return f"""
    You are a quiz generator. Generate a {config.difficulty}-level True/False (OX) question about '{topic}'.

    Respond ONLY with this JSON structure:
    {example_prompt}

    Constraints:
    - Only respond with the JSON object, no explanations.
    - Ensure the correct answer matches the label provided.
    - Do not include any text before or after the JSON object.
    """
