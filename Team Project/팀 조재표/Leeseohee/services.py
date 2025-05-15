# services.py
import openai
import os
import json
import re # 정규 표현식
from dotenv import load_dotenv
from prompts import generate_mcq_prompt, generate_ox_prompt, generate_short_prompt
from schemas import MCQPromptConfig, OXPromptConfig, ShortPromptConfig, QuizOption, QuizResponse
from pydantic import ValidationError

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
        max_tokens=350,
        temperature=0.3 # 이 값을 어떻게 하는지가 중요 -> Stress test에서 같은 문제와 답변이 나오는 거 수정해야 함
    )

    response_content = response['choices'][0]['message']['content']

    # validate_json으로 검증 및 파싱
    try:
        parsed_response = validate_json(response_content)
    except ValidationError as e:
        print(f"Validation Error: {e}")
        raise ValueError("OpenAI response format error")

    # # JSON으로 파싱
    # try:
    #     parsed_response = json.loads(response_content)
    # except json.JSONDecodeError:
    #     print("JSON parsing error:", response_content)
    #     raise ValueError("OpenAI response format error")

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
        correct_answer_key = parsed_response["correct_answer"]
        # 추가 검증: 올바른 옵션인지 확인
        if correct_answer_key not in ["A", "B", "C", "D"]:
            raise ValueError(f"Invalid correct answer key: {correct_answer_key}")

        for key, value in parsed_response.items():
            if key in ["A", "B", "C", "D"]:
                is_correct = (key == correct_answer_key)
                options.append(QuizOption(option_text=value, is_correct=is_correct))

    # QuizResponse 생성
    quiz_response = QuizResponse(
        question=parsed_response["question"],
        options=options,
        answer=parsed_response["correct_answer"]
    )

    return quiz_response

def validate_json(response_content: str):
    """JSON 구조 검증 및 키 매칭 확인"""
    try:
        # 정규식으로 JSON만 추출
        json_str = re.search(r'\{.*\}', response_content, re.DOTALL).group()
        parsed = json.loads(json_str)
        # 필수 키 체크
        required_keys = ["question", "A", "B", "C", "D", "correct_answer"]
        for key in required_keys:
            if key not in parsed:
                raise ValueError(f"Missing required key: {key}")
        # Multiple Choice (MCQ) 문제인 경우
        if all(option in parsed for option in ["A", "B", "C", "D"]):
            options = ["A", "B", "C", "D"]
            if parsed["correct_answer"] not in options:
                raise ValueError(f"Correct answer '{parsed['correct_answer']}' does not match any of the provided options.")
        
        # OX 문제인 경우
        elif "options" in parsed:
            ox_options = [opt["option_text"] for opt in parsed["options"]]
            if parsed["correct_answer"] not in ox_options:
                raise ValueError(f"Correct answer '{parsed['correct_answer']}' does not match any of the provided options.")
        # Short Answer 문제는 추가적인 매칭이 필요하지 않음
        return parsed
    except json.JSONDecodeError:
        raise ValidationError("JSON decoding failed. The response is not a valid JSON. ")
    except Exception as e:
        raise ValidationError(f"Validation failed: {str(e)}")