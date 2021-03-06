#!/usr/bin/env bash

#goto git root directory
git rev-parse && cd "$(git rev-parse --show-cdup)"

. development/env.sh

"${SQLCLI}" sys/${ORACLE_PWD}@//${CONNECTION_STR} AS SYSDBA <<-SQL
set echo on
drop user ${UT3_OWNER} cascade;
drop user ${UT3_RELEASE_VERSION_SCHEMA} cascade;
drop user ${UT3_TESTER} cascade;
drop user ${UT3_USER} cascade;

begin
  for i in (
    select decode(owner,'PUBLIC','drop public synonym "','drop synonym "'||owner||'"."')|| synonym_name ||'"' drop_orphaned_synonym from dba_synonyms a
     where not exists (select 1 from dba_objects b where (a.table_name=b.object_name and a.table_owner=b.owner or b.owner='SYS' and a.table_owner=b.object_name) )
       and a.table_owner not in ('SYS','SYSTEM')
  ) loop
    dbms_output.put_line(i.drop_orphaned_synonym);
    execute immediate i.drop_orphaned_synonym;
  end loop;
end;
/
exit
SQL
