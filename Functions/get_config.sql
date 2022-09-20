

--- Read Configuration File:
CREATE OR REPLACE FUNCTION get_config(p_col IN VARCHAR2)
RETURN VARCHAR2
AS


l_clob    CLOB;
lv_value  VARCHAR2(240):=NULL;

BEGIN

--- get file:
BEGIN
SELECT config_file INTO l_clob FROM xx_wms_int_config_tb WHERE 1=1;
EXCEPTION WHEN OTHERS THEN
NULL;
END;

------------------------------
SELECT VALUE 
INTO lv_value
FROM TABLE(
pljson_table.json_table(l_clob,
pljson_varray(p_col),
pljson_varray('value'),
table_mode => 'nested'));
------------------------------
RETURN lv_value;

END get_config;