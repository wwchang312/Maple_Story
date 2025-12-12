CREATE OR ALTER PROCEDURE maple.SP_DROP_TABLE
(
	@schema_nm 		NVARCHAR(64) = 'maple',
	@table_type 	INT
) 
AS
BEGIN
	SET NOCOUNT ON;


	/*
	 table_type값을 입력받아 각 테이블 목적에 따른 삭제 구현
	 0 - 전체
	 1 - 이력 테이블 삭제
	 2 - 뷰 삭제
	 
	 본 프로시저는 테이블 구조 전체를 다시 설계할때 사용하기 위함이므로
	 특정 테이블을 지정하여 삭제하는 경우는 고려하지 않는다. 
	 
	 본테이블을 삭제하는 경우, 이와 관련된 뷰와 이력 테이블도 같이 삭제되야한다고 판단하여, 이력 테이블 삭제와 뷰 테이블 삭제만 별도로 분리함.
	 */

	DECLARE @sql	NVARCHAR(MAX);
	
	-- 테이블 전체 삭제
	IF @table_type = 0
	BEGIN
		
		-- 제약 조건이 있는 자식 테이블 우선 삭제
				
		SELECT @sql=STRING_AGG(CONCAT('DROP TABLE ',s.name,'.',t.name),';')
		FROM sys.foreign_keys fk 
		JOIN sys.tables t ON fk.parent_object_id =t.object_id 
		JOIN sys.schemas s ON s.schema_id=t.schema_id
		WHERE s.name=@schema_nm;
		
		EXEC sp_executesql @sql ;
		
		-- 나머지 부모 테이블 삭제
		SELECT @sql = STRING_AGG(CONCAT('DROP TABLE ',@schema_nm,'.',TABLE_NAME),';')
		FROM INFORMATION_SCHEMA.TABLES t 
		WHERE TABLE_SCHEMA =@schema_nm AND TABLE_TYPE='BASE TABLE';
		
		EXEC sp_executesql @sql ;
	
		-- 뷰 삭제
		SELECT @sql = STRING_AGG(CONCAT('DROP VIEW ',@schema_nm,'.',TABLE_NAME),';')
		FROM INFORMATION_SCHEMA.TABLES t 
		WHERE TABLE_SCHEMA =@schema_nm AND TABLE_TYPE='VIEW';
		
		EXEC sp_executesql @sql;
		
	
		
	END
	
	-- 이력 테이블 삭제
	IF @table_type = 1
	BEGIN
	
	SELECT @sql = STRING_AGG(CONCAT('DROP TABLE ',@schema_nm,'.',TABLE_NAME),';')
		FROM INFORMATION_SCHEMA.TABLES t 
		WHERE TABLE_SCHEMA =@schema_nm AND TABLE_TYPE='BASE TABLE' AND TABLE_NAME LIKE '%_hist%';
		
		EXEC sp_executesql @sql ;
	
	END
	
	-- View 삭제
	IF @table_type =2
	BEGIN
		SELECT @sql = STRING_AGG(CONCAT('DROP VIEW ',@schema_nm,'.',TABLE_NAME),';')
		FROM INFORMATION_SCHEMA.TABLES t 
		WHERE TABLE_SCHEMA =@schema_nm AND TABLE_TYPE='VIEW';
		
		EXEC sp_executesql @sql;
		
	END
	
	
	
	
END






