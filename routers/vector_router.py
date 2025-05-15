from fastapi import APIRouter, Query, UploadFile, File, HTTPException
from qdrant_client import QdrantClient
from qdrant_client.http.models import Distance, VectorParams, PointStruct, Filter
from sentence_transformers import SentenceTransformer
import uuid, json

router = APIRouter()
COLLECTION_NAME = "korean-texts"
VECTOR_DIM = 768
client = QdrantClient(url="http://qdrant:6333")

model = SentenceTransformer("jhgan/ko-sbert-sts")

@router.post("/init")
def init_collection():
    client.recreate_collection(
        collection_name=COLLECTION_NAME,
        vectors_config=VectorParams(size=VECTOR_DIM, distance=Distance.COSINE)
    )
    return {"status": "컬렉션 초기화 완료"}

@router.post("/add")
def add_text(text: str = Query(..., description="저장할 문장")):
    embedding = model.encode(text).tolist()
    point = PointStruct(id=str(uuid.uuid4()), vector=embedding, payload={"text": text})
    client.upsert(collection_name=COLLECTION_NAME, points=[point])
    return {"status": "저장 완료", "text": text}

@router.get("/search")
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

@router.get("/all")
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

@router.delete("/delete")
def delete_all():
    client.delete(
        collection_name=COLLECTION_NAME,
        points_selector=Filter(must=[])
    )
    return {"status": "전체 데이터 삭제 완료"}

@router.post("/upload-json")
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