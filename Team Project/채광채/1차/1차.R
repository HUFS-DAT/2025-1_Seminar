library(dplyr)
library(lightgbm)
library(caret)

# 1. 데이터 로드
train <- read.csv("C:/Users/hyva/Desktop/학회/4-1/프로젝트/데이콘자료/train.csv")
test  <- read.csv("C:/Users/hyva/Desktop/학회/4-1/프로젝트/데이콘자료/test.csv")

# 2. 전처리 함수 정의
parse_valuation <- function(x) {
  if (is.na(x) || x == "") return(NA)
  if (x == "6000이상") return(6000)
  parts <- strsplit(x, "-")[[1]]
  return(mean(as.numeric(parts)))
}

winsorize_manual <- function(x, lower = 0.05, upper = 0.95) {
  bounds <- quantile(x, probs = c(lower, upper), na.rm = TRUE)
  x[x < bounds[1]] <- bounds[1]
  x[x > bounds[2]] <- bounds[2]
  return(x)
}

fill_missing_by_group <- function(df, group_col, target_cols) {
  for (col in target_cols) {
    df <- df %>%
      group_by(.data[[group_col]]) %>%
      mutate(!!col := ifelse(is.na(.data[[col]]),
                             median(winsorize_manual(.data[[col]]), na.rm = TRUE),
                             .data[[col]])) %>% ungroup()
  }
  return(df)
}

# 3. 피처 엔지니어링
train$업력 <- 2025 - train$설립연도
test$업력  <- 2025 - test$설립연도

train$기업가치_중간값 <- sapply(train$기업가치.백억원., parse_valuation)
test$기업가치_중간값  <- sapply(test$기업가치.백억원., parse_valuation)

train$고객X매출 <- train$고객수.백만명. * train$연매출.억원.
test$고객X매출  <- test$고객수.백만명. * test$연매출.억원.

# 4. 범주 통합
top_countries <- names(sort(table(train$국가), decreasing = TRUE))[1:10]
train$국가_정리 <- ifelse(train$국가 %in% top_countries, train$국가, "기타")
test$국가_정리  <- ifelse(test$국가 %in% top_countries, test$국가, "기타")

top_fields <- names(sort(table(train$분야), decreasing = TRUE))[1:8]
train$분야_정리 <- ifelse(train$분야 %in% top_fields, train$분야, "기타")
test$분야_정리  <- ifelse(test$분야 %in% top_fields, test$분야, "기타")

# 5. 결측치 처리
target_cols <- c("직원.수", "고객수.백만명.", "총.투자금.억원.", "연매출.억원.", 
                 "SNS.팔로워.수.백만명.", "기업가치_중간값", "고객X매출")
train <- fill_missing_by_group(train, "국가", target_cols)
test  <- fill_missing_by_group(test, "국가", target_cols)

# 6. 가중치
train <- train %>% filter(!is.na(분야))
count_tbl <- table(train$성공확률)
train$weight <- 1 / count_tbl[as.character(train$성공확률)]
train$weight <- train$weight / mean(train$weight)

# 7. 이진 변수 변환
train$인수여부 <- ifelse(train$인수여부 == "Yes", 1, 0)
test$인수여부  <- ifelse(test$인수여부 == "Yes", 1, 0)
train$상장여부 <- ifelse(train$상장여부 == "Yes", 1, 0)
test$상장여부  <- ifelse(test$상장여부 == "Yes", 1, 0)

# 8. 모델 학습 준비
features <- c("국가_정리", "분야_정리", "투자단계", "인수여부", 
              "상장여부", "업력", target_cols)
X <- model.matrix(~ . -1, data = train[, features])
y <- train$성공확률
w <- train$weight

# 9. 교차검증
set.seed(42)
folds <- createFolds(y, k = 5)
mae_scores <- c()
params <- list(objective = "regression", metric = "mae", learning_rate = 0.01)

for (i in 1:5) {
  idx <- folds[[i]]
  dtrain <- lgb.Dataset(X[-idx, ], label = y[-idx], weight = w[-idx])
  dval   <- lgb.Dataset(X[idx, ],  label = y[idx],  weight = w[idx])
  
  model_cv <- lgb.train(params, dtrain, nrounds = 3000,
                        valids = list(valid = dval),
                        early_stopping_rounds = 50, verbose = 0)
  
  preds <- predict(model_cv, X[idx, ])
  mae <- sum(w[idx] * abs(y[idx] - preds)) / sum(w[idx])
  mae_scores <- c(mae_scores, mae)
}
cat("평균 MAE:", mean(mae_scores), "\n")

# 10. 전체 학습 및 예측
final_model <- lgb.train(params, lgb.Dataset(X, label = y, weight = w), nrounds = model_cv$best_iter)
test_matrix <- model.matrix(~ . -1, data = test[, features])
preds <- predict(final_model, test_matrix)
preds <- round(pmin(pmax(preds, 0.1), 0.9), 1)

# 11. 저장
submission <- data.frame(ID = test$ID, 성공확률 = preds)
write.csv(submission, "C:/Users/hyva/Desktop/학회/4-1/프로젝트/데이콘자료/submission_final.csv", row.names = FALSE)
cat("완료: submission_final.csv 저장됨\n")
