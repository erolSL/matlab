function I = bg_remove(fg, bg)
    % Example using:   bg_remove('006.mpg', '002.mpg')

    [mn st] = bg_model(bg);

    reader = mmreader(fg);                  % videoyu framelerine ay�rmak i�in okuma de�i�kenine ata
    N = get(reader, 'numberOfFrames') - 1;  % video i�erisinde ka� frame oldu�unu ata
    frames = read(reader, [1, N]);          % videonun N adet frameni oku ve ata
    dir_name = 'frames';                   % framelerin kay�dolaca�� dizin ismi
    mkdir(dir_name);                        % framelerin kay�dolaca�� dizini olu�tur
    rmdir(dir_name,'s');
    mkdir(dir_name);                        % framelerin kay�dolaca�� dizini olu�tur

    [R, C, L] = size(frames(:, :, :, 1));   % frameler i�in sat�r ve s�tun say�lar�n� al (R=sat�r say�s� ve C=s�tun say�s� olarak ata)

    I = uint8([]);
    for i = 1 : N
        I(:, :, 1) = abs(double(frames(:, :, 1, i)) - double(mn(:, :, 1))); % her framenin k�rm�z� de�erlerinin ortalama k�rm�z� de�erlerden fark�n� al
        I(:, :, 2) = abs(double(frames(:, :, 2, i)) - double(mn(:, :, 2))); % her framenin ye�il de�erlerinin ortalama ye�il de�erlerden fark�n� al
        I(:, :, 3) = abs(double(frames(:, :, 3, i)) - double(mn(:, :, 3))); % her framenin mavi de�erlerinin ortalama mavi de�erlerden fark�n� al
        Y = zeros(R, C);
        Y(I(:, :, 2) >= 15 * st(:, :, 2)) = 1;

        se = strel('disk', 7);
        Y = imopen(Y, se);
        Y = imclose(Y, se);

        label = bwlabel(Y);
        s = regionprops(label, 'Area');
        id = find([s.Area] > 1000);
        Y = ismember(label, id);

        frame_name = strcat(dir_name, '\frame', num2str(i), '.jpg'); % frame ismi ata
        imwrite(Y, frame_name, 'jpg');                              % frame kaydet
    end
end