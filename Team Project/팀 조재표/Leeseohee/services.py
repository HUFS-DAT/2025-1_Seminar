# services.py
import openai
import os
import json
from dotenv import load_dotenv
from prompts import generate_mcq_prompt, generate_ox_prompt, generate_short_prompt
from schemas import MCQPromptConfig, OXPromptConfig, ShortPromptConfig, QuizOption, QuizResponse

load_dotenv()
openai.api_key = os.getenv("OPENAI_API_KEY")

async def generate_quiz(quiz_type: str, topic: str, config: dict):
    if quiz_type == "ox":
        prompt = generate_ox_prompt(topic, OXPromptConfig(**config))
    elif quiz_type == "mcq":
        prompt = generate_mcq_prompt(topic, MCQPromptConfig(**config))
    elif quiz_type == "short":
        prompt = generate_short_prompt(topic, ShortPromptConfig(**config))
    else:
        raise ValueError("Invalid quiz type.")
    
    response = openai.ChatCompletion.create(
        model="gpt-3.5-turbo",
        messages=[
            {"role": "system", "content": "You are a helpful assistant that generates quiz questions."},
            {"role": "user", "content": prompt}
        ],
        max_tokens=150,
        temperature=0.7
    )

    response_content = response['choices'][0]['message']['content']
    # JSON으로 파싱
    try:
        parsed_response = json.loads(response_content)
    except json.JSONDecodeError:
        print("JSON parsing error:", response_content)
        raise ValueError("OpenAI response format error")

    #options 생성 (변경 전 - MCQ만 고려)
    # options = []
    # for key, value in parsed_response.items():
    #     if key in ["A", "B", "C", "D"]:
    #         options.append(QuizOption(option_text=value, is_correct=(key == parsed_response["correct_answer"])))
    
    # options 생성 (변경 후 - ox, short, mcq 모두 고려)
    options = []

    # OX 문제 처리
    if quiz_type == "ox":
        options = [
            QuizOption(option_text="O", is_correct=(parsed_response["correct_answer"] == "O")),
            QuizOption(option_text="X", is_correct=(parsed_response["correct_answer"] == "X"))
        ]
        correct_answer_text = parsed_response["correct_answer"]

    # Short Answer 문제 처리
    elif quiz_type == "short":
        options = []  # Short Answer는 선택지가 없으므로 빈 리스트
        correct_answer_text = parsed_response["correct_answer"]

    # Multiple Choice 문제 처리
    else:
        correct_answer_text = parsed_response[parsed_response["correct_answer"]]
        for key, value in parsed_response.items():
            if key in ["A", "B", "C", "D"]:
                is_correct = (value == correct_answer_text)
                options.append(QuizOption(option_text=value, is_correct=is_correct))

    # QuizResponse 생성
    quiz_response = QuizResponse(
        question=parsed_response["question"],
        options=options,
        answer=parsed_response["correct_answer"]
    )

    return quiz_response