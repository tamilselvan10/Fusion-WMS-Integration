1.java -jar ords.war user acg_api_user acg_api_role
username:acg_api_user
password:acg_api_user
-------------------------------------------------------------------------------------------------------------
create role in sql developer:acg_api_role

2.Get Ship Confirm
enable rest service for the object:xx_wms_ship_hdr_dtls_tb
Assign ACI_API_ROLE to the oracle.dbtools.role.autorest.KW21169_IFACE.XX_WMS_SHIP_HDR_DTLS_TB
protected_module:gship
-------------------------------------------------------------------------------------------------------------
3.Ship Confirm
enable rest service for the object:record_ship_details
Assign ACI_API_ROLE to the oracle.dbtools.role.autorest.KW21169_IFACE.RECORD_SHIP_DETAILS
protected_module:ship

-------------------------------------------------------------------------------------------------------------