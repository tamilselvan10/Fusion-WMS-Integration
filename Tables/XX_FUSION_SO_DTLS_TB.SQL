  CREATE TABLE "XX_FUSION_SO_DTLS_TB" 
   (	"LEGAL_ENTITY_ID" NUMBER, 
	"LEGAL_ENTITY_NAME" VARCHAR2(240 BYTE), 
	"BUSINESS_UNIT" VARCHAR2(40 BYTE), 
	"HEADER_ID" NUMBER, 
	"ORDER_NUMBER" VARCHAR2(240 BYTE), 
	"ORDERED_DATE" VARCHAR2(240 BYTE), 
	"ORDERED_CREATION_DATE" VARCHAR2(240 BYTE), 
	"STATUS_CODE" VARCHAR2(240 BYTE), 
	"HEADER_CANCELED_FLAG" VARCHAR2(240 BYTE), 
	"TRANS_CURR_CODE" VARCHAR2(240 BYTE), 
	"CANCEL_REASON_CODE" VARCHAR2(240 BYTE), 
	"SUBINVENTORY" VARCHAR2(240 BYTE), 
	"CUSTOMER_PO_NO" VARCHAR2(240 BYTE), 
	"ORDER_TYPE" VARCHAR2(240 BYTE), 
	"SOURCE_SYSTEM_NAME" VARCHAR2(240 BYTE), 
	"LINE_ID" NUMBER, 
	"LINE_NUMBER" VARCHAR2(240 BYTE), 
	"ORDERED_UOM" VARCHAR2(240 BYTE), 
	"ORDERED_QTY" NUMBER, 
	"SHIPPED_QTY" NUMBER, 
	"PICKED_QTY" NUMBER, 
	"CANCELLED_QTY" NUMBER, 
	"UNIT_LIST_PRICE" NUMBER, 
	"UNIT_SELLING_PRICE" NUMBER, 
	"EXTENDED_AMOUNT" NUMBER, 
	"CATEGORY_CODE" VARCHAR2(240 BYTE), 
	"LINE_STATUS" VARCHAR2(240 BYTE), 
	"ITEM_CODE" VARCHAR2(240 BYTE), 
        "ORACLE_CODE" VARCHAR2(240 BYTE),
        "BARCODE" VARCHAR2(240 BYTE),
	"ITEM_DESCRIPTION" VARCHAR2(240 BYTE), 
	"ACTUAL_SHIP_DATE" VARCHAR2(240 BYTE), 
	"SCHEDULED_SHIP_DATE" VARCHAR2(240 BYTE), 
	"REQUEST_SHIP_DATE" VARCHAR2(240 BYTE), 
	"PROMISE_SHIP_DATE" VARCHAR2(240 BYTE), 
	"CUSTOMER_NAME" VARCHAR2(240 BYTE), 
	"CUSTOMER_ACCOUNT_NAME" VARCHAR2(240 BYTE), 
	"CUSTOMER_ACCOUNT_NUMBER" VARCHAR2(240 BYTE), 
	"SHIP_TO_CUSTOMER" VARCHAR2(240 BYTE), 
	"SHIP_TO_ADDRESS" VARCHAR2(240 BYTE), 
	"INV_ORG_ID" NUMBER, 
	"INV_ORG_CODE" VARCHAR2(30 BYTE), 
	"INV_ORG_NAME" VARCHAR2(240 BYTE), 
	"WAREHOUSE_ID" NUMBER, 
	"WAREHOUSE_CODE" VARCHAR2(30 BYTE), 
	"WAREHOUSE_NAME" VARCHAR2(240 BYTE), 
	"CREATION_DATE" DATE, 
	"LAST_UPDATE_DATE" DATE, 
	"IMPORT_METHOD" VARCHAR2(100 BYTE), 
	"STATUS" VARCHAR2(240 BYTE), 
	"ERROR_MESSAGE" VARCHAR2(4000 BYTE), 
	"HEADER_ATTRIBUTE_CHAR1" VARCHAR2(240 BYTE), 
	"HEADER_ATTRIBUTE_CHAR2" VARCHAR2(240 BYTE), 
	"HEADER_ATTRIBUTE_CHAR3" VARCHAR2(240 BYTE), 
	"HEADER_ATTRIBUTE_CHAR4" VARCHAR2(240 BYTE), 
	"HEADER_ATTRIBUTE_CHAR5" VARCHAR2(240 BYTE), 
	"HEADER_ATTRIBUTE_CHAR6" VARCHAR2(240 BYTE), 
	"HEADER_ATTRIBUTE_CHAR7" VARCHAR2(240 BYTE), 
	"HEADER_ATTRIBUTE_CHAR8" VARCHAR2(240 BYTE), 
	"HEADER_ATTRIBUTE_CHAR9" VARCHAR2(240 BYTE), 
	"HEADER_ATTRIBUTE_CHAR10" VARCHAR2(240 BYTE), 
	"HEADER_ATTRIBUTE_CHAR11" VARCHAR2(240 BYTE), 
	"HEADER_ATTRIBUTE_CHAR12" VARCHAR2(240 BYTE), 
	"HEADER_ATTRIBUTE_CHAR13" VARCHAR2(240 BYTE), 
	"HEADER_ATTRIBUTE_CHAR14" VARCHAR2(240 BYTE), 
	"HEADER_ATTRIBUTE_CHAR15" VARCHAR2(240 BYTE), 
	"HEADER_ATTRIBUTE_CHAR16" VARCHAR2(240 BYTE), 
	"HEADER_ATTRIBUTE_CHAR17" VARCHAR2(240 BYTE), 
	"HEADER_ATTRIBUTE_CHAR18" VARCHAR2(240 BYTE), 
	"HEADER_ATTRIBUTE_CHAR19" VARCHAR2(240 BYTE), 
	"HEADER_ATTRIBUTE_CHAR20" VARCHAR2(240 BYTE), 
	"HEADER_ATTRIBUTE_NUMBER1" NUMBER, 
	"HEADER_ATTRIBUTE_NUMBER2" NUMBER, 
	"HEADER_ATTRIBUTE_NUMBER3" NUMBER, 
	"HEADER_ATTRIBUTE_NUMBER4" NUMBER, 
	"HEADER_ATTRIBUTE_NUMBER5" NUMBER, 
	"HEADER_ATTRIBUTE_NUMBER6" NUMBER, 
	"HEADER_ATTRIBUTE_NUMBER7" NUMBER, 
	"HEADER_ATTRIBUTE_NUMBER8" NUMBER, 
	"HEADER_ATTRIBUTE_NUMBER9" NUMBER, 
	"HEADER_ATTRIBUTE_NUMBER10" NUMBER, 
	"HEADER_ATTRIBUTE_DATE1" DATE, 
	"HEADER_ATTRIBUTE_DATE2" DATE, 
	"HEADER_ATTRIBUTE_DATE3" DATE, 
	"HEADER_ATTRIBUTE_DATE4" DATE, 
	"HEADER_ATTRIBUTE_DATE5" DATE, 
	"HEADER_ATTRIBUTE_TIMESTAMP1" TIMESTAMP (6), 
	"HEADER_ATTRIBUTE_TIMESTAMP2" TIMESTAMP (6), 
	"HEADER_ATTRIBUTE_TIMESTAMP3" TIMESTAMP (6), 
	"HEADER_ATTRIBUTE_TIMESTAMP4" TIMESTAMP (6), 
	"HEADER_ATTRIBUTE_TIMESTAMP5" TIMESTAMP (6), 
	"LINE_ATTRIBUTE_CHAR1" VARCHAR2(240 BYTE), 
	"LINE_ATTRIBUTE_CHAR2" VARCHAR2(240 BYTE), 
	"LINE_ATTRIBUTE_CHAR3" VARCHAR2(240 BYTE), 
	"LINE_ATTRIBUTE_CHAR4" VARCHAR2(240 BYTE), 
	"LINE_ATTRIBUTE_CHAR5" VARCHAR2(240 BYTE), 
	"LINE_ATTRIBUTE_CHAR6" VARCHAR2(240 BYTE), 
	"LINE_ATTRIBUTE_CHAR7" VARCHAR2(240 BYTE), 
	"LINE_ATTRIBUTE_CHAR8" VARCHAR2(240 BYTE), 
	"LINE_ATTRIBUTE_CHAR9" VARCHAR2(240 BYTE), 
	"LINE_ATTRIBUTE_CHAR10" VARCHAR2(240 BYTE), 
	"LINE_ATTRIBUTE_CHAR11" VARCHAR2(240 BYTE), 
	"LINE_ATTRIBUTE_CHAR12" VARCHAR2(240 BYTE), 
	"LINE_ATTRIBUTE_CHAR13" VARCHAR2(240 BYTE), 
	"LINE_ATTRIBUTE_CHAR14" VARCHAR2(240 BYTE), 
	"LINE_ATTRIBUTE_CHAR15" VARCHAR2(240 BYTE), 
	"LINE_ATTRIBUTE_CHAR16" VARCHAR2(240 BYTE), 
	"LINE_ATTRIBUTE_CHAR17" VARCHAR2(240 BYTE), 
	"LINE_ATTRIBUTE_CHAR18" VARCHAR2(240 BYTE), 
	"LINE_ATTRIBUTE_CHAR19" VARCHAR2(240 BYTE), 
	"LINE_ATTRIBUTE_CHAR20" VARCHAR2(240 BYTE), 
	"LINE_ATTRIBUTE_NUMBER1" NUMBER, 
	"LINE_ATTRIBUTE_NUMBER2" NUMBER, 
	"LINE_ATTRIBUTE_NUMBER3" NUMBER, 
	"LINE_ATTRIBUTE_NUMBER4" NUMBER, 
	"LINE_ATTRIBUTE_NUMBER5" NUMBER, 
	"LINE_ATTRIBUTE_NUMBER6" NUMBER, 
	"LINE_ATTRIBUTE_NUMBER7" NUMBER, 
	"LINE_ATTRIBUTE_NUMBER8" NUMBER, 
	"LINE_ATTRIBUTE_NUMBER9" NUMBER, 
	"LINE_ATTRIBUTE_NUMBER10" NUMBER, 
	"LINE_ATTRIBUTE_DATE1" DATE, 
	"LINE_ATTRIBUTE_DATE2" DATE, 
	"LINE_ATTRIBUTE_DATE3" DATE, 
	"LINE_ATTRIBUTE_DATE4" DATE, 
	"LINE_ATTRIBUTE_DATE5" DATE, 
	"LINE_ATTRIBUTE_TIMESTAMP1" TIMESTAMP (6), 
	"LINE_ATTRIBUTE_TIMESTAMP2" TIMESTAMP (6), 
	"LINE_ATTRIBUTE_TIMESTAMP3" TIMESTAMP (6), 
	"LINE_ATTRIBUTE_TIMESTAMP4" TIMESTAMP (6), 
	"LINE_ATTRIBUTE_TIMESTAMP5" TIMESTAMP (6), 
	"RETURN_REASON" VARCHAR2(4000 BYTE), 
	"RETURN_TYPE" VARCHAR2(4000 BYTE), 
	"ORIGINAL_SALES_ORDER" VARCHAR2(240 BYTE), 
	"WMS_REQ_PAYLOAD" CLOB, 
	"WMS_SO_RESP_OBJECT" CLOB, 
	"WMS_TRANSACTION_ID" VARCHAR2(4000 BYTE), 
	"WMS_RESULT" VARCHAR2(4000 BYTE), 
	"WMS_MESSAGETYPE" VARCHAR2(4000 BYTE), 
	"WMS_MESSAGECODE" VARCHAR2(4000 BYTE), 
	"WMS_MESSAGE" VARCHAR2(4000 BYTE), 
	"WMS_SUCCESS" VARCHAR2(30 BYTE)
   )