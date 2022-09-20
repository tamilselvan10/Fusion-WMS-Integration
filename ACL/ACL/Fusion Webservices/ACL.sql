CONN sys/password@db11g AS SYSDBA

grant execute on utl_http to KW21169_IFACE;
grant execute on dbms_lock to KW21169_IFACE;

-- Create ACL
BEGIN
DBMS_NETWORK_ACL_ADMIN.CREATE_ACL (
acl => 'ACG_TEST_FUSION_TO_TEST_DB.xml',
description => 'Permissions to access web service',
principal => 'KW21169_IFACE',
is_grant => TRUE,
privilege => 'connect',
start_date => SYSTIMESTAMP,
end_date => NULL
);
COMMIT;
END;
/



-- Add Privilege
BEGIN
DBMS_NETWORK_acl_ADMIN.ADD_PRIVILEGE(
acl => 'ACG_TEST_FUSION_TO_TEST_DB.xml',
principal => 'KW21169_IFACE',
is_grant => true,
privilege => 'resolve',
start_date => NULL,
end_date => NULL
);
COMMIT;
END;
/



-- Assign ACL
BEGIN
DBMS_NETWORK_ACL_ADMIN.ASSIGN_ACL (
acl => 'ACG_TEST_FUSION_TO_TEST_DB.xml',
host => '*.oraclecloud.com',
lower_port => NULL,
upper_port => NULL
);
COMMIT;
END;
/