
import fitz  # PyMuPDF
import os
from PIL import Image
import pytesseract
from datetime import datetime
from langchain_ollama import OllamaLLM
from langchain.prompts import ChatPromptTemplate

llm = OllamaLLM(model="gemma3:12b")


# Tesseract 언어 설정 (한글 + 영어)
tesseract_lang = "kor+eng"
pytesseract.pytesseract.tesseract_cmd = r"C:\Program Files\Tesseract-OCR\tesseract.exe"


# 추출할 파일
doc = fitz.open(r"d:\고홍규\2025 한국외대 수학과 2학년 2학기\Quiz생성ai 프로젝트\OSS9.pdf")



# 현재 시간으로 이미지저장폴더명 생성
now_str = datetime.now().strftime("%Y%m%d_%H%M%S")
output_folder = os.path.join(
    r"d:\고홍규\2025 한국외대 수학과 2학년 2학기\Quiz생성ai 프로젝트", f"추출_{now_str}"
)
os.makedirs(output_folder, exist_ok=True)


# 이미지 저장
for page_num in range(len(doc)):
    page = doc.load_page(page_num)
    images = page.get_images(full=True)

    for img_index, img in enumerate(images):
        xref = img[0]
        pix = fitz.Pixmap(doc, xref)

        # RGB 아닌 경우 변환
        if pix.n > 4:
            pix = fitz.Pixmap(fitz.csRGB, pix)

        image_filename = os.path.join(output_folder, f"page{page_num+1}_img{img_index+1}.png")
        pix.save(image_filename)
        print(f"[✔] 저장됨: {image_filename}")

# 이미지 추출정보
for img in page.get_images():
    print("[이미지 정보]", img)


# 이미지에서 텍스트 추출 후 저장
for filename in os.listdir(output_folder):
    if filename.endswith(".png"):
        image_path = os.path.join(output_folder, filename)
        img = Image.open(image_path)

        # OCR 수행
        extracted_text = pytesseract.image_to_string(img, lang=tesseract_lang)
        # extracted_text = 사진에서 추출된 단어정보

# =================
# 오타교정 (방법3가지.)

        # # PART 1: Create a ChatPromptTemplate using a template string
        # print("-----Prompt from Template-----")
        # template = "Tell me a joke about {topic}."
        # prompt_template = ChatPromptTemplate.from_template(template)

        # prompt = prompt_template.invoke({"topic": a})
        # result = llm.invoke(prompt)
 

        # # PART 2: Prompt with Multiple Placeholders
        
        # template_multiple = """You are a helpful assistant.
        # Human: Tell me a {adjective} short story about a {animal}.
        # Assistant:"""
        # prompt_multiple = ChatPromptTemplate.from_template(template_multiple)
        # prompt = prompt_multiple.invoke({"adjective": "funny", "animal": "panda"})

        # result = llm.invoke(prompt)
 

        # PART 3: Prompt with System and Human Messages (Using Tuples)
        messages = [
            ("system", "너는 사용자가 입력한 문장의 오타를 교정하는 AI야. 오타가 있어도 최대한 자연스럽고 정확한 문장으로 고쳐줘. 결과는 오직 교정된 문장 하나만 출력해. 그 외의 설명, 접두어, 메타 정보는 출력하지 마."),
            ("human", "이 문장을 오타 교정해줘: {text}")
        ]
        prompt_template = ChatPromptTemplate.from_messages(messages)
        prompt = prompt_template.invoke({"text": extracted_text})
        #디폴트로 model변수의 AI 모델을 쓰는거임?
        extracted_text_llm_modify = llm.invoke(prompt)



# =================
        # 텍스트 파일로 저장 (같은 이름으로 .txt 확장자)
        txt_filename = filename.rsplit(".", 1)[0] + ".txt"
        txt_path = os.path.join(output_folder, txt_filename)
        with open(txt_path, "w", encoding="utf-8") as f:
            f.write(extracted_text)

        print(f"[✔] OCR 텍스트 저장됨: {txt_path}")

        txt_filename = filename.rsplit(".", 1)[0] + "_llm_modify.txt"
        txt_path = os.path.join(output_folder, txt_filename)
        with open(txt_path, "w", encoding="utf-8") as f:
            f.write(extracted_text_llm_modify)

        print(f"[✔] OCR 텍스트 저장됨: {txt_path}")


# 텍스트 추출
text = ""
for page in doc:
    text += page.get_text() + "\n"
print("[텍스트]", text)
# text = pdf에서 순수 추출된 단어정보

# ===============================
# 오타교정 (방법3가지.)



# PART 3: Prompt with System and Human Messages (Using Tuples)
messages = [
            ("system", "너는 사용자가 입력한 문장의 오타를 교정하는 AI야. 오타가 있어도 최대한 자연스럽고 정확한 문장으로 고쳐줘. 결과는 오직 교정된 문장 하나만 출력해. 그 외의 설명, 접두어, 메타 정보는 출력하지 마."),
            ("human", "이 문장을 오타 교정해줘: {text}")
        ]
prompt_template = ChatPromptTemplate.from_messages(messages)
prompt = prompt_template.invoke({"text": text})
#디폴트로 model변수의 AI 모델을 쓰는거임?
text_llm_modify = llm.invoke(prompt)



# =================




# 텍스트와 주석 저장할 파일 경로
text_output_path = os.path.join(output_folder, "pageAll_text.txt")
# annot_output_path = os.path.join(output_folder, "page_annotations.txt")


# 텍스트 저장
with open(text_output_path, "w", encoding="utf-8") as f:
    f.write(text)
    print(f"[✔] 전체페이지 텍스트 저장됨: {text_output_path}")

# 오타 교정된 텍스트 저장
corrected_output_path = os.path.join(output_folder, "pageAll_text_llm_modify.txt")  # 원하는 경로/파일명으로 수정 가능
with open(corrected_output_path, "w", encoding="utf-8") as f:
    f.write(text_llm_modify)
    print(f"[✔] 전체페이지 오타 교정된 텍스트 저장됨: {corrected_output_path}")
