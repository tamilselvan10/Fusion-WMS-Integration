  CREATE TABLE "XX_WMS_SHIP_BATCH_DTLS_TB" 
   (	"BATCH_ID" VARCHAR2(50 BYTE), 
	"PICKING_BATCH_NAME" VARCHAR2(50 BYTE), 
	"CREATE_PICK_WAVE_RESP_OBJ" CLOB, 
	"CREATE_PICK_WAVE_STATUS" VARCHAR2(2 BYTE), 
	"CREATE_PICK_WAVE_MESSAGE" VARCHAR2(4000 BYTE), 
	"CREATE_PICK_WAVE_DATE" VARCHAR2(30 BYTE), 
	"RELEASE_PICK_WAVE_RESP_OBJ" CLOB, 
	"RELEASE_PICK_WAVE_STATUS" VARCHAR2(2 BYTE), 
	"RELEASE_PICK_WAVE_MESSAGE" VARCHAR2(4000 BYTE), 
	"RELEASE_PICK_WAVE_DATE" VARCHAR2(30 BYTE), 
	"CREATION_DATE" VARCHAR2(30 BYTE), 
	"LAST_UPDATE_DATE" VARCHAR2(30 BYTE)
   )