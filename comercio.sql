CREATE DATABASE IF NOT EXISTS comercio;
USE comercio;



CREATE TABLE Produtos (
    ProdutoID INT PRIMARY KEY,
    Nome VARCHAR(255),
    Descricao TEXT,
    Preco DECIMAL(10, 2),
    QuantidadeEmEstoque INT
);


CREATE TABLE Pedidos (
    PedidoID INT PRIMARY KEY,
    Data DATE,
    ClienteID INT,
    Status VARCHAR(50),
    FOREIGN KEY (ClienteID) REFERENCES Clientes(ClienteID)
);

CREATE TABLE Clientes (
    ClienteID INT PRIMARY KEY,
    Nome VARCHAR(255),
    EnderecoDeEntrega VARCHAR(255),
    InformacoesDeContato VARCHAR(255)
);


CREATE TABLE ItensDePedido (
    ItemID INT PRIMARY KEY,
    PedidoID INT,
    ProdutoID INT,
    Quantidade INT,
    FOREIGN KEY (PedidoID) REFERENCES Pedidos(PedidoID),
    FOREIGN KEY (ProdutoID) REFERENCES Produtos(ProdutoID)
);

-- Stored Procedure para adicionar produtos ao carrinho de compras
DELIMITER $
CREATE PROCEDURE AdicionarAoCarrinhoDeCompras(IN PedidoID INT, IN ProdutoID INT, IN Quantidade INT)
BEGIN
    INSERT INTO ItensDePedido (PedidoID, ProdutoID, Quantidade)
    VALUES (PedidoID, ProdutoID, Quantidade);
END $
DELIMITER ;

-- Stored Procedure para processar pedidos
DELIMITER $
CREATE PROCEDURE ProcessarPedido(IN PedidoID INT)
BEGIN
    -- Atualizar o estoque do produto
    UPDATE Produtos
    SET QuantidadeEmEstoque = QuantidadeEmEstoque - (SELECT Quantidade FROM ItensDePedido WHERE PedidoID = PedidoID)
    WHERE ProdutoID IN (SELECT ProdutoID FROM ItensDePedido WHERE PedidoID = PedidoID);

    -- Atualizar o status do pedido
    UPDATE Pedidos
    SET Status = 'Processado'
    WHERE PedidoID = PedidoID;
END $
DELIMITER ;

-- Stored Procedure para calcular o total do pedido
DELIMITER $
CREATE PROCEDURE CalcularTotalDoPedido(IN PedidoID INT)
BEGIN
    SELECT SUM(p.Preco * ip.Quantidade) AS Total
    FROM Produtos p
    INNER JOIN ItensDePedido ip ON p.ProdutoID = ip.ProdutoID
    WHERE ip.PedidoID = PedidoID;
END $
DELIMITER ;

-- View para o histórico de pedidos de um cliente
CREATE VIEW HistoricoDePedidos AS
SELECT c.Nome AS NomeDoCliente, p.Data, pr.Nome AS NomeDoProduto, ip.Quantidade, p.Status
FROM Clientes c
INNER JOIN Pedidos p ON c.ClienteID = p.ClienteID
INNER JOIN ItensDePedido ip ON p.PedidoID = ip.PedidoID
INNER JOIN Produtos pr ON ip.ProdutoID = pr.ProdutoID;

-- Inserindo dados para Notebooks
INSERT INTO Produtos (ProdutoID, Nome, Descricao, Preco, QuantidadeEmEstoque)
VALUES 
    (1, 'Notebook Dell Ispirion', 'Notebook de alta performance', 1200.00, 20),
    (2, 'Notebook Acer', 'Notebook leve e portátil', 800.00, 15),
    (3, 'Notebook Galaxy Book', 'Notebook com longa duração de bateria', 1000.00, 18),
    (4, 'Samsung Book Notel', 'Notebook para jogos', 1500.00, 10),
    (5, 'Macbook Pro', 'Notebook para tarefas diárias', 600.00, 25),
    (6, 'Notebook Asus Vivobook', 'Notebook com tela sensível ao toque', 1300.00, 12),
    (7, 'Notebook Lenovo Ultrafino ', 'Notebook com armazenamento SSD', 1100.00, 22),
    (8, 'Notebook Yoga Book', 'Notebook com processador de última geração', 1400.00, 8),
    (9, 'Macbook Pro 15', 'Notebook com design elegante', 900.00, 20),
    (10, 'Macbook Pro 17 Plus', 'Notebook com grande capacidade de armazenamento', 1600.00, 10);

-- Inserindo dados para Celulares
INSERT INTO Produtos (ProdutoID, Nome, Descricao, Preco, QuantidadeEmEstoque)
VALUES 
    (11, 'Iphone X', 'Celular com excelente qualidade de câmera', 600.00, 30),
    (12, 'Samsung Galaxy a31', 'Celular com longa duração da bateria', 400.00, 25),
    (13, 'Iphone 15', 'Celular resistente à água', 500.00, 20),
    (14, 'Iphone 15 Pro Max', 'Celular com tela grande', 700.00, 15),
    (15, 'Xiaomi', 'Celular com desempenho rápido', 800.00, 18),
    (16, 'Lg K10', 'Celular com armazenamento expansível', 450.00, 20),
    (17, 'Iphone 11', 'Celular com reconhecimento facial', 550.00, 22),
    (18, 'Iphone 15 Pro Max', 'Celular com tecnologia 5G', 750.00, 12),
    (19, 'Samsung NOTE 11', 'Celular com design compacto', 650.00, 25),
    (20, 'Nextel Ferrari', 'Celular com tela de alta resolução', 900.00, 15);

-- View para lista de produtos disponíveis
CREATE VIEW ProdutosDisponiveis AS
SELECT * FROM Produtos
WHERE QuantidadeEmEstoque > 0;