------------------------------------------------------------------------------------
-----------------------------| 행 중복해서 나오는 문제 해결 |----------------------------
------------------------------------------------------------------------------------
-- 테이블을 생성합니다.
DROP table if exists retail_sales;
CREATE table retail_sales
(
sales_month date
,naics_code varchar
,kind_of_business varchar
,reason_for_null varchar
,sales decimal
)
;

-- CSV 파일에서 데이터를 읽어 테이블에 채워넣습니다.
-- 본인이 다운로드 한 CSV 파일의 경로로 수정하세요
COPY retail_sales FROM 'C:\Users\dndma\Downloads\us_retail_sales.csv' DELIMITER ',' CSV HEADER;



------------------------------------------------------------------------------------
-----------------------------------| [3주차] 시계열 2 |-------------------------------
------------------------------------------------------------------------------------
---3.4.1 시간 윈도우 롤링 계산
--12개월 기준 이동평균 매출 계산
SELECT a.sales_month
,a.sales
,b.sales_month as rolling_sales_month
,b.sales as rolling_sales
FROM retail_sales a
JOIN retail_sales b on a.kind_of_business = b.kind_of_business
	and b.sales_month between a.sales_month - interval '11 months'
	and a.sales_month
	and b.kind_of_business = 'Women''s clothing stores'
WHERE a.kind_of_business = 'Women''s clothing stores'
and a.sales_month = '2019-12-01'
;

-- a 테이블 : 현재 기준이 되는 월
-- b 테이블 : a 테이블을 기준으로 과거 11개월간 데이터를 가져오는 역할
--2019년 12월의 매출을 기준으로 과거 11개월의 데이터 가져오기 (** 총 12개월 불러오는거임, 만약 12 months 로 하면 13개월 불러옴)

-- avg 집계 함수를 활용한 평균 구하기
SELECT a.sales_month
,a.sales
,avg(b.sales) as moving_avg
,count(b.sales) as records_count
FROM retail_sales a
JOIN retail_sales b on a.kind_of_business = b.kind_of_business
	and b.sales_month between a.sales_month - interval '11 months'
	and a.sales_month
	and b.kind_of_business = 'Women''s clothing stores'
WHERE a.kind_of_business = 'Women''s clothing stores'
and a.sales_month >= '1993-01-01'
GROUP BY 1,2
ORDER BY 1
;
-- avg(b.sales) as moving_avg : 현재 월 (a.sales_month)을 기준으로 과거 11개월 동안의 평균 매출
-- count(b.sales) AS recodes_count : 현재 월(a.sales_month)을 기준으로 과거 11개월 동안의 데이터 개수_ 각 행이 12개의 레코드의 평균을 계산한것이 맞는지 확인하기 위함
--									 (즉, 이동 평균을 계산할 때 포함된 데이터 개수)
-- kind_of_business = 'Women''s clothing stores'필터링을 각 테이블에 모두 적용할 필요는 없음 


---윈도우함수(PARTITION BY, Frame 절 등)을 활용한 쿼리 짜기
SELECT sales_month
,avg(sales) over (order by sales_month
				   rows between 11 preceding and current row
				   ) as moving_avg
,count(sales) over (order by sales_month
					rows between 11 preceding and current row
					) as recodes_count
FROM retail_sales
WHERE kind_of_business = 'Women''s clothing stores'
;



--3.4.2 희소 데이터와 시간 윈도우 롤링 p.146 (왜 안되지?)
SELECT a.date, b.sales_month, b.sales
FROM date_dim AS a
JOIN 
(
	SELECT sales_month, sales
	FROM retail_sales
	WHERE kind_of_business = 'Women''s clothing stores'
		and date_part('month',sales_month) in (1,7)
) b on b.sales_month between a.date - interval '11 months' and a.date
WHERE a.date = a.first_day_of_month
and a.date between '1993-01-01'and '2020-12-01'
ORDER BY 1,2
;


--3.4.3 누적값 계산 (YTD 예시)
--sum 집계 함수를 활용한 YTD 
SELECT sales_month,sales
,sum(sales) over (partition by date_part('year',sales_month)
					order by sales_month
					)as sales_ytd
FROM retail_sales
WHERE kind_of_business = 'Women''s clothing stores'
;

-- self-join을 활용한 YTD
FROM retail_sales a
JOIN retail_sales b on
	date_part('year',a.sales_month) = date_part('year',b.sales_month)
	and b.sales_month <= a.sales_month
	and b.kind_of_business = 'Women''s clothing stores'
WHERE a.kind_of_business = 'Women''s clothing stores'
GROUP BY 1,2
;


---3.5.1 구간 비교 : YoY 와 MoM
-- 소매업 매출 데이터셋에서 전년 대비 증감률과 전월 대비 증감률 구하기 
SELECT kind_of_business, sales_month, sales
,lag(sales_month) over (partition by kind_of_business
						order by sales_month
						)as prev_month
,lag(sales) over (partition by kind_of_business
						order by sales_month
						) as prev_month_sales
FROM retail_sales
WHERE kind_of_business = 'Book stores'
;


-- 이전 값 대비 비율 변화 
SELECT kind_of_business, sales_month,sales
,(sales/lag(sales) over (partition by kind_of_business
						order by sales_month) -1 )* 100 as pct_growth_from_preivous
FROM retail_sales
WHERE kind_of_business ='Book stores'


--전년 대비 증감률 (서점업에 대해서만 하므로 partition by 생략한 버전)
SELECT sales_year,yearly_sales
,lag(yearly_sales) over (order by sales_year) as prev_year_sales
,(yearly_sales / lag(yearly_sales) over (order by sales_year)
-1) * 100 as pct_growth_from_previous
FROM 
(
	SELECT date_part('year',sales_month) as sales_year
	,sum(sales) as yearly_sales
	FROM retail_sales
	WHERE kind_of_business = 'Book stores'
	GROUP BY 1
) a 
;

----3.5.2 구간비교 : 작년과 올해 비교
--빌드업 1)date_part()함수 정수값 반환 확인 
SELECT sales_month,date_part('month',sales_month) --> date_part() --> 정수값으로 반환함
FROM retail_sales
WHERE kind_of_business = 'Book stores'
;

--빌드업 2) 서브쿼리 출력 결과 확인 
SELECT sales_month, sales
,lag(sales_month) over (partition by date_part('month',sales_month)
						order by sales_month
						) as prev_year_month
,lag(sales) over (partition by date_part('month',sales_month)
					order by sales_month
					) as prev_year_sales
FROM retail_sales
WHERE kind_of_business = 'Book stores'

-- 최종 쿼리 : 전년 대비 매출의 절댓값 차이와 비율 차이
SELECT sales_month, sales
,sales - lag(sales) over (partition by date_part('month',sales_month)
						   order by sales_month
						   ) as absolute_diff
,(sales/lag(sales) over (partition by date_part('month',sales_month)
						  order by sales_month)
-1) * 100 as pct_diff
FROM retail_sales
WHERE kind_of_business ='Book stores'
;

-- 서점업 월간 매출 (1992-1994년)
SELECT date_part('month',sales_month) as month_number
,to_char(sales_month,'Month')as month_name
,max(case when date_part('year',sales_month)=1992 then sales end)
as sales_1992
,max(case when date_part('year',sales_month)=1993 then sales end)
as sales_1993
,max(case when date_part('year',sales_month)=1994 then sales end)
as sales_1994
FROM retail_sales
WHERE kind_of_business = 'Book stores'
	and sales_month between '1992-01-01'and '1994-12-01'
GROUP BY 1,2
;


---3.5.3 다중 구간 비교
--현재 월의 매출을 최근 3년간의 동월 데이터와 비교
SELECT sales_month,sales
,lag(sales,1) over (partition by date_part('month',sales_month)
					 order by sales_month
					 )as prev_sales1
,lag(sales,2)over (partition by date_part('month',sales_month)
					order by sales_month
					)as prev_sales2
,lag(sales,3)over (partition by date_part('month',sales_month)
					order by sales_month
					)as prev_sales3					
FROM retail_sales
WHERE kind_of_business = 'Book stores'
;

--지난 3년간의 월매출 평균 대비 현재 월 매출 비율 : lag 함수와 offset 활용
SELECT sales_month,sales
,sales / ((prev_sales_1 + prev_sales_2 + prev_sales_3)/3)*100
as pct_of_3_prev
FROM
(
	SELECT sales_month,sales
	,lag(sales,1) over (partition by date_part('month',sales_month)
						 order by sales_month
						 )as prev_sales_1
	,lag(sales,2)over (partition by date_part('month',sales_month)
						order by sales_month
						)as prev_sales_2
	,lag(sales,3)over (partition by date_part('month',sales_month)
						order by sales_month
						)as prev_sales_3					
	FROM retail_sales
	WHERE kind_of_business = 'Book stores'
)a
;

-- 지난 3년간 월매출 평균 대비 현재 월 매출 비율 : FRAME 절 활용
SELECT sales_month,sales
,sales / avg(sales) over (partition by date_part('month',sales_month)
						  order by sales_month
						  rows between 3 preceding and 1 preceding
						  ) * 100 as pct_of_prev_3
FROM retail_sales
WHERE kind_of_business = 'Book stores'
;

'''
추가설명: lag,offset을 사용할때는 맨 위 3행이 null값이 나왔는데 왜 frame을 썻을때는 안나오지?
최근 3년값이 모두 null값이 아닌 경우에만 평균을 정상적으로 계산하므로 1993년,1994년의 pct_of_3_prev값이 모두 null로 출력됨
'''




------------------------------------------------------------------------------------
-----------------------------|   스터디 분석 자료 쿼리   |-----------------------------
------------------------------------------------------------------------------------
-- 금융위기 동안 가장 큰 타격은 받은 업종 (평균매출감소율)
WITH pre_crisis AS (
    SELECT kind_of_business, AVG(sales) AS avg_sales_before
    FROM retail_sales
    WHERE sales_month BETWEEN '2006-01-01' AND '2007-12-31'
    GROUP BY kind_of_business
),
during_crisis AS (
    SELECT kind_of_business, AVG(sales) AS avg_sales_during
    FROM retail_sales
    WHERE sales_month BETWEEN '2008-01-01' AND '2010-12-31'
    GROUP BY kind_of_business
)
SELECT 
    p.kind_of_business,
    p.avg_sales_before,
    d.avg_sales_during,
    ROUND(((p.avg_sales_before - d.avg_sales_during) / p.avg_sales_before) * 100, 2) AS decline_percentage
FROM pre_crisis p
JOIN during_crisis d ON p.kind_of_business = d.kind_of_business
ORDER BY decline_percentage DESC;



--2006-2007 평균 매출과 동일하거나, 더 높은 값을 출력하는 쿼리,but 출력되는 행 0
WITH avg_sales_before AS (
    SELECT AVG(sales) AS avg_sales
    FROM retail_sales
    WHERE kind_of_business = 'Floor covering stores'
      AND sales_month BETWEEN '2006-01-01' AND '2007-12-31'
)
SELECT kind_of_business, sales_month, sales
FROM retail_sales
WHERE kind_of_business = 'Floor covering stores'
  AND sales_month >= '2008-01-01'  -- 2008년 1월 1일 이후
  AND sales >= (SELECT avg_sales FROM avg_sales_before)  -- 2006-2007년 평균 매출 이상
ORDER BY sales_month
LIMIT 1;  -- 첫 번째 회복 시점만 반환



---지난 4년간 월 매출 평균 대비 현재 월 매출 비율 (바닥재)
SELECT sales_month,sales
,sales / avg(sales) over (partition by date_part('month',sales_month)
						  order by sales_month
						  rows between 4 preceding and 1 preceding
						  ) * 100 as pct_of_prev_4
FROM retail_sales
WHERE kind_of_business = 'Floor covering stores'
;


-- 2006-2007 평균 매출 확인
SELECT AVG(sales) AS avg_sales
FROM retail_sales
WHERE kind_of_business = 'Floor covering stores'
  AND sales_month BETWEEN '2006-01-01' AND '2007-12-31';




------------------------------------------------------------------------------------
---------------------------------|  쿼리 문제 -1 |-----------------------------------
'''"Motor vehicle and parts dealers"  업종에 대해서,  월별 매출의 **3 개월 이동 평균(rolling
average)**을 계산하세요. 단,  매출이 존재하는 행만 계산에 포함하고,  결과에는 sales_month,   sales,   3_month_avg 를
포함하세요'''
------------------------------------------------------------------------------------

SELECT a.sales_month
,a.sales
,avg(b.sales) as moving_avg
,count(b.sales) as records_count
FROM retail_sales a
JOIN retail_sales b on a.kind_of_business = b.kind_of_business
	and b.sales_month between a.sales_month - interval '2 months'
	and a.sales_month
	and b.kind_of_business = 'Motor vehicle and parts dealers'
WHERE a.kind_of_business = 'Motor vehicle and parts dealers'
and a.sales_month >= '1992-01-01'
GROUP BY 1,2
ORDER BY 1
;



------------------------------------------------------------------------------------
---------------------------------|  쿼리 문제 -2 |-----------------------------------
'''"Used car dealers" 업종에 대해서, **동월 대비 매출 변화율 (YoY, Year-over-Year growth)**을
계산하세요.
sales_month 는  YYYY-MM 형식으로   비교하며,  결과에는  sales_month,   sales,
prev_year_sales, yoy_growth(%)를 포함하세요'''
------------------------------------------------------------------------------------
SELECT sales_month, sales
,lag(sales,1) over (partition by date_part('month',sales_month)
					order by sales_month
					)as prev_year_sales
,sales / avg(sales) over (partition by date_part('month',sales_month)
						  order by sales_month 
						  rows between 1 preceding and 1 preceding 
						  ) *100 -100 as yoy_growth 
FROM retail_sales
WHERE kind_of_business = 'Used car dealers';
