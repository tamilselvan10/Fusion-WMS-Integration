  CREATE OR REPLACE VIEW "XX_FUSION_SO_DTLS_VW" AS 
  SELECT UNIQUE 
--------------------------------------------------------
legal_entity_name,
business_unit,
customer_name,
customer_account_number,
ship_to_customer,
ship_to_address,
---------------------------------------------------------
order_number                        sales_order,
to_date(ordered_date, 'yyyy/mm/dd') sales_order_date,
case when category_code='ORDER' THEN 'SO' 
     when category_code='RETURN' THEN 'SO RETURN'
	 else category_code END AS order_type,
trans_curr_code                     currency,
---------------------------------------------------------
line_number,
oracle_code  item,
item_description description,
line_status,
ordered_uom uom,
ordered_qty,
picked_qty,
shipped_qty,
cancelled_qty,
unit_list_price,
unit_selling_price,
extended_amount,
warehouse_code,
warehouse_name,
return_reason,
return_type,
original_sales_order,
wms_transaction_id,
wms_result,
wms_message,
barcode,
(SELECT count(*) FROM xx_wms_ship_line_dtls_tb a  WHERE 1=1 AND a.sales_order=order_number and a.item_number=oracle_code and a.line_number=line_number) ship_records_count

FROM xx_fusion_so_dtls_tb
ORDER BY order_number,line_number ASC;