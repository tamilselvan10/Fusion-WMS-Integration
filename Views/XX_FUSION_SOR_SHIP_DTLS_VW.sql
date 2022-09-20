 CREATE OR REPLACE  VIEW "XX_FUSION_SOR_SHIP_DTLS_VW"  AS 
  SELECT UNIQUE
xwsltdt.id,
xwsltdt.sales_order,
xwsltdt.line_number,
xwsltdt.receipt_header_id,
xwsltdt.receipt_number,
xwsltdt.receipt_date,
xwsltdt.item_number,
xwsltdt.wms_shipped_quantity,
xwsltdt.wms_shipped_date,
xwsltdt.ra_quantity_expected,
xwsltdt.quantity_received,
xwsltdt.picked_from_subinventory subinventory,
xwsltdt.picked_from_locator      locator,
xwsltdt.status,
---------------------------
xwsltdt.transaction_type,
xwsltdt.line_status,
xwsltdt.group_id,
xwsltdt.processing_status_code,
xwsltdt.return_status receipt_creation_status,
xwsltdt.creation_date,
xwsltdt.last_update_date
----------------------------
FROM  xx_wms_ship_line_dtls_tb xwsltdt
WHERE 1=1
AND EXISTS (SELECT * FROM xx_fusion_so_dtls_tb WHERE 1=1 AND category_code='RETURN' AND order_number=xwsltdt.sales_order and oracle_code=xwsltdt.item_number)
ORDER BY ID ASC