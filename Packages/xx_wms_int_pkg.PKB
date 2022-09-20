create or replace PACKAGE BODY xx_wms_int_pkg
AS
--##########################################################################
--# Filename: xx_wms_int_pkg.pkb
--# Description: Import SO Data from Fusion - WMS Oracle DB
--#   Date       | Name                                   | Remarks
--# ----------------------------------------------------------------------
--#  27-Jun-2022 | WMS Integration                        | 
--##########################################################################


    --  procedure to write log messages:
    procedure write_log(p_text in varchar2)
    is
    begin
      dbms_output.put_line(p_text);
    end write_log;	

    -- sleep:
	procedure sleep (p_milli_seconds in number) 
    as language java name 'java.lang.thread.sleep(long)';

-- get legal entity name:
function get_legal_entity_name (p_sales_order in varchar2)
return varchar2 as

lv_legal_entity_name varchar2(240):=null;

begin
---------------------------------------------------------------------------------------------------------------------
begin
select unique legal_entity_name into lv_legal_entity_name from xx_fusion_so_dtls_tb where 1=1 and order_number =p_sales_order;
exception when others then
lv_legal_entity_name:=null;
end;
---------------------------------------------------------------------------------------------------------------------

RETURN lv_legal_entity_name;

end get_legal_entity_name;

/*==================================================================================================================================*/

-- get business unit:
function get_business_unit (p_sales_order in varchar2)
return varchar2 as

lv_business_unit varchar2(240):=null;

begin

begin
select unique business_unit into lv_business_unit from xx_fusion_so_dtls_tb where 1=1 and order_number =p_sales_order;
exception when others then
lv_business_unit:=null;
end;


RETURN lv_business_unit;

end get_business_unit ;

/*==================================================================================================================================*/

-- get customer_name:
function get_customer_name(p_sales_order in varchar2)
return varchar2 as

lv_customer_name varchar2(240):=null;

begin

begin
select unique customer_name into lv_customer_name from xx_fusion_so_dtls_tb where 1=1 and order_number =p_sales_order;
exception when others then
lv_customer_name:=null;
end;

RETURN lv_customer_name;

end get_customer_name;

/*==================================================================================================================================*/

-- get Item Description:
function get_item_description(p_sales_order in varchar2,p_item_number IN VARCHAR2)
return varchar2 as

lv_item_description varchar2(240):=null;

begin

begin
select unique item_description into lv_item_description from xx_fusion_so_dtls_tb where 1=1 and order_number =p_sales_order AND item_code=p_item_number;
exception when others then
lv_item_description:=null;
end;

RETURN lv_item_description;

end get_item_description;

/*==================================================================================================================================*/

-- get uom:
function get_uom(p_sales_order in varchar2,p_item_number IN VARCHAR2)
return varchar2 as

lv_uom varchar2(240):=null;

begin

begin
select unique ordered_uom into lv_uom from xx_fusion_so_dtls_tb where 1=1 and order_number =p_sales_order AND item_code=p_item_number;
exception when others then
lv_uom:=null;
end;

RETURN lv_uom;

end get_uom;

--- Function to get received quantity:
FUNCTION get_quantity_received(p_sales_order in VARCHAR2,p_rma_line_id IN NUMBER,p_line_number in VARCHAR2,p_item_number in VARCHAR2)
RETURN NUMBER 
IS 

lv_qty_received   NUMBER:=0;

BEGIN

---
BEGIN
SELECT SUM(quantity_received)
INTO lv_qty_received
FROM  xx_wms_ship_line_dtls_tb
WHERE 1=1
AND sales_order=p_sales_order
AND rma_line_id=p_rma_line_id
AND line_number=p_line_number
AND item_number=p_item_number;
EXCEPTION WHEN OTHERS THEN
lv_qty_received:=0;
END;
---

RETURN lv_qty_received;

END;

/*==================================================================================================================================*/

-- Get fusion so data extract report request payload:
function get_report_request_payload (p_business_unit IN VARCHAR2,p_line_status in varchar2)
return varchar2 
is 

l_soap_req_msg              varchar2 (32767):=NULL;

begin

   l_soap_req_msg := '<soap:Envelope xmlns:soap="http://www.w3.org/2003/05/soap-envelope" xmlns:pub="http://xmlns.oracle.com/oxp/service/PublicReportService">
   <soap:Header/>
   <soap:Body>
      <pub:runReport>
         <pub:reportRequest>
            <pub:attributeFormat>'||c_output_format||'</pub:attributeFormat>
			<pub:flattenXML>false</pub:flattenXML>
            <pub:parameterNameValues>
				  <!--1st Parameter of BIP Report-->
                  <pub:item>
                  <pub:name>p_line_status</pub:name>
                  <pub:values>
                      <pub:item>'||p_line_status||'</pub:item>
                  </pub:values>
                  </pub:item>

				  <!--2ns Parameter of BIP Report-->
                  <pub:item>
                  <pub:name>p_start_date</pub:name>
                  <pub:values>
                      <pub:item>'||c_integration_start_date||'</pub:item>
                  </pub:values>
                  </pub:item>

				 <!--3rd Parameter of BIP Report-->
                  <pub:item>
                  <pub:name>p_business_unit</pub:name>
                  <pub:values>
                      <pub:item>'||p_business_unit||'</pub:item>
                  </pub:values>
                  </pub:item>

            </pub:parameterNameValues>
            <pub:reportAbsolutePath>'||c_so_report_xdo_path||'</pub:reportAbsolutePath>
			<pub:sizeOfDataChunkDownload>-1</pub:sizeOfDataChunkDownload>
         </pub:reportRequest>
      </pub:runReport>
   </soap:Body>
</soap:Envelope>';

return l_soap_req_msg;

end get_report_request_payload;	

-- Get fusion vendor/customer data extract report request payload:
function get_vc_report_request_payload(p_business_unit in varchar2)
return varchar2 
is 

l_soap_req_msg              varchar2 (32767):=NULL;

begin

   l_soap_req_msg := '<soap:Envelope xmlns:soap="http://www.w3.org/2003/05/soap-envelope" xmlns:pub="http://xmlns.oracle.com/oxp/service/PublicReportService">
   <soap:Header/>
   <soap:Body>
      <pub:runReport>
         <pub:reportRequest>
            <pub:attributeFormat>'||c_output_format||'</pub:attributeFormat>
			<pub:flattenXML>false</pub:flattenXML>
			<pub:parameterNameValues>
				  <!--1st Parameter of BIP Report-->
                  <pub:item>
                  <pub:name>p_business_unit</pub:name>
                  <pub:values>
                      <pub:item>'||p_business_unit||'</pub:item>
                  </pub:values>
                  </pub:item>				  
            </pub:parameterNameValues>
            <pub:reportAbsolutePath>'||c_vc_report_xdo_path||'</pub:reportAbsolutePath>
			<pub:sizeOfDataChunkDownload>-1</pub:sizeOfDataChunkDownload>								
         </pub:reportRequest>
      </pub:runReport>
   </soap:Body>
</soap:Envelope>';

return l_soap_req_msg;

end get_vc_report_request_payload;

-- WMS Item request payload:
FUNCTION get_wms_item_request_payload (p_item_id IN VARCHAR2)
RETURN clob
IS

lv_json CLOB;

BEGIN

-- item_details:
WITH item_details AS (
SELECT UNIQUE '{ '
       ||'"id":"'||item_id||'"'
       ||',"Warehouse":"'||warehouse||'"'
	   ||',"barcode":"'||barcode||'"'
	   ||',"description":"'||description||'"'	   
	   ||',"origin":"'||country_of_origin||'"'
	   ||',"item":"'||item_code||'"'
	   ---------------------------------------------------
	   ||',"color":"'||color_code||'"'
       ||',"type":"'||type||'"'
	   ||',"businessGroup":"'||business_Group_code||'"'
	   ||',"divisionGroup":"'||division_Group_code||'"'	   
	   ||',"retailGroup":"'||retail_Group_code||'"'
	   ||',"localDescription":"'||local_Description||'"'
	   ||',"uniqueDescription":"'||unique_Description||'"'
	   ||',"uom":"'||uom||'"'
	   ----------------------------------------------------
	   ||',"width":'||NVL(width,0)||''
	   ||',"grossWeight":'||gross_weight||''
	   ||',"netWeight":'||net_Weight||''
	   ||',"uomWeight":"'||uom_Weight||'"'
	   ||',"Volume":'||Volume||''
	   ----------------------------------------------------
	   ||',"Brand":"'||Brand||'"'
	   ||',"OracleCode":"'||oracle_code||'"'
       ||'}'
        json
FROM   xx_item_master_dtls_tb
WHERE 1=1
AND item_id=p_item_id
AND status='NEW')


SELECT UNIQUE
(SELECT json FROM item_details)
 INTO lv_json
FROM dual;

RETURN lv_json;

END get_wms_item_request_payload;


-- Get fusion Item Master data extract report request payload:
function get_item_report_request_payload 
return varchar2 
is 

l_soap_req_msg              varchar2 (32767):=NULL;

begin

   l_soap_req_msg := '<soap:Envelope xmlns:soap="http://www.w3.org/2003/05/soap-envelope" xmlns:pub="http://xmlns.oracle.com/oxp/service/PublicReportService">
   <soap:Header/>
   <soap:Body>
      <pub:runReport>
         <pub:reportRequest>
            <pub:attributeFormat>'||c_output_format||'</pub:attributeFormat>
			<pub:flattenXML>false</pub:flattenXML>
            <pub:parameterNameValues>
				  <!--1st Parameter of BIP Report-->
                  <pub:item>
                  <pub:name>p_org_code</pub:name>
                  <pub:values>
                      <pub:item>'||c_org_code||'</pub:item>
                  </pub:values>
                  </pub:item>
            </pub:parameterNameValues>
            <pub:reportAbsolutePath>'||c_item_report_xdo_path||'</pub:reportAbsolutePath>
			<pub:sizeOfDataChunkDownload>-1</pub:sizeOfDataChunkDownload>
         </pub:reportRequest>
      </pub:runReport>
   </soap:Body>
</soap:Envelope>';

return l_soap_req_msg;

end get_item_report_request_payload;		

--generate user token:
FUNCTION generate_user_token
RETURN VARCHAR2 IS 

  req utl_http.req;
  res utl_http.resp;

  l_text     VARCHAR2(32767);
  l_clob     CLOB;
  content    CLOB;

  obj pljson;

BEGIN

   content:=   '{
    "UserCode":"'||c_user_code||'"'
||',"UserPassword":"'||c_user_password||'"'
||'}';

 -- Make a HTTP request and get the response. 	
  req := utl_http.begin_request (url=>c_user_token_url,
                                 method=>c_user_token_http_method,
								 http_version=>c_user_token_http_version);

  utl_http.set_header(req, 'content-type'  ,c_user_token_content_type); 
  utl_http.set_header(req, 'Content-Length', LENGTH(content));

  utl_http.write_text(req, content);
  res := utl_http.get_response(req);

  write_log('Request:');
  write_log('--------');
  write_log(content);

-------------------------------------------------------------  
 -- Build a CLOB variable to hold web service response
        dbms_lob.createtemporary(l_clob, FALSE );
        dbms_lob.open(l_clob, dbms_lob.lob_readwrite );

         write_log('Response:');
         write_log('--------');
BEGIN
LOOP
   -- Copy the web service response body
   -- in a buffer string variable l_text
   utl_http.read_text(res, l_text, 32766);
   write_log(l_text);

   -- Append data from l_text to CLOB variable
dbms_lob.writeappend(l_clob, length(l_text), l_text);

END LOOP;
EXCEPTION
       WHEN OTHERS THEN
          --  Exit loop without exception
          --  when end-of-body is reached
          IF SQLCODE <> -29266 THEN
             RAISE;
          END IF;
END;
utl_http.end_response(res);

  ---parse it into a pljson object:
  obj := pljson(l_clob);

 RETURN pljson_ext.get_string(obj, 'Token');

 dbms_lob.freetemporary(l_clob); 

EXCEPTION
	WHEN utl_http.too_many_requests 
	THEN 
	write_log('Error Occured while executing the "generate_user_token"');
    write_log('Error Code   :'||SQLCODE);
    write_log('Error Message:'||SQLERRM);
	utl_http.end_response(res);
    WHEN utl_http.end_of_body 
    THEN 
	write_log('Error Occured while executing the "generate_user_token"');
    write_log('Error Code   :'||SQLCODE);
    write_log('Error Message:'||SQLERRM);
	utl_http.end_response(res);
	WHEN OTHERS 
	THEN 
	write_log('Error Occured while executing the "generate_user_token"');
    write_log('Error Code   :'||SQLCODE);
    write_log('Error Message:'||SQLERRM);
	utl_http.end_response(res);
END generate_user_token;

-- WMS Sales Order request payload for Shipment:
FUNCTION get_wms_so_request_payload (p_header_id IN NUMBER,p_order_number IN VARCHAR2)
RETURN clob
IS

lv_json CLOB;

BEGIN

-- header_details:
WITH header_details AS (
SELECT UNIQUE '{ '
       ||'"id":"'||h.header_id||'"'
       ||',"doctype":"'||DECODE(h.category_code,'RETURN','ORDER_RTN',h.category_code)||'"'
	   ||',"warehouse":"'||h.warehouse_code||'"'
	   ||',"isCancelled":'||DECODE(h.header_canceled_flag,'Y','true','false')||''
	   ||',"orderNum":"'||h.order_number||'"'
	  ||',"custAccount":"'||h.customer_name||'"'
	   ||',"custName":"'||h.customer_name||'"'
	   ||',"deliveryDate":"'||NVL(h.scheduled_ship_date,h.ordered_creation_date)||'"'
	   ||',"currency":"'||h.trans_curr_code||'"'
	   ||',"numberOfItems":'||(select count(distinct line_id) from xx_fusion_so_dtls_tb a where 1=1 and a.header_id=h.header_id)||''
	   ||',"totalQTY":'||(select sum(ordered_qty) from xx_fusion_so_dtls_tb a where 1=1 and a.header_id=h.header_id) ||''
        json,header_id,order_number
FROM   xx_fusion_so_dtls_tb h
WHERE 1=1
AND h.header_id=p_header_id
AND h.order_number=p_order_number 
AND (h.wms_success<>'true' or h.wms_success IS NULL)
AND h.line_status IN ('Awaiting Shipping','Awaiting Receiving'))

-- line_details:
,line_details AS (
SELECT UNIQUE '{ '
       ||'"oracleCode":"'||h.oracle_code||'"'
	   ||',"barcode":"'||h.barcode||'"'
       ||',"itemCode":"'||h.item_code||'"'
       ||',"qty":'||h.ordered_qty||''
       ||'} ' json
FROM   xx_fusion_so_dtls_tb h
WHERE 1=1
AND (h.wms_success<>'true' or h.wms_success IS NULL)
AND h.header_id= (SELECT UNIQUE header_id FROM header_details WHERE 1=1))


SELECT UNIQUE
(SELECT json FROM header_details)
||',"itemLines":'||(  select '['||listagg( json, ',')
                                                  within group (order by 1)
                                  ||']'
                             from line_details
                          )
    ||'} ' INTO lv_json
FROM dual;

RETURN lv_json;

END get_wms_so_request_payload;


-- WMS Vendor/Customer Master request payload:
FUNCTION get_wms_vc_request_payload(
                                p_party_id in varchar2,
								p_party_code in varchar2,
								p_party_name in varchar2)
RETURN clob
IS

lv_json CLOB;

BEGIN

-- master details:
WITH cv_master AS (
SELECT UNIQUE '{ '
       ||'"id":"'||party_id||'"'
       ||',"type":"'||party_type||'"'
	   ||',"code":"'||party_code||'"'
	   ||',"name":"'||party_name||'"'
	   ||',"phone":"'||phone_number||'"'
	   ||',"email":"'||email_address||'"'
	   ||',"creditPeriod":'||credit_period_days||''
	   ||',"creditLimit":'||credit_limit_amount||''
	---   ||'}'
        json
FROM   xx_fusion_cust_vend_dtls_tb
WHERE 1=1
AND party_id=p_party_id
AND party_code=p_party_code
AND status='NEW'
AND message IS NULL )

-- address details:
 ,cv_address AS (
SELECT UNIQUE '{ '
       ||'"SiteCode":"'||party_site_code||'"'
       ||',"SiteName":"'||party_site_name||'"'
	   ||',"ShipToLocation":"'||ship_to_location||'"'
	   ||',"SiteAddress":"'||party_site_address||'"'
       ||'}'
        json
FROM   xx_fusion_cust_vend_dtls_tb
WHERE 1=1
AND party_id=p_party_id
AND party_code=p_party_code
AND status='NEW'
AND message IS NULL )


SELECT UNIQUE
(SELECT json FROM cv_master)
||',"address":'||(  select '['||listagg( json, ',')
                                                  within group (order by 1)
                                  ||']'
                             from cv_address
                          )
    ||'} ' INTO lv_json
FROM dual;

RETURN lv_json;

END get_wms_vc_request_payload;

-- get Create Pick Wave Request payload:
FUNCTION get_crt_pickwave_req_payload(p_sales_order_number IN VARCHAR2,p_id IN NUMBER)
RETURN CLOB
IS

lv_json           CLOB;

BEGIN

---Create pick wave details:
WITH cpw_details AS (
SELECT UNIQUE '{ '
       ||'"SourceSystemName":"'||a.source_system_name||'"'	
	   ||',"ReleaseRule":"'||c_release_rule||'"'	   
       ||',"ShipFromOrganizationCode":"'||a.warehouse_code||'"'
	   ||',"ReleaseStatus":"All"'
	   ||',"OrderType":"Sales order"'
	   ||',"OrderNumber":"'||a.order_number||'"'
	   ||',"Customer":"'||a.customer_name||'"'
	   ||',"ItemNumber":"'||a.oracle_code||'"'	   	  
       ||'} ' json
FROM   xx_fusion_so_dtls_tb a
WHERE 1=1
AND a.line_status='Awaiting Shipping'
AND EXISTS (SELECT * FROM xx_wms_ship_hdr_dtls_tb b
WHERE 1=1 
AND b.sales_order=p_sales_order_number 
AND b.id=p_id
AND b.sales_order=a.order_number 
AND b.item_number=a.oracle_code
and b.status='NEW'
))

SELECT UNIQUE
(SELECT json FROM cpw_details)
INTO lv_json
FROM dual;

RETURN lv_json;

EXCEPTION WHEN OTHERS THEN
write_log('Error Occured while executing the function "get_crt_pickwave_req_payload" ');
write_log('Error Code   :'||SQLCODE);
write_log('Error Message:'||SQLERRM);
END get_crt_pickwave_req_payload;

-- Get Pick Slip Request payload:
FUNCTION get_cnf_pickslip_req_payload  (p_id IN NUMBER,p_sales_order IN VARCHAR2,p_batch_id IN VARCHAR2,p_item_number IN VARCHAR2,
                                       p_wms_shipped_qty IN NUMBER,p_wms_shipped_date IN VARCHAR2)
RETURN CLOB
AS

 PRAGMA AUTONOMOUS_TRANSACTION;



  lv_json CLOB:=NULL;

  req utl_http.req;
  res utl_http.resp;

  l_text     VARCHAR2(32767);
  l_clob     CLOB;
  lv_url     VARCHAR2(4000):=NULL;

   lv_pick_slip_line_payload VARCHAR2(1000):=NULL;

   lv_wms_shipped_qty    NUMBER;
   lv_wms_shipped_date   VARCHAR2(50);
   lv_sales_order        VARCHAR2(30);
   lv_item_number        VARCHAR2(30);
   lv_pick_slip_number   VARCHAR2(240):=NULL;
   lv_shipment_number    VARCHAR2(240):=NULL;

   obj                   pljson;
   lv_original_wship_qty NUMBER:=0;
   lv_item_description   VARCHAR2(240):=NULL;

BEGIN

---------------------------
BEGIN
SELECT wms_shipped_quantity
INTO lv_original_wship_qty
FROM  xx_wms_ship_hdr_dtls_tb
WHERE 1=1
AND id=p_id;
EXCEPTION WHEN OTHERS THEN
lv_original_wship_qty:=0;
END;
---------------------------
BEGIN
SELECT UNIQUE item_description
INTO lv_item_description
FROM  xx_fusion_so_dtls_tb
WHERE 1=1
AND order_number=p_sales_order
AND oracle_code=p_item_number;
EXCEPTION WHEN OTHERS THEN
lv_item_description:=0;
END;
---------------------------

lv_wms_shipped_qty:=p_wms_shipped_qty;
lv_wms_shipped_date:=p_wms_shipped_date;
lv_sales_order:=p_sales_order;
lv_item_number:=p_item_number;


BEGIN
xx_wms_int_pkg.get_pick_slip_details(p_batch_id =>p_batch_id,
                                     p_pick_slip_number=>lv_pick_slip_number,
                                     p_shipment_number=>lv_shipment_number);
write_log('lv_pick_slip_number:'||lv_pick_slip_number);
write_log('lv_shipment_number:'||lv_shipment_number);
END;


   lv_url:=c_instance_url||'/fscmRestApi/resources/11.13.18.05/pickSlipDetails/'||lv_pick_slip_number||'/child/pickLines?orderBy=SourceOrderLine&fields=SourceOrder,SourceOrderLine,PickSlip,PickSlipLine,Item,RequestedQuantity,MaximumPickedQuantity,SourceSubinventory,SourceLocator,DestinationSubinventory,ShipToLocation,Customer,UOM&onlyData=true&totalResults=false&q=Item='||lv_item_number;

   write_log('url:'||lv_url);

-- If using HTTPS, open a wallet containing the trusted root certificate.
  utl_http.set_wallet (path=>c_wallet_path,password=>c_wallet_pwd);

 -- Make a HTTP request and put the response. 	
  req := utl_http.begin_request (url=>lv_url,method=>c_gps_http_method,http_version=>c_gps_http_version);

  utl_http.set_authentication (req,c_username,c_password);

  res := utl_http.get_response(req);

-------------------------------------------------------------  
 -- Build a CLOB variable to hold web service response
        dbms_lob.createtemporary(l_clob, FALSE );
        dbms_lob.open(l_clob, dbms_lob.lob_readwrite );

         write_log('Response:');
         write_log('--------');
BEGIN
LOOP
   -- Copy the web service response body
   -- in a buffer string variable l_text
   utl_http.read_text(res, l_text, 32766);
   write_log(l_text);

   -- Append data from l_text to CLOB variable
dbms_lob.writeappend(l_clob, length(l_text), l_text);

END LOOP;
EXCEPTION
       WHEN OTHERS THEN
          --  Exit loop without exception
          --  when end-of-body is reached
          IF SQLCODE <> -29266 THEN
             RAISE;
          END IF;
END;

utl_http.end_response(res);

  ---parse it into a pljson object:
  obj := pljson(l_clob);

  --then modify the object:
  pljson_ext.remove(obj, 'links');

  --finally, update the clob and commit:
  dbms_lob.trim(l_clob, 0); --empty the lob
  obj.to_clob(l_clob);
------------------------------------------------------------------------------------
DELETE  XX_WMS_PICK_SLIP_TEMP_TB;
COMMIT;
------------------------------------------------------------------------------------
INSERT INTO XX_WMS_PICK_SLIP_TEMP_TB
select *
from table(
pljson_table.json_table(l_clob,
pljson_varray('items[*].SourceOrder',
              'items[*].SourceOrderLine',
			  'items[*].PickSlip',
			  'items[*].PickSlipLine',
			  'items[*].Item',
			  'items[*].RequestedQuantity',
			  'items[*].MaximumPickedQuantity',
			  'items[*].SourceSubinventory',
			  'items[*].SourceLocator',
			  'items[*].DestinationSubinventory',
			  'items[*].ShipToLocation',
			  'items[*].Customer',
			  'items[*].UOM'),
pljson_varray('SourceOrder','SourceOrderLine','PickSlip','PickSlipLine','Item','RequestedQuantity','MaximumPickedQuantity','SourceSubinventory','SourceLocator','DestinationSubinventory','ShipToLocation','Customer','UOM'),
table_mode => 'nested')
);
COMMIT;

-----------------------------------------------------------------------------------------------------------------------------------------------
lv_pick_slip_line_payload :=NULL;

BEGIN

FOR i IN (select * from xx_wms_pick_slip_temp_tb where 1=1 and pickslip=lv_pick_slip_number order by sourceorderline asc)
LOOP
----------------------------------------------------------------------------
IF i.maximumpickedquantity>lv_wms_shipped_qty THEN

IF lv_pick_slip_line_payload IS NOT NULL THEN  lv_pick_slip_line_payload:=lv_pick_slip_line_payload||',' ; END IF;

lv_pick_slip_line_payload:=lv_pick_slip_line_payload||
'{ '||'"PickSlip":'||i.pickslip||''
    ||',"PickSlipLine":'||i.pickslipline||''
    ||',"PickedQuantity":'||lv_wms_shipped_qty||''
    ||'} ';

INSERT INTO xx_wms_ship_line_dtls_tb
(
id                           ,
batch_id                     ,
------------------------------------------------
customer_name                ,
ship_to_location             ,
-------------------------------------------------
sales_order                  ,
line_number                  ,
item_number                  ,
item_description             ,
uom                          ,
wms_shipped_quantity         ,
wms_shipped_date             ,
fusion_picked_quantity       ,
fusion_shipped_quantity      ,
staging_subinventory         ,
picked_from_subinventory     ,
picked_from_locator          , 
status                       ,
pick_slip_number             ,
pick_slip_line               ,
shipment_number              ,
creation_date                ,
last_update_date             
)
VALUES
(
p_id                         ,
p_batch_id                   ,
------------------------------------------------
i.customer                   ,
i.shiptolocation             ,
-------------------------------------------------
lv_sales_order               ,
i.sourceorderline            ,
i.item                       ,
lv_item_description          ,
i.uom                        ,
lv_original_wship_qty        ,
lv_wms_shipped_date          ,
NULL                         ,
NULL                         ,
i.DestinationSubinventory    ,
i.SourceSubinventory         ,
i.sourcelocator              ,
NULL                         ,
lv_pick_slip_number          ,
i.pickslipline               ,
lv_shipment_number           ,
TO_CHAR(SYSDATE,'DD-MON-YYYY HH24:MI:SS'),
TO_CHAR(SYSDATE,'DD-MON-YYYY HH24:MI:SS')            
);
COMMIT;

lv_wms_shipped_qty:=0;
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
ELSIF i.maximumpickedquantity=lv_wms_shipped_qty THEN

IF lv_pick_slip_line_payload IS NOT NULL THEN  lv_pick_slip_line_payload:=lv_pick_slip_line_payload||',' ; END IF;

lv_pick_slip_line_payload:=lv_pick_slip_line_payload||
'{ '||'"PickSlip":'||i.pickslip||''
    ||',"PickSlipLine":'||i.pickslipline||''
    ||',"PickedQuantity":'||lv_wms_shipped_qty||''
    ||'} ';


INSERT INTO xx_wms_ship_line_dtls_tb
(
id                           ,
batch_id                     ,
------------------------------------------------
customer_name                ,
ship_to_location             ,
-------------------------------------------------
sales_order                  ,
line_number                  ,
item_number                  ,
item_description             ,
uom                          ,
wms_shipped_quantity         ,
wms_shipped_date             ,
fusion_picked_quantity       ,
fusion_shipped_quantity      ,
staging_subinventory         ,
picked_from_subinventory     ,
picked_from_locator         , 
status                       ,
pick_slip_number             ,
pick_slip_line               ,
shipment_number              ,
creation_date                ,
last_update_date             
)
VALUES
(
p_id                         ,
p_batch_id                   ,
------------------------------------------------
i.customer                   ,
i.shiptolocation             ,
-------------------------------------------------
lv_sales_order               ,
i.sourceorderline            ,
i.item                       ,
lv_item_description          ,
i.uom                        ,
lv_original_wship_qty        ,
lv_wms_shipped_date          ,
NULL                         ,
NULL                         ,
i.DestinationSubinventory    ,
i.SourceSubinventory         ,
i.sourcelocator              ,
NULL                         ,
lv_pick_slip_number          ,
i.pickslipline               ,
lv_shipment_number           ,
TO_CHAR(SYSDATE,'DD-MON-YYYY HH24:MI:SS'),
TO_CHAR(SYSDATE,'DD-MON-YYYY HH24:MI:SS')        
);
COMMIT;

lv_wms_shipped_qty:=0;
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

ELSIF i.maximumpickedquantity<lv_wms_shipped_qty THEN

IF lv_pick_slip_line_payload IS NOT NULL THEN  lv_pick_slip_line_payload:=lv_pick_slip_line_payload||',' ; END IF;

lv_pick_slip_line_payload:=lv_pick_slip_line_payload||
 '{'||'"PickSlip":'||i.pickslip||''
    ||',"PickSlipLine":'||i.pickslipline||''
    ||',"PickedQuantity":'||i.maximumpickedquantity||''
    ||'} ';

INSERT INTO xx_wms_ship_line_dtls_tb
(
id                           ,
batch_id                     ,
------------------------------------------------
customer_name                ,
ship_to_location             ,
-------------------------------------------------
sales_order                  ,
line_number                  ,
item_number                  ,
item_description             ,
uom                          ,
wms_shipped_quantity         ,
wms_shipped_date             ,
fusion_picked_quantity       ,
fusion_shipped_quantity      ,
staging_subinventory         ,
picked_from_subinventory     ,
picked_from_locator          , 
status                       ,
pick_slip_number             ,
pick_slip_line               ,
shipment_number              ,
creation_date                ,
last_update_date             
)
VALUES
(
p_id                         ,
p_batch_id                   ,
------------------------------------------------
i.customer                   ,
i.shiptolocation             ,
-------------------------------------------------
lv_sales_order               ,
i.sourceorderline            ,
i.item                       ,
lv_item_description          ,
i.uom                        ,
lv_original_wship_qty        ,
lv_wms_shipped_date          ,
NULL                         ,
NULL                         ,
i.DestinationSubinventory    ,
i.SourceSubinventory         ,
i.sourcelocator              ,
NULL                         ,
lv_pick_slip_number          ,
i.pickslipline               ,
lv_shipment_number           ,
TO_CHAR(SYSDATE,'DD-MON-YYYY HH24:MI:SS'),
TO_CHAR(SYSDATE,'DD-MON-YYYY HH24:MI:SS')            
);
COMMIT;

lv_wms_shipped_qty:=(lv_wms_shipped_qty-i.maximumpickedquantity);
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
END IF;
--------------------------------------------------------------------------------
EXIT WHEN lv_wms_shipped_qty<=0;
END LOOP;
END;
--------------------------------------------------------------------------------------
DELETE  XX_WMS_PICK_SLIP_TEMP_TB;
COMMIT;

dbms_lob.freetemporary(l_clob);

SELECT UNIQUE
'{"OverpickAndMoveFlag": "false"'
||',"pickLines" :['||lv_pick_slip_line_payload
       ||']} ' INTO lv_json
FROM dual;

RETURN lv_json;

EXCEPTION
	WHEN utl_http.too_many_requests 
	THEN 

	write_log('Error Occured while executing the "get_cnf_pickslip_req_payload "');
    write_log('Error Code   :'||SQLCODE);
    write_log('Error Message:'||SQLERRM);
	utl_http.end_response(res);

    WHEN utl_http.end_of_body 
    THEN 

	write_log('Error Occured while executing the "get_cnf_pickslip_req_payload "');
    write_log('Error Code   :'||SQLCODE);
    write_log('Error Message:'||SQLERRM);
	utl_http.end_response(res);

	WHEN OTHERS 
	THEN 

	write_log('Error Occured while executing the "get_cnf_pickslip_req_payload "');
    write_log('Error Code   :'||SQLCODE);
    write_log('Error Message:'||SQLERRM);
	utl_http.end_response(res);

END get_cnf_pickslip_req_payload ;

-- Get Shipment Lines Payload:
FUNCTION get_shipment_lines_payload  (p_sales_order IN VARCHAR2,p_batch_id IN VARCHAR2,p_item_number IN VARCHAR2)
RETURN VARCHAR2
AS

  req utl_http.req;
  res utl_http.resp;

  l_text     VARCHAR2(32767);
  l_clob     CLOB;
  lv_url     VARCHAR2(4000):=NULL;
  obj        pljson;

  lv_lines                  VARCHAR2(240):=NULL;
  lv_shipment_lines_payload VARCHAR2(32767):=NULL;
  lv_shipment_line_payload  VARCHAR2(32767):=NULL;

BEGIN

   lv_url:=c_instance_url||'/fscmRestApi/resources/11.13.18.05/shipmentLines/?fields=ShipmentLine&q=Order='||p_sales_order||';PickWaveId='||p_batch_id||';Item='||p_item_number||';LineStatus=Staged';

   write_log('url:'||lv_url);

-- If using HTTPS, open a wallet containing the trusted root certificate.
  utl_http.set_wallet (path=>c_wallet_path,password=>c_wallet_pwd);

 -- Make a HTTP request and put the response. 	
  req := utl_http.begin_request (url=>lv_url,method=>'GET',http_version=>c_gps_http_version);

  utl_http.set_authentication (req,c_username,c_password);

  res := utl_http.get_response(req);

-------------------------------------------------------------  
 -- Build a CLOB variable to hold web service response
        dbms_lob.createtemporary(l_clob, FALSE );
        dbms_lob.open(l_clob, dbms_lob.lob_readwrite );

         write_log('Response:');
         write_log('--------');
BEGIN
LOOP
   -- Copy the web service response body
   -- in a buffer string variable l_text
   utl_http.read_text(res, l_text, 32766);
   write_log(l_text);

   -- Append data from l_text to CLOB variable
dbms_lob.writeappend(l_clob, length(l_text), l_text);

END LOOP;
EXCEPTION
       WHEN OTHERS THEN
          --  Exit loop without exception
          --  when end-of-body is reached
          IF SQLCODE <> -29266 THEN
             RAISE;
          END IF;
END;

utl_http.end_response(res);

  ---parse it into a pljson object:
  obj := pljson(l_clob);

  --then modify the object:
  pljson_ext.remove(obj, 'links');

  --finally, update the clob and commit:
  dbms_lob.trim(l_clob, 0); --empty the lob
  obj.to_clob(l_clob);

--- Get List of Shipment Lines:
BEGIN
select LISTAGG(ShipmentLine, ',') 
INTO lv_lines
from table(
pljson_table.json_table(l_clob,
pljson_varray('items[*].ShipmentLine'),
pljson_varray('ShipmentLine'),
table_mode => 'nested'));
EXCEPTION WHEN OTHERS THEN
lv_lines:=NULL;
END;

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
lv_shipment_line_payload:=NULL;
FOR m IN (
SELECT DISTINCT column_value FROM (SELECT * FROM 
  TABLE(comma_to_table(lv_lines))))
LOOP
lv_shipment_line_payload:=(CASE WHEN lv_shipment_line_payload IS NOT NULL
                               THEN lv_shipment_line_payload||'<typ:ShipmentLineList>'||m.column_value||'</typ:ShipmentLineList>'
							   ELSE '<typ:ShipmentLineList>'||m.column_value||'</typ:ShipmentLineList>'
							   END);
END LOOP;  
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
lv_shipment_lines_payload:='<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:typ="http://xmlns.oracle.com/apps/scm/shipping/shipConfirm/deliveries/shipmentLineService/types/">
   <soapenv:Header/>
   <soapenv:Body>
      <typ:AutocreateShipments>
         <typ:apiVersionNumber>1.0</typ:apiVersionNumber>
         <!--1 or more repetitions:-->
         '||lv_shipment_line_payload||'
      </typ:AutocreateShipments>
   </soapenv:Body>
</soapenv:Envelope>';

RETURN lv_shipment_lines_payload;

EXCEPTION
	WHEN utl_http.too_many_requests 
	THEN 

	write_log('Error Occured while executing the "get_shipment_lines_payload "');
    write_log('Error Code   :'||SQLCODE);
    write_log('Error Message:'||SQLERRM);
	utl_http.end_response(res);

    WHEN utl_http.end_of_body 
    THEN 

	write_log('Error Occured while executing the "get_shipment_lines_payload "');
    write_log('Error Code   :'||SQLCODE);
    write_log('Error Message:'||SQLERRM);
	utl_http.end_response(res);

	WHEN OTHERS 
	THEN 

	write_log('Error Occured while executing the "get_shipment_lines_payload "');
    write_log('Error Code   :'||SQLCODE);
    write_log('Error Message:'||SQLERRM);
	utl_http.end_response(res);

END get_shipment_lines_payload ;

-- Get Shipment Lines:
FUNCTION get_shipment_lines (p_sales_order in varchar2,p_batch_id in varchar2,p_item_number in varchar2)
RETURN VARCHAR2
AS
  req utl_http.req;
  res utl_http.resp;

  l_text     VARCHAR2(32767);
  l_clob     CLOB;
  lv_url     VARCHAR2(4000):=NULL;
  obj        pljson;

  lv_lines   VARCHAR2(240):=NULL;

BEGIN

   lv_url:=c_instance_url||'/fscmRestApi/resources/11.13.18.05/shipmentLines/?fields=ShipmentLine&q=Order='||p_sales_order||';PickWaveId='||p_batch_id||';Item='||p_item_number||';LineStatus=Staged';

   write_log('url:'||lv_url);

-- If using HTTPS, open a wallet containing the trusted root certificate.
  utl_http.set_wallet (path=>c_wallet_path,password=>c_wallet_pwd);

 -- Make a HTTP request and put the response. 	
  req := utl_http.begin_request (url=>lv_url,method=>'GET',http_version=>c_gps_http_version);

  utl_http.set_authentication (req,c_username,c_password);

  res := utl_http.get_response(req);

-------------------------------------------------------------  
 -- Build a CLOB variable to hold web service response
        dbms_lob.createtemporary(l_clob, FALSE );
        dbms_lob.open(l_clob, dbms_lob.lob_readwrite );

         write_log('Response:');
         write_log('--------');
BEGIN
LOOP
   -- Copy the web service response body
   -- in a buffer string variable l_text
   utl_http.read_text(res, l_text, 32766);
   write_log(l_text);

   -- Append data from l_text to CLOB variable
dbms_lob.writeappend(l_clob, length(l_text), l_text);

END LOOP;
EXCEPTION
       WHEN OTHERS THEN
          --  Exit loop without exception
          --  when end-of-body is reached
          IF SQLCODE <> -29266 THEN
             RAISE;
          END IF;
END;

utl_http.end_response(res);

  ---parse it into a pljson object:
  obj := pljson(l_clob);

  --then modify the object:
  pljson_ext.remove(obj, 'links');

  --finally, update the clob and commit:
  dbms_lob.trim(l_clob, 0); --empty the lob
  obj.to_clob(l_clob);

--- Get List of Shipment Lines:
BEGIN
select LISTAGG(ShipmentLine, ',') 
INTO lv_lines
from table(
pljson_table.json_table(l_clob,
pljson_varray('items[*].ShipmentLine'),
pljson_varray('ShipmentLine'),
table_mode => 'nested'));
EXCEPTION WHEN OTHERS THEN
lv_lines:=NULL;
END;

dbms_lob.freetemporary (l_clob);

RETURN lv_lines;

EXCEPTION
	WHEN utl_http.too_many_requests 
	THEN 

	write_log('Error Occured while executing the "get_shipment_lines"');
    write_log('Error Code   :'||SQLCODE);
    write_log('Error Message:'||SQLERRM);
	utl_http.end_response(res);

    WHEN utl_http.end_of_body 
    THEN 

	write_log('Error Occured while executing the "get_shipment_lines"');
    write_log('Error Code   :'||SQLCODE);
    write_log('Error Message:'||SQLERRM);
	utl_http.end_response(res);

	WHEN OTHERS 
	THEN 

	write_log('Error Occured while executing the "get_shipment_lines"');
    write_log('Error Code   :'||SQLCODE);
    write_log('Error Message:'||SQLERRM);
	utl_http.end_response(res);

END get_shipment_lines;


   -- get receipt creation request payload:
   function get_receipt_req_payload (p_id in number,p_sales_order_number in varchar2,p_item_number in varchar2,p_wms_shipped_qty in number,
                                  p_wms_shipped_date in varchar2)
   return clob
   IS
   PRAGMA AUTONOMOUS_TRANSACTION;
 lv_json CLOB;   
  -- soap requests message
  l_soap_req_msg                varchar2(32767):=NULL;

  -- http request/response
  http_req                      utl_http.req;
  http_resp                     utl_http.resp;
  l_clob                        clob;
  l_text                        varchar2(32767);

lv_header_payload       VARCHAR2(32767):=NULL;
lv_line_payload         VARCHAR2(32767):=NULL;
lv_bu                   VARCHAR2(240):=NULL;
lv_le                   VARCHAR2(240):=NULL;
lv_ship_to_location     VARCHAR2(240):=NULL;
------------------------------------------------------------------------------------
lv_wms_shipped_qty      NUMBER:=0;
lv_wms_shipped_date     VARCHAR2(30):=NULL; 
lv_picked_from_subinv   VARCHAR2(240):=NULL;
lv_picked_from_locator  VARCHAR2(240):=NULL; 
------------------------------------------------------------------------------------
lv_warehouse_code       VARCHAR2(240):=NULL;
lv_customer_name        VARCHAR2(240):=NULL;
lv_original_sales_order VARCHAR2(240):=NULL;
lv_quantity             NUMBER:=0;


BEGIN

--- get warehouse code,customer,BU and LE:
BEGIN
SELECT UNIQUE warehouse_code,customer_name,business_unit,legal_entity_name,original_sales_order
INTO lv_warehouse_code,lv_customer_name,lv_bu,lv_le,lv_original_sales_order
FROM xx_fusion_so_dtls_tb
WHERE 1=1
AND line_status<>'Awaiting Billing'
AND order_number=p_sales_order_number
AND oracle_code=p_item_number
AND ROWNUM=1;
EXCEPTION WHEN OTHERS THEN
NULL;
END;


l_soap_req_msg :='<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:typ="http://xmlns.oracle.com/apps/scm/receiving/receiptsInterface/receiptAdvice/receiptAdviceService/types/" xmlns:rec="http://xmlns.oracle.com/apps/scm/receiving/receiptsInterface/receiptAdvice/receiptAdviceService/">
   <soapenv:Header/>
   <soapenv:Body>
      <typ:getReceiptAdviceDetailsAsync>
         <typ:ReceiptAdviceParameter>
            <rec:OrganizationCode>'||lv_warehouse_code||'</rec:OrganizationCode>
            <rec:RMA>'||p_sales_order_number||'</rec:RMA>
            <rec:Item>'||p_item_number||'</rec:Item>
            <rec:Resend>Y</rec:Resend>
         </typ:ReceiptAdviceParameter>
      </typ:getReceiptAdviceDetailsAsync>
   </soapenv:Body>
</soapenv:Envelope>';

    write_log('l_soap_req_msg:'||l_soap_req_msg );

  -- set wallet directory
    utl_http.set_wallet (path=>c_wallet_path,password=>c_wallet_pwd);

  -- WSDL url for fusion report web service is placed in UTL_HTTP.begin_request, web service handler as 'POST' and protocol version HTTP/1.1
    http_req := utl_http.begin_request (url=>c_ges_ship_wsdl_url,
	                                    method=>c_ges_ship_http_method,
										http_version=>c_ges_ship_http_version);

    utl_http.set_header (http_req, 'Content-Type'  , c_ges_ship_content_type);--type of input data i.e. request payload
    utl_http.set_header (http_req, 'Content-Length', length (l_soap_req_msg));
    utl_http.set_header (http_req, 'SOAPAction'    , c_ges_ship_soap_action);
    utl_http.set_header (http_req, 'Connection'    , c_ges_ship_connection);

  --Specify fusion user's username and password
    utl_http.set_authentication (http_req,c_username,c_password);

    utl_http.write_text (http_req, l_soap_req_msg);

  -- invoke request and get response.
    http_resp := utl_http.get_response (http_req);

    dbms_lob.createtemporary (l_clob, false);
    dbms_lob.open (l_clob, dbms_lob.lob_readwrite);


BEGIN
LOOP
   -- Copy the web service response body
   -- in a buffer string variable l_text
   utl_http.read_text(http_resp, l_text, 32766);
   write_log(l_text);

   -- Append data from l_text to CLOB variable
   dbms_lob.writeappend(l_clob, length(l_text), l_text);

END LOOP;
EXCEPTION
       WHEN OTHERS THEN
          --  Exit loop without exception
          --  when end-of-body is reached
          IF SQLCODE <> -29266 THEN
             RAISE;
          END IF;
END;

utl_http.end_response (http_resp);    
-------------------------------------------------------------------------------------------------------------
lv_wms_shipped_qty:=p_wms_shipped_qty;
lv_wms_shipped_date:=p_wms_shipped_date;

-- Get Picked From Subinventory and Locator:
BEGIN
SELECT UNIQUE picked_from_subinventory,picked_from_locator,ship_to_location
INTO lv_picked_from_subinv,lv_picked_from_locator,lv_ship_to_location
FROM xx_wms_ship_line_dtls_tb 
WHERE 1=1 
AND ROWNUM=1
AND sales_order=lv_original_sales_order
AND item_number=p_item_number;
EXCEPTION WHEN OTHERS THEN
NULL;
END;
--------------------------------------------------------------------------------------------------------------
lv_header_payload:=NULL;
lv_header_payload:='{ "ReceiptSourceCode": "CUSTOMER"'
          ||',"OrganizationCode":"'||lv_warehouse_code||'"'
          ||',"ASNType": "STD"'
	      ||',"CustomerPartyName":"'||lv_customer_name||'"'
	      ||',"BusinessUnit":"'||lv_bu||'"'
	      ||',"RMASourceSystemName":"Oracle Fusion Order Orchestration And Planning"';		  
--------------------------------------------------------------------------------------------------------------



 BEGIN
 FOR i IN (
 select UNIQUE Receipt_Source_Code,source_document_code,organization_code,rma_number,rma_line_number,
 item_number,item_description,quantity,uom,rma_line_id,original_sales_order,customer_name,receiving_location,status
 from
  (select xmltype(l_clob) xml from dual) t,
   xmltable(
   xmlnamespaces (
     'http://schemas.xmlsoap.org/soap/envelope/' as "e"
	,'http://xmlns.oracle.com/apps/scm/receiving/receiptsInterface/receiptAdvice/receiptAdviceService/types/' as "ns0"
	,'http://xmlns.oracle.com/apps/scm/receiving/receiptsInterface/receiptAdvice/receiptAdviceService/' as "ns2"
   ),
   'e:Envelope/e:Body/ns0:getReceiptAdviceDetailsAsyncResponse/ns0:ReceiptAdvice/ns2:ReceiptAdviceLine'
   passing t.xml
   columns
   document_line_number   varchar2(100) path 'ns2:DocumentLineNumber',
   receipt_source_code    varchar2(100) path 'ns2:ReceiptSourceCode',
   source_document_code   varchar2(100) path 'ns2:SourceDocumentType',
   organization_code      varchar2(100) path 'ns2:OrganizationCode',
   rma_number             varchar2(100) path 'ns2:SourceHeaderNumber',
   rma_line_number        varchar2(100) path 'ns2:DocumentLineNumber',
   item_number            varchar2(100) path 'ns2:ItemNumber',
   item_description       varchar2(240) path 'ns2:ItemDescription',
   quantity               number path 'ns2:Quantity',
   uom                    varchar2(100) path 'ns2:UnitOfMeasure',
   rma_line_id            varchar2(100) path 'ns2:RMALineId',
   original_sales_order   varchar2(100) path 'ns2:OriginalSalesOrderNumber',
   customer_name          varchar2(100) path 'ns2:CustomerPartyName',
   receiving_location     varchar2(400) path 'ns2:ReceivingLocation',
   status                 varchar2(400) path 'ns2:ReceiptAdviceLineStatus'
  ) x
  ORDER BY rma_line_number ASC)
  LOOP

  lv_quantity :=0;

  IF i.status='PARTIALLY RECEIVED' THEN
  lv_quantity:=(i.quantity-NVL(get_quantity_received(p_sales_order=>i.rma_number,p_rma_line_id=>i.rma_line_id,p_line_number=>i.rma_line_number,p_item_number=>i.item_number),0));
  ELSE
  lv_quantity:=i.quantity;
  END IF;
  ------------------------------------------------------------------------------------------------------------------------------------------------------
IF (lv_quantity> lv_wms_shipped_qty AND lv_wms_shipped_qty !=0) OR lv_quantity = lv_wms_shipped_qty THEN

IF lv_line_payload IS NOT NULL THEN  lv_line_payload:=lv_line_payload||',' ; END IF;

 lv_line_payload:=lv_line_payload||'{ 
           "ReceiptSourceCode": "CUSTOMER"'
       ||',"SourceDocumentCode": "RMA"'
       ||',"TransactionType": "RECEIVE"'
	   ||',"AutoTransactCode": "DELIVER"'
	   ||',"DestinationTypeCode": "INVENTORY"'
	   ||',"OrganizationCode":"'||i.organization_code||'"'
	   ||',"RMANumber":"'||i.rma_number||'"'
	   ||',"RMALineNumber":'||i.rma_line_number||''
	   ||',"ItemNumber":"'||i.item_number||'"'
	   ||',"Quantity":'||lv_wms_shipped_qty||''
	   ||',"UnitOfMeasure":"'||i.uom||'"'
	   ||',"SoldtoLegalEntity":"'||lv_le||'"'
	   ||',"Subinventory":"'||lv_picked_from_subinv||'"'
	   ||',"Locator":"'||lv_picked_from_locator||'"'
	   ||'}';


INSERT INTO xx_wms_ship_line_dtls_tb
(
id                           ,
customer_name                ,
ship_to_location             ,
---------------------------------------
sales_order                  ,
line_number                  ,
rma_line_id                  ,
---------------------------------------
item_number                  ,
item_description             ,
uom                          ,
wms_shipped_quantity         ,
wms_shipped_date             ,
staging_subinventory         ,
picked_from_subinventory     ,
picked_from_locator          ,
ra_quantity_expected         , 
receiving_location           ,
creation_date                ,
last_update_date             
)
VALUES
(
p_id                         ,
i.customer_name              ,
lv_ship_to_location          ,
---------------------------------------
i.rma_number                 ,
i.rma_line_number            ,
i.rma_line_id                ,
---------------------------------------
i.item_number                ,
i.item_description           ,
i.uom                        ,
p_wms_shipped_qty           ,
lv_wms_shipped_date          ,
NULL                         ,
lv_picked_from_subinv        ,
lv_picked_from_locator       ,
lv_wms_shipped_qty           ,
i.receiving_location         ,
TO_CHAR(SYSDATE,'DD-MON-YYYY HH24:MI:SS'),
TO_CHAR(SYSDATE,'DD-MON-YYYY HH24:MI:SS')
);
COMMIT;	     

lv_wms_shipped_qty:=0;	 
-----------------------------------------------------------------------------------------------------------------	   
ELSIF  lv_quantity < lv_wms_shipped_qty THEN

IF lv_line_payload IS NOT NULL THEN  lv_line_payload:=lv_line_payload||',' ; END IF;

 lv_line_payload:=lv_line_payload||'{ 
           "ReceiptSourceCode": "CUSTOMER"'
       ||',"SourceDocumentCode": "RMA"'
       ||',"TransactionType": "RECEIVE"'
	   ||',"AutoTransactCode": "DELIVER"'
	   ||',"DestinationTypeCode": "INVENTORY"'
	   ||',"OrganizationCode":"'||i.organization_code||'"'
	   ||',"RMANumber":"'||i.rma_number||'"'
	   ||',"RMALineNumber":'||i.rma_line_number||''
	   ||',"ItemNumber":"'||i.item_number||'"'
	   ||',"Quantity":'||lv_quantity||''
	   ||',"UnitOfMeasure":"'||i.uom||'"'
	   ||',"SoldtoLegalEntity":"'||lv_le||'"'
	   ||',"Subinventory":"'||lv_picked_from_subinv||'"'
	   ||',"Locator":"'||lv_picked_from_locator||'"'
	   ||'}';


INSERT INTO xx_wms_ship_line_dtls_tb
(
id                           ,
customer_name                ,
ship_to_location             ,
---------------------------------------
sales_order                  ,
line_number                  ,
rma_line_id                  ,
---------------------------------------
item_number                  ,
item_description             ,
uom                          ,
wms_shipped_quantity         ,
wms_shipped_date             ,
staging_subinventory         ,
picked_from_subinventory     ,
picked_from_locator          ,
ra_quantity_expected         , 
receiving_location           ,
creation_date                ,
last_update_date             
)
VALUES
(
p_id                         ,
i.customer_name              ,
lv_ship_to_location          ,
---------------------------------------
i.rma_number                 ,
i.rma_line_number            ,
i.rma_line_id                ,
---------------------------------------
i.item_number                ,
i.item_description           ,
i.uom                        ,
p_wms_shipped_qty            ,
lv_wms_shipped_date          ,
NULL                         ,
lv_picked_from_subinv        ,
lv_picked_from_locator       ,
lv_quantity                  ,
i.receiving_location         ,
TO_CHAR(SYSDATE,'DD-MON-YYYY HH24:MI:SS'),
TO_CHAR(SYSDATE,'DD-MON-YYYY HH24:MI:SS')
);
COMMIT;	      
lv_wms_shipped_qty:=ABS(lv_wms_shipped_qty-lv_quantity);

END IF;
------------------------------------------------------------------------------------------------------------------------------------------------------
EXIT WHEN lv_wms_shipped_qty<=0;

END LOOP;

EXCEPTION WHEN OTHERS THEN
NULL;
END; 

SELECT lv_header_payload
||',"lines" :['||lv_line_payload
       ||']} ' INTO lv_json
FROM dual;

RETURN lv_json;

--- Free Temporary memory:
dbms_lob.freetemporary (l_clob);

EXCEPTION
	WHEN utl_http.too_many_requests 
	THEN 
	write_log('Error Occured while executing the "get_receipt_req_payload"');
    write_log('Error Code   :'||SQLCODE);
    write_log('Error Message:'||SQLERRM);
	utl_http.end_response(http_resp);
    WHEN utl_http.end_of_body 
    THEN 
	write_log('Error Occured while executing the "get_receipt_req_payload"');
    write_log('Error Code   :'||SQLCODE);
    write_log('Error Message:'||SQLERRM);
	utl_http.end_response(http_resp);
	WHEN OTHERS 
	THEN 
	write_log('Error Occured while executing the "get_receipt_req_payload"');
    write_log('Error Code   :'||SQLCODE);
    write_log('Error Message:'||SQLERRM);
	utl_http.end_response(http_resp);
END get_receipt_req_payload;	  	



-- send receipt confirmation:
function receipt_confirm_req_payload(p_organization_id    IN NUMBER,
                                     p_source_system_id   IN NUMBER,
                                     p_receipt_header_id  IN NUMBER,
									 p_org_code           IN VARCHAR2,
									 p_source_system_name IN VARCHAR2)
return varchar2 
is 

  -- soap requests message
  l_soap_req_msg              varchar2 (32767):=NULL;

begin

   l_soap_req_msg := '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:typ="http://xmlns.oracle.com/apps/financials/commonModules/shared/model/erpIntegrationService/types/">
<soapenv:Header/>
<soapenv:Body>
<typ:submitESSJobRequest>
<typ:jobPackageName>/oracle/apps/ess/scm/receiving/receiptsInterface/flexSupply/outbound</typ:jobPackageName>
<typ:jobDefinitionName>ReceiptConfirmationJob</typ:jobDefinitionName>
<!--Zero or more repetitions:-->
<typ:paramList>'||p_organization_id||'</typ:paramList>   /*Organization ID*/
<typ:paramList></typ:paramList> 
<typ:paramList>'||p_source_system_id||'</typ:paramList>  /*Source System ID*/
<typ:paramList></typ:paramList> 
<typ:paramList>'||p_receipt_header_id||'</typ:paramList> /* Receipt ID*/
<typ:paramList></typ:paramList> 
<typ:paramList>'||p_org_code||'</typ:paramList> 
<typ:paramList></typ:paramList> 
<typ:paramList>'||p_source_system_name||'</typ:paramList>  /*Source System Name*/
<typ:paramList></typ:paramList> 
<typ:paramList></typ:paramList> 
</typ:submitESSJobRequest>
</soapenv:Body>
</soapenv:Envelope>';

return l_soap_req_msg;

EXCEPTION
WHEN OTHERS 
	THEN 
	write_log('Error Occured while executing the "receipt_confirm_req_payload"');
    write_log('Error Code   :'||SQLCODE);
    write_log('Error Message:'||SQLERRM);
end receipt_confirm_req_payload;

/*==================================================================================================================================*/

---Get parse xml clob:
function parse_xml_clob (
    p_xml               in xmltype,
    p_xpath             in varchar2,
    p_ns                in varchar2 default null ) return clob
is
    l_response          clob;
begin

    l_response := p_xml.extract(p_xpath,p_ns).getclobval();

    return l_response;

exception when others then
    if sqlcode = -30625 then -- path not found
        return null;
    end if;
end parse_xml_clob;

/*==================================================================================================================================*/

-- Get Decode Base64 encoding to File BLOB
function get_base64_decoded (p_result in clob)
return blob
is 

  -- Base64 decoding related variables
  l_blob                    blob;
  l_raw                     raw(32767);
  l_amt                     number := 7700;
  l_offset                  number := 1;
  l_temp                    varchar2(32767);

begin

  -- Decode Base64 encoding to File BLOB
  dbms_lob.createtemporary(l_blob, true);
  FOR i in 1 .. ceil(dbms_lob.getlength(p_result) / l_amt)
  LOOP
    dbms_lob.read(p_result, l_amt, l_offset, l_temp);    
    l_raw := utl_encode.base64_decode(utl_raw.cast_to_raw(l_temp));
    dbms_lob.append(l_blob, to_blob(l_raw));
    l_offset := l_offset + l_amt;
  END LOOP;

return l_blob ;

end get_base64_decoded;

/*==================================================================================================================================*/

-- BLOB to XML CLOB Conversion
function convert_blob_to_xml_clob (p_blob in blob)
return CLOB
is 

  -- report invocation related variables
  l_xml                     XMLTYPE;

  -- BLOB to XML CLOB conversion related variables
  l_clob                    CLOB;
  lc_xml_clob               CLOB;
  lc_varchar                VARCHAR2(32767);
  ln_start                  PLS_INTEGER := 1;
  ln_buffer                 PLS_INTEGER := 32767;

begin

  -- BLOB to XML CLOB Conversion
  dbms_lob.createtemporary(l_clob, true);
  FOR i IN 1..ceil(dbms_lob.getlength(p_blob) / ln_buffer) LOOP
    lc_varchar := utl_raw.cast_to_varchar2(dbms_lob.substr(p_blob, ln_buffer, ln_start));

    dbms_lob.writeappend(l_clob, length(lc_varchar), lc_varchar);
    ln_start := ln_start + ln_buffer;
  END LOOP;

    l_xml := xmltype.createxml(l_clob);
    lc_xml_clob := l_xml.getclobval();

return lc_xml_clob ;

end convert_blob_to_xml_clob;	

/*==================================================================================================================================*/
-- Load data from XML clob into table
procedure load_so_data (p_xml_clob in clob)
is 

  lv_record_count       NUMBER:=0;
  lv_original_so_count  NUMBER:=0;

begin

    -- Iterate through XML Table rows and merge data into the DB Table
  FOR r IN (
      SELECT 
	         extractvalue(VALUE(p), '/G_1/LEGAL_ENTITY_ID/text()')           AS LEGAL_ENTITY_ID         , 
	         extractvalue(VALUE(p), '/G_1/LEGAL_ENTITY_NAME/text()')         AS LEGAL_ENTITY_NAME       , 
	         extractvalue(VALUE(p), '/G_1/BUSINESS_UNIT/text()')             AS BUSINESS_UNIT           ,
	  --- Header Details:
             extractvalue(VALUE(p), '/G_1/HEADER_ID/text()')                 AS HEADER_ID               ,
             extractvalue(VALUE(p), '/G_1/ORDER_NUMBER/text()')              AS ORDER_NUMBER            ,
             extractvalue(VALUE(p), '/G_1/ORDERED_DATE/text()')              AS ORDERED_DATE            ,
			 extractvalue(VALUE(p), '/G_1/CREATION_DATE/text()')             AS ORDERED_CREATION_DATE   ,
			 extractvalue(VALUE(p), '/G_1/STATUS_CODE/text()')               AS STATUS_CODE             ,
             extractvalue(VALUE(p), '/G_1/HEADER_CANCELED_FLAG/text()')      AS HEADER_CANCELED_FLAG    ,
             extractvalue(VALUE(p), '/G_1/TRANS_CURR_CODE/text()')           AS TRANS_CURR_CODE         ,
			 extractvalue(VALUE(p), '/G_1/CANCEL_REASON_CODE/text()')        AS CANCEL_REASON_CODE      ,
			 extractvalue(VALUE(p), '/G_1/SUBINVENTORY/text()')              AS SUBINVENTORY            ,
             extractvalue(VALUE(p), '/G_1/CUSTOMER_PO_NO/text()')            AS CUSTOMER_PO_NO          ,
			 extractvalue(VALUE(p), '/G_1/ORDER_TYPE/text()')                AS ORDER_TYPE              ,
			 extractvalue(VALUE(p), '/G_1/SOURCE_SYSTEM_NAME/text()')        AS SOURCE_SYSTEM_NAME      ,
			 ----------------------------------------------------------------------------------------------
     --- Customer Details:			 
             extractvalue(VALUE(p), '/G_1/CUSTOMER_NAME/text()')              AS CUSTOMER_NAME          ,
			 extractvalue(VALUE(p), '/G_1/CUSTOMER_ACCOUNT_NAME/text()')      AS CUSTOMER_ACCOUNT_NAME  ,
             extractvalue(VALUE(p), '/G_1/CUSTOMER_ACCOUNT_NUMBER/text()')    AS CUSTOMER_ACCOUNT_NUMBER,
             extractvalue(VALUE(p), '/G_1/SHIP_TO_CUSTOMER/text()')           AS SHIP_TO_CUSTOMER       ,	 			
			 extractvalue(VALUE(p), '/G_1/SHIP_TO_ADDRESS/text()')            AS SHIP_TO_ADDRESS        ,
			 ----------------------------------------------------------------------------------------------
	 --- Line Details:		 
             extractvalue(VALUE(p), '/G_1/LINE_ID/text()')                    AS LINE_ID                ,
             extractvalue(VALUE(p), '/G_1/LINE_NUMBER/text()')                AS LINE_NUMBER            ,
             extractvalue(VALUE(p), '/G_1/ORDERED_UOM/text()')                AS ORDERED_UOM            ,			 			
			 extractvalue(VALUE(p), '/G_1/ORDERED_QTY/text()')                AS ORDERED_QTY            ,
			 extractvalue(VALUE(p), '/G_1/SHIPPED_QTY/text()')                AS SHIPPED_QTY            ,
			 extractvalue(VALUE(p), '/G_1/PICKED_QTY/text()')                 AS PICKED_QTY             ,
			 extractvalue(VALUE(p), '/G_1/CANCELLED_QTY/text()')              AS CANCELLED_QTY          ,			 
             extractvalue(VALUE(p), '/G_1/UNIT_LIST_PRICE/text()')            AS UNIT_LIST_PRICE        ,
             extractvalue(VALUE(p), '/G_1/UNIT_SELLING_PRICE/text()')         AS UNIT_SELLING_PRICE     ,
             extractvalue(VALUE(p), '/G_1/EXTENDED_AMOUNT/text()')            AS EXTENDED_AMOUNT        ,
			 extractvalue(VALUE(p), '/G_1/CATEGORY_CODE/text()')              AS CATEGORY_CODE          ,
			 extractvalue(VALUE(p), '/G_1/LINE_STATUS/text()')                AS LINE_STATUS            ,		 		
             extractvalue(VALUE(p), '/G_1/ITEM_CODE/text()')                  AS ITEM_CODE              ,
			 extractvalue(VALUE(p), '/G_1/ORACLE_CODE/text()')                AS ORACLE_CODE            ,
			 extractvalue(VALUE(p), '/G_1/BARCODE/text()')                    AS BARCODE                ,
             extractvalue(VALUE(p), '/G_1/ITEM_DESCRIPTION/text()')           AS ITEM_DESCRIPTION       ,
             extractvalue(VALUE(p), '/G_1/ACTUAL_SHIP_DATE/text()')           AS ACTUAL_SHIP_DATE       ,			 			
			 extractvalue(VALUE(p), '/G_1/SCHEDULED_SHIP_DATE/text()')        AS SCHEDULED_SHIP_DATE    ,
             extractvalue(VALUE(p), '/G_1/REQUEST_SHIP_DATE/text()')          AS REQUEST_SHIP_DATE      ,
			 extractvalue(VALUE(p), '/G_1/PROMISE_SHIP_DATE/text()')          AS PROMISE_SHIP_DATE      ,
			 ----------------------------------------------------------------------------------------------
	 --- Inventory Related Details:
	         extractvalue(VALUE(p), '/G_1/INV_ORG_ID/text()')                 AS INV_ORG_ID             , 
	         extractvalue(VALUE(p), '/G_1/INV_ORG_CODE/text()')               AS INV_ORG_CODE           ,
			 extractvalue(VALUE(p), '/G_1/INV_ORG_NAME/text()')               AS INV_ORG_NAME           ,
			 extractvalue(VALUE(p), '/G_1/WAREHOUSE_ID/text()')               AS WAREHOUSE_ID           , 
			 extractvalue(VALUE(p), '/G_1/WAREHOUSE_CODE/text()')             AS WAREHOUSE_CODE         ,
			 extractvalue(VALUE(p), '/G_1/WAREHOUSE_NAME/text()')             AS WAREHOUSE_NAME         ,
     --- Header Attributes:
	         extractvalue(VALUE(p), '/G_1/HEADER_ATTRIBUTE_CHAR1/text()')      AS HEADER_ATTRIBUTE_CHAR1 ,
			 extractvalue(VALUE(p), '/G_1/HEADER_ATTRIBUTE_CHAR2/text()')      AS HEADER_ATTRIBUTE_CHAR2 ,
			 extractvalue(VALUE(p), '/G_1/HEADER_ATTRIBUTE_CHAR3/text()')      AS HEADER_ATTRIBUTE_CHAR3 ,
			 extractvalue(VALUE(p), '/G_1/HEADER_ATTRIBUTE_CHAR4/text()')      AS HEADER_ATTRIBUTE_CHAR4 ,
			 extractvalue(VALUE(p), '/G_1/HEADER_ATTRIBUTE_CHAR5/text()')      AS HEADER_ATTRIBUTE_CHAR5 ,
			 extractvalue(VALUE(p), '/G_1/HEADER_ATTRIBUTE_CHAR6/text()')      AS HEADER_ATTRIBUTE_CHAR6 ,
			 extractvalue(VALUE(p), '/G_1/HEADER_ATTRIBUTE_CHAR7/text()')      AS HEADER_ATTRIBUTE_CHAR7 ,
			 extractvalue(VALUE(p), '/G_1/HEADER_ATTRIBUTE_CHAR8/text()')      AS HEADER_ATTRIBUTE_CHAR8 ,
			 extractvalue(VALUE(p), '/G_1/HEADER_ATTRIBUTE_CHAR9/text()')      AS HEADER_ATTRIBUTE_CHAR9 ,
			 extractvalue(VALUE(p), '/G_1/HEADER_ATTRIBUTE_CHAR10/text()')     AS HEADER_ATTRIBUTE_CHAR10 ,
			 extractvalue(VALUE(p), '/G_1/HEADER_ATTRIBUTE_CHAR11/text()')     AS HEADER_ATTRIBUTE_CHAR11 ,
			 extractvalue(VALUE(p), '/G_1/HEADER_ATTRIBUTE_CHAR12/text()')     AS HEADER_ATTRIBUTE_CHAR12 ,
			 extractvalue(VALUE(p), '/G_1/HEADER_ATTRIBUTE_CHAR13/text()')     AS HEADER_ATTRIBUTE_CHAR13 ,
			 extractvalue(VALUE(p), '/G_1/HEADER_ATTRIBUTE_CHAR14/text()')     AS HEADER_ATTRIBUTE_CHAR14 ,
			 extractvalue(VALUE(p), '/G_1/HEADER_ATTRIBUTE_CHAR15/text()')     AS HEADER_ATTRIBUTE_CHAR15 ,
			 extractvalue(VALUE(p), '/G_1/HEADER_ATTRIBUTE_CHAR16/text()')     AS HEADER_ATTRIBUTE_CHAR16 ,
			 extractvalue(VALUE(p), '/G_1/HEADER_ATTRIBUTE_CHAR17/text()')     AS HEADER_ATTRIBUTE_CHAR17 ,
			 extractvalue(VALUE(p), '/G_1/HEADER_ATTRIBUTE_CHAR18/text()')     AS HEADER_ATTRIBUTE_CHAR18 ,
			 extractvalue(VALUE(p), '/G_1/HEADER_ATTRIBUTE_CHAR19/text()')     AS HEADER_ATTRIBUTE_CHAR19 ,
			 extractvalue(VALUE(p), '/G_1/HEADER_ATTRIBUTE_CHAR20/text()')     AS HEADER_ATTRIBUTE_CHAR20 ,
			 ----------------------------------------------------------------------------------------------
			 extractvalue(VALUE(p), '/G_1/HEADER_ATTRIBUTE_NUMBER1/text()')      AS HEADER_ATTRIBUTE_NUMBER1 ,
			 extractvalue(VALUE(p), '/G_1/HEADER_ATTRIBUTE_NUMBER2/text()')      AS HEADER_ATTRIBUTE_NUMBER2 ,
			 extractvalue(VALUE(p), '/G_1/HEADER_ATTRIBUTE_NUMBER3/text()')      AS HEADER_ATTRIBUTE_NUMBER3 ,
			 extractvalue(VALUE(p), '/G_1/HEADER_ATTRIBUTE_NUMBER4/text()')      AS HEADER_ATTRIBUTE_NUMBER4 ,
			 extractvalue(VALUE(p), '/G_1/HEADER_ATTRIBUTE_NUMBER5/text()')      AS HEADER_ATTRIBUTE_NUMBER5 ,
			 extractvalue(VALUE(p), '/G_1/HEADER_ATTRIBUTE_NUMBER6/text()')      AS HEADER_ATTRIBUTE_NUMBER6 ,
			 extractvalue(VALUE(p), '/G_1/HEADER_ATTRIBUTE_NUMBER7/text()')      AS HEADER_ATTRIBUTE_NUMBER7 ,
			 extractvalue(VALUE(p), '/G_1/HEADER_ATTRIBUTE_NUMBER8/text()')      AS HEADER_ATTRIBUTE_NUMBER8 ,
			 extractvalue(VALUE(p), '/G_1/HEADER_ATTRIBUTE_NUMBER9/text()')      AS HEADER_ATTRIBUTE_NUMBER9 ,
			 extractvalue(VALUE(p), '/G_1/HEADER_ATTRIBUTE_NUMBER10/text()')     AS HEADER_ATTRIBUTE_NUMBER10 ,
			 ------------------------------------------------------------------------------------------------
			 extractvalue(VALUE(p), '/G_1/HEADER_ATTRIBUTE_DATE1/text()')      AS HEADER_ATTRIBUTE_DATE1 ,
			 extractvalue(VALUE(p), '/G_1/HEADER_ATTRIBUTE_DATE2/text()')      AS HEADER_ATTRIBUTE_DATE2 ,
			 extractvalue(VALUE(p), '/G_1/HEADER_ATTRIBUTE_DATE3/text()')      AS HEADER_ATTRIBUTE_DATE3 ,
			 extractvalue(VALUE(p), '/G_1/HEADER_ATTRIBUTE_DATE4/text()')      AS HEADER_ATTRIBUTE_DATE4 ,
			 extractvalue(VALUE(p), '/G_1/HEADER_ATTRIBUTE_DATE5/text()')      AS HEADER_ATTRIBUTE_DATE5 ,
             ------------------------------------------------------------------------------------------------
			 extractvalue(VALUE(p), '/G_1/HEADER_ATTRIBUTE_TIMESTAMP1/text()')      AS HEADER_ATTRIBUTE_TIMESTAMP1 ,
			 extractvalue(VALUE(p), '/G_1/HEADER_ATTRIBUTE_TIMESTAMP2/text()')      AS HEADER_ATTRIBUTE_TIMESTAMP2 ,
			 extractvalue(VALUE(p), '/G_1/HEADER_ATTRIBUTE_TIMESTAMP3/text()')      AS HEADER_ATTRIBUTE_TIMESTAMP3 ,
			 extractvalue(VALUE(p), '/G_1/HEADER_ATTRIBUTE_TIMESTAMP4/text()')      AS HEADER_ATTRIBUTE_TIMESTAMP4 ,
			 extractvalue(VALUE(p), '/G_1/HEADER_ATTRIBUTE_TIMESTAMP5/text()')      AS HEADER_ATTRIBUTE_TIMESTAMP5 ,
			 -------------------------------------------------------------------------------------------------
	 --- Line attributes:

             extractvalue(VALUE(p), '/G_1/LINE_ATTRIBUTE_CHAR1/text()')      AS LINE_ATTRIBUTE_CHAR1 ,
			 extractvalue(VALUE(p), '/G_1/LINE_ATTRIBUTE_CHAR2/text()')      AS LINE_ATTRIBUTE_CHAR2 ,
			 extractvalue(VALUE(p), '/G_1/LINE_ATTRIBUTE_CHAR3/text()')      AS LINE_ATTRIBUTE_CHAR3 ,
			 extractvalue(VALUE(p), '/G_1/LINE_ATTRIBUTE_CHAR4/text()')      AS LINE_ATTRIBUTE_CHAR4 ,
			 extractvalue(VALUE(p), '/G_1/LINE_ATTRIBUTE_CHAR5/text()')      AS LINE_ATTRIBUTE_CHAR5 ,
			 extractvalue(VALUE(p), '/G_1/LINE_ATTRIBUTE_CHAR6/text()')      AS LINE_ATTRIBUTE_CHAR6 ,
			 extractvalue(VALUE(p), '/G_1/LINE_ATTRIBUTE_CHAR7/text()')      AS LINE_ATTRIBUTE_CHAR7 ,
			 extractvalue(VALUE(p), '/G_1/LINE_ATTRIBUTE_CHAR8/text()')      AS LINE_ATTRIBUTE_CHAR8 ,
			 extractvalue(VALUE(p), '/G_1/LINE_ATTRIBUTE_CHAR9/text()')      AS LINE_ATTRIBUTE_CHAR9 ,
			 extractvalue(VALUE(p), '/G_1/LINE_ATTRIBUTE_CHAR10/text()')     AS LINE_ATTRIBUTE_CHAR10 ,
			 extractvalue(VALUE(p), '/G_1/LINE_ATTRIBUTE_CHAR11/text()')     AS LINE_ATTRIBUTE_CHAR11 ,
			 extractvalue(VALUE(p), '/G_1/LINE_ATTRIBUTE_CHAR12/text()')     AS LINE_ATTRIBUTE_CHAR12 ,
			 extractvalue(VALUE(p), '/G_1/LINE_ATTRIBUTE_CHAR13/text()')     AS LINE_ATTRIBUTE_CHAR13 ,
			 extractvalue(VALUE(p), '/G_1/LINE_ATTRIBUTE_CHAR14/text()')     AS LINE_ATTRIBUTE_CHAR14 ,
			 extractvalue(VALUE(p), '/G_1/LINE_ATTRIBUTE_CHAR15/text()')     AS LINE_ATTRIBUTE_CHAR15 ,
			 extractvalue(VALUE(p), '/G_1/LINE_ATTRIBUTE_CHAR16/text()')     AS LINE_ATTRIBUTE_CHAR16 ,
			 extractvalue(VALUE(p), '/G_1/LINE_ATTRIBUTE_CHAR17/text()')     AS LINE_ATTRIBUTE_CHAR17 ,
			 extractvalue(VALUE(p), '/G_1/LINE_ATTRIBUTE_CHAR18/text()')     AS LINE_ATTRIBUTE_CHAR18 ,
			 extractvalue(VALUE(p), '/G_1/LINE_ATTRIBUTE_CHAR19/text()')     AS LINE_ATTRIBUTE_CHAR19 ,
			 extractvalue(VALUE(p), '/G_1/LINE_ATTRIBUTE_CHAR20/text()')     AS LINE_ATTRIBUTE_CHAR20 ,
			 ----------------------------------------------------------------------------------------------
			 extractvalue(VALUE(p), '/G_1/LINE_ATTRIBUTE_NUMBER1/text()')      AS LINE_ATTRIBUTE_NUMBER1 ,
			 extractvalue(VALUE(p), '/G_1/LINE_ATTRIBUTE_NUMBER2/text()')      AS LINE_ATTRIBUTE_NUMBER2 ,
			 extractvalue(VALUE(p), '/G_1/LINE_ATTRIBUTE_NUMBER3/text()')      AS LINE_ATTRIBUTE_NUMBER3 ,
			 extractvalue(VALUE(p), '/G_1/LINE_ATTRIBUTE_NUMBER4/text()')      AS LINE_ATTRIBUTE_NUMBER4 ,
			 extractvalue(VALUE(p), '/G_1/LINE_ATTRIBUTE_NUMBER5/text()')      AS LINE_ATTRIBUTE_NUMBER5 ,
			 extractvalue(VALUE(p), '/G_1/LINE_ATTRIBUTE_NUMBER6/text()')      AS LINE_ATTRIBUTE_NUMBER6 ,
			 extractvalue(VALUE(p), '/G_1/LINE_ATTRIBUTE_NUMBER7/text()')      AS LINE_ATTRIBUTE_NUMBER7 ,
			 extractvalue(VALUE(p), '/G_1/LINE_ATTRIBUTE_NUMBER8/text()')      AS LINE_ATTRIBUTE_NUMBER8 ,
			 extractvalue(VALUE(p), '/G_1/LINE_ATTRIBUTE_NUMBER9/text()')      AS LINE_ATTRIBUTE_NUMBER9 ,
			 extractvalue(VALUE(p), '/G_1/LINE_ATTRIBUTE_NUMBER10/text()')     AS LINE_ATTRIBUTE_NUMBER10 ,
			 ------------------------------------------------------------------------------------------------
			 extractvalue(VALUE(p), '/G_1/LINE_ATTRIBUTE_DATE1/text()')      AS LINE_ATTRIBUTE_DATE1 ,
			 extractvalue(VALUE(p), '/G_1/LINE_ATTRIBUTE_DATE2/text()')      AS LINE_ATTRIBUTE_DATE2 ,
			 extractvalue(VALUE(p), '/G_1/LINE_ATTRIBUTE_DATE3/text()')      AS LINE_ATTRIBUTE_DATE3 ,
			 extractvalue(VALUE(p), '/G_1/LINE_ATTRIBUTE_DATE4/text()')      AS LINE_ATTRIBUTE_DATE4 ,
			 extractvalue(VALUE(p), '/G_1/LINE_ATTRIBUTE_DATE5/text()')      AS LINE_ATTRIBUTE_DATE5 ,
             ------------------------------------------------------------------------------------------------
			 extractvalue(VALUE(p), '/G_1/LINE_ATTRIBUTE_TIMESTAMP1/text()')      AS LINE_ATTRIBUTE_TIMESTAMP1 ,
			 extractvalue(VALUE(p), '/G_1/LINE_ATTRIBUTE_TIMESTAMP2/text()')      AS LINE_ATTRIBUTE_TIMESTAMP2 ,
			 extractvalue(VALUE(p), '/G_1/LINE_ATTRIBUTE_TIMESTAMP3/text()')      AS LINE_ATTRIBUTE_TIMESTAMP3 ,
			 extractvalue(VALUE(p), '/G_1/LINE_ATTRIBUTE_TIMESTAMP4/text()')      AS LINE_ATTRIBUTE_TIMESTAMP4 ,
			 extractvalue(VALUE(p), '/G_1/LINE_ATTRIBUTE_TIMESTAMP5/text()')      AS LINE_ATTRIBUTE_TIMESTAMP5 ,
			 -------------------------------------------------------------------------------------------------
			 extractvalue(VALUE(p), '/G_1/RETURN_REASON/text()')         AS RETURN_REASON         , 
			 extractvalue(VALUE(p), '/G_1/RETURN_TYPE/text()')           AS RETURN_TYPE           ,
			 extractvalue(VALUE(p), '/G_1/ORIGINAL_SALES_ORDER/text()')  AS ORIGINAL_SALES_ORDER      


        FROM TABLE ( xmlsequence(EXTRACT(xmltype(p_xml_clob), '/DATA_DS/G_1')) ) p
  )
  LOOP

  lv_record_count:=0;
  lv_original_so_count:=0;

  -- record count:
  BEGIN  
  SELECT COUNT(*) INTO lv_record_count
  FROM xx_fusion_so_dtls_tb
  WHERE 1=1
  AND order_number= r.order_number
  AND header_id=r.header_id 
  AND line_id=r.line_id;  
  EXCEPTION WHEN OTHERS THEN
  lv_record_count:=0;
  END;

  -- original sales order count:
  BEGIN  
  SELECT COUNT(*) INTO lv_original_so_count
  FROM xx_fusion_so_dtls_tb
  WHERE 1=1
  AND order_number= r.original_sales_order;
  EXCEPTION WHEN OTHERS THEN
  lv_original_so_count:=0;
  END;  

  IF (lv_record_count=0 AND r.category_code='ORDER' AND r.line_status='Awaiting Shipping') 
  OR (lv_record_count=0 AND lv_original_so_count>0 AND r.category_code='RETURN' AND r.line_status='Awaiting Receiving') THEN

  INSERT INTO xx_fusion_so_dtls_tb(
legal_entity_id         ,		  
legal_entity_name       ,		  
business_unit           ,
---header;
header_id               ,
order_number            ,
ordered_date            ,
ordered_creation_date   ,
status_code             ,
header_canceled_flag    ,
trans_curr_code         ,
cancel_reason_code      ,
subinventory            ,
customer_po_no          ,
order_type              ,
source_system_name      ,
---line:
line_id                 ,
line_number             ,
ordered_uom             ,
ordered_qty             ,
shipped_qty             ,
picked_qty              ,
cancelled_qty           ,
unit_list_price         ,
unit_selling_price      ,
extended_amount         ,
category_code           ,
line_status             ,
item_code               ,
oracle_code             ,
barcode                 ,
item_description        ,
actual_ship_date        ,
scheduled_ship_date     ,
request_ship_date       ,
promise_ship_date       ,

---customer details:
customer_name           ,
customer_account_name   ,
customer_account_number ,
ship_to_customer        ,
ship_to_address         ,
---inventory related details:
inv_org_id              ,
inv_org_code            ,
inv_org_name            ,
warehouse_id            ,
warehouse_code          ,
warehouse_name          , 

---header attributes:
header_attribute_char1  ,
header_attribute_char2 ,
header_attribute_char3 ,
header_attribute_char4 ,
header_attribute_char5 ,
header_attribute_char6 ,
header_attribute_char7 ,
header_attribute_char8 ,
header_attribute_char9 ,
header_attribute_char10 ,
header_attribute_char11 ,
header_attribute_char12 ,
header_attribute_char13 ,
header_attribute_char14 ,
header_attribute_char15 ,
header_attribute_char16 ,
header_attribute_char17 ,
header_attribute_char18 ,
header_attribute_char19 ,
header_attribute_char20 ,
header_attribute_number1   ,
header_attribute_number2  ,
header_attribute_number3  ,
header_attribute_number4  ,
header_attribute_number5  ,
header_attribute_number6  ,
header_attribute_number7  ,
header_attribute_number8  ,
header_attribute_number9  ,
header_attribute_number10  ,
header_attribute_date1  ,
header_attribute_date2  ,
header_attribute_date3  ,
header_attribute_date4  ,
header_attribute_date5  ,
header_attribute_timestamp1  ,
header_attribute_timestamp2  ,
header_attribute_timestamp3  ,
header_attribute_timestamp4  ,
header_attribute_timestamp5 ,

---line attributes:
line_attribute_char1  ,
line_attribute_char2 ,
line_attribute_char3 ,
line_attribute_char4 ,
line_attribute_char5 ,
line_attribute_char6 ,
line_attribute_char7 ,
line_attribute_char8 ,
line_attribute_char9 ,
line_attribute_char10 ,
line_attribute_char11 ,
line_attribute_char12 ,
line_attribute_char13 ,
line_attribute_char14 ,
line_attribute_char15 ,
line_attribute_char16 ,
line_attribute_char17 ,
line_attribute_char18 ,
line_attribute_char19 ,
line_attribute_char20 ,
line_attribute_number1   ,
line_attribute_number2  ,
line_attribute_number3  ,
line_attribute_number4  ,
line_attribute_number5  ,
line_attribute_number6  ,
line_attribute_number7  ,
line_attribute_number8  ,
line_attribute_number9  ,
line_attribute_number10  ,
line_attribute_date1  ,
line_attribute_date2  ,
line_attribute_date3  ,
line_attribute_date4  ,
line_attribute_date5  ,
line_attribute_timestamp1  ,
line_attribute_timestamp2  ,
line_attribute_timestamp3  ,
line_attribute_timestamp4  ,
line_attribute_timestamp5  ,

return_reason              ,
return_type                ,
original_sales_order       ,

---who:
creation_date              ,
last_update_date           ,
import_method              ,
status                     , 
error_message              
)
VALUES
(
r.legal_entity_id         ,
r.legal_entity_name       ,
r.business_unit           ,
---header;
r.header_id               ,
r.order_number            ,
r.ordered_date            ,
r.ordered_creation_date   ,
r.status_code             ,
r.header_canceled_flag    ,
r.trans_curr_code         ,
r.cancel_reason_code      ,
r.subinventory            ,
r.customer_po_no          ,
r.order_type              ,
r.source_system_name      ,
---line:
r.line_id                 ,
r.line_number             ,
r.ordered_uom             ,
r.ordered_qty             ,
r.shipped_qty             ,
r.picked_qty              ,
r.cancelled_qty           ,
r.unit_list_price         ,
r.unit_selling_price      ,
r.extended_amount         ,
r.category_code           ,
r.line_status             ,
r.item_code               ,
r.oracle_code             ,
r.barcode                 ,
r.item_description        ,
r.actual_ship_date        ,
r.scheduled_ship_date     ,
r.request_ship_date       ,
r.promise_ship_date       ,
---customer details:
r.customer_name           ,
r.customer_account_name   ,
r.customer_account_number ,
r.ship_to_customer        ,
r.ship_to_address         ,
---inventory related details:
r.inv_org_id              ,
r.inv_org_code            ,
r.inv_org_name            ,
r.warehouse_id            ,
r.warehouse_code          ,
r.warehouse_name          ,

---header attributes:
r.header_attribute_char1  ,
r.header_attribute_char2 ,
r.header_attribute_char3 ,
r.header_attribute_char4 ,
r.header_attribute_char5 ,
r.header_attribute_char6 ,
r.header_attribute_char7 ,
r.header_attribute_char8 ,
r.header_attribute_char9 ,
r.header_attribute_char10 ,
r.header_attribute_char11 ,
r.header_attribute_char12 ,
r.header_attribute_char13 ,
r.header_attribute_char14 ,
r.header_attribute_char15 ,
r.header_attribute_char16 ,
r.header_attribute_char17 ,
r.header_attribute_char18 ,
r.header_attribute_char19 ,
r.header_attribute_char20 ,
r.header_attribute_number1   ,
r.header_attribute_number2  ,
r.header_attribute_number3  ,
r.header_attribute_number4  ,
r.header_attribute_number5  ,
r.header_attribute_number6  ,
r.header_attribute_number7  ,
r.header_attribute_number8  ,
r.header_attribute_number9  ,
r.header_attribute_number10  ,
r.header_attribute_date1  ,
r.header_attribute_date2  ,
r.header_attribute_date3  ,
r.header_attribute_date4  ,
r.header_attribute_date5  ,
r.header_attribute_timestamp1  ,
r.header_attribute_timestamp2  ,
r.header_attribute_timestamp3  ,
r.header_attribute_timestamp4  ,
r.header_attribute_timestamp5 ,


---line attributes:
r.line_attribute_char1  ,
r.line_attribute_char2 ,
r.line_attribute_char3 ,
r.line_attribute_char4 ,
r.line_attribute_char5 ,
r.line_attribute_char6 ,
r.line_attribute_char7 ,
r.line_attribute_char8 ,
r.line_attribute_char9 ,
r.line_attribute_char10 ,
r.line_attribute_char11 ,
r.line_attribute_char12 ,
r.line_attribute_char13 ,
r.line_attribute_char14 ,
r.line_attribute_char15 ,
r.line_attribute_char16 ,
r.line_attribute_char17 ,
r.line_attribute_char18 ,
r.line_attribute_char19 ,
r.line_attribute_char20 ,
r.line_attribute_number1   ,
r.line_attribute_number2  ,
r.line_attribute_number3  ,
r.line_attribute_number4  ,
r.line_attribute_number5  ,
r.line_attribute_number6  ,
r.line_attribute_number7  ,
r.line_attribute_number8  ,
r.line_attribute_number9  ,
r.line_attribute_number10  ,
r.line_attribute_date1  ,
r.line_attribute_date2  ,
r.line_attribute_date3  ,
r.line_attribute_date4  ,
r.line_attribute_date5  ,
r.line_attribute_timestamp1  ,
r.line_attribute_timestamp2  ,
r.line_attribute_timestamp3  ,
r.line_attribute_timestamp4  ,
r.line_attribute_timestamp5 ,

r.return_reason              ,
r.return_type                ,
r.original_sales_order       ,

---WHO:
SYSDATE,
SYSDATE,
'INTG_WEBSERVICE',
'NEW',
NULL
);
  COMMIT;


  ELSE
  --------------------------------------------
  IF r.category_code='ORDER' THEN
  UPDATE xx_fusion_so_dtls_tb
  SET line_status = r.line_status
  WHERE 1=1
  AND order_number= r.order_number
  AND header_id=r.header_id 
  AND line_id=r.line_id
  AND ordered_qty=shipped_qty
  AND ordered_qty=picked_qty
  AND line_status='Awaiting Shipping';
  COMMIT;
  --------------------------------------------
  ELSE
  --------------------------------------------
    UPDATE xx_fusion_so_dtls_tb
  SET line_status = r.line_status
  WHERE 1=1
  AND order_number= r.order_number
  AND header_id=r.header_id 
  AND line_id=r.line_id
  AND line_status='Awaiting Receiving';
  COMMIT;
  END IF;
  --------------------------------------------
  END IF;

END LOOP;
EXCEPTION WHEN OTHERS THEN
write_log('Error Occured while executing the "load_so_data"');
write_log('Error Code   :'||SQLCODE);
write_log('Error Message:'||SQLERRM);
end load_so_data;

/*==================================================================================================================================*/
-- Load data from XML clob into table
procedure load_vc_data (p_xml_clob in clob)
is 

lv_record_count NUMBER:=0;

begin

    -- Iterate through XML Table rows and merge data into the DB Table
  FOR r IN (
      SELECT 

	         extractvalue(VALUE(p), '/G_1/PARTY_ID/text()')                  AS PARTY_ID         , 
	         extractvalue(VALUE(p), '/G_1/PARTY_TYPE/text()')                AS PARTY_TYPE       , 
			 extractvalue(VALUE(p), '/G_1/PARTY_CODE/text()')                AS PARTY_CODE       , 
	         extractvalue(VALUE(p), '/G_1/PARTY_NAME/text()')                AS PARTY_NAME       ,
			 extractvalue(VALUE(p), '/G_1/PARTY_SITE_CODE/text()')           AS PARTY_SITE_CODE  ,
			 extractvalue(VALUE(p), '/G_1/PARTY_SITE_NAME/text()')           AS PARTY_SITE_NAME  ,
			 extractvalue(VALUE(p), '/G_1/SHIP_TO_LOCATION/text()')          AS SHIP_TO_LOCATION ,
			 extractvalue(VALUE(p), '/G_1/PARTY_SITE_ADDRESS/text()')        AS PARTY_SITE_ADDRESS ,
			 extractvalue(VALUE(p), '/G_1/PHONE_NUMBER/text()')              AS PHONE_NUMBER     ,
			 extractvalue(VALUE(p), '/G_1/EMAIL_ADDRESS/text()')             AS EMAIL_ADDRESS    ,
			 extractvalue(VALUE(p), '/G_1/CREDIT_PERIOD_DAYS/text()')        AS CREDIT_PERIOD_DAYS         ,
			 extractvalue(VALUE(p), '/G_1/CREDIT_LIMIT_AMOUNT/text()')       AS CREDIT_LIMIT_AMOUNT ,  
			 ---------------------------------------------------------------------------------------
			 extractvalue(VALUE(p), '/G_1/ATTRIBUTE1/text()')       AS ATTRIBUTE1  ,  
			 extractvalue(VALUE(p), '/G_1/ATTRIBUTE2/text()')       AS ATTRIBUTE2  ,  
			 extractvalue(VALUE(p), '/G_1/ATTRIBUTE3/text()')       AS ATTRIBUTE3  ,  
			 extractvalue(VALUE(p), '/G_1/ATTRIBUTE4/text()')       AS ATTRIBUTE4  ,  
			 extractvalue(VALUE(p), '/G_1/ATTRIBUTE5/text()')       AS ATTRIBUTE5  ,  
			 extractvalue(VALUE(p), '/G_1/ATTRIBUTE6/text()')       AS ATTRIBUTE6  ,  
			 extractvalue(VALUE(p), '/G_1/ATTRIBUTE7/text()')       AS ATTRIBUTE7  ,  
			 extractvalue(VALUE(p), '/G_1/ATTRIBUTE8/text()')       AS ATTRIBUTE8  ,  
			 extractvalue(VALUE(p), '/G_1/ATTRIBUTE9/text()')       AS ATTRIBUTE9  ,  
			 extractvalue(VALUE(p), '/G_1/ATTRIBUTE10/text()')      AS ATTRIBUTE10 ,  
			 extractvalue(VALUE(p), '/G_1/ATTRIBUTE11/text()')      AS ATTRIBUTE11 ,  
			 extractvalue(VALUE(p), '/G_1/ATTRIBUTE12/text()')      AS ATTRIBUTE12 ,  
			 extractvalue(VALUE(p), '/G_1/ATTRIBUTE13/text()')      AS ATTRIBUTE13 ,  
			 extractvalue(VALUE(p), '/G_1/ATTRIBUTE14/text()')      AS ATTRIBUTE14 ,  
			 extractvalue(VALUE(p), '/G_1/ATTRIBUTE15/text()')      AS ATTRIBUTE15 

        FROM TABLE ( xmlsequence(EXTRACT(xmltype(p_xml_clob), '/DATA_DS/G_1')) ) p
  )
  LOOP


  -- original sales order count:
  BEGIN  
  SELECT COUNT(*) INTO lv_record_count
  FROM xx_fusion_cust_vend_dtls_tb
  WHERE 1=1
  AND party_id= r.party_id
  AND party_code=r.party_code
  AND party_name=r.party_name
  AND (party_site_code =r.party_site_code OR party_site_name=r.party_site_name);
  EXCEPTION WHEN OTHERS THEN
  lv_record_count:=0;
  END;  

  IF (lv_record_count=0 ) THEN

  INSERT INTO xx_fusion_cust_vend_dtls_tb( 
party_id	            ,
party_type	            ,
party_code	            ,
party_name	            ,
party_site_code      	,
party_site_name	        ,
ship_to_location	    ,
party_site_address	    ,
phone_number	        ,
email_address	        ,
credit_period_days	    ,
credit_limit_amount	    ,
creation_date	        ,
last_update_date	    ,
import_method	        ,
status	      

)
VALUES
(
r.party_id	                ,
r.party_type	            ,
r.party_code	            ,
r.party_name	            ,
r.party_site_code      	    ,
r.party_site_name	        ,
r.ship_to_location	        ,
r.party_site_address	    ,
r.phone_number	            ,
r.email_address	            ,
r.credit_period_days	    ,
r.credit_limit_amount	    ,
---WHO:
SYSDATE                     ,
SYSDATE                     ,
'INTG_WEBSERVICE'           ,
'NEW'
);
  COMMIT;
END IF;  
END LOOP;

EXCEPTION WHEN OTHERS THEN
write_log('Error Occured while executing the "load_vc_data"');
write_log('Error Code   :'||SQLCODE);
write_log('Error Message:'||SQLERRM);
end load_vc_data;

/*==================================================================================================================================*/
-- Load data from XML clob into table
procedure load_item_data (p_xml_clob in clob)
is 

lv_record_count NUMBER:=0;

begin

    -- Iterate through XML Table rows and merge data into the DB Table
  FOR r IN (
      SELECT 
	         extractvalue(VALUE(p), '/G_1/ITEM_ID/text()')                   AS ITEM_ID                 , 
	         extractvalue(VALUE(p), '/G_1/WAREHOUSE_NUMBER/text()')          AS WAREHOUSE_NUMBER        , 
	         extractvalue(VALUE(p), '/G_1/BARCODE/text()')                   AS BARCODE                 , 
			 extractvalue(VALUE(p), '/G_1/DESCRIPTION/text()')               AS DESCRIPTION             , 
	         extractvalue(VALUE(p), '/G_1/COUNTRY_OF_ORIGIN/text()')         AS COUNTRY_OF_ORIGIN       ,
			 extractvalue(VALUE(p), '/G_1/ITEM_CODE/text()')                 AS ITEM_CODE               ,
			 extractvalue(VALUE(p), '/G_1/COLOR_CODE/text()')                AS COLOR_CODE              ,
			 extractvalue(VALUE(p), '/G_1/TYPE/text()')                      AS TYPE                    ,
			 extractvalue(VALUE(p), '/G_1/BUSINESS_GROUP_CODE/text()')       AS BUSINESS_GROUP_CODE     ,
			 extractvalue(VALUE(p), '/G_1/DIVISION_GROUP_CODE/text()')       AS DIVISION_GROUP_CODE     ,
			 extractvalue(VALUE(p), '/G_1/RETAIL_GROUP_CODE/text()')         AS RETAIL_GROUP_CODE       ,
			 extractvalue(VALUE(p), '/G_1/LOCAL_DESCRIPTION/text()')         AS LOCAL_DESCRIPTION       ,
			 extractvalue(VALUE(p), '/G_1/UNIQUE_DESCRIPTION/text()')        AS UNIQUE_DESCRIPTION      ,
			 extractvalue(VALUE(p), '/G_1/UOM/text()')                       AS UOM                     ,  
			 extractvalue(VALUE(p), '/G_1/LENGTH/text()')                    AS LENGTH                  , 
			 extractvalue(VALUE(p), '/G_1/WIDTH/text()')                     AS WIDTH                   , 
			 extractvalue(VALUE(p), '/G_1/HEIGHT/text()')                    AS HEIGHT                  , 
			 extractvalue(VALUE(p), '/G_1/WEIGHT/text()')                    AS WEIGHT                  , 
			 extractvalue(VALUE(p), '/G_1/GROSS_WEIGHT/text()')              AS GROSS_WEIGHT            , 
			 extractvalue(VALUE(p), '/G_1/NET_WEIGHT/text()')                AS NET_WEIGHT              , 
			 extractvalue(VALUE(p), '/G_1/UOM_WEIGHT/text()')                AS UOM_WEIGHT	            , 
			 extractvalue(VALUE(p), '/G_1/VOLUME/text()')                    AS VOLUME	                , 
			 extractvalue(VALUE(p), '/G_1/BRAND/text()')                     AS BRAND	                , 
			 extractvalue(VALUE(p), '/G_1/ORACLE_CODE/text()')               AS ORACLE_CODE	            , 			 
			 ---------------------------------------------------------------------------------------
			 extractvalue(VALUE(p), '/G_1/ATTRIBUTE1/text()')       AS ATTRIBUTE1  ,  
			 extractvalue(VALUE(p), '/G_1/ATTRIBUTE2/text()')       AS ATTRIBUTE2  ,  
			 extractvalue(VALUE(p), '/G_1/ATTRIBUTE3/text()')       AS ATTRIBUTE3  ,  
			 extractvalue(VALUE(p), '/G_1/ATTRIBUTE4/text()')       AS ATTRIBUTE4  ,  
			 extractvalue(VALUE(p), '/G_1/ATTRIBUTE5/text()')       AS ATTRIBUTE5  ,  
			 extractvalue(VALUE(p), '/G_1/ATTRIBUTE6/text()')       AS ATTRIBUTE6  ,  
			 extractvalue(VALUE(p), '/G_1/ATTRIBUTE7/text()')       AS ATTRIBUTE7  ,  
			 extractvalue(VALUE(p), '/G_1/ATTRIBUTE8/text()')       AS ATTRIBUTE8  ,  
			 extractvalue(VALUE(p), '/G_1/ATTRIBUTE9/text()')       AS ATTRIBUTE9  ,  
			 extractvalue(VALUE(p), '/G_1/ATTRIBUTE10/text()')      AS ATTRIBUTE10 ,  
			 extractvalue(VALUE(p), '/G_1/ATTRIBUTE11/text()')      AS ATTRIBUTE11 ,  
			 extractvalue(VALUE(p), '/G_1/ATTRIBUTE12/text()')      AS ATTRIBUTE12 ,  
			 extractvalue(VALUE(p), '/G_1/ATTRIBUTE13/text()')      AS ATTRIBUTE13 ,  
			 extractvalue(VALUE(p), '/G_1/ATTRIBUTE14/text()')      AS ATTRIBUTE14 ,  
			 extractvalue(VALUE(p), '/G_1/ATTRIBUTE15/text()')      AS ATTRIBUTE15 

        FROM TABLE ( xmlsequence(EXTRACT(xmltype(p_xml_clob), '/DATA_DS/G_1')) ) p
  )
  LOOP


  -- original sales order count:
  BEGIN  
  SELECT COUNT(*) INTO lv_record_count
  FROM xx_item_master_dtls_tb
  WHERE 1=1
  AND item_id=r.item_id;
  EXCEPTION WHEN OTHERS THEN
  lv_record_count:=0;
  END;  

  IF (lv_record_count=0 ) THEN

  INSERT INTO xx_item_master_dtls_tb(
item_id	                ,
warehouse	            ,
barcode	                ,
description	            ,
country_of_origin	    ,
item_code	            ,
color_code	            ,
type	                ,
business_group_code	    ,
division_group_code	    ,
retail_group_code	    ,
local_description	    ,
unique_description	    ,
uom	                    ,
width	                ,
gross_weight	        ,
net_weight	            ,
uom_weight	            ,
volume	                ,
brand	                ,
oracle_code	            ,
creation_date	        ,
last_update_date	    ,
import_method	        ,
status	                
)
VALUES
(
r.item_id	                ,
r.warehouse_number	        ,
r.barcode	                ,
r.description	            ,
r.country_of_origin	        ,
r.item_code	                ,
r.color_code	            ,
r.type	                    ,
r.business_group_code	    ,
r.division_group_code	    ,
r.retail_group_code	        ,
r.local_description	        ,
r.unique_description	    ,
r.uom	                    ,
r.width	                    ,
r.gross_weight	            ,
r.net_weight	            ,
r.uom_weight	            ,
r.volume	                ,
r.brand	                    ,
r.oracle_code	            ,
---WHO:
SYSDATE                     ,
SYSDATE                     ,
'INTG_WEBSERVICE'           ,
'NEW'
);
  COMMIT;
END IF;  
END LOOP;

EXCEPTION WHEN OTHERS THEN
write_log('Error Occured while executing the "load_item_data"');
write_log('Error Code   :'||SQLCODE);
write_log('Error Message:'||SQLERRM);
end load_item_data;

/*==================================================================================================================================*/
---Parse XML and load data into table
procedure parse_xml_load_data(p_clob IN CLOB)
IS
  -- report invocation related variables
  l_xml                     XMLTYPE;
  l_result                  CLOB;

  -- Base64 decoding related variables
  l_blob                    BLOB;

  -- BLOB to XML CLOB conversion related variables
  lc_xml_clob               CLOB;

  BEGIN


  -- 1. Parse SOAP XML Response returned by the Report Service
  l_result := parse_xml_clob(
    p_xml   => xmltype.createxml(p_clob),
    p_xpath => '//reportBytes/text()',
    p_ns    => 'xmlns="http://xmlns.oracle.com/oxp/service/PublicReportService"'
  );

  write_log('SOAP Response Parsed');

  -- 2. Decode Base64 encoding to File BLOB
  l_blob:=get_base64_decoded(p_result=>l_result);

  write_log('Base64 Decoded');

  -- 3. BLOB to XML CLOB Conversion
  lc_xml_clob :=convert_blob_to_xml_clob(p_blob=>l_blob);

  write_log('XML CLOB Generated');

  -- 4. Iterate through XML Table rows and merge data into the DB Table
    begin  
	load_so_data(p_xml_clob=>lc_xml_clob);
	end;

  write_log('Data Inserted/Updated');

  -- 5. Free Temporary memory
  dbms_lob.freetemporary(l_result);
  dbms_lob.freetemporary(l_blob);
  dbms_lob.freetemporary(lc_xml_clob);

EXCEPTION
  WHEN OTHERS
  THEN
    write_log('Error Occured while parsing the http response(parse_xml_load_data)');
	write_log('Error Code   :'||SQLCODE);
	write_log('Error Message:'||SQLERRM);
END parse_xml_load_data;

/*==================================================================================================================================*/
---Parse XML and load data into table
procedure parse_xml_load_vc_data(p_clob IN CLOB)
IS
  -- report invocation related variables
  l_xml                     XMLTYPE;
  l_result                  CLOB;

  -- Base64 decoding related variables
  l_blob                    BLOB;

  -- BLOB to XML CLOB conversion related variables
  lc_xml_clob               CLOB;

  BEGIN


  -- 1. Parse SOAP XML Response returned by the Report Service
  l_result := parse_xml_clob(
    p_xml   => xmltype.createxml(p_clob),
    p_xpath => '//reportBytes/text()',
    p_ns    => 'xmlns="http://xmlns.oracle.com/oxp/service/PublicReportService"'
  );

  write_log('SOAP Response Parsed');

  -- 2. Decode Base64 encoding to File BLOB
  l_blob:=get_base64_decoded(p_result=>l_result);

  write_log('Base64 Decoded');

  -- 3. BLOB to XML CLOB Conversion
  lc_xml_clob :=convert_blob_to_xml_clob(p_blob=>l_blob);

  write_log('XML CLOB Generated');

  -- 4. Iterate through XML Table rows and merge data into the DB Table
    begin  
	load_vc_data(p_xml_clob=>lc_xml_clob);
	end;

  write_log('Data Inserted/Updated');

  -- 5. Free Temporary memory
  dbms_lob.freetemporary(l_result);
  dbms_lob.freetemporary(l_blob);
  dbms_lob.freetemporary(lc_xml_clob);

EXCEPTION
  WHEN OTHERS
  THEN
    write_log('Error Occured while parsing the http response(parse_xml_load_vc_data)');
	write_log('Error Code   :'||SQLCODE);
	write_log('Error Message:'||SQLERRM);
END parse_xml_load_vc_data;

/*==================================================================================================================================*/
---Parse XML and load data into table
procedure parse_xml_load_item_data(p_clob IN CLOB)
IS
  -- report invocation related variables
  l_xml                     XMLTYPE;
  l_result                  CLOB;

  -- Base64 decoding related variables
  l_blob                    BLOB;

  -- BLOB to XML CLOB conversion related variables
  lc_xml_clob               CLOB;

  BEGIN


  -- 1. Parse SOAP XML Response returned by the Report Service
  l_result := parse_xml_clob(
    p_xml   => xmltype.createxml(p_clob),
    p_xpath => '//reportBytes/text()',
    p_ns    => 'xmlns="http://xmlns.oracle.com/oxp/service/PublicReportService"'
  );

  write_log('SOAP Response Parsed');

  -- 2. Decode Base64 encoding to File BLOB
  l_blob:=get_base64_decoded(p_result=>l_result);

  write_log('Base64 Decoded');

  -- 3. BLOB to XML CLOB Conversion
  lc_xml_clob :=convert_blob_to_xml_clob(p_blob=>l_blob);

  write_log('XML CLOB Generated');

  -- 4. Iterate through XML Table rows and merge data into the DB Table
    begin  
	load_item_data(p_xml_clob=>lc_xml_clob);
	end;

  write_log('Data Inserted/Updated');

  -- 5. Free Temporary memory
  dbms_lob.freetemporary(l_result);
  dbms_lob.freetemporary(l_blob);
  dbms_lob.freetemporary(lc_xml_clob);

EXCEPTION
  WHEN OTHERS
  THEN
    write_log('Error Occured while parsing the http response(parse_xml_load_item_data)');
	write_log('Error Code   :'||SQLCODE);
	write_log('Error Message:'||SQLERRM);
END parse_xml_load_item_data;

---Get Pick Slip Details:
PROCEDURE get_pick_slip_details(p_batch_id IN VARCHAR2,p_pick_slip_number OUT VARCHAR2,p_shipment_number OUT VARCHAR2)
AS

  req utl_http.req;
  res utl_http.resp;

  l_text               VARCHAR2(32767);
  l_clob               CLOB;
  lv_url               VARCHAR2(4000):=NULL;

  lv_pick_slip_number  VARCHAR2(400):=NULL;
  lv_shipment_number   VARCHAR2(400):=NULL;
   obj                   pljson       ;

BEGIN

   lv_url:=c_instance_url||'/fscmRestApi/resources/11.13.18.05/pickSlipDetails?q=PickWave='||p_batch_id;

   write_log('url:'||lv_url);

-- If using HTTPS, open a wallet containing the trusted root certificate.
  utl_http.set_wallet (path=>c_wallet_path,password=>c_wallet_pwd);

 -- Make a HTTP request and put the response. 	
  req := utl_http.begin_request (url=>lv_url,method=>c_gps_http_method,http_version=>c_gps_http_version);

  utl_http.set_authentication (req,c_username,c_password);

  res := utl_http.get_response(req);

-------------------------------------------------------------  
 -- Build a CLOB variable to hold web service response
        dbms_lob.createtemporary(l_clob, FALSE );
        dbms_lob.open(l_clob, dbms_lob.lob_readwrite );

         write_log('Response:');
         write_log('--------');
BEGIN
LOOP
   -- Copy the web service response body
   -- in a buffer string variable l_text
   utl_http.read_text(res, l_text, 32766);
   write_log(l_text);

   -- Append data from l_text to CLOB variable
dbms_lob.writeappend(l_clob, length(l_text), l_text);

END LOOP;
EXCEPTION
       WHEN OTHERS THEN
          --  Exit loop without exception
          --  when end-of-body is reached
          IF SQLCODE <> -29266 THEN
             RAISE;
          END IF;
END;

utl_http.end_response(res);

  ---parse it into a pljson object:
  obj := pljson(l_clob);

  --then modify the object:
  pljson_ext.remove(obj, 'links');

  --finally, update the clob and commit:
  dbms_lob.trim(l_clob, 0); --empty the lob
  obj.to_clob(l_clob);
------------------------------------------------------------------------------------
BEGIN
select UNIQUE PickSlip,Shipment
INTO lv_pick_slip_number,lv_shipment_number
from table(
pljson_table.json_table(l_clob,
pljson_varray('items[*].PickSlip',
              'items[*].Shipment'),
pljson_varray('PickSlip','Shipment'),
table_mode => 'nested')
);
EXCEPTION WHEN OTHERS THEN
NULL;
END;
------------------------------------------------------------------------------------

p_pick_slip_number:=lv_pick_slip_number;
p_shipment_number:=lv_shipment_number;

dbms_lob.freetemporary(l_clob);

EXCEPTION
	WHEN utl_http.too_many_requests 
	THEN 

	write_log('Error Occured while executing the "get_pick_slip_details"');
    write_log('Error Code   :'||SQLCODE);
    write_log('Error Message:'||SQLERRM);
	utl_http.end_response(res);

    WHEN utl_http.end_of_body 
    THEN 

	write_log('Error Occured while executing the "get_pick_slip_details"');
    write_log('Error Code   :'||SQLCODE);
    write_log('Error Message:'||SQLERRM);
	utl_http.end_response(res);

	WHEN OTHERS 
	THEN 

	write_log('Error Occured while executing the "get_pick_slip_details"');
    write_log('Error Code   :'||SQLCODE);
    write_log('Error Message:'||SQLERRM);
	utl_http.end_response(res);
END get_pick_slip_details;  

/*==================================================================================================================================*/

 -- Pull SO data from fusion
 procedure pull_so_data_from_fusion(p_business_unit IN VARCHAR2,p_line_status in varchar2)
 is 
  -- soap requests message
  l_soap_req_msg                varchar2(32767):=xx_wms_int_pkg.get_report_request_payload(p_business_unit=>p_business_unit,p_line_status=>p_line_status);

  -- http request/response
  http_req                      utl_http.req;
  http_resp                     utl_http.resp;
  l_clob                        clob;
  l_text                        varchar2(32767);

BEGIN
  -- set wallet directory
    utl_http.set_wallet (path=>c_wallet_path,password=>c_wallet_pwd);

  -- WSDL url for fusion report web service is placed in UTL_HTTP.begin_request, web service handler as 'POST' and protocol version HTTP/1.1
    http_req := utl_http.begin_request (url=>c_report_wsdl_url,
	                                    method=>c_http_method,
										http_version=>c_http_version);

    utl_http.set_header (http_req, 'Content-Type'  , c_content_type);--type of input data i.e. request payload
    utl_http.set_header (http_req, 'Content-Length', length (l_soap_req_msg));
    utl_http.set_header (http_req, 'SOAPAction'    , c_soap_action);
    utl_http.set_header (http_req, 'Connection'    , c_connection);

  --Specify fusion user's username and password
    utl_http.set_authentication (http_req,c_username,c_password);

    utl_http.write_text (http_req, l_soap_req_msg);

  -- invoke request and get response.
    http_resp := utl_http.get_response (http_req);

    dbms_lob.createtemporary (l_clob, false);
    dbms_lob.open (l_clob, dbms_lob.lob_readwrite);


BEGIN
LOOP
   -- Copy the web service response body
   -- in a buffer string variable l_text
   utl_http.read_text(http_resp, l_text, 32766);
   write_log(l_text);

   -- Append data from l_text to CLOB variable
   dbms_lob.writeappend(l_clob, length(l_text), l_text);

END LOOP;
EXCEPTION
       WHEN OTHERS THEN
          --  Exit loop without exception
          --  when end-of-body is reached
          IF SQLCODE <> -29266 THEN
             RAISE;
          END IF;
END;
utl_http.end_response (http_resp);
------------------------------------
BEGIN
parse_xml_load_data(p_clob=>l_clob);
END;
------------------------------------
-- Free Temporary memory
dbms_lob.freetemporary (l_clob);

EXCEPTION
  WHEN utl_http.too_many_requests THEN
       utl_http.end_response(http_resp); 
	   write_log('Error occured while importing the SO data from fusion');
	   write_log('Error Code   :'||SQLCODE);
	   write_log('Error Message:'||SQLERRM);
  WHEN utl_http.end_of_body THEN
	 write_log('Error occured while importing the SO data from fusion');
	 write_log('Error Code   :'||SQLCODE);
	 write_log('Error Message:'||SQLERRM);
     utl_http.end_response(http_resp);
  WHEN OTHERS THEN
	 write_log('Error occured while importing the SO data from fusion');
	 write_log('Error Code   :'||SQLCODE);
	 write_log('Error Message:'||SQLERRM);
     utl_http.end_response(http_resp);	 
END pull_so_data_from_fusion;	

/*==================================================================================================================================*/

 -- Pull Vendor/Customer Master data from fusion
 procedure pull_vc_data_from_fusion(p_business_unit IN VARCHAR2)
 is 
  -- soap requests message
  l_soap_req_msg                varchar2(32767):=xx_wms_int_pkg.get_vc_report_request_payload(p_business_unit=>p_business_unit);

  -- http request/response
  http_req                      utl_http.req;
  http_resp                     utl_http.resp;
  l_clob                        clob;
  l_text                        varchar2(32767);

BEGIN
  -- set wallet directory
    utl_http.set_wallet (path=>c_wallet_path,password=>c_wallet_pwd);

  -- WSDL url for fusion report web service is placed in UTL_HTTP.begin_request, web service handler as 'POST' and protocol version HTTP/1.1
    http_req := utl_http.begin_request (url=>c_report_wsdl_url,
	                                    method=>c_http_method,
										http_version=>c_http_version);

    utl_http.set_header (http_req, 'Content-Type'  , c_content_type);--type of input data i.e. request payload
    utl_http.set_header (http_req, 'Content-Length', length (l_soap_req_msg));
    utl_http.set_header (http_req, 'SOAPAction'    , c_soap_action);
    utl_http.set_header (http_req, 'Connection'    , c_connection);

  --Specify fusion user's username and password
    utl_http.set_authentication (http_req,c_username,c_password);

    utl_http.write_text (http_req, l_soap_req_msg);

  -- invoke request and get response.
    http_resp := utl_http.get_response (http_req);

    dbms_lob.createtemporary (l_clob, false);
    dbms_lob.open (l_clob, dbms_lob.lob_readwrite);


BEGIN
LOOP
   -- Copy the web service response body
   -- in a buffer string variable l_text
   utl_http.read_text(http_resp, l_text, 32766);
   write_log(l_text);

   -- Append data from l_text to CLOB variable
   dbms_lob.writeappend(l_clob, length(l_text), l_text);

END LOOP;
EXCEPTION
       WHEN OTHERS THEN
          --  Exit loop without exception
          --  when end-of-body is reached
          IF SQLCODE <> -29266 THEN
             RAISE;
          END IF;
END;
utl_http.end_response (http_resp);
------------------------------------
BEGIN
parse_xml_load_vc_data(p_clob=>l_clob);
END;
------------------------------------
-- Free Temporary memory
dbms_lob.freetemporary (l_clob);

EXCEPTION
  WHEN utl_http.too_many_requests THEN
       utl_http.end_response(http_resp); 
	   write_log('Error occured while importing the Vendor/Customer Master data from fusion');
	   write_log('Error Code   :'||SQLCODE);
	   write_log('Error Message:'||SQLERRM);
  WHEN utl_http.end_of_body THEN
	 write_log('Error occured while importing the Vendor/Customer Master data from fusion');
	 write_log('Error Code   :'||SQLCODE);
	 write_log('Error Message:'||SQLERRM);
     utl_http.end_response(http_resp);
  WHEN OTHERS THEN
	 write_log('Error occured while importing the Vendor/Customer Master data from fusion');
	 write_log('Error Code   :'||SQLCODE);
	 write_log('Error Message:'||SQLERRM);
     utl_http.end_response(http_resp);	 
END pull_vc_data_from_fusion;

-- Pull Item data from fusion
 procedure pull_item_data_from_fusion
 is 
  -- soap requests message
  l_soap_req_msg                varchar2(32767):=xx_wms_int_pkg.get_item_report_request_payload;

  -- http request/response
  http_req                      utl_http.req;
  http_resp                     utl_http.resp;
  l_clob                        clob;
  l_text                        varchar2(32767);

BEGIN
  -- set wallet directory
    utl_http.set_wallet (path=>c_wallet_path,password=>c_wallet_pwd);

  -- WSDL url for fusion report web service is placed in UTL_HTTP.begin_request, web service handler as 'POST' and protocol version HTTP/1.1
    http_req := utl_http.begin_request (url=>c_report_wsdl_url,
	                                    method=>c_http_method,
										http_version=>c_http_version);

    utl_http.set_header (http_req, 'Content-Type'  , c_content_type);--type of input data i.e. request payload
    utl_http.set_header (http_req, 'Content-Length', length (l_soap_req_msg));
    utl_http.set_header (http_req, 'SOAPAction'    , c_soap_action);
    utl_http.set_header (http_req, 'Connection'    , c_connection);

  --Specify fusion user's username and password
    utl_http.set_authentication (http_req,c_username,c_password);

    utl_http.write_text (http_req, l_soap_req_msg);

  -- invoke request and get response.
    http_resp := utl_http.get_response (http_req);

    dbms_lob.createtemporary (l_clob, false);
    dbms_lob.open (l_clob, dbms_lob.lob_readwrite);


BEGIN
LOOP
   -- Copy the web service response body
   -- in a buffer string variable l_text
   utl_http.read_text(http_resp, l_text, 32766);
   write_log(l_text);

   -- Append data from l_text to CLOB variable
   dbms_lob.writeappend(l_clob, length(l_text), l_text);

END LOOP;
EXCEPTION
       WHEN OTHERS THEN
          --  Exit loop without exception
          --  when end-of-body is reached
          IF SQLCODE <> -29266 THEN
             RAISE;
          END IF;
END;
utl_http.end_response (http_resp);
------------------------------------
BEGIN
parse_xml_load_item_data(p_clob=>l_clob);
END;
------------------------------------
-- Free Temporary memory
dbms_lob.freetemporary (l_clob);

EXCEPTION
  WHEN utl_http.too_many_requests THEN
       utl_http.end_response(http_resp); 
	   write_log('Error occured while importing the item data from fusion');
	   write_log('Error Code   :'||SQLCODE);
	   write_log('Error Message:'||SQLERRM);
  WHEN utl_http.end_of_body THEN
	 write_log('Error occured while importing the item data from fusion');
	 write_log('Error Code   :'||SQLCODE);
	 write_log('Error Message:'||SQLERRM);
     utl_http.end_response(http_resp);
  WHEN OTHERS THEN
	 write_log('Error occured while importing the item data from fusion');
	 write_log('Error Code   :'||SQLCODE);
	 write_log('Error Message:'||SQLERRM);
     utl_http.end_response(http_resp);	 
END pull_item_data_from_fusion;	

-- procedure to call Vendor/Customer Master Webservice:
PROCEDURE push_vc_data_to_wms(
                              p_party_id in varchar2,
							  p_party_code in varchar2,
							  p_party_name in varchar2)
AS

  req utl_http.req;
  res utl_http.resp;

  l_text         VARCHAR2(32767);
  l_clob         CLOB;
  content        CLOB;
  lv_status      VARCHAR2(240) :=NULL;
  lv_name        VARCHAR2(240) :=NULL;
  lv_message     VARCHAR2(4000):=NULL;
  lv_success_tag VARCHAR2(4000):=NULL;
  lv_statuscode_tag VARCHAR2(4000):=NULL;

  obj pljson;
  lv_user_token  VARCHAR2(4000):=xx_wms_int_pkg.generate_user_token;

BEGIN

write_log('Line:3082');
   content:=xx_wms_int_pkg.get_wms_vc_request_payload
                             (
                              p_party_id         => p_party_id,
							  p_party_code       => p_party_code,
							  p_party_name       => p_party_name);
write_log('Line:3088');
 -- Make a HTTP request and get the response. 	
  req := utl_http.begin_request (url=>c_vc_url,
                                 method=>c_vc_http_method,
								 http_version=>c_vc_http_version);

  utl_http.set_header(req, 'Authorization' ,'Bearer '||lv_user_token);
  utl_http.set_header(req, 'content-type'  , c_vc_content_type); 
  utl_http.set_header(req, 'Content-Length', LENGTH(content));

  utl_http.write_text(req, content);
  res := utl_http.get_response(req);

  write_log('Request:');
  write_log('--------');
  write_log(content);

-------------------------------------------------------------  
 -- Build a CLOB variable to hold web service response
        dbms_lob.createtemporary(l_clob, FALSE );
        dbms_lob.open(l_clob, dbms_lob.lob_readwrite );

         write_log('Response:');
         write_log('--------');
BEGIN
LOOP
   -- Copy the web service response body
   -- in a buffer string variable l_text
   utl_http.read_text(res, l_text, 32766);
   write_log(l_text);

   -- Append data from l_text to CLOB variable
dbms_lob.writeappend(l_clob, length(l_text), l_text);

END LOOP;
EXCEPTION
       WHEN OTHERS THEN
          --  Exit loop without exception
          --  when end-of-body is reached
          IF SQLCODE <> -29266 THEN
             RAISE;
          END IF;
END;

utl_http.end_response(res);

  ---parse it into a pljson object:
  obj := pljson(l_clob);

BEGIN  
select unique success INTO lv_success_tag
from table(
pljson_table.json_table(
l_clob,
pljson_varray('success'),
pljson_varray('success'))
);
EXCEPTION WHEN OTHERS THEN
lv_success_tag:=NULL;
END;

BEGIN  
select unique StatusCode INTO lv_statuscode_tag
from table(
pljson_table.json_table(
l_clob,
pljson_varray('StatusCode'),
pljson_varray('StatusCode'))
);
EXCEPTION WHEN OTHERS THEN
lv_statuscode_tag:=NULL;
END;

IF (lv_success_tag IN ('true','false')) THEN

UPDATE xx_fusion_cust_vend_dtls_tb
SET 
request_payload         = content     ,
response_object         = l_clob      ,
transaction_id          = pljson_ext.get_string(obj, 'transactionId')  ,
result                  = pljson_ext.get_string(obj, 'result')  ,
messagetype             = pljson_ext.get_string(obj, 'messagetype')  ,
messagecode             = pljson_ext.get_string(obj, 'messagecode')  ,
message                 = pljson_ext.get_string(obj, 'message')  ,
success                 = lv_success_tag  ,
status                  = 'SUCCESS',
last_update_date        = SYSDATE
WHERE 1=1
AND party_id=p_party_id
AND party_code=p_party_code
AND status<>'SUCCESS';
COMMIT;  

END IF;

IF lv_statuscode_tag='error' THEN

UPDATE xx_fusion_cust_vend_dtls_tb
SET 
request_payload         = content     ,
response_object         = l_clob      ,
transaction_id          = pljson_ext.get_string(obj, 'ResTxnId')  ,
result                  = pljson_ext.get_string(obj, 'result')  ,
messagetype             = pljson_ext.get_string(obj, 'Status')  ,
messagecode             = pljson_ext.get_string(obj, 'StatusCode')  ,
message                 = pljson_ext.get_string(obj, 'Message')  ,
status                  = 'ERROR',
last_update_date        = SYSDATE
WHERE 1=1
AND party_id=p_party_id
AND party_code=p_party_code
AND status<>'SUCCESS';
COMMIT;  

END IF;



write_log('WMS_SUCCESS:'||pljson_ext.get_string(obj, 'success'));

dbms_lob.freetemporary(l_clob);

EXCEPTION
	WHEN utl_http.too_many_requests THEN
	     write_log('error occured while executing the push_vc_data_to_wms');
         write_log('Error Code   :'||SQLCODE);
         write_log('Error Message:'||SQLERRM);
         utl_http.end_response(res);
    WHEN utl_http.end_of_body THEN 
      	 write_log('error occured while executing the push_vc_data_to_wms');
         write_log('Error Code   :'||SQLCODE);
         write_log('Error Message:'||SQLERRM);
         utl_http.end_response(res);

	WHEN OTHERS THEN 
      	 write_log('error occured while executing the push_vc_data_to_wms');
         write_log('Error Code   :'||SQLCODE);
         write_log('Error Message:'||SQLERRM);
         utl_http.end_response(res);	 
END push_vc_data_to_wms;

-- procedure to call Item Webservice:
PROCEDURE push_item_data_to_wms(p_item_id in VARCHAR2)
AS

  req utl_http.req;
  res utl_http.resp;

  l_text         VARCHAR2(32767);
  l_clob         CLOB;
  content        CLOB;
  lv_status      VARCHAR2(240) :=NULL;
  lv_name        VARCHAR2(240) :=NULL;
  lv_message     VARCHAR2(4000):=NULL;
  lv_success_tag VARCHAR2(4000):=NULL;
  lv_statuscode_tag VARCHAR2(4000):=NULL;

  obj pljson;
  lv_user_token  VARCHAR2(4000):=xx_wms_int_pkg.generate_user_token;

BEGIN

   content:=xx_wms_int_pkg.get_wms_item_request_payload (p_item_id=>p_item_id);

 -- Make a HTTP request and get the response. 	
  req := utl_http.begin_request (url=>c_it_url,
                                 method=>c_it_http_method,
								 http_version=>c_it_http_version);

  utl_http.set_header(req, 'Authorization' ,'Bearer '||lv_user_token);
  utl_http.set_header(req, 'content-type'  , c_it_content_type); 
  utl_http.set_header(req, 'Content-Length', LENGTH(content));

  utl_http.write_text(req, content);
  res := utl_http.get_response(req);

  write_log('Request:');
  write_log('--------');
  write_log(content);

-------------------------------------------------------------  
 -- Build a CLOB variable to hold web service response
        dbms_lob.createtemporary(l_clob, FALSE );
        dbms_lob.open(l_clob, dbms_lob.lob_readwrite );

         write_log('Response:');
         write_log('--------');
BEGIN
LOOP
   -- Copy the web service response body
   -- in a buffer string variable l_text
   utl_http.read_text(res, l_text, 32766);
   write_log(l_text);

   -- Append data from l_text to CLOB variable
dbms_lob.writeappend(l_clob, length(l_text), l_text);

END LOOP;
EXCEPTION
       WHEN OTHERS THEN
          --  Exit loop without exception
          --  when end-of-body is reached
          IF SQLCODE <> -29266 THEN
             RAISE;
          END IF;
END;

utl_http.end_response(res);

  ---parse it into a pljson object:
  obj := pljson(l_clob);

BEGIN  
select unique success INTO lv_success_tag
from table(
pljson_table.json_table(
l_clob,
pljson_varray('success'),
pljson_varray('success'))
);
EXCEPTION WHEN OTHERS THEN
lv_success_tag:=NULL;
END;
--------------------------------------------------------
BEGIN  
select unique StatusCode INTO lv_statuscode_tag
from table(
pljson_table.json_table(
l_clob,
pljson_varray('StatusCode'),
pljson_varray('StatusCode'))
);
EXCEPTION WHEN OTHERS THEN
lv_statuscode_tag:=NULL;
END;

--------------------------------------------------------

IF lv_success_tag IN ('true','false')  THEN

UPDATE xx_item_master_dtls_tb
SET 
request_payload  =content,
response_object  =l_clob,
transaction_id   =NVL(pljson_ext.get_string(obj, 'transactionId'),pljson_ext.get_string(obj, 'ResTxnId')),
result           =pljson_ext.get_string(obj, 'result'),
messagetype      =pljson_ext.get_string(obj, 'messageType'),
messagecode      =NVL(pljson_ext.get_string(obj, 'messageCode'),pljson_ext.get_string(obj, 'StatusCode')),
message          =NVL(pljson_ext.get_string(obj, 'message'),pljson_ext.get_string(obj, 'Message')),
success          =lv_success_tag,
status           ='SUCCESS',
last_update_date =SYSDATE
WHERE 1=1
AND item_id=p_item_id
AND status<>'SUCCESS';
COMMIT;  

END IF;

--------------------------------------------------------

IF lv_statuscode_tag='error' THEN

UPDATE xx_item_master_dtls_tb
SET 
request_payload  =content,
response_object  =l_clob,
transaction_id   =NVL(pljson_ext.get_string(obj, 'transactionId'),pljson_ext.get_string(obj, 'ResTxnId')),
result           =pljson_ext.get_string(obj, 'result'),
messagetype      =pljson_ext.get_string(obj, 'messageType'),
messagecode      =NVL(pljson_ext.get_string(obj, 'messageCode'),pljson_ext.get_string(obj, 'StatusCode')),
message          =NVL(pljson_ext.get_string(obj, 'message'),pljson_ext.get_string(obj, 'Message')),
success          =lv_success_tag,
status           ='ERROR',
last_update_date =SYSDATE
WHERE 1=1
AND item_id=p_item_id
AND status<>'SUCCESS';
COMMIT;  

END IF;

write_log('WMS_SUCCESS:'||pljson_ext.get_string(obj, 'success'));

dbms_lob.freetemporary(l_clob);

EXCEPTION
	WHEN utl_http.too_many_requests THEN
	     write_log('error occured while executing the push_item_data_to_wms');
         write_log('Error Code   :'||SQLCODE);
         write_log('Error Message:'||SQLERRM);
         utl_http.end_response(res);
    WHEN utl_http.end_of_body THEN 
      	 write_log('error occured while executing the push_item_data_to_wms');
         write_log('Error Code   :'||SQLCODE);
         write_log('Error Message:'||SQLERRM);
         utl_http.end_response(res);

	WHEN OTHERS THEN 
      	 write_log('error occured while executing the push_item_data_to_wms');
         write_log('Error Code   :'||SQLCODE);
         write_log('Error Message:'||SQLERRM);
         utl_http.end_response(res);	 
END push_item_data_to_wms;

-- procedure to call WMS Ship Order Webservice:
PROCEDURE push_so_data_to_wms(p_header_id IN NUMBER,p_order_number in VARCHAR2)
AS

  req utl_http.req;
  res utl_http.resp;

  l_text         VARCHAR2(32767);
  l_clob         CLOB;
  content        CLOB;
  lv_status      VARCHAR2(240) :=NULL;
  lv_name        VARCHAR2(240) :=NULL;
  lv_message     VARCHAR2(4000):=NULL;
  lv_success_tag VARCHAR2(4000):=NULL;

  obj pljson;
  lv_user_token  VARCHAR2(4000):=xx_wms_int_pkg.generate_user_token;

BEGIN

   content:=xx_wms_int_pkg.get_wms_so_request_payload(p_header_id=>p_header_id,p_order_number=>p_order_number);

 -- Make a HTTP request and get the response. 	
  req := utl_http.begin_request (url=>c_dn_url,
                                 method=>c_dn_http_method,
								 http_version=>c_dn_http_version);

  utl_http.set_header(req, 'Authorization' ,'Bearer '||lv_user_token);
  utl_http.set_header(req, 'content-type'  , c_dn_content_type); 
  utl_http.set_header(req, 'Content-Length', LENGTH(content));

  utl_http.write_text(req, content);
  res := utl_http.get_response(req);

  write_log('Request:');
  write_log('--------');
  write_log(content);

-------------------------------------------------------------  
 -- Build a CLOB variable to hold web service response
        dbms_lob.createtemporary(l_clob, FALSE );
        dbms_lob.open(l_clob, dbms_lob.lob_readwrite );

         write_log('Response:');
         write_log('--------');
BEGIN
LOOP
   -- Copy the web service response body
   -- in a buffer string variable l_text
   utl_http.read_text(res, l_text, 32766);
   write_log(l_text);

   -- Append data from l_text to CLOB variable
dbms_lob.writeappend(l_clob, length(l_text), l_text);

END LOOP;
EXCEPTION
       WHEN OTHERS THEN
          --  Exit loop without exception
          --  when end-of-body is reached
          IF SQLCODE <> -29266 THEN
             RAISE;
          END IF;
END;

utl_http.end_response(res);

  ---parse it into a pljson object:
  obj := pljson(l_clob);

BEGIN  
select unique success INTO lv_success_tag
from table(
pljson_table.json_table(
l_clob,
pljson_varray('success'),
pljson_varray('success'))
);
EXCEPTION WHEN OTHERS THEN
lv_success_tag:=NULL;
END;

UPDATE xx_fusion_so_dtls_tb
SET 
wms_req_payload     =content,
wms_so_resp_object  =l_clob,
wms_transaction_id  =NVL(pljson_ext.get_string(obj, 'transactionId'),pljson_ext.get_string(obj, 'ResTxnId')),
wms_result          =pljson_ext.get_string(obj, 'result'),
wms_messagetype     =pljson_ext.get_string(obj, 'messageType'),
wms_messagecode     =NVL(pljson_ext.get_string(obj, 'messageCode'),pljson_ext.get_string(obj, 'StatusCode')),
wms_message         =NVL(pljson_ext.get_string(obj, 'message'),pljson_ext.get_string(obj, 'Message')),
wms_success         =lv_success_tag

WHERE 1=1
AND header_id=p_header_id
AND order_number=p_order_number
AND (wms_success<>'true' or wms_success IS NULL)
AND line_status IN ('Awaiting Shipping','Awaiting Receiving');
COMMIT;  

write_log('WMS_SUCCESS:'||pljson_ext.get_string(obj, 'success'));

dbms_lob.freetemporary(l_clob);

EXCEPTION
	WHEN utl_http.too_many_requests THEN
	     write_log('error occured while executing the push_so_data_to_wms');
         write_log('Error Code   :'||SQLCODE);
         write_log('Error Message:'||SQLERRM);
         utl_http.end_response(res);
    WHEN utl_http.end_of_body THEN 
      	 write_log('error occured while executing the push_so_data_to_wms');
         write_log('Error Code   :'||SQLCODE);
         write_log('Error Message:'||SQLERRM);
         utl_http.end_response(res);

	WHEN OTHERS THEN 
      	 write_log('error occured while executing the push_so_data_to_wms');
         write_log('Error Code   :'||SQLCODE);
         write_log('Error Message:'||SQLERRM);
         utl_http.end_response(res);	 
END push_so_data_to_wms;

/*==================================================================================================================================*/
--- Parse Json items:
PROCEDURE cps_parse_json_items(p_id IN NUMBER,p_batch_id IN VARCHAR2)
AS

  obj             pljson;
  my_clob         clob ;
  lv_cps_status   VARCHAR2(240);
  lv_cps_message  VARCHAR2(4000):=NULL;

begin

select confirm_pick_slip_resp_obj into my_clob from xx_wms_ship_line_dtls_tb where 1=1 and id=p_id and batch_id=p_batch_id AND confirm_pick_slip_resp_obj IS NOT NULL AND ROWNUM=1;

  ---parse it into a pljson object:
  obj := pljson(my_clob);

  --then modify the object:
  pljson_ext.remove(obj, 'links');

  --------
  lv_cps_status:=pljson_ext.get_string(obj, 'ReturnStatus'); 
  lv_cps_message:=pljson_ext.get_string(obj, 'ErrorCode')||'-'||pljson_ext.get_string(obj, 'ErrorExplanation');
  ----------

DELETE xx_wms_pick_slip_line_temp_tb;
COMMIT;

--- Get picked Quantity:
BEGIN
INSERT INTO xx_wms_pick_slip_line_temp_tb
select UNIQUE pick_slip_number,pick_slip_line,picked_quantity
from table(
pljson_table.json_table(my_clob,
pljson_varray('pickLines[*].PickSlip','pickLines[*].PickSlipLine','pickLines[*].PickedQuantity'),
pljson_varray('Pick_Slip_number','Pick_Slip_Line','Picked_Quantity'),
table_mode => 'nested'));
COMMIT;
EXCEPTION WHEN OTHERS THEN
NULL;
END;  
--------------------------------------------------------------------------------------------------
FOR m IN (SELECT * FROM XX_WMS_PICK_SLIP_LINE_TEMP_TB WHERE 1=1)
LOOP

UPDATE xx_wms_ship_line_dtls_tb 
SET fusion_picked_quantity=m.picked_quantity ,
    confirm_pick_slip_status=lv_cps_status,
	confirm_pick_slip_message=lv_cps_message,
	confirm_pick_slip_date=TO_CHAR(SYSDATE,'DD-MON-YYYY HH24:MI:SS'),
	last_update_date=TO_CHAR(SYSDATE,'DD-MON-YYYY HH24:MI:SS'),
	status=(CASE WHEN lv_cps_status='Success' THEN 'Pick slip was confirmed' ELSE lv_cps_message END)
WHERE 1=1 
AND id=p_id
AND batch_id=p_batch_id
AND pick_slip_number=m.pick_slip_number
AND pick_slip_line=m.pick_slip_line;
COMMIT;
END LOOP;
--------------------------------------------------------------------------------------------------
DELETE xx_wms_pick_slip_line_temp_tb;
COMMIT;

EXCEPTION WHEN OTHERS THEN
write_log('Error Occured while executing the procedure cps_parse_json_items');
write_log('Error Code:'||SQLCODE);
write_log('Error Message:'||SQLERRM);  
end cps_parse_json_items;

--- Parse Json items:
PROCEDURE sc_parse_json_items(p_id IN NUMBER,p_sales_order_number IN VARCHAR2,p_batch_id IN VARCHAR2)
AS
  obj                   pljson       ;
  my_clob               CLOB         ;
  lv_sc_status          VARCHAR2(240);
  lv_sc_message         VARCHAR2(4000):=NULL;

begin

select ship_confirm_resp_obj into my_clob from xx_wms_ship_line_dtls_tb where 1=1 and id=p_id and sales_order=p_sales_order_number and batch_id=p_batch_id AND ship_confirm_resp_obj IS NOT NULL AND ROWNUM=1;

  ---parse it into a pljson object:
  obj := pljson(my_clob);

  --then modify the object:
  pljson_ext.remove(obj, 'links');

  --------    
  lv_sc_status:=pljson_ext.get_string(obj, 'Result');
  lv_sc_message:=pljson_ext.get_string(obj, 'ErrorMessage');
  ----------

UPDATE xx_wms_ship_line_dtls_tb
SET 
status=(CASE WHEN lv_sc_status<>'ERROR' THEN 'Ship confirmed' ELSE lv_sc_message END),
ship_confirm_status=lv_sc_status,
ship_confirm_message=lv_sc_message,
ship_confirm_date=TO_CHAR(SYSDATE,'DD-MON-YYYY HH24:MI:SS'),
last_update_date=TO_CHAR(SYSDATE,'DD-MON-YYYY HH24:MI:SS')
WHERE 1=1
and sales_order=p_sales_order_number
and id=p_id
and batch_id=p_batch_id;
COMMIT;

EXCEPTION WHEN OTHERS THEN
write_log('Error Occured while executing the procedure sc_parse_json_items');
write_log('Error Code:'||SQLCODE);
write_log('Error Message:'||SQLERRM);  
end sc_parse_json_items;


-- create pick wave:
PROCEDURE create_pick_wave(p_id IN NUMBER,p_sales_order_number IN VARCHAR2,p_batch_id OUT VARCHAR2)
AS

  req utl_http.req;
  res utl_http.resp;

  l_text       VARCHAR2(32767);
  l_clob       CLOB;
  m_clob       CLOB;
  content      CLOB;
  lv_status    VARCHAR2(240) :=NULL;
  lv_name      VARCHAR2(240) :=NULL;
  lv_message   VARCHAR2(4000):=NULL;

  lv_batch_id           VARCHAR2(240) :=NULL;
  lv_picking_batch_name VARCHAR2(240) :=NULL;
  lv_pick_wave_status   VARCHAR2(240) :=NULL;
  lv_pick_wave_message  VARCHAR2(4000):=NULL;

   obj                   pljson;

BEGIN

   content:=xx_wms_int_pkg.get_crt_pickwave_req_payload(p_sales_order_number=>p_sales_order_number,
                                                        p_id=>p_id);

-- If using HTTPS, open a wallet containing the trusted root certificate.
  utl_http.set_wallet (path=>c_wallet_path,password=>c_wallet_pwd);

 -- Make a HTTP request and get the response. 	
  req := utl_http.begin_request (url=>c_cpw_url,
                                 method=>c_cpw_http_method,
								 http_version=>c_cpw_http_version);

  utl_http.set_header(req, 'content-type'  , c_cpw_content_type); 
  utl_http.set_header(req, 'Content-Length', LENGTH(content));

    --Specify fusion user's username and password
    utl_http.set_authentication (req,c_username,c_password);

  utl_http.write_text(req, content);
  res := utl_http.get_response(req);

  write_log('Request:');
  write_log('--------');
  write_log(content);

-------------------------------------------------------------  
 -- Build a CLOB variable to hold web service response
        dbms_lob.createtemporary(l_clob, FALSE );
        dbms_lob.open(l_clob, dbms_lob.lob_readwrite );

         write_log('Response:');
         write_log('--------');
BEGIN
LOOP
   -- Copy the web service response body
   -- in a buffer string variable l_text
   utl_http.read_text(res, l_text, 32766);
   write_log(l_text);

   -- Append data from l_text to CLOB variable
dbms_lob.writeappend(l_clob, length(l_text), l_text);

END LOOP;
EXCEPTION
       WHEN OTHERS THEN
          --  Exit loop without exception
          --  when end-of-body is reached
          IF SQLCODE <> -29266 THEN
             RAISE;
          END IF;
END;

utl_http.end_response(res);

m_clob:=l_clob;

-------------------------------------------------------------------------------------------------------
  ---parse it into a pljson object:
  obj := pljson(l_clob);
  --then modify the object:
  pljson_ext.remove(obj, 'links');
  --------
  lv_batch_id:=pljson_ext.get_number(obj, 'BatchId');
  lv_picking_batch_name:=pljson_ext.get_string(obj, 'PickingBatchName');     
  lv_pick_wave_status:=pljson_ext.get_string(obj, 'ReturnStatus');
  lv_pick_wave_message:=pljson_ext.get_string(obj, 'ReturnMessage');
------------------------------------------------------------------------------------
-- Update Response Object:
BEGIN
INSERT INTO xx_wms_ship_batch_dtls_tb
(
batch_id                        ,
picking_batch_name              ,
create_pick_wave_status         ,
create_pick_wave_message        ,
create_pick_wave_date           ,
creation_date                   ,
last_update_date                
)
VALUES
(
lv_batch_id,
lv_picking_batch_name,
lv_pick_wave_status,
lv_pick_wave_message,
TO_CHAR(SYSDATE,'DD-MON-YYYY HH24:MI:SS'),
TO_CHAR(SYSDATE,'DD-MON-YYYY HH24:MI:SS'),
TO_CHAR(SYSDATE,'DD-MON-YYYY HH24:MI:SS')
);
COMMIT;
write_log('Updated the response');
EXCEPTION WHEN OTHERS THEN
NULL;
END;

-- Update Response CLOB Object:
update xx_wms_ship_batch_dtls_tb set create_pick_wave_resp_obj=m_clob where 1=1 and batch_id=lv_batch_id;
commit;

-- Free Temporary Memory:
dbms_lob.freetemporary(l_clob);
dbms_lob.freetemporary(m_clob);

-- Return Batch ID:
p_batch_id:=lv_batch_id;

EXCEPTION
	WHEN utl_http.too_many_requests 
	THEN 
	write_log('Error Occured while executing the "create_pick_wave"');
    write_log('Error Code   :'||SQLCODE);
    write_log('Error Message:'||SQLERRM);
	utl_http.end_response(res);
    WHEN utl_http.end_of_body 
    THEN 
	write_log('Error Occured while executing the "create_pick_wave"');
    write_log('Error Code   :'||SQLCODE);
    write_log('Error Message:'||SQLERRM);
	utl_http.end_response(res);
	WHEN OTHERS 
	THEN 
	write_log('Error Occured while executing the "create_pick_wave"');
    write_log('Error Code   :'||SQLCODE);
    write_log('Error Message:'||SQLERRM);
	utl_http.end_response(res);
END create_pick_wave;

-- procedure to release pick wave:
PROCEDURE release_pick_wave(p_batch_id IN VARCHAR2)
AS

  req utl_http.req;
  res utl_http.resp;

  l_text     VARCHAR2(32767);
  l_clob     CLOB;
  m_clob     CLOB;
  content    CLOB;
  lv_status  VARCHAR2(240) :=NULL;
  lv_name    VARCHAR2(240) :=NULL;
  lv_message VARCHAR2(4000):=NULL;


  obj                   pljson;
  my_clob               clob ;
  lv_batch_id           VARCHAR2(240) :=NULL;
  lv_picking_batch_name VARCHAR2(240) :=NULL;
  lv_pick_wave_status   VARCHAR2(240) :=NULL;
  lv_pick_wave_message  VARCHAR2(4000):=NULL;

BEGIN

   content:='{
	"PickReleaseFlag": true,
	"ReleaseMode": "ONLINE"
    }';

-- If using HTTPS, open a wallet containing the trusted root certificate.
  utl_http.set_wallet (path=>c_wallet_path,password=>c_wallet_pwd);

 -- Make a HTTP request and get the response. 	
  req := utl_http.begin_request (url=>c_rpw_url||p_batch_id,
                                 method=>c_rpw_http_method,
								 http_version=>c_rpw_http_version);

  utl_http.set_header(req, 'content-type'  , c_rpw_content_type); 
  utl_http.set_header(req, 'Content-Length', LENGTH(content));

    --Specify fusion user's username and password
    utl_http.set_authentication (req,c_username,c_password);

  utl_http.write_text(req, content);
  res := utl_http.get_response(req);

  write_log('Request:');
  write_log('--------');
  write_log(content);

-------------------------------------------------------------  
 -- Build a CLOB variable to hold web service response
        dbms_lob.createtemporary(l_clob, FALSE );
        dbms_lob.open(l_clob, dbms_lob.lob_readwrite );

         write_log('Response:');
         write_log('--------');
BEGIN
LOOP
   -- Copy the web service response body
   -- in a buffer string variable l_text
   utl_http.read_text(res, l_text, 32766);
   write_log(l_text);

   -- Append data from l_text to CLOB variable
dbms_lob.writeappend(l_clob, length(l_text), l_text);

END LOOP;
EXCEPTION
       WHEN OTHERS THEN
          --  Exit loop without exception
          --  when end-of-body is reached
          IF SQLCODE <> -29266 THEN
             RAISE;
          END IF;
END;

utl_http.end_response(res);

m_clob:=l_clob;

-------------------------------------------------------------------------------------------------------
  ---parse it into a pljson object:
  obj := pljson(l_clob);
  --then modify the object:
  pljson_ext.remove(obj, 'links');
  --------    
  lv_pick_wave_status:=pljson_ext.get_string(obj, 'ReturnStatus');
  lv_pick_wave_message:=pljson_ext.get_string(obj, 'ReturnMessage');
------------------------------------------------------------------------------------
-- Update Response Object:
BEGIN
UPDATE xx_wms_ship_batch_dtls_tb
SET
release_pick_wave_status =lv_pick_wave_status,
release_pick_wave_message =lv_pick_wave_message,
release_pick_wave_date=TO_CHAR(SYSDATE,'DD-MON-YYYY HH24:MI:SS'),
last_update_date=TO_CHAR(SYSDATE,'DD-MON-YYYY HH24:MI:SS')
WHERE 1=1
and batch_id=p_batch_id;
COMMIT;
write_log('Updated the response');
EXCEPTION WHEN OTHERS THEN
NULL;
END;

-- Update Response CLOB Object:
update xx_wms_ship_batch_dtls_tb set release_pick_wave_resp_obj=m_clob where 1=1 and batch_id=p_batch_id;
commit;

-- Free Temporary Memory:
dbms_lob.freetemporary(l_clob);

EXCEPTION
	WHEN utl_http.too_many_requests 
	THEN 
	write_log('Error Occured while executing the "release_pick_wave"');
    write_log('Error Code   :'||SQLCODE);
    write_log('Error Message:'||SQLERRM);
	utl_http.end_response(res);
    WHEN utl_http.end_of_body 
    THEN 
	write_log('Error Occured while executing the "release_pick_wave"');
    write_log('Error Code   :'||SQLCODE);
    write_log('Error Message:'||SQLERRM);
	utl_http.end_response(res);
	WHEN OTHERS 
	THEN 
	write_log('Error Occured while executing the "release_pick_wave"');
    write_log('Error Code   :'||SQLCODE);
    write_log('Error Message:'||SQLERRM);
	utl_http.end_response(res);
END release_pick_wave;

---procedure to confirm pick slip:
PROCEDURE confirm_pick_slip (p_id IN NUMBER,p_sales_order IN VARCHAR2,p_batch_id IN VARCHAR2,p_item_number IN VARCHAR2,
                            p_wms_shipped_qty IN NUMBER,p_wms_shipped_date IN VARCHAR2)					
AS

  req utl_http.req;
  res utl_http.resp;

  l_text        VARCHAR2(32767);
  l_clob        CLOB;
  content       CLOB;
  lv_status     VARCHAR2(240) :=NULL;
  lv_name       VARCHAR2(240) :=NULL;
  lv_message    VARCHAR2(4000):=NULL;
  lv_batch_id   NUMBER;

BEGIN

   content:=xx_wms_int_pkg.get_cnf_pickslip_req_payload(p_id=>p_id,
                                                        p_sales_order=>p_sales_order,
                                                        p_batch_id=>p_batch_id,
														p_item_number=>p_item_number,
														p_wms_shipped_qty=>p_wms_shipped_qty,
														p_wms_shipped_date=>p_wms_shipped_date);



-- If using HTTPS, open a wallet containing the trusted root certificate.
  utl_http.set_wallet (path=>c_wallet_path,password=>c_wallet_pwd);

 -- Make a HTTP request and get the response. 	
  req := utl_http.begin_request (url=>c_cps_url,
                                 method=>c_cps_http_method,
								 http_version=>c_cps_http_version);

  utl_http.set_header(req, 'content-type'  , c_cps_content_type); 
  utl_http.set_header(req, 'Content-Length', LENGTH(content));

    --Specify fusion user's username and password
    utl_http.set_authentication (req,c_username,c_password);

  utl_http.write_text(req, content);
  res := utl_http.get_response(req);

  write_log('Request:');
  write_log('--------');
  write_log(content);

-------------------------------------------------------------  
 -- Build a CLOB variable to hold web service response
        dbms_lob.createtemporary(l_clob, FALSE );
        dbms_lob.open(l_clob, dbms_lob.lob_readwrite );

         write_log('Response:');
         write_log('--------');
BEGIN
LOOP
   -- Copy the web service response body
   -- in a buffer string variable l_text
   utl_http.read_text(res, l_text, 32766);
   write_log(l_text);

   -- Append data from l_text to CLOB variable
dbms_lob.writeappend(l_clob, length(l_text), l_text);

END LOOP;
EXCEPTION
       WHEN OTHERS THEN
          --  Exit loop without exception
          --  when end-of-body is reached
          IF SQLCODE <> -29266 THEN
             RAISE;
          END IF;
END;

utl_http.end_response(res);

update xx_wms_ship_line_dtls_tb set confirm_pick_slip_resp_obj=l_clob where 1=1 and id=p_id AND batch_id=p_batch_id;
commit;

write_log('Updated the response');

---Parse Json Items:
BEGIN
cps_parse_json_items(p_id=>p_id,p_batch_id=>p_batch_id);
END;

write_log('Parse json items');

dbms_lob.freetemporary(l_clob);

EXCEPTION
	WHEN utl_http.too_many_requests 
	THEN 
	write_log('Error occured while executing the "confirm_pick_slip"');
    write_log('Error Code   :'||SQLCODE);
    write_log('Error Message:'||SQLERRM);
	utl_http.end_response(res);
    WHEN utl_http.end_of_body 
    THEN 
	write_log('Error occured while executing the "confirm_pick_slip"');
    write_log('Error Code   :'||SQLCODE);
    write_log('Error Message:'||SQLERRM);
	utl_http.end_response(res);
	WHEN OTHERS 
	THEN 
	write_log('Error occured while executing the "confirm_pick_slip"');
    write_log('Error Code   :'||SQLCODE);
    write_log('Error Message:'||SQLERRM);
	utl_http.end_response(res);
END confirm_pick_slip;

-- procedure to ship confirm:
PROCEDURE ship_confirm(p_id IN NUMBER,p_sales_order_number IN VARCHAR2,p_batch_id IN VARCHAR2,p_shipment_number IN VARCHAR2)
AS

  req utl_http.req;
  res utl_http.resp;

  l_text     VARCHAR2(32767);
  l_clob     CLOB;
  content    CLOB;

  lv_warehouse_code  VARCHAR2(50):=NULL;


BEGIN

-- get warehouse_code:
BEGIN
SELECT UNIQUE warehouse_code
INTO lv_warehouse_code
FROM xx_fusion_so_dtls_tb
WHERE 1=1
AND order_number=p_sales_order_number;
EXCEPTION WHEN OTHERS THEN
lv_warehouse_code:=NULL;
END;

content:='{
"Action": "CONFIRM"'
||',"Organization":"'||lv_warehouse_code||'"'
||',"ShipmentName":"'||p_shipment_number||'"'
||'}';

-- If using HTTPS, open a wallet containing the trusted root certificate.
  utl_http.set_wallet (path=>c_wallet_path,password=>c_wallet_pwd);

 -- Make a HTTP request and get the response. 	
  req := utl_http.begin_request (url=>c_sc_url,
                                 method=>c_sc_http_method,
								 http_version=>c_sc_http_version);

  utl_http.set_header(req, 'content-type'  , c_sc_content_type); 
  utl_http.set_header(req, 'Content-Length', LENGTH(content));

    --Specify fusion user's username and password
    utl_http.set_authentication (req,c_username,c_password);

  utl_http.write_text(req, content);
  res := utl_http.get_response(req);

  write_log('Request:');
  write_log('--------');
  write_log(content);

-------------------------------------------------------------  
 -- Build a CLOB variable to hold web service response
        dbms_lob.createtemporary(l_clob, FALSE );
        dbms_lob.open(l_clob, dbms_lob.lob_readwrite );

         write_log('Response:');
         write_log('--------');
BEGIN
LOOP
   -- Copy the web service response body
   -- in a buffer string variable l_text
   utl_http.read_text(res, l_text, 32766);
   write_log(l_text);

   -- Append data from l_text to CLOB variable
dbms_lob.writeappend(l_clob, length(l_text), l_text);

END LOOP;
EXCEPTION
       WHEN OTHERS THEN
          --  Exit loop without exception
          --  when end-of-body is reached
          IF SQLCODE <> -29266 THEN
             RAISE;
          END IF;
END;

utl_http.end_response(res);


update xx_wms_ship_line_dtls_tb set ship_confirm_resp_obj=l_clob where 1=1 and id=p_id and sales_order=p_sales_order_number AND batch_id=p_batch_id;
commit;

write_log('Updated the response');

---Parse Json Items:
BEGIN
sc_parse_json_items(p_id=>p_id,p_sales_order_number=>p_sales_order_number,p_batch_id=>p_batch_id);
END;

write_log('Parse json items');

dbms_lob.freetemporary(l_clob);

EXCEPTION
	WHEN utl_http.too_many_requests 
	THEN 
	write_log('Error Occured while executing the "ship_confirm"');
    write_log('Error Code   :'||SQLCODE);
    write_log('Error Message:'||SQLERRM);
	utl_http.end_response(res);
    WHEN utl_http.end_of_body 
    THEN 
	write_log('Error Occured while executing the "ship_confirm"');
    write_log('Error Code   :'||SQLCODE);
    write_log('Error Message:'||SQLERRM);
	utl_http.end_response(res);
	WHEN OTHERS 
	THEN 
	write_log('Error Occured while executing the "ship_confirm"');
    write_log('Error Code   :'||SQLCODE);
    write_log('Error Message:'||SQLERRM);
	utl_http.end_response(res);
END ship_confirm;


---Pick Slip Details Lines:
PROCEDURE pick_slip_details_lines(p_pick_slip_number IN VARCHAR2,p_item_number IN VARCHAR2,p_id IN NUMBER)
AS
  req utl_http.req;
  res utl_http.resp;

  l_text               VARCHAR2(32767);
  l_clob               CLOB;
  lv_url               VARCHAR2(4000):=NULL;

   obj                   pljson       ;

BEGIN

   lv_url:=c_instance_url||'/fscmRestApi/resources/11.13.18.05/pickSlipDetails/'||p_pick_slip_number||'/child/pickLines?fields=PickSlip,Item,MovementRequest,RequestedQuantity,Customer,ShipToLocation&onlyData=true&q=Item='||p_item_number;

   write_log('url:'||lv_url);

-- If using HTTPS, open a wallet containing the trusted root certificate.
  utl_http.set_wallet (path=>c_wallet_path,password=>c_wallet_pwd);

 -- Make a HTTP request and put the response. 	
  req := utl_http.begin_request (url=>lv_url,method=>'GET',http_version=>c_gps_http_version);

  utl_http.set_authentication (req,c_username,c_password);

  res := utl_http.get_response(req);

-------------------------------------------------------------  
 -- Build a CLOB variable to hold web service response
        dbms_lob.createtemporary(l_clob, FALSE );
        dbms_lob.open(l_clob, dbms_lob.lob_readwrite );

         write_log('Response:');
         write_log('--------');
BEGIN
LOOP
   -- Copy the web service response body
   -- in a buffer string variable l_text
   utl_http.read_text(res, l_text, 32766);
   write_log(l_text);

   -- Append data from l_text to CLOB variable
dbms_lob.writeappend(l_clob, length(l_text), l_text);

END LOOP;
EXCEPTION
       WHEN OTHERS THEN
          --  Exit loop without exception
          --  when end-of-body is reached
          IF SQLCODE <> -29266 THEN
             RAISE;
          END IF;
END;

utl_http.end_response(res);

  ---parse it into a pljson object:
  obj := pljson(l_clob);

  --then modify the object:
  pljson_ext.remove(obj, 'links');

  --finally, update the clob and commit:
  dbms_lob.trim(l_clob, 0); --empty the lob
  obj.to_clob(l_clob);
------------------------------------------------------------------------------------
BEGIN
INSERT INTO XX_FUSION_PICK_SLIP_DTLS_TEMP_TB
select p_id,PickSlip,MovementRequest batch_id,MovementRequest picking_batch_name,Item,RequestedQuantity,Customer,ShipToLocation
from table(
pljson_table.json_table(l_clob,
pljson_varray('items[*].PickSlip',
              'items[*].Item',
			  'items[*].MovementRequest',
			  'items[*].RequestedQuantity',
			  'items[*].Customer',
			  'items[*].ShipToLocation'),
pljson_varray('PickSlip','Item','MovementRequest','RequestedQuantity','Customer','ShipToLocation'),
table_mode => 'nested')
);
COMMIT;
EXCEPTION WHEN OTHERS THEN
NULL;
END;

dbms_lob.freetemporary(l_clob);

EXCEPTION
	WHEN utl_http.too_many_requests 
	THEN 

	write_log('Error Occured while executing the "pick_slip_details_lines"');
    write_log('Error Code   :'||SQLCODE);
    write_log('Error Message:'||SQLERRM);
	utl_http.end_response(res);

    WHEN utl_http.end_of_body 
    THEN 

	write_log('Error Occured while executing the "pick_slip_details_lines"');
    write_log('Error Code   :'||SQLCODE);
    write_log('Error Message:'||SQLERRM);
	utl_http.end_response(res);

	WHEN OTHERS 
	THEN 

	write_log('Error Occured while executing the "pick_slip_details_lines"');
    write_log('Error Code   :'||SQLCODE);
    write_log('Error Message:'||SQLERRM);
	utl_http.end_response(res);
END pick_slip_details_lines;

---Pick Slip Details Headers:
PROCEDURE pick_slip_details_headers(p_sales_order_number IN VARCHAR2,p_item_number IN VARCHAR2,p_id IN NUMBER)
AS

  req utl_http.req;
  res utl_http.resp;

  l_text               VARCHAR2(32767);
  l_clob               CLOB;
  lv_url               VARCHAR2(4000):=NULL;

  lv_pick_slip_number  VARCHAR2(400):=NULL;
   obj                   pljson       ;

BEGIN

   lv_url:=c_instance_url||'/fscmRestApi/resources/11.13.18.05/pickSlipDetails?q=Order='||p_sales_order_number||'&fields=PickSlip,PickWave,MovementRequest&onlyData=True';

   write_log('url:'||lv_url);

-- If using HTTPS, open a wallet containing the trusted root certificate.
  utl_http.set_wallet (path=>c_wallet_path,password=>c_wallet_pwd);

 -- Make a HTTP request and put the response. 	
  req := utl_http.begin_request (url=>lv_url,method=>'GET',http_version=>c_gps_http_version);

  utl_http.set_authentication (req,c_username,c_password);

  res := utl_http.get_response(req);

-------------------------------------------------------------  
 -- Build a CLOB variable to hold web service response
        dbms_lob.createtemporary(l_clob, FALSE );
        dbms_lob.open(l_clob, dbms_lob.lob_readwrite );

         write_log('Response:');
         write_log('--------');
BEGIN
LOOP
   -- Copy the web service response body
   -- in a buffer string variable l_text
   utl_http.read_text(res, l_text, 32766);
   write_log(l_text);

   -- Append data from l_text to CLOB variable
dbms_lob.writeappend(l_clob, length(l_text), l_text);

END LOOP;
EXCEPTION
       WHEN OTHERS THEN
          --  Exit loop without exception
          --  when end-of-body is reached
          IF SQLCODE <> -29266 THEN
             RAISE;
          END IF;
END;

utl_http.end_response(res);

  ---parse it into a pljson object:
  obj := pljson(l_clob);

  --then modify the object:
  pljson_ext.remove(obj, 'links');

  --finally, update the clob and commit:
  dbms_lob.trim(l_clob, 0); --empty the lob
  obj.to_clob(l_clob);
------------------------------------------------------------------------------------
BEGIN
select UNIQUE LISTAGG(PickSlip, ',') 
INTO lv_pick_slip_number
from table(
pljson_table.json_table(l_clob,
pljson_varray('items[*].PickSlip'),
pljson_varray('PickSlip'),
table_mode => 'nested')
);
EXCEPTION WHEN OTHERS THEN
NULL;
END;
------------------------------------------------------------------------------------
DELETE XX_FUSION_PICK_SLIP_DTLS_TEMP_TB;
COMMIT;
------------------------------------------------------------------------------------

FOR m IN (
SELECT DISTINCT column_value FROM (SELECT * FROM 
  TABLE(comma_to_table(lv_pick_slip_number))))
LOOP
pick_slip_details_lines(p_pick_slip_number=>m.column_value,p_item_number=>p_item_number,p_id=>p_id);
END LOOP; 
------------------------------------------------------------------------------------
dbms_lob.freetemporary(l_clob);

EXCEPTION
	WHEN utl_http.too_many_requests 
	THEN 

	write_log('Error Occured while executing the "pick_slip_details_headers"');
    write_log('Error Code   :'||SQLCODE);
    write_log('Error Message:'||SQLERRM);
	utl_http.end_response(res);

    WHEN utl_http.end_of_body 
    THEN 

	write_log('Error Occured while executing the "pick_slip_details_headers"');
    write_log('Error Code   :'||SQLCODE);
    write_log('Error Message:'||SQLERRM);
	utl_http.end_response(res);

	WHEN OTHERS 
	THEN 

	write_log('Error Occured while executing the "pick_slip_details_headers"');
    write_log('Error Code   :'||SQLCODE);
    write_log('Error Message:'||SQLERRM);
	utl_http.end_response(res);
END pick_slip_details_headers;

 -- create shipment:
 procedure create_shipment(p_id IN NUMBER,p_sales_order IN VARCHAR2,p_batch_id IN VARCHAR2,p_item_number IN VARCHAR2,p_shipment_number OUT VARCHAR2)
 is 
  -- soap requests message
  l_soap_req_msg                varchar2(32767):=xx_wms_int_pkg.get_shipment_lines_payload(p_sales_order=>p_sales_order,p_batch_id=>p_batch_id,p_item_number=>p_item_number);

  -- http request/response
  http_req                      utl_http.req;
  http_resp                     utl_http.resp;
  l_clob                        clob;
  l_text                        varchar2(32767);
  lv_shipment_no                varchar2(240):=NULL;
  lv_return_status              varchar2(240):=NULL;


BEGIN

  write_log('l_soap_req_msg:'||l_soap_req_msg );

  -- set wallet directory
    utl_http.set_wallet (path=>c_wallet_path,password=>c_wallet_pwd);

  -- WSDL url for fusion report web service is placed in UTL_HTTP.begin_request, web service handler as 'POST' and protocol version HTTP/1.1
    http_req := utl_http.begin_request (url=>c_cs_wsdl_url,
	                                    method=>c_cs_http_method,
										http_version=>c_cs_http_version);

    utl_http.set_header (http_req, 'Content-Type'  , c_cs_content_type);--type of input data i.e. request payload
    utl_http.set_header (http_req, 'Content-Length', length (l_soap_req_msg));
    utl_http.set_header (http_req, 'SOAPAction'    , c_cs_soap_action);
    utl_http.set_header (http_req, 'Connection'    , c_cs_connection);

  --Specify fusion user's username and password
    utl_http.set_authentication (http_req,c_username,c_password);

    utl_http.write_text (http_req, l_soap_req_msg);

  -- invoke request and get response.
    http_resp := utl_http.get_response (http_req);

    dbms_lob.createtemporary (l_clob, false);
    dbms_lob.open (l_clob, dbms_lob.lob_readwrite);


BEGIN
LOOP
   -- Copy the web service response body
   -- in a buffer string variable l_text
   utl_http.read_text(http_resp, l_text, 32766);
   write_log(l_text);

   -- Append data from l_text to CLOB variable
   dbms_lob.writeappend(l_clob, length(l_text), l_text);

END LOOP;
EXCEPTION
       WHEN OTHERS THEN
          --  Exit loop without exception
          --  when end-of-body is reached
          IF SQLCODE <> -29266 THEN
             RAISE;
          END IF;
END;

  utl_http.end_response (http_resp);    
--------------------------------------------------------------------------------------------------------------
 BEGIN
 select x.returnstatus,x.shipment
 INTO lv_return_status,lv_shipment_no
 from
  (select xmltype(l_clob) xml from dual) t,
   xmltable(
   xmlnamespaces (
     'http://schemas.xmlsoap.org/soap/envelope/' as "e"
	,'http://xmlns.oracle.com/apps/scm/shipping/shipConfirm/deliveries/shipmentLineService/types/' as "ns0"
	,'http://xmlns.oracle.com/apps/scm/shipping/shipConfirm/deliveries/shipmentLineService/' as "ns1"
   ),
   'e:Envelope/e:Body/ns0:AutocreateShipmentsResponse/ns0:result'
   passing t.xml
   columns
   returnstatus varchar2(100) path 'ns1:ReturnStatus',
   MessageCount varchar2(100) path 'ns1:MessageCount',
   Shipment     varchar2(100) path 'ns1:Shipment'
  ) x;
EXCEPTION WHEN OTHERS THEN
NULL;
END; 

-------------------------------------------------------
UPDATE xx_wms_ship_line_dtls_tb
SET shipment_number=lv_shipment_no,
    last_update_date=TO_CHAR(SYSDATE,'DD-MON-YYYY HH24:MI:SS'),
    status=(CASE WHEN UPPER(lv_return_status)='SUCCESS' THEN 'Shipment Created' ELSE 'Shipment not Created' END )
WHERE 1=1
AND id=p_id
AND batch_id=p_batch_id;
COMMIT;	
-------------------------------------------------------
p_shipment_number:=lv_shipment_no;

dbms_lob.freetemporary (l_clob);

EXCEPTION
	WHEN utl_http.too_many_requests 
	THEN 
	write_log('Error Occured while executing the "create_shipment"');
    write_log('Error Code   :'||SQLCODE);
    write_log('Error Message:'||SQLERRM);
	utl_http.end_response(http_resp);
    WHEN utl_http.end_of_body 
    THEN 
	write_log('Error Occured while executing the "create_shipment"');
    write_log('Error Code   :'||SQLCODE);
    write_log('Error Message:'||SQLERRM);
	utl_http.end_response(http_resp);
	WHEN OTHERS 
	THEN 
	write_log('Error Occured while executing the "create_shipment"');
    write_log('Error Code   :'||SQLCODE);
    write_log('Error Message:'||SQLERRM);
	utl_http.end_response(http_resp);
END create_shipment;	  	


-- Update Shipment Line:
 procedure update_shipment_line(p_id IN NUMBER,p_sales_order in varchar2,p_batch_id in varchar2,p_item_number in varchar2,p_shipment_line IN VARCHAR2,p_uom IN VARCHAR2,p_quantity IN NUMBER)

 is 
  -- soap requests message
  l_soap_req_msg           varchar2(32767):=null;  
  lv_line_no               varchar2(4000):=xx_wms_int_pkg.get_shipment_lines(p_sales_order=>p_sales_order,p_batch_id=>p_batch_id,p_item_number=>p_item_number);

  -- http request/response
  http_req                 utl_http.req;
  http_resp                utl_http.resp;
  l_clob                   clob;
  l_text                   varchar2(32767);


    lv_return_status      varchar2(240):=NULL;
	lv_message_count      NUMBER:=0;
	lv_shipment_line      varchar2(240):=NULL;
	lv_message_text       varchar2(240):=NULL;


BEGIN

--- Payload:
l_soap_req_msg:=
'<soapenv:Envelope xmlns:ship="http://xmlns.oracle.com/apps/scm/shipping/shipConfirm/deliveries/shipmentLineService/" xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:typ="http://xmlns.oracle.com/apps/scm/shipping/shipConfirm/deliveries/shipmentLineService/types/">
   <soapenv:Header>
   </soapenv:Header>
   <soapenv:Body>
      <typ:UpdateShipmentLinesAsync>
         <typ:apiVersionNumber>1.0</typ:apiVersionNumber>
         <typ:ShipmentLineInformation>
            <ship:ShipmentLine>'||p_shipment_line||'</ship:ShipmentLine>
            <ship:ShippedQuantity unitCode="'||p_uom||'">'||p_quantity||'</ship:ShippedQuantity>
         </typ:ShipmentLineInformation>
      </typ:UpdateShipmentLinesAsync>
   </soapenv:Body>
</soapenv:Envelope>';

  -- set wallet directory
    utl_http.set_wallet (path=>c_wallet_path,password=>c_wallet_pwd);

  -- WSDL url for fusion report web service is placed in UTL_HTTP.begin_request, web service handler as 'POST' and protocol version HTTP/1.1
    http_req := utl_http.begin_request (url=>c_us_wsdl_url,
	                                    method=>c_us_http_method,
										http_version=>c_us_http_version);

    utl_http.set_header (http_req, 'Content-Type'  , c_us_content_type);--type of input data i.e. request payload
    utl_http.set_header (http_req, 'Content-Length', length (l_soap_req_msg));
    utl_http.set_header (http_req, 'SOAPAction'    , c_us_soap_action);
    utl_http.set_header (http_req, 'Connection'    , c_us_connection);

  --Specify fusion user's username and password
    utl_http.set_authentication (http_req,c_username,c_password);

    utl_http.write_text (http_req, l_soap_req_msg);

  -- invoke request and get response.
    http_resp := utl_http.get_response (http_req);

    dbms_lob.createtemporary (l_clob, false);
    dbms_lob.open (l_clob, dbms_lob.lob_readwrite);


BEGIN
LOOP
   -- Copy the web service response body
   -- in a buffer string variable l_text
   utl_http.read_text(http_resp, l_text, 32766);
   write_log(l_text);

   -- Append data from l_text to CLOB variable
   dbms_lob.writeappend(l_clob, length(l_text), l_text);

END LOOP;
EXCEPTION
       WHEN OTHERS THEN
          --  Exit loop without exception
          --  when end-of-body is reached
          IF SQLCODE <> -29266 THEN
             RAISE;
          END IF;
END;

  utl_http.end_response (http_resp);    
--------------------------------------------------------------------------------------------------------------
 BEGIN
  select x.returnstatus,x.MessageCount,x.ShipmentLine,MessageText
  INTO lv_return_status,lv_message_count,lv_shipment_line,lv_message_text
 from
  (select xmltype(l_clob) xml from dual) t,
 xmltable(
   xmlnamespaces (
     'http://schemas.xmlsoap.org/soap/envelope/' as "s"
	,'http://xmlns.oracle.com/apps/scm/shipping/shipConfirm/deliveries/shipmentLineService/types/' as "e1"
	,'http://xmlns.oracle.com/apps/scm/shipping/shipConfirm/deliveries/shipmentLineService/types/' as "e2"
	,'http://xmlns.oracle.com/apps/scm/shipping/shipConfirm/deliveries/shipmentLineService/' as "e3"
   ),
   's:Envelope/s:Body/e1:UpdateShipmentLinesAsyncResponse/e1:result'
   passing t.xml
   columns
   returnstatus    varchar2(100) path 'e3:ReturnStatus',
   MessageCount    varchar2(100) path 'e3:MessageCount',
   ShipmentLine    varchar2(100) path 'e3:Message/e3:ShipmentLine',
   MessageText     varchar2(100) path 'e3:Message/e3:MessageText'
  ) x;
EXCEPTION WHEN OTHERS THEN
NULL;
END; 

-------------------------------------------------------
UPDATE xx_wms_ship_line_dtls_tb
SET ship_confirm_message=lv_shipment_line||'-'||lv_message_text,
    last_update_date=TO_CHAR(SYSDATE,'DD-MON-YYYY HH24:MI:SS'),
    status=(CASE WHEN UPPER(lv_return_status)='SUCCESS' THEN 'Update Shipment' ELSE 'Update Shipment Failed' END)
WHERE 1=1
AND id=p_id
AND batch_id=p_batch_id;
COMMIT;	
-------------------------------------------------------

dbms_lob.freetemporary (l_clob);

EXCEPTION
	WHEN utl_http.too_many_requests 
	THEN 
	write_log('Error Occured while executing the "update_shipment_line"');
    write_log('Error Code   :'||SQLCODE);
    write_log('Error Message:'||SQLERRM);
	utl_http.end_response(http_resp);
    WHEN utl_http.end_of_body 
    THEN 
	write_log('Error Occured while executing the "update_shipment_line"');
    write_log('Error Code   :'||SQLCODE);
    write_log('Error Message:'||SQLERRM);
	utl_http.end_response(http_resp);
	WHEN OTHERS 
	THEN 
	write_log('Error Occured while executing the "update_shipment_line"');
    write_log('Error Code   :'||SQLCODE);
    write_log('Error Message:'||SQLERRM);
	utl_http.end_response(http_resp);
END update_shipment_line;	

-- Update Shipment:
Procedure update_shipment (p_id IN NUMBER,p_sales_order IN VARCHAR2,p_batch_id IN VARCHAR2,p_item_number IN VARCHAR2)
AS

  req utl_http.req;
  res utl_http.resp;

  l_text     VARCHAR2(32767);
  l_clob     CLOB;
  lv_url     VARCHAR2(4000):=NULL;
  obj        pljson;

BEGIN

   lv_url:=c_instance_url||'/fscmRestApi/resources/11.13.18.05/shipmentLines/?fields=ShipmentLine,RequestedQuantityUOM,PickedQuantity&q=Order='||p_sales_order||';PickWaveId='||p_batch_id||';Item='||p_item_number||';LineStatus=Staged';

   write_log('url:'||lv_url);

-- If using HTTPS, open a wallet containing the trusted root certificate.
  utl_http.set_wallet (path=>c_wallet_path,password=>c_wallet_pwd);

 -- Make a HTTP request and put the response. 	
  req := utl_http.begin_request (url=>lv_url,method=>'GET',http_version=>c_gps_http_version);

  utl_http.set_authentication (req,c_username,c_password);

  res := utl_http.get_response(req);

-------------------------------------------------------------  
 -- Build a CLOB variable to hold web service response
        dbms_lob.createtemporary(l_clob, FALSE );
        dbms_lob.open(l_clob, dbms_lob.lob_readwrite );

         write_log('Response:');
         write_log('--------');
BEGIN
LOOP
   -- Copy the web service response body
   -- in a buffer string variable l_text
   utl_http.read_text(res, l_text, 32766);
   write_log(l_text);

   -- Append data from l_text to CLOB variable
dbms_lob.writeappend(l_clob, length(l_text), l_text);

END LOOP;
EXCEPTION
       WHEN OTHERS THEN
          --  Exit loop without exception
          --  when end-of-body is reached
          IF SQLCODE <> -29266 THEN
             RAISE;
          END IF;
END;

utl_http.end_response(res);

  ---parse it into a pljson object:
  obj := pljson(l_clob);

  --then modify the object:
  pljson_ext.remove(obj, 'links');

  --finally, update the clob and commit:
  dbms_lob.trim(l_clob, 0); --empty the lob
  obj.to_clob(l_clob);


DELETE xx_fusion_shipment_dtls_temp_tb;
COMMIT;

INSERT INTO xx_fusion_shipment_dtls_temp_tb
select ShipmentLine,uom,PickedQuantity
from table(
pljson_table.json_table(l_clob,
pljson_varray('items[*].ShipmentLine','items[*].RequestedQuantityUOM','items[*].PickedQuantity'),
pljson_varray('ShipmentLine','UOM','PickedQuantity'),
table_mode => 'nested'));
COMMIT;

FOR k IN (SELECT * FROM xx_fusion_shipment_dtls_temp_tb WHERE 1=1) LOOP
-- Update Shipment Line:
BEGIN
update_shipment_line(p_id=>p_id,
                     p_sales_order=>p_sales_order,
					 p_batch_id=>p_batch_id,
					 p_item_number=>p_item_number,
					 p_shipment_line=>k.shipment_line,
					 p_uom=>k.uom,
					 p_quantity=>k.picked_quantity);
END;
END LOOP;

DELETE xx_fusion_shipment_dtls_temp_tb;
COMMIT;

dbms_lob.freetemporary (l_clob);

EXCEPTION
	WHEN utl_http.too_many_requests 
	THEN 

	write_log('Error Occured while executing the "update_shipment"');
    write_log('Error Code   :'||SQLCODE);
    write_log('Error Message:'||SQLERRM);
	utl_http.end_response(res);

    WHEN utl_http.end_of_body 
    THEN 

	write_log('Error Occured while executing the "update_shipment"');
    write_log('Error Code   :'||SQLCODE);
    write_log('Error Message:'||SQLERRM);
	utl_http.end_response(res);

	WHEN OTHERS 
	THEN 

	write_log('Error Occured while executing the "update_shipment"');
    write_log('Error Code   :'||SQLCODE);
    write_log('Error Message:'||SQLERRM);
	utl_http.end_response(res);

END update_shipment;

-- Update Main Table:
Procedure update_main_table (p_sales_order IN VARCHAR2,p_item_number IN VARCHAR2)
AS

BEGIN

FOR i IN (SELECT UNIQUE sales_order,item_number,line_number,SUM(fusion_picked_quantity) picked_qty,SUM(fusion_shipped_quantity) shipped_qty
          FROM xx_wms_ship_line_dtls_tb 
		  WHERE 1=1 
		  AND sales_order=p_sales_order 
		  AND item_number=p_item_number
		  GROUP BY sales_order,item_number,line_number)
LOOP

----------------------------------
UPDATE xx_fusion_so_dtls_tb
SET picked_qty=i.picked_qty,
    shipped_qty=i.shipped_qty
WHERE 1=1
AND order_number=i.sales_order
AND oracle_code=i.item_number
AND line_number=i.line_number;
COMMIT;
----------------------------------
END LOOP;

END update_main_table;


---Receipt creation against RMA
PROCEDURE create_receipt_for_rma(p_id in number,p_sales_order_number in varchar2,p_item_number in varchar2,p_wms_shipped_qty in number,
                                  p_wms_shipped_date in varchar2)
AS

  req utl_http.req;
  res utl_http.resp;

  l_text         VARCHAR2(32767);
  l_clob         CLOB;
  content        CLOB;
  lv_status      VARCHAR2(240) :=NULL;
  lv_name        VARCHAR2(240) :=NULL;
  lv_message     VARCHAR2(4000):=NULL;
  lv_success_tag VARCHAR2(4000):=NULL;

  obj pljson;

BEGIN

   content:=xx_wms_int_pkg.get_receipt_req_payload(p_id=>p_id,
                           p_sales_order_number=>p_sales_order_number,
						   p_item_number=>p_item_number,
						   p_wms_shipped_qty=>p_wms_shipped_qty,
                           p_wms_shipped_date=>p_wms_shipped_date);

   -- If using HTTPS, open a wallet containing the trusted root certificate.
  utl_http.set_wallet (path=>c_wallet_path,password=>c_wallet_pwd);

   -- Make a HTTP request and get the response. 	
   req := utl_http.begin_request (url=>c_rc_a_rma_url,
                                  method=>c_rc_a_rma_http_method,
								  http_version=>c_rc_a_rma_http_version);

  utl_http.set_header(req, 'content-type'  , c_rc_a_rma_content_type); 
  utl_http.set_header(req, 'Content-Length', LENGTH(content));

    --Specify fusion user's username and password
    utl_http.set_authentication (req,c_username,c_password);

  utl_http.write_text(req, content);
  res := utl_http.get_response(req);

  write_log('Request:');
  write_log('--------');
  write_log(content);

-------------------------------------------------------------  
 -- Build a CLOB variable to hold web service response
        dbms_lob.createtemporary(l_clob, FALSE );
        dbms_lob.open(l_clob, dbms_lob.lob_readwrite );

         write_log('Response:');
         write_log('--------');
BEGIN
LOOP
   -- Copy the web service response body
   -- in a buffer string variable l_text
   utl_http.read_text(res, l_text, 32766);
   write_log(l_text);

   -- Append data from l_text to CLOB variable
dbms_lob.writeappend(l_clob, length(l_text), l_text);

END LOOP;
EXCEPTION
       WHEN OTHERS THEN
          --  Exit loop without exception
          --  when end-of-body is reached
          IF SQLCODE <> -29266 THEN
             RAISE;
          END IF;
END;

utl_http.end_response(res);

  ---parse it into a pljson object:
  obj := pljson(l_clob);

  pljson_ext.remove(obj, 'links');

UPDATE xx_wms_ship_line_dtls_tb
SET 

    receipt_request_payload=content                                           ,
	receipt_resp_object    =l_clob                                            ,
    receipt_header_id      =pljson_ext.get_number(obj, 'ReceiptHeaderId')     ,
    receipt_number         =pljson_ext.get_string(obj, 'ReceiptNumber')       ,
    receipt_date           =TO_CHAR(SYSDATE,'DD-MON-YYYY HH24:MI:SS')         ,
    expected_receipt_date  =pljson_ext.get_string(obj, 'ExpectedReceiptDate') ,
    group_id               =pljson_ext.get_number(obj, 'GroupId')             ,
    processing_status_code =pljson_ext.get_string(obj, 'ProcessingStatusCode'),
    gl_date                =pljson_ext.get_string(obj, 'GLDate')              ,
    return_status          =pljson_ext.get_string(obj, 'ReturnStatus')        ,
    rma_source_system_id   =pljson_ext.get_number(obj, 'RMASourceSystemId')   ,
    rma_source_system_name =pljson_ext.get_string(obj, 'RMASourceSystemName') ,
    last_update_date       =TO_CHAR(SYSDATE,'DD-MON-YYYY HH24:MI:SS')         ,
	quantity_received      =(CASE WHEN pljson_ext.get_string(obj, 'ReturnStatus')='SUCCESS' THEN ra_quantity_expected ELSE NULL END),
	status                 =(CASE WHEN pljson_ext.get_string(obj, 'ReturnStatus')='SUCCESS' THEN 'Receipt Created' ELSE 'Receipt not created' END)

WHERE 1=1
AND id=p_id
AND sales_order=p_sales_order_number;
COMMIT;  

-- Free Temprary Memory:
dbms_lob.freetemporary(l_clob);


EXCEPTION
	WHEN utl_http.too_many_requests 
	THEN 
	write_log('Error Occured while executing the "create_receipt_for_rma"');
    write_log('Error Code   :'||SQLCODE);
    write_log('Error Message:'||SQLERRM);
	utl_http.end_response(res);
    WHEN utl_http.end_of_body 
    THEN 
	write_log('Error Occured while executing the "create_receipt_for_rma"');
    write_log('Error Code   :'||SQLCODE);
    write_log('Error Message:'||SQLERRM);
	utl_http.end_response(res);
	WHEN OTHERS 
	THEN 
	write_log('Error Occured while executing the "create_receipt_for_rma"');
    write_log('Error Code   :'||SQLCODE);
    write_log('Error Message:'||SQLERRM);
	utl_http.end_response(res);
END create_receipt_for_rma;

-- send receipt confirmation
 procedure send_receipt_confirmation(  p_organization_id    IN NUMBER,
                                     p_source_system_id   IN NUMBER,
                                     p_receipt_header_id  IN NUMBER,
									 p_org_code           IN VARCHAR2,
									 p_source_system_name IN VARCHAR2)
 is 
  -- soap requests message
  l_soap_req_msg                varchar2(32767):=xx_wms_int_pkg.receipt_confirm_req_payload
                                    (p_organization_id    =>p_organization_id,
                                     p_source_system_id   =>p_source_system_id,
                                     p_receipt_header_id  =>p_receipt_header_id,
									 p_org_code           =>p_org_code,
									 p_source_system_name =>p_source_system_name);

  -- http request/response
  http_req                      utl_http.req;
  http_resp                     utl_http.resp;
  l_clob                        clob;
  l_text                        varchar2(32767);


BEGIN
  -- set wallet directory
    utl_http.set_wallet (path=>c_wallet_path,password=>c_wallet_pwd);

  -- WSDL url for fusion report web service is placed in UTL_HTTP.begin_request, web service handler as 'POST' and protocol version HTTP/1.1
    http_req := utl_http.begin_request (url=>c_src_url,
	                                    method=>c_src_http_method,
										http_version=>c_src_http_version);

    utl_http.set_header (http_req, 'Content-Type'  , c_src_content_type);--type of input data i.e. request payload
    utl_http.set_header (http_req, 'Content-Length', length (l_soap_req_msg));
    utl_http.set_header (http_req, 'SOAPAction'    , c_src_soap_action);
    utl_http.set_header (http_req, 'Connection'    , c_src_connection);

  --Specify fusion user's username and password
    utl_http.set_authentication (http_req,c_username,c_password);

    utl_http.write_text (http_req, l_soap_req_msg);

  -- invoke request and get response.
    http_resp := utl_http.get_response (http_req);

    dbms_lob.createtemporary (l_clob, false);
    dbms_lob.open (l_clob, dbms_lob.lob_readwrite);


BEGIN
LOOP
   -- Copy the web service response body
   -- in a buffer string variable l_text
   utl_http.read_text(http_resp, l_text, 32766);
   write_log(l_text);

   -- Append data from l_text to CLOB variable
   dbms_lob.writeappend(l_clob, length(l_text), l_text);

END LOOP;
EXCEPTION
       WHEN OTHERS THEN
          --  Exit loop without exception
          --  when end-of-body is reached
          IF SQLCODE <> -29266 THEN
             RAISE;
          END IF;
END;

  utl_http.end_response (http_resp);

  dbms_lob.freetemporary (l_clob);

EXCEPTION
	WHEN utl_http.too_many_requests 
	THEN 
	write_log('Error Occured while executing the "send_receipt_confirmation"');
    write_log('Error Code   :'||SQLCODE);
    write_log('Error Message:'||SQLERRM);
	utl_http.end_response(http_resp);
    WHEN utl_http.end_of_body 
    THEN 
	write_log('Error Occured while executing the "send_receipt_confirmation"');
    write_log('Error Code   :'||SQLCODE);
    write_log('Error Message:'||SQLERRM);
	utl_http.end_response(http_resp);
	WHEN OTHERS 
	THEN 
	write_log('Error Occured while executing the "send_receipt_confirmation"');
    write_log('Error Code   :'||SQLCODE);
    write_log('Error Message:'||SQLERRM);
	utl_http.end_response(http_resp);
END send_receipt_confirmation;

---Sales order flow:
PROCEDURE fusion_so_exec_flow
AS

lv_status                       VARCHAR2(240)  :=NULL;
lv_pick_slip_record_count       NUMBER:=0;
lv_wms_shipped_quantity         NUMBER:=0;
lv_pick_slip_number             VARCHAR2(240):=NULL;
lv_shipment_number              VARCHAR2(240):=NULL;
lv_batch_id                     NUMBER:=0;

BEGIN


-- Query:
FOR i IN (SELECT * FROM xx_wms_ship_dtls_vw WHERE 1=1 AND category_code='ORDER')
LOOP

lv_pick_slip_record_count:=0;
lv_wms_shipped_quantity:=0;

-- Get Pick Slip Details:
BEGIN
DELETE xx_fusion_pick_slip_dtls_temp_tb;
COMMIT;
xx_wms_int_pkg.pick_slip_details_headers(p_sales_order_number=>i.sales_order,
                                         p_item_number=>i.item_number,
										 p_id=>i.id);
END;

-- Get Pick Record Count:
BEGIN
SELECT COUNT(*)
INTO lv_pick_slip_record_count
FROM xx_fusion_pick_slip_dtls_temp_tb
WHERE 1=1
AND id=i.id;
EXCEPTION WHEN OTHERS THEN
lv_pick_slip_record_count:=0;
END;

lv_wms_shipped_quantity:=i.wms_shipped_quantity;

IF lv_pick_slip_record_count>0 THEN ------------- First

FOR m IN (SELECT UNIQUE batch_id,pick_slip_number,item_number,SUM(requested_quantity) requested_quantity
FROM xx_fusion_pick_slip_dtls_temp_tb
WHERE 1=1
AND id=i.id
GROUP BY batch_id,pick_slip_number,item_number)
LOOP

IF (m.requested_quantity>lv_wms_shipped_quantity AND lv_wms_shipped_quantity!=0) OR m.requested_quantity=lv_wms_shipped_quantity THEN
/**************************************************************************************************************************************/
-- Confirm Pick Slip:
BEGIN
xx_wms_int_pkg.confirm_pick_slip(p_id=>i.id,p_sales_order=>i.sales_order,p_batch_id=>m.batch_id,p_item_number=>m.item_number,p_wms_shipped_qty=>lv_wms_shipped_quantity,p_wms_shipped_date=>i.wms_shipped_date);
END;

--- Create Shipment:
BEGIN
xx_wms_int_pkg.create_shipment(p_id=>i.id,p_sales_order=>i.sales_order,p_batch_id=>m.batch_id,p_item_number=>m.item_number,p_shipment_number=>lv_shipment_number);
write_log('lv_shipment_number:'||lv_shipment_number);
END;

-- Update Shipment:
BEGIN
xx_wms_int_pkg.update_shipment(p_id=>i.id,p_sales_order=>i.sales_order,p_batch_id=>m.batch_id,p_item_number=>m.item_number);
END;

--- Ship Confirm:
BEGIN
xx_wms_int_pkg.ship_confirm(p_id=>i.id,p_sales_order_number=>i.sales_order,p_batch_id=>m.batch_id,p_shipment_number=>lv_shipment_number);
END;

--- Update Shipped Quantity:
UPDATE xx_wms_ship_line_dtls_tb
SET fusion_shipped_quantity=fusion_picked_quantity,
    last_update_date=TO_CHAR(SYSDATE,'DD-MON-YYYY HH24:MI:SS')
WHERE 1=1
AND id=i.id
AND batch_id=m.batch_id
AND status='Ship confirmed';
COMMIT;

-- Get Status:
lv_status:=NULL;
BEGIN
SELECT UNIQUE status INTO lv_status FROM xx_wms_ship_line_dtls_tb WHERE 1=1 AND id=i.id AND batch_id=m.batch_id;
EXCEPTION WHEN OTHERS THEN
lv_status:=NULL;
END;

--- Update Status:
UPDATE xx_wms_ship_hdr_dtls_tb
SET status='SUCCESS',
    last_update_date=TO_CHAR(SYSDATE,'DD-MON-YYYY HH24:MI:SS')
WHERE 1=1
AND id=i.id
AND status IN ('NEW','FAILED')
AND lv_status='Ship confirmed';
COMMIT;

--- Update Status:
UPDATE xx_wms_ship_hdr_dtls_tb
SET status='FAILED',
    last_update_date=TO_CHAR(SYSDATE,'DD-MON-YYYY HH24:MI:SS')
WHERE 1=1
AND id=i.id
AND status IN ('NEW','FAILED')
AND lv_status<>'Ship confirmed';
COMMIT;

BEGIN
update_main_table (p_sales_order=>i.sales_order,p_item_number=>m.item_number);
END;

lv_wms_shipped_quantity:=0;
-------------------------------------------------------------------------------------------------------------------------------------

ELSIF m.requested_quantity<lv_wms_shipped_quantity THEN

-- Confirm Pick Slip:
BEGIN
xx_wms_int_pkg.confirm_pick_slip(p_id=>i.id,p_sales_order=>i.sales_order,p_batch_id=>m.batch_id,p_item_number=>m.item_number,p_wms_shipped_qty=>m.requested_quantity,p_wms_shipped_date=>i.wms_shipped_date);
END;

--- Create Shipment:
BEGIN
xx_wms_int_pkg.create_shipment(p_id=>i.id,p_sales_order=>i.sales_order,p_batch_id=>m.batch_id,p_item_number=>m.item_number,p_shipment_number=>lv_shipment_number);
write_log('lv_shipment_number:'||lv_shipment_number);
END;

-- Update Shipment:
BEGIN
xx_wms_int_pkg.update_shipment (p_id=>i.id,p_sales_order=>i.sales_order,p_batch_id=>m.batch_id,p_item_number=>m.item_number);
END;

--- Ship Confirm:
BEGIN
xx_wms_int_pkg.ship_confirm(p_id=>i.id,p_sales_order_number=>i.sales_order,p_batch_id=>m.batch_id,p_shipment_number=>lv_shipment_number);
END;

--- Update Shipped Quantity:
UPDATE xx_wms_ship_line_dtls_tb
SET fusion_shipped_quantity=fusion_picked_quantity,
    last_update_date=TO_CHAR(SYSDATE,'DD-MON-YYYY HH24:MI:SS')
WHERE 1=1
AND id=i.id
AND batch_id=m.batch_id
AND status='Ship confirmed';
COMMIT;

BEGIN
update_main_table (p_sales_order=>i.sales_order,p_item_number=>m.item_number);
END;

lv_wms_shipped_quantity:=ABS(lv_wms_shipped_quantity-m.requested_quantity);
---------------------------------------------------------------------------------------------------------------------------------------------
IF lv_wms_shipped_quantity>0 THEN

-- Create Pick Wave:
lv_batch_id:=NULL;
BEGIN
xx_wms_int_pkg.create_pick_wave(p_id=>i.id,p_sales_order_number=>i.sales_order,p_batch_id =>lv_batch_id);
write_log('lv_batch_id:'||lv_batch_id);
END;

-- Release Pick Wave:
BEGIN
xx_wms_int_pkg.release_pick_wave(p_batch_id =>lv_batch_id);
END;

-- get pick slip number and shipment number:
lv_pick_slip_number  :=NULL;
lv_shipment_number   :=NULL;
BEGIN
xx_wms_int_pkg.get_pick_slip_details(p_batch_id =>lv_batch_id,
                                     p_pick_slip_number=>lv_pick_slip_number,
                                     p_shipment_number=>lv_shipment_number);
write_log('lv_pick_slip_number:'||lv_pick_slip_number);
write_log('lv_shipment_number:'||lv_shipment_number);
END;

-- Confirm Pick Slip:
BEGIN
xx_wms_int_pkg.confirm_pick_slip(p_id=>i.id,p_sales_order=>i.sales_order,p_batch_id=>lv_batch_id,p_item_number=>m.item_number,p_wms_shipped_qty=>lv_wms_shipped_quantity,p_wms_shipped_date=>i.wms_shipped_date);
END;

--- Ship Confirm:
BEGIN
xx_wms_int_pkg.ship_confirm(p_id=>i.id,p_sales_order_number=>i.sales_order,p_batch_id=>lv_batch_id,p_shipment_number=>lv_shipment_number);
END;

--- Update Shipped Quantity:
UPDATE xx_wms_ship_line_dtls_tb
SET fusion_shipped_quantity=fusion_picked_quantity,
    last_update_date=TO_CHAR(SYSDATE,'DD-MON-YYYY HH24:MI:SS')
WHERE 1=1
AND id=i.id
AND batch_id=lv_batch_id
AND status='Ship confirmed';
COMMIT;

-- Get Status:
lv_status:=NULL;
BEGIN
SELECT UNIQUE status INTO lv_status FROM xx_wms_ship_line_dtls_tb WHERE 1=1 AND id=i.id AND batch_id=lv_batch_id;
EXCEPTION WHEN OTHERS THEN
lv_status:=NULL;
END;

--- Update Status:
UPDATE xx_wms_ship_hdr_dtls_tb
SET status='SUCCESS',
    last_update_date=TO_CHAR(SYSDATE,'DD-MON-YYYY HH24:MI:SS')
WHERE 1=1
AND id=i.id
AND status IN ('NEW','FAILED')
AND lv_status='Ship confirmed';
COMMIT;

--- Update Status:
UPDATE xx_wms_ship_hdr_dtls_tb
SET status='FAILED',
    last_update_date=TO_CHAR(SYSDATE,'DD-MON-YYYY HH24:MI:SS')
WHERE 1=1
AND id=i.id
AND status IN ('NEW','FAILED')
AND lv_status<>'Ship confirmed';
COMMIT;

BEGIN
update_main_table (p_sales_order=>i.sales_order,p_item_number=>m.item_number);
END;
END IF;
END IF;
END LOOP;

/*//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////*/
ELSE

-- Create Pick Wave:
lv_batch_id:=NULL;
BEGIN
xx_wms_int_pkg.create_pick_wave(p_id=>i.id,p_sales_order_number=>i.sales_order,p_batch_id =>lv_batch_id);
write_log('lv_batch_id:'||lv_batch_id);
END;

-- Release Pick Wave:
BEGIN
xx_wms_int_pkg.release_pick_wave(p_batch_id =>lv_batch_id);
END;

-- get pick slip number and shipment number:
lv_pick_slip_number  :=NULL;
lv_shipment_number   :=NULL;
BEGIN
xx_wms_int_pkg.get_pick_slip_details(p_batch_id =>lv_batch_id,
                                     p_pick_slip_number=>lv_pick_slip_number,
                                     p_shipment_number=>lv_shipment_number);
write_log('lv_pick_slip_number:'||lv_pick_slip_number);
write_log('lv_shipment_number:'||lv_shipment_number);
END;

-- Confirm Pick Slip:
BEGIN
xx_wms_int_pkg.confirm_pick_slip(p_id=>i.id,p_sales_order=>i.sales_order,p_batch_id=>lv_batch_id,p_item_number=>i.item_number,p_wms_shipped_qty=>i.wms_shipped_quantity,p_wms_shipped_date=>i.wms_shipped_date);
END;

--- Ship Confirm:
BEGIN
xx_wms_int_pkg.ship_confirm(p_id=>i.id,p_sales_order_number=>i.sales_order,p_batch_id=>lv_batch_id,p_shipment_number=>lv_shipment_number);
END;

--- Update Shipped Quantity:
UPDATE xx_wms_ship_line_dtls_tb
SET fusion_shipped_quantity=fusion_picked_quantity,
    last_update_date=TO_CHAR(SYSDATE,'DD-MON-YYYY HH24:MI:SS')
WHERE 1=1
AND id=i.id
AND batch_id=lv_batch_id
AND status='Ship confirmed';
COMMIT;

-- Get Status:
lv_status:=NULL;
BEGIN
SELECT UNIQUE status INTO lv_status FROM xx_wms_ship_line_dtls_tb WHERE 1=1 AND id=i.id AND batch_id=lv_batch_id;
EXCEPTION WHEN OTHERS THEN
lv_status:=NULL;
END;

--- Update Status:
UPDATE xx_wms_ship_hdr_dtls_tb
SET status='SUCCESS',
    last_update_date=TO_CHAR(SYSDATE,'DD-MON-YYYY HH24:MI:SS')
WHERE 1=1
AND id=i.id
AND status IN ('NEW','FAILED')
AND lv_status='Ship confirmed';
COMMIT;

--- Update Status:
UPDATE xx_wms_ship_hdr_dtls_tb
SET status='FAILED',
    last_update_date=TO_CHAR(SYSDATE,'DD-MON-YYYY HH24:MI:SS')
WHERE 1=1
AND id=i.id
AND status IN ('NEW','FAILED')
AND lv_status<>'Ship confirmed';
COMMIT;

BEGIN
update_main_table (p_sales_order=>i.sales_order,p_item_number=>i.item_number);
END;

END IF;

END LOOP;
-----------------------------------------
DELETE XX_FUSION_PICK_SLIP_DTLS_TEMP_TB;
COMMIT;
-----------------------------------------

BEGIN
xx_wms_int_pkg.pull_so_data_from_fusion(p_business_unit=>NULL,p_line_status=>'AWAIT_BILLING');
END;


EXCEPTION WHEN OTHERS THEN
write_log('Error Occured while executing the "sales order execution flow"');
write_log('Error Code   :'||SQLCODE);
write_log('Error Message:'||SQLERRM);
END fusion_so_exec_flow;


---Sales order return flow:
PROCEDURE fusion_so_return_exec_flow
AS

lv_status VARCHAR2(100):=NULL;
BEGIN

/* 
--- Flow
1.Receipt Creation
2.Send Receipt Confirmation
*/
--- Query:

DELETE xx_wms_ship_line_dtls_tb WHERE 1=1 AND status='Receipt not created';
COMMIT;

FOR i IN (SELECT * FROM xx_wms_ship_dtls_vw WHERE 1=1 AND category_code='RETURN')
LOOP


/*=====================================================================================================================================*/
-- 1.Receipt Creation:
BEGIN
xx_wms_int_pkg.create_receipt_for_rma
(p_id=>i.id,
p_sales_order_number=>i.sales_order,
p_item_number=>i.item_number,
p_wms_shipped_qty=>i.wms_shipped_quantity,
p_wms_shipped_date=>i.wms_shipped_date);
END;

/*=====================================================================================================================================*/
-- 2.Send Receipt Confirmation:
BEGIN
xx_wms_int_pkg.send_receipt_confirmation( 
                                     p_organization_id    => i.warehouse_id,
                                     p_source_system_id   => i.rma_source_system_id,
                                     p_receipt_header_id  => i.receipt_header_id,
									 p_org_code           => i.warehouse_code,
									 p_source_system_name => i.rma_source_system_name);
END;

-- Get Status:
lv_status:=NULL;
BEGIN
SELECT UNIQUE status INTO lv_status FROM xx_wms_ship_line_dtls_tb WHERE 1=1 AND id=i.id;
EXCEPTION WHEN OTHERS THEN
lv_status:=NULL;
END;

--- Update Status:
UPDATE xx_wms_ship_hdr_dtls_tb
SET status='SUCCESS',
    last_update_date=TO_CHAR(SYSDATE,'DD-MON-YYYY HH24:MI:SS')
WHERE 1=1
AND id=i.id
AND status IN ('NEW','FAILED')
AND lv_status='Receipt Created';
COMMIT;

--- Update Status:
UPDATE xx_wms_ship_hdr_dtls_tb
SET status='FAILED',
    last_update_date=TO_CHAR(SYSDATE,'DD-MON-YYYY HH24:MI:SS')
WHERE 1=1
AND id=i.id
AND status IN ('NEW','FAILED')
AND lv_status<>'Receipt Created';
COMMIT;

END LOOP;

--- Call Fusion SO Report:
BEGIN
xx_wms_int_pkg.pull_so_data_from_fusion(p_business_unit=>NULL,p_line_status=>'AWAIT_BILLING');
END;

BEGIN
xx_wms_int_pkg.pull_so_data_from_fusion(p_business_unit=>NULL,p_line_status=>'PARTIAL_REC');
END;

/*=====================================================================================================================================*/

EXCEPTION WHEN OTHERS THEN
write_log('Error Occured while executing the "sales order return execution flow"');
write_log('Error Code:'||SQLCODE);
write_log('Error Message:'||SQLERRM);
END fusion_so_return_exec_flow; 


--- Vendor/Customer Master data to WMS
PROCEDURE vc_master_data_export_process
AS

CURSOR C1 IS SELECT UNIQUE party_id,
                           party_code,
						   party_name
			 FROM xx_fusion_cust_vend_dtls_tb 
			 WHERE 1=1 
			 AND status <> 'SUCCESS' 
			 AND party_id=300000025681066;


BEGIN

FOR i IN (select business_unit
from 
table(
pljson_table.json_table(
(SELECT config_file FROM xx_wms_int_config_tb) ,
pljson_varray('scope.vc_master.bu'),
pljson_varray('business_unit'))))

LOOP

--- Pull data from fusion:
BEGIN
xx_wms_int_pkg.pull_vc_data_from_fusion(p_business_unit=>i.business_unit);
EXCEPTION WHEN OTHERS THEN
write_log('Error Occured while executing the "Pull Vendor/Master Data from fusion"');
write_log('Error Code   :'||SQLCODE);
write_log('Error Message:'||SQLERRM);
END;

END LOOP;

FOR i IN C1 LOOP
--- Push data to WMS:
BEGIN
xx_wms_int_pkg.push_vc_data_to_wms(
                    p_party_id            => i.party_id,
					p_party_code          => i.party_code,
					p_party_name          => i.party_name);
EXCEPTION WHEN OTHERS THEN
write_log('Error Occured while executing the "Push Vendor/Master Data to WMS"');
write_log('Error Code   :'||SQLCODE);
write_log('Error Message:'||SQLERRM);
END;								
END LOOP;

EXCEPTION WHEN OTHERS THEN
write_log('Error Occured while executing the "vc_master_data_export_process"');
write_log('Error Code   :'||SQLCODE);
write_log('Error Message:'||SQLERRM);
END vc_master_data_export_process;

/*=====================================================================================================================================*/

--- Item Master data to WMS
PROCEDURE item_master_data_export_process
AS

CURSOR C1 IS SELECT * FROM xx_item_master_dtls_tb WHERE 1=1 AND status<>'SUCCESS';


BEGIN

--- Pull data from fusion:
BEGIN
xx_wms_int_pkg.pull_item_data_from_fusion;
EXCEPTION WHEN OTHERS THEN
write_log('Error Occured while executing the "Pull Item Data from fusion"');
write_log('Error Code   :'||SQLCODE);
write_log('Error Message:'||SQLERRM);
END;


FOR i IN C1 
LOOP

--- Push data to WMS:
BEGIN
xx_wms_int_pkg.push_item_data_to_wms(p_item_id=>i.item_id);
EXCEPTION WHEN OTHERS THEN
write_log('Error Occured while executing the "Push Item Data to WMS"');
write_log('Error Code   :'||SQLCODE);
write_log('Error Message:'||SQLERRM);
END;

END LOOP;

EXCEPTION WHEN OTHERS THEN
write_log('Error Occured while executing the "item_master_data_export_process"');
write_log('Error Code   :'||SQLCODE);
write_log('Error Message:'||SQLERRM);
END item_master_data_export_process;

--- Fusion SO data import and transfer:
PROCEDURE data_import_and_transfer
AS

BEGIN

/* 
--- Flow
1.Import SO data from fusion
2.Push SO data to WMS
*/

/*=====================================================================================================================================*/

DELETE xx_fusion_so_dtls_tb WHERE 1=1 AND wms_messagecode ='error';
COMMIT;


FOR i IN (select business_unit
from 
table(
pljson_table.json_table(
(SELECT config_file FROM xx_wms_int_config_tb) ,
pljson_varray('scope.sales_order.bu'),
pljson_varray('business_unit'))))

LOOP

-- 1.SO data import from fusion:
BEGIN
xx_wms_int_pkg.pull_so_data_from_fusion(p_business_unit=>i.business_unit,p_line_status=>'AWAIT_BILLING');
END;

BEGIN
xx_wms_int_pkg.pull_so_data_from_fusion(p_business_unit=>i.business_unit,p_line_status=>'AWAIT_SHIP');
END;

BEGIN
xx_wms_int_pkg.pull_so_data_from_fusion(p_business_unit=>i.business_unit,p_line_status=>'AWAIT_RECEIVING');
END;

BEGIN
xx_wms_int_pkg.pull_so_data_from_fusion(p_business_unit=>i.business_unit,p_line_status=>'PARTIAL_REC');
END;

END LOOP;

/*=====================================================================================================================================*/
-- 2.Push SO data to WMS:
FOR i IN (SELECT UNIQUE header_id,order_number 
         FROM xx_fusion_so_dtls_tb 
		 WHERE 1=1 
		 AND (wms_success<>'true' or wms_success IS NULL) 
		 AND TRUNC(creation_date)=TRUNC(SYSDATE))
LOOP
begin
xx_wms_int_pkg.push_so_data_to_wms(p_header_id=>i.header_id,p_order_number=>i.order_number);
end;
END LOOP;
/*=====================================================================================================================================*/

EXCEPTION WHEN OTHERS THEN
write_log('Error Occured while executing the "data_import_and_transfer"');
write_log('Error Code:'||SQLCODE);
write_log('Error Message:'||SQLERRM);
END data_import_and_transfer;


-- Fusion - WMS order management integration execution flow
PROCEDURE om_integration_execution_flow
AS

BEGIN

/* 
--- Flow
1.Data Import from Fusion and Transfer to WMS
2.sales order flow
3.sales order return flow
*/


/*=====================================================================================================================================*/
-- 1.Data Import from Fusion and Transfer to WMS:
BEGIN
data_import_and_transfer;
END;

/*=====================================================================================================================================*/
-- 2.sales order flow:
BEGIN
fusion_so_exec_flow;
END;

/*=====================================================================================================================================*/
-- 3.sales order return flow:
BEGIN
fusion_so_return_exec_flow;
END;
/*=====================================================================================================================================*/


EXCEPTION WHEN OTHERS THEN
write_log('Error Occured while executing the "om_integration_execution_flow"');
write_log('Error Code   :'||SQLCODE);
write_log('Error Message:'||SQLERRM);
END om_integration_execution_flow;


-- Schedule the Fusion-WMS OM Integration:
PROCEDURE sync_fusion_wms_om_intg
  AS
    lc_prog_name      VARCHAR2(100) := 'XX_FUSION_TO_WMS_OM_INTG';
	lc_program_action VARCHAR2(100) := 'XX_WMS_INT_PKG.OM_INTEGRATION_EXECUTION_FLOW';
    lc_job_name       VARCHAR2(100) := 'XX_FUSION_TO_WMS_OM_INTG_JOB';
	lb_false          BOOLEAN       := FALSE;
	lc_datetime       VARCHAR2(30);

  BEGIN
	--
	-- Create Program
	--
	DBMS_SCHEDULER.CREATE_PROGRAM(
		program_name        => lc_prog_name,
		program_action      => lc_program_action,
		program_type        => 'STORED_PROCEDURE',
		number_of_arguments => 0,
		comments            => lc_prog_name,
		enabled             => lb_false);

    DBMS_SCHEDULER.ENABLE(name=>lc_prog_name);
	--
	-- Create Job
	--
	lc_datetime := TO_CHAR(SYSDATE,'DDMMYYYYHH24MISS');

    DBMS_SCHEDULER.CREATE_JOB (
	   job_name        => lc_job_name,
	   program_name    => lc_prog_name,
	   start_date      => SYSTIMESTAMP,
	   repeat_interval => 'freq=minutely;interval=2; bysecond=0;',
	   enabled         => lb_false,
	   comments        => 'XX_FUSION_TO_WMS_OM_INTG_JOB');

	DBMS_SCHEDULER.ENABLE(name=>lc_job_name);

  END sync_fusion_wms_om_intg;

END xx_wms_int_pkg;