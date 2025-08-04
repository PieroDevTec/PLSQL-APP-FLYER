CREATE OR REPLACE PACKAGE APP_FLYER.PKG_UTIL--------------------------------------------------------------------------------
--  📦 PAQUETE        : PKG_UTIL
--  👤 AUTOR          : Piero Alvarez
--  🗓  FECHA CREACIÓN: 03/08/2025
--  🧩 MÓDULO         : [Aplicacion de FLyers.]  [Version Actual] v.1.0.0
--
--  📝 DESCRIPCIÓN
--     Este paquete contiene el variables que sirven como constantes reutilizables y
--     funciones que nos sirve para debuguear con detalle los errores presentados en la aplicacion flyers.
--     Incluye funciones y procedimientos para:
--       - [Ej. Variable MSG_ERROR_GENERAL que indica un error general no contemplado en las excepciones.]
--       - [Ej. Variable NO_APP que indica el nombre del  aplicacion.]
--       - [Ej. funcion ERROR_LOG que nos detalle el error presentado en la aplicacion.]
--
--  📂 DEPENDENCIAS
--     - NINGUNA.
--
--  🔐 PERMISOS NECESARIOS
--     - NINGUNO
--
--  🛠 HISTORIAL DE CAMBIOS
--     - [03/08/2025] Creación del funcion ERROR_LOG (Piero Alvarez)
--     - [03/08/2025] Creación de la variables CO_PDF  (Piero Alvarez)
--     - [03/08/2025] Creación de la variables CO_EXCEL  (Piero Alvarez)
--     - [03/08/2025] Creación de la variables CO_WORD  (Piero Alvarez)
--     - [03/08/2025] Creación de la variables CO_URL_DRIVE  (Piero Alvarez)
--     - [03/08/2025] Creación del variable NO_APP (Piero Alvarez)
--     - [03/08/2025] Creación del variable MSG_ERROR_GENERAL (Piero Alvarez)
--     - [03/08/2025] Creación del paquete PKG_UTIL (Piero Alvarez)
--------------------------------------------------------------------------------
IS
  CO_PDF CONSTANT CHAR(5):='00001';
  CO_EXCEL CONSTANT CHAR(5) := '00005';
  CO_WORD CONSTANT CHAR(5) := '00006';
  CO_URL_DRIVE  CONSTANT CHAR(5) := '00003';
  MSG_ERROR_GENERAL CONSTANT VARCHAR2(100):= 'ERRBD::Ha ocurrido un problema en la Base de Datos, comunicarse con el area de soporte del Sistema.';
  NO_APP CONSTANT VARCHAR2(100) := 'APLICACION FLYER';
  
  FUNCTION ERROR_LOG
  RETURN CLOB;
END;
/
CREATE OR REPLACE PACKAGE BODY APP_FLYER.PKG_UTIL
IS
  FUNCTION ERROR_LOG
  RETURN
  CLOB
  IS
  V_MSG_ERROR CLOB;
  V_DES_ERROR VARCHAR2(10000);
  BEGIN
   V_DES_ERROR := SQLERRM;
   IF SQLCODE <> 0 THEN
     V_DES_ERROR := '*************** ERROR ***************'||CHR(10)||CHR(13);
     V_DES_ERROR := V_DES_ERROR ||'Objeto : ' ||$$PLSQL_UNIT|| CHR(10) ||CHR(13);
     V_DES_ERROR := V_DES_ERROR ||'Descripcion: '||SQLERRM||CHR(10)||CHR(13);
     V_DES_ERROR := V_DES_ERROR || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE() ||CHR(10)||CHR(13);
     V_DES_ERROR := V_DES_ERROR || '*************** BACKTRACE ***************';
   END IF;
   V_MSG_ERROR := V_DES_ERROR;
   RETURN V_MSG_ERROR;
  END;
END;
/