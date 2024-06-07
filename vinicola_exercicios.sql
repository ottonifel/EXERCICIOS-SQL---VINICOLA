-- CRIAÇÃO PADRÃO:
CREATE TABLE regiao(
regiao_id 		    smallint PRIMARY KEY,
nome_regiao		    varchar(100) NOT NULL,
descriçao_regiao	text);

CREATE TABLE vinicola(
vinicola_id		    smallint PRIMARY KEY,
nome_vinicola		varchar(50) NOT NULL,
descriçao_vinicola	text,
fone_vinicola		varchar(15),
fax_vinicola		varchar(15),
regiao_id		    smallint, 

FOREIGN KEY(regiao_id) REFERENCES regiao(regiao_id) ON DELETE SET NULL
);

CREATE TABLE vinho(
vinho_id 		    smallint PRIMARY KEY,
nome_vinho 		    varchar(50) NOT NULL,
tipo_vinho		    varchar(10) DEFAULT 'seco' NOT NULL,
ano_vinho		    int DEFAULT 2000 CHECK (ano_vinho < 2020), --precisou colocar os parenteses
descriçao_vinho 	text,
vinicola_id		    smallint NOT NULL,

FOREIGN KEY (vinicola_id) REFERENCES vinicola(vinicola_id)
	ON UPDATE CASCADE
	ON DELETE CASCADE
);


INSERT INTO regiao VALUES (01, 'Sao Roque', 'Regiao entre Sorocaba e Sao Paulo');
INSERT INTO regiao VALUES (02, 'Sul', 'Sul do Brasil');
INSERT INTO vinicola VALUES (01, 'Vinícola Palmeiras', 'Vinícola de Sao Roque', '(15)3388-5269', '(15)3388-5269', 01);
INSERT INTO vinicola VALUES (02, 'Vinícola Góes', 'Vinícola de Sao Roque', '(15)3223-3683', '(15)3223-3683', 01); -- precisou mudar regiaoid pra uma regiao que existe
INSERT INTO vinicola VALUES (03, 'Vinícola Tche', 'Vinícola de Porto Alegre', '(51)3229-3783', '(15)9322-3683', 02);
INSERT INTO vinho VALUES (01, 'Palmeiras', 'Branco', 1997, 'Vinho da minha tia', 01);
INSERT INTO vinho VALUES (02, 'Góes', 'Suave', 2001, 'Vinho barato', 02);
INSERT INTO vinho VALUES (17, 'Fogo Tche', 'Cabernet', 2019, 'Vinho barato', 03); -- ano tem que ser < 2020
INSERT INTO vinho VALUES (18, 'Fogo Negro', 'Pinot', 2010, 'Vinho envelhecido', 03); -- precisou mudar a PK
INSERT INTO vinho VALUES (19, 'Fogo Sul', 'Merlot', 2015, 'Vinho tinto', 01); -- vinicola_id nao pode ser NULL e tem q existir

SELECT * FROM regiao;
SELECT * FROM vinicola;
SELECT * FROM vinho;

-- EXERCICIOS PARTE 1:

-- 1: SELECIONE TODOS OS VINHOS DA REGIÃO SUL:

SELECT vinho_id, nome_vinho, tipo_vinho, ano_vinho, descriçao_vinho, nome_regiao
FROM vinho v NATURAL JOIN vinicola vi NATURAL JOIN regiao r
WHERE nome_regiao ILIKE 'sul';

-- 2: SELECIONE TODOS OS VINHOS NA FAIXA DE PRECO [100, 200]
-- obs: primeiro crie a coluna preco em vinho
ALTER TABLE vinho ADD preco numeric(10,2) NOT NULL DEFAULT 50.00;

-- mudanças no preço
UPDATE vinho
SET preco = 150.00
WHERE ano_vinho >= 2015 AND ano_vinho <= 2019

-- consulta
SELECT *
FROM vinho
WHERE preco <= 100 AND preco >= 200;

-- 3: SELECIONE TODAS AS VINIVOLAS CUJO NOME TERMINA COM 's'

SELECT *
FROM vinicola
WHERE nome_vinicola LIKE '%s';

-- 4: AUMENTE O PREÇO DOS VINHOS DA REGIÃO SUL EM 10%
select *from vinho

-- OPÇÃO 1:
UPDATE vinho
SET preco = preco * 1.10
WHERE vinicola_id IN (
    SELECT vinicola_id
    FROM vinicola vi NATURAL JOIN regiao r
    WHERE r.nome_regiao ILIKE 'sul'
);

-- OPÇÃO 2:
UPDATE vinho
SET preco = vinho.preco * 1.10
FROM vinicola NATURAL JOIN regiao
WHERE vinho.vinicola_id = vinicola.vinicola_id
AND regiao.nome_regiao ILIKE 'sul';

-- EXERCICIOS PARTE 2:

-- 1: LISTE A QUANTIDADE DE VINHOS QUE TEM CADA VINICOLA
SELECT vi.vinicola_id , nome_vinicola, descriçao_vinicola ,count(vinho_id) AS quantidade
FROM vinho v NATURAL JOIN vinicola vi
GROUP BY vi.vinicola_id;

-- 2: LISTE A QUANTIDADE DE VINHOS QUE TEM CADA VINICOLA DA REGIÃO SUL
SELECT vi.vinicola_id , nome_vinicola, descriçao_vinicola ,count(vinho_id) AS quantidade
FROM vinho v NATURAL JOIN vinicola vi NATURAL JOIN regiao r
WHERE nome_regiao ILIKE 'sul'
GROUP BY vi.vinicola_id;

-- 3: LISTE A QUANTIDADE DE VINHOS QUE TEM EM CADA VINICOLA DA REGIAO SUL PARA AS VINICOLAS QUE TEM MAIS DE 1 VINHO (>1)
SELECT vi.vinicola_id , nome_vinicola, descriçao_vinicola ,count(vinho_id) AS quantidade
FROM vinho v NATURAL JOIN vinicola vi NATURAL JOIN regiao r
WHERE nome_regiao ILIKE 'sul'
GROUP BY vi.vinicola_id
HAVING count(vinho_id) > 1;

-- 4: LISTE AS VINICOLAS QUE NÃO TEM CADASTRO DE VINHOS
-- inserir vinicolas sem vinhos
INSERT INTO vinicola VALUES (04, 'Vinícola Arcadia', 'Vinícola de Sao Roque', '(15)3882-5789', '(15)3377-5467', 01);
INSERT INTO vinicola VALUES (05, 'Vinícola Oasis', 'Vinícola de Sao Roque', '(15)3234-9070', '(15)3243-5030', 01);

--OPÇÃO 1: JUNÇÃO A ESQUERDA E NULL
SELECT nome_vinicola, v.vinicola_id
FROM vinicola vi LEFT JOIN vinho v ON vi.vinicola_id = v.vinicola_id
WHERE vinho_id IS NULL;

-- OPÇÃO 2: JUNÇÃO A ESQUERDA E GROUP BY E HAVING
SELECT nome_vinicola, count(vinho_id) as quantidade
FROM vinicola vi LEFT JOIN vinho v ON vi.vinicola_id = v.vinicola_id
GROUP BY vi.vinicola_id
HAVING count(vinho_id) = 0;

-- OPÇÃO 3: NOT IN
SELECT nome_vinicola
FROM vinicola
WHERE vinicola_id NOT IN (
	SELECT vinicola_id
	FROM vinho
);

-- OPÇÃO 4: NOT EXISTS
SELECT nome_vinicola
FROM vinicola vi
WHERE NOT EXISTS (
	SELECT 1
	FROM vinho v
	WHERE vi.vinicola_id = v.vinicola_id
);

-- OPÇÃO 5: EXCEPT	
SELECT nome_vinicola 
FROM vinicola natural join (
	SELECT vi.vinicola_id
	FROM vinicola vi
	EXCEPT -- para usar operador de conjuntos precisa usar a PK (e nao o nome) POR QUE?
	SELECT v.vinicola_id
	FROM vinho v) t
	
-- 5: LISTE A(S)REGIÃO COM MAIS VINICOLAS

-- OPÇÃO 1: MAX
SELECT nome_regiao, count(vinicola_id) as qtd_vinicolas
FROM regiao r NATURAL JOIN vinicola vi
GROUP BY r.regiao_id
HAVING count(vinicola_id) = ( SELECT max(quantidade)
							  FROM ( SELECT count(vinicola_id) as quantidade
									 FROM vinicola
									 GROUP BY regiao_id) t
							)
							
-- OPÇÃO 2: ALL --> COMPARA O LADO ESQUERDO COM TUDO DO LADO DIREITO
SELECT nome_regiao, count(vinicola_id) AS quantidade
FROM vinicola v NATURAL JOIN regiao r
GROUP BY r.regiao_id
HAVING count(vinicola_id) >= ALL(SELECT count(vinicola_id)
								 FROM vinicola
								 GROUP BY regiao_id)

-- 6: QUAL A MEDIA DE VINHOS POR VINICOLA ?

-- OPÇÃO 1: APENAS COM AS QUE TEM VINHO
SELECT avg(qtd_vinho) AS media
FROM ( SELECT count(vinho_id) as qtd_vinho
       FROM vinho
       GROUP BY vinicola_id) t;
	   
-- OPÇÃO 2: CONTA AS QUE NÃO TEM NENHUM VINHO TBM
SELECT avg(qtd_vinho) AS media
FROM ( SELECT count(vinho_id) as qtd_vinho
       FROM vinho v RIGHT JOIN vinicola vi ON v.vinicola_id = vi.vinicola_id
       GROUP BY vi.vinicola_id) t;

-- 7: LISTE AS REGIÕES QUE NÃO TEM VINICOLAS
INSERT INTO regiao VALUES (03, 'Norte', 'Norte do Brasil');
INSERT INTO regiao VALUES (04, 'Sudeste', 'Sudeste do Brasil');

-- OPÇÃO 1: RIGTH(LEFT) JOIN/ NULL
SELECT *
FROM regiao r LEFT JOIN vinicola vi ON vi.regiao_id = r.regiao_id
WHERE vi.vinicola_id IS NULL;

-- OPÇÃO 2: RIGHT(LEFT) JOIN / GORUP BY ... HAVING
SELECT nome_regiao, count(vinicola_id) as qtd_vinicolas
FROM regiao r LEFT JOIN vinicola vi ON vi.regiao_id = r.regiao_id
GROUP BY r.regiao_id
HAVING count(vinicola_id) = 0;

-- OPÇÃO 3: NOT IN
SELECT nome_regiao
FROM regiao
WHERE regiao_id NOT IN (
	SELECT regiao_id
	FROM vinicola
);

-- OPÇÃO 4: NOT EXISTS
SELECT nome_regiao
FROM regiao r
WHERE NOT EXISTS (
	SELECT 1
	FROM vinicola vi
	WHERE r.regiao_id = vi.regiao_id
);

-- OPÇÃO 5: EXCEPT	
SELECT nome_regiao
FROM regiao natural join (
	SELECT r.regiao_id
	FROM regiao r
	EXCEPT -- para usar operador de conjuntos precisa usar a PK (e nao o nome) POR QUE?
	SELECT vi.regiao_id
	FROM vinicola vi) t

-- 8: LISTE O VINHO DE MAIOR PREÇO

SELECT vinho_id, nome_vinho, preco
FROM vinho
WHERE preco IN (SELECT max(preco) as preco_max
                FROM vinho)

-- 9: LISTE OS VINHOS DO TIPO SECO OU DO ANO 2000 (substitui por suave e ano 2010 pra não ter uque criar mais vinhos)

SELECT *
FROM vinho
WHERE tipo_vinho ILIKE 'suave' OR ano_vinho = 2010;

-- 10: LISTE OS VINHOS DE TIPO SECO E DO ANO 2000

SELECT *
FROM vinho
WHERE tipo_vinho ILIKE 'suave' AND ano_vinho = 2010;

-- 11: LISTE OS VINHOS DE TIPO SECO QUE NÃO SÃO DO ANO 2000

SELECT *
FROM vinho
WHERE tipo_vinho ILIKE 'suave' AND ano_vinho <> 2010; 

-- 12: REFAÇA AS CONSULTAS 9, 10, 11 COM OPERADORES DE CONJUNTOS (UNION,INTERSECT, EXCEPT)
		-- 9: LISTE OS VINHOS DO TIPO SECO OU DO ANO 2000
		
		SELECT v.vinho_id, v.nome_vinho, v.ano_vinho, v.tipo_vinho
		FROM vinho v
		WHERE v.vinho_id IN (
			(SELECT vinho_id
			 FROM vinho
			 WHERE tipo_vinho ILIKE 'suave')
			 UNION
			(SELECT vinho_id
			 FROM vinho
			 WHERE ano_vinho = 2010)
        );
		
		SELECT *
		FROM vinho
		WHERE tipo_vinho ILIKE 'suave'
		UNION
		SELECT *
		FROM vinho
		WHERE ano_vinho = 2010
		
		-- 10: LISTE OS VINHOS DO TIPO SECO E DO ANO 2000
		
		SELECT v.vinho_id, v.nome_vinho, v.ano_vinho, v.tipo_vinho
		FROM vinho v
		WHERE v.vinho_id IN (
			(SELECT vinho_id
			 FROM vinho
			 WHERE tipo_vinho ILIKE 'suave')
			 INTERSECT
			(SELECT vinho_id
			 FROM vinho
			 WHERE ano_vinho = 2010)
        );
		
		SELECT *
		FROM vinho
		WHERE tipo_vinho ILIKE 'suave'
		INTERSECT
		SELECT *
		FROM vinho
		WHERE ano_vinho = 2010
		
		-- 11: LISTE OS VINHOS DE TIPO SECO QUE NÃO SÃO DO ANO 2000
		
		SELECT v.vinho_id, v.nome_vinho, v.ano_vinho, v.tipo_vinho
		FROM vinho v
		WHERE v.vinho_id IN (
			(SELECT vinho_id
			 FROM vinho
			 WHERE tipo_vinho ILIKE 'suave')
			 EXCEPT
			(SELECT vinho_id
			 FROM vinho
			 WHERE ano_vinho = 2010)
        );
		
		SELECT *
		FROM vinho
		WHERE tipo_vinho ILIKE 'suave'
		EXCEPT
		SELECT *
		FROM vinho
		WHERE ano_vinho = 2010

		
-- 13: A) ACRESCENTE UM ATRIBUTO regiao NA TABELA DE vinhos, QUE REFERENCIE A TABELA DE regioes E RESPONDA:
ALTER TABLE vinho
ADD COLUMN regiao_id smallint DEFAULT 2 REFERENCES regiao(regiao_id);

-- 13: B) RECUPERE OS VINHOS QUE SEJAM DA MESMA REGIAO DA SUA VINICOLA
SELECT v.vinho_id, v.nome_vinho
FROM vinho v NATURAL JOIN vinicola vi
WHERE v.regiao_id = vi.regiao_id;

SELECT * FROM vinho

-- 14: RECUPERE A VINICOLA QUE TEM O MAIOR PRECO MEDIO DE VINHOS

SELECT nome_vinicola, avg(v.preco) as media_preco
FROM vinho v INNER JOIN vinicola vi ON vi.vinicola_id = v.vinicola_id
GROUP BY vi.vinicola_id
HAVING avg(v.preco) = (SELECT max(media_preco) as max_preco_medio
					   FROM ( SELECT nome_vinicola,avg(v.preco) as media_preco
	                          FROM vinho v INNER JOIN vinicola vi ON vi.vinicola_id = v.vinicola_id
                              GROUP BY vi.vinicola_id)t
					  )

-- 15: RECUPERE A VINICOLA QUE TEM APENAS UM VINHO CADASTRADO
-- A) USANDO "UNIQUE": ??
SELECT vi.nome_vinicola
FROM vinicola vi
WHERE UNIQUE ( SELECT v.vinicola_id
			   FROM vinho v
)

-- B) AGREGAÇÃO
SELECT nome_vinicola
FROM vinicola vi
WHERE vinicola_id IN ( SELECT vinicola_id
					   FROM vinho v
					   GROUP BY vinicola_id
					   HAVING count(vinho_id) = 1)
					   

-- OU

SELECT vi.nome_vinicola, count(v.vinho_id) as qtd
FROM vinicola vi INNER JOIN vinho v ON vi.vinicola_id = v.vinicola_id
GROUP BY vi.vinicola_id
HAVING count(vinho_id) = 1

-- 16: RECUPERE OS VINHOS QUE TENHAM PREÇOS MAIORES QUE AO MENOS UM VINHO DA REGIÃO SUL
-- OPÇÃO 1: ANY
SELECT v.nome_vinho, v.preco
FROM vinho v
WHERE v.preco > ANY (
    SELECT v2.preco
    FROM vinho v2 INNER JOIN vinicola vi ON v2.vinicola_id = vi.vinicola_id
    INNER JOIN regiao r ON vi.regiao_id = r.regiao_id
    WHERE r.nome_regiao ILIKE 'sul'
);

-- OPÇÃO 2: MIN
SELECT v.nome_vinho, v.preco
FROM vinho v INNER JOIN vinicola vi ON v.vinicola_id = vi.vinicola_id
INNER JOIN regiao r ON vi.regiao_id = r.regiao_id
WHERE v.preco > (
    SELECT MIN(v2.preco)
    FROM vinho v2
    JOIN vinicola vi2 ON v2.vinicola_id = vi2.vinicola_id
    JOIN regiao r2 ON vi2.regiao_id = r2.regiao_id
    WHERE r2.nome_regiao ILIKE 'sul'
)

SELECT * FROM vinho
SELECT * FROM vinicola
SELECT * FROM regiao


-- EXTRA: LISTE VINICOLAS POR REGIAO

SELECT r.* ,count(vi.vinicola_id) as qtd_vinicolas
FROM vinicola vi NATURAL JOIN regiao r
GROUP BY r.regiao_id

