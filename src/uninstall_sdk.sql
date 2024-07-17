--------------------------------------------------------------------------------
-- Copyright 2024 Parusnik-Belgorod, LLC
--
-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at
--
-- http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--------------------------------------------------------------------------------

/* Удаление объектов БД */
drop package PKG_KMQ;
drop package PKG_KMQ_INT;
drop package PKG_KMQ_INT$PG;
drop package PKG_KMB;
drop procedure P_KMBDATA_BINSERT_AT;
drop procedure P_KMBDATA_BINSERT_AT$PG;
drop procedure P_KMBDATA_BINSERT;
drop procedure P_KMBDATA_BUPDATE_AT;
drop procedure P_KMBDATA_BUPDATE_AT$PG;
drop procedure P_KMBDATA_BUPDATE;
drop trigger T_KMBDATA_BINSERT;
drop table KMBDATA;

/* Удаление системных параметров */
begin
  delete from OPTIONS where CODE = 'KiparisGatewayAddress';

  commit;
end;