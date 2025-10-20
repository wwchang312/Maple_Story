CREATE OR ALTER PROCEDURE SP_CREATE_CHARACTER_TABLE 
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
	 
	 2-1) 캐릭터 식별자(ocid)조회 
	 2-2) 캐릭터 기본 정보 조회 
	 2-3) 캐릭터 인기도 정보 조회 
	 2-4) 캐릭터 종합 능력치 정보 조회 
	 2-5) 캐릭터 하이퍼스탯 정보 조회 
	 2-6) 캐릭터 성향 정보 조회 
	 2-7) 캐릭터 어빌리티 정보 조회 
	 2-8) 캐릭터 장착 장비 정보 조회(캐시 장비 제외)
	 2-9) 장착 캐시 장비 정보 조회
	 2-10) 장착 심볼 정보 조회
	 2-11) 적용 세트 효과 정보 조회
	 2-12) 장착 헤어, 성형, 피부 정보 조회
	 2-13) 장착 안드로이드 정보 조회
	 2-14) 장착 펫 정보 조회
	 2-15) 스킬 정보 조회
	 2-16) 장착 링크 스킬 정보 조회
	 2-17) V매트릭스 정보 조회
	 2-18) HEXA 코어 정보 조회
	 2-19) HEXA 매트릭스 설정 HEXA 스탯 정보 조회
	 2-20) 무릉도장 최고 기록 정보 조회
	 2-21) 기타 능력치 영향 요소 정보 조회 조회
	 2-22) 링 익스체인지 스킬 등록 장비 조회
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
	[date]					DATETIMEOFFSET,		--조회기준일
	ocid					NVARCHAR(64),		--캐릭터 식별자 (PK용 컬럼, 파라미터의 값을 가져와서 INSERT)
	character_name			NVARCHAR(128),		--캐릭터 명
	world_name				NVARCHAR(64),		--월드 명
	character_gender		NVARCHAR(8),		--캐릭터 성별
	character_class			NVARCHAR(64),		--캐릭터 직업
	character_class_level	NVARCHAR(4),		--캐릭터 전직 차수
	character_level			INT,				--캐릭터 레벨
	character_exp			BIGINT,				--현재 레벨에서 보유한 경험치
	character_exp_rate		NVARCHAR(8),		--현재 레벨에서 경험치 퍼센트
	character_guild_name	NVARCHAR(64),		--캐릭터 소속 길드 명
	character_image			NVARCHAR(MAX),		--캐릭터 외형 이미지
	character_date_create	DATETIMEOFFSET,		--캐릭터 생성일
	access_flag				NVARCHAR(8),		--최근 7일간 접속 여부
	liberation_quest_clear	NVARCHAR(8),		--해방 퀘스트 완료 여부 (0:미완료, 1:제네시스 무기 해방, 2:데스티니 무기 1차 해방)
	CONSTRAINT pk_character_basic PRIMARY KEY (ocid)
	);';

--	2-3) 캐릭터 인기도 정보 조회 테이블
	SET @sql += N'
	IF OBJECT_ID(N''dbo.character_popularity'',''U'') IS NULL
	CREATE TABLE dbo.character_popularity (
	[date]			DATETIMEOFFSET,				--조회기준일
	ocid			NVARCHAR(64),				--캐릭터 식별자
	popularity		INT,						--캐릭터 인기도
	CONSTRAINT pk_character_popularity PRIMARY KEY (ocid)
	);';

--	2-4) 캐릭터 종합 능력치 정보 조회 테이블
	SET @sql += N'
	IF OBJECT_ID(N''dbo.character_stat'',''U'') IS NULL
	CREATE TABLE dbo.character_stat (
	[date]				DATETIMEOFFSET,
	ocid				NVARCHAR(64),
	character_class		NVARCHAR(64),
	final_stat			NVARCHAR(MAX),			--현재 스탯 정보
	CONSTRAINT pk_character_stat PRIMARY KEY (ocid)
	);';

--  2-5) 캐릭터 하이퍼스탯 정보 조회 테이블
	SET @sql += N'
	IF OBJECT_ID(N''dbo.character_hyper_stat'',''U'') IS NULL
	CREATE TABLE dbo.character_hyper_stat (
	[date]								DATETIMEOFFSET,
	ocid								NVARCHAR(64),
	character_class 					NVARCHAR(64),
	use_preset_no						NVARCHAR(4),		--적용 중인 프리셋 번호
	use_available_hyper_stat			INT,				--사용 가능한 최대 하이퍼 스탯 포인트
	hyper_stat_preset_1		 			NVARCHAR(MAX),		--1번 프리셋 하이퍼 스탯 정보
	hyper_stat_preset_1_remain_point 	INT,				--1번 프리셋 하이퍼 스탯 잔여 포인트
	hyper_stat_preset_2					NVARCHAR(MAX),		--2번 프리셋 하이퍼 스탯 정보
	hyper_stat_preset_2_remain_point	INT,				--2번 프리셋 하이퍼 스탯 잔여 포인트
	hyper_stat_preset_3					NVARCHAR(MAX),		--3번 프리셋 하이퍼 스탯 정보
	hyper_stat_preset_3_remain_point	INT					--3번 프리셋 하이퍼 스탯 잔여 포인트
	CONSTRAINT pk_character_hyper_stat PRIMARY KEY (ocid)
	);';

	
--  2-6) 캐릭터 성향 정보 조회 테이블
	SET @sql += N'
	IF OBJECT_ID(N''dbo.character_propensity'',''U'') IS NULL
	CREATE TABLE dbo.character_propensity (
	[date]				DATETIMEOFFSET,
	ocid				NVARCHAR(64),
	charisma_level		INT,								--카리스마 레벨
	sensibility_level	INT,								--감성 레벨
	insight_level		INT,								--통찰력 레벨
	willingness_level	INT,								--의지 레벨
	handicraft_level	INT,								--손재주 레벨
	charm_level			INT,								--매력 레벨
	CONSTRAINT pk_character_propensity PRIMARY KEY (ocid)
	);';

--	2-7) 캐릭터 어빌리티 정보 조회 테이블
	SET @sql += N'
	IF OBJECT_ID(N''dbo.character_ability'',''U'') IS NULL
	CREATE TABLE dbo.character_ability (
	[date]				DATETIMEOFFSET,
	ocid				NVARCHAR(64),
	ability_grade		NVARCHAR(16),						--어빌리티 등급
	ability_info		NVARCHAR(MAX),						--어빌리티 정보
	remain_fame			INT,								--보유 명성치
	preset_no			INT,								--적용 중인 어빌리티 프리셋 번호
	ability_preset_1	NVARCHAR(MAX),						--어빌리티 1번 프리셋 전체 정보
	ability_preset_2	NVARCHAR(MAX),						--어빌리티 2번 프리셋 전체 정보
	ability_preset_3	NVARCHAR(MAX),						--어빌리티 3번 프리셋 전체 정보
	CONSTRAINT pk_character_ability PRIMARY KEY (ocid)
	);';

--	2-8) 캐릭터 장착 장비 정보 조회(캐시 장비 제외)
	SET @sql += N'
	IF OBJECT_ID(N''dbo.character_item_equipment'',''U'') IS NULL
	CREATE TABLE dbo.character_item_equipment (
	[date]						DATETIMEOFFSET,
	ocid						NVARCHAR(64),
	character_gender			NVARCHAR(8),
	character_class				NVARCHAR(64),
	preset_no					INT,						--적용 중인 장비 프리셋 번호
	item_equipment				NVARCHAR(MAX),				--장비 정보
	item_equipment_preset_1		NVARCHAR(MAX),				--1번 프리셋 장비 정보
	item_equipment_preset_2		NVARCHAR(MAX),				--2번 프리셋 장비 정보
	item_equipment_preset_3		NVARCHAR(MAX),				--3번 프리셋 장비 정보
	title						NVARCHAR(MAX),				--칭호 정보
	medal_shape					NVARCHAR(MAX),				--외형 설정에 등록한 훈장 외형 정보
	dragon_equipment			NVARCHAR(MAX),				--에반 드래곤 장비 정보(에반인 경우 응답)
	mechanic_equipment			NVARCHAR(MAX),				--메카닉 장비 정보 (메카닉인 경우 응답)
	CONSTRAINT pk_character_item_equipment PRIMARY KEY (ocid)
	);';

--	2-9) 장착 캐시 장비 정보 조회
	SET @sql += N'
	IF OBJECT_ID(N''dbo.character_cashitem_equipment'',''U'') IS NULL
	CREATE TABLE dbo.character_cashitem_equipment (
	[date]									DATETIMEOFFSET,
	ocid									NVARCHAR(64),
	character_gender						NVARCHAR(8),
	character_class							NVARCHAR(64),
	character_look_mode						NVARCHAR(4),	--캐릭터 외형 모드 (0: 일반, 1: 제로인 경우 베타, 엔젤릭 버스터인 경우 드레스 업 모드)
	preset_no								INT,			--적용 중인 캐시 장비 프리셋 번호
	cash_item_equipment_base				NVARCHAR(MAX),	--장착 중인 캐시 장비
	cash_item_equipment_preset_1			NVARCHAR(MAX),	--1번 코디 프리셋
	cash_item_equipment_preset_2			NVARCHAR(MAX),	--2번 코디 프리셋
	cash_item_equipment_preset_3			NVARCHAR(MAX),	--3번 코디 프리셋
	additional_cash_item_equipment_base		NVARCHAR(MAX),	--제로인 경우 베타, 엔젤릭버스터인 경우 드레스 업 모드에서 장착 중인 캐시 장비
	additional_cash_item_equipment_preset_1	NVARCHAR(MAX),	--제로인 경우 베타, 엔젤릭버스터인 경우 드레스 업 모드의 1번 코디 프리셋
	additional_cash_item_equipment_preset_2	NVARCHAR(MAX),	--제로인 경우 베타, 엔젤릭버스터인 경우 드레스 업 모드의 2번 코디 프리셋
	additional_cash_item_equipment_preset_3	NVARCHAR(MAX),	--제로인 경우 베타, 엔젤릭버스터인 경우 드레스 업 모드의 3번 코디 프리셋
	CONSTRAINT pk_character_cashitem_equipment	PRIMARY KEY (ocid)
	);';

--	2-10) 장착 심볼 정보 조회
	SET @sql += N'
	IF OBJECT_ID(N''dbo.character_symbol_equipment'',''U'') IS NULL
	CREATE TABLE dbo.character_symbol_equipment(
	[date]					DATETIMEOFFSET,
	ocid					NVARCHAR(64),
	character_class			NVARCHAR(64),
	symbol					NVARCHAR(MAX),						--심볼 정보
	CONSTRAINT pk_character_symbol_equipment PRIMARY KEY (ocid)
	);';	

--	2-11) 적용 세트 효과 정보 조회
	SET @sql += N'
	IF OBJECT_ID(N''dbo.character_set_effect'',''U'') IS NULL
	CREATE TABLE dbo.character_set_effect (
	[date]			DATETIMEOFFSET,
	ocid			NVARCHAR(64),
	set_effect		NVARCHAR(MAX),							--세트 효과 정보
	CONSTRAINT pk_character_set_effect PRIMARY KEY (ocid)
	);';

--	2-12) 장착 헤어, 성형, 피부 정보 조회
	SET @sql += N'
	IF OBJECT_ID(N''dbo.character_beauty_equipment'',''U'') IS NULL
	CREATE TABLE dbo.character_beauty_equipment(
	[date]						DATETIMEOFFSET,
	ocid						NVARCHAR(64),
	character_gender			NVARCHAR(8),
	character_class				NVARCHAR(64),
	character_hair				NVARCHAR(MAX),		--캐릭터 헤어 정보 (제로인 경우 알파, 엔젤릭버스터인 경우 일반모드)
	character_face				NVARCHAR(MAX),		--캐릭터 성형 정보 (제로인 경우 알파, 엔젤릭버스터인 경우 일반모드)
	character_skin				NVARCHAR(MAX),		--캐릭터 피부 정보 (제로인 경우 알파, 엔젤릭버스터인 경우 일반모드)	
	additional_character_hair	NVARCHAR(MAX),		--캐릭터 헤어 정보 (제로인 경우 베타, 엔젤릭버스터인 경우 드레스업)
	additional_character_face	NVARCHAR(MAX),		--캐릭터 성형 정보 (제로인 경우 베타, 엔젤릭버스터인 경우 드레스업)
	additional_character_skin	NVARCHAR(MAX),		--캐릭터 피부 정보 (제로인 경우 베타, 엔젤릭버스터인 경우 드레스업)
	CONSTRAINT pk_character_beauty_equipment PRIMARY KEY (ocid)
	);';

--	2-13) 장착 안드로이드 정보 조회
	SET @sql += N'
	IF OBJECT_ID(N''dbo.character_android_equipment'',''U'') IS NULL
	CREATE TABLE dbo.character_android_equipment(
	[date]							DATETIMEOFFSET,
	ocid							NVARCHAR(64),
	android_name					NVARCHAR(32),			--안드로이드 명
	android_nickname				NVARCHAR(32),			--안드로이드 닉네임
	android_icon					NVARCHAR(1024),			--안드로이드 아이콘
	android_description				NVARCHAR(512),			--안드로이드 아이템 설명
	android_hair					NVARCHAR(MAX),			--안드로이드 헤어 정보
	android_face					NVARCHAR(MAX),			--안드로이드 성형 정보
	android_skin					NVARCHAR(MAX),			--안드로이드 피부 정보
	android_cash_item_equipment		NVARCHAR(MAX),			--안드로이드 캐시 아이템 장착 정보
	android_ear_sensor_clip_flag	NVARCHAR(5),			--안드로이드 이어센서 클립 적용 여부
	android_gender					NVARCHAR(4),			--안드로이드 성별
	android_grade					NVARCHAR(8),			--안드로이드 등급
	android_non_humanoid_flag		NVARCHAR(5),			--비인간형 안드로이드 여부
	android_shop_usable_flag		NVARCHAR(5),			--잡화상점 기능 이용 가능 여부
	preset_no						INT,					--적용 중인 장비 프리셋 번호
	android_preset_1				NVARCHAR(MAX),			--1번 프리셋 안드로이드 정보
	android_preset_2				NVARCHAR(MAX),			--2번 프리셋 안드로이드 정보
	android_preset_3				NVARCHAR(MAX),			--3번 프리셋 안드로이드 정보
	CONSTRAINT pk_character_android_equipment PRIMARY KEY (ocid)
	);'
	
--	2-14) 장착 펫 정보 조회
	SET @sql += N'
	IF OBJECT_ID(N''dbo.character_pet_equipment'',''U'') IS NULL
	CREATE TABLE dbo.character_pet_equipment(
	[date]							DATETIMEOFFSET,
	ocid							NVARCHAR(64),			
	pet_1_name						NVARCHAR(32),			--펫1 명
	pet_1_nickname					NVARCHAR(32),			--펫1 닉네임
	pet_1_icon						NVARCHAR(1024),			--펫1 아이콘
	pet_1_description				NVARCHAR(1024),			--펫1 설명
	pet_1_equipment					NVARCHAR(MAX),			--펫1 장착정보
	pet_1_auto_skill				NVARCHAR(MAX),			--펫1 펫 버프 자동스킬 정보
	pet_1_pet_type					NVARCHAR(32),			--펫1 원더 펫 종류
	pet_1_skill						NVARCHAR(32),			--펫1 펫 보유 스킬
	pet_1_date_expire				NVARCHAR(32),			--펫1 마법의 시간
	pet_1_appearance				NVARCHAR(1024),			--펫1 외형
	pet_1_appearance_icon			NVARCHAR(1024),			--펫1 외형 아이콘
	pet_2_name						NVARCHAR(32),			--펫2 명
	pet_2_nickname					NVARCHAR(32),			--펫2 닉네임
	pet_2_icon						NVARCHAR(1024),			--펫2 아이콘
	pet_2_description				NVARCHAR(1024),			--펫2 설명
	pet_2_equipment					NVARCHAR(MAX),			--펫2 장착정보
	pet_2_auto_skill				NVARCHAR(MAX),			--펫2 펫 버프 자동스킬 정보
	pet_2_pet_type					NVARCHAR(32),			--펫2 원더 펫 종류
	pet_2_skill						NVARCHAR(32),			--펫2 펫 보유 스킬
	pet_2_date_expire				NVARCHAR(32),			--펫2 마법의 시간
	pet_2_appearance				NVARCHAR(1024),			--펫2 외형
	pet_2_appearance_icon			NVARCHAR(1024),			--펫2 외형 아이콘
	pet_3_name						NVARCHAR(32),			--펫3 명
	pet_3_nickname					NVARCHAR(32),			--펫3 닉네임
	pet_3_icon						NVARCHAR(1024),			--펫3 아이콘
	pet_3_description				NVARCHAR(1024),			--펫3 설명
	pet_3_equipment					NVARCHAR(MAX),			--펫3 장착정보
	pet_3_auto_skill				NVARCHAR(MAX),			--펫3 펫 버프 자동스킬 정보
	pet_3_pet_type					NVARCHAR(32),			--펫3 원더 펫 종류
	pet_3_skill						NVARCHAR(32),			--펫3 펫 보유 스킬
	pet_3_date_expire				NVARCHAR(32),			--펫3 마법의 시간
	pet_3_appearance				NVARCHAR(1024),			--펫3 외형
	pet_3_appearance_icon			NVARCHAR(1024),			--펫3 외형 아이콘
	CONSTRAINT pk_character_pet_equipment	PRIMARY KEY (ocid)
	);';
	
--	2-15) 스킬 정보 조회
	SET @sql += N'
	IF OBJECT_ID(N''dbo.character_skill'',''U'') IS NULL
	CREATE TABLE dbo.character_skill(
	[date]					DATETIMEOFFSET,
	ocid					NVARCHAR(64),
	character_class			NVARCHAR(64),
	character_skill_grade	NVARCHAR(16),			--스킬 전직 차수
	character_skill			NVARCHAR(MAX),			--스킬 정보
	CONSTRAINT pk_character_skill PRIMARY KEY (ocid,character_skill_grade)
	);';

--	2-16) 장착 링크 스킬 정보 조회
	SET @sql += N'
	IF OBJECT_ID(N''dbo.character_link_skill'',''U'') IS NULL
	CREATE TABLE dbo.character_link_skill(
	[date]								DATETIMEOFFSET,
	ocid								NVARCHAR(64),
	character_class						NVARCHAR(64),
	character_link_skill				NVARCHAR(MAX),		--링크 스킬 정보
	character_link_skill_preset_1		NVARCHAR(MAX),		--링크 스킬 1번 프리셋 정보
	character_link_skill_preset_2		NVARCHAR(MAX),		--링크 스킬 2번 프리셋 정보
	character_link_skill_preset_3		NVARCHAR(MAX),		--링크 스킬 3번 프리셋 정보
	character_owned_link_skill			NVARCHAR(MAX),		--내 링크 스킬 정보
	character_owned_link_skill_preset_1	NVARCHAR(MAX),		--내 링크 스킬 1번 프리셋 정보	
	character_owned_link_skill_preset_2	NVARCHAR(MAX),		--내 링크 스킬 2번 프리셋 정보	
	character_owned_link_skill_preset_3	NVARCHAR(MAX),		--내 링크 스킬 3번 프리셋 정보	
	CONSTRAINT pk_character_link_skill PRIMARY KEY (ocid)
	);';
	
--	2-17) V매트릭스 정보 조회
	SET @sql += N'
	IF OBJECT_ID(N''dbo.character_vmatrix'',''U'') IS NULL
	CREATE TABLE dbo.character_vmatrix(
	[date]											DATETIMEOFFSET,
	ocid				 							NVARCHAR(64),
	character_class									NVARCHAR(64),
	character_v_core_equipment						NVARCHAR(MAX),	--V코어 정보
	character_v_matrix_remain_slot_upgrade_point	INT,			--캐릭터 잔여 매트릭스 강화 포인트
	CONSTRAINT pk_character_vmatrix PRIMARY KEY (ocid)
	);';

--	2-18) HEXA 코어 정보 조회
	SET @sql += N'
	IF OBJECT_ID(N''dbo.character_hexamatrix'',''U'') IS NULL
	CREATE TABLE dbo.character_hexamatrix(
	[date]							DATETIMEOFFSET,
	ocid							NVARCHAR(64),
	character_hexa_core_equipment	NVARCHAR(MAX),	--HEXA 코어 정보
	CONSTRAINT pk_character_hexamatrix PRIMARY KEY (ocid)
	);';

--	2-19) HEXA 매트릭스 설정 HEXA 스탯 정보 조회
	SET @sql += N'
	IF OBJECT_ID(N''dbo.character_hexamatrix_stat'',''U'') IS NULL
	CREATE TABLE dbo.character_hexamatrix_stat(
	[date]						DATETIMEOFFSET,
	ocid						NVARCHAR(64),
	character_class				NVARCHAR(64),
	character_hexa_stat_core	NVARCHAR(MAX),	--HEXA 스탯 1 코어 정보
	character_hexa_stat_core_2	NVARCHAR(MAX),	--HEXA 스탯 2 코어 정보
	character_hexa_stat_core_3	NVARCHAR(MAX),	--HEXA 스탯 3 코어 정보
	preset_hexa_stat_core		NVARCHAR(MAX),	--프리셋 HEXA 스탯 1 코어 정보
	preset_hexa_stat_core_2		NVARCHAR(MAX),	--프리셋 HEXA 스탯 2 코어 정보
	preset_hexa_stat_core_3		NVARCHAR(MAX),	--프리셋 HEXA 스탯 3 코어 정보
	CONSTRAINT pk_character_hexamatrix_stat	PRIMARY KEY (ocid)
	);';

--	2-20) 무릉도장 최고 기록 정보 조회
	SET @sql +=N'
	IF OBJECT_ID(N''dbo.character_dojang'',''U'') IS NULL
	CREATE TABLE dbo.character_dojang(
	[date]				DATETIMEOFFSET,
	ocid				NVARCHAR(64),
	character_class		NVARCHAR(64),
	world_name			NVARCHAR(32),
	dojang_best_floor	INT,					--무릉도장 최고 기록 층수
	date_dojang_record	NVARCHAR(32),			--무릉도장 최고 기록 달성 일
	dojang_best_time	INT						--무릉도장 최고 층수 클리어에 걸린 시간 (초)
	CONSTRAINT pk_character_dojang	PRIMARY KEY (ocid)
	);';

--	2-21) 기타 능력치 영향 요소 정보 조회 조회
	SET @sql +=N'
	IF OBJECT_ID(N''dbo.character_other_stat'',''U'') IS NULL
	CREATE TABLE dbo.character_other_stat(
	[date]				DATETIMEOFFSET,
	ocid				NVARCHAR(64),
	other_stat			NVARCHAR(MAX),						--능력치에 영향을 주는 요소 및 스탯 정보
	CONSTRAINT pk_character_other_stat	PRIMARY KEY (ocid)
	);';

--	2-22) 링 익스체인지 스킬 등록 장비 조회
	SET @sql +=N'
	IF OBJECT_ID(N''dbo.character_ring_exchange_skill_equipment'',''U'') IS NULL
	CREATE TABLE dbo.character_ring_exchange_skill_equipment(
	[date]						DATETIMEOFFSET,
	ocid						NVARCHAR(64),
	character_class				NVARCHAR(64),
	special_ring_exchange_name	NVARCHAR(128),
	special_ring_exchange_level	INT,
	CONSTRAINT pk_character_ring_exchange_skill_equipment	PRIMARY KEY (ocid,special_ring_exchange_name)
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