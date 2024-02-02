function  [ECTermopar] = ObterDadosTermopar(NucleoQueima)

    %eT =['a07'; 'b05'; 'b07'; 'c03'; 'c06'; 'c08'; 'c11'; 'd02'; 'd05'; 'd07'; ...
    %     'd12'; 'e04'; 'e06'; 'e10'; 'f09'; 'f12'; 'g01'; 'g02'; 'g04'; 'g07'; ...
    %     'g12'; 'h06'; 'h09'; 'h10'; 'h11'; 'h13'; 'i02'; 'i04'; 'i07'; 'i10'; ...
    %     'j03'; 'j06'; 'j08'; 'j09'; 'k03'; 'k11'; 'l07'; 'l10'; 'm06'];

    eTp = [[01,07]; [02,05]; [02,07]; [03,03]; [03,06]; [03,08]; [03,11]; [04,02]; [04,05]; [04,07]; ...
           [04,12]; [05,04]; [05,06]; [05,10]; [06,09]; [06,12]; [07,01]; [07,02]; [07,04]; [07,07]; ...
           [07,12]; [08,06]; [08,09]; [08,10]; [08,11]; [08,13]; [09,02]; [09,04]; [09,07]; [09,10]; ...
           [10,03]; [10,06]; [10,08]; [10,09]; [11,03]; [11,11]; [12,07]; [12,10]; [13,06]];

    eTp1 = eTp(:,1); eTp2 = eTp(:,2);
    eTp = [eTp2, eTp1]; % Guarda as posiçoes do termopar em um vetor 39x2.

    %Monta a matriz NucleoTemperaturas. Isto é, a matriz que contem as
    %medidas da temperatura fornecidas pelos termopares.
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
       
    vTp = vTp'; % Guarda a temperatura dos termopares em um vetor.
    
    % Guarda na estrutura de dados ECTemopar o valor real das temperaturas
    % dos termopares, bem como suas posicoes no nucleo e tambem o mapa de
    % de temperatura dos termopares.
    ECTermopar.ValorTemperatura(:) = vTp(:);
    ECTermopar.LocalizacaoTermopar(:, :) = eTp(:,:);
    ECTermopar.Temperaturas(:, :) = NucleoTemperaturas(:,:);

    
    return
end