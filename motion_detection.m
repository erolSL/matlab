function [people] = motion_detection
    % Example using :
    % ilk_frame ve son_frame'in deðerlerini
    % deðiþtirerek sonuçlarý görebilirsiniz.
    % denemek için örnek girdiler:
    %   ilk_frame = 1    140   195   195
    %   son_frame = 375  211   375   211

    I = {};
    ilk_frame = 1;
    son_frame = 375;
    j = 1;
    for i = ilk_frame:son_frame
        frame_name = strcat('frames\frame', num2str(i), '.jpg'); % frame ismi ata
        I{j} = imread(frame_name);
        j = j + 1;
    end

    N = length(I);
    [R C] = size(I{1}); % 1. frame gibi

    people = struct('arm_angle', [0], 'arm_width', [0], 'count', [0], 'area', {[0]}, 'bound', {[0]});   % iki insan için bilgiler

    for i = 1:N
        P = im2bw(I{i});
        L = bwlabel(P);
        s = regionprops(L, 'all');
        areas = [s.Area];
        % parazitleri yok et /( ortalama ile minumum arasýndaki alanlarý yok et)
        id = find(areas > (mean(areas) - min(areas))); 
        bw = ismember(L, id);
        % tekrar al
        L = bwlabel(bw);
        s = regionprops(L, 'all');
        b = [s.BoundingBox];
        c = [s.Centroid];
        area = [s.Area];
        people.count(i) = length(area);
        for p = 1 : people.count(i)
            people.area(i, p) = area(p);
        end
        for p = 1 : length(b)
            people.bound(i, p) = b(p);
        end
        if length(b) > 0 && length(b) <= 4
            for p = length(b):2*length(b)
                people.bound(i, p) = 0;
            end
        end

        if length(b) > 0
            p1c = floor(b(1));
            p1r = floor(b(2));
            p1c_width = floor(b(3));
            p1r_width = floor(b(4));

            arm_x = p1c + p1c_width;
            arm_y = mean(find(P(:, arm_x) == 1));

            p1x = c(1);
            p1y = c(2);
            oran = (arm_y - p1y) / (arm_x - p1x);
            if oran < 0
                arm_alfa = rad2deg(atan(90 + abs(oran)));
            else            
                arm_alfa = rad2deg(atan(1 / oran));
            end

            people.arm_angle(i, 1) = arm_alfa;
            people.arm_width(i, 1) = arm_x - p1x;

            if ((p1r + p1r_width) <= R) & ((p1c + p1c_width) <= C) & (p1c > 0)
                % sadece p1 resimleri gösterilmek istenirse
                % figure, imshow(P(p1r:p1r+p1r_width, p1c:p1c+p1c_width))
            end
        end
        if length(b) > 4
            p2c = floor(b(5));
            p2r = floor(b(6));
            p2c_width = floor(b(7));
            p2r_width = floor(b(8));

            arm_x = p2c + p2c_width;
            arm_y = mean(find(P(:, arm_x) == 1));

            p2x = c(3);
            p2y = c(4);

            arm_alfa = rad2deg(atan((arm_x - p2x) / (arm_y - p2y)));

            people.arm_angle(i, 2) = arm_alfa;
            people.arm_width(i, 2) = arm_x - p2x;

            if ((p2r + p2r_width) <= R) & ((p2c + p2c_width) <= C) & (p2c > 0)
                % sadece p2 resimleri gösterilmek istenirse
                % figure, imshow(P(p2r:p2r+p2r_width, p2c:p2c+p2c_width)) %
            end
        end
    end

    % together and untogether ? 
    % birlikte olup ayrýlýyorlar mý tespit et
    together_index = 0;
    untogether_index = 0;
    together_state = false;
    untogether_state = false;
    for i = 1:length(people.count)-1
        if people.count(i) ~= 0
            p1_right = people.bound(i, 1) + people.bound(i, 3);
            p2_left = people.bound(i, 5);
            p_width = p2_left - p1_right;
            if p1_right < C
                if together_state == false && p_width < people.bound(i, 3) && people.count(i + 1) < people.count(i)   % kiþi sayýsý azalýyorsa
                    together_index = i;
                    together_state = true;
                end
                if untogether_state == false && p_width < people.bound(i, 3) && people.count(i + 1) > people.count(i) % kiþi sayýsý artýyorsa
                    untogether_index = i;
                    untogether_state = true;
                end
            end
        end
    end

    % p1 arm angle with bounding box and motion starting ?
    % kol merkezden açýsý artýyorsa haraket baþlama zamanýný yakala
    motion_starting_index = 0;
    motion_starting_state = false;
    p1_mean_width = mean(people.bound(:, 3));
    if together_state
        for i = together_index-1:-1:1
            if p1_mean_width < people.bound(i, 3) & people.arm_angle(i) < people.arm_angle(i + 1)
                motion_starting_state = true;
            elseif motion_starting_state == true
                motion_starting_index = i + 1;
                break;
            end
        end
    end

    % p2 bounding_box and motion ending ?
    % p2 hareketini ne zaman bitiriyor
    motion_ending_index = 0;
    motion_ending_state = false;
    p2_mean_width = mean(people.bound(:, 7));
    if untogether_state
        for i = untogether_index:N
            if p2_mean_width < people.bound(i, 7)
                motion_ending_index = i;
                motion_ending_state = true;
                break;
            end
        end
    end

    % p1 and p2 together motion ?
    % p1 ve p2 birlikte hareketi sýrasýnda geniþliklerinde
    % büyüme küçülme %70 oranýnda oluyorsa yakala
    together_motion_state = false;
    if together_state || untogether_state ||  unique(people.count) == 1
        if together_state == false
            together_index = 1;
        end
        if untogether_state == false
            untogether_index = N;
        end
        motion_width = [];
        for i = together_index+1:untogether_index
             motion_width(end + 1) = people.bound(i, 3);
        end
        if motion_width
            start = motion_width(1:round(length(motion_width)/2));
            stop = motion_width(round(length(motion_width)/2):end);

            start_like = 0;
            reverse_start = wrev(sort(start));
            for i = 1:length(start)
                if start(i) == reverse_start(i)
                    start_like = start_like + (100/length(start));
                end
            end
            stop_like = 0;
            sort_stop = sort(stop);
            for i = 1:length(stop)
                if stop(i) == sort_stop(i)
                    stop_like = stop_like + (100/length(stop));
                end
            end
            if stop_like > 70 && start_like > 70 % benzerlik oranlarý
                together_motion_state = true;
            end
        end
    end

    percent = 0;
    if motion_starting_state
        fprintf('- p1 biþiler yapmaya baþladý:%d\n', motion_starting_index);
        frame_no = ilk_frame+motion_starting_index;
        figure(frame_no), imshow(imread(strcat('frames\frame', num2str(frame_no), '.jpg')));
        percent = percent + 35;
    end
    if together_state
        fprintf('- birlikte oldular:%d\n', together_index);
        frame_no = ilk_frame+together_index;
        figure(frame_no), imshow(imread(strcat('frames\frame', num2str(frame_no), '.jpg')));
        percent = percent + 10;
    end
    if together_motion_state
        fprintf('- birlikte iken küçülme ve büyüme oldu:[%d-%d]\n', together_index, untogether_index);
        percent = percent + 20;
    end
    if untogether_state
        fprintf('- ayrýldýlar:%d\n', untogether_index);
        frame_no = ilk_frame+untogether_index;
        figure(frame_no), imshow(imread(strcat('frames\frame', num2str(frame_no), '.jpg')));
        percent = percent + 10;
    end
    if motion_ending_state
        fprintf('- p2ye biþiler oldu:%d\n', motion_ending_index);
        frame_no = ilk_frame+motion_ending_index;
        figure(frame_no), imshow(imread(strcat('frames\frame', num2str(frame_no), '.jpg')));
        percent = percent + 25;
    end
    fprintf('> itme durumu: |%% %d|\n', percent);
    if (percent > 60)
        fprintf('[!] %%60 ý geçtiði için itme var\n');
    else
        fprintf('[o] %%60 ý geçmediði için itme yok\n');
    end
    people;