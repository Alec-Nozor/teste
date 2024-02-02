
%*******************************************************************************
% Essa funcao calcula a temperatura dos EC's sem tempopar usando o
% metodo da Matriz Peso. Isto e, Tec = MatrizPeso*vTp. Alem disso, calcula
% o erro associado  a estimativa, bem como erro medio e maximo, ambos
% com respeito ao erro relativo.
%*******************************************************************************
function [KernelECS] = CalculaTemperaturaEC(ECTermopar, KernelECS)
    
    %***************************************************************************
    % Recupera a temperatura do EC's com termopar (valor real medido) e a Matriz
    % Peso para o cáclulo da temperatura dos EC's sem termopar
    %***************************************************************************    
    vTp(:) = ECTermopar.ValorTemperatura(:);      
    MatrizPeso(:, :) = KernelECS.MatrizPeso(:,:);   
    
    %***************************************************************************
    % Estima a temperatura nos EC's sem termopar usando o método da matriz
    % peso.
    %***************************************************************************
    TemperaturaEstimadaEC(:) =  MatrizPeso(:, :)* vTp(:);
    
    
    %***************************************************************************
    % Temperatura media: Calculada a partir da temperatura estima nas
    % posicoes dos EC's sem termopar.
    %***************************************************************************
    TemperaturaMediaEstimadaEC =  mean(TemperaturaEstimadaEC); 
    
    %***************************************************************************
    % Recupera a temperatura de referência nos EC's sem termopar para o cálculo
    % do erro.
    %***************************************************************************
    TemperaturaReferenciaEC(:) = KernelECS.TemperaturaReferenciaEC(:);

    
    %***************************************************************************
    % Calcula o erros abasolutos e  relativos com respeito ao velor de referência.
    %*************************************************************************** 
    ErroAbsoluto(:) = abs(TemperaturaReferenciaEC(:) - TemperaturaEstimadaEC(:));
    
    ErroRelativo(:) =  ErroAbsoluto(:)./TemperaturaReferenciaEC(:);
    
    %***************************************************************************
    % Localiza o Erro Máximo e sua posição no vetor ErroRelativo
    %***************************************************************************
    [MaximoErro, Posicao] = max(ErroRelativo);
       
    ErroMedio = 100*mean(ErroRelativo);
    
    
    %***************************************************************************
    % Guarda na estrutura de dados KernelECS a temperatura estimada nas
    % posicoes dos EC's sem termopar. Guarada também os erros.
    %***************************************************************************
    KernelECS.TemperaturaEstimadaEC(:)= TemperaturaEstimadaEC(:);
    
    KernelECS.TemperaturaMediaEstimadaEC = TemperaturaMediaEstimadaEC;
    
    KernelECS.ErroAbsoluto(:) =  ErroAbsoluto(:);
    
    KernelECS.ErroRelativo(:) =  ErroRelativo(:).*100;
    
    KernelECS.Erro(:,1) =  Posicao;
     
    KernelECS.Erro(:,2) =  100*MaximoErro;
     
    KernelECS.Erro(:,3) =  ErroMedio;


    return
end