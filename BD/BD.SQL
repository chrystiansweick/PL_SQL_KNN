/******************************************************************************/
/***          Generated by IBExpert 2012.02.21 27/07/2017 21:29:56          ***/
/******************************************************************************/

SET SQL DIALECT 3;

SET NAMES WIN1252;

SET CLIENTLIB 'fbclient.dll';

CREATE DATABASE '127.0.0.1/3051:C:\Users\chrys\Desktop\estudo machine\BD\KNN.fdb'
USER 'SYSDBA' PASSWORD 'masterkey'
PAGE_SIZE 4096
DEFAULT CHARACTER SET WIN1252 COLLATION WIN1252;



SET TERM ^ ; 



/******************************************************************************/
/***                           Stored Procedures                            ***/
/******************************************************************************/

CREATE PROCEDURE PRC_COMPARA_ACERTOS
RETURNS (
    DIFERENTE BIGINT,
    IGUAL INTEGER,
    ID_TEST INTEGER)
AS
BEGIN
  SUSPEND;
END^





CREATE PROCEDURE PRC_RESULTADO_FINAL
RETURNS (
    ACERTOS INTEGER,
    ERROS INTEGER,
    EFICACIA VARCHAR(10))
AS
BEGIN
  SUSPEND;
END^






SET TERM ; ^



/******************************************************************************/
/***                                 Tables                                 ***/
/******************************************************************************/



CREATE TABLE TBL_TEST (
    ID_TEST  INTEGER NOT NULL,
    SAPATO   NUMERIC(12,4),
    ALTURA   NUMERIC(12,4),
    CLASSE   VARCHAR(40)
);

CREATE TABLE TBL_TRAIN (
    ID_TRAIN  INTEGER NOT NULL,
    SAPATO    NUMERIC(12,4),
    ALTURA    NUMERIC(12,4),
    CLASSE    VARCHAR(40)
);



/******************************************************************************/
/***                                 Views                                  ***/
/******************************************************************************/


/* View: VW_DISTANCIA */
CREATE VIEW VW_DISTANCIA(
    DISTANCIA,
    ID_TRAIN,
    CLASSE_TRAIN,
    ID_TEST,
    CLASSE_TEST)
AS
select
CAST(sqrt(POWER((e.sapato-t.sapato),2)+POWER((e.altura-t.altura),2))AS NUMERIC(14,4))as distancia,
t.id_train,
t.classe,
e.id_test,
e.classe

from tbl_train t
inner join tbl_test e on t.id_train is not null
order by 1 asc
;




/******************************************************************************/
/***                              Primary Keys                              ***/
/******************************************************************************/

ALTER TABLE TBL_TEST ADD CONSTRAINT PK_TBL_TEST PRIMARY KEY (ID_TEST);
ALTER TABLE TBL_TRAIN ADD CONSTRAINT PK_TBL_TRAIN PRIMARY KEY (ID_TRAIN);


/******************************************************************************/
/***                           Stored Procedures                            ***/
/******************************************************************************/


SET TERM ^ ;

ALTER PROCEDURE PRC_COMPARA_ACERTOS
RETURNS (
    DIFERENTE BIGINT,
    IGUAL INTEGER,
    ID_TEST INTEGER)
AS
declare variable IDTEST integer;
begin

for select e.id_test from tbl_test e
into idtest

DO
BEGIN
 WHILE(idtest > 0) DO
  BEGIN
select count(*) from (
select first 5 * from vw_distancia v
where v.id_test = :idtest )
where classe_train <> classe_test
INTO diferente;

select count(*) from (
select first 5 * from vw_distancia v
where v.id_test = :idtest )
where classe_train = classe_test
INTO  igual ;

id_test = idtest;


 idtest = 0;

end
 suspend;
END
END^


ALTER PROCEDURE PRC_RESULTADO_FINAL
RETURNS (
    ACERTOS INTEGER,
    ERROS INTEGER,
    EFICACIA VARCHAR(10))
AS
declare variable COUNT_ACERTO integer;
declare variable COUNT_ERRO integer;
begin

select
COUNT(*) FROM prc_compara_acertos pA
WHERE PA.igual > PA.diferente
INTO COUNT_ACERTO;
select
COUNT(*) FROM prc_compara_acertos pe
WHERE Pe.igual < Pe.diferente
into COUNT_ERRO;
BEGIN
 ACERTOS  = :COUNT_ACERTO;
 ERROS    = :COUNT_ERRO;
 EFICACIA = CAST(CAST((:COUNT_ACERTO*100)/(:COUNT_ACERTO+:COUNT_ERRO)AS NUMERIC(2,2))as VARCHAR(6))||'%';

END
 suspend;
END^



SET TERM ; ^
