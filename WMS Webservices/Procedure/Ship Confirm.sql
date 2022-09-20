-----------------------------------------------------------------------------------------------------------------------------------

--- Get WMS Shipment details:
CREATE OR REPLACE PROCEDURE record_ship_details (p_data         IN  BLOB,
                                                 p_out_record   OUT sys_refcursor,
                                                 p_timestamp    OUT VARCHAR2,
												 p_record_count OUT NUMBER,
												 p_status       OUT VARCHAR2,
												 p_message      OUT VARCHAR2)
AS
  
  TYPE t_ship_tab IS TABLE OF xx_wms_ship_hdr_dtls_tb%ROWTYPE;

  l_ship_tab       t_ship_tab := t_ship_tab();

  l_top_obj        JSON_OBJECT_T;
  l_ship_arr       JSON_ARRAY_T;
  l_ship_obj       JSON_OBJECT_T;

  lv_record_count  NUMBER:=0;
  lv_s_i_count     NUMBER:=0;
  
  lv_so_number     VARCHAR2(4000):=NULL;
  lv_item_number   VARCHAR2(4000):=NULL;
  
  lv_id            VARCHAR2(240):=NULL;
  lv_current_id    NUMBER:=NULL;

BEGIN

  p_timestamp:=TO_CHAR(SYSDATE,'DD-MON-YYYY HH24:MI:SS');

  l_top_obj := JSON_OBJECT_T(p_data);

  l_ship_arr := l_top_obj.get_array('shipdetails');
  
   p_message:=NULL;

    FOR j IN 0 .. l_ship_arr.get_size - 1 LOOP

	  lv_s_i_count:=0;
	  lv_so_number:=NULL;
	  lv_item_number:=NULL;

      l_ship_obj := TREAT(l_ship_arr.get(j) AS JSON_OBJECT_T);

      l_ship_tab.extend;
	  
	  lv_current_id:=xx_wms_ship_id_seq.NEXTVAL;  
	  
	l_ship_tab(l_ship_tab.last).id                        := lv_current_id;
    l_ship_tab(l_ship_tab.last).sales_order               := l_ship_obj.get_string('sales_order');
    l_ship_tab(l_ship_tab.last).item_number               := l_ship_obj.get_string('item_number');
    l_ship_tab(l_ship_tab.last).wms_shipped_quantity      := l_ship_obj.get_number('wms_shipped_quantity');
    l_ship_tab(l_ship_tab.last).wms_shipped_date          := l_ship_obj.get_string('wms_shipped_date');
    l_ship_tab(l_ship_tab.last).status                    := 'NEW';
    l_ship_tab(l_ship_tab.last).creation_date             := TO_CHAR(SYSDATE,'DD-MON-YYYY HH24:MI:SS');
    l_ship_tab(l_ship_tab.last).last_update_date          := TO_CHAR(SYSDATE,'DD-MON-YYYY HH24:MI:SS');	
    ----------------------------------------------------------------------------------------------------------------
	
		lv_so_number:=l_ship_obj.get_string('sales_order');
		lv_item_number:=l_ship_obj.get_string('item_number');
		
		lv_id:=(CASE WHEN lv_id IS NOT NULL THEN (lv_id||','||TO_CHAR(lv_current_id)) 
		            ELSE TO_CHAR(lv_current_id)
					END);
		
	lv_record_count:=lv_record_count+1;

	BEGIN
	SELECT COUNT(*) 
	INTO   lv_s_i_count
	FROM xx_fusion_so_dtls_tb
	WHERE 1=1
	AND order_number=lv_so_number
	AND oracle_code=lv_item_number;
	EXCEPTION WHEN OTHERS THEN 
	lv_s_i_count:=0 ;
	END;
	

	IF lv_s_i_count=0 THEN	
	p_message:=(CASE WHEN p_message IS NOT NULL THEN p_message||',Invalid Sales Order ('||l_ship_obj.get_string('sales_order')||') and Item Code ('||l_ship_obj.get_string('item_number')||').'
	            ELSE
				'Invalid Sales Order ('||l_ship_obj.get_string('sales_order')||') and Item Code ('||l_ship_obj.get_string('item_number')||').'
				END);
	END IF;
    

    END LOOP;

 IF p_message is NULL THEN
  -- Populate the tables.
  FORALL i IN l_ship_tab.first .. l_ship_tab.last
	  insert into xx_wms_ship_hdr_dtls_tb VALUES l_ship_tab(i);
      COMMIT;	  
  p_message:='Ship details inserted';
  p_status:='success';	  	  
 ELSE
    p_status:='Error';	  
 END IF;	
 
 -- OUT Variable:
 p_record_count:=lv_record_count; 
 
 IF p_status='success' THEN
 
 ---
    OPEN P_OUT_RECORD FOR
    SELECT *
    FROM   xx_wms_ship_hdr_dtls_tb
    WHERE  1=1
	AND TO_CHAR(id) IN (SELECT DISTINCT column_value FROM (SELECT * FROM 
              TABLE(comma_to_table(lv_id)))); 
 ---
 END IF;
 
 
EXCEPTION
  WHEN OTHERS THEN
    p_message:=SQLCODE||'-'||SQLERRM;
    p_status:='Error';
	p_record_count:=lv_record_count;
    HTP.print(SQLERRM);
END;

--------------------------------------------------------------------------------------------------------------------------------------------------------

BEGIN
    
	  ORDS.ENABLE_SCHEMA(
      p_enabled             => TRUE,
      p_schema              => 'KW21169_IFACE',
      p_url_mapping_type    => 'BASE_PATH',
      p_url_mapping_pattern => 'acg',
      p_auto_rest_auth      => FALSE);  
	  
  COMMIT;
END;
/


BEGIN
  ORDS.define_module(
    p_module_name    => 'ship',
    p_base_path      => 'ship/',
    p_items_per_page => 0);
  
  ORDS.define_template(
   p_module_name    => 'ship',
   p_pattern        => 'shipdetails/');

  ORDS.define_handler(
    p_module_name    => 'ship',
    p_pattern        => 'shipdetails/',
    p_method         => 'POST',
    p_source_type    => ORDS.source_type_plsql,
    p_source         => 'BEGIN   
                         record_ship_details(p_data=>:body,
						                     p_out_record=>:new_record,
						                     p_timestamp=>:timestamp,
						                     p_record_count=>:record_count,
											 p_status=>:status,
											 p_message=>:message);
                         END;',
    p_items_per_page => 0);

  ORDS.DEFINE_PARAMETER(
      p_module_name        => 'ship',
      p_pattern            => 'shipdetails/',
      p_method             => 'POST',
      p_name               => 'shipdetails',
      p_bind_variable_name => 'new_record',
      p_source_type        => 'RESPONSE',
      p_param_type         => 'RESULTSET',
      p_access_method      => 'OUT');   
	  
	  
ORDS.DEFINE_PARAMETER(
      p_module_name        => 'ship',
      p_pattern            => 'shipdetails/',
      p_method             => 'POST',
      p_name               => 'time',
      p_bind_variable_name => 'timestamp',
      p_source_type        => 'RESPONSE',
      p_param_type         => 'STRING',
      p_access_method      => 'OUT',
      p_comments           => NULL);   

  ORDS.DEFINE_PARAMETER(
      p_module_name        => 'ship',
      p_pattern            => 'shipdetails/',
      p_method             => 'POST',
      p_name               => 'record_count',
      p_bind_variable_name => 'record_count',
      p_source_type        => 'RESPONSE',
      p_param_type         => 'STRING',
      p_access_method      => 'OUT',
      p_comments           => NULL);  

  ORDS.DEFINE_PARAMETER(
      p_module_name        => 'ship',
      p_pattern            => 'shipdetails/',
      p_method             => 'POST',
      p_name               => 'status',
      p_bind_variable_name => 'status',
      p_source_type        => 'RESPONSE',
      p_param_type         => 'STRING',
      p_access_method      => 'OUT',
      p_comments           => NULL); 	 

  ORDS.DEFINE_PARAMETER(
      p_module_name        => 'ship',
      p_pattern            => 'shipdetails/',
      p_method             => 'POST',
      p_name               => 'message',
      p_bind_variable_name => 'message',
      p_source_type        => 'RESPONSE',
      p_param_type         => 'STRING',
      p_access_method      => 'OUT',
      p_comments           => NULL);      
  	  	    

  COMMIT;
END;
/

http://192.168.20.86:8081/ords/acg/ship/shipdetails/