CREATE OR ALTER PROCEDURE SP_CREATE_CHARACTER_TABLE
(
@schema_nm 	   NVARCHAR(64) = 'maple',-- 내부 테이블용 스키마
@pub_schema_nm NVARCHAR(64) = 'pub'   -- 외부 반출용 스키마
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
	 - 캐릭터_무릉도장_최고_기록_정보_이력_테이블
	 - 기타_능력치_영향_요소_정보_테이블
	 - 기타_능력치_영향_요소_정보_이력_테이블
	 - 링_익스체인지_스킬_등록_장비_테이블
	 - 링_익스체인지_스킬_등록_장비_이력_테이블
	 - 예비_특수_반지_장착_정보_테이블
	 - 예비_특수_반지_장착_정보_이력_테이블
	 */

---------------------------------------------------------------------------------------
	 /*	
	 
	 3. JSON 데이터 조회 VIEW 
	character_list는 계정에 생성되어있는 전체 캐릭터를 호출해오고 있는데, 이는 캐릭터 기본정보를 호출해오기 위한 내부 로직용 VIEW로 사용한다.
	그 외 VIEW는 public, 즉 JSON 형식으로 받아온 데이터를 파싱 및 반출하여, BI와 같은 외부 툴에서 사용할 수 있게 한다.
	
	내부에서 사용하기 위한 VIEW는 스키마를 원천 테이블과 동일하게 가져가지만,
	외부 반출용 VIEW는 별도의 외부 반출용 스키마에 생성하여 이를 분리한다.

	 ---- 구성 VIEW ----

	 - 캐릭터_목록_조회_VIEW / vw_character_list (내부용)
	 - 업적_정보_조회_VIEW / vw_user_achievement 		
	 - 캐릭터_기본_정보_HIST_VIEW / vw_character_basic_hist
	 - 캐릭터_적용_어빌리티_VIEW / vw_character_ability
	 - 캐릭터_어빌리티_프리셋_VIEW / vw_character_ability_preset
	 - 헥사매트릭스_조회_VIEW / vw_character_hexamatrix
	 - 헥사매트릭스_스탯_조회_VIEW / vw_character_hexamatrix_stat
	 - 헥사매트릭스_스탯_이력_조회_VIEW / vw_character_hexamatrix_stat_hist
	 - 캐릭터_장착_장비_조회_VIEW / vw_character_item_equipment
	 - 캐릭터_장비_스텟_상세_정보_VIEW / vw_character_item_equipment_detail
	 - 캐릭터_장착_칭호_조회_VIEW / vw_character_title_equipment
	 - 캐릭터_장착_훈장_조회_VIEW / vw_character_medal_equipment
	 - 캐릭터_링크_스킬_조회_VIEW / vw_character_link_skill
	 - 기타_능력치_영향_요소_정보_조회_VIEW / vw_character_other_stat
	 - 무릉도장_최고_기록_정보_HIST_VIEW / vw_character_dojang_hist
	 - 캐릭터_성향정보_VIEW / vw_character_propensity
	 - 캐릭터_적용_세트효과_VIEW / vw_character_apply_set_effect
	 - 적용가능_full_세트효과_VIEW / vw_set_effect_all (내부용)
	 - 캐릭터_스킬_정보_0차_스킬 /vw_character_skill_0
	 - 캐릭터_스킬_정보_1차_스킬 /vw_character_skill_1
	 - 캐릭터_스킬_정보_1.5차_스킬 /vw_character_skill_1_5
	 - 캐릭터_스킬_정보_2차_스킬 /vw_character_skill_2
	 - 캐릭터_스킬_정보_2.5차_스킬 /vw_character_skill_2_5
	 - 캐릭터_스킬_정보_3차_스킬 /vw_character_skill_3
	 - 캐릭터_스킬_정보_4차_스킬 /vw_character_skill_4
	 - 캐릭터_스킬_정보_하이퍼_패시브_스킬 /vw_character_skill_hyp
	 - 캐릭터_스킬_정보_하이퍼_액티브_스킬 /vw_character_skill_hya
	 - 캐릭터_스킬_정보_5차_스킬 /vw_character_skill_5
	 - 캐릭터_스킬_정보_6차_스킬 /vw_character_skill_6
	 - 캐릭터_스탯_정보_VIEW /vw_character_stat
	 - 캐릭터_장착_심볼_정보_VIEW / vw_character_symbol_equipment
	 - 캐릭터_V코어_정보_VIEW /vw_character_vmatrix
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
	CONSTRAINT pk_character_basic_hist PRIMARY KEY (update_date,[date],ocid)
	);';

--	캐릭터_인기도_정보_테이블
	SET @sql += N'
	IF OBJECT_ID('''+ @schema_nm +N'.character_popularity'',''U'') IS NULL
	CREATE TABLE '+ @schema_nm +N'.character_popularity (
	[date]			NVARCHAR(32),				--조회기준일
	ocid			NVARCHAR(64),				--캐릭터 식별자
	popularity		INT,						--캐릭터 인기도
	CONSTRAINT pk_character_popularity PRIMARY KEY (ocid)
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
	CONSTRAINT pk_character_stat PRIMARY KEY (ocid)
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
	CONSTRAINT pk_character_hyper_stat PRIMARY KEY (ocid)
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
	CONSTRAINT pk_character_propensity PRIMARY KEY (ocid)
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
	CONSTRAINT pk_character_ability	PRIMARY KEY (ocid)
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
	CONSTRAINT pk_character_item_equipment	PRIMARY KEY (ocid)
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
	CONSTRAINT pk_character_cashitem_equipment	PRIMARY KEY (ocid)
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
	CONSTRAINT pk_character_symbol_equipment	PRIMARY KEY (ocid)
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
	CONSTRAINT pk_character_set_effect	PRIMARY KEY (ocid)
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
	CONSTRAINT pk_character_beauty_equipment	PRIMARY KEY (ocid)
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
	CONSTRAINT pk_character_android_equipment	PRIMARY KEY(ocid)
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

-- 캐릭터_장착_펫_정보_테이블
	SET @sql +=N'
	IF OBJECT_ID('''+ @schema_nm +N'.character_pet_equipment'',''U'') IS NULL
	CREATE TABLE '+ @schema_nm +N'.character_pet_equipment(
	[date]							NVARCHAR(32),
	ocid							NVARCHAR(64),
	pet_1_name						NVARCHAR(64),
	pet_1_nickname					NVARCHAR(64),
	pet_1_icon						NVARCHAR(1024),
	pet_1_description				NVARCHAR(1024),
	pet_1_equipment					NVARCHAR(MAX),
	pet_1_auto_skill				NVARCHAR(MAX),
	pet_1_pet_type					NVARCHAR(64),
	pet_1_skill						NVARCHAR(128),
	pet_1_date_expire				NVARCHAR(64),
	pet_1_appearance				NVARCHAR(512),
	pet_1_appearance_icon			NVARCHAR(1024),
	pet_2_name						NVARCHAR(64),
	pet_2_nickname					NVARCHAR(64),
	pet_2_icon						NVARCHAR(1024),
	pet_2_description				NVARCHAR(1024),
	pet_2_equipment					NVARCHAR(MAX),
	pet_2_auto_skill				NVARCHAR(MAX),
	pet_2_pet_type					NVARCHAR(64),
	pet_2_skill						NVARCHAR(128),
	pet_2_date_expire				NVARCHAR(64),
	pet_2_appearance				NVARCHAR(512),
	pet_2_appearance_icon			NVARCHAR(1024),
	pet_3_name						NVARCHAR(64),
	pet_3_nickname					NVARCHAR(64),
	pet_3_icon						NVARCHAR(1024),
	pet_3_description				NVARCHAR(1024),
	pet_3_equipment					NVARCHAR(MAX),
	pet_3_auto_skill				NVARCHAR(MAX),
	pet_3_pet_type					NVARCHAR(64),
	pet_3_skill						NVARCHAR(128),
	pet_3_date_expire				NVARCHAR(64),
	pet_3_appearance				NVARCHAR(512),
	pet_3_appearance_icon			NVARCHAR(1024),
	CONSTRAINT pk_character_pet_equipment	PRIMARY KEY(ocid)
	);';

-- 캐릭터_장착_펫_정보_이력_테이블
	SET @sql +=N'
	IF OBJECT_ID('''+ @schema_nm +N'.character_pet_equipment_hist'',''U'') IS NULL
	CREATE TABLE '+ @schema_nm +N'.character_pet_equipment_hist(
	update_date						DATETIME DEFAULT GETDATE(),
	[date]							NVARCHAR(32),
	ocid							NVARCHAR(64),
	pet_1_name						NVARCHAR(64),
	pet_1_nickname					NVARCHAR(64),
	pet_1_icon						NVARCHAR(1024),
	pet_1_description				NVARCHAR(1024),
	pet_1_equipment					NVARCHAR(MAX),
	pet_1_auto_skill				NVARCHAR(MAX),
	pet_1_pet_type					NVARCHAR(64),
	pet_1_skill						NVARCHAR(128),
	pet_1_date_expire				NVARCHAR(64),
	pet_1_appearance				NVARCHAR(512),
	pet_1_appearance_icon			NVARCHAR(1024),
	pet_2_name						NVARCHAR(64),
	pet_2_nickname					NVARCHAR(64),
	pet_2_icon						NVARCHAR(1024),
	pet_2_description				NVARCHAR(1024),
	pet_2_equipment					NVARCHAR(MAX),
	pet_2_auto_skill				NVARCHAR(MAX),
	pet_2_pet_type					NVARCHAR(64),
	pet_2_skill						NVARCHAR(128),
	pet_2_date_expire				NVARCHAR(64),
	pet_2_appearance				NVARCHAR(512),
	pet_2_appearance_icon			NVARCHAR(1024),
	pet_3_name						NVARCHAR(64),
	pet_3_nickname					NVARCHAR(64),
	pet_3_icon						NVARCHAR(1024),
	pet_3_description				NVARCHAR(1024),
	pet_3_equipment					NVARCHAR(MAX),
	pet_3_auto_skill				NVARCHAR(MAX),
	pet_3_pet_type					NVARCHAR(64),
	pet_3_skill						NVARCHAR(128),
	pet_3_date_expire				NVARCHAR(64),
	pet_3_appearance				NVARCHAR(512),
	pet_3_appearance_icon			NVARCHAR(1024),
	CONSTRAINT	pk_character_pet_equipment_hist	PRIMARY KEY (update_date,ocid)
	);';

-- 캐릭터_스킬_정보_테이블
	SET @sql +=N'
	IF OBJECT_ID('''+ @schema_nm +N'.character_skill'',''U'') IS NULL
	CREATE TABLE '+ @schema_nm +N'.character_skill(
	[date]							NVARCHAR(32),
	ocid							NVARCHAR(64),
	character_class					NVARCHAR(64),
	character_skill_grade			NVARCHAR(32),
	character_skill					NVARCHAR(MAX),
	CONSTRAINT pk_character_skill	PRIMARY KEY(ocid,character_skill_grade)
	);';

-- 캐릭터_스킬_정보_이력_테이블
	SET @sql +=N'
	IF OBJECT_ID('''+ @schema_nm +N'.character_skill_hist'',''U'') IS NULL
	CREATE TABLE '+ @schema_nm +N'.character_skill_hist(
	update_date						DATETIME DEFAULT GETDATE(),
	[date]							NVARCHAR(32),
	ocid							NVARCHAR(64),
	character_class					NVARCHAR(64),
	character_skill_grade			NVARCHAR(32),
	character_skill					NVARCHAR(MAX),
	CONSTRAINT	pk_character_skill_hist	PRIMARY KEY (update_date,ocid,character_skill_grade)
	);';

-- 캐릭터_장착_링크_스킬_정보_테이블
	SET @sql +=N'
	IF OBJECT_ID('''+ @schema_nm +N'.character_link_skill'',''U'') IS NULL
	CREATE TABLE '+ @schema_nm +N'.character_link_skill(
	[date]								NVARCHAR(32),
	ocid								NVARCHAR(64),
	character_class						NVARCHAR(64),
	character_link_skill				NVARCHAR(MAX),  --링크 스킬 정보
	character_link_skill_preset_1		NVARCHAR(MAX),  --링크 스킬 1번 프리셋
	character_link_skill_preset_2		NVARCHAR(MAX),  --링크 스킬 2번 프리셋
	character_link_skill_preset_3		NVARCHAR(MAX),  --링크 스킬 3번 프리셋
	character_owned_link_skill			NVARCHAR(MAX),
	character_owned_link_skill_preset_1	NVARCHAR(MAX),
	character_owned_link_skill_preset_2	NVARCHAR(MAX),
	character_owned_link_skill_preset_3	NVARCHAR(MAX),
	CONSTRAINT pk_character_link_skill	PRIMARY KEY(ocid)
	);';

-- 캐릭터_장착_링크_스킬_정보_테이블
	SET @sql +=N'
	IF OBJECT_ID('''+ @schema_nm +N'.character_link_skill_hist'',''U'') IS NULL
	CREATE TABLE '+ @schema_nm +N'.character_link_skill_hist(
	update_date							DATETIME DEFAULT GETDATE(),
	[date]								NVARCHAR(32),
	ocid								NVARCHAR(64),
	character_class						NVARCHAR(64),
	character_link_skill				NVARCHAR(MAX),  --링크 스킬 정보
	character_link_skill_preset_1		NVARCHAR(MAX),  --링크 스킬 1번 프리셋
	character_link_skill_preset_2		NVARCHAR(MAX),  --링크 스킬 2번 프리셋
	character_link_skill_preset_3		NVARCHAR(MAX),  --링크 스킬 3번 프리셋
	character_owned_link_skill			NVARCHAR(MAX),
	character_owned_link_skill_preset_1	NVARCHAR(MAX),
	character_owned_link_skill_preset_2	NVARCHAR(MAX),
	character_owned_link_skill_preset_3	NVARCHAR(MAX),
	CONSTRAINT	pk_character_link_skill_hist	PRIMARY KEY (update_date,ocid)
	);';

-- 캐릭터_V매트릭스_정보_테이블
	SET @sql +=N'
	IF OBJECT_ID('''+ @schema_nm +N'.character_vmatrix'',''U'') IS NULL
	CREATE TABLE '+ @schema_nm +N'.character_vmatrix(
	[date]											NVARCHAR(32),
	ocid											NVARCHAR(64),
	character_class									NVARCHAR(64),
	character_v_core_equipment						NVARCHAR(MAX),
	character_v_matrix_remain_slot_upgrade_point	INT,
	CONSTRAINT pk_character_vmatrix	PRIMARY KEY(ocid)
	);';

-- 캐릭터_V매트릭스_정보_이력_테이블
	SET @sql +=N'
	IF OBJECT_ID('''+ @schema_nm +N'.character_vmatrix_hist'',''U'') IS NULL
	CREATE TABLE '+ @schema_nm +N'.character_vmatrix_hist(
	update_date										DATETIME DEFAULT GETDATE(),
	[date]											NVARCHAR(32),
	ocid											NVARCHAR(64),
	character_class									NVARCHAR(64),
	character_v_core_equipment						NVARCHAR(MAX),
	character_v_matrix_remain_slot_upgrade_point	INT,
	CONSTRAINT pk_character_vmatrix_hist	PRIMARY KEY(update_date,ocid)
	);';

-- 캐릭터_HEXA_코어_정보_테이블
	SET @sql +=N'
	IF OBJECT_ID('''+ @schema_nm +N'.character_hexamatrix'',''U'') IS NULL
	CREATE TABLE '+ @schema_nm +N'.character_hexamatrix(
	[date]								NVARCHAR(32),
	ocid								NVARCHAR(64),
	character_hexa_core_equipment		NVARCHAR(MAX),		
	CONSTRAINT pk_character_hexamatrix	PRIMARY KEY(ocid)
	);';

-- 캐릭터_HEXA_코어_정보_이력_테이블
	SET @sql +=N'
	IF OBJECT_ID('''+ @schema_nm +N'.character_hexamatrix_hist'',''U'') IS NULL
	CREATE TABLE '+ @schema_nm +N'.character_hexamatrix_hist(
	update_date							DATETIME DEFAULT GETDATE(),
	[date]								NVARCHAR(32),
	ocid								NVARCHAR(64),
	character_hexa_core_equipment		NVARCHAR(MAX),		
	CONSTRAINT pk_character_hexamatrix_hist	PRIMARY KEY(update_date,ocid)
	);';

--	캐릭터_HEXA_매트릭스_설정_HEXA_스탯_정보_테이블
	SET @sql +=N'
	IF OBJECT_ID('''+ @schema_nm +N'.character_hexamatrix_stat'',''U'') IS NULL
	CREATE TABLE '+ @schema_nm +N'.character_hexamatrix_stat(
	[date]						NVARCHAR(32),
	ocid						NVARCHAR(64),
	character_class				NVARCHAR(64),
	character_hexa_stat_core	NVARCHAR(MAX),
	character_hexa_stat_core_2	NVARCHAR(MAX),
	character_hexa_stat_core_3	NVARCHAR(MAX),
	preset_hexa_stat_core		NVARCHAR(MAX),
	preset_hexa_stat_core_2		NVARCHAR(MAX),
	preset_hexa_stat_core_3		NVARCHAR(MAX),
	CONSTRAINT pk_character_hexamatrix_stat	PRIMARY KEY(ocid)
	);';

-- 캐릭터_HEXA_매트릭스_설정_HEXA_스탯_정보_이력_테이블
	SET @sql +=N'
	IF OBJECT_ID('''+ @schema_nm +N'.character_hexamatrix_stat_hist'',''U'') IS NULL
	CREATE TABLE '+ @schema_nm +N'.character_hexamatrix_stat_hist(
	update_date					DATETIME DEFAULT GETDATE(),
	[date]						NVARCHAR(32),
	ocid						NVARCHAR(64),
	character_class				NVARCHAR(64),
	character_hexa_stat_core	NVARCHAR(MAX),
	character_hexa_stat_core_2	NVARCHAR(MAX),
	character_hexa_stat_core_3	NVARCHAR(MAX),
	preset_hexa_stat_core		NVARCHAR(MAX),
	preset_hexa_stat_core_2		NVARCHAR(MAX),
	preset_hexa_stat_core_3		NVARCHAR(MAX),
	CONSTRAINT pk_character_hexamatrix_stat_hist	PRIMARY KEY(update_date,ocid)
	);';

--	캐릭터_무릉도장_최고_기록_정보_테이블
	SET @sql +=N'
	IF OBJECT_ID('''+ @schema_nm +N'.character_dojang'',''U'') IS NULL
	CREATE TABLE '+ @schema_nm +N'.character_dojang(
	[date]						NVARCHAR(32),
	ocid						NVARCHAR(64),
	character_class				NVARCHAR(64),
	world_name					NVARCHAR(32),
	dojang_best_floor			INT,
	date_dojang_record			NVARCHAR(32),
	dojang_best_time			INT,
	CONSTRAINT pk_character_dojang	PRIMARY KEY(ocid)
	);';

-- 캐릭터_무릉도장_최고_기록_정보_이력_테이블
	SET @sql +=N'
	IF OBJECT_ID('''+ @schema_nm +N'.character_dojang_hist'',''U'') IS NULL
	CREATE TABLE '+ @schema_nm +N'.character_dojang_hist(
	update_date					DATETIME DEFAULT GETDATE(),
	[date]						NVARCHAR(32),
	ocid						NVARCHAR(64),
	character_class				NVARCHAR(64),
	world_name					NVARCHAR(32),
	dojang_best_floor			INT,
	date_dojang_record			NVARCHAR(32),
	dojang_best_time			INT,
	CONSTRAINT pk_character_dojang_hist	PRIMARY KEY(update_date,ocid)
	);';

--	기타_능력치_영향_요소_정보_테이블
	SET @sql +=N'
	IF OBJECT_ID('''+ @schema_nm +N'.character_other_stat'',''U'') IS NULL
	CREATE TABLE '+ @schema_nm +N'.character_other_stat(
	[date]				NVARCHAR(32),
	ocid				NVARCHAR(64),
	other_stat			NVARCHAR(MAX),
	CONSTRAINT pk_character_other_stat	PRIMARY KEY(ocid)
	);';

-- 기타_능력치_영향_요소_정보_이력_테이블
	SET @sql +=N'
	IF OBJECT_ID('''+ @schema_nm +N'.character_other_stat_hist'',''U'') IS NULL
	CREATE TABLE '+ @schema_nm +N'.character_other_stat_hist(
	update_date			DATETIME DEFAULT GETDATE(),
	[date]				NVARCHAR(32),
	ocid				NVARCHAR(64),
	other_stat			NVARCHAR(MAX),
	CONSTRAINT pk_character_other_stat_hist PRIMARY KEY (update_date,ocid)
	);';

--	링_익스체인지_스킬_등록_장비_테이블
	SET @sql +=N'
	IF OBJECT_ID('''+ @schema_nm +N'.character_ring_exchange_skill_equipment'',''U'') IS NULL
	CREATE TABLE '+ @schema_nm +N'.character_ring_exchange_skill_equipment(
	[date]								NVARCHAR(32),
	ocid								NVARCHAR(64),
	character_class						NVARCHAR(64),
	special_ring_exchange_name			NVARCHAR(64),
	special_ring_exchange_level			INT,
	special_ring_exchange_icon			NVARCHAR(1024),
	special_ring_exchange_description	NVARCHAR(1024),
	CONSTRAINT pk_character_ring_exchange_skill_equipment	PRIMARY KEY(ocid)
	);';

-- 링_익스체인지_스킬_등록_장비_이력_테이블
	SET @sql +=N'
	IF OBJECT_ID('''+ @schema_nm +N'.character_ring_exchange_skill_equipment_hist'',''U'') IS NULL
	CREATE TABLE '+ @schema_nm +N'.character_ring_exchange_skill_equipment_hist(
	update_date					DATETIME DEFAULT GETDATE(),
	[date]								NVARCHAR(32),
	ocid								NVARCHAR(64),
	character_class						NVARCHAR(64),
	special_ring_exchange_name			NVARCHAR(64),
	special_ring_exchange_level			INT,
	special_ring_exchange_icon			NVARCHAR(1024),
	special_ring_exchange_description	NVARCHAR(1024),
	CONSTRAINT pk_character_ring_exchange_skill_equipment_hist PRIMARY KEY (update_date,ocid)
	);';

--	예비_특수_반지_장착_정보_테이블
	SET @sql +=N'
	IF OBJECT_ID('''+ @schema_nm +N'.character_ring_reserve_skill_equipment'',''U'') IS NULL
	CREATE TABLE '+ @schema_nm +N'.character_ring_reserve_skill_equipment(
	[date]								NVARCHAR(32),
	ocid								NVARCHAR(64),
	character_class						NVARCHAR(64),
	special_ring_reserve_name			NVARCHAR(64),
	special_ring_reserve_level			INT,
	special_ring_reserve_icon			NVARCHAR(1024),
	special_ring_reserve_description	NVARCHAR(1024),
	CONSTRAINT pk_character_ring_reserve_skill_equipment	PRIMARY KEY(ocid)
	);';

-- 예비_특수_반지_장착_정보_이력_테이블
	SET @sql +=N'
	IF OBJECT_ID('''+ @schema_nm +N'.character_ring_reserve_skill_equipment_hist'',''U'') IS NULL
	CREATE TABLE '+ @schema_nm +N'.character_ring_reserve_skill_equipment_hist(
	update_date					DATETIME DEFAULT GETDATE(),
	[date]								NVARCHAR(32),
	ocid								NVARCHAR(64),
	character_class						NVARCHAR(64),
	special_ring_reserve_name			NVARCHAR(64),
	special_ring_reserve_level			INT,
	special_ring_reserve_icon			NVARCHAR(1024),
	special_ring_reserve_description	NVARCHAR(1024),
	CONSTRAINT pk_character_ring_reserve_skill_equipment_hist PRIMARY KEY (update_date,ocid)
	);';


	BEGIN TRY
-- SQL 실행
		BEGIN TRAN;
		

		EXEC sys.sp_executesql @sql;

	
-- 성공 시 COMMIT	
		COMMIT TRAN;
		
--------------------------외부 반출용 VIEW 생성 쿼리--------------------------------

		
--  캐릭터_목록_조회_VIEW 
	EXEC(N'
		CREATE OR ALTER VIEW ' + @schema_nm +N'.vw_character_list AS 
		SELECT 
			aoj.ocid,                        --캐릭터 식별 ID
			aoj.character_name,				 --캐릭터명
			aoj.world_name,					 --월드명
			aoj.character_class,			 --캐릭터 직업
			aoj.character_level				 --캐릭터 레벨
		FROM ' +@schema_nm+ N'.character_list cl
		CROSS APPLY OPENJSON(cl.character_list)
		WITH (
			ocid				NVARCHAR(64),	
			character_name		NVARCHAR(64),	
			world_name			NVARCHAR(32),	
			character_class		NVARCHAR(64),	
			character_level		INT				
			)aoj ;'
		);

--	업적_정보_조회_VIEW
	EXEC(N'
		CREATE OR ALTER VIEW ' + @pub_schema_nm + N'.vw_user_achievement AS
		SELECT 
			ua.account_id,
			aoj.achievement_name,
			aoj.achievement_description
		FROM '+ @schema_nm + N'.user_achievement ua
		CROSS APPLY OPENJSON(ua.achievement_achieve)
		WITH (
			achievement_name		NVARCHAR(1024),
			achievement_description	NVARCHAR(2048)
			 ) aoj ;' 
		);

-- 캐릭터_기본_정보_HIST_VIEW
	EXEC(N'
		CREATE OR ALTER VIEW ' + @pub_schema_nm +N'.vw_character_basic_hist AS 
		SELECT 
			cbh.[date],
			cbh.character_name, 
			cbh.world_name, 
			cbh.character_gender, 
			cbh.character_class, 
			cbh.character_class_level, 
			cbh.character_level, 
			cbh.character_exp, 
			cbh.character_exp_rate, 
			cbh.character_guild_name, 
			cbh.character_image, 
			cbh.character_date_create, 
			cbh.access_flag, 
			cbh.liberation_quest_clear
		FROM ' +@schema_nm+ '.character_basic_hist cbh ; '
		) ;



--  캐릭터_적용_어빌리티_VIEW
	EXEC(N'
		CREATE OR ALTER VIEW ' + @pub_schema_nm + N'.vw_character_ability AS
		SELECT 
			ca.date,                                --조회 기준일
			cb.character_name,						--캐릭터 명
			ca.preset_no AS "using_preset_no",		--사용중인 프리셋 번호
			ca.ability_grade,						--어빌리티 등급
			ca.remain_fame AS "remain_fame",		--잔여 명성치
			aoj.ability_no AS "locate_no",			--어빌리티번호(순서)
			aoj.ability_grade "ability_per_grade",	--각 번호별 어빌리티 등급
			aoj.ability_value						--어빌리티 값
		FROM '+ @schema_nm+'.character_basic cb
		INNER JOIN '+@schema_nm+'.character_ability ca ON cb.ocid = ca.ocid
		CROSS APPLY OPENJSON(ca.ability_info)
		WITH (
			ability_no 	INT,
	  		ability_grade	NVARCHAR(32),
	  		ability_value NVARCHAR(256)
			 ) aoj ; '
		);

-- 캐릭터_어빌리티_프리셋_VIEW
/*
 캐릭터 어빌리티 프리셋의 경우 ability_preset_1,ability_preset_2,ability_preset_3을 각각 JSON 파싱하여 테이블로 만들고, 이를 UNION하여 프리셋 별로 한눈에 볼 수 있도록 VIEW를 생성
 */
	EXEC(N'
		CREATE OR ALTER VIEW ' + @pub_schema_nm + N'.vw_character_ability_preset AS 
		SELECT
			cb.character_name,																		--캐릭터 명
			1 AS "ability_preset_no",																--어빌리티 프리셋 번호
			JSON_VALUE(ca.ability_preset_1,''$.ability_preset_grade'') AS "ability_preset_grade",	--첫번째 어빌리티 프리셋 등급
			aoj.ability_no,																			--첫번째 프리셋 어빌리티 순서
			aoj.ability_grade,																		--어빌리티 등급
			aoj.ability_value																		--어빌리티 값
		FROM '+@schema_nm+ '.character_basic cb
		INNER JOIN '+@schema_nm+ '.character_ability ca on cb.ocid = ca.ocid
		CROSS APPLY OPENJSON(ca.ability_preset_1, ''$.ability_info'') 
		WITH (
	  		ability_no 	INT,
	 		ability_grade NVARCHAR(64),
	  		ability_value NVARCHAR(128)
	 		) aoj
		UNION ALL
		SELECT
			cb.character_name,																
			2 AS "ability_preset_no",														
			JSON_VALUE(ca.ability_preset_2,''$.ability_preset_grade'') AS "ability_preset_grade",
			aoj.ability_no,
			aoj.ability_grade,
			aoj.ability_value
		FROM ' + @schema_nm + '.character_basic cb
		INNER JOIN ' +@schema_nm+ '.character_ability ca on cb.ocid = ca.ocid
		CROSS APPLY OPENJSON(ca.ability_preset_2, ''$.ability_info'') 
		WITH (
	  		ability_no 	INT,
	  		ability_grade NVARCHAR(64),
	  		ability_value NVARCHAR(128)
	 		) aoj
		UNION ALL
		SELECT
			cb.character_name,
			3 AS "ability_preset_no",
			JSON_VALUE(ca.ability_preset_3,''$.ability_preset_grade'') AS "ability_preset_grade",
			aoj.ability_no,
			aoj.ability_grade,
			aoj.ability_value
		FROM ' +@schema_nm+ '.character_basic cb
		INNER JOIN ' +@schema_nm+ '.character_ability ca on cb.ocid = ca.ocid
		CROSS APPLY OPENJSON(ca.ability_preset_3, ''$.ability_info'') 
		WITH (
	  		ability_no 	INT,
	  		ability_grade NVARCHAR(64),
	  		ability_value NVARCHAR(128)
	 		) aoj ; '  
		);

-- 헥사매트릭스_조회_VIEW
	EXEC(N'
		CREATE OR ALTER VIEW ' + @pub_schema_nm + N'.vw_character_hexamatrix AS
		SELECT 
			chx.[date],
			cb.character_name,
			aoj.hexa_core_name,
			aoj.hexa_core_level,
			aoj.hexa_core_type,
			aoj2.hexa_skill_id
		FROM ' +@schema_nm+ '.character_basic cb
		INNER JOIN ' +@schema_nm+ '.character_hexamatrix chx ON cb.ocid=chx.ocid
		CROSS APPLY OPENJSON(chx.character_hexa_core_equipment)
		WITH (
			hexa_core_name		NVARCHAR(128),
			hexa_core_level		INT,
			hexa_core_type		NVARCHAR(64),
	 		linked_skill 			NVARCHAR(MAX) AS JSON
	 		) aoj
		CROSS APPLY OPENJSON(aoj.linked_skill)
		WITH (
	 		hexa_skill_id		NVARCHAR(256)
			) aoj2 ; '
		);

-- 헥사매트릭스_스탯_조회_VIEW
	EXEC(N'
		CREATE OR ALTER VIEW ' + @pub_schema_nm + N'.vw_character_hexamatrix_stat AS
		SELECT 
			chxs.date,
			cb.character_name,
			cb.character_class,
			''1'' 				AS "hexa_stat_id",
			aoj.stat_grade,
			aoj.main_stat_name,
			aoj.main_stat_level,
			aoj.sub_stat_name_1,
			aoj.sub_stat_level_1,
			aoj.sub_stat_name_2,
			aoj.sub_stat_level_2
		FROM ' +@schema_nm+ '.character_basic cb
		INNER JOIN ' +@schema_nm+ '.character_hexamatrix_stat chxs ON cb.ocid=chxs.ocid
		CROSS APPLY OPENJSON(character_hexa_stat_core) 
		WITH (
			slot_id				NVARCHAR(1),
			main_stat_name  	NVARCHAR(128),
			sub_stat_name_1 	NVARCHAR(128),
			sub_stat_name_2 	NVARCHAR(128),
			main_stat_level 	INT,
			sub_stat_level_1	INT,
			sub_stat_level_2	INT,
			stat_grade			INT
			) aoj
		WHERE  chxs.character_hexa_stat_core <> ''[]''  --핵사 스탯이 없는 경우 VIEW에서 제외하기 위함  
		UNION ALL
		SELECT 
			chxs.date,
			cb.character_name,
			cb.character_class,
			''2'' 				AS "hexa_stat_id",
			aoj.stat_grade,
			aoj.main_stat_name,
			aoj.main_stat_level,
			aoj.sub_stat_name_1,
			aoj.sub_stat_level_1,
			aoj.sub_stat_name_2,
			aoj.sub_stat_level_2
		FROM ' +@schema_nm+ '.character_basic cb
		INNER JOIN ' +@schema_nm+ '.character_hexamatrix_stat chxs ON cb.ocid=chxs.ocid
		CROSS APPLY OPENJSON(character_hexa_stat_core_2) 
		WITH (
			slot_id				NVARCHAR(1),
			main_stat_name  	NVARCHAR(128),
			sub_stat_name_1 	NVARCHAR(128),
			sub_stat_name_2 	NVARCHAR(128),
			main_stat_level 	INT,
			sub_stat_level_1	INT,
			sub_stat_level_2	INT,
			stat_grade			INT
			) aoj
		WHERE  chxs.character_hexa_stat_core_2 <> ''[]''
		UNION ALL
		SELECT 
			chxs.date,
			cb.character_name,
			cb.character_class,
			''3''				AS "hexa_stat_id",
			aoj.stat_grade,
			aoj.main_stat_name,
			aoj.main_stat_level,
			aoj.sub_stat_name_1,
			aoj.sub_stat_level_1,
			aoj.sub_stat_name_2,
			aoj.sub_stat_level_2
		FROM ' +@schema_nm+ '.character_basic cb
		INNER JOIN ' +@schema_nm+ '.character_hexamatrix_stat chxs ON cb.ocid=chxs.ocid
		CROSS APPLY OPENJSON(character_hexa_stat_core_3) 
		WITH (
			slot_id				NVARCHAR(1),
			main_stat_name  	NVARCHAR(128),
			sub_stat_name_1 	NVARCHAR(128),
			sub_stat_name_2 	NVARCHAR(128),
			main_stat_level 	INT,
			sub_stat_level_1	INT,
			sub_stat_level_2	INT,
			stat_grade			INT
			) aoj
		WHERE  chxs.character_hexa_stat_core_3 <> ''[]''  --핵사 스탯이 없는 경우 VIEW에서 제외하기 위함  --핵사 스탯이 없는 경우 VIEW에서 제외하기 위함
			; '
		);

-- 헥사매트릭스_스탯_이력_조회_VIEW
	EXEC(N'
		CREATE OR ALTER VIEW ' + @pub_schema_nm + N'.vw_character_hexamatrix_stat_hist AS
		SELECT 
			cbh.date,
			cbh.character_name,
			cbh.character_class,
			cbh.character_level,
			''1'' 				AS "hexa_stat_core",
			aoj.slot_id,
			aoj.main_stat_name,
			aoj.sub_stat_name_1,
			aoj.sub_stat_name_2,
			aoj.main_stat_level,
			aoj.sub_stat_level_1,
			aoj.sub_stat_level_2,
			aoj.stat_grade
		FROM ' +@schema_nm+ '.character_basic_hist cbh
		INNER JOIN ' +@schema_nm+ '.character_hexamatrix_stat_hist chxsh ON cbh.ocid=chxsh.ocid AND cbh.[date]=chxsh.[date]
		CROSS APPLY OPENJSON(character_hexa_stat_core) 
		WITH (
			slot_id				NVARCHAR(1),
			main_stat_name  	NVARCHAR(128),
			sub_stat_name_1 	NVARCHAR(128),
			sub_stat_name_2 	NVARCHAR(128),
			main_stat_level 	INT,
			sub_stat_level_1	INT,
			sub_stat_level_2	INT,
			stat_grade			INT
			) aoj
		WHERE  chxsh.character_hexa_stat_core <> ''[]''  --핵사 스탯이 없는 경우 VIEW에서 제외하기 위함  
		UNION ALL
		SELECT 
			cbh.date,
			cbh.character_name,
			cbh.character_class,
			cbh.character_level,
			''2'' 				AS "hexa_stat_core",
			aoj.slot_id,
			aoj.main_stat_name,
			aoj.sub_stat_name_1,
			aoj.sub_stat_name_2,
			aoj.main_stat_level,
			aoj.sub_stat_level_1,
			aoj.sub_stat_level_2,
			aoj.stat_grade
		FROM ' +@schema_nm+ '.character_basic_hist cbh
		INNER JOIN ' +@schema_nm+ '.character_hexamatrix_stat_hist chxsh ON cbh.ocid=chxsh.ocid AND cbh.[date]=chxsh.[date]
		CROSS APPLY OPENJSON(character_hexa_stat_core_2) 
		WITH (
			slot_id				NVARCHAR(1),
			main_stat_name  	NVARCHAR(128),
			sub_stat_name_1 	NVARCHAR(128),
			sub_stat_name_2 	NVARCHAR(128),
			main_stat_level 	INT,
			sub_stat_level_1	INT,
			sub_stat_level_2	INT,
			stat_grade			INT
			) aoj
		WHERE  chxsh.character_hexa_stat_core_2 <> ''[]''
		UNION ALL
		SELECT 
			cbh.date,
			cbh.character_name,
			cbh.character_class,
			cbh.character_level,
			''3'' 				AS "hexa_stat_core",
			aoj.slot_id,
			aoj.main_stat_name,
			aoj.sub_stat_name_1,
			aoj.sub_stat_name_2,
			aoj.main_stat_level,
			aoj.sub_stat_level_1,
			aoj.sub_stat_level_2,
			aoj.stat_grade
		FROM ' +@schema_nm+ '.character_basic_hist cbh
		INNER JOIN ' +@schema_nm+ '.character_hexamatrix_stat_hist chxsh ON cbh.ocid=chxsh.ocid AND cbh.[date]=chxsh.[date]
		CROSS APPLY OPENJSON(character_hexa_stat_core_3) 
		WITH (
			slot_id				NVARCHAR(1),
			main_stat_name  	NVARCHAR(128),
			sub_stat_name_1 	NVARCHAR(128),
			sub_stat_name_2 	NVARCHAR(128),
			main_stat_level 	INT,
			sub_stat_level_1	INT,
			sub_stat_level_2	INT,
			stat_grade			INT
			) aoj
		WHERE  chxsh.character_hexa_stat_core_3 <> ''[]''  --핵사 스탯이 없는 경우 VIEW에서 제외하기 위함  --핵사 스탯이 없는 경우 VIEW에서 제외하기 위함
			; '
		);


-- 캐릭터_장착_장비_조회_VIEW
	EXEC(N' 
		CREATE OR ALTER VIEW ' + @pub_schema_nm + N'.vw_character_item_equipment AS
		SELECT 
			cie.[date],
			cb.character_name,
			cb.character_gender,
			cb.character_class,
			cie.preset_no,
			aoj.item_equipment_part,
			aoj.item_equipment_slot,
			aoj.item_name,
			aoj.item_icon,
			aoj.item_description,
			aoj.item_shape_name,
			aoj.item_shape_icon,
			aoj.item_gender,
			aoj.item_total_option,
			aoj.item_base_option,
			aoj.potential_option_grade,
			aoj.additional_potential_option_grade,
			aoj.potential_option_flag,
			aoj.potential_option_1,
			aoj.potential_option_2,
			aoj.potential_option_3,
			aoj.additional_potential_option_flag,
			aoj.additional_potential_option_1,
			aoj.additional_potential_option_2,
			aoj.additional_potential_option_3,
			aoj.equipment_level_increase,
			aoj.item_exceptional_option,
			aoj.item_add_option,
			aoj.growth_exp,
			aoj.growth_level,
			aoj.scroll_upgrade,
			aoj.cuttable_count,
			aoj.golden_hammer_flag,
			aoj.scroll_resilience_count,
			aoj.scroll_upgradeable_count,
			aoj.soul_name,
			aoj.soul_option,
			aoj.item_etc_option,
			aoj.starforce,
			aoj.starforce_scroll_flag,
			aoj.item_starforce_option,
			aoj.special_ring_level,
			aoj.date_expire,
			aoj.freestyle_flag
		FROM ' +@schema_nm+ '.character_basic cb
		INNER JOIN ' +@schema_nm+ '.character_item_equipment cie ON cb.ocid = cie.ocid
		CROSS APPLY OPENJSON(cie.item_equipment) 
		WITH (
			item_equipment_part					NVARCHAR(64),
			item_equipment_slot 				NVARCHAR(64),
			item_name							NVARCHAR(128),
			item_icon							NVARCHAR(512),
			item_description					NVARCHAR(1024),
			item_shape_name						NVARCHAR(256),
			item_shape_icon						NVARCHAR(512),
			item_gender							NVARCHAR(32),
			item_total_option					NVARCHAR(MAX) AS JSON,
			item_base_option					NVARCHAR(MAX) AS JSON,
			potential_option_grade 				NVARCHAR(32),
			additional_potential_option_grade	NVARCHAR(32),
			potential_option_flag				NVARCHAR(32),
			potential_option_1					NVARCHAR(64),
			potential_option_2					NVARCHAR(64),
			potential_option_3					NVARCHAR(64),
			additional_potential_option_flag	NVARCHAR(32),
			additional_potential_option_1		NVARCHAR(64),
			additional_potential_option_2		NVARCHAR(64),
			additional_potential_option_3		NVARCHAR(64),
			equipment_level_increase			NVARCHAR(64),
			item_exceptional_option				NVARCHAR(MAX) AS JSON,
			item_add_option						NVARCHAR(MAX) AS JSON,
			growth_exp							INT,
			growth_level						INT,
			scroll_upgrade						INT,
			cuttable_count						INT,
			golden_hammer_flag					NVARCHAR(32),
			scroll_resilience_count				INT,
			scroll_upgradeable_count			INT,
			soul_name							NVARCHAR(32),
			soul_option							NVARCHAR(64),
			item_etc_option						NVARCHAR(MAX) AS JSON,
			starforce							INT,
			starforce_scroll_flag				NVARCHAR(32),
			item_starforce_option				NVARCHAR(MAX) AS JSON,
			special_ring_level					INT,
			date_expire							NVARCHAR(64),
			freestyle_flag						NVARCHAR(32)
			) aoj '
		);


-- 캐릭터_장비_스텟_상세_정보_VIEW
	EXEC(N'
		CREATE OR ALTER VIEW ' + @pub_schema_nm + N'.vw_character_item_equipment_detail AS 
		SELECT 
			vcie.date,
			vcie.character_name,
			vcie.character_class,
			vcie.preset_no,
			vcie.item_equipment_slot,
			vcie.item_name,
			--장비 최종 옵션 정보
			JSON_VALUE(vcie.item_total_option,''$.str'') AS "item_total_option_str",
			JSON_VALUE(vcie.item_total_option,''$.dex'') AS "item_total_option_dex",
			JSON_VALUE(vcie.item_total_option,''$.int'') AS "item_total_option_int",
			JSON_VALUE(vcie.item_total_option,''$.luk'') AS "item_total_option_luk",
			JSON_VALUE(vcie.item_total_option,''$.max_hp'') AS "item_total_option_max_hp",
			JSON_VALUE(vcie.item_total_option,''$.max_mp'') AS "item_total_option_max_mp",
			JSON_VALUE(vcie.item_total_option,''$.attack_power'') AS "item_total_option_attack_power",
			JSON_VALUE(vcie.item_total_option,''$.magic_power'') AS "item_total_option_magic_power",
			JSON_VALUE(vcie.item_total_option,''$.armor'') AS "item_total_option_armor",
			JSON_VALUE(vcie.item_total_option,''$.speed'') AS "item_total_option_speed",
			JSON_VALUE(vcie.item_total_option,''$.jump'') AS "item_total_option_jump",
			JSON_VALUE(vcie.item_total_option,''$.boss_damage'') AS "item_total_option_boss_damage",
			JSON_VALUE(vcie.item_total_option,''$.ignore_monster_armor'') AS "item_total_option_ignore_monster_armor",
			JSON_VALUE(vcie.item_total_option,''$.all_stat'') AS "item_total_option_all_stat",
			JSON_VALUE(vcie.item_total_option,''$.damage'') AS "item_total_option_damage",
			JSON_VALUE(vcie.item_total_option,''$.equipment_level_decrease'') AS "item_total_option_equipment_level_decrease",
			JSON_VALUE(vcie.item_total_option,''$.max_hp_rate'') AS "item_total_option_max_hp_rate",
			JSON_VALUE(vcie.item_total_option,''$.max_mp_rate'') AS "item_total_option_max_mp_rate",
			--장비 기본 옵션 정보
			JSON_VALUE(vcie.item_base_option,''$.str'') AS "item_base_option_str",
			JSON_VALUE(vcie.item_base_option,''$.dex'') AS "item_base_option_dex",
			JSON_VALUE(vcie.item_base_option,''$.int'') AS "item_base_option_int",
			JSON_VALUE(vcie.item_base_option,''$.luk'') AS "item_base_option_luk",
			JSON_VALUE(vcie.item_base_option,''$.max_hp'') AS "item_base_option_max_hp",
			JSON_VALUE(vcie.item_base_option,''$.max_mp'') AS "item_base_option_max_mp",
			JSON_VALUE(vcie.item_base_option,''$.attack_power'') AS "item_base_option_attack_power",
			JSON_VALUE(vcie.item_base_option,''$.magic_power'') AS "item_base_option_magic_power",
			JSON_VALUE(vcie.item_base_option,''$.armor'') AS "item_base_option_armor",
			JSON_VALUE(vcie.item_base_option,''$.speed'') AS "item_base_option_speed",
			JSON_VALUE(vcie.item_base_option,''$.jump'') AS "item_base_option_jump",
			JSON_VALUE(vcie.item_base_option,''$.boss_damage'') AS "item_base_option_boss_damage",
			JSON_VALUE(vcie.item_base_option,''$.ignore_monster_armor'') AS "item_base_option_ignore_monster_armor",
			JSON_VALUE(vcie.item_base_option,''$.all_stat'') AS "item_base_option_all_stat",
			JSON_VALUE(vcie.item_base_option,''$.max_hp_rate'') AS "item_base_option_max_hp_rate",
			JSON_VALUE(vcie.item_base_option,''$.max_mp_rate'') AS "item_base_option_max_mp_rate",
			JSON_VALUE(vcie.item_base_option,''$.base_equipment_level'') AS "item_base_option_base_equipment_level",
			--장비 특별 옵션 정보
			JSON_VALUE(vcie.item_exceptional_option,''$.str'') AS "item_exceptional_option_str",
			JSON_VALUE(vcie.item_exceptional_option,''$.dex'') AS "item_exceptional_option_dex",
			JSON_VALUE(vcie.item_exceptional_option,''$.int'') AS "item_exceptional_option_int",
			JSON_VALUE(vcie.item_exceptional_option,''$.luk'') AS "item_exceptional_option_luk",
			JSON_VALUE(vcie.item_exceptional_option,''$.max_hp'') AS "item_exceptional_option_max_hp",
			JSON_VALUE(vcie.item_exceptional_option,''$.max_mp'') AS "item_exceptional_option_max_mp",
			JSON_VALUE(vcie.item_exceptional_option,''$.attack_power'') AS "item_exceptional_option_attack_power",
			JSON_VALUE(vcie.item_exceptional_option,''$.magic_power'') AS "item_exceptional_option_magic_power",
			JSON_VALUE(vcie.item_exceptional_option,''$.exceptional_upgrade'') AS "item_exceptional_option_exceptional_upgrade",
			--장비 추가 옵션 정보
			JSON_VALUE(vcie.item_add_option,''$.str'') AS "item_add_option_str",
			JSON_VALUE(vcie.item_add_option,''$.dex'') AS "item_add_option_dex",
			JSON_VALUE(vcie.item_add_option,''$.int'') AS "item_add_option_int",
			JSON_VALUE(vcie.item_add_option,''$.luk'') AS "item_add_option_luk",
			JSON_VALUE(vcie.item_add_option,''$.max_hp'') AS "item_add_option_max_hp",
			JSON_VALUE(vcie.item_add_option,''$.max_mp'') AS "item_add_option_max_mp",
			JSON_VALUE(vcie.item_add_option,''$.attack_power'') AS "item_add_option_attack_power",
			JSON_VALUE(vcie.item_add_option,''$.magic_power'') AS "item_add_option_magic_power",
			JSON_VALUE(vcie.item_add_option,''$.armor'') AS "item_add_option_armor",
			JSON_VALUE(vcie.item_add_option,''$.speed'') AS "item_add_option_speed",
			JSON_VALUE(vcie.item_add_option,''$.jump'') AS "item_add_option_jump",
			JSON_VALUE(vcie.item_add_option,''$.boss_damage'') AS "item_add_option_boss_damage",
			JSON_VALUE(vcie.item_add_option,''$.damage'') AS "item_add_option_damage",
			JSON_VALUE(vcie.item_add_option,''$.all_stat'') AS "item_add_option_all_stat",
			JSON_VALUE(vcie.item_add_option,''$.equipment_level_decrease'') AS "item_add_option_equipment_level_decrease",
			--장비 기타 옵션 정보
			JSON_VALUE(vcie.item_etc_option,''$.str'') AS "item_etc_option_str",
			JSON_VALUE(vcie.item_etc_option,''$.dex'') AS "item_etc_option_dex",
			JSON_VALUE(vcie.item_etc_option,''$.int'') AS "item_etc_option_int",
			JSON_VALUE(vcie.item_etc_option,''$.luk'') AS "item_etc_option_luk",
			JSON_VALUE(vcie.item_etc_option,''$.max_hp'') AS "item_etc_option_max_hp",
			JSON_VALUE(vcie.item_etc_option,''$.max_mp'') AS "item_etc_option_max_mp",
			JSON_VALUE(vcie.item_etc_option,''$.attack_power'') AS "item_etc_option_attack_power",
			JSON_VALUE(vcie.item_etc_option,''$.magic_power'') AS "item_etc_option_magic_power",
			JSON_VALUE(vcie.item_etc_option,''$.armor'') AS "item_etc_option_armor",
			JSON_VALUE(vcie.item_etc_option,''$.speed'') AS "item_etc_option_speed",
			JSON_VALUE(vcie.item_etc_option,''$.jump'') AS "item_etc_option_jump",
			--장비 스타포스 옵션 정보
			JSON_VALUE(vcie.item_starforce_option,''$.str'') AS "item_starforce_option_str",
			JSON_VALUE(vcie.item_starforce_option,''$.dex'') AS "item_starforce_option_dex",
			JSON_VALUE(vcie.item_starforce_option,''$.int'') AS "item_starforce_option_int",
			JSON_VALUE(vcie.item_starforce_option,''$.luk'') AS "item_starforce_option_luk",
			JSON_VALUE(vcie.item_starforce_option,''$.max_hp'') AS "item_starforce_option_max_hp",
			JSON_VALUE(vcie.item_starforce_option,''$.max_mp'') AS "item_starforce_option_max_mp",
			JSON_VALUE(vcie.item_starforce_option,''$.attack_power'') AS "item_starforce_option_attack_power",
			JSON_VALUE(vcie.item_starforce_option,''$.magic_power'') AS "item_starforce_option_magic_power",
			JSON_VALUE(vcie.item_starforce_option,''$.armor'') AS "item_starforce_option_armor",
			JSON_VALUE(vcie.item_starforce_option,''$.speed'') AS "item_starforce_option_speed",
			JSON_VALUE(vcie.item_starforce_option,''$.jump'') AS "item_starforce_option_jump"
		FROM '+@pub_schema_nm+ '.vw_character_item_equipment vcie ;
		');

/*
 캐릭터 칭호와 훈장은 데이터의 불필요한 중복을 피하고, 훈장정보와 칭호정보만 따로 볼 수 있도록 장작 장비 정보와 분리함.
 */

-- 캐릭터_장착_칭호_조회_VIEW
	EXEC(N' 
		CREATE OR ALTER VIEW ' + @pub_schema_nm + N'.vw_character_title_equipment AS
		SELECT 
			cie.[date],
			cb.character_name,
			cb.world_name,
			JSON_VALUE(title,''$.title_name'') AS ''title_name'',
			JSON_VALUE(title,''$.title_icon'') AS ''title_icon'',
			JSON_VALUE(title,''$.title_description'') AS ''title_description'',
			JSON_VALUE(title,''$.date_expire'') AS ''date_expire'',
			JSON_VALUE(title,''$.date_option_expire'') AS ''date_option_expire'',
			JSON_VALUE(title,''$.title_shape_name'') AS ''title_shape_name'',
			JSON_VALUE(title,''$.title_shape_icon'') AS ''title_shape_icon'',
			JSON_VALUE(title,''$.title_shape_description'') AS ''title_shape_description''
		FROM '+@schema_nm+ '.character_basic cb
		INNER JOIN ' +@schema_nm+ '.character_item_equipment cie ON cb.ocid = cie.ocid
		');

-- 캐릭터_장착_훈장_조회_VIEW
	EXEC(N' 
		CREATE OR ALTER VIEW ' + @pub_schema_nm + N'.vw_character_medal_equipment AS
		SELECT 
			cie.[date],
			cb.character_name,
			cb.world_name,
			JSON_VALUE(medal_shape,''$.medal_shape_name'') AS ''medal_shape_name'',
			JSON_VALUE(medal_shape,''$.medal_shape_icon'') AS ''medal_shape_icon'',
			JSON_VALUE(medal_shape,''$.medal_shape_description'') AS ''medal_shape_description'',
			JSON_VALUE(medal_shape,''$.medal_shape_changed_name'') AS ''medal_shape_changed_name'',
			JSON_VALUE(medal_shape,''$.medal_shape_changed_icon'') AS ''medal_shape_changed_icon'',
			JSON_VALUE(medal_shape,''$.medal_shape_changed_description'') AS ''medal_shape_changed_description''
		FROM ' +@schema_nm+ '.character_basic cb
		INNER JOIN ' +@schema_nm+ '.character_item_equipment cie ON cb.ocid = cie.ocid
		');

-- 캐릭터_링크_스킬_조회_VIEW
	EXEC(N'
		CREATE OR ALTER VIEW ' + @pub_schema_nm + N'.vw_character_link_skill AS 
		SELECT 
			cb.[date],
			cb.character_name,
			cb.character_level,
			cb.world_name,
			cb.character_class,
			cb.character_class_level,
			aoj.skill_name,
			aoj.skill_description,
			aoj.skill_level,
			aoj.skill_effect,
			aoj.skill_icon,
			aoj.skill_effect_next,
			0	AS "own_linked_skill_flag"
		FROM ' +@schema_nm+ '.character_basic cb
		INNER JOIN ' +@schema_nm+ '.character_link_skill cls on cb.ocid = cls.ocid
		CROSS APPLY OPENJSON(cls.character_link_skill) 
		WITH (
			skill_name			NVARCHAR(128),
			skill_description	NVARCHAR(1024),
			skill_level			INT,
			skill_effect		NVARCHAR(1024),
			skill_icon			NVARCHAR(1024),
			skill_effect_next	NVARCHAR(1024)
			)aoj
		UNION ALL
		SELECT 
			cb.[date],
			cb.character_name,
			cb.character_level,
			cb.world_name,
			cb.character_class,
			cb.character_class_level,
			aoj.skill_name,
			aoj.skill_description,
			aoj.skill_level,
			aoj.skill_effect,
			aoj.skill_icon,
			aoj.skill_effect_next,
			1	AS "own_linked_skill_flag"	--캐릭터 자체 보유 링크스킬 구분 플래그
		FROM ' +@schema_nm+ '.character_basic cb
		INNER JOIN ' +@schema_nm+ '.character_link_skill cls on cb.ocid = cls.ocid
		CROSS APPLY OPENJSON(cls.character_owned_link_skill) 
		WITH (
			skill_name			NVARCHAR(128),
			skill_description	NVARCHAR(1024),
			skill_level			INT,
			skill_effect		NVARCHAR(1024),
			skill_icon			NVARCHAR(1024),
			skill_effect_next	NVARCHAR(1024)
			)aoj;
		');

-- 기타_능력치_영향_요소_정보_조회_VIEW
	EXEC(N'
		CREATE OR ALTER VIEW ' + @pub_schema_nm + N'.vw_character_other_stat AS 
		SELECT
			cb.[date],
			cb.character_name,
			cb.world_name,
			cb.character_class,
			JSON_VALUE(cos.other_stat,''$[0].other_stat_type'') "stat_type",
			aoj.stat_name,
			aoj.stat_value
		FROM ' +@schema_nm+ '.character_basic cb
		INNER JOIN ' +@schema_nm+ '.character_other_stat cos ON cb.ocid=cos.ocid
		CROSS APPLY OPENJSON(cos.other_stat,''$[0].stat_info'')
		WITH (
			stat_name		NVARCHAR(64),
			stat_value		NVARCHAR(32)
			) aoj ;'
		);

-- 무릉도장_최고_기록_정보_HIST_VIEW
	EXEC(N'
		CREATE OR ALTER VIEW ' + @pub_schema_nm + N'.vw_character_dojang_hist AS 
		SELECT 
			cdh.[date],
			cbh.character_name,
			cbh.character_level,
			cdh.character_class,
			cbh.character_class_level, 
			cdh.world_name, 
			cdh.dojang_best_floor, 
			cdh.date_dojang_record, 
			cdh.dojang_best_time
		FROM ' +@schema_nm+ '.character_basic_hist cbh
		INNER JOIN ' +@schema_nm+ '.character_dojang_hist cdh ON cbh.ocid=cdh.ocid AND cbh.[date]=cdh.[date]
		WHERE cdh.date_dojang_record IS NOT NULL; '
		) ;

-- 캐릭터_성향정보_VIEW
	EXEC(N'
		CREATE OR ALTER VIEW ' + @pub_schema_nm + N'.vw_character_propensity AS
		SELECT 
			cp.[date], 
			cb.character_name,
			cb.character_class,
			cp.charisma_level, 
			cp.sensibility_level, 
			cp.insight_level, 
			cp.willingness_level, 
			cp.handicraft_level, 
			cp.charm_level
		FROM ' +@schema_nm+ '.character_basic cb
		INNER JOIN ' +@schema_nm+ '.character_propensity cp on cb.ocid = cp.ocid; '
		) ;

--캐릭터_적용_세트효과_VIEW
	EXEC(N'
		CREATE OR ALTER VIEW ' + @pub_schema_nm + N'.vw_character_apply_set_effect AS 
		SELECT 
			cse.[date], 
			cb.character_name,
			cb.character_class,
			aoj.set_name,
			aoj2.set_count,
			aoj2.set_option
		FROM ' +@schema_nm+ '.character_basic cb
		INNER JOIN ' +@schema_nm+ '.character_set_effect cse ON cb.ocid=cse.ocid
		CROSS APPLY OPENJSON(cse.set_effect)
		WITH (
			set_name			NVARCHAR(64),
			total_set_count		INT,
			set_effect_info		NVARCHAR(MAX) AS JSON,
			set_option_full		NVARCHAR(MAX) AS JSON
			) aoj
		CROSS APPLY OPENJSON(aoj.set_effect_info)
		WITH (
			set_count		INT,
			set_option		NVARCHAR(128)
			) aoj2; '
		) ;

--적용가능_full_세트효과_VIEW (내부용)
/*
 현재 캐릭터가 착용하고 있는 장비의 전체 세트효과 정보를 조회할 수 있다.
 캐릭터의 현재 능력치와는 직접적인 연관은 없지만, 착용하고 있는 장비의 세트 효과에 대한 전체 정보를 보여주기 때문에,
 메타 데이터 개념으로 생성하고, 내부 조회용 VIEW로 활용한다.
 */
	EXEC(N'
		CREATE OR ALTER VIEW ' + @schema_nm + N'.vw_set_effect_all AS 
		SELECT 
			aoj.set_name,
			aoj2.set_count,
			aoj2.set_option
		FROM ' +@schema_nm+ '.character_basic cb
		INNER JOIN ' +@schema_nm + '.character_set_effect cse ON cb.ocid=cse.ocid
		CROSS APPLY OPENJSON(cse.set_effect)
		WITH (
			set_name			NVARCHAR(64),
			total_set_count		INT,
			set_option_full		NVARCHAR(MAX) AS JSON
			) aoj
		CROSS APPLY OPENJSON(aoj.set_option_full)
		WITH (
			set_count		INT,
			set_option		NVARCHAR(128)
			) aoj2 ;'
		) ;

-- 캐릭터_스킬_정보_0차_스킬
	EXEC(N'
		CREATE OR ALTER VIEW ' + @pub_schema_nm + N'.vw_character_skill_0 AS 
		SELECT 
			cs.[date],
			cb.character_name,
			cb.character_class,
			aoj.skill_name,
			aoj.skill_description,
			aoj.skill_level,
			aoj.skill_effect,
			aoj.skill_icon,
			aoj.skill_effect_next
		FROM ' +@schema_nm+ '.character_basic cb
		INNER JOIN ' +@schema_nm+ '.character_skill cs ON cb.ocid=cs.ocid
		CROSS APPLY OPENJSON(cs.character_skill)
		WITH (
			skill_name			NVARCHAR(64),
			skill_description	NVARCHAR(1024),
			skill_level			INT,
			skill_effect		NVARCHAR(1024),
			skill_icon			NVARCHAR(1024),
			skill_effect_next	NVARCHAR(1024)
			) aoj
		WHERE cs.character_skill_grade=''0'';'
		) ;

-- 캐릭터_스킬_정보_1차_스킬
	EXEC(N'
		CREATE OR ALTER VIEW ' + @pub_schema_nm + N'.vw_character_skill_1 AS 
		SELECT 
			cs.[date],
			cb.character_name,
			cb.character_class,
			aoj.skill_name,
			aoj.skill_description,
			aoj.skill_level,
			aoj.skill_effect,
			aoj.skill_icon,
			aoj.skill_effect_next
		FROM ' +@schema_nm+ '.character_basic cb
		INNER JOIN ' +@schema_nm+ '.character_skill cs ON cb.ocid=cs.ocid
		CROSS APPLY OPENJSON(cs.character_skill)
		WITH (
			skill_name			NVARCHAR(64),
			skill_description	NVARCHAR(1024),
			skill_level			INT,
			skill_effect		NVARCHAR(1024),
			skill_icon			NVARCHAR(1024),
			skill_effect_next	NVARCHAR(1024)
			) aoj
		WHERE cs.character_skill_grade=''1'';'
		) ;

-- 캐릭터_스킬_정보_1.5차_스킬
	EXEC(N'
		CREATE OR ALTER VIEW ' + @pub_schema_nm + N'.vw_character_skill_1_5 AS 
		SELECT 
			cs.[date],
			cb.character_name,
			cb.character_class,
			aoj.skill_name,
			aoj.skill_description,
			aoj.skill_level,
			aoj.skill_effect,
			aoj.skill_icon,
			aoj.skill_effect_next
		FROM ' +@schema_nm+ '.character_basic cb
		INNER JOIN ' +@schema_nm+ '.character_skill cs ON cb.ocid=cs.ocid
		CROSS APPLY OPENJSON(cs.character_skill)
		WITH (
			skill_name			NVARCHAR(64),
			skill_description	NVARCHAR(1024),
			skill_level			INT,
			skill_effect		NVARCHAR(1024),
			skill_icon			NVARCHAR(1024),
			skill_effect_next	NVARCHAR(1024)
			) aoj
		WHERE cs.character_skill_grade=''1.5'';'
		) ;

-- 캐릭터_스킬_정보_2차_스킬
	EXEC(N'
		CREATE OR ALTER VIEW ' + @pub_schema_nm + N'.vw_character_skill_2 AS 
		SELECT 
			cs.[date],
			cb.character_name,
			cb.character_class,
			aoj.skill_name,
			aoj.skill_description,
			aoj.skill_level,
			aoj.skill_effect,
			aoj.skill_icon,
			aoj.skill_effect_next
		FROM ' +@schema_nm+ '.character_basic cb
		INNER JOIN ' +@schema_nm+ '.character_skill cs ON cb.ocid=cs.ocid
		CROSS APPLY OPENJSON(cs.character_skill)
		WITH (
			skill_name			NVARCHAR(64),
			skill_description	NVARCHAR(1024),
			skill_level			INT,
			skill_effect		NVARCHAR(1024),
			skill_icon			NVARCHAR(1024),
			skill_effect_next	NVARCHAR(1024)
			) aoj
		WHERE cs.character_skill_grade=''2'';'
		) ;

-- 캐릭터_스킬_정보_2.5차_스킬
	EXEC(N'
		CREATE OR ALTER VIEW ' + @pub_schema_nm + N'.vw_character_skill_2_5 AS 
		SELECT 
			cs.[date],
			cb.character_name,
			cb.character_class,
			aoj.skill_name,
			aoj.skill_description,
			aoj.skill_level,
			aoj.skill_effect,
			aoj.skill_icon,
			aoj.skill_effect_next
		FROM ' +@schema_nm+ '.character_basic cb
		INNER JOIN ' +@schema_nm+ '.character_skill cs ON cb.ocid=cs.ocid
		CROSS APPLY OPENJSON(cs.character_skill)
		WITH (
			skill_name			NVARCHAR(64),
			skill_description	NVARCHAR(1024),
			skill_level			INT,
			skill_effect		NVARCHAR(1024),
			skill_icon			NVARCHAR(1024),
			skill_effect_next	NVARCHAR(1024)
			) aoj
		WHERE cs.character_skill_grade=''2.5'';'
		) ;

-- 캐릭터_스킬_정보_3차_스킬
	EXEC(N'
		CREATE OR ALTER VIEW ' + @pub_schema_nm + N'.vw_character_skill_3 AS 
		SELECT 
			cs.[date],
			cb.character_name,
			cb.character_class,
			aoj.skill_name,
			aoj.skill_description,
			aoj.skill_level,
			aoj.skill_effect,
			aoj.skill_icon,
			aoj.skill_effect_next
		FROM ' +@schema_nm+ '.character_basic cb
		INNER JOIN ' +@schema_nm+ '.character_skill cs ON cb.ocid=cs.ocid
		CROSS APPLY OPENJSON(cs.character_skill)
		WITH (
			skill_name			NVARCHAR(64),
			skill_description	NVARCHAR(1024),
			skill_level			INT,
			skill_effect		NVARCHAR(1024),
			skill_icon			NVARCHAR(1024),
			skill_effect_next	NVARCHAR(1024)
			) aoj
		WHERE cs.character_skill_grade=''3'';'
		) ;

-- 캐릭터_스킬_정보_4차_스킬
	EXEC(N'
		CREATE OR ALTER VIEW ' + @pub_schema_nm + N'.vw_character_skill_4 AS 
		SELECT 
			cs.[date],
			cb.character_name,
			cb.character_class,
			aoj.skill_name,
			aoj.skill_description,
			aoj.skill_level,
			aoj.skill_effect,
			aoj.skill_icon,
			aoj.skill_effect_next
		FROM ' +@schema_nm+ '.character_basic cb
		INNER JOIN ' +@schema_nm+ '.character_skill cs ON cb.ocid=cs.ocid
		CROSS APPLY OPENJSON(cs.character_skill)
		WITH (
			skill_name			NVARCHAR(64),
			skill_description	NVARCHAR(1024),
			skill_level			INT,
			skill_effect		NVARCHAR(1024),
			skill_icon			NVARCHAR(1024),
			skill_effect_next	NVARCHAR(1024)
			) aoj
		WHERE cs.character_skill_grade=''4'';'
		) ;

-- 캐릭터_스킬_정보_하이퍼_패시브_스킬 
	EXEC(N'
		CREATE OR ALTER VIEW ' + @pub_schema_nm + N'.vw_character_skill_hyp AS 
		SELECT 
			cs.[date],
			cb.character_name,
			cb.character_class,
			aoj.skill_name,
			aoj.skill_description,
			aoj.skill_level,
			aoj.skill_effect,
			aoj.skill_icon,
			aoj.skill_effect_next
		FROM ' +@schema_nm+ '.character_basic cb
		INNER JOIN ' +@schema_nm+ '.character_skill cs ON cb.ocid=cs.ocid
		CROSS APPLY OPENJSON(cs.character_skill)
		WITH (
			skill_name			NVARCHAR(64),
			skill_description	NVARCHAR(1024),
			skill_level			INT,
			skill_effect		NVARCHAR(1024),
			skill_icon			NVARCHAR(1024),
			skill_effect_next	NVARCHAR(1024)
			) aoj
		WHERE cs.character_skill_grade=''hyperpassive'';'
		) ;

-- 캐릭터_스킬_정보_하이퍼_액티브_스킬 
	EXEC(N'
		CREATE OR ALTER VIEW ' + @pub_schema_nm + N'.vw_character_skill_hya AS 
		SELECT 
			cs.[date],
			cb.character_name,
			cb.character_class,
			aoj.skill_name,
			aoj.skill_description,
			aoj.skill_level,
			aoj.skill_effect,
			aoj.skill_icon,
			aoj.skill_effect_next
		FROM ' +@schema_nm+ '.character_basic cb
		INNER JOIN ' +@schema_nm+ '.character_skill cs ON cb.ocid=cs.ocid
		CROSS APPLY OPENJSON(cs.character_skill)
		WITH (
			skill_name			NVARCHAR(64),
			skill_description	NVARCHAR(1024),
			skill_level			INT,
			skill_effect		NVARCHAR(1024),
			skill_icon			NVARCHAR(1024),
			skill_effect_next	NVARCHAR(1024)
			) aoj
		WHERE cs.character_skill_grade=''hyperactive'';'
		) ;
	
-- 캐릭터_스킬_정보_5차_스킬
	EXEC(N'
		CREATE OR ALTER VIEW ' + @pub_schema_nm + N'.vw_character_skill_5 AS 
		SELECT 
			cs.[date],
			cb.character_name,
			cb.character_class,
			aoj.skill_name,
			aoj.skill_description,
			aoj.skill_level,
			aoj.skill_effect,
			aoj.skill_icon,
			aoj.skill_effect_next
		FROM ' +@schema_nm+ '.character_basic cb
		INNER JOIN ' +@schema_nm+ '.character_skill cs ON cb.ocid=cs.ocid
		CROSS APPLY OPENJSON(cs.character_skill)
		WITH (
			skill_name			NVARCHAR(64),
			skill_description	NVARCHAR(1024),
			skill_level			INT,
			skill_effect		NVARCHAR(1024),
			skill_icon			NVARCHAR(1024),
			skill_effect_next	NVARCHAR(1024)
			) aoj
		WHERE cs.character_skill_grade=''5'';'
		) ;	

-- 캐릭터_스킬_정보_6차_스킬
	EXEC(N'
		CREATE OR ALTER VIEW ' + @pub_schema_nm + N'.vw_character_skill_6 AS 
		SELECT 
			cs.[date],
			cb.character_name,
			cb.character_class,
			aoj.skill_name,
			aoj.skill_description,
			aoj.skill_level,
			aoj.skill_effect,
			aoj.skill_icon,
			aoj.skill_effect_next
		FROM ' +@schema_nm+ '.character_basic cb
		INNER JOIN ' +@schema_nm+ '.character_skill cs ON cb.ocid=cs.ocid
		CROSS APPLY OPENJSON(cs.character_skill)
		WITH (
			skill_name			NVARCHAR(64),
			skill_description	NVARCHAR(1024),
			skill_level			INT,
			skill_effect		NVARCHAR(1024),
			skill_icon			NVARCHAR(1024),
			skill_effect_next	NVARCHAR(1024)
			) aoj
		WHERE cs.character_skill_grade=''6'';'
		) ;

-- 캐릭터_스탯_정보_VIEW
	EXEC(N'
		CREATE OR ALTER VIEW ' + @pub_schema_nm + N'.vw_character_stat AS 
		SELECT 
			cs.[date], 
			cb.character_name,
			cb.character_class,
			aoj.stat_name,
			aoj.stat_value
		FROM ' +@schema_nm+ '.character_basic cb
		INNER JOIN ' +@schema_nm+ '.character_stat cs ON cb.ocid=cs.ocid
		CROSS APPLY OPENJSON(cs.final_stat)
		WITH (
			stat_name		NVARCHAR(128),
			stat_value		NVARCHAR(64)
			) aoj ; '
		) ;

-- 캐릭터_장착_심볼_정보_VIEW
	EXEC(N'
		CREATE OR ALTER VIEW ' + @pub_schema_nm + N'.vw_character_symbol_equipment AS 
		SELECT 
			cse.[date], 
			cb.character_name,
			cb.character_class,
			aoj.symbol_name,
			aoj.symbol_icon,
			aoj.symbol_description,
			aoj.symbol_other_effect_description,
			aoj.symbol_force,
			aoj.symbol_level,
			aoj.symbol_str,
			aoj.symbol_dex,
			aoj.symbol_int,
			aoj.symbol_luk,
			aoj.symbol_hp,
			aoj.symbol_drop_rate,
			aoj.symbol_meso_rate,
			aoj.symbol_exp_rate,
			aoj.symbol_growth_count,
			aoj.symbol_require_growth_count
		FROM ' +@schema_nm+ '.character_basic cb
		INNER JOIN ' +@schema_nm+ '.character_symbol_equipment cse ON cb.ocid=cse.ocid
		CROSS APPLY OPENJSON(cse.symbol)
		WITH (
			symbol_name						NVARCHAR(64),
			symbol_icon						NVARCHAR(1024),
			symbol_description				NVARCHAR(1024),
			symbol_other_effect_description NVARCHAR(1024),
			symbol_force					NVARCHAR(32),
			symbol_level					INT,
			symbol_str						NVARCHAR(64),
			symbol_dex						NVARCHAR(64),
			symbol_int						NVARCHAR(64),
			symbol_luk						NVARCHAR(64),
			symbol_hp						NVARCHAR(64),
			symbol_drop_rate				NVARCHAR(64),
			symbol_meso_rate				NVARCHAR(64),
			symbol_exp_rate					NVARCHAR(64),
			symbol_growth_count				INT,
			symbol_require_growth_count		INT
			) aoj ;'
		) ; 

-- 캐릭터_V코어_정보_VIEW
	EXEC(N'
		CREATE OR ALTER VIEW ' + @pub_schema_nm + N'.vw_character_vmatrix AS 
		SELECT 
			cvx.[date], 
			cb.character_name,
			cb.character_class,
			aoj.slot_id,
			aoj.v_core_name,
			aoj.v_core_type,
			aoj.v_core_level
		FROM ' +@schema_nm+ '.character_basic cb
		INNER JOIN ' +@schema_nm+ '.character_vmatrix cvx ON cb.ocid=cvx.ocid
		CROSS APPLY OPENJSON(cvx.character_v_core_equipment)
		WITH (
			slot_id			NVARCHAR(32),
			v_core_name		NVARCHAR(64),
			v_core_type		NVARCHAR(64),
			v_core_level	INT
			) aoj ;'
		) ;


	END TRY
	
	BEGIN CATCH
		IF XACT_STATE() <> 0 ROLLBACK TRAN;
	
		-- 에러 메시지 생성용
		THROW;
	END CATCH
END
GO