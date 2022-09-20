SELECT UNIQUE 
       hou.name                                    business_unit, 
/***********************************************************************************************************/	 	   
	   ---Header:
       dha.header_id                               header_id,
       dha.order_number                            order_number,
	   TO_CHAR(dha.ordered_date,'YYYY-MM-DD')      ordered_date,
       TO_CHAR(dha.creation_date,'YYYY-MM-DD')     creation_date,
	   dha.status_code                             status_code,
	   dha.canceled_flag                           header_canceled_flag,
	   dha.transactional_currency_code             trans_curr_code,
       dha.cancel_reason_code                      cancel_reason_code,
	   dha.subinventory                            subinventory,
	   dha.customer_po_number                      customer_po_no, 
	   val.meaning                                 order_type ,
	   dheb.attribute_char1 header_attribute_char1,
dheb.attribute_char2 header_attribute_char2,
dheb.attribute_char3 header_attribute_char3,
dheb.attribute_char4 header_attribute_char4,
dheb.attribute_char5 header_attribute_char5,
dheb.attribute_char6 header_attribute_char6,
dheb.attribute_char7 header_attribute_char7,
dheb.attribute_char8 header_attribute_char8,
dheb.attribute_char9 header_attribute_char9,
dheb.attribute_char10 header_attribute_char10,
dheb.attribute_char11 header_attribute_char11,
dheb.attribute_char12 header_attribute_char12,
dheb.attribute_char13 header_attribute_char13,
dheb.attribute_char14 header_attribute_char14,
dheb.attribute_char15 header_attribute_char15,
dheb.attribute_char16 header_attribute_char16,
dheb.attribute_char17 header_attribute_char17,
dheb.attribute_char18 header_attribute_char18,
dheb.attribute_char19 header_attribute_char19,
dheb.attribute_char20 header_attribute_char20,
dheb.attribute_number1 header_attribute_number1,
dheb.attribute_number2 header_attribute_number2,
dheb.attribute_number3 header_attribute_number3,
dheb.attribute_number4 header_attribute_number4,
dheb.attribute_number5 header_attribute_number5,
dheb.attribute_number6 header_attribute_number6,
dheb.attribute_number7 header_attribute_number7,
dheb.attribute_number8 header_attribute_number8,
dheb.attribute_number9 header_attribute_number9,
dheb.attribute_number10 header_attribute_number10,
dheb.attribute_date1 header_attribute_date1,
dheb.attribute_date2 header_attribute_date2,
dheb.attribute_date3 header_attribute_date3,
dheb.attribute_date4 header_attribute_date4,
dheb.attribute_date5 header_attribute_date5,
dheb.attribute_timestamp1 header_attribute_timestamp1,
dheb.attribute_timestamp2 header_attribute_timestamp2,
dheb.attribute_timestamp3 header_attribute_timestamp3,
dheb.attribute_timestamp4 header_attribute_timestamp4,
dheb.attribute_timestamp5 header_attribute_timestamp5,
/***********************************************************************************************************/	   
     ---Line:	   
	   dla.line_id                                 line_id,
	   dla.line_number                             line_number,
	   (SELECT 
      UNIQUE iuomtl.unit_of_measure
      FROM 
	  fusion.inv_units_of_measure_b iuomb ,
      fusion.inv_units_of_measure_tl iuomtl
      WHERE 1=1
      AND iuomb.unit_of_measure_id = iuomtl.unit_of_measure_id
      AND iuomtl.language = 'US'
      AND iuomb.uom_code =dla.ordered_uom
	  AND ROWNUM=1)                                       ordered_uom,                  	   
	   dla.ordered_qty                                    ordered_qty,
	   cus.shipped_quantity                               shipped_qty,
	   cus.picked_quantity                                picked_qty,
	   dla.canceled_qty                                   cancelled_qty,
	   dla.unit_list_price                                unit_list_price,
	   dla.unit_selling_price                             unit_selling_price,
	   dla.extended_amount                                extended_amount,
	   dla.category_code                                  category_code,
	   (SELECT  UNIQUE 
        dst.display_name
        FROM fusion.doo_statuses_b  dsb,
             fusion.doo_statuses_tl dst
        WHERE 1=1 
        AND dsb.status_id = dst.status_id
		AND dsb.status_code =dfla.status_code
        AND dst.language =userenv('LANG')
		AND ROWNUM=1)                line_status,
	   esi.item_number                                    item_code,
       esi.description                                    item_description,
	   TO_CHAR(dfla.actual_ship_date,'YYYY-MM-DD')        actual_ship_date,
	   TO_CHAR(dfla.schedule_ship_date,'YYYY-MM-DD')      scheduled_ship_date,
	   TO_CHAR(dfla.request_ship_date ,'YYYY-MM-DD')      request_ship_date,
	   TO_CHAR(dfla.promise_ship_date,'YYYY-MM-DD')       promise_ship_date,
	   dleb.attribute_char1 line_attribute_char1,
dleb.attribute_char2 line_attribute_char2,
dleb.attribute_char3 line_attribute_char3,
dleb.attribute_char4 line_attribute_char4,
dleb.attribute_char5 line_attribute_char5,
dleb.attribute_char6 line_attribute_char6,
dleb.attribute_char7 line_attribute_char7,
dleb.attribute_char8 line_attribute_char8,
dleb.attribute_char9 line_attribute_char9,
dleb.attribute_char10 line_attribute_char10,
dleb.attribute_char11 line_attribute_char11,
dleb.attribute_char12 line_attribute_char12,
dleb.attribute_char13 line_attribute_char13,
dleb.attribute_char14 line_attribute_char14,
dleb.attribute_char15 line_attribute_char15,
dleb.attribute_char16 line_attribute_char16,
dleb.attribute_char17 line_attribute_char17,
dleb.attribute_char18 line_attribute_char18,
dleb.attribute_char19 line_attribute_char19,
dleb.attribute_char20 line_attribute_char20,
dleb.attribute_number1 line_attribute_number1,
dleb.attribute_number2 line_attribute_number2,
dleb.attribute_number3 line_attribute_number3,
dleb.attribute_number4 line_attribute_number4,
dleb.attribute_number5 line_attribute_number5,
dleb.attribute_number6 line_attribute_number6,
dleb.attribute_number7 line_attribute_number7,
dleb.attribute_number8 line_attribute_number8,
dleb.attribute_number9 line_attribute_number9,
dleb.attribute_number10 line_attribute_number10,
dleb.attribute_date1 line_attribute_date1,
dleb.attribute_date2 line_attribute_date2,
dleb.attribute_date3 line_attribute_date3,
dleb.attribute_date4 line_attribute_date4,
dleb.attribute_date5 line_attribute_date5,
dleb.attribute_timestamp1 line_attribute_timestamp1,
dleb.attribute_timestamp2 line_attribute_timestamp2,
dleb.attribute_timestamp3 line_attribute_timestamp3,
dleb.attribute_timestamp4 line_attribute_timestamp4,
dleb.attribute_timestamp5 line_attribute_timestamp5,
	   	---Customers:
	   party2.party_name                                  customer_name,
	   acct.account_name                                  customer_account_name , 
       acct.account_number                                customer_account_number , 
	   ship_party.party_name                              ship_to_Customer, 
      (ship_to_loc.ADDRESS1 ||' '||ship_to_loc.ADDRESS2 ||' ' ||ship_to_loc.city ||' '||ship_to_loc.state)  ship_to_address ,
	  mpi.organization_code                               inv_org_code,
	  houi.name                                           inv_org_name,
	  mpx.organization_code                               warehouse_code,
	  houx.name                                           warehouse_name,
	  cus.shipment_number,
	  cus.pick_slip_number,
	  cus.staging_subinventory,
	  cus.picked_from_subinventory
/***********************************************************************************************************/	 	   	   	   	  
	   
FROM
 doo_headers_all              dha           ,
 doo_lines_all                dla           ,
 doo_fulfill_lines_all        dfla          ,
 hz_parties                   party2        ,
 fnd_lookup_values            val           ,
 doo_order_addresses          address       ,
 doo_order_addresses          ship_address  , 
 hz_parties                   ship_party    , 
 hz_party_sites               party_site    , 
 hz_locations                 ship_to_loc   , 
 hz_cust_accounts             acct          ,
 hr_operating_units           hou           ,
 egp_system_items             esi           ,
 hr_all_organization_units_x  houx          ,
 inv_org_parameters           mpx           ,
 hr_all_organization_units_x  houi          ,
 inv_org_parameters           mpi           ,
 doo_headers_eff_b            dheb          ,
 doo_lines_eff_b              dleb          ,
 (SELECT wdd.source_header_id,
         wdd.source_line_id,
		 wdd.sales_order_number,
		 wdd.sales_order_line_number,
		 wdd.picked_quantity,
		 wdd.shipped_quantity,
		 wnd.delivery_name shipment_number,
         ipsn.pick_slip_number,
		 wdd.subinventory staging_subinventory,
		 wdd.picked_from_subinventory
FROM wsh_delivery_details     wdd,
     wsh_delivery_assignments wda,
	 wsh_new_deliveries       wnd,
	 inv_pick_slip_numbers    ipsn
	 
WHERE 1=1
AND wdd.delivery_detail_id=wda.delivery_detail_id
AND wda.delivery_id=wnd.delivery_id
AND wdd.batch_id=ipsn.pick_slip_batch_id)cus

WHERE 1=1
AND dha.canceled_flag='N'
AND dha.object_version_number = 
                     (SELECT MAX(object_version_number) 
                        FROM doo_headers_all dha_latest 
                        WHERE 1=1
						AND dha_latest.order_number = dha.order_number 
                        AND dha_latest.status_code = dha.status_code )
AND dha.order_type_code=val.lookup_code 	
AND val.lookup_type = 'ORA_DOO_ORDER_TYPES' 
--------------------------------------------------------------------------------------------
AND dha.order_type_code=NVL(:p_order_type,dha.order_type_code)  --- parameter1:Order Type
--------------------------------------------------------------------------------------------
AND dha.header_id=dla.header_id	
AND dla.inventory_organization_id = esi.organization_id
AND dla.inventory_item_id = esi.inventory_item_id	
AND dla.line_id=dfla.line_id	
AND dla.canceled_flag='N'
AND dfla.status_code=NVL(:p_line_status,'AWAIT_SHIP')    --- parameter2:Line Status
---------------------------------------------
AND dfla.fulfill_org_id=houx.organization_id
AND houx.organization_id=mpx.organization_id
---------------------------------------------	
AND dla.inventory_organization_id=houi.organization_id
AND houi.organization_id=mpi.organization_id
---------------------------------------------	
AND dha.sold_to_party_id = party2.party_id(+) 
AND dha.header_id =address.header_id(+) 
AND address.ADDRESS_USE_TYPE(+) = 'BILL_TO' 
AND address.cust_acct_id = acct.cust_account_id(+) 
AND dha.org_id =hou.organization_id
AND ship_address.header_id(+) = dha.header_id 
AND ship_address.ADDRESS_USE_TYPE(+) = 'SHIP_TO' 
AND ship_party.party_id(+) = ship_address.party_id 
AND party_site.party_site_id(+) = ship_address.party_site_id 
AND ship_to_loc.location_id(+) = party_site.location_id
AND dha.header_id=dheb.header_id(+)
AND dla.line_id=dleb.line_id(+)
AND dha.order_number=cus.sales_order_number(+)
AND dla.line_number=cus.sales_order_line_number(+)

ORDER BY dha.header_id,dla.line_id ASC