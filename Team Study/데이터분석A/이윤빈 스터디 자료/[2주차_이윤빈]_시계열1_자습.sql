---2주차 스터디_시계열분석1_혼공내용

-- 매출 구분 확인하기
SELECT distinct(kind_of_business)
FROM retail_sales
ORDER BY 1

-- '신발가게 매출을 보면 경제 흐름을 알 수 있다'라는 말이 진실일까?
-- 신발가게 매출
SELECT date_part('year',sales_month) as  sales_year,kind_of_business
,sum(sales) as sales
FROM retail_sales
WHERE kind_of_business in ('Shoe stores')
GROUP BY 1,2
ORDER BY 1

-- 화장품 및 개인 관리 용품 관련 매출
SELECT date_part('year',sales_month) as  sales_year,kind_of_business
,sum(sales) as sales
FROM retail_sales
WHERE kind_of_business in ('Health and personal care stores','Pharmacies and drug stores')
GROUP BY 1,2
ORDER BY 2

--신발 가게 매출 증가 추이 확인 쿼리
WITH sales_data as (
	SELECT date_part('year',sales_month) as sales_year,SUM(sales) as total_sales
	FROM retail_sales
	WHERE kind_of_business = 'Shoe stores'
	GROUP BY sales_year
)
SELECT sales_year, total_sales,
	LAG(total_sales) OVER (ORDER BY sales_year) as prev_year_sales,
	ROUND((total_sales - LAG(total_sales) OVER (ORDER BY sales_year)) /
	NULLIF(LAG(total_sales) OVER (ORDER BY sales_year),0)* 100,1) as growth_rate
FROM sales_data
ORDER BY sales_year;
--->LAG 쿼리문: 전월 대비 증감률 계산
--LAG(total_sales) over (ORDER BY sales_month) > 이전 달 매출값 가져옴
--(total_sales - prev_month_sales)/prev_month_sales * 100 > 성장률 계싼
--NULLIF(prev_month_sales,0) > 0으로 나누는 오류 방지 


--액세서리 및 패션 관련 매출 증가 추이 확인
WITH sales_data as (
	SELECT date_part('year',sales_month) as sales_year,SUM(sales) as total_sales
	FROM retail_sales
	WHERE kind_of_business in('Clothing stores')
	GROUP BY sales_year
)
SELECT sales_year, total_sales,
	LAG(total_sales) OVER (ORDER BY sales_year) as prev_year_sales,
	ROUND((total_sales - LAG(total_sales) OVER (ORDER BY sales_year)) /
	NULLIF(LAG(total_sales) OVER (ORDER BY sales_year),0)* 100,1) as growth_rate
FROM sales_data
ORDER BY sales_year;

--가정 및 인테리어 소품 관련 매출 증가 추이 확인
WITH sales_data as (
	SELECT date_part('year',sales_month) as sales_year,SUM(sales) as total_sales
	FROM retail_sales
	WHERE kind_of_business in('Hobby, toy, and game stores')
	GROUP BY sales_year
)
SELECT sales_year, total_sales,
	LAG(total_sales) OVER (ORDER BY sales_year) as prev_year_sales,
	ROUND((total_sales - LAG(total_sales) OVER (ORDER BY sales_year)) /
	NULLIF(LAG(total_sales) OVER (ORDER BY sales_year),0)* 100,1) as growth_rate
FROM sales_data
ORDER BY sales_year;

--- 연관된 시장의 매출 증가 추이(2018~2020년) 확인
WITH sales_data AS (
    SELECT 
        date_part('year', sales_month) AS sales_year, 
        kind_of_business,  
        SUM(sales) AS total_sales
    FROM retail_sales
    WHERE 
        kind_of_business IN ('Hobby, toy, and game stores', 'Health and personal care stores','Clothing stores','Shoe stores','Jewelry stores')
        AND date_part('year', sales_month) BETWEEN 2015 AND 2020 -- 연도 필터링
    GROUP BY sales_year, kind_of_business  
)
SELECT 
    sales_year, 
    kind_of_business,
    total_sales, 
    LAG(total_sales) OVER (PARTITION BY kind_of_business ORDER BY sales_year) AS prev_year_sales, 
    ROUND(
        (total_sales - LAG(total_sales) OVER (PARTITION BY kind_of_business ORDER BY sales_year)) / 
        NULLIF(LAG(total_sales) OVER (PARTITION BY kind_of_business ORDER BY sales_year), 0) * 100, 
        1
    ) AS growth_rate
FROM sales_data
ORDER BY kind_of_business, sales_year;

















-- 코로나 시대때 주류 소비량 분석

--주류상점 매출
SELECT date_part('year',sales_month) as  sales_year,kind_of_business
,sum(sales) as sales
FROM retail_sales
WHERE kind_of_business in ('Beer, wine, and liquor stores')
GROUP BY 1,2
ORDER BY 1

--주점 매출
SELECT date_part('year',sales_month) as  sales_year,kind_of_business
,sum(sales) as sales
FROM retail_sales
WHERE kind_of_business in ('Drinking places')
GROUP BY 1,2
ORDER BY 1



