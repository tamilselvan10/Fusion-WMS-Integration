  CREATE OR REPLACE VIEW "XX_ITEM_DASHBOARD_VW"  AS 
SELECT  UNIQUE 1 id,'Total Items' label,count(UNIQUE Item_id) value
FROM xx_item_master_dtls_tb
WHERE 1=1
UNION
SELECT  UNIQUE 2 id,'Total Success' label,count(UNIQUE Item_id) value
FROM xx_item_master_dtls_tb
WHERE 1=1
AND status='SUCCESS'
UNION
SELECT  UNIQUE 3 id,'Total Error' label,count(UNIQUE Item_id) value
FROM xx_item_master_dtls_tb
WHERE 1=1
AND status='ERROR'