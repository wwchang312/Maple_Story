CREATE OR ALTER PROCEDURE SP_INSERT_DATA
	@schema_nm 	NVARCHAR(64) = 'maple',
	@table_nm 	NVARCHAR(128),
	@json	  	NVARCHAR(MAX),
	@wt			NVARCHAR(MAX) =NULL
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
	SELECT @wt = 'WITH ('
				+STRING_AGG(COLUMN_NAME
				,',')
				+')'
	FROM INFORMATION_SCHEMA.COLUMNS c 
	WHERE TABLE_SCHEMA = @schema_nm
  	AND TABLE_NAME   = @table_nm;

	PRINT @wt;
END
