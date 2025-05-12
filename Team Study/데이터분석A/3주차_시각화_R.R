

data3 <- read.csv("C:/Users/hyva/Desktop/SQL/2주차 csv/data-1742792596921.csv")
str(data3)

data3$sales_month <- as.Date(data3$sales_month)  # sales_month를 Date 형식으로 변환



# 연도 추출
data3$year <- format(data3$sales_month, "%Y")

# sales를 숫자형으로 변환
data3$sales <- as.numeric(as.character(data3$sales))

# 선 그래프 그리기
ggplot(data3, aes(x = sales_month)) +
  geom_line(aes(y = moving_avg, color = "Moving Average"), size = 1) +  # 이동 평균 선 추가
  geom_line(aes(y = sales, color = "Sales")) +  # 실제 판매 선 추가
  labs(title = "Sales and Moving Average Over Time",  # 그래프 제목
       x = "Sales Month",                              # x축 레이블
       y = "Sales") +                                 # y축 레이블
  scale_x_date(breaks = seq(from = as.Date("1993-01-01"), 
                            to = as.Date("2021-01-01"), 
                            by = "2 years"), 
               date_labels = "%Y") +
  scale_color_manual(values = c("Moving Average" = "blue", "Sales" = "green")) +  # 색상 설정
  theme_minimal() +                                  # 미니멀 테마 적용
  theme(legend.title = element_blank())              # 범례 제목 제거


-------------------------------
  
  
data4 <- read.csv("C:/Users/hyva/Desktop/SQL/2주차 csv/data-1742795406180.csv")
data4
str(data4)

# sales_month를 Date 형식으로 변환
data4$sales_month <- as.Date(data4$sales_month)

# sales를 숫자형으로 변환
data4$sales <- as.numeric(as.character(data4$sales))

# 연도 및 월 변수 추가
data4$year <- format(data4$sales_month, "%Y")
data4$month <- format(data4$sales_month, "%m")

# 연도 및 월별 누적 매출 계산
data4 <- data4 %>%
  group_by(year, month) %>%
  mutate(cumulative_sales = cumsum(sales)) %>%  # 월별 누적 매출 계산
  ungroup()

# 연도별로 누적 매출을 계산하고, 각 연도별로 0부터 시작하도록 설정
data4 <- data4 %>%
  group_by(year) %>%
  mutate(cumulative_sales = ifelse(month == "01", sales, lag(cumulative_sales, order_by = sales_month) + sales)) %>%
  ungroup()

# 월별 누적 매출 데이터 생성
data4$cumulative_sales[is.na(data4$cumulative_sales)] <- 0  # 누적 매출 NA를 0으로 변경

# 월별 매출 및 누적 매출 그래프 그리기
ggplot(data4, aes(x = sales_month)) +
  geom_bar(aes(y = cumulative_sales, fill = "Cumulative Sales"), stat = "identity", position = "identity", alpha = 0.5) +  # 누적 매출 바 추가
  geom_line(aes(y = sales, color = "Monthly Sales"), size = 1) +  # 월별 매출 선 추가
  labs(title = "Monthly Sales and Cumulative Sales by Year",  # 그래프 제목
       x = "Sales Month",                                   # x축 레이블
       y = "Sales Amount") +                                # y축 레이블
  scale_color_manual(values = c("Monthly Sales" = "blue")) +  # 월별 매출 색상 설정
  scale_fill_manual(values = "gray") +  # 모든 연도의 바 색상을 회색으로 설정
  theme_minimal() +                                       # 미니멀 테마 적용
  theme(legend.title = element_blank())                 # 범례 제목 제거

ddd
-------------------
# 국제 금값 데이터...

date <- c(2020-12-01,2020-11-01,2020-10-01,2020-09-01,2020-08-01,2020-07-01,2020-06-01,2020-05-01,2020-04-01,2020-03-01,2020-02-01,
2020-01-01,
2019-12-01,
2019-11-01,
2019-10-01,
2019-09-01,
2019-08-01,
2019-07-01,
2019-06-01,
2019-05-01,
2019-04-01,
2019-03-01,
2019-02-01,
2019-01-01,
2018-12-01,
2018-11-01,
2018-10-01,
2018-09-01,
2018-08-01,
2018-07-01,
2018-06-01,
2018-05-01,
2018-04-01,
2018-03-01,
2018-02-01,
2018-01-01,
2017-12-01,
2017-11-01,
2017-10-01,
2017-09-01,
2017-08-01,
2017-07-01,
2017-06-01,
2017-05-01,
2017-04-01,
2017-03-01,
2017-02-01,
2017-01-01,
2016-12-01,
2016-11-01,
2016-10-01,
2016-09-01,
2016-08-01,
2016-07-01,
2016-06-01,
2016-05-01,
2016-04-01,
2016-03-01,
2016-02-01,
2016-01-01,
2015-12-01,
2015-11-01,
2015-10-01,
2015-09-01,
2015-08-01,
2015-07-01,
2015-06-01,
2015-05-01,
2015-04-01,
2015-03-01,
2015-02-01,
2015-01-01,
2014-12-01,
2014-11-01,
2014-10-01,
2014-09-01,
2014-08-01,
2014-07-01,
2014-06-01,
2014-05-01,
2014-04-01,
2014-03-01,
2014-02-01,
2014-01-01,
2013-12-01,
2013-11-01,
2013-10-01,
2013-09-01,
2013-08-01,
2013-07-01,
2013-06-01,
2013-05-01,
2013-04-01,
2013-03-01,
2013-02-01,
2013-01-01,
2012-12-01,
2012-11-01,
2012-10-01,
2012-09-01,
2012-08-01,
2012-07-01,
2012-06-01,
2012-05-01,
2012-04-01,
2012-03-01,
2012-02-01,
2012-01-01,
2011-12-01,
2011-11-01,
2011-10-01,
2011-09-01,
2011-08-01,
2011-07-01,
2011-06-01,
2011-05-01,
2011-04-01,
2011-03-01,
2011-02-01,
2011-01-01,
2010-12-01,
2010-11-01,
2010-10-01,
2010-09-01,
2010-08-01,
2010-07-01,
2010-06-01,
2010-05-01,
2010-04-01,
2010-03-01,
2010-02-01,
2010-01-01,
2009-12-01,
2009-11-01,
2009-10-01,
2009-09-01,
2009-08-01,
2009-07-01,
2009-06-01,
2009-05-01,
2009-04-01,
2009-03-01,
2009-02-01,
2009-01-01,
2008-12-01,
2008-11-01,
2008-10-01,
2008-09-01,
2008-08-01,
2008-07-01,
2008-06-01,
2008-05-01,
2008-04-01,
2008-03-01,
2008-02-01,
2008-01-01,
2007-12-01,
2007-11-01,
2007-10-01,
2007-09-01,
2007-08-01,
2007-07-01,
2007-06-01,
2007-05-01,
2007-04-01,
2007-03-01,
2007-02-01,
2007-01-01,
2006-12-01,
2006-11-01,
2006-10-01,
2006-09-01,
2006-08-01,
2006-07-01,
2006-06-01,
2006-05-01,
2006-04-01,
2006-03-01,
2006-02-01,
2006-01-01,
2005-12-01,
2005-11-01,
2005-10-01,
2005-09-01,
2005-08-01,
2005-07-01,
2005-06-01,
2005-05-01,
2005-04-01,
2005-03-01,
2005-02-01,
2005-01-01,
2004-12-01,
2004-11-01,
2004-10-01,
2004-09-01,
2004-08-01,
2004-07-01,
2004-06-01,
2004-05-01,
2004-04-01,
2004-03-01,
2004-02-01,
2004-01-01,
2003-12-01,
2003-11-01,
2003-10-01,
2003-09-01,
2003-08-01,
2003-07-01,
2003-06-01,
2003-05-01,
2003-04-01,
2003-03-01,
2003-02-01,
2003-01-01,
2002-12-01,
2002-11-01,
2002-10-01,
2002-09-01,
2002-08-01,
2002-07-01,
2002-06-01,
2002-05-01,
2002-04-01,
2002-03-01,
2002-02-01,
2002-01-01,
2001-12-01,
2001-11-01,
2001-10-01,
2001-09-01,
2001-08-01,
2001-07-01,
2001-06-01,
2001-05-01,
2001-04-01,
2001-03-01,
2001-02-01,
2001-01-01)
date



open <- c(1775.0open <- c(1775.0open <- c(1775.0,1878.9,1884.1,1961.7,1984.3,1793.6,1740.4,1686.6,1592.9,1586.5,1592.9,1518.1,1463.9,1511.0,1468.7,1527.8,1411.3,1386.6,1307.0,1278.7,1291.8,
1312.2,
1320.3,
1286.0,
1222.5,
1215.4,
1191.6,
1193.8,
1222.9,
1298.4,
1298.6,
1313.2,
1325.2,
1313.4,
1343.8,
1302.3,
1274.1,
1272.2,
1280.0,
1320.2,
1268.4,
1236.0,
1268.0,
1268.7,
1247.5,
1247.8,
1211.9,
1151.6,
1172.7,
1279.3,
1313.5,
1305.3,
1348.8,
1324.5,
1215.7,
1293.3,
1232.3,
1240.5,
1116.7,
1063.4,
1064.6,
1142.1,
1115.2,
1133.5,
1095.5,
1173.1,
1190.6,
1178.1,
1182.9,
1213.1,
1283.9,
1184.0,
1166.4,
1166.4,
1207.7,
1284.5,
1284.1,
1326.7,
1249.6,
1288.7,
1285.1,
1335.9,
1242.4,
1204.3,
1251.2,
1325.7,
1328.0,
1395.2,
1323.0,
1234.7,
1389.1,
1475.8,
1596.8,
1579.6,
1663.9,
1672.8,
1714.9,
1722.3,
1766.0,
1689.1,
1613.4,
1597.5,
1560.0,
1665.0,
1668.8,
1688.6,
1738.2,
1565.0,
1747.0,
1706.7,
1627.8,
1825.8,
1623.0,
1502.2,
1535.7,
1564.6,
1433.4,
1415.3,
1333.1,
1415.6,
1386.8,
1360.3,
1309.0,
1246.3,
1181.7,
1206.3,
1224.8,
1178.6,
1125.1,
1119.3,
1081.0,
1117.7,
1181.0,
1045.5,
1007.4,
954.2,
952.6,
929.3,
978.8,
884.0,
918.6,
940.6,
927.8,
881.5,
817.2,
728.8,
878.0,
829.9,
904.9,
943.6,
886.5,
855.0,
915.0,
984.2,
924.8,
848.7,
783.9,
785.3,
745.1,
672.5,
663.2,
649.6,
661.5,
673.7,
663.8,
673.0,
652.9,
635.2,
645.7,
612.5,
598.2,
624.4,
635.4,
631.0,
642.8,
658.0,
582.0,
562.5,
570.8,
645.1,
494.2,
463.0,
467.8,
438.5,
430.0,
427.8,
416.4,
434.7,
428.3,
435.0,
422.2,
431.0,
451.6,
427.3,
419.1,
407.3,
391.2,
396.0,
393.9,
387.0,
427.2,
396.4,
402.3,
415.7,
397.2,
382.8,
385.5,
375.0,
354.1,
351.4,
364.9,
339.0,
336.0,
349.2,
368.0,
346.1,
317.9,
318.8,
322.0,
312.5,
303.2,
314.0,
326.6,
309.1,
302.6,
298.0,
282.3,
278.9,
273.5,
279.7,
291.8,
271.6,
266.2,
270.6,
264.7,
264.4,
257.8,
265.2,
266.3,
268.4
)
open

# 2001-01-01부터 2020-12-01까지의 월별 날짜 생성 후 역순 정렬
date <- seq(from = as.Date("2001-01-01"), to = as.Date("2020-12-01"), by = "months")
date <- rev(date)  # 역순으로 정렬

# 결과 확인
print(date)
gold <- data.frame(date,open)
gold

# 시계열 그래프 그리기
ggplot(gold, aes(x = date, y = open)) +
  geom_line(color = "blue", size = 1) +  # 선 그래프 추가
  labs(title = "Gold Prices from January 2001 to December 2020",  # 그래프 제목
       x = "Date",                                                   # x축 레이블
       y = "Open Price") +                                         # y축 레이블
  theme_minimal() +                                              # 미니멀 테마 적용
  scale_x_date(date_labels = "%Y-%m",                           # x축 날짜 형식 설정
               date_breaks = "1 year")                        # x축 눈금 간격 설정


## 월별 증가율 비고 
# 월별 증가율 계산
gold <- gold %>%
  arrange(date) %>%
  mutate(previous_price = lag(open),  # 이전 월 가격
         price_change = open - previous_price,  # 가격 변화
         percentage_change = (price_change / previous_price) * 100)  # 증가율 계산
# 12월 데이터 추출
december_changes <- gold[format(gold$date, "%m") == "12", ]

# 12월 증가율 확인
print(december_changes[, c("date", "open", "percentage_change")])

# 월별 증가율 시각화
ggplot(gold, aes(x = date, y = percentage_change)) +
  geom_line(color = "blue", size = 1) +  # 선 그래프 추가
  geom_point(data = december_changes, color = "red", size = 2) +  # 12월 데이터 강조
  labs(title = "Monthly Percentage Change in Gold Prices (2001-2020)",  # 그래프 제목
       x = "Date",                                                         # x축 레이블
       y = "Percentage Change (%)") +                                     # y축 레이블
  theme_minimal() +                                                      # 미니멀 테마 적용
  scale_x_date(date_labels = "%Y-%m",                                   # x축 날짜 형식 설정
               date_breaks = "1 year")                                 # x축 눈금 간격 설정

# 12월 데이터 추출
december_changes <- gold[format(gold$date, "%m") == "12", ]

# 1월 데이터 추출
january_changes <- gold[format(gold$date, "%m") == "01", ]

# 12월과 1월의 증가율 시각화
ggplot(gold, aes(x = date, y = percentage_change)) +
  geom_line(color = "blue", size = 1) +  # 전체 증가율 선 그래프 추가
  geom_point(data = december_changes, color = "red", size = 2) +  # 12월 데이터 강조
  geom_point(data = january_changes, color = "orange", size = 2) +  # 1월 데이터 강조
  labs(title = "Monthly Percentage Change in Gold Prices (2001-2020)",  # 그래프 제목
       x = "Date",                                                         # x축 레이블
       y = "Percentage Change (%)") +                                     # y축 레이블
  theme_minimal() +                                                      # 미니멀 테마 적용
  scale_x_date(date_labels = "%Y-%m",                                   # x축 날짜 형식 설정
               date_breaks = "1 year")                                 # x축 눈금 간격 설정
december_positive_count <- nrow(december_changes[december_changes$percentage_change > 0, ])
december_negative_count <- nrow(december_changes[december_changes$percentage_change < 0, ])

# 결과 출력
cat("12월 데이터 양수 개수:", december_positive_count, "\n")
cat("12월 데이터 음수 개수:", december_negative_count, "\n")

# 1월 데이터의 양수 및 음수 개수 확인
january_positive_count <- nrow(january_changes[january_changes$percentage_change > 0, ])
january_negative_count <- nrow(january_changes[january_changes$percentage_change < 0, ])

# 결과 출력
cat("1월 데이터 양수 개수:", january_positive_count, "\n")
cat("1월 데이터 음수 개수:", january_negative_count, "\n")

dddd
-----
d
# 이동 평균 데이터 추출 및 날짜 범위 제한
moving_avg_data <- data3 %>%
  filter(sales_month >= as.Date("2001-01-01") & sales_month <= as.Date("2020-12-01")) %>%
  select(sales_month, moving_avg)

combined_data <- merge(gold, moving_avg_data, by.x = "date", by.y = "sales_month", all = TRUE)

# 상관관계 분석
correlation <- cor(combined_data$open, combined_data$moving_avg, use = "complete.obs")

# 결과 출력
print(paste("상관계수:", correlation))

# 시각화
ggplot(combined_data, aes(x = date)) +
  geom_line(aes(y = open, color = "Gold Prices"), size = 1) +  # 금 가격 선 추가
  geom_line(aes(y = moving_avg, color = "Moving Average"), size = 1) +  # 이동 평균 선 추가
  labs(title = "Gold Prices and Moving Average (2001-2020)",  # 그래프 제목
       x = "Date",                                               # x축 레이블
       y = "Price / Moving Average") +                         # y축 레이블
  scale_color_manual(values = c("Gold Prices" = "green", "Moving Average" = "blue")) +  # 색상 설정
  theme_minimal() +                                          # 미니멀 테마 적용
  theme(legend.title = element_blank())                      # 범례 제목 제거


correlation_test <- cor.test(combined_data$open, combined_data$moving_avg, method = "pearson")

# 결과 출력
print(correlation_test)

alpha <- 0.05
if (correlation_test$p.value < alpha) {
  cat("귀무가설을 기각합니다: moving_average와 gold 간의 상관관계가 있습니다.\n")
} else {
  cat("귀무가설을 채택합니다: moving_average와 gold 간의 상관관계가 없습니다.\n")
}
