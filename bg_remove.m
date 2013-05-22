function I = bg_remove(fg, bg)
    % Example using:   bg_remove('006.mpg', '002.mpg')

    [mn st] = bg_model(bg);

    reader = mmreader(fg);                  % videoyu framelerine ayýrmak için okuma deðiþkenine ata
    N = get(reader, 'numberOfFrames') - 1;  % video içerisinde kaç frame olduðunu ata
    frames = read(reader, [1, N]);          % videonun N adet frameni oku ve ata
    dir_name = 'frames';                   % framelerin kayýdolacaðý dizin ismi
    mkdir(dir_name);                        % framelerin kayýdolacaðý dizini oluþtur
    rmdir(dir_name,'s');
    mkdir(dir_name);                        % framelerin kayýdolacaðý dizini oluþtur

    [R, C, L] = size(frames(:, :, :, 1));   % frameler için satýr ve sütun sayýlarýný al (R=satýr sayýsý ve C=sütun sayýsý olarak ata)

    I = uint8([]);
    for i = 1 : N
        I(:, :, 1) = abs(double(frames(:, :, 1, i)) - double(mn(:, :, 1))); % her framenin kýrmýzý deðerlerinin ortalama kýrmýzý deðerlerden farkýný al
        I(:, :, 2) = abs(double(frames(:, :, 2, i)) - double(mn(:, :, 2))); % her framenin yeþil deðerlerinin ortalama yeþil deðerlerden farkýný al
        I(:, :, 3) = abs(double(frames(:, :, 3, i)) - double(mn(:, :, 3))); % her framenin mavi deðerlerinin ortalama mavi deðerlerden farkýný al
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