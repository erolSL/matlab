function [mn st] = bg_model(f)
    % Example using:   [mn st] = bg_model('002.mpg');

    reader = mmreader(f);                   % videoyu framelerine ay�rmak i�in okuma de�i�kenine ata
    N = get(reader, 'numberOfFrames') - 1;  % video i�erisinde ka� frame oldu�unu ata
    frames = read(reader, [1, N]);          % videonun N adet frameni oku ve ata

    [R, C, L] = size(frames(:, :, :, 1));   % frameler i�in sat�r ve s�tun say�lar�n� al (R=sat�r say�s� ve C=s�tun say�s� olarak ata)
    I_mn = uint8([]);                       % framelerin pixel ortalamalar�n�n tutulaca�� de�i�ken
    I_st = [];                              % framelerin pixel standart sapmalar�n�n tutulaca�� de�i�ken
    for r = 1 : R
        for c = 1 : C
            pixel_rc = {[] [] []};          % framelerin her bir pixelinin k�rm�z�, ye�il, mavi de�erlerini tutmak i�in ceil(h�cre) kullan
            for i = 1 : N
                pixel_rc{1}(i) = frames(r, c, 1, i); % her bir framenin r sat�r, c s�tun numaralar� k�rm�z� renk de�erini al
                pixel_rc{2}(i) = frames(r, c, 2, i); % her bir framenin r sat�r, c s�tun numaralar� ye�il renk de�erini al
                pixel_rc{3}(i) = frames(r, c, 3, i); % her bir framenin r sat�r, c s�tun numaralar� mavi renk de�erini al
            end
            I_mn(r, c, 1) = mean(pixel_rc{1});       % framelerin r sat�r, c s�tun numaralar� k�rm�z� renk de�erlerinin ortalamas�n� hesapla
            I_mn(r, c, 2) = mean(pixel_rc{2});       % framelerin r sat�r, c s�tun numaralar� ye�il renk de�erlerinin ortalamas�n� hesapla
            I_mn(r, c, 3) = mean(pixel_rc{3});       % framelerin r sat�r, c s�tun numaralar� mavi renk de�erlerinin ortalamas�n� hesapla
            I_st(r, c, 1) = std(pixel_rc{1});        % framelerin r sat�r, c s�tun numaralar� k�rm�z� renk de�erlerinin standart sapmas�n� hesapla
            I_st(r, c, 2) = std(pixel_rc{2});        % framelerin r sat�r, c s�tun numaralar� ye�il renk de�erlerinin standart sapmas�n� hesapla
            I_st(r, c, 3) = std(pixel_rc{3});        % framelerin r sat�r, c s�tun numaralar� mavi renk de�erlerinin standart sapmas�n� hesapla
        end
    end

    mn = I_mn; % d�n�� de�erlerine ata
    st = I_st; % d�n�� de�erlerine ata