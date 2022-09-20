
  CREATE OR REPLACE VIEW "XX_SO_RTN_DASHBOARD_VW"  AS 
  SELECT ID,LABEL,VALUE FROM (
SELECT  UNIQUE 1 id,'Total SO' label,count(UNIQUE order_number) value
FROM xx_fusion_so_dtls_tb
WHERE 1=1
AND category_code='RETURN'
UNION
SELECT  UNIQUE 2 id,'Transfer to WMS' label,count(UNIQUE order_number) value
FROM xx_fusion_so_dtls_tb
WHERE 1=1
AND category_code='RETURN'
AND wms_transaction_id IS NOT NULL
UNION
SELECT  UNIQUE 3 id,'Received From WMS' label,count(UNIQUE sales_order) value
FROM xx_wms_ship_hdr_dtls_tb
WHERE 1=1
AND EXISTS (SELECT * FROM xx_fusion_so_dtls_tb WHERE 1=1 AND order_number=sales_order AND category_code='RETURN')
UNION
SELECT  UNIQUE 4 id,'Return' label,count(UNIQUE sales_order) value
FROM xx_wms_ship_hdr_dtls_tb
WHERE 1=1
AND EXISTS (SELECT * FROM xx_fusion_so_dtls_tb WHERE 1=1 AND order_number=sales_order AND category_code='RETURN')
AND sales_order not in  (SELECT UNIQUE order_number FROM xx_fusion_so_dtls_tb WHERE 1=1 AND category_code='RETURN' AND line_status='Awaiting Receiving'))
ORDER BY ID ASC;
