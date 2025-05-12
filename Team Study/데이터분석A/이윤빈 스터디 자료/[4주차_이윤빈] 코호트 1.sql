--------------------------------------------------------------------------------
-------------------------| 4주차 스터디 - 코호트 1 |-----------------------------
--------------------------------------------------------------------------------

---4.3.1 기본 리텐션 계산하기
--의원별 가장 첫 임기 시작일 ( 코호트 기준점 )
SELECT id_bioguide
,min(term_start) as first_term
FROM legislators_terms
GROUP BY 1 ;

-- 구간별 재임 중인 의원의 수 계산 
-- 같은 의원(id_bioguide)에 대해 모든 임기정보를 가져와서 join으로 연결 -> 얼마나 오랫동안 활동했는지 확인하기 위함
SELECT date_part('year',age(b.term_start,a.first_term)) as period
,count(distinct a.id_bioguide) as cohort_retained
FROM
(
SELECT id_bioguide, min(term_start) as first_term
FROM legislators_terms
GROUP BY 1
)a
JOIN legislators_terms b on a.id_bioguide = b.id_bioguide
GROUP BY 1
;



-- 전체대비 남아있는 의원 비율 계산
SELECT period
,first_value(cohort_retained) over (order by period) as cohort_size
,cohort_retained
,cohort_retained * 1.0/
first_value(cohort_retained) over (order by period) as pct_retained
FROM
	(
	SELECT date_part('year',age(b.term_start,a.first_term)) as period
	,count(distinct a.id_bioguide) as cohort_retained
	FROM 
	(
		SELECT id_bioguide,min(term_start) as first_term
		FROM legislators_terms
		GROUP BY 1
	) a
	JOIN legislators_terms b on a.id_bioguide = b.id_bioguide
	GROUP BY 1
	)aa
	;

--리텐션 분석 결과 표형식으로 정리해 출력 
SELECT cohort_size
,max(case when period=0 then pct_retained end ) as yr0
,max(case when period=1 then pct_retained end ) as yr1
,max(case when period=2 then pct_retained end ) as yr2
,max(case when period=3 then pct_retained end ) as yr3
,max(case when period=4 then pct_retained end ) as yr4
FROM
(
	SELECT period
	,first_value(cohort_retained) over (order by period)
	as cohort_size
	,cohort_retained * 1.0
	/first_value(cohort_retained) over (order by period)
	as pct_retained
	FROM
	(
	SELECT
	date_part('year',age(b.term_start, a.first_term))as period
	,count(distinct a.id_bioguide) as cohort_retained
	FROM(
		SELECT id_bioguide, min(term_start) as first_term
		FROM legislators_terms
		GROUP BY 1
	)a
	JOIN legislators_terms b on a.id_bioguide = b.id_bioguide
	GROUP BY 1
	)aa
)aaa
GROUP BY 1;


---4.3.2 시계열을 조절해 리텐션 정확도 향상하기

--서브쿼리 : first_term 값 반환
-- legislators_terms 테이블에 join하여 각 의원의 임기별 시작날짜 term_start와 종료날짜 term_end 값 가져오기\
-- 날짜차원 date_dim 테이블에 다시 join수행하여 term_start와 term_end 사이 날짜 중 12월 31일이 있는지 확인
--period는 age 함수를 활용해 date_dim 사이에 반환했던 날짜와 first_term 사이의 연도값 계산
SELECT a.id_bioguide,a.first_term
,b.term_start,b.term_end
,c.date
,date_part('year',age(c.date,a.first_term))as period
FROM
(
SELECT id_bioguide, min(term_start) as first_term
FROM legislators_terms
GROUP BY 1
)a
JOIN legislators_terms b on a.id_bioguide = b.id_bioguide
LEFT JOIN date_dim c on c.date between b.term_start and b.term_end
and c.month_name = 'December' and c.day_of_month = 31
;

--dim 사용 불가한 경우. 
-- 날짜 차원 테이블을 반환하는 서브 쿼리. (1770년 12월 31일부터 2020년 12월 31일까지 1년 주기의 dim 만듦)
SELECT generate_series :: date as date
FROM generate_series('1770-12-31','2020-12-31',interval '1 year')

--데이터셋에서 필요한 날짜 차원 테이블 생성 (테이블에서 필요한 연도 값만 가져온뒤, make_date 함수로 12월 31일 날짜를 만들어 각 연도 값에 이어붙이면 연도별 12월 31일 날짜가 생성됨)
SELECT distinct make_date(date_part('year',term_start)::int,12,31)
FROM legislators_terms;


-- 재임기간 차이(2년/6년)를 고려한 재임 연도 구간으로 재임 계산
SELECT 
coalesce(date_part('year',age(c.date,a.first_term)),0) as period
,count(distinct a.id_bioguide) as cohort_retained
FROM
(
SELECT id_bioguide, min(term_start) as first_term
FROM legislators_terms
GROUP BY 1
)a
JOIN legislators_terms b on a.id_bioguide= b.id_bioguide
LEFT JOIN date_dim c on c.date between b.term_start and b.term_end
and c.month_name = 'December' and c.day_of_month = 31
GROUP BY 1
;


-- 재임기간 차이를 고려한 리텐션 율 계산
SELECT period
,first_value(cohort_retained) over (order by period) as cohort_size
,cohort_retained
,cohort_retained *1.0/
first_value(cohort_retained) over (order by period) as pct_retained
FROM
	(
	SELECT coalesce(date_part('year',age(c.date,a.first_term)),0) as period
	,count(distinct a.id_bioguide) as cohort_retained
	--age(c.date,a.first_term) : 두 날짜의 차이 계산
	-- date_part('year',age(...)) : 계산한 날짜차이에서 연도만 추출
	-- coalesce(date_part(...)) : 추출한 연도가 null이면 0값으로 대체
	--  최종 결과 값을 period라고 호칭하고 이를 선택
	--  의원별 처음 임기 시작한 날짜 저장한 테이블 a에 각 의원수를 세고 cohort_retained라고 호칭, 이를 선택
	FROM
	(
		SELECT id_bioguide,min(term_start) as first_term
		FROM legislators_terms
		GROUP BY 1 
		--의원별 처음 시작한 임기날짜를 first_term으로 저장, 이를 a 테이블로 지정
	)a
	JOIN legislators_terms b on a.id_bioguide = b.id_bioguide
	LEFT JOIN date_dim c on c.date between b.term_start and b.term_end
	and c.month_name = 'December' and c.day_of_month = 31
	GROUP BY 1
		--의원기간 테이블 b로 칭하고, b 테이블 ㅁ 테이블과 조인
		--의원기간 테이블 b의 임기시작날짜와 종료날짜, 
		-- date_dim (c라고 호칭) 테이블에 달이름이 12월이고 날짜가 31일일인것으로만 date_dim(c라고 호칭)에 조인시킴
	)aa
	;

--  종료날짜 구하기 with interval 함수
SELECT a.id_bioguide,a.first_term
,b.term_start
,case when b.term_type = 'rep'then b.term_start + interval '2 years'
	  when b.term_type = 'sen'then b.term_start + interval '6 years'
	  end as term_end
FROM
	(
	SELECT id_bioguide,min(term_start) as first_term
	FROM legislators_terms
	GROUP BY 1
	)a
JOIN legislators_terms b on a.id_bioguide = b.id_bioguide;

-- 종료날짜 구하기 with lead 함수 사용 
SELECT a.id_bioguide, a.first_term
,b.term_start
,lead(b.term_start) over (partition by a.id_bioguide
							order by b.term_start)
- interval '1 day'as term_end 
FROM
(
	SELECT id_bioguide, min(term_start) as first_term
	FROM legislators_terms
	GROUP BY 1
) a
JOIN legislators_terms b on a.id_bioguide = b.id_bioguide
ORDER BY 1,3
;


-- 4.3.3 시계열 데이터에서 코호트 분석하기

-- 연도 기준 코호트 계산
SELECT date_part('year',a.first_term) as first_year
,coalesce(date_part('year',age(c.date,a.first_term)),0) as period
FROM
(
SELECT id_bioguide, min(term_start) as first_term
FROM legislators_terms
GROUP BY 1
)a
JOIN legislators_terms b on a.id_bioguide = b.id_bioguide
LEFT JOIN date_dim c on c.date between b.term_start and b.term_end
and c.month_name = 'December' and c.day_of_month = 31
GROUP BY 1,2
;

--
SELECT first_year
,period
,first_value(cohort_retained) over (partition by first_year
									order by period) as cohort_size
,cohort_retained
,cohort_retained *1.0/
first_value(cohort_retained) over (partition by first_year
								order by period) as pct_retained
--각 first_year 마다 처음 인원수를(cohort_size) 저장하고, 현재 cohort_retained 수 나눠서 잔존율(pct_retained) 계산.

FROM
(
		SELECT date_part('year',a.first_term) as first_year
		,coalesce(date_part('year',age(c.date,a.first_term)),0) as period
		,count(distinct a.id_bioguide) as cohort_retained
		--a 테이블에 첫 임기 시작일에 연도를 first year 로 지칭
		--c.date 그해 12/31 기준으로 처음 임기 시작일과 차이
		
		FROM
			(
			SELECT id_bioguide, min(term_start) as first_term
			FROM legislators_terms
			GROUP BY 1
			)a
			-- 의원 ID 별로 가장 첫 임기 시작일 확인, 테이블 a로 지칭
	JOIN legislators_terms b on a.id_bioguide = b.id_bioguide
	LEFT JOIN date_dim c on c.date between b.term_start and b.term_end
	and c.month_name = 'December' and c.day_of_month = 31
	GROUP BY 1,2
	--lefislator_term 테이블을 b로 저장하고 a테이블에 의원 id 기준으로 조인 (같은 의원의 모든 임기와 조인하여 재직기간 정보 확보)
	-- date_dim을 c로 불러오고 테이블 b의 임기 시작일과 임기 종료일, 일자가 12월 31일인 날로 조인 
	--												  (매년 12월 31일 기준으로 재직중인지 확인하기 위함)
	-- 이를 aa 테이블로 호칭 
)aa
;


-- 세기별 코호트 계산
SELECT first_century
,period
,first_value(cohort_retained) over (partition by first_century
									order by period) as cohort_size
,cohort_retained
,cohort_retained *1.0/
first_value(cohort_retained) over (partition by first_century
									order by period) as pct_retained
FROM
	(
	SELECT date_part('century',a.first_term) as first_century
	,coalesce(date_part('year',age(c.date,a.first_term)),0) as period
	,count (distinct a.id_bioguide) as cohort_retained
	FROM
	(	
		SELECT id_bioguide,min(term_start) as first_term
		FROM legislators_terms
		GROUP BY 1
	)a
	JOIN legislators_terms b on a.id_bioguide = b.id_bioguide
	LEFT JOIN date_dim c on c.date between b.term_start and b.term_end
	and c.month_name = 'December' and c.day_of_month =31
	GROUP BY 1,2
	)aa
order by 1,2;


-- 의원별 첫 임기를 수행한 주 
SELECT distinct id_bioguide
,min(term_start) over (partition by id_bioguide) as first_term
,first_value(state) over (partition by id_bioguide
							order by term_start) as first_state
FROM legislators_terms;


-- 첫 임기를 수행한 주별 리텐션
SELECT first_state
,period
,first_value(cohort_retained) over (partition by first_state
									order by period) as cohort_size
,cohort_retained
,cohort_retained * 1.0/
first_value(cohort_retained) over (partition by first_state
									order by period) as pct_retained
FROM
(
	SELECT a.first_state
	,coalesce(date_part('year',age(c.date,a.first_term)),0) as period
	,count(distinct a.id_bioguide) as cohort_retained
	FROM
		(
		SELECT distinct id_bioguide
		,min(term_start) over (partition by id_bioguide) as first_term
		,first_value(state) over (partition by id_bioguide
									order by term_start) as first_state
		FROM legislators_terms
		) a
	JOIN legislators_terms b on a.id_bioguide = b.id_bioguide
	LEFT JOIN date_dim c on c.date between b.term_start and b.term_end
	and c.month_name = 'December' and c.day_of_month = 31
	GROUP BY 1,2
	) aa
ORDER BY 1,2
;


---4.3.4 다른 테이블에 저장된 속성으로 코호트 분석하기 
-- 의원의 성별에 따른 리텐션
SELECT d.gender
,coalesce (date_part('year',age(c.date,a.first_term)),0) as period
,count (distinct a.id_bioguide) as cohort_retained
FROM
	(	
	SELECT id_bioguide, min(term_start) as first_term
	FROM legislators_terms
	GROUP BY 1
	) a
JOIN legislators_terms b on a.id_bioguide = b.id_bioguide
LEFT JOIN date_dim c on c.date between b.term_start and b.term_end
and c.month_name='December' and c.day_of_month= 31
JOIN legislators d on a.id_bioguide = d.id_bioguide
--	legistlators 테이블에 있는 성별 속성을 사용하기 위해 d로 저장하여 불러오고 테이블 조인
GROUP BY 1,2
ORDER BY 2,1
;

-- 성별 차이에 따른 리텐션 비율
SELECT gender
,period
,first_value(cohort_retained) over (partition by gender
									order by period) as cohort_size
,cohort_retained
,cohort_retained *1.0/
first_value(cohort_retained) over (partition by gender
									order by period) as pct_retained
FROM
	(
	SELECT d.gender
	,coalesce (date_part('year',age(c.date,a.first_term)),0) as period
	,count (distinct a.id_bioguide) as cohort_retained
	FROM
		(	
		SELECT id_bioguide, min(term_start) as first_term
		FROM legislators_terms
		GROUP BY 1
		) a
	JOIN legislators_terms b on a.id_bioguide = b.id_bioguide
	LEFT JOIN date_dim c on c.date between b.term_start and b.term_end
	and c.month_name='December' and c.day_of_month= 31
	JOIN legislators d on a.id_bioguide = d.id_bioguide
	--	legistlators 테이블에 있는 성별 속성을 사용하기 위해 d로 저장하여 불러오고 테이블 조인
	GROUP BY 1,2
	)aa
ORDER BY 2,1;


--여성의원의 활동기간만을 분석
SELECT gender
,period
,first_value(cohort_retained) over (partition by gender
									order by period) as cohort_size
,cohort_retained
,cohort_retained * 1.0/
first_value(cohort_retained) over (partition by gender
									order by period)as pct_retained
FROM
	(
	SELECT d.gender
	,coalesce(date_part('year',age(c.date,a.first_term)),0) as period
	,count(distinct a.id_bioguide) as cohort_retained
	FROM
		(
		SELECT id_bioguide,min(term_start) as first_term
		FROM legislators_terms 
		GROUP BY 1
		)a
	JOIN legislators_terms b on a.id_bioguide = b.id_bioguide
	LEFT JOIN date_dim as c on c.date between b.term_start and b.term_end
	and c.month_name = 'December' and c.day_of_month = 31
	JOIN legislators d on a.id_bioguide = b.id_bioguide
	GROUP BY 1,2
	)aa
	order by 2,1
	;


---4.3.5 희소 코호트 다루기

--주별 임기를 수행한 성별에 따른 리텐션 비율
SELECT first_state,gender, period
,first_value (cohort_retained) over (partition by first_state, gender
										order by period) as cohort_size
,cohort_retained
,cohort_retained * 1.0
/ first_value(cohort_retained) over (partition by first_state, gender
										order by period)as pct_retained
FROM
	(
	SELECT a.first_state, d.gender
	,coalesce(date_part('year',age(c.date,a.first_term)),0) as period
	,count(distinct a.id_bioguide) as cohort_retained
	FROM
		(	
		SELECT distinct id_bioguide
		,min(term_start) over (partition by id_bioguide) as first_term
		,first_value(state) over (partition by id_bioguide
									order by term_start) as first_state
		FROM legislators_terms
		) a
	JOIN legislators_terms b on a.id_bioguide = b.id_bioguide
	LEFT JOIN date_dim c on c.date between b.term_start and b.term_end
	and c.month_name = 'December' and c.day_of_month = 31
	JOIN legislators d on a.id_bioguide = d.id_bioguide
	WHERE a.first_term between '1917-01-01'and '1999-12-31'
	GROUP BY 1,2,3
	)aa
	;


-- 희소데이터처리한 리텐션
SELECT aa.gender, aa.first_state, cc.period, aa.cohort_size
FROM
(
	SELECT b.gender, a.first_state
	,count(distinct a.id_bioguide) as cohort_size
	FROM
		(	
		SELECT distinct id_bioguide
		,min(term_start) over (partition by id_bioguide) as first_term
		,first_value(state) over (partition by id_bioguide
									order by term_start) as first_state
		FROM legislators_terms
		) a
	JOIN legislators b on a.id_bioguide = b.id_bioguide
	WHERE a.first_term between '1917-01-01' and '1999-12-31'
	GROUP by 1,2
)aa
JOIN
(
	SELECT generate_series as period
	FROM generate_series(0,20,1)
) cc on 1=1
order by 1,2,3
;


--  
SELECT aaa.gender, aaa.first_state, aaa.period, aaa.cohort_size
,coalesce(ddd.cohort_retained,0) as cohort_retained
,coalesce(ddd.cohort_retained,0) * 1.0 / aaa.cohort_size as pct_retained
FROM 
(
	SELECT aa.gender, aa.first_state, cc.period, aa.cohort_size
	FROM
	(
		SELECT b.gender, a.first_state
		,count(distinct a.id_bioguide) as cohort_size
		FROM
			(	
			SELECT distinct id_bioguide
			,min(term_start) over (partition by id_bioguide) as first_term
			,first_value(state) over (partition by id_bioguide
										order by term_start) as first_state
			FROM legislators_terms
			) a
		JOIN legislators b on a.id_bioguide = b.id_bioguide
		WHERE a.first_term between '1917-01-01' and '1999-12-31'
		GROUP by 1,2
	)aa
	JOIN
	(
		SELECT generate_series as period
		FROM generate_series(0,20,1)
	) cc on 1=1
)aaa
LEFT JOIN 
(
	SELECT d.first_state,g.gender
	,coalesce(date_part('year',age(f.date,d.first_term)),0) as period
	,count(distinct d.id_bioguide)as cohort_retained
	FROM
	(
		SELECT distinct id_bioguide
		,min(term_start) over (partition by id_bioguide)as first_term
		,first_value(state) over (partition by id_bioguide
									order by term_start) as first_state
		FROM legislators_terms							
	) d 
	JOIN legislators_terms e on d.id_bioguide = e.id_bioguide
	LEFT JOIN date_dim f on f.date between e.term_start and e.term_end
	and f.month_name = 'December' and f.day_of_month = 31
	JOIN legislators g on d.id_bioguide = g.id_bioguide
	WHERE d.first_term between '1917-01-01' and '1999-12-31'
	GROUP BY 1,2,3
) ddd on aaa.gender = ddd.gender and aaa.first_state = ddd.first_state
and aaa.period = ddd.period
order by 1,2,3
;

-- 위의 쿼리 피벗
SELECT gender, first_state,cohort_size
,max(case when period =0 then pct_retained end)as yr0
,max(case when period =2 then pct_retained end)as yr2
,max(case when period =4 then pct_retained end)as yr4
,max(case when period =6 then pct_retained end)as yr6
,max(case when period =8 then pct_retained end)as yr8
,max(case when period =10 then pct_retained end)as yr10
FROM
(
SELECT aaa.gender, aaa.first_state, aaa.period, aaa.cohort_size
,coalesce(ddd.cohort_retained,0) as cohort_retained
,coalesce(ddd.cohort_retained,0) * 1.0 / aaa.cohort_size as pct_retained
FROM 
(
	SELECT aa.gender, aa.first_state, cc.period, aa.cohort_size
	FROM
	(
		SELECT b.gender, a.first_state
		,count(distinct a.id_bioguide) as cohort_size
		FROM
			(	
			SELECT distinct id_bioguide
			,min(term_start) over (partition by id_bioguide) as first_term
			,first_value(state) over (partition by id_bioguide
										order by term_start) as first_state
			FROM legislators_terms
			) a
		JOIN legislators b on a.id_bioguide = b.id_bioguide
		WHERE a.first_term between '1917-01-01' and '1999-12-31'
		GROUP by 1,2
	)aa
	JOIN
	(
		SELECT generate_series as period
		FROM generate_series(0,20,1)
	) cc on 1=1
)aaa
LEFT JOIN 
(
	SELECT d.first_state,g.gender
	,coalesce(date_part('year',age(f.date,d.first_term)),0) as period
	,count(distinct d.id_bioguide)as cohort_retained
	FROM
	(
		SELECT distinct id_bioguide
		,min(term_start) over (partition by id_bioguide)as first_term
		,first_value(state) over (partition by id_bioguide
									order by term_start) as first_state
		FROM legislators_terms							
	) d 
	JOIN legislators_terms e on d.id_bioguide = e.id_bioguide
	LEFT JOIN date_dim f on f.date between e.term_start and e.term_end
	and f.month_name = 'December' and f.day_of_month = 31
	JOIN legislators g on d.id_bioguide = g.id_bioguide
	WHERE d.first_term between '1917-01-01' and '1999-12-31'
	GROUP BY 1,2,3
) ddd on aaa.gender = ddd.gender and aaa.first_state = ddd.first_state
and aaa.period = ddd.period
)a
GROUP BY 1,2,3
;
