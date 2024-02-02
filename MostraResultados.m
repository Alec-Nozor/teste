%***************************************************************************
% Essa função cálcula o erro relativo do método dos fatores pesos com respeito 
% ao valor de referência.
%***************************************************************************
function [KernelECS] = MostraResultados(iQ, ECTermopar, KernelECS)
    
    eTp(:,:) = ECTermopar.LocalizacaoTermopar(:,:);
    
    TemperaturaMediaEstimada = (ECTermopar.TemperaturaMedia(:,1) + KernelECS.TemperaturaMediaEstimadaEC)/2;
    
    TemperaturaMediaReal = ECTermopar.TemperaturaMedia(:,2);
    
    DesvioTemperaturaMedio = abs(TemperaturaMediaReal - TemperaturaMediaEstimada);
    
    ErroRelativo(:) = KernelECS.ErroRelativo(:) ;
     
    PosicaoErroMaximo = KernelECS.Erro(:,1);
    
    PosicaoEC(:, :) = KernelECS.PosicaoEC(:,:);
        
    ErroRelativoMaximo = KernelECS.Erro(:,2);
    
    ErroRelativoMedio = KernelECS.Erro(:,3);

              
    for iEC = 1:length(PosicaoEC)

        %Posições das Linhas e Colunas dos termopares, ou seja,
        %a posição y e x dos termopares.
        yEC = PosicaoEC(iEC,2); xEC = PosicaoEC(iEC,1);

        %Distância quadratica relativa do termopar para o EC
        NucleErroRelativo (yEC, xEC) =  ErroRelativo(iEC); 
        
        if (iEC == PosicaoErroMaximo)          
            LinaErroMaximo = yEC;
            ColunaErroMaximo = xEC;              
        end

    end
    
    KernelECS.NucleErroRelativo(:,:) = NucleErroRelativo(:,:);
    
    %***************************************************************************
    % Construindo o Gráfico
    %***************************************************************************
    scrsz = get(0, 'ScreenSize');
    strName = sprintf('Mapa de Posicao de Termopares');
    hfig = figure('ToolBar','none','Color','White','Name',strName, ...
                  'Position', [1 scrsz(4) scrsz(3) scrsz(4)]);

   
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
    for iEC = 1:length(PosicaoEC)
        
        yEC = PosicaoEC(iEC,2); xEC = PosicaoEC(iEC,1);
        plot(xEC,yEC,'b.')
        text(xEC,yEC,sprintf('%.3g', NucleErroRelativo(yEC,xEC)), ...
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
        
    strA = 'iQ - ';
    
    strB = string(iQ);
    
    strC = ' - ER-MAXIMO = ' + string(ErroRelativoMaximo) + ' %' + ' ';
    
    strD = '(' + string(LinaErroMaximo) + ', ' + string(ColunaErroMaximo) + ')';
    
    strE = ' - ER-MEDIO = ' + string(ErroRelativoMedio) + ' %' + ' ';   
    
    strF = ' - TMR = ' + string(TemperaturaMediaReal) + ' ºC' + ' '; 
    
    strG = ' - TME = ' + string(TemperaturaMediaEstimada) + ' ºC' + ' ';
    
    strH = ' - DESVIO = ' + string(DesvioTemperaturaMedio) + ' ºC' + ' '; 
    
    strTitulo =  strA + strB + strC + strD + strE + strF + strG + strH;
    title (strTitulo     ,'Color','Blue','FontSize',11,'FontAngle','Italic')

    box on, grid on, axis ij
    drawnow;

    return
end