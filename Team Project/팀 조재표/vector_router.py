from fastapi import APIRouter, Query, UploadFile, File, HTTPException
from qdrant_client import QdrantClient
from qdrant_client.http.models import Distance, VectorParams, PointStruct, Filter
from sentence_transformers import SentenceTransformer
import uuid, json
from utils.get_topic import get_topic
from utils.settings import QDRANT_URL, COLLECTION_NAME, STOPWORDS_KO_PATH, STOPWORDS_EN_PATH

client = QdrantClient(url=QDRANT_URL)

router = APIRouter()
COLLECTION_NAME = "korean-texts"
VECTOR_DIM = 512
# client = QdrantClient(url="http://qdrant:6333")

# model = SentenceTransformer("jhgan/ko-sbert-sts")
model = SentenceTransformer("sentence-transformers/distiluse-base-multilingual-cased-v2")

@router.post("/init", summary="시작", description="가장 먼저 실행해야함.")
def init_collection():
    client.recreate_collection(
        collection_name=COLLECTION_NAME,
        vectors_config=VectorParams(size=VECTOR_DIM, distance=Distance.COSINE)
    )
    return {"status": "컬렉션 초기화 완료"}


@router.post("/add", summary="추가", description="직접 추가할 때 사용.")
def add_text(text: str = Query(..., description="저장할 문장")):
    embedding = model.encode(text).tolist()
    point = PointStruct(id=str(uuid.uuid4()), vector=embedding, payload={"text": text})
    client.upsert(collection_name=COLLECTION_NAME, points=[point])
    return {"status": "저장 완료", "text": text}

@router.post("/upload-json", summary="json 파일 업로드", description="json 파일 벡터 임베딩 후 DB 저장장")
async def upload_json(file: UploadFile = File(...)):
    if not file.filename.endswith(".json"):
        raise HTTPException(status_code=400, detail="JSON 파일만 업로드 가능합니다.")

    content = await file.read()
    try:
        data = json.loads(content)
    except Exception as e:
        raise HTTPException(status_code=400, detail="JSON 파싱 오류")

    points = []
    for item in data:
        embedding = model.encode(item["text"]).tolist()
        point = PointStruct(
            id=str(uuid.uuid4()),
            vector=embedding,
            payload={
                "id": item.get("id"),
                "title": item.get("title"),
                "category": item.get("category"),
                "text": item.get("text")
            }
        )
        points.append(point)

    client.upsert(collection_name=COLLECTION_NAME, points=points)
    return {"status": "업로드 및 저장 완료", "count": len(points)}


@router.get("/search", summary="벡터 데이터 검색", description="입력 데이터의 상위 3개 유사한 벡터 탐색.")
def search_text(query: str = Query(..., description="검색할 문장")):
    query_vec = model.encode(query).tolist()
    results = client.search(
        collection_name=COLLECTION_NAME,
        query_vector=query_vec,
        limit=3,
        with_payload=True
    )
    return {
        "matches": [
            {"text": r.payload.get("text", ""), "score": r.score}
            for r in results
        ]
    }

@router.get("/search_1", summary="데이터 검색", description="입력값의 임계값 이상 벡터 데이터 탐색.")
def search_text(query: str = Query(...), threshold: float = 0.75):
    query_vec = model.encode(query).tolist()
    results = client.search(
        collection_name=COLLECTION_NAME,
        query_vector=query_vec,
        limit=10,
        with_payload=True,
        score_threshold=threshold
    )
    return {
        "matches": [
            {"text": r.payload.get("text", ""), "score": r.score}
            for r in results
        ]
    }

@router.get("/all", summary="전체 출력", description="DB내 모든 데이터 출력.")
def get_all():
    points, _ = client.scroll(
        collection_name=COLLECTION_NAME,
        limit=100,
        with_vectors=True
    )
    return [
        {
            "id": p.id,
            "text": p.payload.get("text", ""),
            "vector": p.vector[:5]  # 벡터 앞 5차원만 예시 출력
        }
        for p in points
    ]

@router.get("/vector/top-words", summary="최빈값", description="최빈 단어 10개 출력.")
def get_top_words_from_qdrant():
    result = get_topic(top_n=10)
    return {"top_words": result}


@router.delete("/delete", summary="전체 삭제", description="DB내 모든 데이터 삭제.")
def delete_all():
    client.delete(
        collection_name=COLLECTION_NAME,
        points_selector=Filter(must=[])
    )
    return {"status": "전체 데이터 삭제 완료"}


