
SELECT utl_http.request(url=>'https://ebns-test.fa.em2.oraclecloud.com/xmlpserver/services/ExternalReportWSSService?WSDL',
        wallet_path     =>'file:/u01/wallet',
        wallet_password =>'password123') FROM DUAL;



-----------------------------------
Wallet Path:/u01/wallet
Wallet Pwd :password123
-----------------------------------
