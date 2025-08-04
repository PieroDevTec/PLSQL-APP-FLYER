CREATE OR REPLACE PACKAGE APP_FLYER.PKG_SERV_APP_FLYER
--------------------------------------------------------------------------------
--  📦 PAQUETE        : PKG_SERV_APP_FLYER
--  👤 AUTOR          : Piero Alvarez
--  🗓  FECHA CREACIÓN: 03/08/2025
--  🧩 MÓDULO         : [Aplicacion de FLyers.]  [Version Actual] v.1.0.0
--
--  📝 DESCRIPCIÓN
--     Este paquete contiene lógica de negocio relacionada al guardado y listados de los flyers.
--     Incluye funciones y procedimientos para:
--       - [Ej. Guardar los flyers]
--       - [Ej. Guardar los documentos adjuntos(pdf,word,excel, google drive) del flyer]
--       - [Ej. Listar los flyers]
--       - [Ej. Listar los documentos adjuntos(pdf,word,excel,google drive) del flyer]
--
--  📂 DEPENDENCIAS
--     - Tablas : TP_FLYER, TA_TIPO_ADJU,TP_ADJU
--     - Paquetes: APP_FLYER.PKG_DAO_APP_FLYER,PKG_UTIL.MSG_ERROR_GENERAL,PKG_UTIL.NO_APP, PKG_UTIL.CO_PDF, PKG_UTIL.CO_EXCEL,PKG_UTIL.CO_WORD,PKG_UTIL.CO_URL_DRIVE.
--
--  🔐 PERMISOS NECESARIOS
--     - NINGUNO.
--
--  🛠 HISTORIAL DE CAMBIOS
--     - [03/08/2025] Creación del procedimiento SP_LIST_ADJU (Piero Alvarez)
--     - [03/08/2025] Creación del procedimiento SP_GUAR_ADJUNTO (Piero Alvarez)
--     - [03/08/2025] Creación del procedimiento SP_LIST_FLYERS (Piero Alvarez)
--     - [03/08/2025] Creación del procedimiento SP_GUAR_FLYER (Piero Alvarez)
--     - [03/08/2025] Creación del procedimiento SP_LIST_TIPO_ADJU (Piero Alvarez)
--     - [03/08/2025] Creación del procedimiento SP_GUAR_TIPO_ADJU (Piero Alvarez)
--     - [03/08/2025] Creación del paquete PKG_SERV_APP_FLYER (Piero Alvarez)
--------------------------------------------------------------------------------
AS
  PROCEDURE SP_GUAR_TIPO_ADJU(
     PIV_NO_TIPO_ADJU VARCHAR2,
     PII_CO_USER INTEGER,
     POI_CODE OUT INTEGER,
     POV_MSG OUT VARCHAR2
  );
  PROCEDURE SP_LIST_TIPO_ADJU(
     PII_CO_USER INTEGER,
     POCUR OUT SYS_REFCURSOR,
     POI_CODE OUT INTEGER,
     POV_MSG OUT VARCHAR2
  );
  PROCEDURE SP_GUAR_FLYER(
    PIV_NO_FLYER VARCHAR2,
    PIB_IMG BLOB,
    PII_CO_USER INTEGER,
    POI_CODE OUT INTEGER,
    POV_MSG OUT VARCHAR2
  );
  PROCEDURE SP_LIST_FLYERS(
     PII_CO_USER INTEGER,
     POI_CODE OUT INTEGER,
     POV_MSG OUT VARCHAR2,
     POCUR OUT SYS_REFCURSOR  
  );

  PROCEDURE SP_GUAR_ADJUNTO (
    PIC_CO_TIPO_ADJU CHAR,
    PIC_CO_FLYER CHAR,
    PIV_NO_ADJUNTO VARCHAR2,
    PIB_DOC_BLOB BLOB,
    PIV_URL_DRIVE VARCHAR2,
    PII_CO_USER INTEGER,
    POI_CODE OUT INTEGER,
    POV_MSG OUT VARCHAR2
  );
  PROCEDURE SP_LIST_ADJU(
    PIC_CO_FLYER CHAR,
    PII_CO_USER INTEGER,
    POCUR OUT SYS_REFCURSOR,
    POI_CODE OUT INTEGER,
    POV_MSG OUT VARCHAR2
  );
END;
/
CREATE OR REPLACE PACKAGE BODY APP_FLYER.PKG_SERV_APP_FLYER
AS
  PROCEDURE SP_GUAR_TIPO_ADJU(
     PIV_NO_TIPO_ADJU VARCHAR2,
     PII_CO_USER INTEGER,
     POI_CODE OUT INTEGER,
     POV_MSG OUT VARCHAR2
  )
  IS
  V_CO_INS INTEGER := 0;
  V_MSG_INS VARCHAR2(30) := '-';
  BEGIN
    DBMS_APPLICATION_INFO.set_module(module_name=>APP_FLYER.PKG_UTIL.NO_APP,action_name=>'SP_GUAR_TIPO_ADJU::PROCEDIMIENTO PARA EL GUARDADO DE TIPOS DE ADJUNTOS.');
    DBMS_APPLICATION_INFO.set_client_info(client_info=>PII_CO_USER);
    
    IF(PIV_NO_TIPO_ADJU IS NULL ) OR LENGTH(PIV_NO_TIPO_ADJU) <= 1 THEN
       POI_CODE := '1';
       POV_MSG := 'El nombre del tipo adjunto no puede ser nulo y debe tener mas de 1 caracter.';
       RETURN;
    END IF;
    
    -- INSERTANDO EL NUEVO TIPO DE ADJUNTO
    APP_FLYER.PKG_DAO_APP_FLYER.INS_TIPO_ADJU(
                                          PIV_NO_TIPO_ADJU,
                                          PII_CO_USER);
                                          
   COMMIT;
   POI_CODE := 0; 
   POV_MSG := 'Se guardo satisfactoriamente el tipo de adjunto.';
  EXCEPTION 
    WHEN OTHERS THEN
      POI_CODE := '2';
      POV_MSG := PKG_UTIL.MSG_ERROR_GENERAL;
      APP_FLYER.PKG_DAO_APP_FLYER.INS_ERROR_LOG(APP_FLYER.PKG_UTIL.NO_APP,PII_CO_USER);
      ROLLBACK;
  END SP_GUAR_TIPO_ADJU;
  
  PROCEDURE SP_LIST_TIPO_ADJU(
     PII_CO_USER INTEGER,
     POCUR OUT SYS_REFCURSOR,
     POI_CODE OUT INTEGER,
     POV_MSG OUT VARCHAR2
  )
  IS
  V_VERIF_DATA INTEGER := 0;
  BEGIN
     DBMS_APPLICATION_INFO.set_module(module_name=>APP_FLYER.PKG_UTIL.NO_APP,action_name=>'SP_LIST_TIPO_ADJU::LISTA EL TIPO DE ADJUNTOS.');
     DBMS_APPLICATION_INFO.set_client_info(client_info=>PII_CO_USER);
     
     SELECT COUNT(0) INTO V_VERIF_DATA FROM APP_FLYER.TA_TIPO_ADJU
     WHERE
     ES_TIPO_ADJU = 'A';
     
     OPEN POCUR FOR
       SELECT ID_TIPO_ADJU AS CODIGO ,NO_TIPO_ADJU AS NOMBRE FROM APP_FLYER.TA_TIPO_ADJU WHERE ES_TIPO_ADJU = 'A';
    POI_CODE := 0;
    POV_MSG := 'Se encontraron resultados satisfactoriamente.';
     
  EXCEPTION 
    WHEN NO_DATA_FOUND THEN
        POI_CODE := 1;
        POV_MSG := 'No se ha encontrado resultados.';
    WHEN OTHERS THEN
        POI_CODE := 2;
        POV_MSG  := APP_FLYER.PKG_UTIL.MSG_ERROR_GENERAL;
        APP_FLYER.PKG_DAO_APP_FLYER.INS_ERROR_LOG(APP_FLYER.PKG_UTIL.NO_APP,PII_CO_USER);
  END SP_LIST_TIPO_ADJU;
  
  PROCEDURE SP_GUAR_FLYER(
    PIV_NO_FLYER VARCHAR2,
    PIB_IMG BLOB,
    PII_CO_USER INTEGER,
    POI_CODE OUT INTEGER,
    POV_MSG OUT VARCHAR2
  )
  IS
  --V_IMG_BLOB BLOB;
  BEGIN
    DBMS_APPLICATION_INFO.set_module(module_name=>APP_FLYER.PKG_UTIL.NO_APP,action_name=>'SP_GUAR_FLYER::PROCEDIMIENTO QUE GUARDA LOS FLYERS.');
    DBMS_APPLICATION_INFO.SET_CLIENT_INFO(CLIENT_INFO=>PII_CO_USER);
    
    IF PIV_NO_FLYER IS NULL OR LENGTH(PIV_NO_FLYER) <= 4 THEN
       POI_CODE := 1;
       POV_MSG := 'El nombre del flyer no puede ser nulo y debe tener mas de 4 caracteres.';
       RETURN;
    END IF;
    
    -- CONDICION PARA EL BLOB
    IF PIB_IMG IS NULL OR DBMS_LOB.GETLENGTH(PIB_IMG) = 0 THEN
      POI_CODE := 1;
      POV_MSG := 'Vuelva a subir la imagen del flyer.';
      RETURN;
    END IF;
    -- BLOB DE PRUEBA
    -- SELECT IMG_BLOB INTO V_IMG_BLOB  FROM MRSQL.TA_BLOB WHERE NO_BLOB = 'scarlet_jhohanson.jpg'; 
    
    APP_FLYER.PKG_DAO_APP_FLYER.INS_FLYER(
       PIV_NO_FLYER,
       PIB_IMG,
       PII_CO_USER
    );
    COMMIT;
    POI_CODE := 0;
    POV_MSG := 'Se guardo el flyer correctamente.';
  EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
       POI_CODE := 1;
       POV_MSG := 'El nombre del flyer ya se encuentra registrado, ingrese otro nombre para el flyer.';
    WHEN OTHERS THEN
        POI_CODE := 2;
        POV_MSG  := APP_FLYER.PKG_UTIL.MSG_ERROR_GENERAL;
        APP_FLYER.PKG_DAO_APP_FLYER.INS_ERROR_LOG(APP_FLYER.PKG_UTIL.NO_APP,PII_CO_USER);
        ROLLBACK;
  END SP_GUAR_FLYER;
  
  PROCEDURE SP_LIST_FLYERS(
     PII_CO_USER INTEGER,
     POI_CODE OUT INTEGER,
     POV_MSG OUT VARCHAR2,
     POCUR OUT SYS_REFCURSOR  
  )
  IS 
  V_VERIF_DATA BINARY_INTEGER:= 0;
  BEGIN
    DBMS_APPLICATION_INFO.set_module(module_name=>APP_FLYER.PKG_UTIL.NO_APP,action_name=>'SP_LIST_FLYERS::PROCEDIMIENTO PARA LISTAR LOS FLYERS.');
    DBMS_APPLICATION_INFO.SET_CLIENT_INFO(CLIENT_INFO=>PII_CO_USER);
    
    SELECT COUNT(*) INTO V_VERIF_DATA FROM APP_FLYER.TP_FLYER
    WHERE
    ES_FLYER = 'A';
    
    IF V_VERIF_DATA = 0 THEN
      POI_CODE := 1;
      POV_MSG := 'No se encontraron resultados.';
      RETURN;
    END IF;
    -- DEVOLVER LOS FLYER EN BLOBS.
    POI_CODE := 0;
    POV_MSG  := 'Se encontraron resultados satisfactoriamente.';
    OPEN POCUR FOR
        SELECT * FROM TABLE(APP_FLYER.PKG_DAO_APP_FLYER.SEL_FLYER);
  EXCEPTION
    WHEN NO_DATA_FOUND THEN 
      POI_CODE := 1;
      POV_MSG := 'No se encontraron resultados.'; 
    WHEN OTHERS THEN 
        POI_CODE := 2;
        POV_MSG  := APP_FLYER.PKG_UTIL.MSG_ERROR_GENERAL;
        APP_FLYER.PKG_DAO_APP_FLYER.INS_ERROR_LOG(APP_FLYER.PKG_UTIL.NO_APP,PII_CO_USER);
        ROLLBACK;
  END SP_LIST_FLYERS;
  
  PROCEDURE SP_GUAR_ADJUNTO (
    PIC_CO_TIPO_ADJU CHAR,
    PIC_CO_FLYER CHAR,
    PIV_NO_ADJUNTO VARCHAR2,
    PIB_DOC_BLOB BLOB,
    PIV_URL_DRIVE VARCHAR2,
    PII_CO_USER INTEGER,
    POI_CODE OUT INTEGER,
    POV_MSG OUT VARCHAR2
  )
  IS
  BEGIN
    DBMS_APPLICATION_INFO.set_module(module_name=>APP_FLYER.PKG_UTIL.NO_APP,action_name=>'SP_LIST_FLYERS::PROCEDIMIENTO PARA GUARDAR LOS ADJUNTOS.');
    DBMS_APPLICATION_INFO.SET_CLIENT_INFO(CLIENT_INFO=>PII_CO_USER);
    
    IF PIC_CO_TIPO_ADJU IS NULL OR PIC_CO_FLYER IS NULL THEN
      POI_CODE := 1;
      POV_MSG := 'El tipo adjunto o el flyer no se ha seleccionado correctamente.';
      RETURN;
    END IF;
    IF PIC_CO_TIPO_ADJU IN (APP_FLYER.PKG_UTIL.CO_URL_DRIVE) THEN
       IF PIV_URL_DRIVE IS NULL THEN
          POI_CODE := 1;
          POV_MSG := 'Ingrese nuevamente la url del google drive.';
          RETURN;
       END IF;
    END IF;
    
    IF PIC_CO_TIPO_ADJU IN (APP_FLYER.PKG_UTIL.CO_PDF,APP_FLYER.PKG_UTIL.CO_WORD,APP_FLYER.PKG_UTIL.CO_EXCEL) THEN
       IF PIB_DOC_BLOB IS NULL OR DBMS_LOB.GETLENGTH(PIB_DOC_BLOB) = 0 THEN
          POI_CODE := 1;
          POV_MSG := 'Vuelva cargar el documento.';
          RETURN;
       END IF;
    END IF;
    
    IF PIV_NO_ADJUNTO IS NULL OR LENGTH(PIV_NO_ADJUNTO) <= 4 THEN
       POI_CODE := 1;
       POV_MSG := 'El nombre del tipo adjunto no puede ser nulo y debe tener mas de 4 caracteres.';
       RETURN;
    END IF;
        
    -- INSERTANDO Y CREANDO EL DOC ADJUNTO 
    APP_FLYER.PKG_DAO_APP_FLYER.INS_ADJU(
      PIC_CO_TIPO_ADJU,
      PIC_CO_FLYER ,
      PIV_NO_ADJUNTO,
      PIB_DOC_BLOB,
      PIV_URL_DRIVE,
      PII_CO_USER
    );
    COMMIT;
    POI_CODE := 0;
    POV_MSG := 'Se guardo satisfactoriamente el documento adjunto.';    
  EXCEPTION 
    WHEN OTHERS THEN
        POI_CODE := 2;
        POV_MSG  := APP_FLYER.PKG_UTIL.MSG_ERROR_GENERAL;
        APP_FLYER.PKG_DAO_APP_FLYER.INS_ERROR_LOG(APP_FLYER.PKG_UTIL.NO_APP,PII_CO_USER);
        ROLLBACK;
  END SP_GUAR_ADJUNTO;
  
  PROCEDURE SP_LIST_ADJU(
    PIC_CO_FLYER CHAR,
    PII_CO_USER INTEGER,
    POCUR OUT SYS_REFCURSOR,
    POI_CODE OUT INTEGER,
    POV_MSG OUT VARCHAR2
  )
  IS 
  V_VERIF_FLYER BINARY_INTEGER := 0;
  V_VERIF_ADJ_FLYER BINARY_INTEGER:= 0;
  BEGIN
    DBMS_APPLICATION_INFO.set_module(module_name=>APP_FLYER.PKG_UTIL.NO_APP,action_name=>'SP_LIST_ADJU::PROCEDIMIENTO LISTAR LOS ADJUNTOS DE CADA FLYERS.');
    DBMS_APPLICATION_INFO.SET_CLIENT_INFO(CLIENT_INFO=>PII_CO_USER);
    
    SELECT COUNT(*) INTO V_VERIF_FLYER  FROM APP_FLYER.TP_FLYER WHERE ID_FLYER = PIC_CO_FLYER;
    SELECT COUNT(*) INTO V_VERIF_ADJ_FLYER FROM APP_FLYER.TP_ADJU WHERE ID_FLYER = PIC_CO_FLYER;
    
    IF V_VERIF_FLYER = 0 THEN
       POI_CODE := 1;
       POV_MSG := 'El nombre del flyer no se encuentra registrado.';
       RETURN;
    END IF;
    
    IF V_VERIF_ADJ_FLYER = 0 THEN
       POI_CODE := 0;
       POV_MSG := 'El flyer no tiene documentos adjuntos.';
       RETURN;
    END IF;

    POI_CODE := 0;
    POV_MSG := 'Se encontraron resultados satisfactoriamente.';
    OPEN POCUR FOR
       SELECT * FROM TABLE(APP_FLYER.PKG_DAO_APP_FLYER.SEL_ADJU_FLYER(PIC_CO_FLYER));
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      POI_CODE := 1;
      POV_MSG := 'Verificar le nombres del flyer, de lo contrario comunicarse con el area de soporte.';
    WHEN OTHERS THEN
        POI_CODE := 2;
        POV_MSG  := APP_FLYER.PKG_UTIL.MSG_ERROR_GENERAL;
        APP_FLYER.PKG_DAO_APP_FLYER.INS_ERROR_LOG(APP_FLYER.PKG_UTIL.NO_APP,PII_CO_USER);
        ROLLBACK;
  END;

END;
/