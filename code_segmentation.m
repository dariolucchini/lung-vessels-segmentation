OutputFolder ='-'; %directory 

dinfo= dir ('*.png'); % image extension
for K = 1 : length(dinfo)
    thisimage = dinfo(K).name;
    I   = imread(thisimage);
    %highpass emphasize filter
    
    H1 = fspecial('average', [3 3]);
    Img = imfilter(I, H1); 
    %highpass
    Img = im2double(Img);
    Img = log(1 + Img);
    M = 2*size(Img,1) + 1;
    N = 2*size(Img,2) + 1;
    sigma = 10;      %deviazione standard per la gaussiana che determina ampiezza della banda a basse frequenze in output
    [X, Y] = meshgrid(1:N,1:M);
    centerX = ceil(N/2);
    centerY = ceil(M/2);
    gaussianNumerator = (X - centerX).^2 + (Y - centerY).^2;
    H = exp(-gaussianNumerator./(2*sigma.^2));
    H = 1 - H;
    %facciamo un passa alto facendo un passa basso e togliendolo a 1 (centered filter)

    H = fftshift(H);   %non centrato così
    If = fft2(Img, M, N);         %FFT dell'immagine con zero padding
    Iout = real(ifft2(H.*If));  %applico filtro
    Iout = Iout(1:size(Img,1),1:size(Img,2));   %ritorniamo a size originale (senza padding)
    Ihmf = exp(Iout) - 1;   %back to non logaritmoù
    
    %emphasize
    alpha = 0.5;                %fattori di correzione per avere contrasto migliore
    beta = 1.5;
    Hemphasis = alpha + beta*H;

    If = fft2(Img, M, N);
    Iout = real(ifft2(Hemphasis.*If));
    Iout = Iout(1:size(Img,1),1:size(Img,2));

    Ihmf_2 = exp(Iout) - 1;    %fine filtering
    
    

    format long g;
    format compact;
    fontSize = 20;

    reg_maxdist=0.16;   %treshold per segmentazione
    figure, imshow(Ihmf_2)
    [yi,xi] = ginput(2);     %seed selection
    xi=round(xi);
    yi=round(yi);
    
    %region growing
    J=regiongrowing(Ihmf_2,xi(1),yi(1),reg_maxdist);
    J2=regiongrowing(Ihmf_2,xi(2), yi(2),reg_maxdist);
    figure, imshow(Ihmf_2+J2+J) 
    J_logical=any(J,3);
    J2_logical=any(J2,3);
    figure, imshow(J_logical+J2_logical)
    
    %per salvare nuove immagini
    s3=string(K);
    s2=strcat(string(K),'.png');
    if K<10
        s1={'FINAL_VESSEL12_0'};       
    else
        s1={'FINAL_VESSEL12_'};
    end
    saveas(gcf,strcat(strcat(s1,s3),'.png'))

end
