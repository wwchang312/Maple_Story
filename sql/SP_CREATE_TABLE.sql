CREATE OR ALTER PROCEDURE SP_CREATE_TABLE 
AS 
BEGIN
	SET NOCOUNT ON;
	SET XACT_ABORT ON; -- 런타임 오류 발생 시, ROLLBACK


	
	--테이블 생성 쿼리 변수 선언
	DECLARE @sql NVARCHAR(MAX) = N'';
	
	/*
	 
	 1. User 계정정보 조회
	 
	 - 구성 테이블
	 
	 1-1) 캐릭터 목록 조회
	 1-v1) 캐릭터 목록 JSON 조회용 VIEW 생성 
	 1-2) 업적 정보 조회
	 
	 */
	
	
--	1-1) 캐릭터 목록 테이블
	SET @sql += N'
	IF OBJECT_ID(N''dbo.character_list'',''U'') IS NULL
	CREATE TABLE dbo.character_list(
	account_id		NVARCHAR(64),		-- 메이플스토리 계정 식별자
	character_list	NVARCHAR(MAX),		-- 캐릭터 목록
	CONSTRAINT pk_character_list PRIMARY KEY (account_id)
	);';

	
-- 	1-2) 업적 정보 조회 테이블
	SET @sql += N'
	IF OBJECT_ID(N''dbo.user_achievement'',''U'') IS NULL
	CREATE TABLE dbo.user_achievement(
	account_id			NVARCHAR(64),	--메이플스토리 계정 식별자
	achievement_achieve	NVARCHAR(MAX),	--달성 업적 정보
	CONSTRAINT pk_user_achievement PRIMARY KEY (account_id)
	);';
	
	-------------------------------------------------------------------------------------

	/*
	 
	 2. Character 캐릭터 정보 조회
	 
	 - 구성 테이블
	 
	 2-1) 캐릭터 식별자(ocid)조회 테이블
	 2-2) 캐릭터 기본 정보 조회 테이블
	 2-3) 캐릭터 인기도 정보 조회 테이블
	 2-4) 캐릭터 종합 능력치 정보 조회 테이블
	 
	 */

--	2-1) 캐릭터 식별자(ocid)조회 테이블
	SET @sql += N'
	IF OBJECT_ID(N''dbo.id'',''U'') IS NULL
	CREATE TABLE dbo.id (
	ocid	NVARCHAR(64),		--캐릭터 식별자
	CONSTRAINT pk_id PRIMARY KEY(ocid)
	);';

--	2-2) 캐릭터 기본 정보 조회 테이블
	SET @sql += N'
	IF OBJECT_ID(N''dbo.character_basic'',''U'') IS NULL
	CREATE TABLE dbo.character_basic (
	[date]					NVARCHAR(32),		--조회기준일
	ocid					NVARCHAR(64),		--캐릭터 식별자 (PK용 컬럼, 파라미터의 값을 가져와서 INSERT)
	character_name			NVARCHAR(128),		--캐릭터 명
	world_name				NVARCHAR(64),		--월드 명
	character_gender		NVARCHAR(128),		--캐릭터 성별
	character_class			NVARCHAR(64),		--캐릭터 직업
	character_class_level	NVARCHAR(4),		--캐릭터 전직 차수
	character_level			INT,				--캐릭터 레벨
	character_exp			BIGINT,				--현재 레벨에서 보유한 경험치
	character_exp_rate		NVARCHAR(8),		--현재 레벨에서 경험치 퍼센트
	character_guild_name	NVARCHAR(64),		--캐릭터 소속 길드 명
	character_image			NVARCHAR(MAX),		--캐릭터 외형 이미지
	character_date_create	NVARCHAR(32),		--캐릭터 생성일
	access_flag				NVARCHAR(8),		--최근 7일간 접속 여부
	liberation_quest_clear	NVARCHAR(8),		--해방 퀘스트 완료 여부 (0:미완료, 1:제네시스 무기 해방, 2:데스티니 무기 1차 해방)
	CONSTRAINT pk_character_basic PRIMARY KEY (ocid)
	);';

--	2-3) 캐릭터 인기도 정보 조회 테이블
	SET @sql += N'
	IF OBJECT_ID(N''dbo.character_popularity'',''U'') IS NULL
	CREATE TABLE dbo.character_popularity (
	[date]			NVARCHAR(32),				--조회기준일
	ocid			NVARCAHR(64),				--캐릭터 식별자
	popularity		INT,						--캐릭터 인기도
	CONSTRAINT pk_character_popularity PRIMARY KEY (ocid)
	);';

--	2-4) 캐릭터 종합 능력치 정보 조회
	SET @sql += N'
	IF OBJECT_ID(N''dbo.character_stat'',''U'') IS NULL
	CREATE TABLE dbo.character_stat (
	[date]				NVARCHAR(32),
	ocid				NVARCHAR(64),
	character_class		NVARCHAR(64),
	final_stat			NVARCHAR(MAX),			--현재 스탯 정보
	CONSTRAINT pk_character_stat PRIMARY KEY (ocid)
	);';

	

	BEGIN TRY
		BEGIN TRAN;
		
		EXEC sys.sp_executesql @sql;
	
	
	-- 	1-v1) 캐릭터 목록 JSON 조회용 VIEW 생성 
		EXEC(N'
		CREATE OR ALTER VIEW dbo.vw_character_list AS 
		select aoj.*
			from character_list cl
			CROSS APPLY OPENJSON(cl.character_list)
			WITH (
				ocid				NVARCHAR(64),	--캐릭터 식별자
				character_name		NVARCHAR(64),	--캐릭터 명
				world_name			NVARCHAR(32),	--월드 명
				character_class		NVARCHAR(64),	--캐릭터 직업
				character_level		INT				--캐릭터 레벨
				)aoj ;'
		);
		
		COMMIT TRAN;
	END TRY
	
	BEGIN CATCH
		IF XACT_STATE() <> 0 ROLLBACK TRAN;
	
		-- 에러 메시지 생성용
		THROW;
	END CATCH
END
GO