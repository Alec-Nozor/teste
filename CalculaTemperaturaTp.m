
%*******************************************************************************
% Essa funcao calcula a temperatura dos EC's c/ tempopar usando o
% metodo da Matriz Peso. Isto e, Tep = MatrizPeso*vTp. Alem disso, calcula
% o erro associado  a estimativa, bem como erro medio e maximo, ambos
% com respeito ao erro relativo.
%*******************************************************************************
function [ECTermopar] = CalculaTemperaturaTp(ECTermopar)

   
    %***************************************************************************
    % Recupera a temperatura do EC's com termopar (valor real medido) e a Matriz
    % Peso para o cáclulo da temperatura dos EC's c/ termopar
    %***************************************************************************   
    vTp(:) = ECTermopar.ValorTemperatura(:);       
    MatrizPesoTermopar(:, :) =  ECTermopar.MatrizPesoTermopar(:,:);
    
    %***************************************************************************
    % Estima a temperatura nos EC's com termopar, a fim de avaliar o erro real.
    %***************************************************************************
    TemperaturaEstimadaTp(:) =  MatrizPesoTermopar(:, :)* vTp(:);

    %***************************************************************************
    % Temperatura media estimada no nucleo e a temperatura media do nucleo 
    % fornecida pelo termopares
    %***************************************************************************
    TemperaturaMediaEstimada =  mean(TemperaturaEstimadaTp);
    TemperaturaMediaReal =  mean(vTp);
    ErroAbsolutoTemperaturaMedia = TemperaturaMediaReal - TemperaturaMediaEstimada;
    
    %***************************************************************************
    % Calcula o erros abasolutos e  relativos com respeito ao velor de referência.
    %***************************************************************************     
    ErroAbsoluto(:) = abs(vTp(:) - TemperaturaEstimadaTp(:));
    
    ErroRelativo(:) =  ErroAbsoluto(:)./vTp(:);
    
    %***************************************************************************
    % Localiza o Erro Máximo Relativo e sua posição no vetor ErroRelativo
    %***************************************************************************
    [MaximoErroRelativo, PosicaoErroMaximoRelativo] = max(ErroRelativo);
       
    ErroMedioRelativo = 100*mean(ErroRelativo);
   
    %***************************************************************************
    % Localiza o Erro Máximo Absoluto e sua posição no vetor ErroRelativo
    %***************************************************************************
    [MaximoErroAbsoluto] = max(ErroAbsoluto);
        
    %***************************************************************************
    % Guarda na estrutura de dados ECTemopar a temperatura estimada nas
    % posicoes dos EC's c/ termopar e os erros associados.
    %***************************************************************************
    ECTermopar.TemperaturaEstimada(:)= TemperaturaEstimadaTp(:);
    
    ECTermopar.ErroAbsoluto(:) =  ErroAbsoluto(:);
    
    ECTermopar.ErroRelativo(:) =  ErroRelativo(:).*100;
    
    ECTermopar.Erro(:,1) =  PosicaoErroMaximoRelativo;
     
    ECTermopar.Erro(:,2) =  100*MaximoErroRelativo;
     
    ECTermopar.Erro(:,3) =  ErroMedioRelativo;
   
    ECTermopar.Erro(:,4) =  MaximoErroAbsoluto;
    
    ECTermopar.TemperaturaMedia(:,1) =  TemperaturaMediaEstimada;

    ECTermopar.TemperaturaMedia(:,2) =  TemperaturaMediaReal;
    
    ECTermopar.TemperaturaMedia(:,3) = ErroAbsolutoTemperaturaMedia;

    return
end