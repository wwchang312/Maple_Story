USE Maple;
CREATE OR ALTER PROCEDURE SP_INSERT_DATA
(
	@schema_nm 	NVARCHAR(64) = 'maple',
	@table_nm 	NVARCHAR(128),
	@json	  	NVARCHAR(MAX),
	@wt			NVARCHAR(MAX) = NULL
)
AS
BEGIN
	SET NOCOUNT ON;

	-- 1. 변수로 입력받은 table_nm을 이용하여 테이블이 존재하는지 확인
	
	IF NOT EXISTS(
		SELECT 1
		FROM sys.tables t
		INNER JOIN	sys.schemas s ON t.schema_id=s.schema_id
		WHERE t.name=@table_nm AND s.name=@schema_nm
	)
	BEGIN
		DECLARE @msg NVARCHAR(4000)
		SET @msg = N'해당 테이블이 존재하지 않습니다.';
		THROW 50001, @msg, 1;
	END
	
	
	-- 2. JSON 파싱을 위한 WITH절 생성
	SELECT @wt = STRING_AGG
							(
							CONCAT(QUOTENAME(c.COLUMN_NAME) , 
							'   ', 
							'NVARCHAR(',
							IIF(CHARACTER_MAXIMUM_LENGTH=-1,'MAX) AS JSON',IIF(CHARACTER_MAXIMUM_LENGTH IS NULL, '64)',CONVERT(NVARCHAR,CHARACTER_MAXIMUM_LENGTH)+')'))
								  ),',')
	FROM INFORMATION_SCHEMA.COLUMNS c 
	WHERE c.TABLE_SCHEMA = @schema_nm
  	AND c.TABLE_NAME   = @table_nm;
	
	-- 3. KEY값 추출
	DECLARE @KeyList TABLE (col SYSNAME);
	
	INSERT INTO @KeyList 
				SELECT COLUMN_NAME 
				FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE kcu 
				WHERE kcu.TABLE_NAME =@table_nm and kcu.TABLE_SCHEMA =@schema_nm;
	
	
	
	
	
	-- 5-1. JOIN 조건절 ON 생성
	
	DECLARE @on NVARCHAR(MAX);
	
	SELECT @on = STRING_AGG(CONCAT('t.',QUOTENAME(col),' = ','s.',QUOTENAME(col)),',')
	FROM @KeyList;
	
	
	
	
	

	
END




