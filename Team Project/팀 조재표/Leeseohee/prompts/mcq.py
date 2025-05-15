from schemas import MCQPromptConfig
import random

def generate_mcq_prompt(topic: str, config: MCQPromptConfig) -> str:
    """
    Generates a structured MCQ prompt with a random correct answer.
    """
    correct_answer = random.choice(["A", "B", "C", "D"])
    # Few-shot 예시 추가
    example_prompt = """
    Example:
    {
        "question": "What is the capital of France?",
        "A": "Paris",
        "B": "London",
        "C": "Rome",
        "D": "Seoul",
        "correct_answer": "A" # One of "A", "B", "C", or "D"
    }
    """

    return f"""
    You are a quiz generator. Generate a {config.difficulty}-level multiple-choice question about '{topic}' requiring {config.bloom_level}-level thinking.
    Include {config.distractor_count} plausible distractors.
    Ensure there is **excatly one correct answer** among the four options.

    Respond ONLY with this JSON structure:
    {example_prompt}

    Constraints:
    - Only respond with the JSON object, no explanations.
    - Ensure the correct answer matches the label provided.
    - Do not include any text before or after the JSON object.
    - Exactly one correct answer (marked in 'correct_answer')
    - 3 distractors must be clearly incorrect but plausible.
    - Labels (A/B/C/D) must strictly match the options.
    """