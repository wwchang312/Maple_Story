CREATE OR ALTER PROCEDURE dbo.SP_DROP_TABLE
	@schema_nm SYSNAME = 'dbo' ,
	@table_nm	NVARCHAR(128)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @sql NVARCHAR(MAX) = N'';
	
	--1. table_nm 변수에 ALL 입력시 전체 테이블 삭제
	
	IF @table_nm = 'ALL'
	BEGIN
		
		SELECT @SQL = STRING_AGG('DROP TABLE ' + QUOTENAME(@schema_nm) + '.' +QUOTENAME(t.name),';')
			FROM sys.tables t
			INNER JOIN sys.schemas s 
				ON t.schema_id=s.schema_id
			WHERE s.name = @schema_nm;	
	
	END
	ELSE
	BEGIN
	--2. table_nm에 특정 테이블 명 입력시, 해당 테이블만 삭제
		
		SET @sql = 'DROP TABLE' + QUOTENAME(@schema_nm) + '.' + QUOTENAME(@table_nm);
	END
	
	-- sql 변수가 비어있지 않을 때만 실행
	
	IF @sql <> ''
	BEGIN
		EXEC sp_executesql @sql;
	END
	ELSE
	BEGIN
		PRINT '대상이 되는 테이블이 없습니다.'
	END
	
END;
GO
	
	
END
