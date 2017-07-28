Implementação de KNN com PL/SQL
===================

Nesse notebook demonstrarei como aplicar o algoritimo KNN com o uso de PL/SQL

----------


Requisitos
-------------
Nesse exemplo estarei usando como SGBD o FIREBIRD. 
http://firebirdsql.org/
Estarei usando a IDE IBexpert para a execução e visualização dos comandos SQL e PL/SQL 
http://www.ibexpert.net/ibe/



> **Nota:**

> - Como a linguagem SQL  e PL/SQL muda muito pouco de um SGBD para outro é possivel seguir esse notebook com outras plataformas com por exemplo: Oracle,Mysql e outros.
#### Criando o Banco de Dados.
Com o Firebird devidamente instalado acesse a IDE IBexpert: 
Database > New Database... 
Na Janela que se abre informe as características do banco de dados.
![Criando Banco de Dados](http://senavalet.com/upload/data/knn/create%20%20database.jpg) 

#### Criando as Tabelas.
Segue código para criação da estrutura das tabelas. 
```sql
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

ALTER TABLE TBL_TEST ADD CONSTRAINT PK_TBL_TEST PRIMARY KEY (ID_TEST);
ALTER TABLE TBL_TRAIN ADD CONSTRAINT PK_TBL_TRAIN PRIMARY KEY (ID_TRAIN);

```
![Estrutura das tabelas](http://senavalet.com/upload/data/knn/Estrutura%20tabela.jpg)
Explicação: 
Serão criadas duas tabelas para o armazenamento das informações de X1,Y1 e X2,Y2
No exemplo elas receberão os nomes de TBL_TEST e TBL_TRAIN
Um campo ID para cada valor inserido. 
Um campo Sapato que sera nosso X na formula de calculo de distância. 
Um campo Altura que sera nosso Y na formula de calculo de distância. 
> **Nota:**

> - O arquivo de inserção dos dados utilizados no teste estão na repositório do projeto.


#### Criando uma visão para calcular a distância euclidiana entres os registros.
Segue código da estrutura da visão. 

```sql
/* VIEW: VW_DISTANCIA */
CREATE VIEW VW_DISTANCIA(
    DISTANCIA,
    ID_TRAIN,
    CLASSE_TRAIN,
    ID_TEST,
    CLASSE_TEST)
AS
SELECT
/*SQRT é a função que traz a raiz quadrada 
e POWER é a função que faz a potência */
CAST(SQRT(POWER((E.SAPATO-T.SAPATO),2)+POWER((E.ALTURA-T.ALTURA),2))AS NUMERIC(14,4))AS DISTANCIA,
T.ID_TRAIN,
T.CLASSE,
E.ID_TEST,
E.CLASSE

FROM TBL_TRAIN T
INNER JOIN TBL_TEST E ON T.ID_TRAIN IS NOT NULL
ORDER BY 1 ASC /* Ordenando para que sempre mostre os mais próximos (menor distância)*/
;


```
![Visão que calcula a distância](http://senavalet.com/upload/data/knn/vw_dist%C3%A2ncia.png)
Explicação: 
A visão retornará no seu primeiro campo a distância euclidiana entre o registro da tabela teste para cada registro da tabela treino. 
Pra que fique uma melhor visualização trouxe no corpo da visão o ID de treino e de teste e a classe de ambos. 
as ID's e classes também serão utilizadas no próximo passo da implementação do algorítimo. 



####Criando uma Procedure que  analisa os 5 vizinhos mais próximos e já verifica a quantidade de acerto e de erros quanto a classe do teste. 
Segue código da procedure. 
```sql
CREATE OR ALTER PROCEDURE PRC_COMPARA_ACERTOS 
RETURNS ( DIFERENTE BIGINT, IGUAL INTEGER, ID_TEST INTEGER) 
AS 
DECLARE VARIABLE IDTEST INTEGER;

BEGIN
FOR
SELECT E.ID_TEST
FROM TBL_TEST E INTO IDTEST 
DO 
BEGIN 
	WHILE(IDTEST > 0) DO BEGIN
	  SELECT COUNT(*)
	  FROM
		(SELECT FIRST 5 *
			FROM VW_DISTANCIA V
			WHERE V.ID_TEST = :IDTEST )
	  WHERE CLASSE_TRAIN <> CLASSE_TEST INTO DIFERENTE;


	  SELECT COUNT(*)
	  FROM
		(SELECT FIRST 5 *
		FROM VW_DISTANCIA V
		WHERE V.ID_TEST = :IDTEST )
	  WHERE CLASSE_TRAIN = CLASSE_TEST INTO IGUAL ;

	IDTEST = 0;

END SUSPEND;
END END;

```
![Comparação dos erros e acertos](http://senavalet.com/upload/data/knn/prc_compara_acertos.png)
Explicação: 
Este numero 5 é o K de vizinhos a ser considerado. 
A procedure faz uma busca pelos 5 primeiros registros de cada id de teste e analisa quantos acertos e quantos erros o algorítimo obteve com o calculo de porcentagem. 
Com isso é possível vermos a eficácia do algorítimo.
Para exemplificar criei mais uma procedure para emitir os resultados.  


####Exemplificando o resultado
É necessário criar uma procedure para mostrar o resultado final. 
Segue o código da procedure.
```sql
CREATE OR ALTER PROCEDURE PRC_RESULTADO_FINAL 
RETURNS ( ACERTOS INTEGER, ERROS INTEGER, EFICACIA VARCHAR(10)) 
AS 
DECLARE VARIABLE COUNT_ACERTO INTEGER;

DECLARE VARIABLE COUNT_ERRO INTEGER;

BEGIN
SELECT COUNT(*)
FROM PRC_COMPARA_ACERTOS PA
WHERE PA.IGUAL > PA.DIFERENTE INTO COUNT_ACERTO;


SELECT COUNT(*)
FROM PRC_COMPARA_ACERTOS PE
WHERE PE.IGUAL < PE.DIFERENTE INTO COUNT_ERRO;

BEGIN ACERTOS = :COUNT_ACERTO;

ERROS = :COUNT_ERRO;

EFICACIA = CAST(CAST((:COUNT_ACERTO*100)/(:COUNT_ACERTO+:COUNT_ERRO)AS NUMERIC(2,2))AS VARCHAR(6))||'%';

END SUSPEND;

END;

```
![Resultado Final](http://senavalet.com/upload/data/knn/Resultado%20Final.png)
A procedure apenas faz um count dos erros e dos acertos e faz uma porcentagem de eficácia do total. 

