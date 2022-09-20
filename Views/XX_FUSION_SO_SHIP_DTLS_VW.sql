  CREATE OR REPLACE  VIEW "XX_FUSION_SO_SHIP_DTLS_VW"  AS 
  SELECT UNIQUE
xwsltdt.ID,
xwsltdt.SALES_ORDER,
xwsltdt.LINE_NUMBER,
xwsltdt.ITEM_NUMBER,
xwsltdt.WMS_SHIPPED_QUANTITY,
xwsltdt.WMS_SHIPPED_DATE,
xwsltdt.FUSION_PICKED_QUANTITY,
xwsltdt.FUSION_SHIPPED_QUANTITY,
xwsltdt.STAGING_SUBINVENTORY,
xwsltdt.PICKED_FROM_SUBINVENTORY,
xwsltdt.PICKED_FROM_LOCATOR,
xwsltdt.STATUS,
---------------------------
xwsltdt.BATCH_ID PICKWAVE,
xwsltdt.PICK_SLIP_NUMBER,
xwsltdt.PICK_SLIP_LINE,
xwsltdt.SHIPMENT_NUMBER,
xwsltdt.CREATION_DATE,
xwsltdt.LAST_UPDATE_DATE
----------------------------
FROM  xx_wms_ship_line_dtls_tb xwsltdt
WHERE 1=1
AND EXISTS (SELECT * FROM xx_fusion_so_dtls_tb WHERE 1=1 AND category_code='ORDER' AND order_number=xwsltdt.sales_order and oracle_code=xwsltdt.item_number and line_number=xwsltdt.line_number)
ORDER BY ID ASC;