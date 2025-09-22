
-- ATIVIDADE PRÁTICA – SQL com Oracle APEX
-- Base: Sistema Bancário (agencia, cliente, conta, emprestimo)
-- Seções 7 a 10 


-- PARTE 1 – JUNÇÕES (Seção 7)


-- 1. Nome de cada cliente com número da conta
SELECT c.cliente_nome, co.conta_numero
FROM cliente c, conta co
WHERE c.cliente_cod = co.cliente_cliente_cod;

-- 2. Produto cartesiano: clientes x agências
SELECT c.cliente_nome, a.agencia_nome
FROM cliente c, agencia a;

-- 3. Nome do cliente + cidade da agência
SELECT c.cliente_nome, a.agencia_cidade
FROM cliente c, conta co, agencia a
WHERE c.cliente_cod = co.cliente_cliente_cod
  AND co.agencia_agencia_cod = a.agencia_cod;


-- PARTE 2 – FUNÇÕES DE GRUPO (Seção 8)

-- 4. Saldo total de todas as contas
SELECT SUM(saldo) AS saldo_total
FROM conta;

-- 5. Maior saldo e média de saldo
SELECT MAX(saldo) AS maior_saldo,
       AVG(saldo) AS media_saldo
FROM conta;

-- 6. Quantidade total de contas
SELECT COUNT(*) AS total_contas
FROM conta;

-- 7. Número de cidades distintas de clientes
SELECT COUNT(DISTINCT cidade) AS cidades_distintas
FROM cliente;

-- 8. Número da conta e saldo (NVL substitui NULL por zero)
SELECT conta_numero, NVL(saldo, 0) AS saldo
FROM conta;

-- PARTE 3 – GROUP BY, HAVING, ROLLUP e UNION (Seção 9)

-- 9. Média de saldo por cidade dos clientes
SELECT c.cidade, AVG(co.saldo) AS media_saldo
FROM cliente c, conta co
WHERE c.cliente_cod = co.cliente_cliente_cod
GROUP BY c.cidade;

-- 10. Cidades com mais de 3 contas
SELECT c.cidade, COUNT(co.conta_numero) AS qtd_contas
FROM cliente c, conta co
WHERE c.cliente_cod = co.cliente_cliente_cod
GROUP BY c.cidade
HAVING COUNT(co.conta_numero) > 3;

-- 11. Totais por cidade da agência + total geral
SELECT a.agencia_cidade, SUM(co.saldo) AS total_saldo
FROM agencia a, conta co
WHERE a.agencia_cod = co.agencia_agencia_cod
GROUP BY ROLLUP(a.agencia_cidade);

-- 12. União de cidades de clientes e agências
SELECT cidade FROM cliente
UNION
SELECT agencia_cidade FROM agencia;

-- PARTE 4 – SUBCONSULTAS (Seção 10)

-- 1. Clientes com saldo acima da média geral
SELECT c.cliente_nome
FROM cliente c, conta co
WHERE c.cliente_cod = co.cliente_cliente_cod
  AND co.saldo > (SELECT AVG(saldo) FROM conta);

-- 2. Clientes com saldo igual ao maior saldo
SELECT c.cliente_nome
FROM cliente c, conta co
WHERE c.cliente_cod = co.cliente_cliente_cod
  AND co.saldo = (SELECT MAX(saldo) FROM conta);

-- 3. Cidades com quantidade de clientes > média geral
SELECT cidade
FROM cliente
GROUP BY cidade
HAVING COUNT(*) > (
    SELECT AVG(qtd) FROM (
        SELECT COUNT(*) AS qtd
        FROM cliente
        GROUP BY cidade
    )
);

-- 4. Clientes com saldo igual a qualquer um dos 10 maiores saldos
SELECT c.cliente_nome
FROM cliente c, conta co
WHERE c.cliente_cod = co.cliente_cliente_cod
  AND co.saldo IN (
      SELECT saldo
      FROM (SELECT saldo FROM conta ORDER BY saldo DESC)
      WHERE ROWNUM <= 10
  );

-- 5. Clientes com saldo menor que todos os saldos de clientes de Niterói
SELECT c.cliente_nome
FROM cliente c, conta co
WHERE c.cliente_cod = co.cliente_cliente_cod
  AND co.saldo < ALL (
      SELECT co2.saldo
      FROM cliente c2, conta co2
      WHERE c2.cliente_cod = co2.cliente_cliente_cod
        AND c2.cidade = 'Niterói'
  );

-- 6. Clientes com saldo entre os saldos de clientes de Volta Redonda
SELECT c.cliente_nome
FROM cliente c, conta co
WHERE c.cliente_cod = co.cliente_cliente_cod
  AND co.saldo BETWEEN (
      SELECT MIN(co2.saldo)
      FROM cliente c2, conta co2
      WHERE c2.cliente_cod = co2.cliente_cliente_cod
        AND c2.cidade = 'Volta Redonda'
  ) AND (
      SELECT MAX(co2.saldo)
      FROM cliente c2, conta co2
      WHERE c2.cliente_cod = co2.cliente_cliente_cod
        AND c2.cidade = 'Volta Redonda'
  );

-- 7. Clientes com saldo > média da sua agência
SELECT c.cliente_nome
FROM cliente c, conta co
WHERE c.cliente_cod = co.cliente_cliente_cod
  AND co.saldo > (
      SELECT AVG(co2.saldo)
      FROM conta co2
      WHERE co2.agencia_agencia_cod = co.agencia_agencia_cod
  );

-- 8. Clientes com saldo < média da sua cidade
SELECT c.cliente_nome, c.cidade
FROM cliente c, conta co
WHERE c.cliente_cod = co.cliente_cliente_cod
  AND co.saldo < (
      SELECT AVG(co2.saldo)
      FROM cliente c2, conta co2
      WHERE c2.cliente_cod = co2.cliente_cliente_cod
        AND c2.cidade = c.cidade
  );

-- 9. Clientes que possuem pelo menos uma conta
SELECT c.cliente_nome
FROM cliente c
WHERE EXISTS (
    SELECT 1
    FROM conta co
    WHERE co.cliente_cliente_cod = c.cliente_cod
);

-- 10. Clientes que não possuem conta
SELECT c.cliente_nome
FROM cliente c
WHERE NOT EXISTS (
    SELECT 1
    FROM conta co
    WHERE co.cliente_cliente_cod = c.cliente_cod
);

-- 11. WITH: clientes com saldo acima da média da sua cidade
WITH medias AS (
    SELECT c.cidade, AVG(co.saldo) AS media_saldo
    FROM cliente c, conta co
    WHERE c.cliente_cod = co.cliente_cliente_cod
    GROUP BY c.cidade
)
SELECT c.cliente_nome, c.cidade, co.saldo
FROM cliente c, conta co, medias m
WHERE c.cliente_cod = co.cliente_cliente_cod
  AND c.cidade = m.cidade
  AND co.saldo > m.media_saldo;

