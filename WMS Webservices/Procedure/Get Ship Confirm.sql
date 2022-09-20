BEGIN
  ORDS.define_module(
    p_module_name    => 'gship',
    p_base_path      => 'gship/',
    p_items_per_page => 0);
  
  ORDS.define_template(
   p_module_name    => 'gship',
   p_pattern        => 'gshipdetails/');

  ORDS.define_handler(
    p_module_name    => 'gship',
    p_pattern        => 'gshipdetails/',
    p_method         => 'GET',
    p_source_type    => ORDS.source_type_collection_feed,
    p_source         => 'SELECT * FROM xx_wms_ship_hdr_dtls_tb where 1=1',
    p_items_per_page => 0);
	
	
  ORDS.define_template(
   p_module_name    => 'gship',
   p_pattern        => 'gshipdetails/:sales_order');

  ORDS.define_handler(
    p_module_name    => 'gship',
    p_pattern        => 'gshipdetails/:sales_order',
    p_method         => 'GET',
    p_source_type    => ORDS.source_type_collection_feed,
    p_source         => 'SELECT * FROM xx_wms_ship_hdr_dtls_tb where 1=1 and sales_order=:sales_order',
    p_items_per_page => 0);	

  COMMIT;
END;
/