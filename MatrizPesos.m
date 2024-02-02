%*******************************************************************************
% Method - Reconstrução das Temperaturas do núcleo do Reator usando o
% método do Kernel
%*******************************************************************************
function [] = MapasTemperaturas()

    clc, clear all, close all
    
   
    %***************************************************************************
    % nQ - Número de instantes de queima.
    % Flag.vQ - Indica qual queima vou análisar a reconstrução
    %***************************************************************************
    nQ = [1]; %nB = [33];
    
    Flag.vQ = [1]; %Flag.vB = [17]; 
    Flag.idBarra = 23;
    
    %***************************************************************************
    % Flag de Controle
    %***************************************************************************
    Flag.Posicao   = 0; % Posicao dos Termopares e dos Combustíveis sem Termopar
    
    
    %***************************************************************************
    % Chamo o programa Principal
    %***************************************************************************
    DisplayTemperaturas(Flag)

    
return    
%*******************************************************************************
% Essa função Retorna a Reconstrução da Temperatura usando o método das
% matrizes pesos.
%*******************************************************************************
function [] = DisplayTemperaturas(Flag)

    %***************************************************************************
    % Leitura dos Mapas de Temperaturas para Cada Queima do Núcleo
    %***************************************************************************

    load Queimas.mat Queimas
    load Quedas.mat Quedas
    
    %***************************************************************************
    % Visualização dos Mapas
    %***************************************************************************  
    for iQ =1: Flag.vQ
        
        iB = Flag.idBarra;
        
        NucleoQueima(:,:) = Queimas(iQ).Nucleo(:,:);
        
        NucleoQueda (:,:) = Quedas(iQ,iB).Nucleo(:,:);
              
        
        if (iB > 0.0)
            
            NucleoQueima(:,:)= NucleoQueda (:,:);
        end

        NucleoTemperaturas(:,:) = 0.0;
        NucleoReconstrucao(:,:) = 0.0;
        
        [eTp] = ObterETP(0);
        
        %Monta a matriz NucleoTemperaturas. Isto é, a matriz que contem as
        %medidas da temperatura fornecidas pelo termopar.
        for iTp = 1:length(eTp)
            iL=eTp(iTp,2); iC=eTp(iTp,1);
            vTp(iTp) = NucleoQueima(iL,iC);
            NucleoTemperaturas(iL,iC) = NucleoQueima(iL,iC);
        end  

        %Localiza a posição dos NaN na Matriz NucleoQueima
        indices = find(isnan(NucleoQueima) == 1);
        [I,J] = ind2sub(size(NucleoQueima),indices);


        %Marca o contorno do núcleo com  
        %valor 1 na Matriz NucleoTemperaturas 
        for iL = 1:length(I)        
              NucleoTemperaturas(I(iL), J(iL))= 1.0;
        end

        %***************************************************************************
        % Chama a função que irá empregar o método dos fatores pesos para
        % reconstrução do mapa de temperatura do núcleo.
        %*************************************************************************** 
        [NucleoReconstrucao, EC_Line, EC_Col] = CalculaTemperaturasNucleo (NucleoTemperaturas, vTp);


        % Guarda o resultado em uma estrutura de dados.
        Resultado.Reconstrucao(iQ).Nucleo(:,:) = NucleoReconstrucao (:, :);
    
        %***************************************************************************
        % Monta o Mapa de Posicao de Termopares e dos combustíveis.
        %***************************************************************************
        if (Flag.Posicao == 1)
            MapaPosicao (EC_Line, EC_Col);
        end
        
        
        [MatrizPeso, DistanciaRelativa, KernelECS] = MontaMatrizes(NucleoTemperaturas, vTp)

        %***************************************************************************
        % Chama a função que moistrao resultado.
        %***************************************************************************
        DisplayErroRelaivo(iQ, NucleoQueima, NucleoTemperaturas, NucleoReconstrucao,EC_Line, EC_Col)
        
    end
    

return

%***************************************************************************
% Essa função cálcula o erro relativo do método dos fatores pesos com respeito 
% ao valor de referência.
%***************************************************************************
function [] = DisplayErroRelaivo (iQ, NucleoQueima, NucleoTemperaturas, NucleoReconstrucao, EC_Line, EC_Col)

 
   nL=13; nC=13;
    %***************************************************************************
    % Cálcula o erro relativo com respeito ao valor de referência.
    %***************************************************************************
    for iL = 1:nL
        for iC = 1:nC         
          NucleErroRelativo (iL, iC) = 100*(NucleoReconstrucao(iL, iC)- NucleoQueima(iL, iC))/NucleoQueima(iL, iC);
        end
    end


    %***************************************************************************
    % Determina qual é o erro relativo máximo na matriz NucleErroRelativo
    %***************************************************************************
    [VetorMaximoErro, Posicao] = max(NucleErroRelativo);
    [ErroRelativoMaximo,PosicaoErroMaximo] = max(VetorMaximoErro);
    
    %Localiza a posição do Erro Relativo Máximo na Matriz
    %NucleErroRelativo.
    ColunaErroMaximo = PosicaoErroMaximo;
    LinaErroMaximo =  (Posicao(PosicaoErroMaximo));
      
    
    
    %***************************************************************************
    % Determina qual é o erro relativo medio e máximo na matriz NucleErroRelativo
    %***************************************************************************
    nL = length(EC_Line);
    Soma  = 0.0;
    ValMaxAnterior = 0.0;
    for k = 1:nL
            ValMax = NucleErroRelativo(EC_Line(k), EC_Col(k));
            
            if (ValMax > ValMaxAnterior)              
                ValMaxAnterior = NucleErroRelativo(EC_Line(k), EC_Col(k));              
            end
            
            Soma = Soma + NucleErroRelativo(EC_Line(k), EC_Col(k));
    end
    
    %Determina o Erro Relativo Médio
    ErroRelativoMedio = Soma /k;
    
    FatordeCorrecao = ErroRelativoMedio/100;

    
    
    %***************************************************************************
    % Construindo o Gráfico
    %***************************************************************************
    scrsz = get(0, 'ScreenSize');
    strName = sprintf('Mapa de Posicao de Termopares');
    hfig = figure('ToolBar','none','Color','White','Name',strName, ...
                  'Position', [1 scrsz(4) scrsz(3) scrsz(4)]);

    %***************************************************************************
    % Essa função obtem as posicao dos Termopares.
    %***************************************************************************
    [eTp] = ObterETP(0); 
    
    %***************************************************************************
    % Mostra as posições do Termpoares no gráfico.
    %***************************************************************************
    hold on
    for iTp = 1:length(eTp)
        ix = eTp(iTp,1); iy = eTp(iTp,2);
        plot(ix,iy,'r.')
        text(ix,iy,sprintf('T%2d %.3g',iTp), ...
             'Color','Red','FontSize',11,'FontAngle','Italic')
    end
    
    hold off
    
    hold on
    
    %***************************************************************************
    % Mostra no gráfico o erro relativo percentual - 
    % Erro = abs(Ref - Método)/Ref
    %***************************************************************************
    for iL = 1:length(EC_Line)
        ix = EC_Col(iL); iy = EC_Line(iL);
        plot(ix,iy,'b.')
        text(ix,iy,sprintf('%.3g', NucleErroRelativo(iy,ix)), ...
             'Color','Blue','FontSize',11,'FontAngle','Italic')
    end
    
    hold off

    %***************************************************************************
    % Delimitando o intervalor de X e Y, bem como colocando o eixo X no
    % topo.
    %***************************************************************************
    axis([0,14,0,14])
    set(gca,'XTick', [0 1 2 3 4 5 6 7 8 9 10 11 12 13 14],'XAxisLocation', 'top' )
    set(gca,'YTick', [0 1 2 3 4 5 6 7 8 9 10 11 12 13 14])
        
    strA = 'Passo de Queima - ';
    
    strB = string(iQ);
    
    strC = ' - Erro Relativo Máximo = ' + string(ErroRelativoMaximo) + ' ';
    
    strD = '(' + string(LinaErroMaximo) + ', ' + string( ColunaErroMaximo) + ')';
    
    strE = ' - Erro Relativo Médio = ' + string(ErroRelativoMedio) + ' ';   
    
    strTitulo =  strA + strB + strC + strD + strE ;
    title (strTitulo     ,'Color','Blue','FontSize',11,'FontAngle','Italic')

    box on, grid on, axis ij
    drawnow;

return



%*******************************************************************************
% Method - MapaPosicao - Faz um gráfico marcando a posição dos termopares e do 
% Centro do EC no plano cartesiano.
%*******************************************************************************
function [] = MapaPosicao (EC_Line, EC_Col)

    %***************************************************************************
    % Gráficos 
    %***************************************************************************

    scrsz = get(0, 'ScreenSize');
    strName = sprintf('Mapa de Posicao de Termopares');
    hfig = figure('ToolBar','none','Color','White','Name',strName, ...
                  'Position', [1 scrsz(4) scrsz(3) scrsz(4)]);

    %***************************************************************************
    % Posicao de Termopares e Barras
    %***************************************************************************
    [eTp] = ObterETP(0); 
    
    %***************************************************************************
    % Display Posicao dos Termopares e de Barras de Controle
    %***************************************************************************
    hold on
    for iTp = 1:length(eTp)
        ix = eTp(iTp,1); iy = eTp(iTp,2);
        plot(ix,iy,'r.','markersize',15)
        text(ix,iy,sprintf('T%2d',iTp), ...
             'Color','Red','FontSize',11,'FontAngle','Italic')
    end
    
    hold off
    
    hold on
    
    for iL = 1:length(EC_Line)
        ix = EC_Col(iL); iy = EC_Line(iL);
        plot(ix,iy,'b.','markersize',15)
        text(ix,iy,sprintf('C%2d',iL), ...
             'Color','Blue','FontSize',11,'FontAngle','Italic')
    end
    
    hold off

    %***************************************************************************
    % Delimitando o intervalor de X e Y, bem como colocando o eixo X no
    % topo.
    %***************************************************************************
    axis([0,14,0,14])
    set(gca,'XTick', [0 1 2 3 4 5 6 7 8 9 10 11 12 13 14],'XAxisLocation', 'top' )
    set(gca,'YTick', [0 1 2 3 4 5 6 7 8 9 10 11 12 13 14])
        
    strBC = 'Posicao dos Termopares e Posição Central dos ECs';
    title (strBC       ,'Color','Blue','FontSize',11,'FontAngle','Italic')

    box on, grid on, axis ij
    drawnow;

return

%*******************************************************************************
% Essa função faz a reconstrução das termperaturas do núcleo a partir das
% medidas do termopar usando o método dos fatores pesos.
%*******************************************************************************
function [NucleoReconstrucao, EC_Line, EC_Col] = CalculaTemperaturasNucleo(NucleoTemperaturas, vTp, NucleoReconstrucao)
        
    %Monta a Estrutura de Dados que irá quardar 
    
    [eTp] = ObterETP(0);
    nL=13; nC=13;
    k = 0;
    i = 0;
    n = 2.0
    for iL = 1:nL
        for iC = 1:nC
            
            
            %Esse if localiza as posições de EC's sem termopar.
            if (NucleoTemperaturas(iL, iC)~= 1.0) && (NucleoTemperaturas(iL, iC)== 0.0)                      
                k = k + 1;

                EC_Line(k)= iL; %Posição linha do EC sem termopar
                EC_Col(k) = iC; %Posição coluna do EC sem termopar

                %Varre todos os termpores do núcleo.
                for iTp = 1:length(eTp)

                    %Posições das Linhas e Colunas dos termopares
                    LTp = eTp(iTp,2); CTp = eTp(iTp,1);

                    %Distância quadratica relativa do termopar para o EC
                    DistanciaRelativa (iTp) = (sqrt((iL - LTp)^2 + (iC - CTp)^2))^n; 

                    %Produto das Temperaturas do Termopare pelas distâncias quadratica relativa do termopar para o EC
                    Produto (iTp) = DistanciaRelativa(iTp)*vTp(iTp);

                    %Armazena os dados em uma Estrura denominada de Kernel
                    Kernel.EC(k).DistanciaRelativa(iTp) = DistanciaRelativa (iTp);
                    Kernel.EC(k).Produto(iTp) = Produto (iTp);   
                end

                %Armazenos os dados em uma Estrura denominada de Kernel
                Kernel.EC(k).SomaNumerador(k) = sum (Produto);
                Kernel.EC(k).SomaDenominador(k) = sum (DistanciaRelativa);
                Kernel.EC(k).Temperatura(k) =(sum (Produto))/(sum (DistanciaRelativa));

                NucleoReconstrucao (iL, iC) = (sum (Produto))/(sum (DistanciaRelativa));
            end
        end
    end
    
    %Adciona os valores dos termopares na matriz NucleoReconstrucao.
    for iTp = 1:length(eTp)

        %Posições dos termopares
        LTp=eTp(iTp,2); CTp=eTp(iTp,1);

        %Distância quadratica relativa do termopar para o EC
        NucleoReconstrucao (LTp, CTp) = vTp(iTp); 
   end     
return 


%*******************************************************************************
% Method - ObterETP - Define as posições dos termopares no núcleo
%*******************************************************************************
function [eTp] = ObterETP(iTp)

    %eT =['a07'; 'b05'; 'b07'; 'c03'; 'c06'; 'c08'; 'c11'; 'd02'; 'd05'; 'd07'; ...
    %     'd12'; 'e04'; 'e06'; 'e10'; 'f09'; 'f12'; 'g01'; 'g02'; 'g04'; 'g07'; ...
    %     'g12'; 'h06'; 'h09'; 'h10'; 'h11'; 'h13'; 'i02'; 'i04'; 'i07'; 'i10'; ...
    %     'j03'; 'j06'; 'j08'; 'j09'; 'k03'; 'k11'; 'l07'; 'l10'; 'm06'];

    eTp = [[01,07]; [02,05]; [02,07]; [03,03]; [03,06]; [03,08]; [03,11]; [04,02]; [04,05]; [04,07]; ...
           [04,12]; [05,04]; [05,06]; [05,10]; [06,09]; [06,12]; [07,01]; [07,02]; [07,04]; [07,07]; ...
           [07,12]; [08,06]; [08,09]; [08,10]; [08,11]; [08,13]; [09,02]; [09,04]; [09,07]; [09,10]; ...
           [10,03]; [10,06]; [10,08]; [10,09]; [11,03]; [11,11]; [12,07]; [12,10]; [13,06]];

    eTp1 = eTp(:,1); eTp2 = eTp(:,2);
    eTp = [eTp2, eTp1];

    %if (nargin > 0)
    %    eTp = eTP(iTp,:)
    %end
       
return


%*******************************************************************************
% Method - ObterEPB - Define as posições dos detectores internos no núcleo
%*******************************************************************************
function [ePb] = ObterEPB(iTp)

    ePb = [[06,02]; [08,02]; [05,03]; [07,03]; [09,03]; [04,04]; [10,04]; [03,05]; [07,05]; [11,05]; ...
           [02,06]; [06,06]; [08,06]; [12,06]; [03,07]; [05,07]; [07,07]; [09,07]; [11,07]; [02,08]; ...
           [06,08]; [08,08]; [12,08]; [03,09]; [07,09]; [11,09]; [04,10]; [10,10]; [05,11]; [07,11]; ...
           [09,11]; [06,12]; [08,12]];
           
return     

function [MatrizPeso, DistanciaRelativa, KernelECS] = MontaMatrizes(NucleoTemperaturas, vTp, n)
        
    %Constrio uma estrutura de dados que guarda os dados dos EC's s/
    %Termopares
    [eTp] = ObterETP(0);
    nL=13; nC=13;
    k = 0;
    
    for iL = 1:nL
        for iC = 1:nC
                    
            %Esse if localiza as posições de EC's sem termopar.
            if (NucleoTemperaturas(iL, iC)~= 1.0) && (NucleoTemperaturas(iL, iC)== 0.0)                      
                k = k + 1;

                EC_Line(k)= iL; %Posição linha do EC sem termopar
                EC_Col(k) = iC; %Posição coluna do EC sem termopar

                %Varre todos os termpores do núcleo.
                for iTp = 1:length(eTp)

                    %Posições das Linhas e Colunas dos termopares
                    LTp = eTp(iTp,2); CTp = eTp(iTp,1);

                    %Distância quadratica relativa do termopar para o EC
                    DistanciaRelativa (k, iTp) = sqrt((iL - LTp)^2 + (iC - CTp)^2); 

                end
                
                Soma = sum(DistanciaRelativa (k, :));
                
                SomaDistancias(k) = Soma;
                  
                %Monta a Matriz Peso 
                MatrizPeso(k,:) = DistanciaRelativa (k, :)./Soma;
                           
            end
        end
    end
    
    %Armazena os dados relativos aos EC's sem termpopares em uma Estrura
    %denominada de KernelEC
    KernelECS.SomaDistancias(:) =  SomaDistancias(:);
    KernelECS.DistanciaRelativa(:, :) =  DistanciaRelativa (:, :);    
    KernelECS.MatrizPeso(:,:) =  MatrizPeso(:,:);
    
    
    
    %Constroi uma estrutura de dados que guarda os dados dos EC's com
    %Termopares
    k = 0;

    for  k = 1:length(eTp)

            %Posições das Linhas e Colunas dos termopares de referencia
            LTpr = eTp(k,2); CTpr = eTp(k,1);
            
            %Varre todos os termpores do núcleo.
            for iTp = 1:length(eTp)

                %Posições das Linhas e Colunas dos termopares relativos
                %ao termopar de referencia
                LTp = eTp(iTp,2); CTp = eTp(iTp,1);

                %Distância quadratica relativa do termopar para o EC
                DistanciaRelativaTermopar (k, iTp) = sqrt((LTpr - LTp)^2 + (CTpr - CTp)^2); 
                
                RazaoTemperaturas(k, iTp) = vTp(k)/ vTp(iTp);
                
                Alfa(k, iTp) = abs( 1 - RazaoTemperaturas(k, iTp));

            end

            Soma = sum(DistanciaRelativa (k, :));

            SomaDistanciasTermopares(k) = Soma;

            MatrizPesoTermopar(k,:) = DistanciaRelativaTermopar (k, :)./Soma;

    end

    %Armazena os dados relativos aos EC's c/ termpopares em uma Estrura
    %denominada de KernelTp.
    KernelTp.SomaDistancias(:) =  SomaDistanciasTermopares(:);
    KernelTp.DistanciaRelativa(:, :) =  DistanciaRelativaTermopar (:, :);    
    KernelTp.RazaoTemperaturas(:,:) =  RazaoTemperaturas(:,:);
    KernelTp.MatrizPeso(:,:) =  MatrizPesoTermopar(:,:);
    
%     for iTp = 1:length(eTp)
%         [ExpoenteN] = CalculaRaizes(DistanciaRelativaTermopar, Alfa, iTp)
% 
%          N(iTp) = ExpoenteN
%     end
%     
return 

function [ExpoenteN] = CalculaRaizes(DistanciaRelativaTermopar, Alfa, iTp)

  d = DistanciaRelativaTermopar
  
  C = Alfa
  
  i = iTp
  
  C1 = C(i,1); d1 = d(1,1); C7 = C(i,7); d7 = d(1,7);     C13 = C(i,13); d13 = d(1,13); C19 = C(i,19); d19 = d(1,19); C25 = C(i,25); d25 = d(1,25); C31 = C(i,31); d31 = d(1,31); C37 = C(i,37); d37 = d(1,37);

  C2 = C(i,2); d2 = d(1,2); C8 = C(i,8); d8 = d(1,8);     C14 = C(i,14); d14 = d(1,14); C20 = C(i,20); d20 = d(1,20); C26 = C(i,26); d26 = d(1,26); C32 = C(i,32); d32 = d(1,32); C38 = C(i,38); d38 = d(1,38);

  C3 = C(i,3); d3 = d(1,3); C9 = C(i,9); d9 = d(1,9);     C15 = C(i,15); d15 = d(1,15); C21 = C(i,21); d21 = d(1,21); C27 = C(i,27); d27 = d(1,27); C33 = C(i,33); d33 = d(1,33); C39 = C(i,39); d39 = d(1,39);  

  C4 = C(i,4); d4 = d(1,4); C10 = C(i,10); d10 = d(1,10); C16 = C(i,16); d16 = d(1,16); C22 = C(i,22); d22 = d(1,22); C28 = C(i,28); d28 = d(1,28); C34 = C(i,34); d34 = d(1,34); 

  C5 = C(i,5); d5 = d(1,5); C11 = C(i,11); d11 = d(1,11); C17 = C(i,17); d17 = d(1,17); C23 = C(i,23); d23 = d(1,23); C29 = C(i,29); d29 = d(1,29); C35 = C(i,35); d35 = d(1,35); 

  C6 = C(i,6); d6 = d(1,6); C12 = C(i,12); d12 = d(1,12); C18 = C(i,18); d18 = d(1,18); C24 = C(i,24); d24 = d(1,24); C30 = C(i,30); d30 = d(1,30); C36 = C(i,36); d36 = d(1,36);  

%   C = [C1,C2,C3,
%   D = [d1,d2,d3
% syms n

delta = C(i,:); dist = d(i,:)

 
fun = @(n) funcao(n,delta,dist);

vetor_n = -3:0.01:3;

plot(vetor_n, fun(vetor_n),'r'), grid on

nzero = fzero(fun,-10)





 Equacao = C1*(d1)^(n) +  C2*(d2)^(n) + C3*(d3)^(n) + C4*(d4)^(n) + C5*(d5)^(n) + C6*(d6)^(n) + C7*(d7)^(n) + C8*(d8)^(n) + C9*(d9)^(n) + C10*(d10)^(n)...
           + C11*(d11)^(n) +  C12*(d12)^(n) + C13*(d13)^(n) + C14*(d14)^(n) + C15*(d15)^(n) + C16*(d16)^(n) + C17*(d17)^(n) + C18*(d18)^(n) + C19*(d19)^(n) + C20*(d20)^(n)...
           + C21*(d21)^(n) +  C22*(d22)^(n) + C23*(d23)^(n) + C24*(d24)^(n) + C25*(d25)^(n) + C26*(d26)^(n) + C27*(d27)^(n) + C28*(d28)^(n) + C29*(d29)^(n) + C30*(d30)^(n)...
           + C31*(d31)^(n) +  C32*(d32)^(n) + C33*(d33)^(n) + C34*(d34)^(n) + C35*(d35)^(n) + C36*(d36)^(n) + C37*(d37)^(n) + C38*(d38)^(n) + C39*(d39)^(n) == 0
%  options = optimoptions("ga","PlotFcn","gaplotbestf");
%  
% rng default % For reproducibility
% [sol,fval] = solve(Equacao,"Solver","ga","Options",options)

 n = solve (Equacao,n)

 ExpoenteN = double(n)

return





