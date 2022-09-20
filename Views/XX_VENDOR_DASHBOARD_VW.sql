  CREATE OR REPLACE VIEW "XX_VENDOR_DASHBOARD_VW"  AS 
SELECT  UNIQUE 1 id,'Total Vendors' label,count(UNIQUE party_id) value
FROM xx_fusion_cust_vend_dtls_tb
WHERE 1=1
AND party_type='V'
UNION
SELECT  UNIQUE 2 id,'Total Success' label,count(UNIQUE party_id) value
FROM xx_fusion_cust_vend_dtls_tb
WHERE 1=1
AND status='SUCCESS'
AND party_type='V'
UNION
SELECT  UNIQUE 3 id,'Total Error' label,count(UNIQUE party_id) value
FROM xx_fusion_cust_vend_dtls_tb
WHERE 1=1
AND status='ERROR'
AND party_type='V'