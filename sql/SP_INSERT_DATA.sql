CREATE OR ALTER PROCEDURE maple.SP_INSERT_DATA
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
							IIF(CHARACTER_MAXIMUM_LENGTH=-1,'NVARCHAR(MAX) AS JSON',IIF(CHARACTER_MAXIMUM_LENGTH IS NULL, DATA_TYPE,'NVARCHAR('+CONVERT(NVARCHAR,CHARACTER_MAXIMUM_LENGTH)+')'))
								  ),',')
	FROM INFORMATION_SCHEMA.COLUMNS c 
	WHERE c.TABLE_SCHEMA = @schema_nm
  	AND c.TABLE_NAME   = @table_nm;
	
	
	
	-- 3. Source 테이블 생성 
	
	DECLARE @sur NVARCHAR(MAX);
	
	SET @sur = N' SELECT *
				 FROM OPENJSON('''+@json+''') WITH('+@wt+')';

	
	-- 4. JOIN 조건절 ON 생성
	
	-- ON 조건 생성
	DECLARE @on NVARCHAR(MAX);
	 
	SELECT @on = CONCAT('t.',COLUMN_NAME,' = s.',COLUMN_NAME) 
	FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE kcu 
	WHERE kcu.TABLE_NAME =@table_nm and kcu.TABLE_SCHEMA =@schema_nm;

	
	-- 변경 대상이 되는 일반 컬럼 추출
	DECLARE @up_col NVARCHAR(MAX);
	
	SELECT @up_col=STRING_AGG(CONCAT('t.',COLUMN_NAME,' = ','s.',COLUMN_NAME),', ')
	FROM INFORMATION_SCHEMA.COLUMNS c 
	WHERE c.TABLE_SCHEMA = @schema_nm AND c.TABLE_NAME = @table_nm 
	AND c.COLUMN_NAME not in (SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE WHERE c.TABLE_NAME   =  @table_nm );
	
	
	-- 테이블 컬럼 추출
	DECLARE @sur_col NVARCHAR(MAX);
	DECLARE @tar_col NVARCHAR(MAX);
	
	SELECT @sur_col = STRING_AGG(CONCAT('s.',COLUMN_NAME), ',')
	FROM INFORMATION_SCHEMA.COLUMNS c 
	WHERE c.TABLE_SCHEMA = @schema_nm
  	AND c.TABLE_NAME   = @table_nm; 
	
	SELECT @tar_col = STRING_AGG(COLUMN_NAME, ',')
	FROM INFORMATION_SCHEMA.COLUMNS c 
	WHERE c.TABLE_SCHEMA = @schema_nm
  	AND c.TABLE_NAME   = @table_nm; 
	
	
	
	-- 5. 이력 테이블 존재 여부에 따른 분기
	
	DECLARE @sql NVARCHAR(MAX) = N'';
	

	
	-- 이력 테이블 존재 
	IF OBJECT_ID(@schema_nm+'.'+ @table_nm +'_hist','U') IS NOT NULL
	BEGIN
		
	-- 이력 테이블에 데이터 INSERT	
		SET @sql = N'INSERT INTO ' +@schema_nm +N'.'+@table_nm +N'_hist ('+@tar_col+')'+ @sur +N';';
		
		EXEC sp_executesql @sql;
		
		
		SET @sql = N'MERGE INTO '+@schema_nm+'.'+@table_nm + N' t USING  (' + @sur +' ) s ON ' + @on + 
					 N' WHEN MATCHED THEN UPDATE SET ' + @up_col+
					 N' WHEN NOT MATCHED THEN INSERT (' + @tar_col + N' ) VALUES (' +@sur_col+');' ;
--		SET @sql += N'DELETE'+ @schema_nm +'.'+@table_nm + ';';
		
--		SET @sql += N'INSERT INTO ' +@schema_nm +'.'+@table_nm +'('+@col+') '+ @sur +';';

	
	END
	ELSE
	BEGIN
--		SET @sql = N'DELETE '+ @schema_nm +'.'+@table_nm + ';';
		
--		SET @sql += N'INSERT INTO ' +@schema_nm +'.'+@table_nm +'('+@col+') '+ @sur +';';
		
		SET @sql = N'MERGE INTO '+@schema_nm+'.'+@table_nm + N't USING  (' + @sur +' ) s ON ' + @on + 
					 N' WHEN MATCHED THEN UPDATE SET ' + @up_col+
					 N' WHEN NOT MATCHED THEN INSERT (' +@tar_col + N' ) VALUES (' +@sur_col+');' ;

	END
	
	
	
	
	EXEC sp_executesql @sql;
	
	
END




