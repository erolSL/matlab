function [mn st] = bg_model(f)
    % Example using:   [mn st] = bg_model('002.mpg');

    reader = mmreader(f);                   % videoyu framelerine ayýrmak için okuma deðiþkenine ata
    N = get(reader, 'numberOfFrames') - 1;  % video içerisinde kaç frame olduðunu ata
    frames = read(reader, [1, N]);          % videonun N adet frameni oku ve ata

    [R, C, L] = size(frames(:, :, :, 1));   % frameler için satýr ve sütun sayýlarýný al (R=satýr sayýsý ve C=sütun sayýsý olarak ata)
    I_mn = uint8([]);                       % framelerin pixel ortalamalarýnýn tutulacaðý deðiþken
    I_st = [];                              % framelerin pixel standart sapmalarýnýn tutulacaðý deðiþken
    for r = 1 : R
        for c = 1 : C
            pixel_rc = {[] [] []};          % framelerin her bir pixelinin kýrmýzý, yeþil, mavi deðerlerini tutmak için ceil(hücre) kullan
            for i = 1 : N
                pixel_rc{1}(i) = frames(r, c, 1, i); % her bir framenin r satýr, c sütun numaralarý kýrmýzý renk deðerini al
                pixel_rc{2}(i) = frames(r, c, 2, i); % her bir framenin r satýr, c sütun numaralarý yeþil renk deðerini al
                pixel_rc{3}(i) = frames(r, c, 3, i); % her bir framenin r satýr, c sütun numaralarý mavi renk deðerini al
            end
            I_mn(r, c, 1) = mean(pixel_rc{1});       % framelerin r satýr, c sütun numaralarý kýrmýzý renk deðerlerinin ortalamasýný hesapla
            I_mn(r, c, 2) = mean(pixel_rc{2});       % framelerin r satýr, c sütun numaralarý yeþil renk deðerlerinin ortalamasýný hesapla
            I_mn(r, c, 3) = mean(pixel_rc{3});       % framelerin r satýr, c sütun numaralarý mavi renk deðerlerinin ortalamasýný hesapla
            I_st(r, c, 1) = std(pixel_rc{1});        % framelerin r satýr, c sütun numaralarý kýrmýzý renk deðerlerinin standart sapmasýný hesapla
            I_st(r, c, 2) = std(pixel_rc{2});        % framelerin r satýr, c sütun numaralarý yeþil renk deðerlerinin standart sapmasýný hesapla
            I_st(r, c, 3) = std(pixel_rc{3});        % framelerin r satýr, c sütun numaralarý mavi renk deðerlerinin standart sapmasýný hesapla
        end
    end

    mn = I_mn; % dönüþ deðerlerine ata
    st = I_st; % dönüþ deðerlerine ata