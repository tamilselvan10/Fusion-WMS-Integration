create table xx_fusion_cust_vend_dtls_tb
(
party_id                varchar2(30),
party_type              varchar2(10),
party_code              varchar2(30),
party_name              varchar2(240),
party_site_code         varchar2(240),
party_site_name         varchar2(240),
ship_to_location        varchar2(240),
party_site_address      varchar2(4000),
phone_number            varchar2(30),
email_address           varchar2(240),
credit_period_days      number,
credit_limit_amount     number,
attribute1              varchar2(240),
attribute2              varchar2(240),
attribute3              varchar2(240),
attribute4              varchar2(240),
attribute5              varchar2(240),
attribute6              varchar2(240),
attribute7              varchar2(240),
attribute8              varchar2(240),
attribute9              varchar2(240),
attribute10             varchar2(240),
attribute11             varchar2(240),
attribute12             varchar2(240),
attribute13             varchar2(240),
attribute14             varchar2(240),
attribute15             varchar2(240),
creation_date           date, 
last_update_date        date, 
import_method           varchar2(100 byte), 
status                  varchar2(240 byte), 
request_payload         clob,
response_object         clob,
transaction_id          varchar2(4000),
result                  varchar2(4000),
messagetype             varchar2(4000),
messagecode             varchar2(4000),
message                 varchar2(4000),
success                 varchar2(30)
);
