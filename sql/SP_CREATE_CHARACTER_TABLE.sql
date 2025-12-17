CREATE OR ALTER PROCEDURE maple.SP_CREATE_CHARACTER_TABLE
(
@schema_nm 	NVARCHAR(64) = 'maple'
)
AS 
BEGIN
	SET NOCOUNT ON;
	SET XACT_ABORT ON; -- 런타임 오류 발생 시, ROLLBACK


	
	--테이블 생성 쿼리 변수 선언
	DECLARE @sql NVARCHAR(MAX) = N'';
	
	/*
	 
	 1. 계정정보 조회

	 ---- 구성 테이블 ----
	 
	 - 캐릭터_목록_테이블
	 - 업적_정보_테이블
	 
	 */
	
	
--	캐릭터_목록_테이블
	SET @sql += N'
	IF OBJECT_ID(''' + @schema_nm + N'.character_list'',''U'') IS NULL
	CREATE TABLE '+ @schema_nm + N'.character_list(
	account_id		NVARCHAR(64),
	character_list	NVARCHAR(MAX),		-- 캐릭터 목록
	CONSTRAINT pk_character_list PRIMARY KEY (account_id)
	);';


-- 	업적_정보_테이블
	SET @sql += N'
	IF OBJECT_ID('''+ @schema_nm + N'.user_achievement'',''U'') IS NULL
	CREATE TABLE '+ @schema_nm + N'.user_achievement(
	account_id			NVARCHAR(64),	--메이플스토리 계정 식별자
	achievement_achieve	NVARCHAR(MAX),	--달성 업적 정보
	CONSTRAINT pk_user_achievement PRIMARY KEY (account_id)
	);';


	
-------------------------------------------------------------------------------------

	/*
	 
	 2. Character 캐릭터 정보 조회
	 
	 ---- 구성 테이블 ----
	 
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
	IF OBJECT_ID('''+ @schema_nm +N'.character_basic'',''U'') IS NULL
	CREATE TABLE '+ @schema_nm +N'.character_basic (
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
	IF OBJECT_ID('''+ @schema_nm +N'.character_basic_hist'',''U'') IS NULL
	CREATE TABLE '+ @schema_nm +N'.character_basic_hist (
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
	CONSTRAINT pk_character_basic_hist PRIMARY KEY (update_date,ocid)
	);';

--	캐릭터_인기도_정보_테이블
	SET @sql += N'
	IF OBJECT_ID('''+ @schema_nm +N'.character_popularity'',''U'') IS NULL
	CREATE TABLE '+ @schema_nm +N'.character_popularity (
	[date]			NVARCHAR(32),				--조회기준일
	ocid			NVARCHAR(64),				--캐릭터 식별자
	popularity		INT,						--캐릭터 인기도
	CONSTRAINT pk_character_popularity PRIMARY KEY (ocid),
	CONSTRAINT fk_character_popularity FOREIGN KEY (ocid) REFERENCES maple.character_basic (ocid)
	);';

--	캐릭터_인기도_정보_이력_테이블
	SET @sql += N'
	IF OBJECT_ID('''+ @schema_nm +N'.character_popularity_hist'',''U'') IS NULL
	CREATE TABLE '+ @schema_nm +N'.character_popularity_hist (
	update_date		DATETIME DEFAULT GETDATE(),  	--api 호출 수행 날짜
	[date]			NVARCHAR(32),					--조회기준일
	ocid			NVARCHAR(64),					--캐릭터 식별자
	popularity		INT,							--캐릭터 인기도
	CONSTRAINT pk_character_popularity_hist PRIMARY KEY (update_date,ocid)
	);';

--	캐릭터_종합_능력치_정보_테이블
	SET @sql += N'
	IF OBJECT_ID('''+ @schema_nm +N'.character_stat'',''U'') IS NULL
	CREATE TABLE '+ @schema_nm +N'.character_stat (
	[date]				NVARCHAR(32),			--조회기준일
	ocid				NVARCHAR(64),			--캐릭터 식별자
	character_class		NVARCHAR(64),			--캐릭터 직업
	final_stat			NVARCHAR(MAX),			--현재 스탯 정보
	remain_ap			INT,					--잔여 AP
	CONSTRAINT pk_character_stat PRIMARY KEY (ocid),
	CONSTRAINT fk_character_stat FOREIGN KEY (ocid) REFERENCES maple.character_basic (ocid)
	);';

--	캐릭터_종합_능력지_정보_이력_테이블
	SET @sql += N'
	IF OBJECT_ID('''+ @schema_nm +N'.character_stat_hist'',''U'') IS NULL
	CREATE TABLE '+ @schema_nm +N'.character_stat_hist (
	update_date			DATETIME DEFAULT GETDATE(),  	--api 호출 수행 날짜
	[date]				NVARCHAR(32),					--조회기준일
	ocid				NVARCHAR(64),					--캐릭터 식별자
	character_class		NVARCHAR(64),					--캐릭터 직업
	final_stat			NVARCHAR(MAX),					--현재 스탯 정보
	remain_ap			INT,
	CONSTRAINT pk_character_stat_hist PRIMARY KEY (update_date,ocid)
	);';

--  캐릭터_하이퍼_스탯_정보_테이블
	SET @sql +=N'
	IF OBJECT_ID('''+ @schema_nm +N'.character_hyper_stat'',''U'') IS NULL
	CREATE TABLE '+ @schema_nm +N'.character_hyper_stat(
	[date]								NVARCHAR(32),	--조회기준일
	ocid								NVARCHAR(64),	--캐릭터 식별자
	character_class						NVARCHAR(64),	--캐릭터 직업
	use_preset_no						NVARCHAR(4),	--
	use_available_hyper_stat			INT,
	hyper_stat_preset_1					NVARCHAR(MAX),
	hyper_stat_preset_1_remain_point	INT,
	hyper_stat_preset_2					NVARCHAR(MAX),
	hyper_stat_preset_2_remain_point	INT,
	hyper_stat_preset_3					NVARCHAR(MAX),
	hyper_stat_preset_3_remain_point	INT,
	CONSTRAINT pk_character_hyper_stat PRIMARY KEY (ocid),
	CONSTRAINT fk_character_hyper_stat FOREIGN KEY (ocid) REFERENCES maple.character_basic (ocid)
	);';

--	캐릭터_하이퍼_스탯_정보_이력_테이블
	SET @sql +=N'
	IF OBJECT_ID('''+ @schema_nm +N'.character_hyper_stat_hist'',''U'') IS NULL
	CREATE TABLE '+ @schema_nm +N'.character_hyper_stat_hist(
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
	CONSTRAINT pk_character_hyper_stat_hist PRIMARY KEY (update_date,ocid)
	);';

--  캐릭터_성향_정보_테이블
	SET @sql +=N'
	IF OBJECT_ID('''+ @schema_nm +N'.character_propensity'',''U'') IS NULL
	CREATE TABLE '+ @schema_nm +N'.character_propensity(
	[date]					NVARCHAR(32),
	ocid					NVARCHAR(64),
	charisma_level			INT,
	sensibility_level		INT,
	insight_level			INT,
	willingness_level		INT,
	handicraft_level		INT,
	charm_level				INT,
	CONSTRAINT pk_character_propensity PRIMARY KEY (ocid),
	CONSTRAINT fk_character_propensity FOREIGN KEY (ocid) REFERENCES maple.character_basic (ocid)
	);';

--  캐릭터_성향_정보_이력_테이블
	SET @sql +=N'
	IF OBJECT_ID('''+ @schema_nm +N'.character_propensity_hist'',''U'') IS NULL
	CREATE TABLE '+ @schema_nm +N'.character_propensity_hist(
	update_date				DATETIME DEFAULT GETDATE(),  -- api 호출 수행 날짜
	[date]					NVARCHAR(32),
	ocid					NVARCHAR(64),
	charisma_level			INT,
	sensibility_level		INT,
	insight_level			INT,
	willingness_level		INT,
	handicraft_level		INT,
	charm_level				INT,
	CONSTRAINT pk_character_propensity_hist PRIMARY KEY (update_date,ocid)
	);';

--	캐릭터_어빌리티_정보_테이블
	SET @sql +=N'
	IF OBJECT_ID('''+ @schema_nm +N'.character_ability'',''U'') IS NULL
	CREATE TABLE '+ @schema_nm +N'.character_ability(
	[date]					NVARCHAR(32),
	ocid					NVARCHAR(64),
	ability_grade			NVARCHAR(32),
	ability_info			NVARCHAR(MAX),
	remain_fame				INT,
	preset_no				INT,
	ability_preset_1		NVARCHAR(MAX),
	ability_preset_2		NVARCHAR(MAX),
	ability_preset_3		NVARCHAR(MAX),
	CONSTRAINT pk_character_ability	PRIMARY KEY (ocid),
	CONSTRAINT fk_character_ability FOREIGN KEY (ocid) REFERENCES maple.character_basic (ocid)
	);';

--  캐릭터_어빌리티_정보_이력_테이블
	SET @sql +=N'
	IF OBJECT_ID('''+ @schema_nm +N'.character_ability_hist'',''U'') IS NULL
	CREATE TABLE '+ @schema_nm +N'.character_ability_hist(
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
	CONSTRAINT pk_character_ability_hist	PRIMARY KEY (update_date,ocid)
	);';

--	캐릭터_장착_장비_정보_테이블
	SET @sql +=N'
	IF OBJECT_ID('''+ @schema_nm +N'.character_item_equipment'',''U'') IS NULL
	CREATE TABLE '+ @schema_nm +N'.character_item_equipment(
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
	CONSTRAINT pk_character_item_equipment	PRIMARY KEY (ocid),
	CONSTRAINT fk_character_item_equipment  FOREIGN KEY (ocid) REFERENCES maple.character_basic (ocid)
	);';

--	캐릭터_장착_장비_정보_이력_테이블
	SET @sql +=N'
	IF OBJECT_ID('''+ @schema_nm +N'.character_item_equipment_hist'',''U'') IS NULL
	CREATE TABLE '+ @schema_nm +N'.character_item_equipment_hist(
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
	CONSTRAINT pk_character_item_equipment_hist	PRIMARY KEY (update_date,ocid)
	);';

-- 캐릭터_장착_캐시_장비_정보_테이블
	SET @sql +=N'
	IF OBJECT_ID('''+ @schema_nm +N'.character_cashitem_equipment'',''U'') IS NULL
	CREATE TABLE '+ @schema_nm +N'.character_cashitem_equipment(
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
	CONSTRAINT pk_character_cashitem_equipment	PRIMARY KEY (ocid),
	CONSTRAINT fk_character_cashitem_equipment  FOREIGN KEY (ocid) REFERENCES maple.character_basic (ocid)
	);';

-- 캐릭터_장착_캐시_장비_정보_이력_테이블
	SET @sql +=N'
	IF OBJECT_ID('''+ @schema_nm +N'.character_cashitem_equipment_hist'',''U'') IS NULL
	CREATE TABLE '+ @schema_nm +N'.character_cashitem_equipment_hist(
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
	CONSTRAINT pk_character_cashitem_equipment_hist	PRIMARY KEY (update_date,ocid)
	);';




--	캐릭터_장착_심볼_정보_테이블
	SET @sql +=N'
	IF OBJECT_ID('''+ @schema_nm +N'.character_symbol_equipment'',''U'') IS NULL
	CREATE TABLE '+ @schema_nm +N'.character_symbol_equipment(
	[date]					NVARCHAR(32),
	ocid					NVARCHAR(64),
	character_class			NVARCHAR(32),
	symbol					NVARCHAR(MAX),
	CONSTRAINT pk_character_symbol_equipment	PRIMARY KEY (ocid),
	CONSTRAINT fk_character_symbol_equipment 	FOREIGN KEY (ocid) REFERENCES maple.character_basic (ocid)
	);';

--	캐릭터_장착_심볼_정보_이력_테이블
	SET @sql +=N'
	IF OBJECT_ID('''+ @schema_nm +N'.character_symbol_equipment_hist'',''U'') IS NULL
	CREATE TABLE '+ @schema_nm +N'.character_symbol_equipment_hist(
	update_date				DATETIME DEFAULT GETDATE(),
	[date]					NVARCHAR(32),
	ocid					NVARCHAR(64),
	character_class			NVARCHAR(32),
	symbol					NVARCHAR(MAX),
	CONSTRAINT pk_character_symbol_equipment_hist	PRIMARY KEY (update_date,ocid)
	);';

-- 캐릭터_적용_세트_효과_정보_테이블
	SET @sql +=N'
	IF OBJECT_ID('''+ @schema_nm +N'.character_set_effect'',''U'') IS NULL
	CREATE TABLE '+ @schema_nm +N'.character_set_effect(
	[date]					NVARCHAR(32),
	ocid					NVARCHAR(64),
	set_effect				NVARCHAR(MAX),
	CONSTRAINT pk_character_set_effect	PRIMARY KEY (ocid),
	CONSTRAINT fk_character_set_effect 	FOREIGN KEY (ocid) REFERENCES maple.character_basic (ocid)
	);';

-- 캐릭터_적용_세트_효과_정보_이력_테이블
	SET @sql +=N'
	IF OBJECT_ID('''+ @schema_nm +N'.character_set_effect_hist'',''U'') IS NULL
	CREATE TABLE '+ @schema_nm +N'.character_set_effect_hist(
	update_date				DATETIME DEFAULT GETDATE(),
	[date]					NVARCHAR(32),
	ocid					NVARCHAR(64),
	set_effect				NVARCHAR(MAX),
	CONSTRAINT pk_character_set_effect_hist	PRIMARY KEY (update_date,ocid)
	);';

-- 캐릭터_외관_정보_테이블
	SET @sql +=N'
	IF OBJECT_ID('''+ @schema_nm +N'.character_beauty_equipment'',''U'') IS NULL
	CREATE TABLE '+ @schema_nm +N'.character_beauty_equipment(
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
	CONSTRAINT pk_character_beauty_equipment	PRIMARY KEY (ocid),
	CONSTRAINT fk_character_beauty_equipment 	FOREIGN KEY (ocid) REFERENCES maple.character_basic (ocid)
	);';

-- 캐릭터_외관_정보_이력_테이블
	SET @sql +=N'
	IF OBJECT_ID('''+ @schema_nm +N'.character_beauty_equipment_hist'',''U'') IS NULL
	CREATE TABLE '+ @schema_nm +N'.character_beauty_equipment_hist(
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
	CONSTRAINT pk_character_beauty_equipment_hist	PRIMARY KEY (update_date,ocid)
	);';

-- 캐릭터_장착_안드로이드_정보_테이블
	SET @sql +=N'
	IF OBJECT_ID('''+ @schema_nm +N'.character_android_equipment'',''U'') IS NULL
	CREATE TABLE '+ @schema_nm +N'.character_android_equipment(
	[date]							NVARCHAR(32),
	ocid							NVARCHAR(64),
	android_name					NVARCHAR(64),
	android_nickname				NVARCHAR(64),
	android_icon					NVARCHAR(1024),
	android_description				NVARCHAR(1024),
	android_hair					NVARCHAR(MAX),
	android_face					NVARCHAR(MAX),
	android_skin					NVARCHAR(MAX),
	android_cash_item_equipment		NVARCHAR(MAX), -- 안드로이드 캐시 아이템 장착 정보
	android_ear_sensor_clip_flag	NVARCHAR(8),
	android_gender					NVARCHAR(8),
	android_grade					NVARCHAR(8),
	android_non_humanoid_flag		NVARCHAR(8),
	android_shop_usable_flag		NVARCHAR(8),
	preset_no						INT,
	android_preset_1				NVARCHAR(MAX),
	android_preset_2				NVARCHAR(MAX),
	android_preset_3				NVARCHAR(MAX),
	CONSTRAINT pk_character_android_equipment	PRIMARY KEY(ocid),
	CONSTRAINT fk_character_android_equipment 	FOREIGN KEY (ocid) REFERENCES maple.character_basic (ocid)
	);';

-- 캐릭터_장착_안드로이드_정보_이력_테이블
	SET @sql +=N'
	IF OBJECT_ID('''+ @schema_nm +N'.character_android_equipment_hist'',''U'') IS NULL
	CREATE TABLE '+ @schema_nm +N'.character_android_equipment_hist(
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
	android_cash_item_equipment		NVARCHAR(MAX), -- 안드로이드 캐시 아이템 장착 정보
	android_ear_sensor_clip_flag	NVARCHAR(8),
	android_gender					NVARCHAR(8),
	android_grade					NVARCHAR(8),
	android_non_humanoid_flag		NVARCHAR(8),
	android_shop_usable_flag		NVARCHAR(8),
	preset_no						INT,
	android_preset_1				NVARCHAR(MAX),
	android_preset_2				NVARCHAR(MAX),
	android_preset_3				NVARCHAR(MAX),
	CONSTRAINT	pk_character_android_equipment_hist	PRIMARY KEY (update_date,ocid)
	);';





	BEGIN TRY
-- SQL 실행
		BEGIN TRAN;
		

		EXEC sys.sp_executesql @sql;

	
-- 성공 시 COMMIT	
		COMMIT TRAN;
		
	 /*	
	 
	 3. JSON 데이터 조회 VIEW 

	 ---- 구성 VIEW ----

	 - 캐릭터_목록_조회_VIEW / vw_character_list
	 - 업적_정보_조회_VIEW / vw_user_achievement
	 
	 */
		
		
		
--  캐릭터_목록_조회_VIEW 
	EXEC(N'
		CREATE OR ALTER VIEW ' + @schema_nm +N'.vw_character_list AS 
		select aoj.*
			from ' +@schema_nm+ N'.character_list cl
			CROSS APPLY OPENJSON(cl.character_list)
			WITH (
				ocid				NVARCHAR(64),	--캐릭터 식별자
				character_name		NVARCHAR(64),	--캐릭터 명
				world_name			NVARCHAR(32),	--월드 명
				character_class		NVARCHAR(64),	--캐릭터 직업
				character_level		INT				--캐릭터 레벨
				)aoj ;'
		);

--	업적_정보_조회_VIEW
	EXEC(N'
		CREATE OR ALTER VIEW ' + @schema_nm + N'.vw_user_achievement AS
		SELECT ua.account_id,aoj.*
		FROM '+ @schema_nm + N'.user_achievement ua
		CROSS APPLY OPENJSON(ua.achievement_achieve)
		WITH (
			achievement_name		NVARCHAR(1024),
			achievement_description	NVARCHAR(2048)
			 ) aoj ;' 
		);


	
	END TRY
	
	BEGIN CATCH
		IF XACT_STATE() <> 0 ROLLBACK TRAN;
	
		-- 에러 메시지 생성용
		THROW;
	END CATCH
END
GO