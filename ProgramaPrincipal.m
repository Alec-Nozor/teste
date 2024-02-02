%*******************************************************************************
% Esse é o programa principal utilizado  para reconstruir a o mapa de temperatura
% no nucleo usando o Método da Matriz Peso.
%*******************************************************************************

%***************************************************************************
% Limpa todos os  dados antes de iniciar o proograma
%***************************************************************************
clc, clear all, close all


%***************************************************************************
% nQ - Numero de instantes de queima.
% nB - Numero de barras de controle.
% iQ - Indica qual é o inicio do intervelo de queima a ser analisado.
% fQ - Indica qual é o final do intervelo de queima a ser analisado.
% idBarra - Indica qual mapa de tempereatura com a barra caída no núcleo
% que sera analisado.
%***************************************************************************
iQ_inical = [1]; 

iQ_final = [18];

nB = [33];

idBarra = 5;

%***************************************************************************
% Avalia o mapa de temperatura do nucleo para o casa em que existe barra de
% controle caida no nucleo, quando Flag.QueimaBarra = true.
%***************************************************************************
Flag.QueimaBarra = false;


%***************************************************************************
% Mostra os resultados em gráficos quando Flag.MostraResultados = true;
%***************************************************************************
Flag.MostraResultados = false;

%***************************************************************************
% Carregado os Mapas de Temperaturas para Cada Queima do Núcleo, inclusive
% considerando os mapas de Temperaturas para o caso em que há queda das
% barras de controle.
%***************************************************************************
load Queimas.mat Queimas
load Quedas.mat Quedas


for iQ = iQ_inical: iQ_final
        
        iB = idBarra;
        
        n = -2;
        
        NucleoQueima(:,:) = Queimas(iQ).Nucleo(:,:);
        
        if Flag.QueimaBarra == true
            NucleoQueda (:,:) = Quedas(iQ,iB).Nucleo(:,:);
            NucleoQueima(:,:) = NucleoQueda (:,:);
        end
        
        
        %***************************************************************************
        % Chama a função que monta os dados EC's com Termopar, guardando
        % as temperaturas e posições do termopares no núcleo, usando a
        % coordenada cartesiana x (coluna) e y (linha).
        %***************************************************************************
        [ECTermopar] = ObterDadosTermopar(NucleoQueima);
           
         
        %***************************************************************************
        % Monta as matrizes pesoso que irão estimar a temperatura do EC nas
        % posicoes sem termporar (MatrizPeso) e a que ira estimar a
        % temperatura na posicao com termopar, a fim de avaliar o erro
        % real.
        %***************************************************************************      
        [ECTermopar, KernelECS] = MontaMatrizePeso(NucleoQueima, ECTermopar, n);
        
        
        %***************************************************************************
        % Estima temperatura usando na posicao do EC sem tempoar, usando a
        % matriz peso, bem como erro associado.
        %***************************************************************************      
        [KernelECS] = CalculaTemperaturaEC(ECTermopar, KernelECS);
        
        
        %***************************************************************************
        % Estima temperatura usando na posicao do EC com tempoar usando a
        % matriz peso, bem como erro associado.
        %***************************************************************************      
        [ECTermopar] = CalculaTemperaturaTp(ECTermopar);
        
        
        %***************************************************************************
        % Mostra os relativos na posição dos EC's sem temporar, bem como o erro 
        % máximo e o médio. 
        %***************************************************************************   
        if Flag.QueimaBarra == true
            [KernelECS] = MostraResultados(iQ, ECTermopar, KernelECS);
        end
       
        
        %***************************************************************************
        % Guarda na estrutura de dados Resultados a Matriz Peso, Erros,
        % Valor das Temperaturas dos Termoapares e Temperatura Media, em
        % todos os instantes de queima.
        %***************************************************************************  
        Resultado.iQ(iQ).MatrizPeso(:, :) = KernelECS.MatrizPeso(:,:);

        Resultado.iQ(iQ).Erro(:, :) =  KernelECS.Erro(:,:);
             
        Resultado.iQ(iQ).ValorTemperatura(:, :) = ECTermopar.ValorTemperatura(:);
        
        Resultado.iQ(iQ).ErroTermopar(:, :) = ECTermopar.Erro;
        
        Resultado.iQ(iQ).TemperaturaMedia(:, :) = ECTermopar.TemperaturaMedia(:, :);
        
        Resultado.iQ(iQ).TemperaturaMedia(:, 4) = KernelECS.TemperaturaMediaEstimadaEC;
        
               
        %***************************************************************************
        % Guarda na estrutura de dados Resultado em um arquivo
        % Resultados.mat que podera ser utilizado posteriormente
        %***************************************************************************  
        save('Resultados.mat','Resultado')

end



