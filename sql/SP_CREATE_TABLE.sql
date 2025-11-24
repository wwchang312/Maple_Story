CREATE OR ALTER PROCEDURE SP_CREATE_TABLE
AS 
BEGIN
	SET NOCOUNT ON;
	SET XACT_ABORT ON; -- 런타임 오류 발생 시, ROLLBACK


	
	--테이블 생성 쿼리 변수 선언
	DECLARE @sql NVARCHAR(MAX) = N'';
	
	/*
	 
	 -- User 계정정보 조회 --
	 
	 ---- 구성 테이블 ----
	 
	 - 캐릭터_목록_테이블
	 - 캐릭터_목록_이력_테이블
	 - 업적_정보_테이블
	 
	 */
	
	
--	캐릭터_목록_테이블
	SET @sql += N'
	IF OBJECT_ID(N''maple.character_list'',''U'') IS NULL
	CREATE TABLE maple.character_list(
	account_id		NVARCHAR(64),		-- 메이플스토리 계정 식별자
	character_list	NVARCHAR(MAX),		-- 캐릭터 목록
	CONSTRAINT pk_character_list PRIMARY KEY (account_id)
	);';

--	캐릭터_목록_이력_테이블
	SET @sql += N'
	IF OBJECT_ID(N''maple.character_list_hist'',''U'') IS NULL
	CREATE TABLE maple.character_list_hist(
	update_date		DATETIME DEFAULT GETDATE(),  -- api 호출 수행 날짜
	account_id		NVARCHAR(64) NOT NULL REFERENCES maple.character_list,		-- 메이플스토리 계정 식별자
	character_list	NVARCHAR(MAX),		-- 캐릭터 목록
	status			NVARCHAR(2),		-- 최초 등록 : C , 변경 : U , 삭제:D
	CONSTRAINT pk_character_list_hist PRIMARY KEY (update_date,account_id)
	);';


-- 	업적_정보_테이블
	SET @sql += N'
	IF OBJECT_ID(N''maple.user_achievement'',''U'') IS NULL
	CREATE TABLE maple.user_achievement(
	account_id			NVARCHAR(64),	--메이플스토리 계정 식별자
	achievement_achieve	NVARCHAR(MAX),	--달성 업적 정보
	CONSTRAINT pk_user_achievement PRIMARY KEY (account_id)
	);';


	
-------------------------------------------------------------------------------------

	/*
	 
	 2. Character 캐릭터 정보 조회
	 
	 -- 구성 테이블
	 
	 - 캐릭터_기본정보_테이블
	 - 캐릭터_기본정보_이력_테이블
	 - 캐릭터_인기도_정보_테이블
	 - 캐릭터_인기도_정보_이력_테이블
	 - 캐릭터_종합_능력치_정보_테이블
	 - 캐릭터_종합_능력지_정보_이력_테이블
	 - 캐릭터_하이퍼_스탯_정보_테이블
	 - 캐릭터_하이퍼_스탯_정보_이력_테이블
	 - 캐릭터_성향_정보_테이블
	 - 캐릭터_성향_정보_이력_테이블
	 - 캐릭터_어빌리티_정보_테이블
	 - 캐릭터_어빌리티_정보_이력_테이블
	 - 캐릭터_장착_장비_정보_테이블
	 - 캐릭터_장착_장비_정보_이력_테이블
	 - 캐릭터_장착_캐시_장비_정보_테이블
	 - 캐릭터_장착_캐시_장비_정보_이력_테이블
	 - 캐릭터_장착_심볼_정보_테이블
	 - 캐릭터_장착_심볼_정보_이력_테이블
	 - 캐릭터_적용_세트_효과_정보_테이블
	 - 캐릭터_적용_세트_효과_정보_이력_테이블
	 - 캐릭터_외관_정보_테이블
	 - 캐릭터_외관_정보_이력_테이블
	 - 캐릭터_장착_안드로이드_정보_테이블
	 - 캐릭터_장착_안드로이드_정보_이력_테이블
	 - 캐릭터_장착_펫_정보_테이블
	 - 캐릭터_장착_펫_정보_이력_테이블
	 - 캐릭터_스킬_정보_테이블
	 - 캐릭터_스킬_정보_이력_테이블
	 - 캐릭터_장착_링크_스킬_정보_테이블
	 - 캐릭터_장착_링크_스킬_정보_이력_테이블
	 - 캐릭터_V매트릭스_정보_테이블
	 - 캐릭터_V매트릭스_정보_이력_테이블
	 - 캐릭터_HEXA_코어_정보_테이블
	 - 캐릭터_HEXA_코어_정보_이력_테이블
	 - 캐릭터_HEXA_매트릭스_설정_HEXA_스탯_정보_테이블
	 - 캐릭터_HEXA_매트릭스_설정_HEXA_스탯_정보_이력_테이블
	 - 캐릭터_무릉도장_최고_기록_정보_테이블
	 - 캐릭터_무릉도장_최고_기록_이력_테이블
	 - 기타_능력치_영향_요소_정보_테이블
	 - 기타_능력치_영향_요소_정보_이력_테이블
	 - 링_익스체인지_스킬_등록_장비_테이블
	 - 링_익스체인지_스킬_등록_장비_이력_테이블
	 */


--	캐릭터_기본정보_테이블
	SET @sql += N'
	IF OBJECT_ID(N''maple.character_basic'',''U'') IS NULL
	CREATE TABLE maple.character_basic (
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
	character_image			NVARCHAR(512),		--캐릭터 외형 이미지
	character_date_create	NVARCHAR(32),		--캐릭터 생성일
	access_flag				NVARCHAR(8),		--최근 7일간 접속 여부
	liberation_quest_clear	NVARCHAR(8),		--해방 퀘스트 완료 여부 (0:미완료, 1:제네시스 무기 해방, 2:데스티니 무기 1차 해방)
	CONSTRAINT pk_character_basic PRIMARY KEY (ocid)
	);';

--  캐릭터_기본정보_이력_테이블
	SET @sql += N'
	IF OBJECT_ID(N''maple.character_basic_hist'',''U'') IS NULL
	CREATE TABLE maple.character_basic_hist (
	update_date				DATETIME DEFAULT GETDATE(),  --api 호출 수행 날짜
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
	character_image			NVARCHAR(512),		--캐릭터 외형 이미지
	character_date_create	NVARCHAR(32),		--캐릭터 생성일
	access_flag				NVARCHAR(8),		--최근 7일간 접속 여부
	liberation_quest_clear	NVARCHAR(8),		--해방 퀘스트 완료 여부 (0:미완료, 1:제네시스 무기 해방, 2:데스티니 무기 1차 해방)
	status					NVARCHAR(2),		--최초 등록 : C , 변경 : U , 삭제:D
	CONSTRAINT pk_character_basic_hist PRIMARY KEY (update_date,ocid)
	);';

--	캐릭터_인기도_정보_테이블
	SET @sql += N'
	IF OBJECT_ID(N''maple.character_popularity'',''U'') IS NULL
	CREATE TABLE maple.character_popularity (
	[date]			NVARCHAR(32),				--조회기준일
	ocid			NVARCHAR(64),				--캐릭터 식별자
	popularity		INT,						--캐릭터 인기도
	CONSTRAINT pk_character_popularity PRIMARY KEY (ocid)
	);';

--	캐릭터_인기도_정보_이력_테이블
	SET @sql += N'
	IF OBJECT_ID(N''maple.character_popularity_hist'',''U'') IS NULL
	CREATE TABLE maple.character_popularity_hist (
	update_date		DATETIME DEFAULT GETDATE(),  	--api 호출 수행 날짜
	[date]			NVARCHAR(32),					--조회기준일
	ocid			NVARCHAR(64),					--캐릭터 식별자
	popularity		INT,							--캐릭터 인기도
	status			NVARCHAR(2),					--최초 등록 : C , 변경 : U , 삭제:D
	CONSTRAINT pk_character_popularity_hist PRIMARY KEY (update_date,ocid)
	);';

--	캐릭터_종합_능력치_정보_테이블
	SET @sql += N'
	IF OBJECT_ID(N''maple.character_stat'',''U'') IS NULL
	CREATE TABLE maple.character_stat (
	[date]				NVARCHAR(32),			--조회기준일
	ocid				NVARCHAR(64),			--캐릭터 식별자
	character_class		NVARCHAR(64),			--캐릭터 직업
	final_stat			NVARCHAR(MAX),			--현재 스탯 정보
	CONSTRAINT pk_character_stat PRIMARY KEY (ocid)
	);';

--	캐릭터_종합_능력지_정보_이력_테이블
	SET @sql += N'
	IF OBJECT_ID(N''maple.character_stat_hist'',''U'') IS NULL
	CREATE TABLE maple.character_stat_hist (
	update_date			DATETIME DEFAULT GETDATE(),  	--api 호출 수행 날짜
	[date]				NVARCHAR(32),					--조회기준일
	ocid				NVARCHAR(64),					--캐릭터 식별자
	character_class		NVARCHAR(64),					--캐릭터 직업
	final_stat			NVARCHAR(MAX),					--현재 스탯 정보
	status				NVARCHAR(2),					--최초 등록 : C , 변경 : U , 삭제:D
	CONSTRAINT pk_character_stat_hist PRIMARY KEY (update_date,ocid)
	);';

--  캐릭터_하이퍼_스탯_정보_테이블
	SET @sql +=N'
	IF OBJECT_ID(N''maple.character_hyper_stat'',''U'') IS NULL
	CREATE TABLE maple.character_hyper_stat(
	[date]								NVARCHAR(32),	--조회기준일
	ocid								NVARCHAR(64),	--캐릭터 식별자
	character_class						NVARCHAR(64),	--캐릭터 직업
	use_preset_no						NVARCHAR(4),	--적용 중인 프리셋 번호
	use_available_hyper_stat			INT,			-- 사용 가능한 최대 하이퍼스탯 포인트
	hyper_stat_preset_1					NVARCHAR(MAX),	-- 1번 프리셋 하이퍼 스탯 정보
	hyper_stat_preset_1_remain_point	INT,			-- 1번 프리셋 하이퍼 스텟 잔여 포인트
	hyper_stat_preset_2					NVARCHAR(MAX),	-- 2번 프리셋 하이퍼 스탯 정보
	hyper_stat_preset_2_remain_point	INT,			-- 2번 프리셋 하이퍼 스텟 잔여 포인트
	hyper_stat_preset_3					NVARCHAR(MAX),	-- 3번 프리셋 하이퍼 스탯 정보
	hyper_stat_preset_3_remain_point	INT,			-- 3번 프리셋 하이퍼 스탯 잔여 포인트
	CONSTRAINT pk_character_hyper_stat PRIMARY KEY (ocid)
	);';

--	캐릭터_하이퍼_스탯_정보_이력_테이블
	SET @sql +=N'
	IF OBJECT_ID(N''maple.character_hyper_stat_hist'',''U'') IS NULL
	CREATE TABLE maple.character_hyper_stat_hist(
	update_date							DATETIME DEFAULT GETDATE(),  -- api 호출 수행 날짜
	[date]								NVARCHAR(32),
	ocid								NVARCHAR(64),
	character_class						NVARCHAR(64),
	use_preset_no						NVARCHAR(4),
	use_available_hyper_stat			INT,
	hyper_stat_preset_1					NVARCHAR(MAX),
	hyper_stat_preset_1_remain_point	INT,
	hyper_stat_preset_2					NVARCHAR(MAX),
	hyper_stat_preset_2_remain_point	INT,
	hyper_stat_preset_3					NVARCHAR(MAX),
	hyper_stat_preset_3_remain_point	INT,
	status								NVARCHAR(2),		-- 최초 등록 : C , 변경 : U , 삭제:D
	CONSTRAINT pk_character_hyper_stat_hist PRIMARY KEY (update_date,ocid)
	);';

--  캐릭터_성향_정보_테이블
	SET @sql +=N'
	IF OBJECT_ID(N''maple.character_propensity'',''U'') IS NULL
	CREATE TABLE maple.character_propensity(
	[date]					NVARCHAR(32),
	ocid					NVARCHAR(64),
	charisma_level			INT,				--카리스마 레벨
	sensibility_level		INT,				--감성 레벨
	insight_level			INT,				--통찰력 레벨
	willingness_level		INT,				--의지 레벨
	handicraft_level		INT,				--손재주 레벨
	charm_level				INT,				--매력 레벨
	CONSTRAINT pk_character_propensity PRIMARY KEY (ocid)
	);';

--  캐릭터_성향_정보_이력_테이블
	SET @sql +=N'
	IF OBJECT_ID(N''maple.character_propensity_hist'',''U'') IS NULL
	CREATE TABLE maple.character_propensity_hist(
	update_date				DATETIME DEFAULT GETDATE(),  -- api 호출 수행 날짜
	[date]					NVARCHAR(32),
	ocid					NVARCHAR(64),
	charisma_level			INT,
	sensibility_level		INT,
	insight_level			INT,
	willingness_level		INT,
	handicraft_level		INT,
	charm_level				INT,
	status					NVARCHAR(2),
	CONSTRAINT pk_character_propensity_hist PRIMARY KEY (update_date,ocid)
	);';

--	캐릭터_어빌리티_정보_테이블
	SET @sql +=N'
	IF OBJECT_ID(N''maple.character_ability'',''U'') IS NULL
	CREATE TABLE maple.character_ability(
	[date]					NVARCHAR(32),
	ocid					NVARCHAR(64),
	ability_grade			NVARCHAR(32),				--어빌리티 등급
	ability_info			NVARCHAR(MAX),				--어빌리티 정보
	remain_fame				INT,						--보유 명성치
	preset_no				INT,						--적용 중인 어빌리티 프리셋 번호
	ability_preset_1		NVARCHAR(MAX),				--어빌리티 1번 프리셋 전체 정보
	ability_preset_2		NVARCHAR(MAX),				--어빌리티 2번 프리셋 전체 정보
	ability_preset_3		NVARCHAR(MAX),				--어빌리티 3번 프리셋 전체 정보
	CONSTRAINT pk_character_ability	PRIMARY KEY (ocid)
	);';

--  캐릭터_어빌리티_정보_이력_테이블
	SET @sql +=N'
	IF OBJECT_ID(N''maple.character_ability_hist'',''U'') IS NULL
	CREATE TABLE maple.character_ability_hist(
	update_date				DATETIME DEFAULT GETDATE(),
	[date]					NVARCHAR(32),
	ocid					NVARCHAR(64),
	ability_grade			NVARCHAR(32),
	ability_info			NVARCHAR(MAX),
	remain_fame				INT,
	preset_no				INT,
	ability_preset_1		NVARCHAR(MAX),
	ability_preset_2		NVARCHAR(MAX),
	ability_preset_3		NVARCHAR(MAX),
	status					NVARCHAR(2),
	CONSTRAINT pk_character_ability_hist	PRIMARY KEY (update_date,ocid)
	);';

--	캐릭터_장착_장비_정보_테이블
	SET @sql +=N'
	IF OBJECT_ID(N''maple.character_item_equipment'',''U'') IS NULL
	CREATE TABLE maple.character_item_equipment(
	[date]					NVARCHAR(32),
	ocid					NVARCHAR(64),
	character_gender		NVARCHAR(8),
	character_class			NVARCHAR(32),
	preset_no				INT,
	item_equipment			NVARCHAR(MAX),		--장비 정보
	item_equipment_preset_1	NVARCHAR(MAX),		--1번 프리셋 장비 정보
	item_equipment_preset_2	NVARCHAR(MAX),		--2번 프리셋 장비 정보
	item_equipment_preset_3	NVARCHAR(MAX),		--3번 프리셋 장비 정보
	title					NVARCHAR(MAX),		--칭호 정보
	medal_shape				NVARCHAR(MAX),		--외형 설정에 등록한 훈장 외형 정보
	dragon_equipment		NVARCHAR(MAX),		--에반 드래곤 장비 정보(에반인 경우 응답)
	mechanic_equipment		NVARCHAR(MAX),		--메카닉 장비 정보(메카닉인 경우 응답)
	CONSTRAINT pk_character_item_equipment	PRIMARY KEY (ocid)
	);';

--	캐릭터_장착_장비_정보_이력_테이블
	SET @sql +=N'
	IF OBJECT_ID(N''maple.character_item_equipment_hist'',''U'') IS NULL
	CREATE TABLE maple.character_item_equipment_hist(
	update_date				DATETIME DEFAULT GETDATE(),
	[date]					NVARCHAR(32),
	ocid					NVARCHAR(64),
	character_gender		NVARCHAR(8),
	character_class			NVARCHAR(32),
	preset_no				INT,
	item_equipment			NVARCHAR(MAX),
	item_equipment_preset_1	NVARCHAR(MAX),
	item_equipment_preset_2	NVARCHAR(MAX),
	item_equipment_preset_3	NVARCHAR(MAX),
	title					NVARCHAR(MAX),
	medal_shape				NVARCHAR(MAX),
	dragon_equipment		NVARCHAR(MAX),
	mechanic_equipment		NVARCHAR(MAX),
	status					NVARCHAR(2),
	CONSTRAINT pk_character_item_equipment_hist	PRIMARY KEY (update_date,ocid)
	);';

-- 캐릭터_장착_캐시_장비_정보_테이블
	SET @sql +=N'
	IF OBJECT_ID(N''maple.character_cashitem_equipment'',''U'') IS NULL
	CREATE TABLE maple.character_cashitem_equipment(
	[date]										NVARCHAR(32),
	ocid										NVARCHAR(64),
	character_gender							NVARCHAR(8),
	character_class								NVARCHAR(32),
	character_look_mode							NVARCHAR(1),   	-- 캐릭터 외형 모드(0:일반 모드, 1:제로인 경우 베타, 엔젤릭버스터인 경우 드레스 업 모드)
	preset_no									INT,
	cash_item_equipment_base					NVARCHAR(MAX), 	-- 장착 중인 캐시 장비
	cash_item_equipment_preset_1				NVARCHAR(MAX), 	-- 1번 코디 프리셋
	cash_item_equipment_preset_2				NVARCHAR(MAX), 	-- 2번 코디 프리셋
	cash_item_equipment_preset_3				NVARCHAR(MAX), 	-- 3번 코디 프리셋
	additional_cash_item_equipment_base			NVARCHAR(MAX),	-- 제로인 경우 베타, 엔젤릭버스터인 경우 드레스 업 모드에서 장착 중인 캐시 장비
	additional_cash_item_equipment_preset_1		NVARCHAR(MAX),	-- 제로인 경우 베타, 엔젤릭버스터인 경우 드레스 업 모드의 1번 코디 프리셋
	additional_cash_item_equipment_preset_2		NVARCHAR(MAX),	-- 제로인 경우 베타, 엔젤릭버스터인 경우 드레스 업 모드의 2번 코디 프리셋
	additional_cash_item_equipment_preset_3		NVARCHAR(MAX),	-- 제로인 경우 베타, 엔젤릭버스터인 경우 드레스 업 모드의 3번 코디 프리셋
	CONSTRAINT pk_character_cashitem_equipment	PRIMARY KEY (ocid)
	);';

-- 캐릭터_장착_캐시_장비_정보_이력_테이블
	SET @sql +=N'
	IF OBJECT_ID(N''maple.character_cashitem_equipment_hist'',''U'') IS NULL
	CREATE TABLE maple.character_cashitem_equipment_hist(
	update_date				DATETIME DEFAULT GETDATE(),
	[date]										NVARCHAR(32),
	ocid										NVARCHAR(64),
	character_gender							NVARCHAR(8),
	character_class								NVARCHAR(32),
	character_look_mode							NVARCHAR(1),   -- 캐릭터 외형 모드(0:일반 모드, 1:제로인 경우 베타, 엔젤릭버스터인 경우 드레스 업 모드)
	preset_no									INT,
	cash_item_equipment_base					NVARCHAR(MAX),
	cash_item_equipment_preset_1				NVARCHAR(MAX),
	cash_item_equipment_preset_2				NVARCHAR(MAX),
	cash_item_equipment_preset_3				NVARCHAR(MAX),
	additional_cash_item_equipment_base			NVARCHAR(MAX),
	additional_cash_item_equipment_preset_1		NVARCHAR(MAX),
	additional_cash_item_equipment_preset_2		NVARCHAR(MAX),
	additional_cash_item_equipment_preset_3		NVARCHAR(MAX),
	status										NVARCHAR(2),
	CONSTRAINT pk_character_cashitem_equipment_hist	PRIMARY KEY (update_date,ocid)
	);';




--	캐릭터_장착_심볼_정보_테이블
	SET @sql +=N'
	IF OBJECT_ID(N''maple.character_symbol_equipment'',''U'') IS NULL
	CREATE TABLE maple.character_symbol_equipment(
	[date]					NVARCHAR(32),
	ocid					NVARCHAR(64),
	character_class			NVARCHAR(32),
	symbol					NVARCHAR(MAX),		--심볼 정보
	CONSTRAINT pk_character_symbol_equipment	PRIMARY KEY (ocid)
	);';

--	캐릭터_장착_심볼_정보_이력_테이블
	SET @sql +=N'
	IF OBJECT_ID(N''maple.character_symbol_equipment_hist'',''U'') IS NULL
	CREATE TABLE maple.character_symbol_equipment_hist(
	update_date				DATETIME DEFAULT GETDATE(),
	[date]					NVARCHAR(32),
	ocid					NVARCHAR(64),
	character_class			NVARCHAR(32),
	symbol					NVARCHAR(MAX),
	status					NVARCHAR(2),
	CONSTRAINT pk_character_symbol_equipment_hist	PRIMARY KEY (update_date,ocid)
	);';

-- 캐릭터_적용_세트_효과_정보_테이블
	SET @sql +=N'
	IF OBJECT_ID(N''maple.character_set_effect'',''U'') IS NULL
	CREATE TABLE maple.character_set_effect(
	[date]					NVARCHAR(32),
	ocid					NVARCHAR(64),
	set_effect				NVARCHAR(MAX),		-- 세트 효과 정보
	CONSTRAINT pk_character_set_effect	PRIMARY KEY (ocid)
	);';

-- 캐릭터_적용_세트_효과_정보_이력_테이블
	SET @sql +=N'
	IF OBJECT_ID(N''maple.character_set_effect_hist'',''U'') IS NULL
	CREATE TABLE maple.character_set_effect_hist(
	update_date				DATETIME DEFAULT GETDATE(),
	[date]					NVARCHAR(32),
	ocid					NVARCHAR(64),
	set_effect				NVARCHAR(MAX),
	status					NVARCHAR(2),
	CONSTRAINT pk_character_set_effect_hist	PRIMARY KEY (update_date,ocid)
	);';

-- 캐릭터_외관_정보_테이블
	SET @sql +=N'
	IF OBJECT_ID(N''maple.character_beauty_equipment'',''U'') IS NULL
	CREATE TABLE maple.character_beauty_equipment(
	[date]						NVARCHAR(32),
	ocid						NVARCHAR(64),
	character_gender			NVARCHAR(8),
	character_class				NVARCHAR(32),
	character_hair				NVARCHAR(MAX),		--캐릭터 헤어 정보
	character_face				NVARCHAR(MAX),		--캐릭터 성형 정보
	character_skin				NVARCHAR(MAX),		--캐릭터 피부 정보
	additional_character_hair	NVARCHAR(MAX),		--제로인 경우 베타, 엔젤릭버스터인 경우 드레스 업 모드에 적용 중인 헤어 정보
	additional_character_face	NVARCHAR(MAX),		--제로인 경우 베타, 엔젤릭버스터인 경우 드레스 업 모드에 적용 중인 성형 정보
	additional_character_skin	NVARCHAR(MAX),		--제로인 경우 베타, 엔젤릭버스터인 경우 드레스 업 모드에 적용 중인 피부 정보
	CONSTRAINT pk_character_beauty_equipment	PRIMARY KEY (ocid)
	);';

-- 캐릭터_외관_정보_이력_테이블
	SET @sql +=N'
	IF OBJECT_ID(N''maple.character_beauty_equipment_hist'',''U'') IS NULL
	CREATE TABLE maple.character_beauty_equipment_hist(
	update_date					DATETIME DEFAULT GETDATE(),
	[date]						NVARCHAR(32),
	ocid						NVARCHAR(64),
	character_gender			NVARCHAR(8),
	character_class				NVARCHAR(32),
	character_hair				NVARCHAR(MAX),
	character_face				NVARCHAR(MAX),
	character_skin				NVARCHAR(MAX),
	additional_character_hair	NVARCHAR(MAX),
	additional_character_face	NVARCHAR(MAX),
	additional_character_skin	NVARCHAR(MAX),
	status						NVARCHAR(2),
	CONSTRAINT pk_character_beauty_equipment_hist	PRIMARY KEY (update_date,ocid)
	);';

-- 캐릭터_장착_안드로이드_정보_테이블
	SET @sql +=N'
	IF OBJECT_ID(N''maple.character_android_equipment'',''U'') IS NULL
	CREATE TABLE maple.character_android_equipment(
	[date]							NVARCHAR(32),
	ocid							NVARCHAR(64),
	android_name					NVARCHAR(64),		--안드로이드 명
	android_nickname				NVARCHAR(64),		--안드로이드 닉네임
	android_icon					NVARCHAR(1024),		--안드로이드 아이콘
	android_description				NVARCHAR(1024),		--안드로이드 아이템 설명
	android_hair					NVARCHAR(MAX),		--안드로이드 헤어 정보
	android_face					NVARCHAR(MAX),		--안드로이드 성형 정보
	android_skin					NVARCHAR(MAX),		--안드로이드 피부 정보
	android_cash_item_equipment		NVARCHAR(MAX), 		--안드로이드 캐시 아이템 장착 정보
	android_ear_sensor_clip_flag	NVARCHAR(8),		--안드로이드 이어센서 클립 적용 여부
	android_gender					NVARCHAR(8),		--안드로이드 성별
	android_grade					NVARCHAR(8),		--안드로이드 등급
	android_non_humanoid_flag		NVARCHAR(8),		--비인간형 안드로이드 여부
	android_shop_usable_flag		NVARCHAR(8),		--잡화상점 기능 이용 가능 여부
	preset_no						INT,				--적용 중인 장비 프리셋 번호
	android_preset_1				NVARCHAR(MAX),		--1번 프리셋 안드로이드 정보
	android_preset_2				NVARCHAR(MAX),		--2번 프리셋 안드로이드 정보
	android_preset_3				NVARCHAR(MAX),		--3번 프리셋 안드로이드 정보
	CONSTRAINT pk_character_android_equipment	PRIMARY KEY(ocid)
	);';

-- 캐릭터_장착_안드로이드_정보_이력_테이블
	SET @sql +=N'
	IF OBJECT_ID(N''maple.character_android_equipment_hist'',''U'') IS NULL
	CREATE TABLE maple.character_android_equipment_hist(
	update_date						DATETIME DEFAULT GETDATE(),
	[date]							NVARCHAR(32),
	ocid							NVARCHAR(64),
	android_name					NVARCHAR(64),
	android_nickname				NVARCHAR(64),
	android_icon					NVARCHAR(1024),
	android_description				NVARCHAR(1024),
	android_hair					NVARCHAR(MAX),
	android_face					NVARCHAR(MAX),
	android_skin					NVARCHAR(MAX),
	android_cash_item_equipment		NVARCHAR(MAX), 		--안드로이드 캐시 아이템 장착 정보
	android_ear_sensor_clip_flag	NVARCHAR(8),
	android_gender					NVARCHAR(8),
	android_grade					NVARCHAR(8),
	android_non_humanoid_flag		NVARCHAR(8),
	android_shop_usable_flag		NVARCHAR(8),
	preset_no						INT,
	android_preset_1				NVARCHAR(MAX),
	android_preset_2				NVARCHAR(MAX),
	android_preset_3				NVARCHAR(MAX),
	status							NVARCHAR(2),
	CONSTRAINT	pk_character_android_equipment_hist	PRIMARY KEY (update_date,ocid)
	);';

--  캐릭터_장착_펫_정보_테이블
	SET @sql +=N'
	IF OBJECT_ID(N''maple.character_pet_equipment'',''U'') IS NULL
	CREATE TABLE maple.character_pet_equipment(
	[date]					NVARCHAR(32),
	ocid					NVARCHAR(64),
	pet_1_name				NVARCHAR(64),			--펫1 이름
	pet_1_nickname			NVARCHAR(64),			--펫1 닉네임
	pet_1_icon				NVARCHAR(128),			--펫1 아이콘
	pet_1_description		NVARCHAR(256),			--펫1 설명
	pet_1_equipment			NVARCHAR(MAX),			--펫1 장착 정보
	pet_1_auto_skill		NVARCHAR(MAX),			--펫1 버프 자동스킬 정보
	pet_1_pet_type			NVARCHAR(32),			--펫1 원더 펫 종류
	pet_1_skill				NVARCHAR(32),			--펫1 보유 스킬
	pet_1_date_expire		NVARCHAR(32),			--펫1 마법의 시간 (expired:만료, null:무제한)
	pet_1_appearance		NVARCHAR(128),			--펫1 외형
	pet_1_appearance_icon	NVARCHAR(128),			--펫1 외형 아이콘
	pet_2_name				NVARCHAR(64),			--펫2 이름
	pet_2_nickname			NVARCHAR(64),			--펫2 닉네임
	pet_2_icon				NVARCHAR(128),			--펫2 아이콘
	pet_2_description		NVARCHAR(256),			--펫2 설명
	pet_2_equipment			NVARCHAR(MAX),			--펫2 장착 정보
	pet_2_auto_skill		NVARCHAR(MAX),			--펫2 버프 자동스킬 정보
	pet_2_pet_type			NVARCHAR(32),			--펫2 원더 펫 종류
	pet_2_skill				NVARCHAR(32),			--펫2 보유 스킬
	pet_2_date_expire		NVARCHAR(32),			--펫2 마법의 시간 (expired:만료, null:무제한)
	pet_2_appearance		NVARCHAR(128),			--펫2 외형
	pet_2_appearance_icon	NVARCHAR(128),			--펫2 외형 아이콘
	pet_3_name				NVARCHAR(64),			--펫3 이름
	pet_3_nickname			NVARCHAR(64),			--펫3 닉네임
	pet_3_icon				NVARCHAR(128),			--펫3 아이콘
	pet_3_description		NVARCHAR(256),			--펫3 설명
	pet_3_equipment			NVARCHAR(MAX),			--펫3 장착 정보
	pet_3_auto_skill		NVARCHAR(MAX),			--펫3 버프 자동스킬 정보
	pet_3_pet_type			NVARCHAR(32),			--펫3 원더 펫 종류
	pet_3_skill				NVARCHAR(32),			--펫3 보유 스킬
	pet_3_date_expire		NVARCHAR(32),			--펫3 마법의 시간 (expired:만료, null:무제한)
	pet_3_appearance		NVARCHAR(128),			--펫3 외형
	pet_3_appearance_icon	NVARCHAR(128),			--펫3 외형 아이콘
	CONSTRAINT pk_character_pet_equipment	PRIMARY KEY (ocid)
	);
	';

--	캐릭터_장착_펫_정보_이력_테이블
	SET @sql +=N'
	IF OBJECT_ID(N''maple.character_pet_equipment_hist'',''U'') IS NULL
	CREATE TABLE maple.character_pet_equipment_hist(
	update_date				DATETIME DEFAULT GETDATE(),
	[date]					NVARCHAR(32),
	ocid					NVARCHAR(64),
	pet_1_name				NVARCHAR(64),			--펫1 이름
	pet_1_nickname			NVARCHAR(64),			--펫1 닉네임
	pet_1_icon				NVARCHAR(128),			--펫1 아이콘
	pet_1_description		NVARCHAR(256),			--펫1 설명
	pet_1_equipment			NVARCHAR(MAX),			--펫1 장착 정보
	pet_1_auto_skill		NVARCHAR(MAX),			--펫1 버프 자동스킬 정보
	pet_1_pet_type			NVARCHAR(32),			--펫1 원더 펫 종류
	pet_1_skill				NVARCHAR(32),			--펫1 보유 스킬
	pet_1_date_expire		NVARCHAR(32),			--펫1 마법의 시간 (expired:만료, null:무제한)
	pet_1_appearance		NVARCHAR(128),			--펫1 외형
	pet_1_appearance_icon	NVARCHAR(128),			--펫1 외형 아이콘
	pet_2_name				NVARCHAR(64),			--펫2 이름
	pet_2_nickname			NVARCHAR(64),			--펫2 닉네임
	pet_2_icon				NVARCHAR(128),			--펫2 아이콘
	pet_2_description		NVARCHAR(256),			--펫2 설명
	pet_2_equipment			NVARCHAR(MAX),			--펫2 장착 정보
	pet_2_auto_skill		NVARCHAR(MAX),			--펫2 버프 자동스킬 정보
	pet_2_pet_type			NVARCHAR(32),			--펫2 원더 펫 종류
	pet_2_skill				NVARCHAR(32),			--펫2 보유 스킬
	pet_2_date_expire		NVARCHAR(32),			--펫2 마법의 시간 (expired:만료, null:무제한)
	pet_2_appearance		NVARCHAR(128),			--펫2 외형
	pet_2_appearance_icon	NVARCHAR(128),			--펫2 외형 아이콘
	pet_3_name				NVARCHAR(64),			--펫3 이름
	pet_3_nickname			NVARCHAR(64),			--펫3 닉네임
	pet_3_icon				NVARCHAR(128),			--펫3 아이콘
	pet_3_description		NVARCHAR(256),			--펫3 설명
	pet_3_equipment			NVARCHAR(MAX),			--펫3 장착 정보
	pet_3_auto_skill		NVARCHAR(MAX),			--펫3 버프 자동스킬 정보
	pet_3_pet_type			NVARCHAR(32),			--펫3 원더 펫 종류
	pet_3_skill				NVARCHAR(32),			--펫3 보유 스킬
	pet_3_date_expire		NVARCHAR(32),			--펫3 마법의 시간 (expired:만료, null:무제한)
	pet_3_appearance		NVARCHAR(128),			--펫3 외형
	pet_3_appearance_icon	NVARCHAR(128),			--펫3 외형 아이콘
	status					NVARCHAR(2),
	CONSTRAINT pk_character_pet_equipment_hist	PRIMARY KEY (update_date,ocid)
	);
	';

--	캐릭터_스킬_정보_테이블
	SET @sql +=N'
	IF OBJECT_ID(N''maple.character_skill'',''U'') IS NULL
	CREATE TABLE maple.character_skill(
	[date]					NVARCHAR(32),
	ocid					NVARCHAR(64),
	character_class			NVARCHAR(64),
	character_skill_grade	NVARCHAR(32),				--스킬 전직 차수
	character_skill			NVARCHAR(MAX),				--스킬 정보
	CONSTRAINT pk_character_skill	PRIMARY KEY (ocid)
	);
	';

--	캐릭터_스킬_정보_이력_테이블
	SET @sql +=N'
	IF OBJECT_ID(N''maple.character_skill_hist'',''U'') IS NULL
	CREATE TABLE maple.character_skill_hist(
	update_date				DATETIME DEFAULT GETDATE(),
	[date]					NVARCHAR(32),
	ocid					NVARCHAR(64),
	character_class			NVARCHAR(64),
	character_skill_grade	NVARCHAR(32),
	character_skill			NVARCHAR(MAX),
	status					NVARCHAR(2),
	CONSTRAINT pk_character_skill_hist	PRIMARY KEY (update_date,ocid)
	);
	';

--	캐릭터_장착_링크_스킬_정보_테이블
	SET @sql +=N'
	IF OBJECT_ID(N''maple.character_link_skill'',''U'') IS NULL
	CREATE TABLE maple.character_link_skill(
	[date]								NVARCHAR(32),
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
	CONSTRAINT pk_character_link_skill	PRIMARY KEY (ocid)
	);
	';

--	캐릭터_장착_링크_스킬_정보_이력_테이블
	SET @sql +=N'
	IF OBJECT_ID(N''maple.character_link_skill_hist'',''U'') IS NULL
	CREATE TABLE maple.character_link_skill_hist(
	update_date				DATETIME DEFAULT GETDATE(),
	[date]								NVARCHAR(32),
	ocid								NVARCHAR(64),
	character_class						NVARCHAR(64),
	character_link_skill				NVARCHAR(MAX),
	character_link_skill_preset_1		NVARCHAR(MAX),
	character_link_skill_preset_2		NVARCHAR(MAX),
	character_link_skill_preset_3		NVARCHAR(MAX),
	character_owned_link_skill			NVARCHAR(MAX),
	character_owned_link_skill_preset_1	NVARCHAR(MAX),
	character_owned_link_skill_preset_2	NVARCHAR(MAX),
	character_owned_link_skill_preset_3	NVARCHAR(MAX),
	status								NVARCHAR(2),
	CONSTRAINT pk_character_link_skill_hist	PRIMARY KEY (update_date,ocid)
	);
	';

--	캐릭터_V매트릭스_정보_테이블
	SET @sql +=N'
	IF OBJECT_ID(N''maple.character_vmatrix'',''U'') IS NULL
	CREATE TABLE maple.character_vmatrix (
	[date]											NVARCHAR(32),
	ocid											NVARCHAR(64),
	character_class									NVARCHAR(64),
	character_v_core_equipment						NVARCHAR(MAX),	--V코어 정보
	character_v_matrix_remain_slot_upgrade_point	INT,			--캐릭터 잔여 매트릭스 강화 포인트
	CONSTRAINT pk_character_vmatrix	PRIMARY KEY (ocid)
	);
	';

--	캐릭터_V매트릭스_정보_이력_테이블
	SET @sql +=N'
	IF OBJECT_ID(N''maple.character_vmatrix_hist'',''U'') IS NULL
	CREATE TABLE maple.character_vmatrix_hist (
	update_date										DATETIME DEFAULT GETDATE(),
	[date]											NVARCHAR(32),
	ocid											NVARCHAR(64),
	character_class									NVARCHAR(64),
	character_v_core_equipment						NVARCHAR(MAX),
	character_v_matrix_remain_slot_upgrade_point	INT,
	status											NVARCHAR(2),
	CONSTRAINT pk_character_vmatrix_hist	PRIMARY KEY (update_date,ocid)
	);
	';

-- 	캐릭터_HEXA_코어_정보_테이블
	SET @sql +=N'
	IF OBJECT_ID(N''maple.character_hexamatrix'',''U'') IS NULL
	CREATE TABLE maple.character_hexamatrix	(
	[date]							NVARCHAR(32),
	ocid							NVARCHAR(64),
	character_hexa_core_equipment	NVARCHAR(MAX),				--HEXA 코어 정보
	CONSTRAINT pk_character_hexamatrix	PRIMARY KEY (ocid)
	);
	';

-- 	캐릭터_HEXA_코어_정보_이력_테이블
	SET @sql +=N'
	IF OBJECT_ID(N''maple.character_hexamatrix_hist'',''U'') IS NULL
	CREATE TABLE maple.character_hexamatrix_hist	(
	update_date						DATETIME DEFAULT GETDATE(),
	[date]							NVARCHAR(32),
	ocid							NVARCHAR(64),
	character_hexa_core_equipment	NVARCHAR(MAX),
	status							NVARCHAR(2),
	CONSTRAINT pk_character_hexamatrix_hist	PRIMARY KEY (update_date,ocid)
	);
	';

-- 	캐릭터_HEXA_매트릭스_설정_HEXA_스탯_정보_테이블
	SET @sql +=N'
	IF OBJECT_ID(N''maple.character_hexamatrix_stat'',''U'') IS NULL
	CREATE TABLE maple.character_hexamatrix_stat	(
	[date]							NVARCHAR(32),
	ocid							NVARCHAR(64),
	character_class					NVARCHAR(64),
	character_hexa_stat_core		NVARCHAR(MAX),				--HEXA 스탯 I 코어 정보
	character_hexa_stat_core_2		NVARCHAR(MAX),				--HEXA 스탯 II 코어 정보
	character_hexa_stat_core_3		NVARCHAR(MAX),				--HEXA 스탯 III 코어 정보
	preset_hexa_stat_core			NVARCHAR(MAX),				--프리셋 HEXA 스탯 I 코어 정보
	preset_hexa_stat_core_2			NVARCHAR(MAX),				--프리셋 HEXA 스탯 II 코어 정보
	preset_hexa_stat_core_3			NVARCHAR(MAX),				--프리셋 HEXA 스탯 III 코어 정보
	CONSTRAINT pk_character_hexamatrix_stat	PRIMARY KEY (ocid)
	);
	';

-- 	캐릭터_HEXA_매트릭스_설정_HEXA_스탯_정보_이력_테이블
	SET @sql +=N'
	IF OBJECT_ID(N''maple.character_hexamatrix_stat_hist'',''U'') IS NULL
	CREATE TABLE maple.character_hexamatrix_stat_hist	(
	update_date						DATETIME DEFAULT GETDATE(),
	[date]							NVARCHAR(32),
	ocid							NVARCHAR(64),
	character_class					NVARCHAR(64),
	character_hexa_stat_core		NVARCHAR(MAX),
	character_hexa_stat_core_2		NVARCHAR(MAX),
	character_hexa_stat_core_3		NVARCHAR(MAX),	
	preset_hexa_stat_core			NVARCHAR(MAX),	
	preset_hexa_stat_core_2			NVARCHAR(MAX),		
	preset_hexa_stat_core_3			NVARCHAR(MAX),			
	status							NVARCHAR(2),
	CONSTRAINT pk_character_hexamatrix_stat_hist	PRIMARY KEY (update_date,ocid)
	);
	';

-- 	캐릭터_무릉도장_최고_기록_정보_테이블
	SET @sql +=N'
	IF OBJECT_ID(N''maple.character_dojang'',''U'') IS NULL
	CREATE TABLE maple.character_dojang	(
	[date]							NVARCHAR(32),
	ocid							NVARCHAR(64),
	character_class					NVARCHAR(64),
	world_name						NVARCHAR(64),
	dojang_best_floor				INT,			-- 무릉도장 최고 기록 층수
	date_dojang_record				NVARCHAR(32),	-- 무릉도장 최고 기록 달성 일
	dojang_best_time				INT,			-- 무릉도장 최고 층수 클리어에 걸린 시간(초)
	CONSTRAINT pk_character_dojang	PRIMARY KEY (ocid)
	);
	';

-- 	캐릭터_무릉도장_최고_기록_이력_테이블
	SET @sql +=N'
	IF OBJECT_ID(N''maple.character_dojang_hist'',''U'') IS NULL
	CREATE TABLE maple.character_dojang_hist	(
	update_date						DATETIME DEFAULT GETDATE(),
	[date]							NVARCHAR(32),
	ocid							NVARCHAR(64),
	character_class					NVARCHAR(64),
	world_name						NVARCHAR(64),
	dojang_best_floor				INT,
	date_dojang_record				NVARCHAR(32),
	dojang_best_time				INT,
	status							NVARCHAR(2),
	CONSTRAINT pk_character_dojang_hist	PRIMARY KEY (update_date,ocid)
	);
	';

-- 	기타_능력치_영향_요소_정보_테이블
	SET @sql +=N'
	IF OBJECT_ID(N''maple.character_other_stat'',''U'') IS NULL
	CREATE TABLE maple.character_other_stat	(
	[date]							NVARCHAR(32),
	ocid							NVARCHAR(64),
	other_stat						NVARCHAR(MAX),			--능력치에 영향을 주는 요소 및 스탯 정보
	CONSTRAINT pk_character_other_stat	PRIMARY KEY (ocid)
	);
	';

-- 	기타_능력치_영향_요소_정보_이력_테이블
	SET @sql +=N'
	IF OBJECT_ID(N''maple.character_other_stat_hist'',''U'') IS NULL
	CREATE TABLE maple.character_other_stat_hist	(
	update_date						DATETIME DEFAULT GETDATE(),
	[date]							NVARCHAR(32),
	ocid							NVARCHAR(64),
	other_stat						NVARCHAR(MAX),
	status							NVARCHAR(2),
	CONSTRAINT pk_character_other_stat_hist	PRIMARY KEY (update_date,ocid)
	);
	';

-- 	링_익스체인지_스킬_등록_장비_테이블
	SET @sql +=N'
	IF OBJECT_ID(N''maple.character_ring_exchange_skill_equipment'',''U'') IS NULL
	CREATE TABLE maple.character_ring_exchange_skill_equipment (
	[date]								NVARCHAR(32),
	ocid								NVARCHAR(64),
	character_class						NVARCHAR(64),
	special_ring_exchange_name			NVARCHAR(64),		--링 익스체인지에 등록된 특수 반지
	special_ring_exchange_level			INT,				--링 익스체인지에 등록된 특수 반지 레벨
	special_ring_exchange_icon			NVARCHAR(128),		--링 익스체인지에 등록된 특수 반지 아이콘
	special_ring_exchange_description	NVARCHAR(256),		--링 익스체인지에 등록된 특수 반지 설명
	CONSTRAINT pk_character_ring_exchange_skill_equipment	PRIMARY KEY (ocid)
	);
	';
	
-- 	링_익스체인지_스킬_등록_장비_이력_테이블
	SET @sql +=N'
	IF OBJECT_ID(N''maple.character_ring_exchange_skill_equipment_hist'',''U'') IS NULL
	CREATE TABLE maple.character_ring_exchange_skill_equipment_hist (
	update_date							DATETIME DEFAULT GETDATE(),
	[date]								NVARCHAR(32),
	ocid								NVARCHAR(64),
	character_class						NVARCHAR(64),
	special_ring_exchange_name			NVARCHAR(64),		--링 익스체인지에 등록된 특수 반지
	special_ring_exchange_level			INT,				--링 익스체인지에 등록된 특수 반지 레벨
	special_ring_exchange_icon			NVARCHAR(128),		--링 익스체인지에 등록된 특수 반지 아이콘
	special_ring_exchange_description	NVARCHAR(256),		--링 익스체인지에 등록된 특수 반지 설명
	status								NVARCHAR(2),
	CONSTRAINT pk_character_ring_exchange_skill_equipment_hist	PRIMARY KEY (update_date,ocid)
	);
	';

	BEGIN TRY
-- SQL 실행
		BEGIN TRAN;
		
		EXEC sys.sp_executesql @sql;
		
-- JSON 속성 조회용 VIEW 생성
	
--  1-v1) 캐릭터 목록 JSON 조회용 VIEW 생성 
		EXEC(N'
		CREATE OR ALTER VIEW maple.vw_character_list AS 
		select aoj.*
			from character_list cl
			CROSS APPLY OPENJSON(cl.character_list)
			WITH (
				ocid				NVARCHAR(64),	--캐릭터 식별자
				character_name		NVARCHAR(64),	--캐릭터 명
				world_name			NVARCHAR(8),	--월드 명
				character_class		NVARCHAR(64),	--캐릭터 직업
				character_level		INT				--캐릭터 레벨
				)aoj ;'
		);
	
-- 성공 시 COMMIT	
		COMMIT TRAN;
		

	
	END TRY
	
	BEGIN CATCH
		IF XACT_STATE() <> 0 ROLLBACK TRAN;
	
		-- 에러 메시지 생성용
		THROW;
	END CATCH
END
GO