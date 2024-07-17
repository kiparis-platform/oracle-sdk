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

begin
  DBMS_NETWORK_ACL_ADMIN.UNASSIGN_ACL
  (
    ACL        => 'kiparis-gateway.xml',
    HOST       => 'YOUR_HOST_NAME',
    LOWER_PORT => 'YOUR_LOWER_PORT',
    UPPER_PORT => 'YOUR_UPPER_PORT'
  );
exception
  when OTHERS then
    null;
end;
/

commit;
/

begin
  DBMS_NETWORK_ACL_ADMIN.DELETE_PRIVILEGE
  (
    ACL         => 'kiparis-gateway.xml',
    PRINCIPAL   => 'YOUR_SCHEMA_NAME',
    IS_GRANT    => false,
    PRIVILEGE   => 'connect'
  );
exception
  when OTHERS then
    null;
end;
/

commit;
/

begin
  DBMS_NETWORK_ACL_ADMIN.DROP_ACL
  (
    ACL         => 'kiparis-gateway.xml'
  );
exception
  when OTHERS then
    null;
end;
/

commit;
/