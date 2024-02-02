function [ECTermopar, KernelECS] = MontaMatrizePeso(NucleoQueima, ECTermopar, n)
        
    %Constro uma estrutura de dados que guarda os dados dos EC's s/
    nL=13; nC=13;
    k = 0;
    
    NucleoTemperaturas (:,:) = ECTermopar.Temperaturas(:, :);
    
    eTp(:,:) = ECTermopar.LocalizacaoTermopar(:,:);
    
    %A vatiavel iy corresponde as linhas da matriz que sera montada e ix
    %corresponde as colunas.
    for iy = 1:nL
        for ix = 1:nC
                    
            %Esse if localiza as posições de EC's sem termopar.
            if (NucleoTemperaturas(iy, ix)~= 1.0) && (NucleoTemperaturas(iy, ix)== 0.0)                      
                k = k + 1;

                EC_y(k) = iy;  %Guarda a posição linha ou o y do EC sem termopar
                EC_x(k) = ix; %Guarda a posição coluna ou x do EC sem termopar
                
                %GUarda as temperaturas de referencia dos EC's sem temoopar
                %para comparacao com a TemperaturaEstimada no EC.
                TemperaturaReferenciaEC (k) = NucleoQueima(iy, ix);

                %Mede a distância de todos os termpores do núcleo com
                %respeito ao EC sem termopar na posicao  EC_y(k),  EC_x(k).
                for iTp = 1:length(eTp)

                    %Posições das Linhas e Colunas dos termopares, ou seja,
                    %a posição y e x dos termopares.
                    yTp = eTp(iTp,2); xTp = eTp(iTp,1);

                    %Distância quadratica relativa do termopar para o EC
                    DistanciaRelativa (k, iTp) = sqrt((iy - yTp)^2 + (ix - xTp)^2); 

                end
                
                DistanciaRelativa_n (k,:) = DistanciaRelativa(k,:).^(n);
                
                SomaDenominado(k) = sum(DistanciaRelativa_n (k, :));
                                 
                %Monta a Matriz Peso 
                MatrizPeso(k,:) = DistanciaRelativa_n (k, :)./SomaDenominado(k);
                           
            end
        end
    end
    
   
    PosicaoEC(:,1) = EC_x(:);
    
    PosicaoEC(:,2) = EC_y(:);

    for  k = 1:length(eTp)

            %Posições das Linhas e Colunas dos termopares de referencia.
            %Isto e a posição y e x do termopar de referência.
            yTpr = eTp(k,2); xTpr = eTp(k,1);
            
            %Varre todos os termpores do núcleo.
            for iTp = 1:length(eTp)

                %Posições das Linhas e Colunas dos termopares relativos
                %ao termopar de referencia
                yTp = eTp(iTp,2); xTp = eTp(iTp,1);

                %Distância quadratica relativa do termopar para o EC
                DistanciaRelativaTermopar (k, iTp) = sqrt((yTpr - yTp)^2 + (xTpr - xTp)^2); 

            end
            
            DistanciaRelativaTermopar_n (k,:) = DistanciaRelativaTermopar(k,:).^(n);
            
            %Trata a matriz DistanciaRelativaTermopar_n, ou seja,  a matriz
            %DistanciaRelativaTermopar elevada a n, de modo, a retirar o
            %infinito para os casos em que n<0. Neste casos os infinitos da
            %diagonal principal são substituidos por zeros, o que não altera 
            % o resultado final, uma vez que proprio termopar nao e
            %considerado para o calculo.
            if n<0
                DistanciaRelativaTermopar_n (k, k) = 0.0;
            end

            SomaDenominadoTermopar(k) = sum(DistanciaRelativaTermopar_n (k, :));

            %Monta a Matriz Peso Termopares referência 
            MatrizPesoTermopar(k,:) = DistanciaRelativaTermopar_n (k, :)./SomaDenominadoTermopar(k);

    end

    ECTermopar.MatrizPesoTermopar(:,:) = MatrizPesoTermopar(:,:);
    
    KernelECS.MatrizPeso(:,:) = MatrizPeso(:, :);
    
    KernelECS.TemperaturaReferenciaEC(:) = TemperaturaReferenciaEC(:);
    
    KernelECS.PosicaoEC(:,:) = PosicaoEC(:, :);
    
    
    return 
end