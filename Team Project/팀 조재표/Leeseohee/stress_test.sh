#!/bin/bash

for i in {1..10}
do
  echo "🌀 Sending request $i..."
  curl -X POST "http://127.0.0.1:8000/generate-quiz" \
       -H "Content-Type: application/json" \
       -d '{
             "quiz_type": "mcq",
             "topic": "Artificial Intelligence",
             "config": {
                 "difficulty": "medium",
                 "bloom_level": "application",
                 "distractor_count": 3
             }
           }' 
  echo -e "\n-----------------------------------------"
done