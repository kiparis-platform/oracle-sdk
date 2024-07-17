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

/* Таблица данных шины сообщений (KIPARIS Message Bus Data Table) */
create table KMBDATA
(
  /* Идентификатор */
  IDENT       number(17) not null,
  /* Пользователь */
  AUTHID      varchar2(30) not null,
  /* Внешний идентификатор сеанса */
  CONNECT_EXT varchar2(255) not null,
  /* Идентификатор сообщения */
  ID          varchar2(36) not null,
  /* Тело запроса */
  REQUEST     blob not null,
  /* Тело ответа */
  RESPONSE    blob default null,
  /* Статус:
      0 - новый запрос
      1 - получен ответ
      2 - ошибка
  */
  STATUS      number(1) default 0 not null
              constraint C_KMBDATA_STATUS_VAL check(STATUS in (0, 1, 2)),
  /* Примечание */
  NOTE        varchar2(4000) default null
              constraint C_KMBDATA_NOTE_NB check(NOTE is null or rtrim(NOTE) is not null),
  /* Первичный ключ */
  constraint C_KMBDATA_PK primary key(ID)
);
/

/* Триггер перед добавлением */
create or replace trigger T_KMBDATA_BINSERT
  before insert on KMBDATA for each row
begin
  /* Инициализация */
  :new.IDENT := GEN_IDENT;
  :new.AUTHID := UTILIZER;
  :new.CONNECT_EXT := PKG_SESSION.GET_CONNECT_EXT;

  /* Установка использования временной таблицы  */
  PKG_TEMP.SET_TEMP_USED('KMBDATA', :new.IDENT);
end;
/

show errors trigger T_KMBDATA_BINSERT;
/

/* Базовое добавление записи шины сообщений */
create or replace procedure P_KMBDATA_BINSERT
(
  sID             in varchar2,  -- идентификатор сообщения
  bREQUEST        in blob       -- тело запроса
)
as
begin
  insert into KMBDATA (ID, REQUEST) values (sID, bREQUEST);
end;
/

show errors procedure P_KMBDATA_BINSERT;
/

/* Базовое добавление записи шины сообщений (в автономной транзакции) */
create or replace procedure P_KMBDATA_BINSERT_AT
(
  sID             in varchar2,  -- идентификатор сообщения
  bREQUEST        in blob       -- тело запроса
)
as
  pragma          AUTONOMOUS_TRANSACTION;
begin
  if (false) then
    PKG_AUTONOMOUS.EXECUTE_PROCEDURE(null);
  end if;

  P_KMBDATA_BINSERT(sID, bREQUEST);

  commit;
end;
/

show errors procedure P_KMBDATA_BINSERT_AT;
/

/* PG: Базовое добавление записи шины сообщений (в автономной транзакции) */
create or replace procedure P_KMBDATA_BINSERT_AT$PG
(
  sID             in varchar2,  -- идентификатор сообщения
  bREQUEST        in blob       -- тело запроса
)
as
begin
  P_NECESSARY_RECREATE_STABLE('P_KMBDATA_BINSERT_AT');
end;
/

show errors procedure P_KMBDATA_BINSERT_AT$PG;
/

/* Базовое исправление записи шины сообщений */
create or replace procedure P_KMBDATA_BUPDATE
(
  sID             in varchar2,    -- идентификатор сообщения
  bRESPONSE       in blob,        -- содержимое ответа
  nSTATUS         in number,      -- статус (0 - новый запрос, 1 - получен ответ, 2 - ошибка)
  sNOTE           in varchar2     -- примечание
)
as
begin
  update KMBDATA
     set RESPONSE = bRESPONSE,
         STATUS = nSTATUS,
         NOTE = sNOTE
   where ID = sID;

  if (SQL%NOTFOUND) then
    P_EXCEPTION(0, 'Запись шины сообщений с идентификатором "%s" не найдена.', sID);
  end if;
end;
/

show errors procedure P_KMBDATA_BUPDATE;
/

/* Базовое исправление записи шины сообщений (в автономной транзакции) */
create or replace procedure P_KMBDATA_BUPDATE_AT
(
  sID             in varchar2,  -- идентификатор сообщения
  bRESPONSE       in blob,      -- содержимое ответа
  nSTATUS         in number,    -- статус (0 - новый запрос, 1 - получен ответ, 2 - ошибка)
  sNOTE           in varchar2   -- примечание
)
as
  pragma          AUTONOMOUS_TRANSACTION;
begin
  /* Обозначение вызова */
  if (false) then
    PKG_AUTONOMOUS.EXECUTE_PROCEDURE(null);
  end if;

  P_KMBDATA_BUPDATE(sID, bRESPONSE, nSTATUS, sNOTE);

  commit;
end;
/

show errors procedure P_KMBDATA_BUPDATE_AT;
/

/* PG: Базовое исправление записи шины сообщений (в автономной транзакции) */
create or replace procedure P_KMBDATA_BUPDATE_AT$PG
(
  sID             in varchar2,  -- идентификатор сообщения
  bRESPONSE       in blob,      -- содержимое ответа
  nSTATUS         in number,    -- статус (0 - новый запрос, 1 - получен ответ, 2 - ошибка)
  sNOTE           in varchar2   -- примечание
)
as
begin
  P_NECESSARY_RECREATE_STABLE('P_KMBDATA_BUPDATE_AT');
end;
/

show errors procedure P_KMBDATA_BUPDATE_AT$PG;
/

/* Пакет для работы с шиной сообщений */
create or replace package PKG_KMB
as
  /* Получить запрос */
  procedure GET_REQUEST
  (
    sID           in varchar2,  -- идентификатор сообщения
    bREQUEST      out blob      -- тело запроса
  );

  /* Установить запрос */
  procedure SET_REQUEST
  (
    bREQUEST      in blob,      -- тело запроса
    sID           out varchar2  -- идентификатор сообщения
  );

  /* Получить ответ */
  procedure GET_RESPONSE
  (
    sID           in varchar2,  -- идентификатор сообщения
    bRESPONSE     out blob      -- тело ответа
  );

  /* Установить ответ */
  procedure SET_RESPONSE
  (
    sID           in varchar2,  -- идентификатор сообщения
    bRESPONSE     in blob       -- тело ответа
  );

  /* Отправить запрос */
  procedure SEND
  (
    nFLAG_SMART   in number,    -- признак генерации исключения (0 - да, 1 - нет)
    sTOPIC        in varchar2,  -- очередь сообщений
    sID           in varchar2,  -- идентификатор сообщения
    nTIMEOUT      in number     -- таймаут ожидания ответа (секунды)
  );

  /* Установить ошибку */
  procedure SET_ERROR
  (
    sID           in varchar2,  -- идентификатор сообщения
    sNOTE         in varchar2   -- текст ошибки
  );
end;
/

show errors package PKG_KMB;
/

/* Пакет для работы с шиной сообщений */
create or replace package body PKG_KMB
as
  /* Получить запрос */
  procedure GET_REQUEST
  (
    sID           in varchar2,  -- идентификатор сообщения
    bREQUEST      out blob      -- тело запроса
  )
  as
  begin
    begin
      select REQUEST into bREQUEST from KMBDATA where ID = sID;
    exception
      when NO_DATA_FOUND then
        P_EXCEPTION(0, 'Запись шины сообщений с идентификатором "%s" не найдена.', sID);
    end;
  end;

  /* Установить запрос */
  procedure SET_REQUEST
  (
    bREQUEST      in blob,      -- тело запроса
    sID           out varchar2  -- идентификатор сообщения
  )
  as
  begin
    sID := F_SYS_GUID;
    P_KMBDATA_BINSERT_AT(sID, bREQUEST);
  end;

  /* Получить ответ */
  procedure GET_RESPONSE
  (
    sID           in varchar2,  -- идентификатор сообщения
    bRESPONSE     out blob      -- тело ответа
  )
  as
  begin
    begin
      select RESPONSE into bRESPONSE from KMBDATA where ID = sID;
    exception
      when NO_DATA_FOUND then
        P_EXCEPTION(0, 'Запись шины сообщений с идентификатором "%s" не найдена.', sID);
    end;
  end;

  /* Установить ответ */
  procedure SET_RESPONSE
  (
    sID           in varchar2,  -- идентификатор сообщения
    bRESPONSE     in blob       -- тело ответа
  )
  as
  begin
    P_KMBDATA_BUPDATE_AT(sID, bRESPONSE, 1, null);
  end;

  /* Отправить запрос */
  procedure SEND
  (
    nFLAG_SMART   in number,    -- признак генерации исключения (0 - да, 1 - нет)
    sTOPIC        in varchar2,  -- очередь сообщений
    sID           in varchar2,  -- идентификатор сообщения
    nTIMEOUT      in number     -- таймаут ожидания ответа (секунды)
  )
  as
    nTIME_WAIT    number;
    nTIME_STAMP   number;
    rDATA         KMBDATA%rowtype;
  begin
    /* Отправить сообщение в очередь */
    PKG_KMQ.SEND(sTOPIC, sID);

    /* Инициализация таймаута */
    nTIME_WAIT := greatest(coalesce(nTIMEOUT, 0), 0);
    nTIME_STAMP := DBMS_UTILITY.GET_TIME;

    /* Ожидание ответа */
    loop
      if (nTIME_WAIT >= 1) then
        PKG_ADVISORY_LOCK.SLEEP(1);
      end if;

      /* Считывание записи */
      begin
        select * into rDATA from KMBDATA where ID = sID;
      exception
        when NO_DATA_FOUND then
          P_EXCEPTION(0, 'Запись шины сообщений с идентификатором "%s" не найдена.', sID);
      end;

      if (rDATA.STATUS != 0) then
        exit;
      end if;

      /* Проверка таймаута */
      if (nTIME_WAIT < 1 or (DBMS_UTILITY.GET_TIME - nTIME_STAMP) / 100 >= nTIME_WAIT) then
        exit;
      end if;
    end loop;

    if (rDATA.STATUS = 0) then
      P_EXCEPTION(nFLAG_SMART, 'Превышено время ожидания ответа (%s секунд) на сообщение с идентификатором "%s" в очереди сообщений "%s".', nTIMEOUT, sID, sTOPIC);
    end if;

    if (rDATA.STATUS = 2) then
      P_EXCEPTION(nFLAG_SMART, 'Ошибка "%s" при обработке сообщения с идентификатором "%s" в очереди сообщений "%s".', rDATA.NOTE, sID, sTOPIC);
    end if;
  end;

  /* Установить ошибку */
  procedure SET_ERROR
  (
    sID           in varchar2,  -- идентификатор сообщения
    sNOTE         in varchar2   -- текст ошибки
  )
  as
  begin
    P_KMBDATA_BUPDATE_AT(sID, null, 2, sNOTE);
  end;
end;
/

show errors package body PKG_KMB;
/

grant execute on PKG_KMB to PUBLIC;
/

/* Внутренний пакет для работы с очередью сообщений */
create or replace package PKG_KMQ_INT
as
  /* Отправка сообщения в очередь */
  procedure SEND
  (
    sBASE_URL       in varchar2,    -- базовый URL
    sMETHOD         in varchar2,    -- метод
    sCONTENT_TYPE   in varchar2,    -- тип контента
    sCONTENT        in varchar2,    -- контент
    sURL_PARAMS     in varchar2 
                      default null  -- параметры URL
  );
end;
/

show errors package PKG_KMQ_INT;
/

/* Внутренний пакет для работы с очередью сообщений */
create or replace package body PKG_KMQ_INT
as
  /* Отправка сообщения в очередь */
  procedure SEND
  (
    sBASE_URL       in varchar2,    -- базовый URL
    sMETHOD         in varchar2,    -- метод
    sCONTENT_TYPE   in varchar2,    -- тип контента
    sCONTENT        in varchar2,    -- контент
    sURL_PARAMS     in varchar2 
                      default null  -- параметры URL
  )
  as
    rREQUEST        UTL_HTTP.REQ;
    rRESPONSE       UTL_HTTP.RESP := null;
    sURL            varchar2(4000) := sBASE_URL;
    sRESPONSE_VAL   varchar2(4000);
  begin
    if rtrim(sURL_PARAMS) is not null then
      sURL := sURL || '/' || sURL_PARAMS;
    end if;

    rREQUEST := UTL_HTTP.BEGIN_REQUEST(sURL, sMETHOD);
    UTL_HTTP.SET_HEADER(rREQUEST, 'Content-Type', sCONTENT_TYPE);
    UTL_HTTP.SET_HEADER(rREQUEST, 'Content-Length', length(sCONTENT));
    UTL_HTTP.WRITE_TEXT(rREQUEST, sCONTENT);

    rRESPONSE := UTL_HTTP.GET_RESPONSE(rREQUEST);
    if rRESPONSE.STATUS_CODE not in (200, 201, 202) then
      UTL_HTTP.END_RESPONSE(rRESPONSE);
      P_EXCEPTION(0, 'Внутренняя ошибка обработки запроса: %s.', rRESPONSE.STATUS_CODE);
    end if;

    UTL_HTTP.READ_TEXT(rRESPONSE, sRESPONSE_VAL);
    UTL_HTTP.END_RESPONSE(rRESPONSE);
  exception
    when UTL_HTTP.END_OF_BODY then
      UTL_HTTP.END_RESPONSE(rRESPONSE);
    when others then 
      PKG_STATE.DIAGNOSTICS_STACKED;
      P_EXCEPTION(0, 'Не удалось поставить сообщение в очередь: %s.', PKG_STATE.SQL_ERRM);
  end;
end;
/

show errors package body PKG_KMQ_INT;
/

/* PG: Внутренний пакет для работы с очередью сообщений */
create or replace package PKG_KMQ_INT$PG
as
  /* Отправка сообщения в очередь */
  procedure SEND
  (
    sBASE_URL       in varchar2,    -- базовый URL
    sMETHOD         in varchar2,    -- метод
    sCONTENT_TYPE   in varchar2,    -- тип контента
    sCONTENT        in varchar2,    -- контент
    sURL_PARAMS     in varchar2 
                      default null  -- параметры URL
  );
end;
/

show errors package PKG_KMQ_INT$PG;
/

/* PG: Внутренний пакет для работы с очередью сообщений */
create or replace package body PKG_KMQ_INT$PG
as
  /* Отправка сообщения в очередь */
  procedure SEND
  (
    sBASE_URL       in varchar2,    -- базовый URL
    sMETHOD         in varchar2,    -- метод
    sCONTENT_TYPE   in varchar2,    -- тип контента
    sCONTENT        in varchar2,    -- контент
    sURL_PARAMS     in varchar2 
                      default null  -- параметры URL
  )
  as
  begin
    P_NECESSARY_RECREATE_VOLATILE('PKG_KMQ_INT.SEND'); 
  end;
end;
/

show errors package body PKG_KMQ_INT$PG;
/

/* Пакет для работы с очередью сообщений */
create or replace package PKG_KMQ
as
  /* Отправка сообщения в очередь */
  procedure SEND
  (
    sTOPIC        in varchar2,  -- очередь сообщений
    sMESSAGE      in varchar2   -- сообщение
  );
end;
/

show errors package PKG_KMQ;
/

/* Пакет для работы с очередью сообщений */
create or replace package body PKG_KMQ
as
  /* Формирование JSON-строки для отправки в очередь */
  function TO_JSON
  (
    sTOPIC        in varchar2,  -- очередь сообщений
    sMESSAGE      in varchar2   -- сообщение
  )
  return varchar2
  as
  begin
    return '{' || CR
        || '  "topic": "' || sTOPIC || '",' || CR
        || '  "message": "' || replace(sMESSAGE, '"', '\"') || '"' || CR
        || '}';
  end;

  /* Отправка сообщения в очередь */
  procedure SEND
  (
    sTOPIC        in varchar2,  -- очередь сообщений
    sMESSAGE      in varchar2   -- сообщение
  )
  as
    sBASE_URL     varchar2(4000) := GET_OPTIONS_STR('KiparisGatewayAddress');
  begin
    PKG_KMQ_INT.SEND(sBASE_URL, 'POST', 'application/json', TO_JSON(sTOPIC, sMESSAGE));
  end;
end;
/

show errors package body PKG_KMQ;
/

/* Начальная загрузка системных параметров */
begin
  /* KIPARIS Gateway Address */
  P_SYSTEM_INIT_OPTION
  (
    sUNITCODE       => 'OptionsSystemGlobal',
    sCODE           => 'KiparisGatewayAddress',
    sNAME           => 'KIPARIS Gateway Address',
    nNUMB           => 1000000000,
    nOPT_TYPE       => 1,
    nOPT_KIND       => 1,
    nOPT_MODE       => 0,
    nENTRY_TYPE     => 0,
    nDATA_TYPE      => 0,
    nSTR_WIDTH      => 240,
    nNUM_WIDTH      => null,
    nNUM_PRECISION  => null,
    sENUM_CODE      => null,
    sENUM_TEXT      => null,
    sLINK_UNITCODE  => null,
    sLINK_METHOD    => null,
    sLINK_INPARAM   => null,
    sLINK_OUTPARAM  => null,
    sLINK_OPTION    => null,
    sSTR_VALUE      => null,
    nNUM_VALUE      => null,
    dDATE_VALUE     => null
  );

  commit;
end;
/
