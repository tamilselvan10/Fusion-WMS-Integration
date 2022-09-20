create or replace PACKAGE xx_wms_int_pkg
AS
--##########################################################################
--# Filename   : xx_wms_int_pkg.pks
--# Description: Fusion OM- WMS Integration
--#   Date       | Name                                   | Remarks
--# ----------------------------------------------------------------------
--#  27-Jun-2022 | Fusion OM- WMS Integration             | 
--##########################################################################

---  Variables:

  -- Integration Start Date:
     c_integration_start_date varchar2(15):=get_config('integration.start_date');  

  -- Oracle Wallet:
     c_wallet_path           varchar2(240):=get_config('wallet.path');
     c_wallet_pwd            varchar2(240):=get_config('wallet.password');

  -- Instance URL:
     c_instance_url          varchar2(4000):=get_config('instance_url');

  -- API authentication  
     c_username              varchar2(240) :=get_config('fusion_api_authentication.username'); -- fusion user's username
     c_password              varchar2(240) :=get_config('fusion_api_authentication.password'); -- fusion user's password

  --1. Report Configuration details:
    c_output_format          varchar2(4000):=get_config('fusion_so_report.output_format'); --- Report o/p format
    c_so_report_xdo_path     varchar2(4000):=get_config('fusion_so_report.xdo_path'); --- Fusion SO data extract report XDO path
	c_vc_report_xdo_path     varchar2(4000):=get_config('fusion_vc_report.xdo_path'); --- Fusion Vendor/Customer Master report
	c_item_report_xdo_path   varchar2(4000):=get_config('fusion_item_report.xdo_path'); --- Fusion Item Master report
  --
    c_report_wsdl_url    varchar2(4000):=get_config('fusion_so_report.wsdl_url');  
    c_http_method        varchar2(240) :=get_config('fusion_so_report.http_method');
    c_http_version       varchar2(240) :=get_config('fusion_so_report.http_version');
    c_content_type       varchar2(240) :=get_config('fusion_so_report.content_type');
    c_soap_action        varchar2(240) :=get_config('fusion_so_report.soap_action');
    c_connection         varchar2(240) :=get_config('fusion_so_report.connection');

  --2. Create pick wave:
    c_cpw_url            varchar2(240) :=get_config('create_pick_wave.url');
    c_cpw_http_method    varchar2(240) :=get_config('create_pick_wave.http_method');
    c_cpw_http_version   varchar2(240) :=get_config('create_pick_wave.http_version');
    c_cpw_content_type   varchar2(240) :=get_config('create_pick_wave.content_type');

  --Release Rule:
    c_release_rule       varchar2(240) :=get_config('release_rule');  

  --3. Release pick wave:
  c_rpw_url            varchar2(240) :=get_config('release_pick_wave.url');
  c_rpw_http_method    varchar2(240) :=get_config('release_pick_wave.http_method');
  c_rpw_http_version   varchar2(240) :=get_config('release_pick_wave.http_version');
  c_rpw_content_type   varchar2(240) :=get_config('release_pick_wave.content_type');

  -- Get pick slip details:
  c_gps_http_method    varchar2(240) :=get_config('pick_slip_details.http_method');
  c_gps_http_version   varchar2(240) :=get_config('pick_slip_details.http_version');
  c_gps_content_type   varchar2(240) :=get_config('pick_slip_details.content_type');

  -- 4. Confirm pick Slip:
  c_cps_url            varchar2(240) :=get_config('confirm_pick_slip.url');
  c_cps_http_method    varchar2(240) :=get_config('confirm_pick_slip.http_method');
  c_cps_http_version   varchar2(240) :=get_config('confirm_pick_slip.http_version');
  c_cps_content_type   varchar2(240) :=get_config('confirm_pick_slip.content_type');


  -- 5. Ship Confirm:
  c_sc_url            varchar2(240) :=get_config('ship_confirm.url');
  c_sc_http_method    varchar2(240) :=get_config('ship_confirm.http_method');
  c_sc_http_version   varchar2(240) :=get_config('ship_confirm.http_version');
  c_sc_content_type   varchar2(240) :=get_config('ship_confirm.content_type');

  -- Create Shipment:
  c_cs_wsdl_url           varchar2(4000):=get_config('create_shipment.wsdl_url'); 
  c_cs_http_version       varchar2(240) :=get_config('create_shipment.http_version');
  c_cs_http_method        varchar2(240) :=get_config('create_shipment.http_method');
  c_cs_content_type       varchar2(240) :=get_config('create_shipment.content_type');
  c_cs_soap_action        varchar2(240) :=get_config('create_shipment.soap_action');
  c_cs_connection         varchar2(240) :=get_config('create_shipment.connection'); 

  -- Update Shipment Line:
  c_us_wsdl_url           varchar2(4000):=get_config('update_shipment.wsdl_url'); 
  c_us_http_version       varchar2(240) :=get_config('update_shipment.http_version');
  c_us_http_method        varchar2(240) :=get_config('update_shipment.http_method');
  c_us_content_type       varchar2(240) :=get_config('update_shipment.content_type');
  c_us_soap_action        varchar2(240) :=get_config('update_shipment.soap_action');
  c_us_connection         varchar2(240) :=get_config('update_shipment.connection');


  --6. Receipt Creation against RMA:
  c_rc_a_rma_url            varchar2(240) :=get_config('rma_receipt.url');
  c_rc_a_rma_http_method    varchar2(240) :=get_config('rma_receipt.http_method');
  c_rc_a_rma_http_version   varchar2(240) :=get_config('rma_receipt.http_version');
  c_rc_a_rma_content_type   varchar2(240) :=get_config('rma_receipt.content_type');

  --7. Send receipt Confirmation:
  c_src_url                varchar2(4000):=get_config('send_receipt_confirmation.wsdl_url');  
  c_src_http_method        varchar2(240) :=get_config('send_receipt_confirmation.http_method');
  c_src_http_version       varchar2(240) :=get_config('send_receipt_confirmation.http_version');
  c_src_content_type       varchar2(240) :=get_config('send_receipt_confirmation.content_type');
  c_src_soap_action        varchar2(240) :=get_config('send_receipt_confirmation.soap_action');
  c_src_connection         varchar2(240) :=get_config('send_receipt_confirmation.connection');

  -- Get Expected Shipments details:
  c_ges_ship_wsdl_url           varchar2(4000):=get_config('expected_shipments.wsdl_url'); 
  c_ges_ship_http_version       varchar2(240) :=get_config('expected_shipments.http_version');
  c_ges_ship_http_method        varchar2(240) :=get_config('expected_shipments.http_method');
  c_ges_ship_content_type       varchar2(240) :=get_config('expected_shipments.content_type');
  c_ges_ship_soap_action       varchar2(240)  :=get_config('expected_shipments.soap_action');
  c_ges_ship_connection         varchar2(240) :=get_config('expected_shipments.connection'); 

----------------------------------WMS-------------------------------------------------------------------------------
  -- WMS User token:
  c_user_code                 varchar2(240) :=get_config('wms_user_token.username');
  c_user_password             varchar2(240) :=get_config('wms_user_token.password');
  c_user_token_url            varchar2(240) :=get_config('wms_user_token.url');
  c_user_token_http_method    varchar2(240) :=get_config('wms_user_token.http_method');
  c_user_token_http_version   varchar2(240) :=get_config('wms_user_token.http_version');
  c_user_token_content_type   varchar2(240) :=get_config('wms_user_token.content_type');  

  -- Ship Order (Sales Order) / Delivery Note:
  c_dn_url            varchar2(240) :=get_config('wms_ship_order.url');
  c_dn_http_method    varchar2(240) :=get_config('wms_ship_order.http_method');
  c_dn_http_version   varchar2(240) :=get_config('wms_ship_order.http_version');
  c_dn_content_type   varchar2(240) :=get_config('wms_ship_order.content_type');


  -- Vendor/Customer Master:
  c_vc_url            varchar2(240) :=get_config('wms_vc_master.url');
  c_vc_http_method    varchar2(240) :=get_config('wms_vc_master.http_method');
  c_vc_http_version   varchar2(240) :=get_config('wms_vc_master.http_version');
  c_vc_content_type   varchar2(240) :=get_config('wms_vc_master.content_type');

  -- Item Master:
  c_it_url            varchar2(240) :=get_config('wms_item_master.url');
  c_it_http_method    varchar2(240) :=get_config('wms_item_master.http_method');
  c_it_http_version   varchar2(240) :=get_config('wms_item_master.http_version');
  c_it_content_type   varchar2(240) :=get_config('wms_item_master.content_type');

  --- Scope:
  c_org_code          varchar2(240) :=get_config('scope.item_master.org_code'); --- Item Master Scope



--- Normal Functions and procedures:

  -- get legal entity name:
  function get_legal_entity_name (p_sales_order in varchar2)
  return varchar2;

  -- get business unit:
  function get_business_unit (p_sales_order in varchar2)
  return varchar2; 

  -- get customer_name:
  function get_customer_name(p_sales_order in varchar2) 
  return varchar2;

  -- get item description:
  function get_item_description(p_sales_order in varchar2,p_item_number in varchar2)
  return varchar2;

  -- get uom:
  function get_uom(p_sales_order in varchar2,p_item_number in varchar2)
  return varchar2;

--- payload functions:

  -- get fusion so data extract report request payload:
  function get_report_request_payload (p_business_unit IN VARCHAR2,p_line_status in varchar2)
  return varchar2; 

    -- Get fusion vendor/customer data extract report request payload:
  function get_vc_report_request_payload(p_business_unit in varchar2)
  return varchar2;

  -- Get fusion Item Master data extract report request payload:
  function get_item_report_request_payload 
  return varchar2;

  -- generate user token:
  function generate_user_token
  return varchar2;

  -- wms sales order request payload for shipment:
  function get_wms_so_request_payload (p_header_id in number,p_order_number in varchar2)
  return clob;

  -- wms vendor/customer master request payload:
   function get_wms_vc_request_payload(p_party_id in varchar2,
                                       p_party_code in varchar2,
									   p_party_name in varchar2)
   return clob;

   -- wms item request payload:
   function get_wms_item_request_payload (p_item_id in varchar2)
   return clob;

  -- get create pick wave request payload:
  function get_crt_pickwave_req_payload(p_sales_order_number in varchar2,p_id in number)
  return clob;

  -- get pick slip request payload:
  function get_cnf_pickslip_req_payload  (p_id in number,p_sales_order in varchar2,p_batch_id in varchar2,p_item_number in varchar2,
                                       p_wms_shipped_qty in number,p_wms_shipped_date in varchar2) return clob;

  -- get shipment lines payload:
  function get_shipment_lines_payload(p_sales_order in varchar2,p_batch_id in varchar2,p_item_number in varchar2)
  return varchar2;

  -- get shipment lines:
  function get_shipment_lines (p_sales_order in varchar2,p_batch_id in varchar2,p_item_number in varchar2)
  return varchar2;

   -- get receipt creation request payload:
   function get_receipt_req_payload (p_id in number,p_sales_order_number in varchar2,p_item_number in varchar2,p_wms_shipped_qty in number,
                                  p_wms_shipped_date in varchar2)
   return clob;

   -- send receipt confirmation:
   function receipt_confirm_req_payload
                                    (p_organization_id    in number,
                                     p_source_system_id   in number,
                                     p_receipt_header_id  in number,
									 p_org_code           in varchar2,
									 p_source_system_name in varchar2)
   return varchar2 ;


--- procedures:

 --1.import so data from fusion:
  procedure pull_so_data_from_fusion(p_business_unit IN VARCHAR2,p_line_status in varchar2);

  -- pull vendor/customer master data from fusion
  procedure pull_vc_data_from_fusion(p_business_unit IN VARCHAR2);

  -- procedure to call vendor/customer master webservice:
  procedure push_vc_data_to_wms(p_party_id in varchar2,
                                p_party_code in varchar2,
								p_party_name in varchar2);

  -- Pull Item data from fusion
  procedure pull_item_data_from_fusion;								

 --2.procedure to call wms ship order webservice:
  procedure push_so_data_to_wms(p_header_id in number,p_order_number in varchar2);

 --3.create pick wave:
 procedure create_pick_wave(p_id in number,p_sales_order_number in varchar2,p_batch_id out varchar2);

 --4.release pick wave:
 procedure release_pick_wave(p_batch_id in varchar2);

 --5.get pick slip details:
 procedure get_pick_slip_details(p_batch_id in varchar2,p_pick_slip_number out varchar2,p_shipment_number out varchar2);

 --6.confirm pick slip:
 procedure confirm_pick_slip (p_id in number,p_sales_order in varchar2,p_batch_id in varchar2,p_item_number in varchar2,p_wms_shipped_qty in number,p_wms_shipped_date in varchar2)	;

 --7.ship confirm:
 procedure ship_confirm(p_id in number,p_sales_order_number in varchar2,p_batch_id in varchar2,p_shipment_number in varchar2);

 -- pick slip details headers:
 procedure pick_slip_details_headers(p_sales_order_number in varchar2,p_item_number in varchar2,p_id in number);

 -- create shipment:
 procedure create_shipment(p_id in number,p_sales_order in varchar2,p_batch_id in varchar2,p_item_number in varchar2,p_shipment_number out varchar2);

 -- update shipment:
 procedure update_shipment (p_id in number,p_sales_order in varchar2,p_batch_id in varchar2,p_item_number in varchar2);

 -- receipt creation against rma
 procedure create_receipt_for_rma(p_id in number,p_sales_order_number in varchar2,p_item_number in varchar2,p_wms_shipped_qty in number,
                                  p_wms_shipped_date in varchar2);
  -- send receipt confirmation
  procedure send_receipt_confirmation(  p_organization_id    in number,
                                        p_source_system_id   in number,
                                        p_receipt_header_id  in number,
									    p_org_code           in varchar2,
									    p_source_system_name in varchar2);



  -- flow:

  -- sales order flow:
  procedure fusion_so_exec_flow;

  -- sales order return flow:
  procedure fusion_so_return_exec_flow;

  -- Vendor/Customer Master flow:
  procedure vc_master_data_export_process;

  --- Item Master data to WMS
  procedure item_master_data_export_process;

  -- fusion so data import and transfer:
  procedure data_import_and_transfer;

 -- Fusion - WMS order management integration execution flow
 procedure om_integration_execution_flow;

 -- Schedule the Fusion-WMS OM Integration:
 procedure sync_fusion_wms_om_intg;


END xx_wms_int_pkg;