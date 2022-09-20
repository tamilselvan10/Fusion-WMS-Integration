  CREATE OR REPLACE VIEW "XX_WMS_SHIP_DTLS_VW"  AS 
  SELECT  UNIQUE a.id,
			   a.sales_order,
			   a.item_number,
			   a.wms_shipped_quantity,
			   a.wms_shipped_date,
---
(SELECT UNIQUE rma_source_system_id FROM xx_wms_ship_line_dtls_tb WHERE 1=1 AND sales_order=a.sales_order and item_number=a.item_number AND rma_source_system_id IS NOT NULL  AND ROWNUM=1) rma_source_system_id,
(SELECT UNIQUE rma_source_system_name FROM xx_wms_ship_line_dtls_tb WHERE 1=1 AND sales_order=a.sales_order and item_number=a.item_number AND rma_source_system_name IS NOT NULL AND  ROWNUM=1) rma_source_system_name,
(SELECT UNIQUE receipt_header_id FROM xx_wms_ship_line_dtls_tb WHERE 1=1 AND sales_order=a.sales_order and item_number=a.item_number AND receipt_header_id IS NOT NULL AND ROWNUM=1) receipt_header_id,
---
(SELECT UNIQUE warehouse_id FROM xx_fusion_so_dtls_tb WHERE 1=1 AND order_number=a.sales_order and oracle_code=a.item_number AND ROWNUM=1) warehouse_id,
(SELECT UNIQUE warehouse_code FROM xx_fusion_so_dtls_tb WHERE 1=1 AND order_number=a.sales_order and oracle_code=a.item_number AND ROWNUM=1) warehouse_code,
(SELECT UNIQUE category_code FROM xx_fusion_so_dtls_tb WHERE 1=1 AND order_number=a.sales_order and oracle_code=a.item_number AND ROWNUM=1) category_code
FROM xx_wms_ship_hdr_dtls_tb a 
WHERE 1=1 
AND a.status IN ('NEW','FAILED')
AND EXISTS(SELECT * FROM xx_fusion_so_dtls_tb WHERE 1=1 AND order_number=a.sales_order and oracle_code=a.item_number AND line_status IN ('Awaiting Shipping','Awaiting Receiving'));
